//
//  FusumaViewController.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import Photos
import AFNetworking
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

public protocol FusumaDelegate: class {
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode)
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode)
    func fusumaVideoCompleted(withFileURL fileURL: URL)
    func fusumaCameraRollUnauthorized()
    
    // optional
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode, metaData: ImageMetadata)
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode)
    func fusumaClosed()
    func fusumaWillClosed()
}

public extension FusumaDelegate {
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode, metaData: ImageMetadata) {}
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {}
    func fusumaClosed() {}
    func fusumaWillClosed() {}
}

public var fusumaBaseTintColor   = UIColor.hex("#c9c7c8", alpha: 1.0)
public var fusumaTintColor       = UIColor.hex("#424141", alpha: 1.0)
public var fusumaBackgroundColor = UIColor.hex("#FCFCFC", alpha: 1.0)

public var fusumaCheckImage: UIImage?
public var fusumaCloseImage: UIImage?
public var fusumaFlashOnImage: UIImage?
public var fusumaFlashOffImage: UIImage?
public var fusumaFlipImage: UIImage?
public var fusumaShotImage: UIImage?

public var fusumaVideoStartImage: UIImage?
public var fusumaVideoStopImage: UIImage?

public var fusumaCropImage: Bool  = true

public var fusumaSavesImage: Bool = false

public var fusumaCameraRollTitle = "Camera Roll"
public var fusumaCameraTitle     = "Photo"
public var fusumaVideoTitle      = "Video"
public var fusumaTitleFont       = UIFont(name: "AvenirNext-DemiBold", size: 15)

public var autoDismiss: Bool = true

@objc public enum FusumaMode: Int {
    
    case camera
    case library
    case video
    
    static var all: [FusumaMode] {
        
        return [.camera, .library, .video]
    }
}

public struct ImageMetadata {
    public let mediaType: PHAssetMediaType
    public let pixelWidth: Int
    public let pixelHeight: Int
    public let creationDate: Date?
    public let modificationDate: Date?
    public let location: CLLocation?
    public let duration: TimeInterval
    public let isFavourite: Bool
    public let isHidden: Bool
    public let asset: PHAsset
    
}

