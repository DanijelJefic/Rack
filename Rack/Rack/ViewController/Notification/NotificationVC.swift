//  NotificationVC.swift
//  Rack
//  Created by hyperlink on 12/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.

import UIKit
import ActiveLabel
var constCellFollowKey: UInt8 = 0
var constCellAcceptKey: UInt8 = 0
let kSubDetail       : String = "SubDetail"
let kTime            : String = "Time"
let kProfileImage    : String = "ProfileImage"
let kDetailImage     : String = "DetailImage"
let kIsRead          : String = "kIsRead"

enum notificationRead : String {
    case read
    case unread
}
class NotificationVC: UIViewController {
    //Other Setup
    enum notificationCellType : String {
        case followRequestsCell
        case repostListCell
        case repostCell
        case normalCell // like with photo
        case notificationWithOutImageCell // general
        case followCell
        case acceptCell
    }
    enum cellAction {
        case followRequests
        case repostList
        case repost
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
    @IBOutlet weak var nonotificationlabel: UILabel!

    //------------------------------------------------------
    //MARK:- Class Variable
    
    var notificationData : [Any]    = [RequestNotificationModel(),[RepostNotificationModel](), [NotificationModel]()]
    var arrayDataSoruce : [NotificationModel] = []
    var page                : Int   = 1
    var isWSCalling         : Bool  = true
    var guideView            = GuideView()
    
