//
//  GFunction.swift
//  Rack
//
//  Created by hyperlink on 29/04/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import TTGSnackbar
import NVActivityIndicatorView
import MBProgressHUD

class GFunction: NSObject  {
    
    static let shared   : GFunction = GFunction()
    
    var snackbar: TTGSnackbar! = TTGSnackbar.init()
    
    var notificationView : NotificationView = NotificationView()
    
    var activityLoader = ActivityData(size: CGSize(width: 45, height: 45)
        , messageFont: UIFont.applyRegular(fontSize: 14.0)
        , type: NVActivityIndicatorType.ballSpinFadeLoader
        , color: UIColor.lightGray
        , textColor: UIColor.lightGray)
    
    var indicatorView   : UIActivityIndicatorView = UIActivityIndicatorView()
    
    //---------------------------------------------------------------------
    
    //MARK: - Alert Method
    
    func alert(title : String , message : String , cancelButton : String) {
        let alert : UIAlertView = UIAlertView(title: title as String, message: message as String, delegate: nil, cancelButtonTitle: cancelButton as String)
        alert.show()
    }
    
    func showAlert(_ title : String = "" ,
                   actionOkTitle : String = "OK" ,
                   actionCancelTitle : String = "" ,
                   message : String,
                   completion: ((Bool) -> ())? ) {
        
        let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let actionOk : UIAlertAction = UIAlertAction(title: actionOkTitle, style: .default) { (action) in
            if completion != nil {
                completion!(true)
            }
        }
        alert.addAction(actionOk)
        
        if actionCancelTitle != "" {
            
            let actionCancel : UIAlertAction = UIAlertAction(title: actionCancelTitle, style: .cancel) { (action) in
                if completion != nil {
                    completion!(false)
                }
            }
            
            alert.addAction(actionCancel)
        }
        
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    func userLogin(_ window : UIWindow!) {
        GFunction.shared.setHomePage(window)
    }
    
    func userLogOut(_ window : UIWindow!) {
        
        
        // I set the root VC dynamicaly because it depends on wether it's the first time to use the app or if the user is logged in or not
        
        let navigationController = mainStoryBoard.instantiateViewController(withIdentifier: "kNavigationTutorialVC") as! UINavigationController
        if window.topMostController() != navigationController {
            
            //Remove UserDefault for userData and userSession
            GFunction.shared.removeUserDefaults(key: kLoginUserData)
            GFunction.shared.removeUserDefaults(key: kUserSession)
            GFunction.shared.removeUserDefaults(key: kUserSearchData)
            GFunction.shared.removeUserDefaults(key: kBrandSearchData)
            GFunction.shared.removeUserDefaults(key: kItemSearchData)
            GFunction.shared.removeUserDefaults(key: kHashSearchData)
            
            //below line currentUser to reset the current user data shared object of current USER.
            UserModel.currentUser = UserModel()
            FriendModel.currentFriendList = []
            SearchText.currentSearchList = []
            
            appDelegate().coverImage = nil
            window.makeKeyAndVisible()
            window.rootViewController = navigationController
        }
    }
    
    func navigationPush(userInfo: [AnyHashable : Any]) {
        
        if let aps = userInfo["aps"]! as? Dictionary<String,Any> {
            if let record = aps["record"] as? Dictionary<String,Any> {
                if let tag = record["type"] as? String {
                    if tag == "user" {
                        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                        vc.viewType = .other
                        vc.fromPage = .otherPage
                        vc.userData = UserModel(fromJson: JSON(record))
                        let currentViewController = (AppDelegate.shared.window?.currentViewController() as? UITabBarController)?.selectedViewController
                        if currentViewController is UINavigationController {
                            (currentViewController as! UINavigationController) .pushViewController(vc, animated: true)
                        } else if currentViewController != nil {
                            currentViewController?.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            //print("Please check navigationPush method")
                        }
                    } else if tag == "item" {
                        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ItemDetailVC") as! RackDetailVC
                        vc.dictFromParent = ItemModel(fromJson: JSON(record))
                        vc.copyDictFromParent = ItemModel(fromJson: JSON(record))
                        let currentViewController = (AppDelegate.shared.window?.currentViewController() as? UITabBarController)?.selectedViewController
                        if currentViewController is UINavigationController {
                            (currentViewController as! UINavigationController) .pushViewController(vc, animated: true)
                        } else if currentViewController != nil {
                            currentViewController?.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            //print("Please check navigationPush method")
                        }
                    }
                }
            }
        }
    }
    
    func setHomePage(_ window : UIWindow!) {
        //TODO:- Load Data into currentUser. Take care of it. :)
        //To Load Current User Data  in to curretnUser From UserDefaults.
        // Follow Line must require to load data From UserDefaults to current User.
        UserModel.currentUser.getUserDetailFromDefaults()
        
        weak var tabBarController = secondStoryBoard.instantiateViewController(withIdentifier: "kNavigationTabBarController") as? TabBar
        window.makeKeyAndVisible()
        
        window.rootViewController = tabBarController
        AppDelegate.shared.registerForPush()
        
        /*
         Set notification badge count
         */
        GFunction.shared.setNotificationCountAPI { (isSuccess : Bool, jsonResponse : JSON?) in
            if isSuccess {
                if AppDelegate.shared.window?.topMostController() is UITabBarController {
                    if #available(iOS 10.0, *) {
                        tabBarController?.tabBar.items?[3].badgeValue = jsonResponse?["notification_count"].stringValue == "0" ? nil : jsonResponse!["notification_count"].stringValue
                        tabBarController?.tabBar.items?[3].badgeColor = UIColor.white
                        tabBarController?.tabBar.items?[3].setBadgeTextAttributes([NSForegroundColorAttributeName : UIColor.black], for: UIControlState.normal)
                        
                        let notification =  NotificationPopUP.instance()
                        notification.reloadNotificationCounts(countsDict: jsonResponse!["unread_counts"].dictionaryObject as! [String : String])
                        
                    } else {
                        
                        let barView = tabBarController?.tabBar.subviews[4].subviews[0]
                        barView?.setRightBadgeButton(jsonResponse!["notification_count"].stringValue)
                    }
                }
            }
            
            /*
             Load discover along with newsfeed - Start check
             */
            if tabBarController?.viewControllers != nil {
                if let searchVC = (tabBarController?.viewControllers![1] as! UINavigationController).topViewController as? SearchVC {
                    if let discoverVC = searchVC.arrayControllers[0] as? DiscoverVC {
                        _ = discoverVC.view
                    }
                }
            }
            /*
             Load discover along with newsfeed - End
             */
        }
    }
    
