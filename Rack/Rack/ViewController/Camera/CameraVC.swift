//
//  CameraVC.swift
//  Rack
//
//  Created by hyperlink on 05/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion
import Photos

public var psCropSquareImage: Bool = true
public var psSavesImage: Bool = false

class CameraVC: UIViewController {

    //MARK:- Outlet
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var btnFlash: UIButton!
    @IBOutlet weak var btnRotate: UIButton!
    @IBOutlet weak var btnCapture: UIButton!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var delegate : ChooseRectDelegate?
    
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var videoInput: AVCaptureDeviceInput?
    var imageOutput: AVCaptureStillImageOutput?
    var focusView: UIView?
    
    var flashOffImage: UIImage?
    var flashOnImage: UIImage?
    

    
    var motionManager: CMMotionManager?
    var currentDeviceOrientation: UIDeviceOrientation?
    
    var mode : PickerMode = .defaultPickerMode
    
    //------------------------------------------------------
    
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
    
        NotificationCenter.default.removeObserver(self)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        
        self.title = "PHOTO"
        self.checkCameraAuth()
        self.initialize()
        
         self.navigationController?.customize()
    }
    
    func initialize() {
        
        if session != nil {
            
            return
        }

   /*
        let bundle = Bundle(for: self.classForCoder)
        
        flashOnImage = fusumaFlashOnImage != nil ? fusumaFlashOnImage : UIImage(named: "ic_flash_on", in: bundle, compatibleWith: nil)
        flashOffImage = fusumaFlashOffImage != nil ? fusumaFlashOffImage : UIImage(named: "ic_flash_off", in: bundle, compatibleWith: nil)
        let flipImage = fusumaFlipImage != nil ? fusumaFlipImage : UIImage(named: "ic_loop", in: bundle, compatibleWith: nil)
        let shotImage = fusumaShotImage != nil ? fusumaShotImage : UIImage(named: "ic_radio_button_checked", in: bundle, compatibleWith: nil)
        
        if(fusumaTintIcons) {
            flashButton.tintColor = fusumaBaseTintColor
            flipButton.tintColor  = fusumaBaseTintColor
            shotButton.tintColor  = fusumaBaseTintColor
            
            flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            flipButton.setImage(flipImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            shotButton.setImage(shotImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        } else {
            flashButton.setImage(flashOffImage, for: UIControlState())
            flipButton.setImage(flipImage, for: UIControlState())
            shotButton.setImage(shotImage, for: UIControlState())
        }
        
        
        self.isHidden = false
 */
        // AVCapture
        session = AVCaptureSession()
        
        for device in AVCaptureDevice.devices() {
            
            if let device = device as? AVCaptureDevice , device.position == AVCaptureDevicePosition.back {
                
                self.device = device
                
                if !device.hasFlash {
                    
                    btnFlash.isHidden = true
                }
            }
        }
        
        do {
            
            if let session = session {
                
                videoInput = try AVCaptureDeviceInput(device: device)
                
                session.addInput(videoInput)
                
                imageOutput = AVCaptureStillImageOutput()
                
                session.addOutput(imageOutput)
                
                let videoLayer = AVCaptureVideoPreviewLayer(session: session)
                videoLayer?.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenWidth)
                videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                self.topView.layer.insertSublayer(videoLayer!, at: 0)
                
                session.sessionPreset = AVCaptureSessionPresetPhoto
                
                session.startRunning()
                
            }
            
            // Focus View
            self.focusView         = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            let tapRecognizer      = UITapGestureRecognizer(target: self, action:#selector(focus(_:)))
            tapRecognizer.numberOfTapsRequired = 1
            self.topView.isUserInteractionEnabled = true
            self.topView.addGestureRecognizer(tapRecognizer)
            
        } catch {
         print("Catch...")
        }
        flashConfiguration()
        
        self.startCamera()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CameraVC.willEnterForegroundNotification(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func willEnterForegroundNotification(_ notification: Notification) {
        
        startCamera()
    }

    func startCamera() {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if status == AVAuthorizationStatus.authorized {
            
            session?.startRunning()
            
            motionManager = CMMotionManager()
            motionManager!.accelerometerUpdateInterval = 0.2
            motionManager!.startAccelerometerUpdates(to: OperationQueue()) { [unowned self] (data, _) in
                if let data = data {
                    if abs( data.acceleration.y ) < abs( data.acceleration.x ) {
                        if data.acceleration.x > 0 {
                            self.currentDeviceOrientation = .landscapeRight
                        } else {
                            self.currentDeviceOrientation = .landscapeLeft
                        }
                    } else {
                        if data.acceleration.y > 0 {
                            self.currentDeviceOrientation = .portraitUpsideDown
                        } else {
                            self.currentDeviceOrientation = .portrait
                        }
                    }
                }
            }
            
        } else if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {
            
            print("denied + restricted")
            stopCamera()
        }
    }
    
    func stopCamera() {
        session?.stopRunning()
        motionManager?.stopAccelerometerUpdates()
        currentDeviceOrientation = nil
    }
    
    func saveImageToCameraRoll(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
            
        }, completionHandler: nil)
    }
    
    func capture() {
        self.btnCapture.isUserInteractionEnabled = false
        guard let imageOutput = imageOutput else {
            
            print("imageOutput not found")
            return
        }
        
        DispatchQueue.global(qos: .default).async(execute: { () -> Void in
            
            let videoConnection = imageOutput.connection(withMediaType: AVMediaTypeVideo)
            
            let orientation: UIDeviceOrientation = self.currentDeviceOrientation ?? UIDevice.current.orientation
            switch (orientation) {
            case .portrait:
                videoConnection?.videoOrientation = .portrait
            case .portraitUpsideDown:
                videoConnection?.videoOrientation = .portraitUpsideDown
            case .landscapeRight:
                videoConnection?.videoOrientation = .landscapeLeft
            case .landscapeLeft:
                videoConnection?.videoOrientation = .landscapeRight
            default:
                videoConnection?.videoOrientation = .portrait
            }
            
            imageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (buffer, error) -> Void in
                
                self.stopCamera()
                
                if error == nil && buffer != nil {
                
                    let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                    
                    if let image = UIImage(data: data!), let delegate = self.delegate {
                        
                        // Image size
                        var iw: CGFloat
                        var ih: CGFloat
                        
                        switch (orientation) {
                        case .landscapeLeft, .landscapeRight:
                            // Swap width and height if orientation is landscape
                            iw = image.size.height
                            ih = image.size.width
                        default:
                            iw = image.size.width
                            ih = image.size.height
                        }
                        
                        // Frame size
                        let sw = self.topView.frame.width
                        
                        // The center coordinate along Y axis
                        let rcy = ih * 0.5
                        
                        let imageRef = image.cgImage?.cropping(to: CGRect(x: rcy-iw*0.5, y: 0 , width: iw, height: iw))
                        
//                        DispatchQueue.main.async(execute: { () -> Void in
                            if psCropSquareImage {
                                let resizedImage = UIImage(cgImage: imageRef!, scale: sw/iw, orientation: image.imageOrientation)
                                
                                //call Delegate Method
                                delegate.getSelectedReckDetail(data: [kImage : resizedImage])
                                
                                //Save Image into Gallery
                                if psSavesImage {
                                    self.saveImageToCameraRoll(image: resizedImage)
                                }
                                
                            } else {
                                //call Delegate Method
                                delegate.getSelectedReckDetail(data: [kImage : image])
                                
                                //Save Image into Gallery
                                if psSavesImage {
                                    self.saveImageToCameraRoll(image: image)
                                }
                            }
                            
                            switch self.mode {
                            case .defaultPickerMode , .profilePickerMode:
                                self.session       = nil
                                self.device        = nil
                                self.imageOutput   = nil
                                self.motionManager = nil
                                _ = self.navigationController?.popViewController(animated: true)
                                
                                break
                            case .imagePostPickerMode:
                                
                                self.startCamera()
                                
                                break
                            }
                        
//                        })
                    }
                }
                
                self.btnCapture.isUserInteractionEnabled = true
            })
            
        })

    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    func leftButtonClicked() {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnFlashClicked(_ sender : UIButton) {

        if !cameraIsAvailable() {
            
            return
        }
        
        do {
            
            if let device = device {
                
                guard device.hasFlash else { return }
                
                try device.lockForConfiguration()
                
                let mode = device.flashMode
                
                if mode == AVCaptureFlashMode.off {
                    
                    device.flashMode = AVCaptureFlashMode.on
//                    flashButton.setImage(flashOnImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
                    
                } else if mode == AVCaptureFlashMode.on {
                    
                    device.flashMode = AVCaptureFlashMode.off
//                    flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
                }
                
                device.unlockForConfiguration()
                
            }
            
        } catch _ {
            
//            flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            return
        }

        
    }
    @IBAction func btnRotateClicked(_ sender : UIButton) {

        if !cameraIsAvailable() {
            
            return
        }
        
        session?.stopRunning()
        
        do {
            
            session?.beginConfiguration()
            
            if let session = session {
                
                for input in session.inputs {
                    
                    session.removeInput(input as! AVCaptureInput)
                }
                
                let position = (videoInput?.device.position == AVCaptureDevicePosition.front) ? AVCaptureDevicePosition.back : AVCaptureDevicePosition.front
                
                for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {
                    
                    if let device = device as? AVCaptureDevice , device.position == position {
                        
                        videoInput = try AVCaptureDeviceInput(device: device)
                        session.addInput(videoInput)
                        
                    }
                }
                
            }
            
            session?.commitConfiguration()
            
            
        } catch {
            
        }
        
        session?.startRunning()
        
    }
    @IBAction func btnCaptureClicked(_ sender : UIButton) {
        self.capture()
    }

    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        _ = addBarButtons(btnLeft: BarButton(title: "Cancel"), btnRight: nil, title: "PHOTO")
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        
    }

}
extension CameraVC {
    