    //MARK:- Memory Management Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        //remove observer
        NotificationCenter.default.removeObserver(kNotificationUserPrivacyPublic)
        NotificationCenter.default.removeObserver(kNotificationUserDetailsUpdate)
        NotificationCenter.default.removeObserver(kNotificationFollowListUpdate)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        //Navigation Bar setup
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationFollowListUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: nil)
        
    }
    
    func addLoaderWithDelay() {
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.tblNotification.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate?
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
            requestModel.type = PageRefreshType.bottom.rawValue
            //call API for top data
            self.callNotificationListAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                self.tblNotification.ins_endPullToRefresh()
                    if isSuccess {
                    self.arrayDataSoruce = []
                    var notifications : JSON?
                    
       //let notification =  NotificationPopUP.instance()
       //notification.reloadNotificationCounts(countsDict: jsonResponse!["unread_counts"].dictionaryObject as! [String : String])
            notifications = jsonResponse!["notifications"]
                    self.arrayDataSoruce.append(contentsOf: NotificationModel.modelsFromDictionaryArray(array: notifications!.arrayValue))
                            var reposts:[RepostNotificationModel] = []
                    for repost in jsonResponse!["repost"].arrayValue{
                        let  repostNotif : RepostNotificationModel = RepostNotificationModel(fromJson:repost)
                        reposts.append(repostNotif)
                    }
                        
                  let request : RequestNotificationModel = RequestNotificationModel(fromJson:jsonResponse!["request"])
                        
                    self.notificationData[0] = request
                    self.notificationData[1] = reposts
                    self.notificationData[2] = self.arrayDataSoruce
                            guard self.tblNotification != nil else {
                        return
                    }
                        
                    self.guideView.isSetupAnimation = true
                    self.tblNotification.reloadData()
                        
                        if (request.profile == nil || request.requestCount == "0") && (self.notificationData[1] as! [RepostNotificationModel]).count == 0 && self.arrayDataSoruce.count == 0 {
                            self.tblNotification.backgroundColor = .clear
                            self.nonotificationlabel.isHidden = false
                        }
                        
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
                        
                        
                        var notifications : JSON?
                        notifications = jsonResponse!["notifications"]
                        self.arrayDataSoruce.append(contentsOf: NotificationModel.modelsFromDictionaryArray(array: notifications!.arrayValue))
                        
                        
                        let request : RequestNotificationModel = RequestNotificationModel(fromJson:jsonResponse!["request"])
                        
                        self.notificationData[0] = request
                        
                        var reposts:[RepostNotificationModel] = []
                        for repost in jsonResponse!["repost"].arrayValue{
                            let  repostNotif : RepostNotificationModel = RepostNotificationModel(fromJson:repost)
                            reposts.append(repostNotif)
                        }
                        self.notificationData[1] = reposts
                        
                        self.notificationData[2] = self.arrayDataSoruce
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
         
         Method Name : request/notification_list
         
         Parameter   : type[top,down]
         
         Optional    : timestamp
         
         Comment     : This api will used for user get the notification list
         
         ==============================
         
         */
        
        APICall.shared.PUT(strURL: kMethodNotificationList
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
                    self.tblNotification.backgroundColor = .white
                    self.nonotificationlabel.isHidden = true
                    GFunction.shared.setNotificationCount()
                            block(true,response[kData])
                    break
                        case noDataFound:
                    self.tblNotification.ins_removeInfinityScroll()
                            if self.page == 1 {
                           self.tblNotification.backgroundColor = .clear
                              self.nonotificationlabel.isHidden = false
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
    
    func followUser(sender : UIButton)  {
        if let cell = objc_getAssociatedObject(sender, &constCellFollowKey) as? NotificationCell {
            if let indexPath = tblNotification.indexPath(for: cell) {
                    let dictAtIndex = arrayDataSoruce[indexPath.row - 2]
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
                        dictAtIndex.isFollowing = FollowType.requested.rawValue
                    } else {
                        //following
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
        _ = addBarButtons(btnLeft: nil, btnRight: nil, title: "Notifications", isSwipeBack: false)
        self.perform(#selector(self.addLoaderWithDelay), with: nil, afterDelay: 0.0)
        
        //Google Analytics
        
        let category = "UI"
        let action = "\(UserModel.currentUser.displayName!) view notifications"
        let lable = ""
        let screenName = "Notification"
        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
        
        //Google Analytics
        tblNotification.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = addBarButtons(btnLeft: nil, btnRight: nil, title: "Notifications", isSwipeBack: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}

extension NotificationVC : PSTableDelegateDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDataSoruce.count + 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var cellHeight = 91.0
        if indexPath.row == 0{
            cellHeight = 85.0
            let request:RequestNotificationModel = notificationData[0] as! RequestNotificationModel
            if request.profile == nil || request.requestCount == "0"{
                cellHeight = 0.0
            }
        } else if indexPath.row == 1{
            cellHeight = 80.0
            if (notificationData[1] as! [RepostNotificationModel]).count == 0{
                cellHeight = 0.0
            }
        }
        return CGFloat(cellHeight)
    }
    
    func addBoldText(_ fullString: NSString, boldPartOfString: String, fontSize: CGFloat) -> NSAttributedString {
        let nonBoldFontAttribute = [NSFontAttributeName: UIFont.applyRegular(fontSize: fontSize)]
        let boldFontAttribute = [NSFontAttributeName: UIFont.applyBold(fontSize: fontSize)]
        let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
        boldString.addAttributes(boldFontAttribute, range: fullString.range(of: boldPartOfString as String))
        return boldString
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nRequestsCell") as! NotificationCell
            cell.selectionStyle = .none
            cell.configureRequest(request: notificationData[0] as! RequestNotificationModel)
            return cell
        } else if indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "nRepostListCell") as! NotificationCell
            cell.selectionStyle = .none
            let repostingListData = notificationData[1] as! [RepostNotificationModel]
            
            cell.configureRepost(reposts: repostingListData)
            /*
            let tempView = UIView(frame: CGRect(x: (cell.frame.size.width/2-50), y: (cell.frame.size.height/2+20), width: 50, height: 50))
            cell.contentView.addSubview(tempView)
            tempView.isHidden = true
            */
            
            if repostingListData.count != 0 {
                // #MARK:- Animation Setup
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    if self.guideView.isSetupAnimation {
                        self.guideView.addTip(.top, forView: cell.repostIcon, withinSuperview: self.tblNotification, textType: .tRepostingPhoto, forAnim: .aRepostingPhoto)
                        self.guideView.addAnimation(cell.repostIcon, withinSuperview: false, forAnim: .aRepostingPhoto)
                    }
                })
            }
            
            return cell
        }
        
        let dictAtIndex = arrayDataSoruce[indexPath.row - 2] as NotificationModel
        let cellType = notificationCellType(rawValue: dictAtIndex.rackCell)
        switch cellType! {
        case .followRequestsCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "nRequestsCell") as! NotificationCell
            cell.lblName.text = dictAtIndex.message
            cell.imgProfile.setImageWithDownload(dictAtIndex.getUserProfile().url())
            cell.selectionStyle = .none
            return cell
        case .repostListCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "nRepostCell") as! NotificationCell
            let text = dictAtIndex.getUserName()+" "+dictAtIndex.message
            cell.lblName.attributedText = addBoldText(text as NSString, boldPartOfString: dictAtIndex.getUserName(), fontSize: 13)
            cell.lblTime.text = dictAtIndex.calculatePostTime()
            cell.imgProfile.setImageWithDownload(dictAtIndex.getUserProfile().url())
            cell.imgDetailPhoto?.setImageWithDownload(dictAtIndex.itemData.image.url())
            cell.selectionStyle = .none
            cell.checkCellReadUnread(notificationRead(rawValue : dictAtIndex.isRead)!)
            return cell
        case .normalCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "nNormalCell") as! NotificationCell
            let text = dictAtIndex.getUserName()+" "+dictAtIndex.message
            cell.lblName.attributedText = addBoldText(text as NSString, boldPartOfString: dictAtIndex.getUserName(), fontSize: 13)
            cell.lblTime.text = dictAtIndex.calculatePostTime()
            cell.imgProfile.setImageWithDownload(dictAtIndex.getUserProfile().url())
            cell.imgDetailPhoto?.setImageWithDownload(dictAtIndex.itemData.thumbnail.url())
            cell.selectionStyle = .none
            cell.checkCellReadUnread(notificationRead(rawValue : dictAtIndex.isRead)!)
            return cell
        case .notificationWithOutImageCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "nnotificationWithOutImageCell") as! NotificationCell
            let text = dictAtIndex.getUserName()+" "+dictAtIndex.message
            cell.lblName.attributedText = addBoldText(text as NSString, boldPartOfString: dictAtIndex.getUserName(), fontSize: 13)
            cell.lblTime.text = dictAtIndex.calculatePostTime()
            cell.imgProfile.setImageWithDownload(dictAtIndex.getUserProfile().url())
            cell.selectionStyle = .none
            cell.checkCellReadUnread(notificationRead(rawValue : dictAtIndex.isRead)!)
            return cell
        case .followCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "nsendCell") as! NotificationCell
            let text = dictAtIndex.getUserName()+" "+dictAtIndex.message
            cell.lblName.attributedText = addBoldText(text as NSString, boldPartOfString: dictAtIndex.getUserName(), fontSize: 13)
            cell.lblTime.text = dictAtIndex.calculatePostTime()
            cell.imgProfile.setImageWithDownload(dictAtIndex.getUserProfile().url())
            cell.selectionStyle = .none
            cell.btnFollow?.addTarget(self, action: #selector(followUser(sender:)), for: .touchUpInside)
            objc_setAssociatedObject(cell.btnFollow, &constCellFollowKey, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            cell.btnFollow?.alpha = 0.0
            
        cell.btnFollow?.setTitle(dictAtIndex.isFollowing.capitalized, for: .normal)

            
            if dictAtIndex.isFollowing.lowercased() == FollowType.follow.rawValue {
                    cell.btnFollow?.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 12.0), titleLabelColor: UIColor.white, cornerRadius: 5, backgroundColor: UIColor.red)
                } else if dictAtIndex.isFollowing.lowercased() == FollowType.following.rawValue {
                    cell.btnFollow?.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 12.0), titleLabelColor: UIColor.black, cornerRadius: 5, borderColor: UIColor.black, borderWidth: 0.5, backgroundColor: UIColor.white)
                } else if dictAtIndex.isFollowing.lowercased() == FollowType.requested.rawValue {
                    cell.btnFollow?.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 12.0), titleLabelColor: UIColor.black, cornerRadius: 5, backgroundColor: UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1))
                } else {
                    cell.btnFollow?.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 12.0), titleLabelColor: UIColor.white, cornerRadius: 5, backgroundColor: UIColor.red)
                   }
        
            cell.checkCellReadUnread(notificationRead(rawValue : dictAtIndex.isRead)!)
          
            return cell

        case .repostCell:
            return UITableViewCell()
        case .acceptCell:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
          let followRequestVC =  secondStoryBoard.instantiateViewController(withIdentifier: "FollowRequestsVC") as! FollowRequestsVC
        self.navigationController?.pushViewController(followRequestVC, animated: true)
            return
        } else if indexPath.row == 1{
            self.guideView.tipDismiss(forAnim: .aRepostingPhoto)
            self.guideView.saveTapActivity(forAnim: .aRepostingPhoto)
            
            let repostVC =  secondStoryBoard.instantiateViewController(withIdentifier: "RepostsVC") as! RepostsVC
         self.navigationController?.pushViewController(repostVC, animated: true)
            return 
            
        }

        let dictAtIndex = arrayDataSoruce[indexPath.row - 2] as NotificationModel
        dictAtIndex.isRead = notificationRead.read.rawValue
        let cellType = notificationCellType(rawValue: dictAtIndex.rackCell)
        let requestModel = RequestModel()
        requestModel.notificationId = dictAtIndex.id
        self.callUpdateReadRequestAPI(requestModel)
        switch cellType! {
        case .normalCell:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ItemDetailVC") as! RackDetailVC
            vc.dictFromParent = dictAtIndex.itemData
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .notificationWithOutImageCell:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            vc.viewType = .other
            vc.fromPage = .otherPage
            vc.userData = UserModel(fromJson: JSON(dictAtIndex.toDictionary()))
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .followCell:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            vc.viewType = .other
            vc.fromPage = .otherPage
            vc.userData = UserModel(fromJson: JSON(dictAtIndex.toDictionary()))
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .followRequestsCell:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "FollowRequestsVC") as! FollowRequestsVC
            self.navigationController?.pushViewController(vc, animated: true)
            break
        
        case .repostListCell:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "FollowRequestsVC") as! FollowRequestsVC
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .repostCell:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "FollowRequestsVC") as! FollowRequestsVC
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .acceptCell:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "FollowRequestsVC") as! FollowRequestsVC

            self.navigationController?.pushViewController(vc, animated: true)
            break
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblNotification.reloadData()
            }
        }, completion: { (Bool) in
        })
    }
    
}

