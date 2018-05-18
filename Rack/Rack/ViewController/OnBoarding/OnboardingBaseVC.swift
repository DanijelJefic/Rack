//
//  ViewController.swift
//  TutorialDemo
//
//  Created by hyperlink on 07/10/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class OnboardingBaseVC: UIViewController {

    //------------------------------------------------------
    
    //MARK:- Outlet
    
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var btnAction: UIButton!
    //------------------------------------------------------
    
    //MARK:- Class variable
    
    var currentindex : Int = 0
    
    var dictData : Dictionary<String,[UIImage]> = [:]
    
    var arrayImage : [UIImage] = []
    
    var pageViewController: UIPageViewController = UIPageViewController()
    
    var pages = [UIViewController]()
    
    var tutorialType :tutorialFlag = .Search
    
    //------------------------------------------------------
    
    //MARK:- WS Methods
    
    //------------------------------------------------------
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Methods
    
    func setUp() {
        
        btnAction.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 13.0), titleLabelColor: UIColor.colorFromHex(hex: kColorDarkGray), backgroundColor: UIColor.white)
        
        dictData =
            [
                tutorialFlag.Search.rawValue : [#imageLiteral(resourceName: "TDiscover"),#imageLiteral(resourceName: "TPeople"),#imageLiteral(resourceName: "THashTag"),#imageLiteral(resourceName: "TBrand"),#imageLiteral(resourceName: "TItem")]
                ,
                tutorialFlag.Add.rawValue : [#imageLiteral(resourceName: "Upload1"),#imageLiteral(resourceName: "Upload2"),#imageLiteral(resourceName: "Upload3"),#imageLiteral(resourceName: "Upload4"),#imageLiteral(resourceName: "Upload5"),#imageLiteral(resourceName: "Upload6")]
                ,
                tutorialFlag.Newsfeed.rawValue : [#imageLiteral(resourceName: "Newsfeed1"),#imageLiteral(resourceName: "Newsfeed2"),#imageLiteral(resourceName: "Newsfeed3"),#imageLiteral(resourceName: "Newsfeed4")]
                ,
                tutorialFlag.Profile.rawValue : [#imageLiteral(resourceName: "Profile1"),#imageLiteral(resourceName: "Profile2"),#imageLiteral(resourceName: "Profile3"),#imageLiteral(resourceName: "Profile4")]
                ,
                tutorialFlag.OtherProfile.rawValue : [#imageLiteral(resourceName: "OtherProfile1"),#imageLiteral(resourceName: "OtherProfile2")]
                ,
                tutorialFlag.Setting.rawValue : [#imageLiteral(resourceName: "Setting1"),#imageLiteral(resourceName: "Setting2"),#imageLiteral(resourceName: "Setting3"),#imageLiteral(resourceName: "Setting4")]
        ]
        
        setData(flag: tutorialType)
        
    }
    
    func setData(flag : tutorialFlag) {
        
        arrayImage = self.dictData[flag.rawValue]!
        
        for i in 0...(arrayImage.count) - 1 {
            let imageVC : ImageVC = mainStoryBoard.instantiateViewController(withIdentifier: "ImageVC") as! ImageVC
            imageVC.img = arrayImage[i]
            pages.append(imageVC)
        }
        
        pageViewController = mainStoryBoard.instantiateViewController(withIdentifier: "pageView") as! UIPageViewController
        addChildViewController(pageViewController)
        viewContainer.addSubview((pageViewController.view)!)
        
        pageViewController.didMove(toParentViewController: self)
        
        self.nextPageTransition()
        
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController!
    {
        if index >= self.pages.count
        {
            return nil
        }
        return pages[index]
    }
    
    func nextPageTransition() {
        pageViewController.setViewControllers([viewControllerAtIndex(index: currentindex)], direction: .forward, animated: true) { (isSuccess : Bool) in
            if isSuccess {
                self.currentindex = self.currentindex + 1
                
                if self.currentindex == self.arrayImage.count {
                    self.btnAction.setTitle("OK, GOT IT", for: UIControlState.normal)
                } else {
                    self.btnAction.setTitle("NEXT", for: UIControlState.normal)
                }
            }
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Methods
    
    @IBAction func btnAction(_ sender: UIButton) {
        
        if currentindex > arrayImage.count {
            return
        }
        
        if currentindex == arrayImage.count {
            
            switch tutorialType {
            case .Newsfeed:
                self.dismiss(animated: false, completion: nil)
                break
            case .Search:
                self.dismiss(animated: false, completion: nil)
                break
            case .Add:
                self.dismiss(animated: false, completion: nil)
                break
            case .Profile:
                self.dismiss(animated: false, completion: nil)
                break
            case .OtherProfile:
                self.dismiss(animated: false, completion: nil)
                break
            case .Setting:
                self.dismiss(animated: false, completion: nil)
                break
            
            }
            
            let requestModel = RequestModel()
            requestModel.tutorial_type = tutorialType.rawValue
            GFunction.shared.setTutorialState(requestModel)
            return
        }
        
        self.nextPageTransition()
        
    }
    
    //------------------------------------------------------
    
    //MARK:- UI View Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.pageViewController.view.frame = CGRect.init(x: 0, y: 0, width: self.viewContainer.frame.size.width, height: self.viewContainer.frame.size.height)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}