    @objc func focus(_ recognizer: UITapGestureRecognizer) {
        
        let point = recognizer.location(in: self.view)
        let viewsize = self.topView.frame.size
        let newPoint = CGPoint(x: point.y/viewsize.height, y: 1.0-point.x/viewsize.width)
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            
            try device?.lockForConfiguration()
            
        } catch _ {
            
            return
        }
        
        if device?.isFocusModeSupported(AVCaptureFocusMode.autoFocus) == true {
            
            device?.focusMode = AVCaptureFocusMode.autoFocus
            device?.focusPointOfInterest = newPoint
        }
        
        if device?.isExposureModeSupported(AVCaptureExposureMode.continuousAutoExposure) == true {
            
            device?.exposureMode = AVCaptureExposureMode.continuousAutoExposure
            device?.exposurePointOfInterest = newPoint
        }
        
        device?.unlockForConfiguration()
        
        self.focusView?.alpha = 0.0
        self.focusView?.center = point
        self.focusView?.backgroundColor = UIColor.clear
        self.focusView?.layer.borderColor = UIColor.red.cgColor
        self.focusView?.layer.borderWidth = 1.0
        self.focusView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.topView.addSubview(self.focusView!)
        
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 3.0, options: UIViewAnimationOptions.curveEaseIn, // UIViewAnimationOptions.BeginFromCurrentState
            animations: {
                self.focusView!.alpha = 1.0
                self.focusView!.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: {(finished) in
            self.focusView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.focusView!.removeFromSuperview()
        })
    }
    
    func flashConfiguration() {
        
        do {
            
            if let device = device {
                
                guard device.hasFlash else { return }
                
                try device.lockForConfiguration()
                
                device.flashMode = AVCaptureFlashMode.off
//                flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
                
                device.unlockForConfiguration()
                
            }
            
        } catch _ {
            
            return
        }
    }
    
    func cameraIsAvailable() -> Bool {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if status == AVAuthorizationStatus.authorized {
            
            return true
        }
        print("cameraIsNotAvailable")
        return false
    }
    
    func checkCameraAuth() {
        

        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (videoGranted: Bool) -> Void in
            if (videoGranted) {
                //Do Your stuff here
                
            } else {

                DispatchQueue.main.async(execute: { () -> Void in
                    
                    AlertManager.shared.showAlertTitle(title: kSettingChangeTitle, message: kCameraPermissionMessage, buttonsArray: ["Close","Go To Settings"], completionBlock: { (index : Int) in
                        
                        switch index{
                        case 0:
                            break
                        case 1:
                            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                            break
                        default:
                            print("-:Something Wrong in cameraRoll VC:-")
                            break
                        }
                        
                    })
                    
                })
                
            }
        })
    }

}
    
