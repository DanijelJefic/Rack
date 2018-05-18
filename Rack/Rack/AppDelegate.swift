
//
//  AppDelegate.swift
//  Rack
//
//  Created by hyperlink on 27/04/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotificationsUI
import UserNotifications
import PeekView
import FBSDKCoreKit
import AFNetworking
import Fabric
import Crashlytics
import PinterestSDK
import TMTumblrSDK
import GoogleSignIn
import TMTumblrSDK
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var coverImage:UIImage! = nil
    var window: UIWindow?

    static let shared = UIApplication.shared.delegate as! AppDelegate
    
    var guideView = GuideView()
    var transitionar = LazyTransitioner()
    var isSwipeBack : Bool = true

    //------------------------------------------------------
    
    //MARK: - Life Cycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.applicationIconBadgeNumber = 1
        UIApplication.shared.applicationIconBadgeNumber = 0
        Fabric.with([Crashlytics.self])
        // Get Device Photos Setup
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            _ = imagesManager().getImages()
        } else{
            sleep(UInt32(0.25))
        }
        
        UITabBar.appearance().tintColor = UIColor.lightGray
        if #available(iOS 10.0, *) {
            UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
        } else {
            // Fallback on earlier versions
        }
        //setRootViewController
        if (UserDefaults.standard.value(forKey: kLoginUserData) != nil){
            GFunction.shared.userLogin(window!)
        } else {
            GFunction.shared.userLogOut(window!)
        }
        GIDSignIn.sharedInstance().clientID = "564037096269-nkru8dtdv5qgtmkeic9ie0557j3llsbc.apps.googleusercontent.com"
