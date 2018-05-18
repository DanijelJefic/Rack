//
//  FSCameraView.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion
import Photos

@objc protocol FSCameraViewDelegate: class {
    func cameraShotFinished(_ image: UIImage)
}

final class FSCameraView: UIView, UIGestureRecognizerDelegate {

    @IBOutlet weak var previewViewContainer: UIView!
    @IBOutlet weak var shotButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var fullAspectRatioConstraint: NSLayoutConstraint!
    var croppedAspectRatioConstraint: NSLayoutConstraint?
    var initialCaptureDevicePosition: AVCaptureDevice.Position = .back
    
    weak var delegate: FSCameraViewDelegate? = nil
    
    fileprivate var session: AVCaptureSession?
    fileprivate var device: AVCaptureDevice?
    fileprivate var videoInput: AVCaptureDeviceInput?
    fileprivate var imageOutput: AVCaptureStillImageOutput?
    fileprivate var videoLayer: AVCaptureVideoPreviewLayer?

    @IBOutlet weak var buttonOverlay: UIView!
    fileprivate var focusView: UIView?

    fileprivate var flashOffImage: UIImage?
    fileprivate var flashOnImage: UIImage?
    
    fileprivate var motionManager: CMMotionManager?
    fileprivate var currentDeviceOrientation: UIDeviceOrientation?
    
