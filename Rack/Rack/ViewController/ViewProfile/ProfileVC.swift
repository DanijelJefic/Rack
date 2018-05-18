//
//  ProfileVC.swift
//  Rack
//
//  Created by hyperlink on 08/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//
//imageShadow
import UIKit
import PeekView

class ProfileVC: UIViewController {
    
    //MARK:- Outlet
    
    let activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblPrivateAccount: UILabel!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var headerView          : CoverView!
    var guideView = GuideView()
    var constant            : CGFloat = 0.0
    let colum               : Float = 3.0,spacing :Float = 1.0
    
    //To manage navigation bar button
    var fromPage            = PageFrom.defaultScreen
    
    var tapGesture          = UITapGestureRecognizer()
    var longGesture         = UILongPressGestureRecognizer()
    
    var viewType            = profileViewType.me
    var userData            : UserModel? = nil
    var cover_image         : String? = nil
    
    var arrayItemData       : [ItemModel] = []
    var page                : Int = 1
    var isWSCalling         : Bool = true
    var isRackEmpty: Bool = false
    //------------------------------------------------------
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
        //print("Profile VC...")
        NotificationCenter.default.removeObserver(kNotificationProfileUpdate)
        NotificationCenter.default.removeObserver(kNotificationUserDataUpdate)
        NotificationCenter.default.removeObserver(kNotificationUserDetailsUpdate)
        NotificationCenter.default.removeObserver(kNotificationRackWantUpdate)
        NotificationCenter.default.removeObserver(kNotificationNewPostAdded)
        NotificationCenter.default.removeObserver(kNotificationRackWantEdit)
        NotificationCenter.default.removeObserver(kNotificationItemDetailDelete)
        NotificationCenter.default.removeObserver(kNotificationWant)
        NotificationCenter.default.removeObserver(kNotificationRackList)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        
        //Navigation Bar setup
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
        _ = addBarButtons(btnLeft: nil, btnRight: nil, title: "")
        
        self.navigationController?.customize()
        //add notification for profile update
        NotificationCenter.default.addObserver(self, selector: #selector(notificationProfileUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationProfileUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationWantUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationNewPostAdded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDataUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRackWantUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationRackWantUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationEditItemDetails(_:)), name: NSNotification.Name(rawValue: kNotificationRackWantEdit), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationWantUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationItemDetailDelete), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationWantUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationWant), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRackListUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationRackList), object: nil)
        
        longGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        longGesture.minimumPressDuration = kMinimumPressDuration
        collectionView.addGestureRecognizer(longGesture)
        lblPrivateAccount.text = "USER HAS SET ACCOUNT\nTO PRIVATE"
        lblPrivateAccount.applyStyle(labelFont: UIFont.applyBold(fontSize: 14.0), labelColor: AppColor.text)
        lblPrivateAccount.isHidden = true
        lblPrivateAccount.backgroundColor = UIColor.clear
        self.activityIndicatorView.frame = self.view.bounds
        self.activityIndicatorView.activityIndicatorViewStyle = .gray
        self.view.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        self.setupPullToRefresh()
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.collectionView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.collectionView.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
        
    }
    
    func setUpData() {
        
        //    let requestModel = RequestModel()
        //    requestModel.user_id = self.userData?.userId
        //    self.callUserCountAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
        //        if isSuccess {
        //            let uData = UserModel(fromJson: jsonResponse)
        //            self.userData?.rackCount = uData.rackCount
        //            self.collectionView.reloadData()
        //        }
        //    })
        
        //to check user current User come from other user profile.
        if self.userData?.userId == UserModel.currentUser.userId && (fromPage != .defaultScreen) {
            viewType = .me
            fromPage = .fromSettingPage // to setup navigation bar button
        }
        
        switch viewType {
        case .me:
            //TODO:- Load old data that are available with us.
            self.userData = UserModel.currentUser
            
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            requestModel.user_name = self.userData?.userName
            
            self.callUserDetailAPI(requestModel, withCompletion: { (isSuccess : Bool) in
                if isSuccess {
                    
                } else {
                    let requestModel = RequestModel()
                    requestModel.user_id = self.userData?.userId
                    requestModel.user_name = self.userData?.userName
                    self.callUserDetailAPI(requestModel)
                }
                
            })
            
            break
        case .other:
            
            //TODO:- Check whether to show onboarding or no
            //      let requestModel1 = RequestModel()
            //      requestModel1.tutorial_type = tutorialFlag.OtherProfile.rawValue
            //
            //      GFunction.shared.getTutorialState(requestModel1) { (isSuccess: Bool) in
            //        if isSuccess {
            //          let onBoarding = mainStoryBoard.instantiateViewController(withIdentifier: "OnboardingBaseVC") as! OnboardingBaseVC
            //          onBoarding.tutorialType = .OtherProfile
            //          self.present(onBoarding, animated: false, completion: nil)
            //        } else {
            //
            //        }
            //
            //      }
            
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            requestModel.user_name = self.userData?.userName
            
            self.callUserDetailAPI(requestModel, withCompletion: { (isSuccess : Bool) in
                if isSuccess {
                    
                } else {
                    let requestModel = RequestModel()
                    requestModel.user_id = self.userData?.userId
                    requestModel.user_name = self.userData?.userName
                    self.callUserDetailAPI(requestModel)
                }
            })
            
            break
        }
    }
    