extension FusumaViewController:UIImagePickerControllerDelegate {
    func showCamera()  {
        let customCameraVC:CustomCameraVC = CustomCameraVC()
        customCameraVC.callBack = {(image) in
             self.albumView.setCoverImage(image:image)
        }
        self.present(customCameraVC, animated: true, completion: nil)
        return
            
        picker.view.backgroundColor = UIColor.white
        picker.sourceType = UIImagePickerControllerSourceType.camera
        picker.delegate = self
        picker.allowsEditing = false
        picker.isNavigationBarHidden = true
        picker.isToolbarHidden = true
        picker.showsCameraControls = false;
        let screenSize:CGSize = UIScreen.main.bounds.size
        let cameraAspectRatio:CGFloat = 4.0 / 3.0;
        let imageWidth:CGFloat = CGFloat(floorf(Float(screenSize.width * cameraAspectRatio)));
        let scale:CGFloat = CGFloat(ceilf(Float((screenSize.height / imageWidth) * 30.0)) / 30.0);
        picker.cameraViewTransform = CGAffineTransform(scaleX: scale, y: scale)
        let overlayView = UIView()
        overlayView.frame = picker.view.bounds
        overlayView.backgroundColor = UIColor.clear
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
        overlayView.addSubview(cancelButton)
        
        
        
        let takePhotoButton = UIButton()
        takePhotoButton.backgroundColor = UIColor.white
        takePhotoButton.contentHorizontalAlignment = .center
        takePhotoButton.setImage(UIImage(named:"ellipse1"), for: .normal)
        takePhotoButton.imageView?.contentMode = .scaleAspectFill
        takePhotoButton.setTitleColor(UIColor.white, for: .normal)
        takePhotoButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        takePhotoButton.setTitle("", for: UIControlState.normal)
        takePhotoButton.titleLabel?.font = UIFont.applyRegular(fontSize: 13.0)
        takePhotoButton.frame = CGRect(x:overlayView.frame.size.width/2.0-87.0/2.0, y:overlayView.frame.size.height-87-40,width: 87,height:87)
        takePhotoButton.layer.borderColor = UIColor.black.withAlphaComponent(0.47).cgColor
        takePhotoButton.layer.borderWidth = 12.0
        takePhotoButton.layer.cornerRadius  = takePhotoButton.frame.size.height/2.0
        takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        overlayView.addSubview(takePhotoButton)
        
        
        var xOffset = ((overlayView.frame.size.width-(takePhotoButton.frame.size.width+takePhotoButton.frame.origin.x))-60.0)/2.0
        let camera1Button = UIButton()
        camera1Button.setImage(UIImage(named:"reverseCamera"), for: .normal)
        camera1Button.imageView?.contentMode = .scaleAspectFit
        camera1Button.addTarget(self, action: #selector(toogleCamera), for: .touchUpInside)
        camera1Button.frame = CGRect(x:takePhotoButton.frame.size.width+takePhotoButton.frame.origin.x+xOffset, y:overlayView.frame.size.height-87-40,width: 60,height:87)
        overlayView.addSubview(camera1Button)
        
        
        xOffset = ((overlayView.frame.size.width-takePhotoButton.frame.origin.x)-60.0)/2.0
        let flashButton = UIButton()
        flashButton.setImage(UIImage(named:"bolt"), for: .normal)
        flashButton.imageView?.contentMode = .scaleAspectFit
        flashButton.addTarget(self, action: #selector(toogleFlash), for: .touchUpInside)
        flashButton.frame = CGRect(x:xOffset-30.0, y:overlayView.frame.size.height-87-40,width: 60,height:87)
        overlayView.addSubview(flashButton)
        picker.cameraOverlayView  = overlayView
        present(picker, animated: true, completion: nil)
   
    }
    
    
    func toogleCamera(){
        if self.picker.cameraDevice == .front {
            UIView.transition(with: self.picker.view, duration: 1.0, options: [.allowAnimatedContent, .transitionFlipFromLeft], animations: {
                self.picker.cameraDevice = .rear
            }, completion: nil)
        }else {
            UIView.transition(with: self.picker.view, duration: 1.0, options: [.allowAnimatedContent, .transitionFlipFromRight], animations: {
                self.picker.cameraDevice = .front
            }, completion: nil)
        }
    }
    
    func toogleFlash(){
         if self.picker.cameraFlashMode == UIImagePickerControllerCameraFlashMode.on {
            self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.off
         }else {
             self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.on
        }
    }
    func takePhoto(){
        picker.takePicture()
    }
    func cancelButtonAction()  {
        dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
      
        UIImageWriteToSavedPhotosAlbum((info[UIImagePickerControllerOriginalImage] as? UIImage)!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        dismiss(animated: true, completion: nil)
 
    }
    
    //MARK: - Add image to Library
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            albumView.setCoverImage(image:image)
   
            
        }
    }
}
@objc public class FusumaViewController: UIViewController {

    public var cameraPosition = AVCaptureDevice.Position.back
    @IBOutlet weak var libraryBottomOffset: NSLayoutConstraint!
    @IBOutlet weak var cameraBottomOffset: NSLayoutConstraint!
    @IBOutlet weak var librarayYOffset: NSLayoutConstraint!
    @IBOutlet weak var cameraYOffset: NSLayoutConstraint!
    @IBOutlet weak var buttonContainerYOffset: NSLayoutConstraint!
  
    var comingWhenTapOnImage:Bool = false
    var headerButton:UIButton = UIButton()
    var dropDownImage:UIImageView = UIImageView()
    var addPost:Bool = false
    var isNewuser:Bool = false
    var isFromEditScreen:Bool = false
    
    let picker = UIImagePickerController()
    var imgWardRobes : UIImage? = nil
    var objWardrobe  : WardrobesModel = WardrobesModel()
    var userData = UserModel()
    public var cropHeightRatio: CGFloat = 1
    public var allowMultipleSelection: Bool = false

    fileprivate var mode: FusumaMode = .library
    
    public var availableModes: [FusumaMode] = [.library, .camera]
    //public var cameraPosition = AVCaptureDevice.Position.back

    @IBOutlet weak var photoLibraryViewerContainer: UIView!
    @IBOutlet weak var cameraShotContainer: UIView!
    @IBOutlet weak var videoShotContainer: UIView!
    @IBOutlet  var buttonContainerView: UIView!
    
    @IBOutlet weak var buttonContainerViewHeight: NSLayoutConstraint!
    //@IBOutlet weak var titleLabel: UILabel!
   // @IBOutlet weak var menuView: UIView!
    //@IBOutlet weak var closeButton: UIButton!
    @IBOutlet  var libraryButton: UIButton!
    @IBOutlet  var cameraButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
   // @IBOutlet weak var doneButton: UIButton!
    