    static func instance() -> FSCameraView {
        
        return UINib(nibName: "FSCameraView", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! FSCameraView
    }
    
    func initialize() {
        
        
        shotButton.isMultipleTouchEnabled = false
        shotButton.isExclusiveTouch = true
        
        flashButton.isMultipleTouchEnabled = false
        flashButton.isExclusiveTouch = true
        
        flipButton.isMultipleTouchEnabled = false
        flipButton.isExclusiveTouch = true
        
        if session != nil { return }
        
        self.backgroundColor = UIColor.white
        
        let bundle = Bundle(for: self.classForCoder)
        
        self.previewViewContainer.frame = CGRect(x:0,y:0,width:self.frame.size.width,height:self.frame.size.width)
        
        self.buttonOverlay.frame = CGRect(x:0,
                                           y: self.previewViewContainer.frame.size.height+50,
                                           width:self.frame.size.width,
                                           height:self.frame.size.height - self.previewViewContainer.frame.size.height - 50.0)
        
        
        
        flashOnImage = fusumaFlashOnImage != nil ? fusumaFlashOnImage : UIImage(named: "bolt1-1", in: bundle, compatibleWith: nil)
        flashOffImage = fusumaFlashOffImage != nil ? fusumaFlashOffImage : UIImage(named: "bolt-1", in: bundle, compatibleWith: nil)
  
        let flipImage = fusumaFlipImage != nil ? fusumaFlipImage : UIImage(named: "reverseCamera-1", in: bundle, compatibleWith: nil)
        let shotImage = fusumaShotImage != nil ? fusumaShotImage : UIImage(named: "ellipse1", in: bundle, compatibleWith: nil)
        
        flashButton.imageView?.contentMode = .scaleAspectFit
        flashButton.tintColor = UIColor(red:130.0/255.0,green:130.0/255.0,blue:130.0/255.0,alpha:1.0)
       
         flipButton.imageView?.contentMode = .scaleAspectFit
        flipButton.tintColor  =  UIColor(red:130.0/255.0,green:130.0/255.0,blue:130.0/255.0,alpha:1.0)
        
        
         shotButton.imageView?.contentMode = .scaleAspectFit
         shotButton.tintColor  = UIColor.white
      
        shotButton.layer.borderColor = UIColor(red:130.0/255.0,green:130.0/255.0,blue:130.0/255.0,alpha:1.0).cgColor
        shotButton.layer.borderWidth = 10.0
        
        flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: .normal)
       
        
        
        flipButton.setImage(flipImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        shotButton.setImage(shotImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        
        
       shotButton.frame = CGRect(x:self.buttonOverlay.frame.size.width/2.0-87.0/2.0, y:self.buttonOverlay.frame.size.height-87-40,width: 87,height:87)
          shotButton.layer.cornerRadius = shotButton.frame.size.width/2.0
        shotButton.clipsToBounds = true
      
        var xOffset:CGFloat = ((self.frame.size.width-shotButton.frame.origin.x)-60.0)/2.0
        
        flashButton.frame =  CGRect(x:xOffset-40.0, y:self.buttonOverlay.frame.size.height-87-40,width: 60,height:87)
       
        xOffset = ((self.frame.size.width-(shotButton.frame.size.width+shotButton.frame.origin.x))-60.0)/2.0
        flipButton.frame = CGRect(x:shotButton.frame.size.width+shotButton.frame.origin.x+xOffset, y:self.buttonOverlay.frame.size.height-87-40,width: 60,height:87)
        
        self.isHidden = false
        
        // AVCapture
        session = AVCaptureSession()
        
        guard let session = session else { return }
        
        for device in AVCaptureDevice.devices() {
            
            if (device as AnyObject).position == initialCaptureDevicePosition {
                
                self.device = device as! AVCaptureDevice
                
                if !(device as AnyObject).hasFlash {
                    
                    flashButton.isHidden = true
                }
            }
        }
        
  
        if let _device = device, let _videoInput = try? AVCaptureDeviceInput(device: _device) {
            videoInput = _videoInput
            session.addInput(videoInput!)
          
            imageOutput = AVCaptureStillImageOutput()
          
            session.addOutput(imageOutput!)
          
            videoLayer = AVCaptureVideoPreviewLayer(session: session)
            videoLayer?.frame = self.previewViewContainer.bounds
            videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
          
            self.previewViewContainer.layer.addSublayer(videoLayer!)
            session.sessionPreset = AVCaptureSessionPresetPhoto
          
            session.startRunning()
          
            // Focus View
            self.focusView         = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            let tapRecognizer      = UITapGestureRecognizer(target: self, action:#selector(FSCameraView.focus(_:)))
            tapRecognizer.delegate = self
            self.previewViewContainer.addGestureRecognizer(tapRecognizer)
        }
        
        flashConfiguration()
        
        self.startCamera()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FSCameraView.willEnterForegroundNotification(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc func willEnterForegroundNotification(_ notification: Notification) {
        startCamera()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startCamera() {
        
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            
            session?.startRunning()
            
            motionManager = CMMotionManager()
            motionManager!.accelerometerUpdateInterval = 0.2
            motionManager!.startAccelerometerUpdates(to: OperationQueue()) { [unowned self] (data, _) in
                
                if let data = data {
                    
                    if abs(data.acceleration.y) < abs(data.acceleration.x) {
                        
                        self.currentDeviceOrientation = data.acceleration.x > 0 ? .landscapeRight : .landscapeLeft

                    } else {
                        
                        self.currentDeviceOrientation = data.acceleration.y > 0 ? .portraitUpsideDown : .portrait
                    }
                }
            }
            
        case .denied, .restricted:
            stopCamera()
        default:
            
            break
        }
    }
    
    func stopCamera() {
        session?.stopRunning()
        motionManager?.stopAccelerometerUpdates()
        currentDeviceOrientation = nil
    }

    @IBAction func shotButtonPressed(_ sender: UIButton) {
        
        guard let imageOutput = imageOutput else {
            return
        }
        
        guard cameraIsAvailable else {
            return
        }
        
        appDelegate().window?.isUserInteractionEnabled = false
        DispatchQueue.global(qos: .default).async(execute: { () -> Void in
            let videoConnection = imageOutput.connection(withMediaType: AVMediaTypeVideo)
            imageOutput.captureStillImageAsynchronously(from: videoConnection!) { (buffer, error) -> Void in
                self.stopCamera()
                guard let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!),
                    let image = UIImage(data: data),
                    let cgImage = image.cgImage,
                    let delegate = self.delegate,
                    let videoLayer = self.videoLayer else {
                        return
                    }
                
                let rect   = videoLayer.metadataOutputRectOfInterest(for: videoLayer.bounds)
                let width  = CGFloat(cgImage.width)
                let height = CGFloat(cgImage.height)
                
                let cropRect = CGRect(x: rect.origin.x * width,
                                      y: rect.origin.y * height,
                                      width: rect.size.width * width,
                                      height: rect.size.height * height)
                
                guard let img = cgImage.cropping(to: cropRect) else {
                    
                    return
                }
                
                let croppedUIImage = UIImage(cgImage: img, scale: 1.0, orientation: image.imageOrientation)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        appDelegate().window?.isUserInteractionEnabled = true
                    }
                    delegate.cameraShotFinished(croppedUIImage)
                    if fusumaSavesImage {
                        self.saveImageToCameraRoll(image: croppedUIImage)
                    }
                    self.session       = nil
                    self.videoLayer    = nil
                    self.device        = nil
                    self.imageOutput   = nil
                    self.motionManager = nil
                })
            }
        })
    }
    
    @IBAction func flipButtonPressed(_ sender: UIButton) {

        if !cameraIsAvailable { return }
        session?.stopRunning()
        do {
            appDelegate().window?.isUserInteractionEnabled = false
            session?.beginConfiguration()
            if let session = session {
                for input in session.inputs {
                    session.removeInput(input as! AVCaptureInput )
                }
                let position = (videoInput?.device.position == AVCaptureDevice.Position.front) ? AVCaptureDevice.Position.back : AVCaptureDevice.Position.front
                for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {
                    if (device as AnyObject).position == position {
                        videoInput = try AVCaptureDeviceInput(device: device as! AVCaptureDevice)
                        session.addInput(videoInput!)
                    }
                }
            }
            session?.commitConfiguration()
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                appDelegate().window?.isUserInteractionEnabled = true
            })
        } catch {
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                appDelegate().window?.isUserInteractionEnabled = true
            })
        }
        
        session?.startRunning()
    }
    
    @IBAction func flashButtonPressed(_ sender: UIButton) {

        if !cameraIsAvailable { return }

        do {
            
            appDelegate().window?.isUserInteractionEnabled = false

            guard let device = device, device.hasFlash else { return }
            
            try device.lockForConfiguration()
            
            switch device.flashMode {
            case .off:
                device.flashMode = AVCaptureDevice.FlashMode.on
                flashButton.setImage(flashOnImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            case .on:
                device.flashMode = AVCaptureDevice.FlashMode.off
                flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            default:
                break
            }
            
            device.unlockForConfiguration()
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                appDelegate().window?.isUserInteractionEnabled = true
            })

        } catch _ {
            flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                appDelegate().window?.isUserInteractionEnabled = true
            })
            return
        }
 
    }
}