//------------------------------------------------------

//MARK: - Notification Cell -

class NotificationCell: UITableViewCell {
    @IBOutlet weak var requestCountLable: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnAccept: UIButton?
    @IBOutlet weak var btnReject: UIButton?
    @IBOutlet weak var btnFollow: UIButton?
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgDetailPhoto: UIImageView?
    @IBOutlet weak var bottomLine: UIView?
    
    @IBOutlet weak var repostIcon: UIImageView!
    
   // Repost list outlets
    @IBOutlet var repostsViews: [UIView]!
    override func awakeFromNib() {
      super.awakeFromNib()
      self.backgroundColor = AppColor.primaryTheme
      self.contentView.backgroundColor = AppColor.primaryTheme
        if self.reuseIdentifier == "nRequestsCell" {
            requestCountLable.applyStyle(labelFont: UIFont.applyRegular(fontSize: 13.0), labelColor: UIColor.black)
            imgProfile.applyStype(cornerRadius: imgProfile.frame.size.width / 2)
            return
        }
        
        if self.reuseIdentifier == "nRequestsCell" || self.reuseIdentifier == "nRepostListCell" {
            return
        }
        lblName.applyStyle(labelFont: UIFont.applyRegular(fontSize: 13.0), labelColor: UIColor.black)
        lblTime.applyStyle(labelFont: UIFont.applyRegular(fontSize: 9.0), labelColor: UIColor.black)
        btnReject?.backgroundColor = UIColor.white
        btnReject?.layer.cornerRadius = 5.0
        btnReject?.clipsToBounds = true
        btnReject?.setImage(nil, for: .normal)
        btnReject?.titleLabel?.font = UIFont.applyRegular(fontSize: 11.0)
        btnReject?.setTitle("Reject", for: .normal)
        btnReject?.layer.borderColor = UIColor.black.cgColor
        btnReject?.layer.borderWidth = 1.0
        btnReject?.contentHorizontalAlignment = .center
        btnReject?.setTitleColor(UIColor.black, for: .normal)
        btnReject?.setTitleColor(UIColor.lightGray, for: .highlighted)
        
        btnAccept?.backgroundColor = UIColor.red
        btnAccept?.layer.cornerRadius = 5.0
        btnAccept?.clipsToBounds = true
        btnAccept?.setImage(nil, for: .normal)
        btnAccept?.titleLabel?.font = UIFont.applyRegular(fontSize: 11.0)
        btnAccept?.setTitle("Accept", for: .normal)
        btnAccept?.layer.borderColor = UIColor.black.cgColor
        btnAccept?.layer.borderWidth = 0.0
        btnAccept?.contentHorizontalAlignment = .center
        btnAccept?.setTitleColor(UIColor.white, for: .normal)
        btnAccept?.setTitleColor(UIColor.lightGray, for: .highlighted)
        
        btnFollow?.backgroundColor = UIColor.red
        btnFollow?.layer.cornerRadius = 5.0
        btnFollow?.clipsToBounds = true
        btnFollow?.titleLabel?.font = UIFont.applyRegular(fontSize: 12.0)
        btnFollow?.setTitle("Follow", for: .normal)
        btnFollow?.layer.borderColor = UIColor.black.cgColor
        btnFollow?.layer.borderWidth = 1.0
        btnFollow?.setTitleColor(UIColor.white, for: .normal)
        btnFollow?.setTitleColor(UIColor.lightGray, for: .highlighted)
        
        imgProfile.applyStype(cornerRadius: imgProfile.frame.size.width / 2)
        
        if self.reuseIdentifier == "nNormalCell" {
            lblTime.applyStyle(labelFont: UIFont.applyRegular(fontSize: 10.0), labelColor: UIColor.black)
        }
        
        if self.reuseIdentifier == "nnotificationWithOutImageCell" {
            lblTime.applyStyle(labelFont: UIFont.applyRegular(fontSize: 10.0), labelColor: UIColor.black)
        }
        
        if self.reuseIdentifier == "nsendCell" {
             lblTime.applyStyle(labelFont: UIFont.applyRegular(fontSize: 10.0), labelColor: UIColor.black)
        }
        
        if self.reuseIdentifier == "nacceptCell" {
            lblTime.applyStyle(labelFont: UIFont.applyRegular(fontSize: 10.0), labelColor: UIColor.black)
        }
        
   }
    