    lazy var albumView:FSAlbumView!  = nil
    lazy var cameraView = FSCameraView.instance()
    lazy var videoView  = FSVideoCameraView.instance()

    typealias CallBack = (UIImage) -> Void
    var callBack:CallBack!
    
    fileprivate var hasGalleryPermission: Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    public weak var delegate: FusumaDelegate? = nil
    
    override public func loadView() {
        
        if let view = UINib(nibName: "FusumaViewController", bundle: Bundle(for: self.classForCoder)).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if addPost {
            libraryBottomOffset.constant = 0.0
            cameraBottomOffset.constant = 0.0
            librarayYOffset.constant = 0.0
            cameraYOffset.constant = 0.0
            if self.buttonContainerYOffset != nil {
                self.buttonContainerYOffset.constant = self.view.frame.size.width
            }
        }else {
             self.buttonContainerYOffset.constant = 0
        }
    }
    
    //MARK:- Life Cycle Method
    private var popGesture: UIGestureRecognizer?
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(false, forKey: "discard")
        
        var type:AlbumPickerType = AlbumPickerType.Cover
        
        if self.buttonContainerYOffset != nil && addPost{
            self.buttonContainerYOffset.constant = self.view.frame.size.width
        }
        
        if self.addPost {
            type = AlbumPickerType.AddPost
        }
        if self.isNewuser && !self.addPost {
            type = AlbumPickerType.PhotoPicker
        }
        
        if addPost {
            if self.buttonContainerView != nil {
                self.buttonContainerView.removeFromSuperview()
                self.buttonContainerView = nil
            }
            
            self.buttonContainerView = UIView()
            self.buttonContainerView.frame = CGRect(x:0,y:self.view.frame.size.width,width:self.view.frame.size.width,height:50.0)
            self.view.addSubview(self.buttonContainerView)
        }
        
        self.albumView = FSAlbumView.instance(type: type)
        self.albumView.type = type
        
        buttonContainerView.backgroundColor = UIColor(red:250.0/255.0,green:250.0/255.0,blue:250.0/255.0,alpha:1.0)
        
        self.view.backgroundColor = fusumaBackgroundColor
        self.navigationController?.customize()
        
        cameraView.delegate = self
        albumView.delegate  = self
        videoView.delegate  = self
        