fileprivate extension FSCameraView {
    
    func saveImageToCameraRoll(image: UIImage) {
        
        PHPhotoLibrary.shared().performChanges({
            
            PHAssetChangeRequest.creationRequestForAsset(from: image)
            
        }, completionHandler: nil)
    }
    
    @objc func focus(_ recognizer: UITapGestureRecognizer) {
        
        let point = recognizer.location(in: self)
        let viewsize = self.bounds.size
        let newPoint = CGPoint(x: point.y/viewsize.height, y: 1.0-point.x/viewsize.width)
        
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            
            return
        }
        
        do {
            
            try device.lockForConfiguration()
            
        } catch _ {
            
            return
        }
        
        if device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) == true {

            device.focusMode = AVCaptureDevice.FocusMode.autoFocus
            device.focusPointOfInterest = newPoint
        }

        if device.isExposureModeSupported(AVCaptureDevice.ExposureMode.continuousAutoExposure) == true {
            
            device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            device.exposurePointOfInterest = newPoint
        }
        
        device.unlockForConfiguration()
        
        guard let focusView = self.focusView else { return }
        
        focusView.alpha = 0.0
        focusView.center = point
        focusView.backgroundColor = UIColor.clear
        focusView.layer.borderColor = fusumaBaseTintColor.cgColor
        focusView.layer.borderWidth = 1.0
        focusView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        addSubview(focusView)
        
        UIView.animate(withDuration: 0.8,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 3.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
            
                focusView.alpha = 1.0
                focusView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        }, completion: {(finished) in
        
            focusView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            focusView.removeFromSuperview()
        })
    }
    
    func flashConfiguration() {
    
        do {
            
            if let device = device {
                
                guard device.hasFlash else { return }
                
                try device.lockForConfiguration()
                
                device.flashMode = AVCaptureDevice.FlashMode.off
                flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
                
                device.unlockForConfiguration()
                
            }
            
        } catch _ {
            
            return
        }
    }

    var cameraIsAvailable: Bool {

        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if status == AVAuthorizationStatus.authorized {
            return true
        }

        return false
    }
}