    func setupPullToRefresh() {
        self.activityIndicatorView.frame = self.view.bounds
        self.collectionView.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
            
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            self.callUserDetailAPI(requestModel, withCompletion: { (isSuccess) in
                scrollView?.ins_endPullToRefresh()
                self.setupTipAnimation()
            })
            
        }
        
        //bottom
        self.collectionView.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            
            if self.isWSCalling {
                self.isWSCalling = false
                
                let requestModel = RequestModel()
                requestModel.user_id = self.userData?.userId
                requestModel.page = String(format: "%d", (self.page))
                self.callRackListAPI(requestModel, withCompletion: { (isSuccess) in
                    self.setupTipAnimation()
                    if isSuccess {
                        self.page = (self.page) + 1
                    }
                    
                })
            }
        }
    }
    
    func handleLongPress(_ gesture : UILongPressGestureRecognizer) {
        
        if gesture.state == .ended {
            
            let window = UIApplication.shared.keyWindow
            
            for peekView in window!.subviews {
                
                if peekView is PeekView {
                    UIView.animate(withDuration: 0.3, animations: {
                        peekView.alpha = 0.0
                    }, completion: { (isComplete : Bool) in
                        peekView.removeFromSuperview()
                    })
                }
            }
            
            return
        }
        
        let point = gesture.location(in: collectionView)
        
        guard let indexPath = self.collectionView.indexPathForItem(at: point) else {
            return
        }
        //print(indexPath)
        
        let objAtIndex = arrayItemData[indexPath.row]
        
        let preViewVC = secondStoryBoard.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
        preViewVC.image = objAtIndex.rackImage.url()
        
        PeekView.viewForController(parentViewController: self
            , contentViewController: preViewVC
            , expectedContentViewFrame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
            , fromGesture: gesture
            , shouldHideStatusBar: true
            , menuOptions: []
            , completionHandler: nil
            , dismissHandler: nil)
        
    }
    
    func callAfterUserDetailServiceResponse() {
        guard self.userData != nil else {
            //print("Some thing wrong.. In Profile VC Collection number of cell")
            return
        }
        
        //still require to check other conditions.
        if self.userData!.isProfileAccessible(viewType) {
            lblPrivateAccount.isHidden = true
        } else {
            lblPrivateAccount.isHidden = false
        }
    }
    
    func btnThreeDotClicked() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionReport = UIAlertAction(title: "Report", style: .default) { (action : UIAlertAction) in
            
            //Report...
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
            vc.reportId = (self.userData?.userId)!
            vc.reportType = .profile
            vc.offenderId = (self.userData?.userId)!
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        let actionBlock = UIAlertAction(title: "Block", style: .default) { (action : UIAlertAction) in
            
            //Blocked...
            AlertManager.shared.showAlertTitle(title: "", message: "Are you sure you want to block this user?", buttonsArray: ["Cancel","Block"]) { (buttonIndex : Int) in
                switch buttonIndex {
                case 0 :
                    break
                case 1:
                    
                    let userOriginalData = self.userData
                    
                    //Block clicked
                    let requestModel = RequestModel()
                    requestModel.user_id = self.userData?.userId
                    requestModel.status = requestStatus.blocked.rawValue
                    
                    self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: FollowType.unblock.rawValue)
                    
                    self.callUpdateRequestAPI(requestModel)
                    
                    break
                default :
                    break
                }
            }
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
            
        }
        actionSheet.addAction(actionReport)
        actionSheet.addAction(actionBlock)
        actionSheet.addAction(actionCancel)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func setPageTitle() {
        
        if self.navigationController?.visibleViewController is ProfileVC {
            
            if let username = self.userData?.userName {
                if !(username.contains("@")) {
                    self.userData?.userName = "@\(String(describing: username))".lowercased()
                }
            }
        switch fromPage {
        case .defaultScreen:
            
            var userName = self.userData?.userName
            if userName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "", let index = userName?.index(userName!.startIndex, offsetBy: 1) {
                userName = userName?.substring(from: index)
            }
            _ = addBarButtons(btnLeft: nil, btnRight: BarButton(image : #imageLiteral(resourceName: "btnSetting") ), title:userName)
            break
        case .fromSettingPage:
            //set When user come his in profile from other profile.
            var userName = self.userData?.userName
            if userName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "", let index = userName?.index(userName!.startIndex, offsetBy: 1) {
                userName = userName?.substring(from: index)
            }
            _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: BarButton(image : #imageLiteral(resourceName: "btnSetting")), title:userName, isSwipeBack: true)
            
            break
            
        case .otherPage:
            var userName = self.userData?.userName
            
            if userName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "", let index = userName?.index(userName!.startIndex, offsetBy: 1) {
                userName = userName?.substring(from: index)
            }
            _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: BarButton(image : #imageLiteral(resourceName: "btnDotVertical")), title: userName, isSwipeBack: true)
            break
        }
     }
}
    
    func changeFollowStatus(originalData : UserModel,data : UserModel,status : String) {
        
        if userData?.userId == UserModel.currentUser.userId {
            return
        }
        
        /*
         Other user's profile follower's count management based of their profile type and previous state
         */
        
        if !originalData.isPrivateProfile() {
            
            switch status {
            case FollowType.requested.rawValue:
                //Dont do anything as state is requested
                userData?.isFollowing = status.lowercased()
                break
            case FollowType.following.rawValue:
                userData?.followersCount = "\(Int((userData?.followersCount)!)! + 1)"
                userData?.isFollowing = status.lowercased()
                break
            case FollowType.follow.rawValue:
                userData?.followersCount = "\(Int((userData?.followersCount)!)! - 1)"
                userData?.isFollowing = status.lowercased()
                break
            case requestStatus.accepted.rawValue:
                userData?.followingCount = "\(Int((userData?.followingCount)!)! + 1)"
                userData?.requestStatus = status.lowercased()
                break
            case requestStatus.rejected.rawValue:
                userData?.requestStatus = status.lowercased()
                break
            case FollowType.unblock.rawValue:
                userData?.followersCount = "\(Int((userData?.followersCount)!)! - 1)"
                userData?.isFollowing = status.lowercased()
                break
            default:
                //print("============Check changeFollowStatus Other user's followers count (Public Account)=================")
                break
            }
            
        } else {
            switch status {
            case FollowType.requested.rawValue:
                //Dont do anything as state is requested
                userData?.isFollowing = status.lowercased()
                break
            case FollowType.follow.rawValue:
                userData?.isFollowing = status.lowercased()
                break
            case requestStatus.accepted.rawValue:
                userData?.followingCount = "\(Int((userData?.followingCount)!)! + 1)"
                userData?.isFollowing = FollowType.following.rawValue
                userData?.requestStatus = status.lowercased()
                break
            case requestStatus.rejected.rawValue:
                userData?.requestStatus = status.lowercased()
                break
            case FollowType.unblock.rawValue:
                userData?.followersCount = "\(Int((userData?.followersCount)!)! - 1)"
                userData?.isFollowing = status.lowercased()
                break
            default:
                //print("============Check changeFollowStatus Other user's followers count (Public Account)=================")
                break
            }
        }
        
        //still require to check other conditions.
        if self.userData!.isProfileAccessible(viewType) {
            lblPrivateAccount.isHidden = true
        } else {
            lblPrivateAccount.isHidden = false
        }
        
        let data = JSON(userData?.toDictionary() ?? [:])
        
        /*
         1. Count management in current user's profile
         2. Follower and Following user list would refect user's status
         */
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: data)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: data)
        
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationProfileUpdate(_ notification : Notification) {
        /* Notification Post Method call
         1. Edit Profile.
         2. Updte Rack
         */
        
        switch viewType {
        case .me:
            
            self.fromPage = .defaultScreen
            
            DispatchQueue.main.async {
                self.arrayItemData.removeAll()
                self.collectionView.reloadData()
            }
            
            self.setUpData()
            
            guard let jsonData   = notification.object as? JSON else {
                return
            }
            
            let notiWantData = ItemModel(fromJson: jsonData)
            
            let predict = NSPredicate(format: "itemId LIKE %@",notiWantData.itemId)
            let temp = self.arrayItemData.filter({ predict.evaluate(with: $0) })
            
            //print(temp)
            
            if !temp.isEmpty {
                if let index = self.arrayItemData.index(of: temp[0]) {
                    self.arrayItemData.remove(at: index)
                }
            } else {
                self.arrayItemData.insert(notiWantData, at: 0)
            }
            
            UIView.animate(withDuration: 0.0, animations: {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }, completion: { (Bool) in
                
            })
            
            break
        case .other:
            
            break
        }
        
    }
    
    func notificationRackListUpdate(_ notification : Notification) {
        /* Notification Post Method call
         1. Update Want List
         2. Add new item
         */
        
        switch viewType {
        case .me:
            
            self.fromPage = .defaultScreen
            
            self.page = 1
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            requestModel.page = String(format: "%d", (self.page))
            self.callRackListAPI(requestModel, withCompletion: { (isSuccess) in
                if isSuccess {
                    self.page = (self.page) + 1
                }
            })
            
            break
        case .other:
            
            break
        }
    }
    
    func notificationWantUpdate(_ notification : Notification) {
        /* Notification Post Method call
         1. Update Want List
         2. Add new item
         */
        
        switch viewType {
        case .me:
            
            self.fromPage = .defaultScreen
            
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            requestModel.user_name = self.userData?.userName
            
            self.callUserDetailAPI(requestModel, withCompletion: { (isSuccess : Bool) in
                if isSuccess {
                    
                } else {
                    let requestModel = RequestModel()
                    requestModel.user_id = self.userData?.userId
                    requestModel.user_name = self.userData?.userName
                    self.callUserDetailAPI(requestModel)
                }
            })
            
            break
        case .other:
            
            break
        }
    }
    
    func notificationEditItemDetails(_ notification : Notification) {
        /*
         Item Details update
         */
        
        guard let _  = self.collectionView else {
            return
        }
        
        switch viewType {
        case .me:
            
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            requestModel.user_name = self.userData?.userName
            
            self.callUserDetailAPI(requestModel, withCompletion: { (isSuccess : Bool) in
                if isSuccess {
                    
                } else {
                    let requestModel = RequestModel()
                    requestModel.user_id = self.userData?.userId
                    requestModel.user_name = self.userData?.userName
                    self.callUserDetailAPI(requestModel)
                }
            })
            
            //
            //      self.fromPage = .defaultScreen
            //      guard let jsonData   = notification.object as? ItemModel else {
            //        return
            //      }
            //
            //      let predict = NSPredicate(format: "itemId LIKE %@",jsonData.itemId!)
            //      let temp = arrayItemData.filter({ predict.evaluate(with: $0) })
            //
            //      if !temp.isEmpty {
            //        if let index = self.arrayItemData.index(of: temp[0]) {
            //          self.arrayItemData[index] = jsonData
            //        }
            //      } else {
            //        self.arrayItemData.insert(jsonData, at: 0)
            //      }
            //
            
            break
        case .other:
            
            break
        }
        
    }
    
    func notificationUserDataUpdate(_ notification : Notification) {
        
        /* Notification Post Method call
         1.FollowerVC Click on follow/following
         2.Profile Button :- Follow/Following.
         */
        //print("============Notification Method Called=================")
        //print(notification.object!)
        
        guard let jsonData   = notification.object as? JSON else {
            return
        }
        
        let notiUserData = UserModel(fromJson: jsonData)
        
        //if own profile then update follow/following count
        if viewType == .me {
            let followData = FollowModel(fromJson: jsonData)
            
            if let followerCount = followData.loginFollowersCount {
                if followerCount != "" {
                    self.userData?.followersCount = followerCount
                }
            }
            
            if let followingCount = followData.loginFollowingCount {
                if followingCount != "" {
                    self.userData?.followingCount = followingCount
                }
            }
            
            self.collectionView.reloadData()
        }
        
        //it will also call for own user.
        //For now change only status. Require to replace other object also as per requirement.
        if self.userData?.userId == notiUserData.userId {
            self.userData?.isFollowing = notiUserData.isFollowing
            self.userData?.requestStatus = notiUserData.requestStatus
            
            
            let followData = FollowModel(fromJson: jsonData)
            if let followerCount = followData.followersCount {
                if followerCount != "" {
                    self.userData?.followersCount = followerCount
                }
            }
            
            if let followingCount = followData.followingCount {
                if followingCount != "" {
                    self.userData?.followingCount = followingCount
                }
            }
            
            if let _headerView = self.headerView {
                _headerView.didChangeStatusOfFollow(notiUserData)
            }
            
            self.collectionView.reloadData()
        }
        
    }
    
    func notificationUserDetailsUpdate(_ notification : Notification) {
        
        guard let _  = collectionView else {
            return
        }
        
        collectionView.ins_beginPullToRefresh()
        
    }
    
    func notificationRackWantUpdate(_ notification : Notification) {
        
        if self.userData?.userId == UserModel.currentUser.userId {
            self.page = 1
            self.userData? = UserModel.currentUser
            collectionView.ins_beginInfinityScroll()
        }
    }
    
    func notificationItemDataDelete(_ notification : Notification) {
        
        //        //print("============Notification Method Called=================")
        //        //print(notification.object!)
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        let notiItemData = jsonData
        //change main data
        
        arrayItemData = arrayItemData.filter { (objFollow : ItemModel) -> Bool in
            if objFollow.itemId == notiItemData.itemId {
                return false
            } else {
                return true
            }
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }, completion: { (Bool) in
            self.view.layoutIfNeeded()
        })
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callUserDetailAPI(_ requestModel : RequestModel,withCompletion block: ((Bool) -> Void)? = nil) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/user_data
         
         Parameter   : user_id or username
         
         Optional    :
         
         Comment     :
         
         ==============================
         
         */
        
        //        APICall.shared.CancelTask(url: kMethodUserData)
        
        APICall.shared.PUT(strURL: kMethodUserData
            , parameter: requestModel.toDictionary()
            , withErrorAlert : false
        ) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            self.activityIndicatorView.stopAnimating()
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    self.userData = UserModel(fromJson: response[kData])
                    if self.userData?.userId == UserModel.currentUser.userId && (self.fromPage != .defaultScreen) {
                        self.viewType = .me
                        self.fromPage = .fromSettingPage // to setup navigation bar button
                    }
                    
                    //if API response for current then require to update userdefault and currentUserModel
                    switch self.viewType {
                    case .me:
                        //Save User Data into userDefaults.
                        self.userData?.saveUserDetailInDefaults()
                        
                        //load latest data in to current User
                        UserModel.currentUser.getUserDetailFromDefaults()
                        
                        //Google Analytics
                        
                        let category = "UI"
                        let action = "\(UserModel.currentUser.displayName!) view his profile"
                        let lable = ""
                        let screenName = "User Profile"
                        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                        
                        //Google Analytics
                        
                        break
                        
                    case .other:
                        
                        self.callAfterUserDetailServiceResponse()
                        
                        //Google Analytics
                        
                        let category = "UI"
                        let action = "\(UserModel.currentUser.displayName!) view his profile \(self.userData!.getUserName()) 's profile"
                        let lable = ""
                        let screenName = "User Profile"
                        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                        
                        //Google Analytics
                        
                        break
                    }
                    
                    self.perform(#selector(self.setPageTitle), with: nil, afterDelay: 0.0)
                    self.collectionView.performBatchUpdates({
                        
                    }, completion: { (isSuccess : Bool) in
                        
                        if isSuccess {
                            
                            self.page = 1
                            self.collectionView.isHidden = false
                            self.collectionView.reloadData()
                            
                            let requestModel = RequestModel()
                            requestModel.user_id = self.userData?.userId
                            requestModel.page = String(format: "%d", (self.page))
                            self.callRackListAPI(requestModel, withCompletion: { (isSuccess) in
                                
                                if isSuccess {
                                    self.page = self.page + 1
                                }
                                
                                //Google Analytics
                                
                                let category = "UI"
                                let action = "\(String(describing: self.userData!.displayName!)) view \(self.userData!.isShowRack() ? "racked" : "want") items"
                                let lable = ""
                                let screenName = "User Profile -> \(self.userData!.isShowRack() ? "Rack" : "Want") Item"
                                googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                                
                                //Google Analytics
                                
                            })
                            
                        }
                        
                    })
                    
                    //handel nil.
                    if let _ = block {
                        block!(true)
                    }
                    
                    break
                    
                case noDataFound:
                    GFunction.shared.showPopup(with: response[kMessage].stringValue, forTime: 2, withComplition: {
                        self.navigationController?.popViewController(animated: true)
                    }, andViewController: self)
                    break
                    
                default:
                    if let _ = block {
                        block!(false)
                    }
                    break
                }
            } else {
                
                if let _ = block {
                    block!(false)
                }
            }
        }
        
    }
    
    func callUpdateRequestAPI(_ requstModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/update_request
         
         Parameter   : status[accepted,rejected,blocked,unfollow],user_id
         
         Optional    :
         
         Comment     : This api will used for user update the request.
         
         Method      : POST
         
         ==============================
         
         */
        
        APICall.shared.CancelTask(url: kMethodUpdateRequest)
        
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
                    
                    if requstModel.status == FollowType.unfollow.rawValue || requstModel.status == FollowType.follow.rawValue {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUnfollow), object: response[kData])
                    }
                    
                    //                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    break
                    
                default:
                    //                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    break
                }
            }
        }
    }
    
    
    func callRackListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        if  self.page != 1 &&  self.arrayItemData.count == 0{
            block(false)
        }
        /*
         ===========API CALL===========
         
         Method Name : item/racklist
         
         Parameter   : user_id
         
         Optional    : page
         
         Comment     : This api will used for fetch User Racks
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodRackList
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            self.isWSCalling = true
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    DispatchQueue.main.async {
                        if self.page == 1{
                            self.arrayItemData.removeAll()
                        }
                        self.collectionView.ins_endInfinityScroll(withStoppingContentOffset: true)
                        let newData = ItemModel.modelsFromDictionaryArray(array: response[kData].arrayValue)
                        for model in newData{
                            let resultPredicate : NSPredicate = NSPredicate(format: "rackId = %@",model.rackId)
                            let searchResults = self.arrayItemData.filter { resultPredicate.evaluate(with: $0) }
                            if searchResults.count == 0{
                                self.arrayItemData.append(model)
                            }
                        }
                        self.isRackEmpty = false
                        self.collectionView.reloadData()
                        block(true)
                    }
                    break
                default:
                    
                    //stop pagination
                    if self.page == 1{
                        self.arrayItemData.removeAll()
                        self.isRackEmpty = true
                        self.collectionView.reloadData()
                    }
                    
                    block(false)
                    
                    break
                }
            } else {
                self.collectionView.ins_endInfinityScroll(withStoppingContentOffset: true)
                block(false)
                
            }
        }
    }
    
    func callUserCountAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool,JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : user/user_count
         
         Parameter   : user_id
         
         Optional    :
         
         Comment     : This api will used for updating user count
         
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodUserCount,
                           parameter: requestModel.toDictionary(),
                           withErrorAlert: false,
                           withLoader: false,
                           debugLog: false)
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
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRackFeedUpdate), object: response[kData])
                    
                    break
                    
                default:
                    break
                }
            }
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    func leftButtonClicked() {
        switch fromPage {
        case .defaultScreen:
            
            break
        case .fromSettingPage:
            _ = self.navigationController?.popViewController(animated: true)
            break
            
        case .otherPage:
            _ = self.navigationController?.popViewController(animated: true)
            break
        }
    }
    
    func rightButtonClicked() {
        
        switch fromPage {
        case .defaultScreen:
            
            let vc : SettingVC = secondStoryBoard.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
        case .fromSettingPage:
            
            let vc : SettingVC = secondStoryBoard.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case .otherPage:
            //"3 Dot clicked..."
            self.btnThreeDotClicked()
            break
        }
        
    }
    
    //MARK: - Header View Action Clicked
    func btnRackedClicked(_ sender: UIButton) {
        self.viewRackClicked(sender)
    }
    
    
    func btnFollowersClicked(_ sender: UIButton) {
        
        guard self.userData != nil else {
            //print("Some thing wrong.. In Profile VC Collection number of cell")
            return
        }
        
        //if profile not accessible then return
        if !self.userData!.isProfileAccessible(viewType) {
            return
        }
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "FollowerListVC") as! FollowerListVC
        vc.vcType = .follow
        vc.userData = self.userData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func btnFollowingClicked(_ sender: UIButton) {
        
        guard self.userData != nil else {
            //print("Some thing wrong.. In Profile VC Collection number of cell")
            return
        }
        
        //if profile not accessible then return
        if !self.userData!.isProfileAccessible(viewType) {
            return
        }
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "FollowerListVC") as! FollowerListVC
        vc.vcType = .following
        vc.userData = self.userData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func cameraButtonAction(_ sender: UIButton) {
        guideView.tipDismiss(forAnim: .aCoverPhoto)
        guideView.saveTapActivity(forAnim: .aCoverPhoto)
        
        let fusuma = FusumaViewController()
        fusuma.userData = self.userData!
        fusuma.isFromEditScreen = true
        fusuma.cropHeightRatio = 1.0
        fusuma.allowMultipleSelection = false
        fusumaSavesImage = true
        self.navigationController?.pushViewController(fusuma, animated: true)
    }
    
    func btnFollowClicked(_ sender: UIButton) {
        
        guideView.tipDismiss(forAnim: .aFollowUser)
        guideView.saveTapActivity(forAnim: .aFollowUser)
        
        let userOriginalData = self.userData
        
        if self.userData?.isFollowing.lowercased() == FollowType.follow.rawValue {
            
            //Following click
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            if (userData?.isPrivateProfile())! {
                self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: FollowType.requested.rawValue)
            } else {
                self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: FollowType.following.rawValue)
            }
            self.callSendRequestAPI(requestModel)
            
        } else if self.userData?.isFollowing.lowercased() == FollowType.following.rawValue {
            //unfllow clicked
            AlertManager.shared.showAlertTitle(title: "", message: "Unfollow \(self.userData!.getUserName())?", buttonsArray: ["Unfollow","Cancel"]) { (buttonIndex : Int) in
                switch buttonIndex {
                case 0 :
                    //Unfollow clicked
                    //call API
                    let requestModel = RequestModel()
                    requestModel.user_id = self.userData?.userId
                    requestModel.status = FollowType.unfollow.rawValue
                    self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: FollowType.follow.rawValue)
                    self.callUpdateRequestAPI(requestModel)
                    break
                case 1:
                    //Cancel clicked
                    break
                default:
                    break
                }
            }
            
        } else if self.userData?.isFollowing.lowercased() == FollowType.requested.rawValue {
            
            //Unfollow clicked
            //call API
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            requestModel.status = FollowType.unfollow.rawValue
            
            self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: FollowType.follow.rawValue)
            
            self.callUpdateRequestAPI(requestModel)
            
        } else if self.userData?.isFollowing.lowercased() == FollowType.unfollow.rawValue {
            
            //Follow clicked
            //call API
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            requestModel.status = FollowType.follow.rawValue
            
            self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: FollowType.follow.rawValue)
            
            self.callUpdateRequestAPI(requestModel)
            
        } else {
            //print("btnFollowClicked.. But Require to handel other click event.")
        }
        
    }
    
    func btnViewCountClicked(_ sender: UIButton) {
        self.viewRackClicked(sender)
    }
    
    func viewRackClicked(_ sender : Any) {
        
        guard self.userData != nil else {
            //print("Some thing wrong.. In Profile VC Collection number of cell")
            return
        }
        
        //still require to check other conditions.
        //if profile not accessible then return
        if !self.userData!.isProfileAccessible(viewType) {
            return
        }
        
    }
    
    func btnAcceptClicked(_ sender: UIButton) {
        
        guard self.userData != nil else {
            //print("Some thing wrong.. In Profile VC Collection number of cell")
            return
        }
        
        let userOriginalData = self.userData
        
        let requestModel = RequestModel()
        requestModel.user_id = self.userData?.userId
        requestModel.status = requestStatus.accepted.rawValue
        
        self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: requestStatus.accepted.rawValue)
        
        self.callUpdateRequestAPI(requestModel)
    }
    
    func btnRejecttClicked(_ sender: UIButton) {
        
        guard self.userData != nil else {
            //print("Some thing wrong.. In Profile VC Collection number of cell")
            return
        }
        
        let userOriginalData = self.userData
        
        let requestModel = RequestModel()
        requestModel.user_id = self.userData?.userId
        requestModel.status = requestStatus.rejected.rawValue
        
        self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: requestStatus.rejected.rawValue)
        
        self.callUpdateRequestAPI(requestModel)
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func awakeFromNib() {
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = AppColor.primaryTheme
        self.collectionView.isHidden = true
        self.collectionView.backgroundColor = AppColor.primaryTheme
        self.setUpView()
        self.setUpData()
        self.collectionView.register(UINib(nibName: "CoverView", bundle: nil), forCellWithReuseIdentifier: "headerCell")
        collectionView.register(UINib(nibName: "CoverView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.perform(#selector(self.setPageTitle), with: nil, afterDelay: 0.0)
        if  self.tabBarController?.selectedIndex == 4 && self.navigationController?.viewControllers.count == 1 {
            appDelegate().addTipView()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.activityIndicatorView.frame = self.view.bounds
        //TabBarHidden:false
        self.tabBarController?.tabBar.isHidden = false
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.collectionView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.collectionView.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
        
        self.setupTipAnimation()
        self.perform(#selector(self.setPageTitle), with: nil, afterDelay: 0.0)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appDelegate().dismissTipViewWithoutSave()
    }
    
}

//MARK: - CollectionView Delegate DataSource -
extension ProfileVC : PSCollectinViewDelegateDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard self.userData != nil else {
            //print("Some thing wrong.. In Profile VC Collection number of cell")
            return 0
        }
        
        //require to change at want list parsing.
        if !self.userData!.isProfileAccessible(viewType) {
            return 0
        }
        
        if self.isRackEmpty {
            return 1
        }else{
            return arrayItemData.count
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.isRackEmpty {
            return CGSize(width: kScreenWidth, height: 120 * kHeightAspectRasio)
        }else{
            return CGSize(width: kScreenWidth, height: kScreenWidth*0.66+25)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isRackEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WantListEmptyCell", for: indexPath)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WantListCell", for: indexPath) as! WantListCell
            if indexPath.row < arrayItemData.count {
                let objAtIndex = arrayItemData[indexPath.row]
                cell.rackPinImage.contentMode = .scaleAspectFill
                cell.rackPinImage.clipsToBounds = true
                cell.rackPinImage.setImageWithDownload(objAtIndex.rackImage.url())
                cell.shadowBackground.layer.cornerRadius = cell.shadowBackground.frame.size.height/2
                cell.shadowBackground.clipsToBounds = true
                cell.rackName.text = objAtIndex.rackName
                cell.rackViews.text = objAtIndex.rackViews
                if let otherImages = objAtIndex.rackitemsData {
                    if otherImages.isEmpty {
                        cell.rackitem1Image.contentMode = .center
                        cell.rackitem1Image.clipsToBounds = true
                        cell.rackitem1Image.image = UIImage(named: "icGallery")
                        cell.rackitem2Image.contentMode = .center
                        cell.rackitem2Image.clipsToBounds = true
                        cell.rackitem2Image.image = UIImage(named: "icGallery")
                    }else{
                        
                        cell.rackitem1Image.image = nil
                        cell.rackitem2Image.image = nil
                        
                        for i in 0..<otherImages.count {
                            
                            if i == 0 {
                                cell.rackitem1Image.contentMode = .scaleAspectFill
                                cell.rackitem1Image.clipsToBounds = true
                                cell.rackitem1Image.setImageWithDownload(otherImages[i].image.url())
                                
                                cell.rackitem2Image.contentMode = .center
                                cell.rackitem2Image.clipsToBounds = true
                                cell.rackitem2Image.image = UIImage(named: "icGallery")
                                
                            }else{
                                cell.rackitem2Image.contentMode = .scaleAspectFill
                                cell.rackitem2Image.clipsToBounds = true
                                cell.rackitem2Image.setImageWithDownload(otherImages[i].thumbnail.url())
                            }
                        }
                    }
                }
                if indexPath.row == arrayItemData.count-1 {
                    cell.sepratorLbl.isHidden = true
                }else{
                    cell.sepratorLbl.isHidden = false
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard self.userData != nil else {
            return CGSize(width: kScreenWidth, height: kScreenWidth + (30 * kHeightAspectRasio))
        }
        let text = self.userData?.bioTxt ?? ""
        var size = -10.0 as CGFloat
        if ((self.userData?.bioTxt) != nil) &&  ((self.userData?.bioTxt.count) != 0) {
            size = text.getHeight(withConstrainedWidth: (kScreenWidth - 46.0), font: UIFont.applyRegular(fontSize: 14.0))
        }
        let totalHeight = kScreenWidth  + size + 104.0
        return CGSize(width: kScreenWidth, height: totalHeight)
        
    }
    
    func setupTipAnimation() {
        
        if headerView != nil {
            // #MARK:- Animation Setup
            
            if self.userData?.userId == UserModel.currentUser.userId {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    self.guideView.addTip(.bottom, forView: self.headerView.coverCircleBackground, withinSuperview: self.headerView, textType: .tCoverPhoto, forAnim: .aCoverPhoto)
                    self.guideView.addAnimation(self.headerView.coverCircleBackground, withinSuperview: true, forAnim: .aCoverPhoto)
                })
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    self.guideView.addTip(.bottom, forView: self.headerView.coverCircleBackground, withinSuperview: self.headerView, textType: .tFollowUser, forAnim: .aFollowUser)
                    self.guideView.addAnimation(self.headerView.coverCircleBackground, withinSuperview: true, forAnim: .aFollowUser)
                })
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            if headerView == nil{
                headerView = collectionView.dequeueReusableSupplementaryView(ofKind:kind, withReuseIdentifier: "headerCell", for: indexPath) as! CoverView
                tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewRackClicked(_:)))
                tapGesture.numberOfTapsRequired = 1
            }
            
            setupTipAnimation()
            
            //to setview type. it must be before setUpData method
            headerView.viewType = self.viewType
            headerView._guideView = self.guideView
            //TODO: - Parameter pass for data setup
            headerView.setUpData(self.userData)
            headerView.btnView.addTarget(self, action: #selector(btnViewCountClicked(_:)), for: .touchUpInside)
            headerView.btnRacked.addTarget(self, action: #selector(btnRackedClicked(_:)), for: .touchUpInside)
            headerView.btnFollower.addTarget(self, action: #selector(btnFollowersClicked(_:)), for: .touchUpInside)
            headerView.btnFollowing.addTarget(self, action: #selector(btnFollowingClicked(_:)), for: .touchUpInside)
            
            if self.viewType == .me {
                headerView.coverCircleButton.addTarget(self, action: #selector(cameraButtonAction(_:)), for: .touchUpInside)
            }else{
                headerView.coverCircleButton.addTarget(self, action: #selector(btnFollowClicked(_:)), for: .touchUpInside)
            }
            
            headerView.rackImage.isUserInteractionEnabled = true
            headerView.isUserInteractionEnabled = true
            headerView.rackImage.addGestureRecognizer(tapGesture)
            headerView.addGestureRecognizer(tapGesture)
            headerView.backgroundColor = AppColor.primaryTheme
            return headerView
            
        }
        return UIView() as! UICollectionReusableView
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if arrayItemData.count == 0 {
            return
        }
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "RackFolderListVC") as! RackFolderListVC
        let cell = collectionView.cellForItem(at: indexPath) as! WantListCell
        vc.rackViewUpdate = {(viewCount) -> Void in
            cell.rackViews.text = viewCount
        }
        vc.userData = self.userData
        vc.viewType = self.viewType
        vc.dictFromParent = arrayItemData[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

class WantListCell: UICollectionViewCell {
    @IBOutlet weak var rackPinImage: UIImageView!
    @IBOutlet weak var rackitem1Image: UIImageView!
    @IBOutlet weak var rackitem2Image: UIImageView!
    @IBOutlet weak var shadowBackground: UIView!
    @IBOutlet weak var rackName: UILabel!
    @IBOutlet weak var rackViews: UILabel!
    @IBOutlet weak var sepratorLbl: UILabel!
    override func awakeFromNib() {
        
        
    }
    
}

