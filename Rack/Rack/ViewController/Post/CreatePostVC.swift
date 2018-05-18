//
//  CreatePostVC.swift
//  Rack
//
//  Created by hyperlink on 25/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import Photos

class CreatePostVC: UIViewController {

    //MARK:- Outlet
    
    @IBOutlet weak var btnCameraRoll: UIButton!
    @IBOutlet weak var btnPhoto: UIButton!
    
    @IBOutlet weak var viewOptions: UIView!
    @IBOutlet weak var viewContainer: UIView!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    
    var btnNext: UIButton! = UIButton()
    
    var bottomLine = CALayer()
    
    var arrayControllers : Array! = [UIViewController]()
    var pageviewController = UIPageViewController()
    
    var containerViewType = ImagePostType.camera

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
      ///  self.navigationController?.navigationBar.shadowImage = UIImage()
          self.navigationController?.customize()
        //Apply button style
        btnCameraRoll.applyStyle(
            titleLabelFont : UIFont.applyRegular(fontSize: 12.0)
            , titleLabelColor : AppColor.btnTitle
        )
        
        btnPhoto.applyStyle(
            titleLabelFont: UIFont.applyRegular(fontSize: 12.0)
            , titleLabelColor : AppColor.btnTitle
        )
        
        btnPhoto.isExclusiveTouch = true
        btnCameraRoll.isExclusiveTouch = true
        self.navigationController?.customize()
        //Array of VCs..

        let vc1 : CameraRollVC = mainStoryBoard.instantiateViewController(withIdentifier: "CameraRollVC") as! CameraRollVC
        vc1.mode = .imagePostPickerMode
        vc1.delegate = self
        
        
        let vc2 : CameraVC = mainStoryBoard.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
        vc2.mode = .imagePostPickerMode
        vc2.delegate = self
        
        arrayControllers = [vc1,vc2]
        
        //PageController SetUp
        pageviewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageviewController.setViewControllers([arrayControllers[0]], direction: .forward, animated: false, completion: nil)
        pageviewController.view.frame = CGRect(x: 0, y: 0, width: viewContainer.frame.size.width, height: viewContainer.frame.size.height)
        addChildViewController(pageviewController)
        viewContainer.addSubview(pageviewController.view)
        pageviewController.didMove(toParentViewController: self)
        
        //Default CameraRoll Selection
        self.btnCameraRollClicked(btnCameraRoll)
    }

    func setUpViewWithDelay() {
        bottomLine = viewOptions.addBottomBorderWithColor(color: AppColor.secondaryTheme, origin: btnCameraRoll.frame.origin, width: kScreenWidth/2, height: 3)
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    func leftButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func rightButtonClicked() {
        
        switch containerViewType {
        case .camera:
            break
        case .gallery:
            
            if let vc = arrayControllers[0] as? CameraRollVC {
                if vc.scrollView.imageToDisplay != nil {
                    vc.delegate?.getSelectedReckDetail(data: [kImage : vc.captureVisibleRect()])
                }
            }
            break
        }
    }

    @IBAction func btnPhotoClicked(_ sender: UIButton) {

        btnNext.isEnabled = false
        
        containerViewType = .camera
        
        bottomLine.frame.origin.x = btnPhoto.frame.origin.x
        btnPhoto.titleLabel?.font = UIFont.applyBold(fontSize: 12.0)
        btnCameraRoll.titleLabel?.font = UIFont.applyRegular(fontSize: 12.0)
        pageviewController.setViewControllers([arrayControllers[1]], direction: .forward, animated: true, completion: nil)
    }
    
    @IBAction func btnCameraRollClicked(_ sender: UIButton) {

        btnNext.isEnabled = true

        containerViewType = .gallery
        
        bottomLine.frame.origin.x = btnCameraRoll.frame.origin.x
        btnCameraRoll.titleLabel?.font = UIFont.applyBold(fontSize: 12.0)
        btnPhoto.titleLabel?.font = UIFont.applyRegular(fontSize: 12.0)
        
        
        pageviewController.setViewControllers([arrayControllers[0]], direction: .reverse, animated: true, completion: nil)
        
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    private var popGesture: UIGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        if self.navigationController!.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
            self.popGesture = navigationController!.interactivePopGestureRecognizer
            self.navigationController!.view.removeGestureRecognizer(navigationController!.interactivePopGestureRecognizer!)
        }
        
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
        
        self.view.backgroundColor = AppColor.primaryTheme
        //self.tbl.backgroundColor = AppColor.primaryTheme
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.customize()
      
        let videoVC = FusumaViewController()
        videoVC.addPost = true
        videoVC.isNewuser = true
        //videoVC.userData = userData
        videoVC.cropHeightRatio = 1.0
        videoVC.allowMultipleSelection = false
        self.navigationController?.pushViewController(videoVC, animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
        //Reuuire to next button disable. Button array getting from addBarButtons.
//        var arrayButton = [UIButton]()
//        arrayButton = addBarButtons(btnLeft: BarButton(title: "Cancel"), btnRight: BarButton(title: "Next"), title: "PHOTO", isSwipeBack: false)
//        btnNext = arrayButton[1]
//
//        switch containerViewType {
//        case .camera: btnNext.isEnabled = false; break
//        case .gallery: btnNext.isEnabled = true; break
//        }
//
        //Google Analytics
        
        let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: self.title)
        
        //Google Analytics
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}

extension CreatePostVC : ChooseRectDelegate {
    
    func getSelectedReckDetail(data: Dictionary<String, Any>) {
        
        switch containerViewType {
        case .camera:
            debugPrint("Camera Image")
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "CameraImagePreviewVC") as! CameraImagePreviewVC
            vc.imgPost = data[kImage] as! UIImage!
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .gallery:
            debugPrint("Gallery Image")
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "UploadVC") as! UploadVC
            vc.imgPost = data[kImage] as! UIImage!
            self.navigationController?.pushViewController(vc, animated: true)
            break
        }
        
    }
}
