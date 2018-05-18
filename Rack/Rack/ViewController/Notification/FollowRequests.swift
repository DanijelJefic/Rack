//  FollowRequestsVCViewController.swift
//  Rack
//  Created by Gurpreet Singh on 24/02/18.
//  Copyright © 2018 Hyperlink. All rights reserved.

import UIKit

class FollowRequestsVC: UIViewController {
    enum notificationCellType : String {
        case normalCell // like with photo
        case notificationWithOutImageCell // general
        case followCell
        case acceptCell
    }
    enum cellAction {
        case followUser
        case unfollowUser
        case accpetRequest
        case rejectRequest
        case none
    }
    
    typealias cellType = notificationCellType
    typealias action   = cellAction
    
    //------------------------------------------------------
    //MARK:- Outlet
    @IBOutlet weak var tblNotification: UITableView!
    //------------------------------------------------------
    //MARK:- Class Variable
    var arrayDataSoruce : [NotificationModel] = []
    var page                : Int = 1
    var isWSCalling         : Bool = true
    //MARK:- Memory Management Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        //remove observer
        NotificationCenter.default.removeObserver(kNotificationUserPrivacyPublic)
        NotificationCenter.default.removeObserver(kNotificationUserRequest)
        NotificationCenter.default.removeObserver(kNotificationUserDetailsUpdate)
        NotificationCenter.default.removeObserver(kNotificationFollowListUpdate)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        
        //Navigation Bar setup
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //set table footer view
        tblNotification.tableFooterView = UIView()
        tblNotification.estimatedRowHeight = 95
        tblNotification.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.customize()
        //setUp for pull to refresh
        self.setupPullToRefresh()
        
