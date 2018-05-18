//
//  FollowerListVC.swift
//  Rack
//
//  Created by hyperlink on 17/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit


class FollowerListVC: BaseViewController {

    //MARK:- Outlet
    
    @IBOutlet weak var tblUser: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var vcType           : FollowType? = nil
    
    var arrayFollow      : [FollowModel] = []
    var arrayOperational : [FollowModel] = []
    var userData         : UserModel? = nil
    var page             : Int = 1
    var isWSCalling      : Bool = true

    //------------------------------------------------------
    
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        //print("Follower Deinit....")

        //remove observer
        NotificationCenter.default.removeObserver(kNotificationFollowListUpdate)
        NotificationCenter.default.removeObserver(kNotificationUserDetailsUpdate)
    }

    //------------------------------------------------------
    
    //MARK:- Custom Method
    func setUpView() {
        
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.delegate = self
        //searchBar.tintColor = AppColor.primaryTheme

        guard let _  = self.userData, let _ = vcType?.rawValue  else {
            //print(":::::::::::::-Something went to wronf in FollowerListVC-:::::::::::::")
            return
        }

        //add notification for profile update
        NotificationCenter.default.addObserver(self, selector: #selector(notificationFollowListUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: nil)

        //setUp for pull to refresh
        self.setupPullToRefresh()

        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.tblUser.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
        infinityIndicator.startAnimating()
        
        //call API with page 1
        tblUser.ins_beginInfinityScroll()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
        
        //Google Analytics
        
        let category = "UI"
        let action = "\(UserModel.currentUser.displayName!) view \(String(describing: vcType?.rawValue)) list"
        let lable = ""
        let screenName: String = (vcType?.rawValue)!
        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
        
        //Google Analytics
        
         self.navigationController?.customize()
    }
    
    func setupPullToRefresh() {
        
        tblUser.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            
            if self.isWSCalling {
                self.isWSCalling = false
                
                guard let searchBar = self.searchBar else {
                    return
                }
                
                //if search bar have text then not require to call Pagination API
                if !(searchBar.text!.isEmpty) {
                    return
                }
                
                //call API
                let requestModel = RequestModel()
                requestModel.user_id = self.userData?.userId
                requestModel.user_type = self.vcType?.rawValue
                requestModel.page = String(format: "%d", (self.page))
                
                self.callFollowAPI(requestModel) { (isSuccess : Bool, jsonResponse : JSON?) in
                    scrollView?.ins_endInfinityScroll(withStoppingContentOffset: true)
                    
                    //response with data
                    if isSuccess  {
                        
                    } else {
                        if self.page == 1 {
                            if (jsonResponse?.stringValue) != nil {
                                GFunction.shared.showPopup(with: (jsonResponse?.stringValue)!, forTime: 2, withComplition: {
                                }, andViewController: self)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func callAfterServiceResponse(_ data : JSON) {

        arrayFollow.append(contentsOf: FollowModel.modelsFromDictionaryArray(array: data.arrayValue))
        arrayOperational = arrayFollow
        
        guard tblUser != nil else {
            return
        }
        
        tblUser.reloadData()
        
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationFollowListUpdate(_ notification : Notification) {
        /* Notification Post Method call
         1. FollowerVC Click on follow/following
         2.
         */

        //print("============Notification Method Called=================")
        //print(notification.object!)
        
        guard let jsonData   = notification.object as? JSON else {
            return
        }

        let notiFollowData = FollowModel(fromJson: jsonData)
        
        //change main data
        arrayFollow = arrayFollow.map { (objFollow : FollowModel) -> FollowModel in
            
            if objFollow.userId == notiFollowData.userId {
                return notiFollowData
            } else {
                return objFollow
            }
        }
        
        
        arrayFollow = arrayFollow.filter({ (objFollow : FollowModel) -> Bool in
            
            if objFollow.isFollowing.lowercased() == "unblock" {
                return false
            } else {
                return true
            }
            
        })
        
        //change operational data
        arrayOperational = arrayOperational.map { (objFollow : FollowModel) -> FollowModel in
            
            if objFollow.userId == notiFollowData.userId {
                return notiFollowData
            } else {
                return objFollow
            }
        }
        
        arrayOperational = arrayOperational.filter({ (objFollow : FollowModel) -> Bool in
            
            if objFollow.isFollowing.lowercased() == "unblock" {
                return false
            } else {
                return true
            }
            
        })

        tblUser.reloadData()
        
        
    }
    
    func notificationUserDetailsUpdate(_ notification : Notification) {
        
        guard let _  = tblUser else {
            return
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblUser.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }

    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callFollowAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/user_list
         
         Parameter   : user_type[follower,following],user_id
         
         Optional    : page,search_value
         
         Comment     : This api will used for any user get follower and following list.
         
         
         ==============================
         
         */
        
        APICall.shared.CancelTask(url: kMethodUserList)
        
        APICall.shared.POST(strURL: kMethodUserList
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            self.isWSCalling = true
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    self.callAfterServiceResponse(response[kData])
                    self.page = (self.page) + 1
                    
                    block(true,response[kData])
                    break
                    
                default:
                    //stop pagination
                    self.tblUser.ins_removeInfinityScroll()
                    
                    block(false,response[kMessage])
                    break
                }
            } else {
                block(false,nil)
                
            }
        }
        
    }
   
    func callFollowSearchAPI() {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/user_list
         
         Parameter   : user_type[follower,following],user_id
         
         Optional    : page,search_value
         
         Comment     : This api will used for any user get follower and following list.
         
         
         ==============================
         
         */
        
        if searchBar.text == "" {
            return
        }
        
        let requestModel = RequestModel()
        requestModel.user_id = self.userData!.userId
        requestModel.user_type = self.vcType!.rawValue
        requestModel.search_value = searchBar.text
        
        APICall.shared.POST(strURL: kMethodUserList
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    self.arrayOperational = FollowModel.modelsFromDictionaryArray(array: response[kData].arrayValue)

                    guard self.tblUser != nil else {
                        return
                    }
                    self.tblUser.reloadData()

                    break
                    
                default:

                    break
                }
            } else {

            }
        }
        
    }

    
    func callUpdateRequestAPI(_ requstModel : RequestModel
        , withCompletion block:@escaping (Bool,JSON?) -> Void) {
     
        /*
         ===========API CALL===========
         
         Method Name : request/update_request
         
         Parameter   : status[accepted,rejected,blocked,unfollow],user_id
         
         Optional    :
         
         Comment     : This api will used for user update the request.
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodUpdateRequest
        , parameter: requstModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
  
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    block(true,response[kData])
                    break
                    
                default:
                    block(false,nil)
                    break
                }
            } else {
                block(false,nil)
            }
        }
    }
    
    func callSendRequestAPI(_ requstModel : RequestModel
        , withCompletion block:@escaping (Bool,JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/send_request
         
         Parameter   : user_id
         
         Optional    :
         
         Comment     : This api will used for user send to new request
         
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodSendRequest
        , parameter: requstModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int, error : Error?) in

            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    block(true,response[kData])
                    break
                    
                default:
                    block(false,nil)
                    break
                }
            } else {
                block(false,nil)
            }
            
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //------------------------------------------------------
    
    //MARK: ScrollView Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = AppColor.primaryTheme
      self.tblUser.backgroundColor = AppColor.primaryTheme
      self.navigationController?.navigationBar.barTintColor = AppColor.primaryTheme
      self.navigationController?.navigationBar.isTranslucent = false
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch vcType! {
        case .follow:
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "FOLLOWERS")
            break
        case .following:
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "FOLLOWING")
            break
        default :
            //print("Somrthing Wrong.................")
            break
        }

    }

    
}
//MARK: - TableView DataSource Delegate
extension FollowerListVC : PSTableDelegateDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60*kHeightAspectRasio
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOperational.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let objAtIndex = arrayOperational[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
        cell.selectionStyle = .none
        cell.lblUserName.text = objAtIndex.getUserName()
        cell.lblDisplayName.text = objAtIndex.displayName

        cell.imgProfile.setImageWithDownload(objAtIndex.getUserProfile().url())

        cell.btnStatus.setTitle(objAtIndex.isFollowing.capitalized, for: .normal)

        //button state management
        if objAtIndex.isFollowing.lowercased() == FollowType.following.rawValue.lowercased() && objAtIndex.userId != UserModel.currentUser.userId {

            cell.btnStatus.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 12.0), titleLabelColor: UIColor.black, cornerRadius: 5, borderColor: UIColor.black, borderWidth: 0.5, backgroundColor: UIColor.white)
            cell.btnStatus.isHidden = false

        } else if objAtIndex.isFollowing.lowercased() == FollowType.follow.rawValue.lowercased() && objAtIndex.userId != UserModel.currentUser.userId {

            cell.btnStatus.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 12.0), titleLabelColor: UIColor.white, cornerRadius: 5, backgroundColor: UIColor.red)
            cell.btnStatus.isHidden = false

        } else if objAtIndex.isFollowing.lowercased() == FollowType.requested.rawValue.lowercased() && objAtIndex.userId != UserModel.currentUser.userId {

            cell.btnStatus.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 12.0), titleLabelColor: UIColor.black, cornerRadius: 5, backgroundColor: UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1))
            cell.btnStatus.isHidden = false

        } else if  objAtIndex.userId == UserModel.currentUser.userId{

            cell.btnStatus.isHidden = true

        } else {
            
            //FIXME: - Require to check. If any issue then.
            cell.btnStatus.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 13.0), titleLabelColor: UIColor.yellow)
            cell.btnStatus.isHidden = false
        }
        
        //status button click
        cell.btnStatusClicked = {
//            cell.btnStatus.setTitle("", for: .normal)
            //to check current status of button. base on call API

            if objAtIndex.isFollowing.lowercased() == FollowType.following.rawValue.lowercased() {
                
                AlertManager.shared.showAlertTitle(title: "", message: "Unfollow \(objAtIndex.getUserName())?", buttonsArray: ["Unfollow","Cancel"]) { (buttonIndex : Int) in
                    switch buttonIndex {
                    case 0 :
                        //Unfollow clicked

                        objAtIndex.isFollowing = FollowType.follow.rawValue.capitalized
                        
                        //call API
                        let requestModel = RequestModel()
                        requestModel.user_id = objAtIndex.userId
                        requestModel.status = requestStatus.unfollow.rawValue
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: JSON(objAtIndex.toDictionary()))
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUnfollow), object: JSON(objAtIndex.toDictionary()))
                        

                        self.callUpdateRequestAPI(requestModel,
                                                 withCompletion: { (isSuccess : Bool, response : JSON?) in
                                                    
                                                    if isSuccess {
                                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: response)
                                                        
                                                    } else {
                                                        //if request fail then roll back to original
                                                        objAtIndex.isFollowing = FollowType.following.rawValue.capitalized
                                                    }
                        })
                        
                        //to handel crash
                        guard self.tblUser != nil else {
                            return
                        }
                        self.tblUser.reloadRows(at: [indexPath], with: .none)
                        
                        break
                    case 1:
                        //Cancel clicked
                        
                        break
                    default:
                        break
                    }
                    
                }
                
            } else if objAtIndex.isFollowing.lowercased() == FollowType.requested.rawValue.lowercased() {
                
                objAtIndex.isFollowing = FollowType.follow.rawValue.capitalized
                
                //call API
                let requestModel = RequestModel()
                requestModel.user_id = objAtIndex.userId
                requestModel.status = requestStatus.unfollow.rawValue
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: JSON(objAtIndex.toDictionary()))
                
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: JSON(objAtIndex.toDictionary()))
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUnfollow), object: JSON(objAtIndex.toDictionary()))
                
                self.callUpdateRequestAPI(requestModel,
                                          withCompletion: { (isSuccess : Bool, response : JSON?) in
                                            
                                            if isSuccess {
//                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: response)
//
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: response)
                                            } else {
                                                //if request fail then roll back to original
                                                objAtIndex.isFollowing = FollowType.requested.rawValue.capitalized
                                            }
                })
                
                //to handel crash
                guard self.tblUser != nil else {
                    return
                }
                self.tblUser.reloadRows(at: [indexPath], with: .none)
                
            } else if objAtIndex.isFollowing.lowercased() == FollowType.follow.rawValue.lowercased() {
                //Means Not follow. Apply for follower
                
                if (objAtIndex.isPrivateProfile()) {
                    objAtIndex.isFollowing = FollowType.requested.rawValue.capitalized
                } else {
                    objAtIndex.isFollowing = FollowType.following.rawValue.capitalized
                }
                
                let requestModel = RequestModel()
                requestModel.user_id = objAtIndex.userId
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: JSON(objAtIndex.toDictionary()))
                
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: JSON(objAtIndex.toDictionary()))
                
                self.callSendRequestAPI(requestModel,
                                         withCompletion: { (isSuccess : Bool, response : JSON?) in
                                            
                                            if isSuccess {
//                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: response)
//
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: response)
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRackFeedUpdate), object: response)
                                            } else {
                                                //if request fail then roll back to original
                                                objAtIndex.isFollowing = FollowType.follow.rawValue.capitalized
                                            }
                })
                
                //to handel crash
                guard self.tblUser != nil else {
                    return
                }
                self.tblUser.reloadRows(at: [indexPath], with: .none)
            }
            else {
                //print("Require to handel.. Button click.. Please check response isFollowing.")
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let objAtIndex = arrayOperational[indexPath.row]

        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.viewType = .other
        vc.fromPage = .otherPage
        vc.userData = UserModel(fromJson: JSON(objAtIndex.toDictionary()))
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

}
//MARK:- SearchBar Delegate
extension FollowerListVC : UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.setShowsCancelButton(true, animated: true)

        //remove bottomRefresh during search
        self.tblUser.ins_removeInfinityScroll()
        
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.setShowsCancelButton(false, animated: true)

        //if search "" and search editing end then re add bottomRefresh.
        if searchBar.text!.isEmpty {
            self.setupPullToRefresh()
        }

        return true
    }
    

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            arrayOperational = arrayFollow
        } else {
            let predict = NSPredicate(format: "userName CONTAINS[cd] %@ OR userName LIKE[cd] %@",searchText, searchText)
            arrayOperational = arrayFollow.filter { predict.evaluate(with: $0) }

            self.callFollowSearchAPI()
        }
        tblUser.reloadData()
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if range.location == 0 && text == " " {
            return false
        }
        
        if text == "@" || text == "#" {
            return false
        }
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
        searchBar.text = ""
        
        arrayOperational = arrayFollow
        tblUser.reloadData()
    
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
    }
}

