//
//  CameraRollVC.swift
//  Rack
//
//  Created by hyperlink on 02/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import Photos


class CameraRollVC: UIViewController {

    //MARK:- Outlet
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var scrollView: FAScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var drawView: UIView!
    @IBOutlet weak var constTop: NSLayoutConstraint!

    @IBOutlet weak var btnResize: UIButton!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var delegate : ChooseRectDelegate?
    
    var constant : CGFloat = 0.0
    let colum : Float = 4.0,spacing :Float = 1.0
    let heightForVisibleView : CGFloat = 60.0
    
    var images: PHFetchResult<PHAsset>!
    var imageManager: PHCachingImageManager?
    var phAsset: PHAsset!
    
    var arrayIndex = NSMutableArray()
    
    var mode : PickerMode = .defaultPickerMode
    var value = 0.0

    //------------------------------------------------------
    
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(NSNotification.Name.UIApplicationUserDidTakeScreenshot)
        NotificationCenter.default.removeObserver(kNotificationScreenShot)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        
        value = Double(floorf((Float(kScreenWidth - 2) - (colum - 1) * spacing) / colum))

        //Add black circle for profile image
        switch mode {
        case .profilePickerMode:
            self.title = "CAMERA ROLL"
            self.addBlackCircle()
            btnResize.isHidden = true
            break
        case .defaultPickerMode:
            btnResize.isHidden = true
            break
        case .imagePostPickerMode:
            btnResize.isHidden = false
            break
        }
    
        //Add pan gesture drawView
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        drawView.addGestureRecognizer(panGesture)
        drawView.isUserInteractionEnabled = true
        
        //Check for permission
        self.checkPhotoAuth()

        //fetch images from photo laira
        self.fetchDataFromPhotoLibrary()
        
        btnResize.applyStyle(cornerRadius: btnResize.frame.size.height / 2)
        btnResize.backgroundColor = UIColor.init(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        
        //observer executes after screenshot updates gallery photos
        let mainQueue = OperationQueue.main
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationUserDidTakeScreenshot,
                                               object: nil,
                                               queue: mainQueue,
                                               using: { notification in
                                                //executes after screenshot
                                                
                                                //Check for permission
                                                self.checkPhotoAuth()
                                                
                                                //fetch images from photo laira
                                                //self.fetchDataFromPhotoLibrary()
                                                self.perform(#selector(self.fetchDataFromPhotoLibrary), with: nil, afterDelay: 1.0)
                                                
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkPhotoAuth), name: NSNotification.Name(rawValue: kNotificationScreenShot), object: nil)
    }
    
    func fetchDataFromPhotoLibrary () {

        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        images = PHAsset.fetchAssets(with: .image, options: options)
        
        //set first image in scrollable Image
        if self.images != nil && self.images.count > 0 {
            self.fetchImageFromPHAsset(self.images[0])
        }
        collectionView.reloadData()
        

    }
    
    func addBlackCircle() {
        
        let radius: Double = (Double(kScreenWidth) / 2)
        let path = UIBezierPath(roundedRect: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(kScreenWidth), height: CGFloat(kScreenWidth)), cornerRadius: 0)
        let circlePath = UIBezierPath(roundedRect: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(2.0 * radius), height: CGFloat(2.0 * radius)), cornerRadius: CGFloat(radius))
        path.append(circlePath)
        path.usesEvenOddFillRule = false
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.40
        topView.layer.addSublayer(fillLayer)
