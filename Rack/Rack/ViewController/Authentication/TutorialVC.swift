//
//  TutorialVC.swift
//  Rack
//
//  Created by hyperlink on 27/04/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit


class TutorialVC: UIViewController {
    
    //MARK:- Outlet
    
    //------------------------------------------------------
    @IBOutlet var viewToAdd: UIView!
    @IBOutlet weak var viewBottom: UIView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var constAspecBottomView: NSLayoutConstraint!
    
    
    //MARK:- Class Variable
    var arrayControllers : Array! = [UIViewController]()
    var pageviewController = UIPageViewController()
    
    var arrayTutorial = [Dictionary<String,Any>]()
    
    var fromPage = PageFrom.defaultScreen
    
    //------------------------------------------------------
    
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        
        //Navigation Bar setup
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
     //   self.navigationController?.navigationBar.shadowImage = UIImage()
        
          self.navigationController?.customize()
        //Apply Button style
        btnLogin.applyStyle(
            titleLabelFont: UIFont.applyBold(fontSize: 13.0)
            , titleLabelColor: UIColor.colorFromHex(hex: kColorGray74)
            , borderColor: UIColor.colorFromHex(hex: kColorGray74)
        )
        btnRegister.applyStyle(
            titleLabelFont: UIFont.applyBold(fontSize: 13.0)
            , titleLabelColor: UIColor.colorFromHex(hex: kColorGray74)
            , borderColor: UIColor.colorFromHex(hex: kColorGray74)
        )
        
        btnClose.applyStyle(
            titleLabelFont: UIFont.applyBold(fontSize: 13.0)
            , titleLabelColor: UIColor.colorFromHex(hex: kColorGray74)
            , borderColor: UIColor.clear
            , borderWidth       : 0.0
        )
        
        //If page from setting screen then -> Require close button and only three tutorial page
        if fromPage == .fromSettingPage {
            
            btnLogin.isHidden = true
            btnRegister.isHidden = true
            btnClose.isHidden = false
            
        } else {
            
            btnLogin.isHidden = false
            btnRegister.isHidden = false
            btnClose.isHidden = true
            
            arrayTutorial.append([kMessage : "" , kImage : #imageLiteral(resourceName: "Tutorial_1")])
        }
        
        arrayTutorial.append([kMessage : "SHOWCASE & SHARE\nYOUR WANTED ITEMS" , kImage : #imageLiteral(resourceName: "Tutorial_2")])
        arrayTutorial.append([kMessage : "FOLLOW FRIENDS & SHOW OFF\nWHAT'S IN YOUR RACK." , kImage : #imageLiteral(resourceName: "Tutorial_3")])
        arrayTutorial.append([kMessage : "A CATALOGUE OF ITEMS\nAT YOUR FINGERTIPS." , kImage : #imageLiteral(resourceName: "Tutorial_4")])
        arrayTutorial.append([kMessage : "A CATALOGUE OF ITEMS\nAT YOUR FINGERTIPS." , kImage : #imageLiteral(resourceName: "Tutorial_5")])
        
        var index : NSInteger = 0
        for item in arrayTutorial {
            
            let vc : PageVC = mainStoryBoard.instantiateViewController(withIdentifier: "PageVC") as! PageVC
            vc.dicData = item
            vc.index = index
            vc.fromPage = fromPage
            index = index + 1
            
            arrayControllers.append(vc)
        }
        
        pageviewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageviewController.setViewControllers([arrayControllers[0]], direction: .forward, animated: false, completion: nil)
        pageviewController.delegate = self
        pageviewController.dataSource = self
        pageviewController.view.frame = CGRect(x: 0, y: 0, width: viewToAdd.frame.size.width, height: viewToAdd.frame.size.height + 40)
        addChildViewController(pageviewController)
        viewToAdd.addSubview(pageviewController.view)
        pageviewController.didMove(toParentViewController: self)
        
        pageControl.numberOfPages = arrayTutorial.count
        pageControl.currentPage = 0
        
        //Google Analytics
        
        let category = "UI"
        let action = "\(UserModel.currentUser.displayName!) view \("tutorial")"
        let lable = ""
        let screenName = "Settings - About Us - Tutorials"
        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
        
        //Google Analytics
        
    }
    
    func bottomViewAnimtion(){
        
        let oldConstraint: NSLayoutConstraint? = constAspecBottomView
        let newMultiplier: CGFloat = 7.11 //AspectRasio (320:45)
        
        let newConstraint = NSLayoutConstraint(item: oldConstraint!.firstItem
            , attribute: oldConstraint!.firstAttribute
            , relatedBy: oldConstraint!.relation
            , toItem: oldConstraint?.secondItem
            , attribute: oldConstraint!.secondAttribute
            , multiplier: newMultiplier
            , constant: oldConstraint!.constant)
        newConstraint.priority = (oldConstraint?.priority)!
        
        self.view.removeConstraint(oldConstraint!)
        self.view.addConstraint(newConstraint)
        
        viewBottom.alpha = 0.0
        UIView.animate(withDuration: 0.7) {
            self.viewBottom.alpha = 1.0
            self.viewBottom.layoutIfNeeded()
        }
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    @IBAction func btnLoginClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func btnRegisterClicked(_ sender: UIButton) {
        
        let registerVC : RegisterVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        self.navigationController?.pushViewController(registerVC, animated: true)
        
    }
    
    @IBAction func btnCloseClicked(_ sender : UIButton) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = addBarButtons(btnLeft: nil, btnRight: nil, title: nil)
        //        self.navigationController?.isNavigationBarHidden = true
        
        self.bottomViewAnimtion()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = addBarButtons(btnLeft: nil, btnRight: nil, title: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
}

extension TutorialVC : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    //MARK: - Datasource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = arrayControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return arrayControllers.last
        }
        
        guard arrayControllers.count > previousIndex else {
            return nil
        }
        
        return arrayControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = arrayControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = arrayControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return arrayControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return arrayControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.arrayTutorial.count
    }
    
    //MARK: - Delegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let firstViewController = pageviewController.viewControllers?.first,
            let index = arrayControllers.index(of: firstViewController) {
            pageControl.currentPage = index
        }
    }
}

class PageVC: UIViewController {
    
    //MARK:- Outlet
    
    @IBOutlet var imgTutorial : UIImageView!
    @IBOutlet var lblMessage  : UILabel!
    @IBOutlet var constHeightLblMessage : NSLayoutConstraint!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var dicData = Dictionary<String,Any>()
    var index : NSInteger = 0
    var fromPage = PageFrom.defaultScreen
    
    //------------------------------------------------------
    
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        
        //Font SetUp
        lblMessage.font = UIFont.applyBold(fontSize: 13.0)
        
        imgTutorial.image = dicData[kImage] as? UIImage
        lblMessage.text = dicData[kMessage] as? String
        
        if index == 0 && fromPage == .defaultScreen {
            view.backgroundColor = UIColor.black
            imgTutorial.contentMode = .center
            constHeightLblMessage.constant = 0
        } else {
            view.backgroundColor = UIColor.colorFromHex(hex: kColorDarkGray)
            imgTutorial.contentMode = .scaleAspectFit
            //TODO: Remove follow constraint line. if tutorial screen have message at top
            constHeightLblMessage.constant = 0
        }
        
         self.navigationController?.customize()
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
}