//        GIDSignIn.sharedInstance().delegate = self
        self.basicSetUp()
        self.checkRechability()
        googleAnalytics().setUp()
        //Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if let data = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] {
            //print(data)
            
            /*
             Handle Push
             */
            
            GFunction.shared.navigationPush(userInfo: data as! [AnyHashable : Any])
        }
        transitionar = LazyTransitioner(animator: PopAnimator(orientation: .leftToRight))
        
        return true
    }
    

    
    
    
    func dismissTipViewWithoutSave() {
        guideView.tipDismiss(forAnim: .aCreateRack)
    }
    
    func addTipView(){
        
        let tabBarInstance = window?.rootViewController as! TabBar
        
        guideView.tipDismiss(forAnim: .aCreateRack)

        if let items = tabBarInstance.tabBar.items {
            for item in items {
                if item.tag == 2 {
                    if let superview = tabBarInstance.tabBar.superview {
                        guideView.addTipOnItem(item, withinSuperView: superview, textType: .tCreateRack, forAnim: .aCreateRack)
                    }
                }
            }
            
            for vw in tabBarInstance.tabBar.subviews {
                if let imageView = (vw.subviews.flatMap { $0 as? UIImageView }.first) {
                    if imageView.image == UIImage(named: "btnAddWhite") {
                        guideView.addAnimation(imageView, withinSuperview: false, forAnim: .aCreateRack)
                    }
                }
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {

    }
    

    
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 1
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //When user keeps create post in background and takes a screenshot, it would update gallery
        if (window?.currentViewController()?.isKind(of: CreatePostVC.self))!{
            NotificationCenter.default.post(name: Notification.Name(kNotificationScreenShot), object: nil)
        }
        
        if (UserDefaults.standard.value(forKey: kLoginUserData) != nil){
            /*
             Set notification badge count
             */
            GFunction.shared.setNotificationCount()
            notificationEnable()
        }
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        googleAnalytics().tracker.set(kGAISessionControl, value: "end")
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        if Twitter.sharedInstance().application(app, open:url, options: options) { // twitter
            return true
        }
        
        let appId = FBSDKSettings.appID()
        if url.scheme != nil && url.scheme!.hasPrefix("fb\(String(describing: appId!))") && url.host ==  "authorize" { // facebook
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        }
        
        if PDKClient.sharedInstance().handleCallbackURL(url) { //Pinterest
            return true
        }
        
//        if TMAPIClient.sharedInstance().handleOpen(url) { //Tumblr
//            return true
//        }
        
        return false
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        googleAnalytics().sendHitsInBackground()
        completionHandler(.newData)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        googleAnalytics().sendHitsInBackground()
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
//        let scheme = url.scheme
//        if("rack" == scheme) {
//            // I don't recommend doing it like this, it's just a demo... I use an authentication
//            // controller singleton object in my projects
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "UserAuthCallbackNotification"), object: url)
//        }
        return true
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        SDImageCache.shared().cleanDisk()
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    //------------------------------------------------------
    
    //MARK: - Device Token
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        GFunction.shared.saveDataIntoUserDefault(object: deviceTokenString  as AnyObject, key: kDeviceToken)
        //print(deviceTokenString)
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        //print("Device Token Not Found \(error)")
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Receive
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        //print(application.applicationState)
        //print(userInfo)
        
        //Display notification below iOS 10
//        if let _ = userInfo["aps"], let msg = (userInfo["aps"]! as! Dictionary<String,Any>)["alert"] {
//            GFunction.shared.showNotificationView(kAppName,msg as! String)
//        }
        
        /*
         Handle Push
         */
        
        let applicationState = application.applicationState
        
        if applicationState == UIApplicationState.inactive {
            GFunction.shared.navigationPush(userInfo: userInfo)
        } else if applicationState == UIApplicationState.active {
            UIApplication.shared.applicationIconBadgeNumber = 1
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        /*
         Set notification badge count
         */
        
        GFunction.shared.setNotificationCount()
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        GFunction.shared.setNotificationCount()
        //print(notification.request.content.userInfo)
        //completionHandler(.alert)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //print(response.notification.request.content.userInfo)
        
         GFunction.shared.navigationPush(userInfo: response.notification.request.content.userInfo)
    }


    //------------------------------------------------------
    
    //MARK: - Custom Method

    func basicSetUp() {

        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
    }
    
    func registerForPush() {
        //For device token
        UIApplication.shared.registerForRemoteNotifications()
        let settings = UIUserNotificationSettings(types: [.alert , .sound , .badge], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        
        if #available(iOS 10.0, *) {
            let center : UNUserNotificationCenter = UNUserNotificationCenter.current()
            center.delegate = self
            
            center.requestAuthorization(options: [.sound , .alert , .badge ], completionHandler: { (granted, error) in
                
                if ((error != nil)) {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            })
        }
        
        let requestModel = RequestModel()
        requestModel.device_token = GFunction.shared.getDeviceToken()
        requestModel.device_type = "I"
        
        self.callEditDeviceInfoAPI(requestModel)
    }
    
    func isNotificationEnabled() -> Bool {
        
        /*
         Old Rack Application Logic
         */
        
        if (UserDefaults.standard.value(forKey: kAppLaunch)) == nil {
            UserDefaults.standard.set(0, forKey: kAppLaunch)
        }
        
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            UserDefaults.standard.set(0, forKey: kAppLaunch)
        } else {
            UserDefaults.standard.set((UserDefaults.standard.value(forKey: kAppLaunch)) as! Int + 1, forKey: kAppLaunch)
        }
        
        if (UserDefaults.standard.value(forKey: kAppLaunch)) as! Int % 10 != 0 {
            return false
        }
        
        let curruntSettings = UIApplication.shared.currentUserNotificationSettings
        if curruntSettings?.types == [] {
            
            let alertController = UIAlertController(title: "Push Notifications", message: "Please go to the App Settings, tap on Notifications and then select Allow Notifications.", preferredStyle: UIAlertControllerStyle.alert)
            
            let setting = UIAlertAction(title: "Go to Settings", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
            })
            
            let close = UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                
            })
            
            alertController.addAction(setting)
            alertController.addAction(close)
            
            (self.window?.rootViewController)!.present(alertController, animated: true, completion: nil)
            
            return false
        }
        return true
    }
    
    func notificationEnable() {
        if (UserDefaults.standard.value(forKey: kLoginUserData) != nil){
            _ = self.isNotificationEnabled()
            
            let requestModel = RequestModel()
            requestModel.device_token = GFunction.shared.getDeviceToken()
            requestModel.device_type = "I"
            
            self.callEditDeviceInfoAPI(requestModel)
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- API Call
    
    func callEditDeviceInfoAPI(_ requestModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : user/editdevice_info
         
         Parameter   : device_type[A,I],device_token
         
         Optional    :
         
         Comment     : This api will used for update the device information.
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodUserDeviceInfo
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
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
    
    //------------------------------------------------------
    
    //MARK:- Check intenet connection
    
    func checkRechability() {
        
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange {  (status: AFNetworkReachabilityStatus) in
            
            debugPrint(status.rawValue)
            
            switch (status.rawValue){
            case 0,-1:
                GFunction.shared.removeLoader()
                AlertManager.shared.showAlertTitle(title: "Network Issue!", message: "Rack has failed to retrieve data. Please check your Internet connection and try again")
                
                
                break
                
            case 1,2:
                
                
                break
            default:
                
                break
            }
        }
        AFNetworkReachabilityManager.shared().startMonitoring()
    }

    
    
}

func appDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