        if self.addPost
        {
            if self.libraryButton != nil {
                self.libraryButton.removeFromSuperview()
                self.libraryButton = nil
                
                self.libraryButton = UIButton()
                self.libraryButton.addTarget(self, action: #selector(self.libraryButtonPressed(_ :)), for: .touchUpInside)
                self.buttonContainerView.addSubview(self.libraryButton)
            }
            
            if self.cameraButton != nil {
                self.cameraButton.removeFromSuperview()
                self.cameraButton = nil
                
                self.cameraButton = UIButton()
                self.cameraButton.addTarget(self, action: #selector(self.photoButtonPressed(_ :)), for: .touchUpInside)
                self.buttonContainerView.addSubview(self.cameraButton)
            }
        }
        
        libraryButton.setTitle(fusumaCameraRollTitle, for: .normal)
        if addPost {
            libraryButton.setTitle("Gallery", for: .normal)
        }
        libraryButton.titleLabel?.font = UIFont.applyRegular(fontSize: 14.0)
        
        if self.addPost {
            cameraButton.setTitle("Camera", for: .normal)
            cameraButton.titleLabel?.font = UIFont.applyRegular(fontSize: 14.0)
        }else {
            cameraButton.setImage(UIImage(named:"cover_camera"), for: .normal)
            cameraButton.imageView?.contentMode = .scaleAspectFit
            
            cameraButton.setTitle("", for: .normal)
        }
        
        videoButton.setTitle(fusumaVideoTitle, for: .normal)
        albumView.allowMultipleSelection = allowMultipleSelection
        libraryButton.tintColor = fusumaTintColor
        cameraButton.tintColor  = fusumaTintColor
        videoButton.tintColor   = fusumaTintColor
        photoLibraryViewerContainer.addSubview(albumView)
        cameraShotContainer.addSubview(cameraView)
        videoShotContainer.addSubview(videoView)
        if availableModes.count == 0 || availableModes.count >= 4 {
            fatalError("the number of items in the variable of availableModes is incorrect.")
        }
        if NSOrderedSet(array: availableModes).count != availableModes.count {
            fatalError("the variable of availableModes should have unique elements.")
        }
        changeMode(availableModes[0], isForced: true)
        var sortedButtons = [UIButton]()
        for (i, mode) in availableModes.enumerated() {
            let button = getTabButton(mode: mode)
            if i == 0 {
                self.view.addConstraint(NSLayoutConstraint(
                    item:       button,
                    attribute:  .leading,
                    relatedBy:  .equal,
                    toItem:     self.view,
                    attribute:  .leading,
                    multiplier: 1.0,
                    constant:   0.0
                ))
                
            } else {
                self.view.addConstraint(NSLayoutConstraint(
                    item:       button,
                    attribute:  .leading,
                    relatedBy:  .equal,
                    toItem:     sortedButtons[i - 1],
                    attribute:  .trailing,
                    multiplier: 1.0,
                    constant:   0.0
                ))
            }
            
            if i == sortedButtons.count - 1 {
                
                self.view.addConstraint(NSLayoutConstraint(
                    item:       button,
                    attribute:  .trailing,
                    relatedBy:  .equal,
                    toItem:     button,
                    attribute:  .trailing,
                    multiplier: 1.0,
                    constant:   0.0
                ))
                
            }
            
            self.view.addConstraint(NSLayoutConstraint(
                item: button,
                attribute: .width,
                relatedBy: .equal, toItem: nil,
                attribute: .width,
                multiplier: 1.0,
                constant: UIScreen.main.bounds.width / CGFloat(availableModes.count)
            ))
            
            sortedButtons.append(button)
        }
        
        for m in FusumaMode.all {
            
            if !availableModes.contains(m) {
                
                getTabButton(mode: m).removeFromSuperview()
            }
        }
        
        if availableModes.count == 1 {
            
            libraryButton.removeFromSuperview()
            cameraButton.removeFromSuperview()
            videoButton.removeFromSuperview()
            return
            
        }
        
        if !availableModes.contains(.camera) {
            
            return
        }
        
        
        self.view.bringSubview(toFront: self.buttonContainerView)
        if fusumaCropImage {
            
            let heightRatio = getCropHeightRatio()
            
            cameraView.croppedAspectRatioConstraint = NSLayoutConstraint(
                item: cameraView.previewViewContainer,
                attribute: NSLayoutAttribute.height,
                relatedBy: NSLayoutRelation.equal,
                toItem: cameraView.previewViewContainer,
                attribute: NSLayoutAttribute.width,
                multiplier: heightRatio,
                constant: 0)
            cameraView.fullAspectRatioConstraint.isActive     = false
            cameraView.croppedAspectRatioConstraint?.isActive = true
            
        } else {
            
            cameraView.fullAspectRatioConstraint.isActive     = true
            cameraView.croppedAspectRatioConstraint?.isActive = false
        }
        
        
        
        if addPost {
            
            libraryBottomOffset.constant = 50.0
            cameraBottomOffset.constant = 50.0
            librarayYOffset.constant = 0.0
            cameraYOffset.constant = 0.0
            libraryButton.frame = CGRect (x:0,y:0,width:(appDelegate().window?.frame.size.width)!/2.0,height:buttonContainerView.frame.size.height)
            cameraButton.frame  = CGRect (x:appDelegate().window!.frame.size.width/2.0,y:0,width:(appDelegate().window?.frame.size.width)!/2.0,height:buttonContainerView.frame.size.height)
            self.buttonContainerView.layer.shadowColor = UIColor.black.cgColor
            self.buttonContainerView.layer.shadowRadius = 1.5
            self.buttonContainerView.layer.shadowOpacity = 0.2
            self.buttonContainerView.layer.shadowOffset = CGSize(width:0,height:1.0)
        }
        
        if comingWhenTapOnImage == true {
            
        }else{
            
        }
        
        
        
    }
    
    func ViewLoadSetup() {
        
        let discardAction = UserDefaults.standard.bool(forKey: "discard")
        if discardAction {
            if self.addPost {
                albumView.resetCamera()
                
                self.buttonContainerView.frame = CGRect(x:0,y:self.view.frame.size.width,width:self.view.frame.size.width,height:50.0)
                self.view.addSubview(self.buttonContainerView)
                
                self.dropDownImage.alpha = 0.0
                headerButton.setTitle("Photo", for: .normal)
                headerButton.isUserInteractionEnabled =  false
                
                cameraView.stopCamera()
                cameraView.initialize()
                cameraView.startCamera()
                
                _ = self.addBarButtons(btnLeft: BarButton(title : "Cancel", color: AppColor.btnTitle),
                                   btnRight: BarButton(title: nil, color: AppColor.btnTitle),
                                   title: "", isSwipeBack: false)
                
                return
            }
            self.showCamera()
        }

    }

    
    func handleTap()  {
    
        self.albumView.callBack = {(isVisisblePhotoAlbums,title) in
            if isVisisblePhotoAlbums {
                self.navigationItem.backBarButtonItem = nil
                self.navigationItem.rightBarButtonItem = nil
                self.navigationItem.leftBarButtonItem = nil
                
                self.addBarButtons(btnLeft: BarButton(title : nil, color: AppColor.btnTitle),
                                   btnRight: BarButton(title: nil, color: AppColor.btnTitle),
                                   title: "", isSwipeBack: false)
                self.dropDownImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            }else {
               self.addBarButtons(btnLeft: BarButton(title : "Cancel", color: AppColor.btnTitle),
                                  btnRight: BarButton(title: "Next", color: AppColor.btnTitle),
                                  title: "", isSwipeBack: false)
                   self.dropDownImage.transform = CGAffineTransform.identity
            }
            self.headerButton.setTitle(title, for: .normal)
        }
        self.albumView.showPhotoGallery()
      
        if (self.albumView.photoGalleryView != nil) {
            self.view.bringSubview(toFront: self.albumView.photoGalleryView)
        }
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isNewuser {
             if self.addPost {
                
                headerButton.setTitle("Camera Roll", for: .normal)
                headerButton.frame = CGRect(x:0,y:0,width:190.0,height:54.0)
                headerButton.titleLabel?.font = UIFont.applyRegular(fontSize: 15.5)
                headerButton.setTitleColor(UIColor.black, for: .normal)
                headerButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
                headerButton.setTitleColor(UIColor.lightGray, for: .highlighted)
                self.navigationItem.titleView = headerButton
                
                dropDownImage.image = UIImage(named:"down_arrow")
                dropDownImage.contentMode = .scaleAspectFit
                dropDownImage.frame = CGRect(x:headerButton.frame.size.width-30.0,y:-6,width:30.0,height:headerButton.frame.size.height)
                self.headerButton.addSubview(dropDownImage)
                
                _ = addBarButtons(btnLeft: BarButton(title : "Cancel", color: AppColor.btnTitle),
                                  btnRight: BarButton(title: "Next", color: AppColor.btnTitle),
                                  title: "", isSwipeBack: false)
             }else {
                _ = addBarButtons(btnLeft: BarButton(title : "Cancel", color: AppColor.btnTitle),
                              btnRight: BarButton(title: "Done", color: AppColor.btnTitle),
                              title: "Choose Photo")
            }
        }else {
            if self.isFromEditScreen {
            _ = addBarButtons(btnLeft: BarButton(title : "Cancel", color: AppColor.btnTitle),
                              btnRight: BarButton(title: "Save", color: AppColor.btnTitle),
                              title: "Choose Cover")
        }else{
             _ = addBarButtons(btnLeft: nil, btnRight: BarButton(title: "Next", color: AppColor.btnTitle), title: "Choose Cover",isSwipeBack: false)
        }
        }
        
        ViewLoadSetup()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.albumView.userData == nil {
            if availableModes.contains(.camera) {
    
                if albumView.type == .AddPost{
                    albumView.buttonContainerYOffset = self.buttonContainerYOffset
                    albumView.optionsContainerView = self.buttonContainerView
                }
                albumView.userData = self.userData
                albumView.isNewuser = self.isNewuser
                albumView.addPost = self.addPost
                albumView.superView = self.view
                //albumView.frame = CGRect(origin: CGPoint.zero, size: photoLibraryViewerContainer.frame.size)
                albumView.frame = CGRect(x:0,y:0,width:photoLibraryViewerContainer.frame.size.width,height:photoLibraryViewerContainer.frame.size.height)
                albumView.layoutIfNeeded()
                albumView.initialize()
                self.view.bringSubview(toFront: self.buttonContainerView)
               
            }
        }
      
        
        if availableModes.contains(.camera) {
//            cameraView.frame = CGRect(x:0,y:0,width:cameraShotContainer.frame.size.width,height:cameraShotContainer.frame.size.height)
//           // cameraView.frame = CGRect(origin: CGPoint.zero, size: cameraShotContainer.frame.size)
//            cameraView.layoutIfNeeded()
//            cameraView.initialize()
        }
        
        if availableModes.contains(.video) {

           // videoView.frame = CGRect(origin: CGPoint.zero, size: videoShotContainer.frame.size)
            //videoView.layoutIfNeeded()
            //videoView.initialize()
        }
        
        self.viewWillAppear(true)
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopAll()
    }

    override public var prefersStatusBarHidden : Bool {
        return false
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.delegate?.fusumaWillClosed()
        
        self.doDismiss {
            self.delegate?.fusumaClosed()
        }
    }
    
    @IBAction func libraryButtonPressed(_ sender: UIButton) {
        
        sender.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sender.isUserInteractionEnabled = true
        }
        
        self.dropDownImage.alpha = 1.0
        headerButton.setTitle(self.albumView.libraryString, for: .normal)
        headerButton.isUserInteractionEnabled =  true
        changeMode(FusumaMode.library)
        
        if self.addPost {
            UserDefaults.standard.set(false, forKey: "discard")
            _ = self.addBarButtons(btnLeft: BarButton(title : "Cancel", color: AppColor.btnTitle),
                               btnRight: BarButton(title: "Next", color: AppColor.btnTitle),
                               title: "", isSwipeBack: false)
            
            self.albumView.addButtonBar()
        }
        
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
    
        sender.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sender.isUserInteractionEnabled = true
        }
        
