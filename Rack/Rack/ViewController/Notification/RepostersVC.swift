
//  RepostersVC.swift
//  Rack
//  Created by saroj  on 21/03/18.
//  Copyright © 2018 Hyperlink. All rights reserved.

import UIKit

class RepostersVC: UIViewController  {
    
    //MARK:- Outlet
    @IBOutlet weak var tblUser: UITableView!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var arrayLikeList       : [FollowModel] = []
    var dictFromParent      : RepostNotificationModel = RepostNotificationModel()
    var page                : Int = 1
    var isNew               : Int = 0
    var isWSCalling         : Bool = true
    var barButtons: [UIButton] = []
    
    //------------------------------------------------------
    
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        //remove observer
        NotificationCenter.default.removeObserver(kNotificationFollowListUpdate)
        NotificationCenter.default.removeObserver(kNotificationUserDetailsUpdate)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        
        //add notification for profile update
        NotificationCenter.default.addObserver(self, selector: #selector(notificationFollowListUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: nil)
        
        //setup for autoPullTorefresh and paggination
        self.setupPullToRefresh()
        
        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.tblUser.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
        infinityIndicator.startAnimating()
        
        //callAPI for first data
        self.tblUser.ins_beginInfinityScroll()
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
        self.navigationController?.customize()
        
        
        if self.navigationController?.visibleViewController is RepostersVC {
         self.barButtons = self.addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "Reposts")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = self.addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "Reposts")
    }
   
    func setupPullToRefresh() {
        //bottom
        self.tblUser.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            
            if self.isWSCalling {
                self.isWSCalling = false
                
                //Call API
                
                let requestModel = RequestModel()
                requestModel.item_id = self.dictFromParent.itemId
                requestModel.page = String(format: "%d", (self.page))
                requestModel.is_recent = String(format: "%d", (self.isNew))
                
                //call API for bottom data
                
                self.callBlockUserListAPI(requestModel, withCompletion: { (isSuccess : Bool) in
                    
                })
            }
        }
    }
    
    func callAfterServiceResponse(_ data : JSON) {
        
        arrayLikeList.append(contentsOf: FollowModel.modelsFromDictionaryArray(array: data.arrayValue))
        
        guard tblUser != nil else {
            return
        }
        self.tblUser.ins_endInfinityScroll(withStoppingContentOffset: true)
        tblUser.reloadData()
        
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationFollowListUpdate(_ notification : Notification) {
        /* Notification Post Method call
         1. FollowerVC Click on follow/following
         2.
         */
        guard let jsonData   = notification.object as? JSON else {
            return
        }
        
        let notiFollowData = FollowModel(fromJson: jsonData)
        
        //change main data
        arrayLikeList = arrayLikeList.map { (objFollow : FollowModel) -> FollowModel in
            
            if objFollow.userId == notiFollowData.userId {
                return notiFollowData
            } else {
                return objFollow
            }
        }
        
        arrayLikeList = arrayLikeList.filter({ (objFollow : FollowModel) -> Bool in
            
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
    
    func callBlockUserListAPI(_ requestModel : RequestModel, withCompletion block :((Bool) -> Void)?) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : "request/user_reposters_list"
         
         Parameter   :
         
         Optional    :
         
         Comment     : This api will used for user get block user list.
         
         
         ==============================
         
         */
        
        
        APICall.shared.GET(strURL: kMethodUserRepostersList
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int, error : Error?) in
            self.isWSCalling = true
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    self.callAfterServiceResponse(response[kData])
                    self.page = (self.page) + 1
                    
                    block!(true)
                    break
                    
                default:
                    //stop pagination
                    self.tblUser.ins_removeInfinityScroll()
                    
                    block!(false)
                    break
                }
            } else {
                
                block!(false)
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
            , parameter: requstModel.toDictionary())
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    block(true,response[kData])
                    break
                    
                default:
                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
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
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppColor.primaryTheme
        self.tblUser.backgroundColor = AppColor.primaryTheme
        
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Google Analytics
        
        let category = "UI"
        let action = "\(UserModel.currentUser.displayName!) view item \(self.dictFromParent.itemId!) like list"
        let lable = ""
        let screenName = "Like List"
        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
        
        //Google Analytics
        
        _ = self.addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "Reposts")
        
    }
   
    
}
//MARK: - TableView Delegate Datasource -
extension RepostersVC : PSTableDelegateDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayLikeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let objAtIndex = arrayLikeList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Reposters") as! UserCell
        
        cell.selectionStyle = .none
        cell.lblUserName.text = objAtIndex.getUserName()
        cell.lblDisplayName.text = objAtIndex.displayName
        
        cell.btnStatus.setTitle(objAtIndex.isFollowing, for: .normal)
        
        cell.imgProfile.setImageWithDownload(objAtIndex.getUserProfile().url())
        
        cell.btnStatus.setTitle(objAtIndex.isFollowing, for: .normal)
        
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
                        
                        self.callUpdateRequestAPI(requestModel,
                                                  withCompletion: { (isSuccess : Bool, response : JSON?) in
                                                    
                                                    if isSuccess {
                                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: response)
                                                        
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
                
                self.callUpdateRequestAPI(requestModel,
                                          withCompletion: { (isSuccess : Bool, response : JSON?) in
                                            
                                            if isSuccess {
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: response)
                                                
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
                
                objAtIndex.isFollowing = FollowType.following.rawValue.capitalized
                
                let requestModel = RequestModel()
                requestModel.user_id = objAtIndex.userId
                self.callSendRequestAPI(requestModel,
                                        withCompletion: { (isSuccess : Bool, response : JSON?) in
                                            
                                            if isSuccess {
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: response)
                                                
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: response)
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
        let objAtIndex = arrayLikeList[indexPath.row]
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.viewType = .other
        vc.fromPage = .otherPage
        vc.userData = UserModel(fromJson: JSON(objAtIndex.toDictionary()))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60*kHeightAspectRasio
    }
    
}


