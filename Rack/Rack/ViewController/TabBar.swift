//
//  TabBar.swift
//  Rack
//
//  Created by hyperlink on 08/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import EasyTipView
import Pulsator

var tabBarInstance: UITabBar!
class TabBar: UITabBarController , UITabBarControllerDelegate {
    
    //MARK:- Outlet
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    static var previousVC : UIViewController? = nil
    var animateTimer = Timer()
    var guideView = GuideView()
    
    //------------------------------------------------------
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        //remove observer
        NotificationCenter.default.removeObserver(kNotificationSetHomePage)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    func setUpView() {
        self.delegate = self
        tabBar.backgroundImage = UIImage()
        
        //add notification for setting home page after uploading item
        NotificationCenter.default.addObserver(self, selector: #selector(notificationSetHomePage(_:)), name: NSNotification.Name(rawValue: kNotificationSetHomePage), object: nil)
        
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationSetHomePage(_ notification : Notification) {
        
        self.selectedIndex = 0
        if let navigation = self.childViewControllers.first as? UINavigationController {
            navigation.popToRootViewController(animated: false)
          navigation.visibleViewController?.viewWillAppear(false)
        }
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    
    //------------------------------------------------------
    
    //MARK: TabBarDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if tabBarController.tabBar.selectedItem!.tag == 2 {
            appDelegate().guideView.tipDismiss(forAnim: .aCreateRack)
            appDelegate().guideView.saveTapActivity(forAnim: .aCreateRack)
            let navigationController = secondStoryBoard.instantiateViewController(withIdentifier: "kNavigationCreatePost") as! UINavigationController
            present(navigationController, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        //To manage scroll rackVC on tap of tapBar.
        if TabBar.previousVC == viewController {
            
            if let navigation = viewController as? UINavigationController {
                
                if let rackVC = navigation.viewControllers.first as? RackVC {
                    if rackVC.isViewLoaded && (rackVC.view.window != nil) {
                        //                        rackVC.tblHome.setContentOffset(CGPoint.zero, animated: true)
                        if !rackVC.arrayItemData.isEmpty {
                            let index = IndexPath(row: 0, section: 0)
                            rackVC.tblHome.scrollToRow(at: index, at: UITableViewScrollPosition.top, animated: true)
                        }
                    }
                }
            }
        }
        
        TabBar.previousVC = viewController
        
        let navigationCntr : UINavigationController = tabBarController.viewControllers![tabBarController.selectedIndex] as! UINavigationController
        navigationCntr.delegate = AppDelegate.shared.transitionar
        
        if (navigationCntr.viewControllers.count > 1){
            AppDelegate.shared.isSwipeBack = true
            if let _ = navigationController {
        AppDelegate.shared.transitionar.addTransition(forView: (navigationController?.topViewController?.view)!)
                navigationCOntroller = navigationController
                navigationController?.delegate = AppDelegate.shared.transitionar
            }
        }
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item.tag == 1 { //Search
            //TODO:- Check whether to show onboarding or no
//            let requestModel = RequestModel()
//            requestModel.tutorial_type = tutorialFlag.Search.rawValue
//
//            GFunction.shared.getTutorialState(requestModel) { (isSuccess: Bool) in
//                if isSuccess {
//                    let onBoarding = mainStoryBoard.instantiateViewController(withIdentifier: "OnboardingBaseVC") as! OnboardingBaseVC
//                    onBoarding.tutorialType = .Search
//                    self.present(onBoarding, animated: false, completion: nil)
//                } else {
//
//                }
//            }
        }
        else if item.tag == 3 { //Notification
            if let navigation = self.childViewControllers[3] as? UINavigationController {
                if let notificationVC = navigation.viewControllers.first as? NotificationVC {
                    notificationVC.perform(#selector(notificationVC.callApi), with: nil, afterDelay: 0.5)
                }
            }
        }
        else if item.tag == 4 { // Own Profile
            //TODO:- Check whether to show onboarding or no
//            let requestModel = RequestModel()
//            requestModel.tutorial_type = tutorialFlag.Profile.rawValue
//            
//            GFunction.shared.getTutorialState(requestModel) { (isSuccess: Bool) in
//                if isSuccess {
//                    let onBoarding = mainStoryBoard.instantiateViewController(withIdentifier: "OnboardingBaseVC") as! OnboardingBaseVC
//                    onBoarding.tutorialType = .Profile
//                    self.present(onBoarding, animated: false, completion: nil)
//                } else {
//                    
//                }
//            }
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let secondItemView = tabBar.subviews[3]
//        let imageView = secondItemView.subviews.flatMap { $0 as? UIImageView }.first
//        
//        let item = tabBar.items
//        if let superview = tabBar.superview {
//            guideView.addTipOnItem(item![2], withinSuperView: superview, textType: .createRack)
//            guideView.addAnimation(imageView!, withinSuperview: true)
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        guideView.tipDismiss()
    }
}