        if self.addPost {
            
            UserDefaults.standard.set(true, forKey: "discard")
            
            albumView.resetCamera()
          
            self.buttonContainerView.frame = CGRect(x:0,y:self.view.frame.size.width,width:self.view.frame.size.width,height:50.0)
            self.view.addSubview(self.buttonContainerView)
            
            self.dropDownImage.alpha = 0.0
            headerButton.setTitle("Photo", for: .normal)
            headerButton.isUserInteractionEnabled =  false
            changeMode(FusumaMode.camera)
          
            _ = self.addBarButtons(btnLeft: BarButton(title : "Cancel", color: AppColor.btnTitle),
                               btnRight: BarButton(title: nil, color: AppColor.btnTitle),
                               title: "", isSwipeBack: false)
            
            return
        }
        
        self.showCamera()
        
    }
    
    @IBAction func videoButtonPressed(_ sender: UIButton) {
        
        changeMode(FusumaMode.video)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        allowMultipleSelection ? fusumaDidFinishInMultipleMode() : fusumaDidFinishInSingleMode()
        
    }
    
    fileprivate func doDismiss(completion: (() -> Void)?) {
        
        if autoDismiss {
            
            self.dismiss(animated: true) {
                completion?()
            }
        
        } else {
           
            completion?()
        }
    }
    
    
    func leftButtonClicked() {
        if addPost {
            if self.albumView.isShowGallery {
                return
            }
        }
        
        if addPost {
              self.dismiss(animated: true, completion: nil)
            return
        }
       _ = self.navigationController?.popViewController(animated: true)
      
    }
    
    
    func rightButtonClicked(){
        
        if addPost {
            if self.albumView.isShowGallery {
                return
            }
            
            if self.mode == .library {
               
                self.imgWardRobes = self.albumView.captureVisibleRect()
                let data:Data = UIImageJPEGRepresentation(self.imgWardRobes!, 0.2)!
                let newImage:UIImage = UIImage(data: data)!
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "UploadVC") as! UploadVC
                vc.imgPost = newImage
                self.navigationController?.pushViewController(vc, animated: true)
                
               return

            }else{
                return
            }
        }
        
