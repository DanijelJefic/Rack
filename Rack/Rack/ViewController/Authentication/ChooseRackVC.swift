//
//  ChooseRackVC.swift
//  Rack
//
//  Created by hyperlink on 02/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import AFNetworking

class ChooseRackVC: UIViewController {



    //MARK:- Outlet

    @IBOutlet weak var btnCameraRoll: UIButton!
    @IBOutlet weak var btnRacks: UIButton!

    @IBOutlet weak var viewOptions: UIView!
    @IBOutlet weak var viewContainer: UIView!
    
    var fromPage = PageFrom.defaultScreen
    
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var bottomLine = CALayer()

    var arrayControllers : Array! = [UIViewController]()
    var pageviewController = UIPageViewController()
    
    var containerViewType = SelectRectType.cameraRoll
    
    var userData = UserModel()
    
    var imgWardRobes : UIImage? = nil
    var objWardrobe  : WardrobesModel = WardrobesModel()
    
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

        //Apply button style
        btnCameraRoll.applyStyle(
            titleLabelFont : UIFont.applyRegular(fontSize: 15.0)
            , titleLabelColor : UIColor(red: 130/255.0, green: 130/255.0, blue: 130/255.0, alpha: 1.0)
        )
        
        btnRacks.applyStyle(
            titleLabelFont: UIFont.applyRegular(fontSize: 15.0)
            , titleLabelColor : UIColor(red: 130/255.0, green: 130/255.0, blue: 130/255.0, alpha: 1.0)
        )
        
        btnRacks.isExclusiveTouch = true
        btnCameraRoll.isExclusiveTouch = true
        