    //------------------------------------------------------
    
    //MARK: - SnackBar
    
    func showPopUpAlert(_ message : String?
        , forTime time : Int = 3
        , completionBlock : ((_ : Int) -> ())? = nil) {
        /*
         snackbar.message = message!
         snackbar.duration = .middle
         
         // Change the content padding inset
         snackbar.contentInset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
         
         // Change margin
         snackbar.leftMargin = 8
         snackbar.rightMargin = 8
         
         
         // Change message text font and color
         snackbar.messageTextColor = UIColor.white
         snackbar.messageTextFont = UIFont.applyRegular(fontSize: 14.0)
         
         // Change snackbar background color
         snackbar.backgroundColor = UIColor.black
         snackbar.layer.borderColor = UIColor.colorFromHex(hex: kColorGray74).cgColor
         snackbar.layer.borderWidth = 0.3
         
         // Change animation duration
         snackbar.animationDuration = 0.3
         
         // Animation type
         snackbar.animationType = .slideFromBottomBackToBottom
         
         snackbar.show()
         
         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((ino64_t)(Double(time) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
         
         if completionBlock != nil {
         completionBlock!(0)
         }
         })*/
    }
    
    //------------------------------------------------------
    
    //MARK:- Loader Method
    
    func addLoader(_ message : String?) {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityLoader)
        
