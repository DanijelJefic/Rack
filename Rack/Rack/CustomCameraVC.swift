//
//  CustomCameraVC.swift
//  Rack
//
//  Created by GP on 24/12/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

import UIKit
import Photos

class CustomCameraVC: UIViewController {
    
     fileprivate var captureButton: UIButton!
    
    ///Displays a preview of the video output generated by the device's cameras.
     fileprivate var capturePreviewView: UIView!
    
    ///Allows the user to put the camera in photo mode.
    fileprivate var photoModeButton: UIButton!
    fileprivate var toggleCameraButton: UIButton!
     fileprivate var toggleFlashButton: UIButton!
    
    ///Allows the user to put the camera in video mode.
     fileprivate var videoModeButton: UIButton!
    
    let cameraController = CameraController()
    
    override var prefersStatusBarHidden: Bool { return true }
    
    typealias CallBack = (UIImage)->Void
    var callBack:CallBack?
    let label = UILabel()
    let flashButton = UIButton()
    
    let imageView = UIImageView()
}

extension CustomCameraVC {
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.black
    
     
        
       
        
       
        let cancelButton = UIButton()
        cancelButton.contentHorizontalAlignment = .left
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.titleLabel?.font = UIFont.applyRegular(fontSize: 12.0)
        cancelButton.frame = CGRect(x:20, y:21,width: 90,height:50.0)
        cancelButton.layer.shadowColor = UIColor.black.cgColor
        cancelButton.layer.shadowRadius = 0.2
        cancelButton.layer.shadowOpacity = 0.1
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        self.view.addSubview(cancelButton)
        
        
        let takePhotoButton = UIButton()
        takePhotoButton.backgroundColor = UIColor.white
        takePhotoButton.contentHorizontalAlignment = .center
        takePhotoButton.setImage(UIImage(named:"ellipse1"), for: .normal)
        takePhotoButton.imageView?.contentMode = .scaleAspectFill
        takePhotoButton.setTitleColor(UIColor.white, for: .normal)
        takePhotoButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        takePhotoButton.setTitle("", for: UIControlState.normal)
        takePhotoButton.titleLabel?.font = UIFont.applyRegular(fontSize: 13.0)
        takePhotoButton.frame = CGRect(x:self.view.frame.size.width/2.0-87.0/2.0, y:self.view.frame.size.height-87-40,width: 87,height:87)
        takePhotoButton.layer.borderColor = UIColor.black.withAlphaComponent(0.47).cgColor
        takePhotoButton.layer.borderWidth = 12.0
        takePhotoButton.layer.cornerRadius  = takePhotoButton.frame.size.height/2.0
        takePhotoButton.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        self.view.addSubview(takePhotoButton)
        
        var xOffset = ((self.view.frame.size.width-(takePhotoButton.frame.size.width+takePhotoButton.frame.origin.x))-60.0)/2.0
        let camera1Button = UIButton()
        camera1Button.setImage(UIImage(named:"reverseCamera"), for: .normal)
        camera1Button.imageView?.contentMode = .scaleAspectFit
        camera1Button.addTarget(self, action: #selector(switchCameras(_ :)), for: .touchUpInside)
        camera1Button.frame = CGRect(x:takePhotoButton.frame.size.width+takePhotoButton.frame.origin.x+xOffset, y:self.view.frame.size.height-87-40,width: 60,height:87)
        self.view.addSubview(camera1Button)
        
        
        xOffset = ((self.view.frame.size.width-takePhotoButton.frame.origin.x)-60.0)/2.0
       
        flashButton.setImage(UIImage(named:"bolt"), for: .normal)
        flashButton.setImage(UIImage(named:"bolt1"), for: .selected)
        flashButton.imageView?.contentMode = .scaleAspectFit
        flashButton.addTarget(self, action: #selector(toggleFlash(_ :)), for: .touchUpInside)
        flashButton.frame = CGRect(x:xOffset-40.0, y:self.view.frame.size.height-87-40,width: 60,height:87)
        self.view.addSubview(flashButton)
        
        label.frame = CGRect(x:flashButton.frame.size.width-20.0, y:flashButton.frame.size.height-35,width: 20,height:20)
        label.text = "ON"
        label.font = UIFont.systemFont(ofSize: 8.0)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 1.5
        label.alpha = 0.0
        label.layer.cornerRadius = label.frame.size.width/2.0
       // flashButton.addSubview(label)
        
        configureCameraController()
        
        imageView.frame = self.view.bounds
        imageView.backgroundColor = UIColor.black
        imageView.alpha = 0.0
        self.view.addSubview(imageView)
        imageView.isUserInteractionEnabled = true
        
        
        let nextButton = UIButton()
        nextButton.contentHorizontalAlignment = .right
        nextButton.setTitleColor(UIColor.white, for: .normal)
        nextButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        nextButton.setTitle("Next", for: UIControlState.normal)
        nextButton.titleLabel?.font = UIFont.applyRegular(fontSize: 12.0)
        nextButton.frame = CGRect(x:imageView.frame.size.width-90-20, y:21,width: 90,height:50.0)
        nextButton.layer.shadowColor = UIColor.black.cgColor
        nextButton.layer.shadowRadius = 0.2
        nextButton.layer.shadowOpacity = 0.1
        nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        imageView.addSubview(nextButton)
        
        
        let crossButton = UIButton()
        crossButton.contentHorizontalAlignment = .left
        crossButton.setTitleColor(UIColor.white, for: .normal)
        crossButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        crossButton.setTitle("X", for: UIControlState.normal)
        crossButton.titleLabel?.font = UIFont.applyRegular(fontSize: 17.0)
        crossButton.frame = CGRect(x:20, y:21,width: 90,height:50.0)
        crossButton.layer.shadowColor = UIColor.black.cgColor
        crossButton.layer.shadowRadius = 0.2
        crossButton.layer.shadowOpacity = 0.1
        crossButton.addTarget(self, action: #selector(hideImage), for: .touchUpInside)
        imageView.addSubview(crossButton)
    }
    
    
    func hideImage()  {
        self.imageView.image = nil
        self.imageView.alpha = 0.0
    }
    
    func nextButtonAction(){
        try? PHPhotoLibrary.shared().performChangesAndWait {
            PHAssetChangeRequest.creationRequestForAsset(from: self.imageView.image!)
        }
        
        if (self.callBack != nil){
            self.callBack!(imageView.image!)
        }
        self.cancelButtonAction()
    }
    
    
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                //print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.view)
        }
    }
}

extension CustomCameraVC {
    func cancelButtonAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
   
     func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            label.alpha = 0.0
            self.flashButton.isSelected = false
            cameraController.flashMode = .off
        }
        else {
            self.flashButton.isSelected = true
              label.alpha = 1.0
            cameraController.flashMode = .on
            
        }
    }
    
     func switchCameras(_ sender: UIButton) {
        do {
            try cameraController.switchCameras()
        }
            
        catch {
            //print(error)
        }
//
//        switch cameraController.currentCameraPosition {
//        case .some(.front):
//
//
//        case .some(.rear):
//
//
//        case .none:
//            return
//        }
    }
    
     func captureImage() {

        cameraController.captureImage {(image, error) in
            guard let image = image else {
                //print(error ?? "Image capture error")
                return
            }
            
            self.imageView.image = image
            self.view.bringSubview(toFront: self.imageView)
            self.imageView.alpha = 1.0
            
          
        }
    }
    
}