        self.navigationController?.customize()
        
        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.tblNotification.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
        infinityIndicator.startAnimating()
        //add notification for user privacy change to public
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserPrivacyPublic(_:)), name: NSNotification.Name(rawValue: kNotificationUserPrivacyPublic), object: nil)
        //add notification for user accepts or decline a particular request
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserAcceptsDeclineRequest(_:)), name: NSNotification.Name(rawValue: kNotificationUserRequest), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationFollowListUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: nil)
    }
    
    func addLoaderWithDelay() {
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.tblNotification.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.tblNotification.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
    }
    
    func callApi() {
        guard let _  = self.tblNotification else {
            return
        }
        
        self.tblNotification.ins_beginPullToRefresh()
    }
    
    func setupPullToRefresh() {
        
        //top
        self.tblNotification.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
            
            let requestModel = RequestModel()
            /*requestModel.type = PageRefreshType.top.rawValue
             
             if let firstItem = self.arrayDataSoruce.first {
             
             if let insertDate = firstItem.getInsertDate() {
             let insertDate = Date().convertToLocal(sourceDate: insertDate)
             requestModel.timestamp = insertDate.getTimeStampFromDate().string
             }
             } else {*/
            requestModel.type = PageRefreshType.bottom.rawValue
            //}
            
            //call API for top data
            self.callNotificationListAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                self.tblNotification.ins_endPullToRefresh()
                
                if isSuccess {
                    self.arrayDataSoruce = []
                    self.arrayDataSoruce.append(contentsOf: NotificationModel.modelsFromDictionaryArray(array: jsonResponse!.arrayValue))
                    
                    guard self.tblNotification != nil else {
                        return
                    }
                    self.tblNotification.reloadData()
                    
                } else {
                    
                }
            })
        }
        
        //bottom
        self.tblNotification.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            
            let requestModel = RequestModel()
            requestModel.type = PageRefreshType.bottom.rawValue
            
            if let lastItem = self.arrayDataSoruce.last {
                if let insertDate = lastItem.getInsertDate() {
                    let insertDate = Date().convertToLocal(sourceDate: insertDate)
                    requestModel.timestamp = insertDate.getTimeStampFromDate().string
                }
            }
            
            //call API for bottom data
            self.callNotificationListAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                scrollView?.ins_endInfinityScroll(withStoppingContentOffset: true)
                if self.isWSCalling {
                    self.isWSCalling = false
                    if isSuccess {
                        self.arrayDataSoruce.append(contentsOf: NotificationModel.modelsFromDictionaryArray(array: jsonResponse!.arrayValue))
                        guard self.tblNotification != nil else {
                            return
                        }
                        self.tblNotification.reloadData()
                    } else {
                        
                    }
                }
            })
        }
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationUserPrivacyPublic(_ notification : Notification) {
        /* Notification Post Method call
         1. Remove all request cell when privacy changes from private to public
         */
        
        //print("============Notification Method Called=================")
        
        arrayDataSoruce = arrayDataSoruce.filter({ (objNotify : NotificationModel) -> Bool in
            if objNotify.rackCell == notificationCellType.acceptCell.rawValue{
                return false
            } else {
                return true
            }
        })
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblNotification.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }
    
    func notificationUserAcceptsDeclineRequest(_ notification : Notification) {
        /* Notification Post Method call
         1. Remove request of a particular user
         */
        
        //print("============Notification Method Called=================")
        
        guard !(notification.object! as! JSON).isEmpty else {
            return
        }
        
        let notiItemData = NotificationModel(fromJson: notification.object as! JSON)
        
        //Replace accept request with following block
        arrayDataSoruce = arrayDataSoruce.map { (objNotify : NotificationModel) -> NotificationModel in
            if objNotify.rackCell == notificationCellType.acceptCell.rawValue && objNotify.userId == notiItemData.userId {
                return notiItemData
            } else {
                return objNotify
            }
        }
        
        //Remove reject request block
        arrayDataSoruce = arrayDataSoruce.filter({ (objNotify : NotificationModel) -> Bool in
            if objNotify.rackCell == notificationCellType.acceptCell.rawValue && objNotify.userId == notiItemData.userId {
                return false
            } else {
                return true
            }
        })
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblNotification.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }
    
    func notificationUserDetailsUpdate(_ notification : Notification) {
        
        guard let _  = tblNotification else {
            return
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblNotification.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }
    
    func notificationFollowListUpdate(_ notification : Notification) {
        /* Notification Post Method call
         1. FollowerVC Click on follow/following
         2. Profile follow/following
         */
        
        //print("============Notification Method Called=================")
        //print(notification.object!)
        
        guard let jsonData   = notification.object as? JSON else {
            return
        }
        
        let notiFollowData = NotificationModel(fromJson: jsonData)
        
        //change main data
        arrayDataSoruce = arrayDataSoruce.map { (objFollow : NotificationModel) -> NotificationModel in
            
            if objFollow.userId == notiFollowData.userId {
                objFollow.isFollowing = notiFollowData.isFollowing
                return objFollow
            } else {
                return objFollow
            }
        }
        
        
        arrayDataSoruce = arrayDataSoruce.filter({ (objFollow : NotificationModel) -> Bool in
            
            if objFollow.isFollowing.lowercased() == "unblock" {
                return false
            } else {
                return true
            }
            
        })
        
        tblNotification.reloadData()
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callNotificationListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/request_list
         
         Parameter   : type[top,down]
         
         Optional    : timestamp
         
         Comment     : This api will used for user get the notification list
         
         ==============================
         
         */
        
        APICall.shared.PUT(strURL: kMethodRequestNotificationList
            , parameter: requestModel.toDictionary()
            , withErrorAlert : false
        ) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            self.isWSCalling = true
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    self.page = self.page + 1
                    
                    /*
                     Set notification badge count
                     */
                    GFunction.shared.setNotificationCount()
                    
                    block(true,response[kData])
                    break
                    
                case noDataFound:
                    self.tblNotification.ins_removeInfinityScroll()
                    
                    if self.page == 1 {
                        GFunction.shared.showPopup(with: response[kMessage].stringValue, forTime: 2, withComplition: {
                        }, andViewController: self)
                    }
                    
                    block(false,nil)
                    break
                    
                default:
                    self.tblNotification.ins_removeInfinityScroll()
                    
                    block(false,nil)
                    break
                }
            } else {
                
                block(false,nil)
            }
        }
    }
    
    func callUpdateRequestAPI(_ requstModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
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
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: response[kData])
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: response[kData])
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserRequest), object: response[kData][kNotificationDetail])
                    
                    block(true,response[kData][kNotificationDetail])
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
    
    func callSendRequestAPI(_ requstModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/send_request
         
         Parameter   : user_id
         
         Optional    :
         
         Comment     : This api will used for user send to new request
         
         
         ==============================
         
         */
        
        APICall.shared.CancelTask(url: kMethodSendRequest)
        
        APICall.shared.GET(strURL: kMethodSendRequest
            , parameter: requstModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: response[kData])
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: response[kData])
                    
                    break
                    
                default:
                    
                    break
                }
            }
        }
    }
    
    func callUpdateReadRequestAPI(_ requstModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/unread_notification
         
         Parameter   : notification_id
         
         Optional    :
         
         Comment     : This api will used for read notification
         
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodRequestNotificationRead
            , parameter: requstModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    
                    
                    break
                    
                default:
                    
                    break
                }
            } else {
                
            }
            
        }
    }
    
    //--------------------------------------------------------------------------
    //MARK:- Action Method
    
    func btnAcceptClicked(sender: UIButton) {
        
        if let cell = sender.superview?.superview as? FollowRequestsCell {
            if let indexPath = tblNotification.indexPath(for: cell) {
                let data = arrayDataSoruce[indexPath.row]
                let requestModel = RequestModel()
                requestModel.user_id = data.userId
                requestModel.status = requestStatus.accepted.rawValue
                self.callUpdateRequestAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                    if isSuccess && jsonResponse != nil {
                        if (self.arrayDataSoruce.count <= indexPath.row){
                            self.arrayDataSoruce.append(NotificationModel(fromJson: jsonResponse))
                        } else {
                            self.arrayDataSoruce.insert(NotificationModel(fromJson: jsonResponse), at: indexPath.row)
                        }
                        UIView.animate(withDuration: 0.0, animations: {
                            DispatchQueue.main.async {
                                self.tblNotification.reloadData()
                            }
                        }, completion: { (Bool) in
                            
                        })
                    }
                })
                arrayDataSoruce.remove(at: indexPath.row)
                tblNotification.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                tblNotification.reloadData()
            }
        }
    }
    
    func btnRejecttClicked(sender: UIButton) {
        
        if let cell = sender.superview?.superview as? FollowRequestsCell {

            if let indexPath = tblNotification.indexPath(for: cell) {
                
                let data = arrayDataSoruce[indexPath.row]
                let requestModel = RequestModel()
                requestModel.user_id = data.userId
                requestModel.status = requestStatus.rejected.rawValue
                
                self.callUpdateRequestAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                    
                })
                arrayDataSoruce.remove(at: indexPath.row)
                tblNotification.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                tblNotification.reloadData()
            }
        }
    }
    
    
    func followUser(sender : UIButton)  {
        if let cell = objc_getAssociatedObject(sender, &constCellFollowKey) as? FollowRequestsCell {
            
            if let indexPath = tblNotification.indexPath(for: cell) {
                
                let dictAtIndex = arrayDataSoruce[indexPath.row]
                let action = dictAtIndex.isFollowing.lowercased()
                
                if action == FollowType.following.rawValue {
                    
                    AlertManager.shared.showAlertTitle(title: "", message: "Unfollow \(dictAtIndex.getUserName())?", buttonsArray: ["Unfollow","Cancel"]) { (buttonIndex : Int) in
                        switch buttonIndex {
                        case 0 :
                            //Unfollow clicked
                            //call API
                            let requestModel = RequestModel()
                            requestModel.user_id = dictAtIndex.userId
                            requestModel.status = FollowType.unfollow.rawValue
                            
                            dictAtIndex.isFollowing = FollowType.follow.rawValue
                            
                            self.tblNotification.reloadData()
                            self.callUpdateRequestAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                
                            })
                            
                            break
                        case 1:
                            //Cancel clicked
                            
                            break
                        default:
                            break
                        }
                        
                    }
                } else if action == FollowType.requested.rawValue {
                    
                    //Unfollow clicked
                    //call API
                    let requestModel = RequestModel()
                    requestModel.user_id = dictAtIndex.userId
                    requestModel.status = FollowType.unfollow.rawValue
                    
                    dictAtIndex.isFollowing = FollowType.follow.rawValue
                    
                    tblNotification.reloadData()
                    self.callUpdateRequestAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                        
                    })
                    
                } else if action == FollowType.follow.rawValue {
                    
                    //Following click
                    let requestModel = RequestModel()
                    requestModel.user_id = dictAtIndex.userId
                    
                    if (dictAtIndex.isPrivateProfile()) {
                        //requested
                        cell.btnFollow?.setImage(#imageLiteral(resourceName: "btnRequested"), for: UIControlState())
                        dictAtIndex.isFollowing = FollowType.requested.rawValue
                    } else {
                        //following
                        cell.btnFollow?.setImage(#imageLiteral(resourceName: "btnFollow"), for: UIControlState())
                        dictAtIndex.isFollowing = FollowType.following.rawValue
                    }
                    tblNotification.reloadData()
                    self.callSendRequestAPI(requestModel)
                    
                } else {
                    //print("btnFollowClicked.. But Require to handel other click event.")
                }
            }
        }
    }
    
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppColor.primaryTheme
        self.tblNotification.backgroundColor = AppColor.primaryTheme
        self.navigationController?.navigationBar.barTintColor = AppColor.primaryTheme
     self.navigationController?.navigationBar.isTranslucent = false
        setUpView()
        self.navigationController?.customize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: nil, title: "Follow Requests", isSwipeBack: true)
        self.perform(#selector(self.addLoaderWithDelay), with: nil, afterDelay: 0.0)
        self.callApi()
        //Google Analytics
        let category = "UI"
        let action = "\(UserModel.currentUser.displayName!) Follow Requests"
        let lable = ""
        let screenName = "Follow Requests"
        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
        //Google Analytics
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: nil, title: "Follow Requests", isSwipeBack: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}

