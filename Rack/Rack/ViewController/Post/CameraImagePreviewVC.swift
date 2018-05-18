//
//  CameraImagePreviewVC.swift
//  Rack
//
//  Created by hyperlink on 26/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class CameraImagePreviewVC: UIViewController {

    //MARK:- Outlet
    
    @IBOutlet weak var imgPreView: UIImageView!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var imgPost : UIImage!


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
        
        if let _ = imgPost {
            imgPreView.image = imgPost
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    func leftButtonClicked() {

        AlertManager.shared.showAlertTitle(title: "", message: "Discard this image?", buttonsArray: ["Discard","CANCEL"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                //Discard clicked
                //print("Discard Clicked")
//                UserDefaults.standard.set(true, forKey: "discard")
                
                DispatchQueue.main.async {
                    _ = self.navigationController?.popViewController(animated: true)
                }
                
                break
            case 1:
                //Cancel clicked
                //print("Cancel Clicked")
                break
            default:
                break
            }
            
        }

    }
    
    func rightButtonClicked() {
        
        self.imgPost = self.imgPost.imageScale(scaledToWidth: kScreenWidth * 2)
        let uploadVC = secondStoryBoard.instantiateViewController(withIdentifier: "UploadVC") as! UploadVC
        uploadVC.imgPost = self.imgPost
        self.navigationController?.pushViewController(uploadVC, animated: true)
    }

    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppColor.primaryTheme
        self.imgPreView.backgroundColor = AppColor.primaryTheme
        self.navigationController?.navigationBar.isTranslucent = false
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title: "Discard"), btnRight: BarButton(title: "Next"), title: "PHOTO", isSwipeBack: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }


}