        let normalizedX = self.albumView.imageCropView.contentOffset.x / self.albumView.imageCropView.contentSize.width
        let normalizedY = self.albumView.imageCropView.contentOffset.y / self.albumView.imageCropView.contentSize.height
        
        let normalizedWidth  = self.albumView.imageCropView.frame.width / self.albumView.imageCropView.contentSize.width
        let normalizedHeight = self.albumView.imageCropView.frame.height / self.albumView.imageCropView.contentSize.height
        let cropRect = CGRect(x: normalizedX, y: normalizedY,
                              width: normalizedWidth, height: normalizedHeight)
        
        if self.albumView.phAsset != nil {
            
        requestImage(with: self.albumView.phAsset, cropRect: cropRect) { (asset, image) in
            self.imgWardRobes = image
            if self.imgWardRobes == nil {
                GFunction.shared.showPopUpAlert("Please choose image")
                return;
            }
            
             if self.isNewuser {
               
                let data:Data = UIImageJPEGRepresentation(self.imgWardRobes!, 0.2)!
                
                let image:UIImage = UIImage(data: data)!
                if self.callBack != nil{
                    self.callBack(image)
                }
                self.navigationController?.popViewController(animated: true)
             }
             else{
                if self.isFromEditScreen {
                    
                    let requestModel : RequestModel = RequestModel()
                    requestModel.wardrobes_id = self.objWardrobe.id
                    self.callEditProfileAPI(requestModel)
                    
                }else{
                    
                    let requestModel : RequestModel = RequestModel()
                    requestModel.user_id = self.userData.userId
                    requestModel.device_token = GFunction.shared.getDeviceToken()
                    requestModel.wardrobes_id = ""
                    requestModel.device_type = "I"
                    
                    self.callWardrobeAPI(requestModel)
                }
            }
           
        }
        }
        
       
    }
    
    
    //------------------------------------------------------
    //MARK: - API Call (TO SAVE COVER)
    func callEditProfileAPI(_ requestModel : RequestModel) {
        var imageData : Data? = nil
        if imgWardRobes != nil {
            guard let data = UIImageJPEGRepresentation(imgWardRobes!, 0.20) else {
                return
            }
            imageData = data
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
                    userData.coverImage = self.imgWardRobes
                    self.userData.coverImage  = self.imgWardRobes
                    userData.saveUserDetailInDefaults()
                    appDelegate().coverImage = self.imgWardRobes!
                    
                    UserModel.currentUser.getUserDetailFromDefaults()
                    
                    AlertManager.shared.showPopUpAlert("", message: "Rack cover updated successfully", forTime: 2.0, completionBlock: { (Int) in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
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
    //MARK: - API Call (TO SAVE COVER FOR FIRST TIME)
    func callWardrobeAPI(_ requestModel : RequestModel) {
        var imageData : Data? = nil
        if imgWardRobes != nil {
            guard let data = UIImageJPEGRepresentation(imgWardRobes!, 0.30) else {
                return
            }
            imageData = data
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
                    
                     let mainStoryBoard                  : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc : FollowFriendVC = mainStoryBoard.instantiateViewController(withIdentifier: "FollowFriendVC") as! FollowFriendVC
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
    
    private func fusumaDidFinishInSingleMode() {
        
    }
    
    private func requestImage(with asset: PHAsset, cropRect: CGRect, completion: @escaping (PHAsset, UIImage) -> Void) {
        
        DispatchQueue.global(qos: .default).async(execute: {
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.normalizedCropRect = cropRect
            options.resizeMode = .exact
            
            let targetWidth  = floor(CGFloat(asset.pixelWidth) * cropRect.width)
            let targetHeight = floor(CGFloat(asset.pixelHeight) * cropRect.height)
            let dimensionW   = max(min(targetHeight, targetWidth), 1024 * UIScreen.main.scale)
            let dimensionH   = dimensionW * self.getCropHeightRatio()
            
            let targetSize   = CGSize(width: dimensionW, height: dimensionH)
            
            PHImageManager.default().requestImage(
                for: asset, targetSize: targetSize,
                contentMode: .aspectFill, options: options) { result, info in

                guard let result = result else { return }
                    
                DispatchQueue.main.async(execute: {
                    
                    completion(asset, result)
                })
            }
        })
    }
    
    private func fusumaDidFinishInMultipleMode() {
        
        guard let view = albumView.imageCropView else { return }
        
        let normalizedX = view.contentOffset.x / view.contentSize.width
        let normalizedY = view.contentOffset.y / view.contentSize.height
        
        let normalizedWidth  = view.frame.width / view.contentSize.width
        let normalizedHeight = view.frame.height / view.contentSize.height
        
        let cropRect = CGRect(x: normalizedX, y: normalizedY,
                              width: normalizedWidth, height: normalizedHeight)
        
        var images = [UIImage]()
        
        for asset in albumView.selectedAssets {
            
            requestImage(with: asset, cropRect: cropRect) { asset, result in
                
                images.append(result)
                
                if asset == self.albumView.selectedAssets.last {
                    
                    self.doDismiss {

                        self.delegate?.fusumaMultipleImageSelected(images, source: self.mode)
                    }
                }
            }
        }
    }
}

extension FusumaViewController: FSAlbumViewDelegate, FSCameraViewDelegate, FSVideoCameraViewDelegate {
    
    public func getCropHeightRatio() -> CGFloat {
        
        return cropHeightRatio
    }
    
    // MARK: FSCameraViewDelegate
    func cameraShotFinished(_ image: UIImage) {
        
        if self.addPost {
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "CameraImagePreviewVC") as! CameraImagePreviewVC
            vc.imgPost = image
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        delegate?.fusumaImageSelected(image, source: mode)
        
        changeMode(FusumaMode.library)
        albumView.layoutIfNeeded()
        albumView.initialize()
        
        
        //self.doDismiss {

           // self.delegate?.fusumaDismissedWithImage(image, source: self.mode)
        //}
    }
    
    public func albumViewCameraRollAuthorized() {
        
        // in the case that we're just coming back from granting photo gallery permissions
        // ensure the done button is visible if it should be
        self.updateDoneButtonVisibility()
    }
    
    public func cameraSelected() {
        if self.addPost {
            changeMode(FusumaMode.camera)
            return
        }
        self.showCamera()
        //changeMode(FusumaMode.camera)
    }
    
    // MARK: FSAlbumViewDelegate
    public func albumViewCameraRollUnauthorized() {
        
        self.updateDoneButtonVisibility()
        delegate?.fusumaCameraRollUnauthorized()
    }
    
    func videoFinished(withFileURL fileURL: URL) {
        
        delegate?.fusumaVideoCompleted(withFileURL: fileURL)
        self.doDismiss(completion: nil)
    }
    
}

private extension FusumaViewController {
    
    func stopAll() {
        
        if availableModes.contains(.video) {

            self.videoView.stopCamera()
        }
        
        if availableModes.contains(.camera) {
            
            self.cameraView.stopCamera()
        }
    }
    
    func changeMode(_ mode: FusumaMode, isForced: Bool = false) {

        if !isForced && self.mode == mode { return }
        
        switch self.mode {
            
        case .camera:
            
            self.cameraView.stopCamera()
        
        case .video:
        
            self.videoView.stopCamera()
        
        default:
        
            break
        }
        
        self.mode = mode
        
        dishighlightButtons()
        updateDoneButtonVisibility()
        
        switch mode {
            
        case .library:
            
            //titleLabel.text = NSLocalizedString(fusumaCameraRollTitle, comment: fusumaCameraRollTitle)
            highlightButton(libraryButton)
            self.view.bringSubview(toFront: photoLibraryViewerContainer)
            //self.view.insertSubview(photoLibraryViewerContainer, at: 0)
        
        case .camera:
            cameraView.frame = CGRect(x:0,y:0,width:cameraShotContainer.frame.size.width,height:cameraShotContainer.frame.size.height)
            // cameraView.frame = CGRect(origin: CGPoint.zero, size: cameraShotContainer.frame.size)
            cameraView.layoutIfNeeded()
            cameraView.initialize()
            cameraView.initialCaptureDevicePosition = cameraPosition
            //titleLabel.text = NSLocalizedString(fusumaCameraTitle, comment: fusumaCameraTitle)
            highlightButton(cameraButton)
            self.view.bringSubview(toFront: cameraShotContainer)
            cameraView.startCamera()
            
        case .video:
            
            //titleLabel.text = NSLocalizedString(fusumaVideoTitle, comment: fusumaVideoTitle)
            highlightButton(videoButton)
            self.view.bringSubview(toFront: videoShotContainer)
            videoView.startCamera()
        }
        
        self.view.bringSubview(toFront: self.buttonContainerView)
    }
    
    func updateDoneButtonVisibility() {

        if !hasGalleryPermission {
            
          //  self.doneButton.isHidden = true
            return
        }

      
    }
    
    func dishighlightButtons() {
        
        cameraButton.setTitleColor(fusumaBaseTintColor, for: .normal)
        
        if let libraryButton = libraryButton {
            
            libraryButton.setTitleColor(fusumaBaseTintColor, for: .normal)
        }
        
        if let videoButton = videoButton {
            
            videoButton.setTitleColor(fusumaBaseTintColor, for: .normal)
        }
    }
    
    func highlightButton(_ button: UIButton) {
        
        button.setTitleColor(fusumaTintColor, for: .normal)
    }
    
    func getTabButton(mode: FusumaMode) -> UIButton {
        
        switch mode {
            
        case .library:
            
            return libraryButton
            
        case .camera:
            
            return cameraButton
            
        case .video:
            
            return videoButton
        }
    }
}