        //Array of VCs..
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)

        let vc1 : CameraRollVC = storyBoard.instantiateViewController(withIdentifier: "CameraRollVC") as! CameraRollVC
        vc1.mode = .defaultPickerMode
        vc1.delegate = self

        let vc2 : SelectRackVC = storyBoard.instantiateViewController(withIdentifier: "SelectRackVC") as! SelectRackVC
        vc2.delegate = self
        
        arrayControllers = [vc1,vc2]

        //PageController SetUp
        pageviewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageviewController.setViewControllers([arrayControllers[0]], direction: .forward, animated: false, completion: nil)
       // pageviewController.view.frame = CGRect(x: 19.5, y: 50, width: viewContainer.frame.size.width-2*19.5, height: viewContainer.frame.size.height-50)
        addChildViewController(pageviewController)
        viewContainer.addSubview(pageviewController.view)
        pageviewController.didMove(toParentViewController: self)
        
        
        //Default CameraRoll Selection
        self.btnCameraRollClicked(btnCameraRoll)
        
         self.navigationController?.customize()
      
        
    }
    
    func setUpViewWithDelay() {
        
        bottomLine = viewOptions.addBottomBorderWithColor(color: UIColor.black.withAlphaComponent(0.25), origin:btnCameraRoll.frame.origin, width:kScreenWidth, height: 1.0)
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callWardrobeAPI(_ requestModel : RequestModel) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/create_wardrobes
         
         Parameter   : user_id,device_type[A,I],device_token
         
         Optional    : wardrobes_id,wardrobes_image
         
         Comment     : This api will used for create and update user wardrobes(Setup 3).
         
         
         ==============================
         
         */
        
        var imageData : Data? = nil
        if imgWardRobes != nil {
            guard let data = UIImageJPEGRepresentation(imgWardRobes!, 0.30) else {
                return
            }
            imageData = data
        } else {
            
        }
        
        APICall.shared.POST(strURL: kMethodCreateWardrobes
            , parameter: requestModel.toDictionary()
            , withLoader: true
            , constructingBodyWithBlock: { (formData : AFMultipartFormData?) in

                if let data = imageData {
                    formData!.appendPart(withFileData: data , name: "wardrobes_image", fileName: "wardrobes.jpeg", mimeType: "image/jpeg")
                }
                
        }) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    // Save UserProfile Banner image in locally
                    UserDefaults.standard.set(imageData, forKey: kUserProfileBanner)
                    
                    let vc : FollowFriendVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowFriendVC") as! FollowFriendVC
                    vc.userData = UserModel(fromJson: response[kData])
                    self.navigationController?.pushViewController(vc, animated: true)

                    break
                default :
                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    break
                }
                
            } else {
                AlertManager.shared.showPopUpAlert("", message: error?.localizedDescription, forTime: 2.0, completionBlock: { (Int) in
                })
            }
            
        }
        
    }

    
    func callEditProfileAPI(_ requestModel : RequestModel) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/edit
         
         Parameter   :
         
         Optional    : user_name,display_name,bio_txt,profile,wardrobes_id,wardrobes_image
         
         Comment     : This api will used for user update the user detail.
         
         
         ==============================
         
         */
        
        var imageData : Data? = nil
        if imgWardRobes != nil {
            guard let data = UIImageJPEGRepresentation(imgWardRobes!, 0.20) else {
                return
            }
            imageData = data
        } else {
            
        }

        APICall.shared.POST(strURL: kMethodUserEdit
            , parameter: requestModel.toDictionary()
            , withLoader: true
            , constructingBodyWithBlock: { (formData : AFMultipartFormData?) in
                
                if let data = imageData {
                    formData!.appendPart(withFileData: data , name: "wardrobes_image", fileName: "wardrobes.jpeg", mimeType: "image/jpeg")
                }
                
        }) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    // Save UserProfile Banner image in locally
                    UserDefaults.standard.set(imageData, forKey: kUserProfileBanner)
                    
                    let userData = UserModel(fromJson: response[kData])
                    //Save User Data into userDefaults.
                    userData.saveUserDetailInDefaults()
                    //load latest data in to current User
                    UserModel.currentUser.getUserDetailFromDefaults()
                    
                    AlertManager.shared.showPopUpAlert("", message: response[kMessage].stringValue, forTime: 2.0, completionBlock: { (Int) in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    
                    //post notification to profile vc to update data
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationProfileUpdate), object: userData)
                    
                    
                    break
                default :
                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    break
                }
                
            } else {
                AlertManager.shared.showPopUpAlert("", message: error?.localizedDescription, forTime: 2.0, completionBlock: { (Int) in
                })
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
        default:
            print("Default one called...")
        }
    }
    
    func rightButtonClicked(){

        //Call Delegate 
        switch containerViewType {
        case .cameraRoll:
            if let vc = arrayControllers[0] as? CameraRollVC, vc.scrollView.imageToDisplay != nil {
                vc.delegate?.getSelectedReckDetail(data: [kImage : vc.captureVisibleRect()])
            }
            break
        case .racks:
            if let vc = arrayControllers[1] as? SelectRackVC, !vc.arrayWardrobe.isEmpty {
                vc.delegate?.getSelectedReckDetail(data: vc.arrayWardrobe[vc.carousel.currentItemIndex].toDictionary())
            }
            break
        }

        switch fromPage {
        case .defaultScreen:

            let requestModel : RequestModel = RequestModel()
            requestModel.user_id = userData.userId
            requestModel.device_token = GFunction.shared.getDeviceToken()
            requestModel.wardrobes_id = objWardrobe.id
            requestModel.device_type = "I"
            
            self.callWardrobeAPI(requestModel)
            
            break
        case .fromSettingPage:

            let requestModel : RequestModel = RequestModel()
            requestModel.wardrobes_id = objWardrobe.id
            self.callEditProfileAPI(requestModel)

            break
        default:
            print("Default one called...")
        }

    }

    @IBAction func btnCameraRollClicked(_ sender: UIButton) {
        
        containerViewType = .cameraRoll
        
        bottomLine.frame.origin.x = btnCameraRoll.frame.origin.x
        btnCameraRoll.titleLabel?.font = UIFont.applyBold(fontSize: 12.0)
        btnRacks.titleLabel?.font = UIFont.applyRegular(fontSize: 12.0)
        
        pageviewController.setViewControllers([arrayControllers[0]], direction: .reverse, animated: true, completion: nil)
    }
    
    @IBAction func btnracksClicked(_ sender: UIButton) {

        containerViewType = .racks

        bottomLine.frame.origin.x = btnRacks.frame.origin.x
        btnRacks.titleLabel?.font = UIFont.applyBold(fontSize: 12.0)
        btnCameraRoll.titleLabel?.font = UIFont.applyRegular(fontSize: 12.0)
        pageviewController.setViewControllers([arrayControllers[1]], direction: .forward, animated: true, completion: nil)
        
    }
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = AppColor.primaryTheme
      
        setUpView()
        self.perform(#selector(setUpViewWithDelay), with: nil, afterDelay: 0.1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


        //Edit and Save Management
        switch fromPage {
        case .defaultScreen:
          _ = addBarButtons(btnLeft: nil, btnRight: BarButton(title: "Next", color: AppColor.btnTitle), title: "Choose Cover",isSwipeBack: false)
            break
        case .fromSettingPage:
            _ = addBarButtons(btnLeft: BarButton(title : "Cancel", color: AppColor.btnTitle),
                              btnRight: BarButton(title: "Save", color: AppColor.btnTitle),
                              title: "Choose Cover")
            break
        default:
            print("Default one called...")
        }
    

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)

    }

}
extension ChooseRackVC : ChooseRectDelegate {
 
    func getSelectedReckDetail(data: Dictionary<String, Any>) {

        switch containerViewType {
        case .cameraRoll:
            imgWardRobes = data[kImage] as? UIImage
            break
        case .racks:
            imgWardRobes = nil
            let json = JSON(data)
            objWardrobe = WardrobesModel(fromJson: json)
            break

        }

    }
}