//        topView.layer.zPosition = 1
    }
    
    func captureVisibleRect() -> UIImage{
        
        var croprect = CGRect.zero
        let xOffset = (scrollView.imageToDisplay?.size.width)! / scrollView.contentSize.width;
        let yOffset = (scrollView.imageToDisplay?.size.height)! / scrollView.contentSize.height;
        
        croprect.origin.x = scrollView.contentOffset.x * xOffset;
        croprect.origin.y = scrollView.contentOffset.y * yOffset;
        
        let normalizedWidth = (scrollView?.frame.width)! / (scrollView?.contentSize.width)!
        let normalizedHeight = (scrollView?.frame.height)! / (scrollView?.contentSize.height)!
        
        croprect.size.width = scrollView.imageToDisplay!.size.width * normalizedWidth
        croprect.size.height = scrollView.imageToDisplay!.size.height * normalizedHeight
        
        let cr: CGImage? = scrollView.imageView.image?.cgImage?.cropping(to: croprect)
        let cropped = UIImage(cgImage: cr!)
        
        return cropped
        
    }
    
    private func isSquareImage() -> Bool{
        let image = scrollView.imageToDisplay
        if image?.size.width == image?.size.height || mode == .defaultPickerMode || mode == .profilePickerMode {
            return true
        }
        else { return false
        }
    }
    
    func displayImageInScrollView(image:UIImage){
        
        //Require to pass Picker Mode to FAScrollView. Depend on that decide image cropping square or with rasio.
        self.scrollView.mode = mode
        self.scrollView.imageToDisplay = image
        if isSquareImage() { btnResize.isHidden = true }
        else { btnResize.isHidden = false }
    }


    func respositionView(_ constantValue : CGFloat) {
        
        //To Change view position of collection view
        
        constTop.constant = constantValue
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }


    func panGestureAction(_ gesture : UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: self.view)
        
        switch gesture.state {
        case .ended,.cancelled,.failed:

            let frame = topView.frame
            if constTop.constant > constant {
                respositionView((constTop.constant - constant) > heightForVisibleView ? 0 : heightForVisibleView - frame.size.height)
            } else {//if (constant < constTop.constant) {
                respositionView((constant - constTop.constant) > heightForVisibleView ? heightForVisibleView - frame.size.height : 0)
            }
          
            break
        case .began:
            constant = constTop.constant
            break
        case .changed:

            print(translation.y)
            //Not allow contraint value more than 0 and lessthan view - 60
            if (translation.y + constant) < 0  && (translation.y + constant > heightForVisibleView - topView.frame.size.height){
                constTop.constant = translation.y + constant
            }
            break

        default:
            print("default changed called")
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    func leftButtonClicked() {

        //TODO:- Offset zero because of VC pop animation generate issue of image clips.
        scrollView.contentOffset = CGPoint(x: 0, y: 0)

        _ = self.navigationController?.popViewController(animated: true)
    }

    func rightButtonClicked() {

        if let _ = self.delegate {
            if scrollView.imageToDisplay != nil {
                self.delegate?.getSelectedReckDetail(data: [kImage : self.captureVisibleRect()])
            }
        }
        
        //TODO:- Offset zero because of VC pop animation generate issue of image clips.
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnResizeClicked(_ sender: UIButton) {

        if scrollView.imageView.image != nil {
            scrollView.zoomWithoutAnimation()
        }
    }
    
    //MARK:- ScrollView Delegate
   
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView.isEqual(collectionView) {
            
            if velocity.y >= 0.10 && constTop.constant == 0 {
                respositionView(heightForVisibleView - topView.frame.size.height)
            }
            /*else if velocity.y < 0
            {
                self.respositionView(0)
            }*/
            
        } else {
            
        }
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
      self.view.backgroundColor = AppColor.primaryTheme
      self.collectionView.backgroundColor = AppColor.primaryTheme
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = addBarButtons(btnLeft: BarButton(title: "Cancel"), btnRight: BarButton(title: "Done"), title: "CAMERA ROLL",isSwipeBack: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
}
//MARK:- Collection DataSource Delegate
extension CameraRollVC : PSCollectinViewDelegateDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images == nil ? 0 : images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //value 2 - is left and right padding of collection view
        //value 1 - is spacing between two cell collection view
        
        return CGSize(width: Double(value), height: Double(value))

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell : CustomImagePickerCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CustomImagePickerCell", for: indexPath) as! CustomImagePickerCell
        
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        
        let options = PHImageRequestOptions()
        
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        let asset = self.images[(indexPath as NSIndexPath).item]
        self.imageManager?.requestImage(for: asset,
                                        targetSize: CGSize(width: cell.frame.size.width * 2, height: cell.frame.size.width * 2),
                                        contentMode: .aspectFill,
                                        options: options) {
                                            result, info in
                                            
                                            if cell.tag == currentTag {
                                                cell.img.image = result
                                            }
                                            
        }
      
        cell.backgroundColor = AppColor.primaryTheme
        cell.contentView.backgroundColor = AppColor.primaryTheme
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if (!arrayIndex.contains(indexPath)) {
         
            arrayIndex.removeAllObjects()
            arrayIndex.add(indexPath)
        
            fetchImageFromPHAsset(self.images[indexPath.row])

            //In .profilePickerMode mode and .imagePostPickerMode mode not require delegate calling during didselect. It require only click on done button.
/*            switch mode {
            case .profilePickerMode , .imagePostPickerMode:
                break
                
            case .defaultPickerMode:
                
                if let _ = self.delegate {
                    self.delegate?.getSelectedReckDetail(data: [kImage : self.captureVisibleRect()])
                }
                break

            }
 */
        }
        self.respositionView(0)
        
    }


}

private extension CameraRollVC {
    
    func fetchImageFromPHAsset(_ asset: PHAsset) {
        
        self.phAsset = asset
        DispatchQueue.global(qos: .default).async(execute: {
            
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.isSynchronous = true

            self.imageManager?.requestImage(for: asset,
                                            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                                            contentMode: .aspectFill,
                                            options: options) {
                                                result, info in
                                                
                                                DispatchQueue.main.async(execute: {
                                                    if let _ = result {
                                                        self.displayImageInScrollView(image: result!)
                                                    }
                                                })
            }
        })
    }
    
    // Check the status of authorization for PHPhotoLibrary
    @objc func checkPhotoAuth() {
        
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            switch status {
            case .authorized:
                self.imageManager = PHCachingImageManager()
                
                DispatchQueue.main.async {
                    self.fetchDataFromPhotoLibrary()
//                    self.perform(#selector(self.fetchDataFromPhotoLibrary), with: nil, afterDelay: 1.0)
                }
                
            case .restricted, .denied:
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    AlertManager.shared.showAlertTitle(title: kSettingChangeTitle, message: kPhotoPermissionMessage, buttonsArray: ["Close","Go To Settings"], completionBlock: { (index : Int) in
                        
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
            default:
                break
            }
        }
    }
}
//MARK:- CustomImagePickerCell -
class CustomImagePickerCell: UICollectionViewCell {
    
    @IBOutlet var img : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      self.backgroundColor = AppColor.primaryTheme
      self.contentView.backgroundColor = AppColor.primaryTheme

        img.contentMode = .scaleAspectFill
        self.isSelected = false
    }
    
    override var isSelected : Bool {
        didSet {
//            self.layer.borderColor = isSelected ? UIColor.red.cgColor : UIColor.clear.cgColor
//            self.layer.borderWidth = isSelected ? 2 : 0
        }
    }
    
}
//MARK:-