    func configureRequest(request:RequestNotificationModel) {
            if request.profile != nil{
        self.imgProfile.setImageWithDownload(request.profile.url(), withIndicator: true)
            self.requestCountLable.text = "You have \(request.requestCount!) follow requests"
            if request.requestCount == "1"{
                self.requestCountLable.text = "You have \(request.requestCount!) follow request"
                
            }
        }
    }
    
    
    func configureRepost(reposts:[RepostNotificationModel]) {
    
        if  reposts.count == 0{
            return
        }
        
        for view in repostsViews{
            view.isHidden = true
        }
        
     for index in 0..<reposts.count  {
        let repostView  = repostsViews[index]
        repostView.isHidden = false
        let repostImage = repostView.viewWithTag(100) as! UIImageView
        repostImage.setImageWithDownload(reposts[index].image.url(), withIndicator: true)
        let repostCount = repostView.viewWithTag(101) as! UILabel
            repostCount.text = reposts[index].repostCount
        }
    }
 
    func checkCellReadUnread(_ isRead : notificationRead) {
        
        switch isRead {
        case .read:
            lblName.applyStyle(labelFont: UIFont.applyRegular(fontSize: 13.0), labelColor: UIColor.black)
              self.bottomLine?.isHidden = true
            break
        case .unread:
            lblName.applyStyle(labelFont: UIFont.applyRegular(fontSize: 13.0), labelColor: UIColor.black)
              self.bottomLine?.isHidden = true
            break
        }
    }
    
}