extension FollowRequestsVC : PSTableDelegateDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDataSoruce.count
    }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 87.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dictAtIndex = arrayDataSoruce[indexPath.row] as NotificationModel
        
        
        let cellType = notificationCellType(rawValue: dictAtIndex.rackCell)
        
        switch cellType! {
            
        case .acceptCell:
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "nacceptCell") as! FollowRequestsCell
        cell.lblName.text = dictAtIndex.getUserName()
        cell.lblDisplayName.text = dictAtIndex.displayName
    cell.imgProfile.setImageWithDownload(dictAtIndex.getUserProfile().url())
        cell.selectionStyle = .none
        cell.btnAccept?.addTarget(self, action: #selector(btnAcceptClicked(sender:)), for: .touchUpInside)
        cell.btnReject?.addTarget(self, action: #selector(btnRejecttClicked(sender:)), for: .touchUpInside)

        return cell
        
        case .followCell:
        let cell = tableView.dequeueReusableCell(withIdentifier: "nsendCell") as! FollowRequestsCell
        cell.lblName.text = dictAtIndex.getUserName()
        cell.lblDisplayName.text = dictAtIndex.displayName
    cell.imgProfile.setImageWithDownload(dictAtIndex.getUserProfile().url())
        cell.selectionStyle = .none
        cell.btnFollow?.addTarget(self, action: #selector(followUser(sender:)), for: .touchUpInside)
        objc_setAssociatedObject(cell.btnFollow, &constCellFollowKey, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        cell.btnFollow?.alpha = 0.0
        if dictAtIndex.isFollowing.lowercased() == FollowType.follow.rawValue {
            cell.btnFollow?.alpha = 1.0
            cell.btnFollow?.backgroundColor = UIColor.red
            cell.btnFollow?.setTitleColor(UIColor.white, for: .normal)
            cell.btnFollow?.setTitle("Follow", for: .normal)
            cell.btnFollow?.layer.borderWidth = 0.0
        } else if dictAtIndex.isFollowing.lowercased() == FollowType.following.rawValue {
            cell.btnFollow?.alpha = 1.0
            cell.btnFollow?.setTitleColor(UIColor.black, for: .normal)
            cell.btnFollow?.setImage(#imageLiteral(resourceName: "btnFollow"), for: UIControlState())
            cell.btnFollow?.backgroundColor = UIColor.white
            cell.btnFollow?.layer.borderWidth = 1.0
            cell.btnFollow?.setTitle("Following", for: .normal)
        } else if dictAtIndex.isFollowing.lowercased() == FollowType.requested.rawValue {
            cell.btnFollow?.alpha = 1.0
            cell.btnFollow?.layer.borderWidth = 0.0
            cell.btnFollow?.backgroundColor = UIColor.red
            cell.btnFollow?.setTitleColor(UIColor.white, for: .normal)
            cell.btnFollow?.setTitle("Follow", for: .normal)
        } else {
            cell.btnFollow?.alpha = 1.0
            cell.btnFollow?.layer.borderWidth = 0.0
            cell.btnFollow?.setTitleColor(UIColor.white, for: .normal)
            cell.btnFollow?.backgroundColor = UIColor.red
            cell.btnFollow?.setTitle("Follow", for: .normal)
        }
        return cell
        case .normalCell:
            return UITableViewCell()
        case .notificationWithOutImageCell:
            return UITableViewCell()
        }
    
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        return
        let dictAtIndex = arrayDataSoruce[indexPath.row] as NotificationModel
        dictAtIndex.isRead = notificationRead.read.rawValue
        let requestModel = RequestModel()
        requestModel.notificationId = dictAtIndex.id
        self.callUpdateReadRequestAPI(requestModel)
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblNotification.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }
    
}

class FollowRequestsCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDisplayName: UILabel!
    @IBOutlet weak var btnAccept: UIButton?
    @IBOutlet weak var btnReject: UIButton?
    @IBOutlet weak var btnFollow: UIButton?
    @IBOutlet weak var imgProfile: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = AppColor.primaryTheme
        self.contentView.backgroundColor = AppColor.primaryTheme
        let shadowView = UIView()
        shadowView.backgroundColor = UIColor.white
        shadowView.layer.shadowRadius = 2.2
        shadowView.layer.shadowColor  = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.9
        shadowView.layer.shadowOffset = CGSize(width:0,height:2.0)
        shadowView.frame = imgProfile.frame
        shadowView.layer.cornerRadius = shadowView.frame.size.height/2.0
        self.contentView.insertSubview(shadowView, at: 0)
        imgProfile.applyStype(cornerRadius: imgProfile.frame.size.width / 2)

    }
}