        if let _ = message {
            NVActivityIndicatorPresenter.sharedInstance.setMessage(message)
        }
    }
    func changeLoaderMessage(_ message : String) {
        NVActivityIndicatorPresenter.sharedInstance.setMessage(message)
    }
    
    func removeLoader() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    //------------------------------------------------------
    
    //MARK: - UIACtivityIndicator
    
    func addActivityIndicator(view : UIView) {
        
        removeActivityIndicator()
        
        indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.color = UIColor.white
        
        view.addSubview(indicatorView)
        
        let horizontalConstraint = NSLayoutConstraint(item: indicatorView,
                                                      attribute: .centerX,
                                                      relatedBy: .equal,
                                                      toItem: view,
                                                      attribute: .centerX,
                                                      multiplier: 1,
                                                      constant: 0)
        
        view.addConstraint(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint(item: indicatorView,
                                                    attribute: .centerY,
                                                    relatedBy: .equal,
                                                    toItem: view,
                                                    attribute: .centerY,
                                                    multiplier: 1,
                                                    constant: 0)
        
        view.addConstraint(verticalConstraint)
    }
    
    func removeActivityIndicator() {
        indicatorView.isHidden = true
        indicatorView.stopAnimating()
        indicatorView .removeFromSuperview()
    }
    
    //------------------------------------------------------
    
    //MARK:- MBProgressHud
    
    func showPopup(with message: String, forTime time: Int, withComplition completion: @escaping () -> Void, andViewController viewController: UIViewController) {
        
        if AppDelegate.shared.window?.currentViewController() != nil {
            let hud = MBProgressHUD.showAdded(to: viewController.view, animated: true)
            hud.isUserInteractionEnabled = false
            
            hud.bezelView.style = .solidColor
            // Configure for text only and offset down
            hud.bezelView.color = UIColor.black
            hud.bezelView.layer.borderColor = UIColor.white.cgColor
            hud.bezelView.layer.borderWidth = 1.0
            hud.bezelView.layer.cornerRadius = 2.0
            hud.mode = .text
            hud.label.text = message
            hud.label.textColor = UIColor.white
            hud.label.font = UIFont.applyRegular(fontSize: 13.0, isAspectRasio: false)
            
            hud.margin = 10.0
            hud.removeFromSuperViewOnHide = true
            hud.hide(animated: true, afterDelay: TimeInterval(time))
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((__int64_t)((Double(time) + 0.20) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                completion()
            })
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- UserDefaults
    
    func saveDataIntoUserDefault (object : AnyObject, key : String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(object, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    func removeUserDefaults (key : String) {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func getDeviceToken () -> String {
        
        if (UserDefaults.standard.value(forKey: kDeviceToken) != nil) {
            
            let deviceToken : String? = UserDefaults.standard.value(forKey: kDeviceToken) as? String
            
            guard let
                letValue = deviceToken, !letValue.isEmpty else {
                    //print(":::::::::-Value Not Found-:::::::::::")
                    return "0"
            }
            return deviceToken!
        }
        return "0"
    }
    
    
    
    
    //------------------------------------------------------
    
    enum TimeFormatType {
        case short
        case full
    }
    
    //MARK: - Other Method
    func conversionSecondsToPostDuration(_ seconds: Int?, formatType: TimeFormatType) -> String {
        
        guard let seconds = seconds else {
            return ""
        }
        
        let minutes: Int = seconds / 60
        let hours: Int = minutes / 60
        let day: Int = hours / 24
        let week: Int = day / 7
        
        if formatType == .short {
            if seconds / 60 < 1 {
                return "\(Int(seconds))s"
            }
            else if minutes >= 1 && minutes <= 59 {
                return "\(Int(minutes))m"
            }
            else if hours < 24 {
                return "\(Int(hours))h"
            }
            else if day < 7 {
                return "\(Int(day))d"
            }
            else {
                return "\(Int(week))w"
            }
        }else{
            if seconds / 60 < 1 {
                return Int(seconds) > 1 ? "\(Int(seconds)) seconds ago" : "\(Int(seconds)) second ago"
            }
            else if minutes >= 1 && minutes <= 59 {
                return Int(minutes) > 1 ? "\(Int(minutes)) minutes ago" : "\(Int(minutes)) minute ago"
            }
            else if hours < 24 {
                return Int(hours) > 1 ? "\(Int(hours)) hours ago" : "\(Int(hours)) hour ago"
            }
            else if day < 7 {
                return Int(day) > 1 ? "\(Int(day)) days ago" : "\(Int(day)) day ago"
            }
            else {
                return Int(week) > 1 ? "\(Int(week)) weeks ago" : "\(Int(week)) week ago"
            }
        }
        
    }
    
    func getProfileCount(_ strView : String) -> String {
        
        guard let count : Int32 = Int32(strView) else {
            return ""
        }
        
        if count <= 0 {
            return ""
        }
        
        if count >= 1000000 {
            if count >= 1100000 {
                let num = Float(count) / Float(1000000)
                return  String(format: "%.1f M", Double(num).truncate(places: 1)).replacingOccurrences(of: ".0", with: "")
            }
            else {
                let num = count / 1000000
                return  String(format: "%ld M", Double(num).truncate(places: 1)).replacingOccurrences(of: ".0", with: "")
            }
        }
        else if count >= 100000 {
            let num = count / 1000
            return  String(format: "%ld K", Double(num).truncate(places: 1)).replacingOccurrences(of: ".0", with: "")
        }
        else if count >= 1000 {
            if count >= 1100 {
                let num = Float(count) / Float(1000)
                return String(format: "%.1f K", Double(num).truncate(places: 1)).replacingOccurrences(of: ".0", with: "")
            }
            else {
                let num = count / 1000
                return  String(format: "%ld K", num).replacingOccurrences(of: ".0", with: "")
            }
        }
        else {
            return  String(format: "%ld", Int(count)).replacingOccurrences(of: ".0", with: "")
        }
    }
    
    /*func getProfileCount(_ number: String) -> String {
     
     guard let count : Int32 = Int32(number) else {
     return ""
     }
     
     if count <= 0 {
     return ""
     }
     
     var num = Int64(number)
     let s: Int = (num! < 0) ? -1 : (num! > 0) ? 1 : 0
     let sign: String = s == -1 ? "-" : ""
     num = llabs(num!)
     if num! < 1000 {
     return "\(sign)\(num!)"
     }
     
     let numb = CGFloat(num!)
     
     let exp = Int(log(numb) / log(1000))
     let units = ["K", "M", "G", "T", "P", "E"]
     
     let strDec = String(describing: pow(1000, exp))
     
     let countString = String(format: "%0.1f", Double("\(numb / (CGFloat(Double(strDec)!)))")!)
     
     return "\(sign)\(countString.replacingOccurrences(of: ".0", with: ""))\(units[exp-1])"
     }*/
    
    func convertToJSONString(arrayData : Any) -> String {
        
        do {
            //Convert to Data
            let jsonData = try JSONSerialization.data(withJSONObject: arrayData, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            //Convert back to string. Usually only do this for debugging
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                return JSONString
            }
        }
        catch {
            return ""
        }
        return ""
    }
    
    func showNotificationView(_ strTitle : String, _ strMsg: String) {
        notificationView.removeFromSuperview()
        
        notificationView = NotificationView(frame: CGRect(x: 0, y: -64, width: kScreenWidth, height: 0))
        AppDelegate.shared.window?.addSubview(notificationView)
        AppDelegate.shared.window?.bringSubview(toFront: notificationView)
        
        notificationView.lblTitle.text = strTitle
        notificationView.lblDesc.text = strMsg
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        notificationView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 64)
        UIView.commitAnimations()
        perform(#selector(self.hideNotificationView), with: nil, afterDelay: 3.0)
    }
    
    func hideNotificationView() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        notificationView.frame = CGRect(x: 0, y: -64, width: kScreenWidth, height: 64)
        UIView.commitAnimations()
    }
    
    func setNotificationCountAPI(withCompletion block:@escaping (Bool, JSON?) -> Void) {
        /*
         ===========API CALL===========
         
         Method Name : item/itemwant
         
         Parameter   : item_id
         
         Optional    :
         
         Comment     : This api will used for user to save particular item to want list.
         
         ==============================
         */
        
        APICall.shared.GET(strURL: kMethodUserNotificationCount
            , parameter: nil
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
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
    
    func setNotificationCount() {
        /*
         Set notification badge count
         */
        GFunction.shared.setNotificationCountAPI { (isSuccess : Bool, jsonResponse : JSON?) in
            if isSuccess {
                if AppDelegate.shared.window?.topMostController() is UITabBarController {
                    if #available(iOS 10.0, *) {
                       
                    
                 (AppDelegate.shared.window?.topMostController() as! UITabBarController).tabBar.items?[3].badgeValue = jsonResponse?["notification_count"].stringValue == "0" ? nil : jsonResponse!["notification_count"].stringValue
                        (AppDelegate.shared.window?.topMostController() as! UITabBarController).tabBar.items?[3].badgeColor = UIColor.white
                        (AppDelegate.shared.window?.topMostController() as! UITabBarController).tabBar.items?[3].setBadgeTextAttributes([NSForegroundColorAttributeName : UIColor.black], for: UIControlState.normal)
                        
                        
                        let notification =  NotificationPopUP.instance()
                        notification.reloadNotificationCounts(countsDict: jsonResponse!["unread_counts"].dictionaryObject as! [String : String])
                        
                    } else {
                        let barView = (AppDelegate.shared.window?.topMostController() as! UITabBarController).tabBar.subviews[4].subviews[0]
                        barView.setRightBadgeButton(jsonResponse!["notification_count"].stringValue)
                    }
                }
            }
        }
    }
    
    func getTutorialState(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        /*
         ===========API CALL===========
         
         Method Name : user/view_user_tutorial
         
         Parameter   : tutorial_type('Newsfeed', 'Search', 'Add', 'Profile', 'OtherProfile', 'Setting')
         
         Optional    :
         
         Comment     : This api will user check already view tutorial.
         
         ==============================
         */
        
        APICall.shared.GET(strURL: kMethodUserViewTutorial
            , parameter: requestModel.toDictionary()
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    block(true)
                    break
                    
                default:
                    block(false)
                    break
                }
            } else {
                block(false)
            }
        }
    }
    
    func setTutorialState(_ requestModel : RequestModel) {
        /*
         ===========API CALL===========
         
         Method Name : user/add_user_tutorial
         
         Parameter   : tutorial_type('Newsfeed', 'Search', 'Add', 'Profile', 'OtherProfile', 'Setting')
         
         Optional    :
         
         Comment     : This api will used for user got it tutorial.
         
         ==============================
         */
        
        APICall.shared.GET(strURL: kMethodUserAddTutorial
            , parameter: requestModel.toDictionary()
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
            if (error == nil) {
                //                let response = JSON(response ?? [:])
                //                let status = response[kCode].stringValue
                
            } else {
                
            }
        }
    }
    
}
