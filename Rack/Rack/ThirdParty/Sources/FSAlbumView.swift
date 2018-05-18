
//  FSAlbumView.swift
//  Fusuma
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.

import UIKit
import Photos


enum AlbumPickerType {
    case Cover
    case PhotoPicker
    case AddPost
}

public protocol FSAlbumViewDelegate: class {
    // Returns height ratio of crop image. e.g) 4:3 -> 7.5
    func getCropHeightRatio() -> CGFloat
    func cameraSelected()
    func albumViewCameraRollUnauthorized()
    func albumViewCameraRollAuthorized()
}

final class FSAlbumView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver, UIGestureRecognizerDelegate {
    var lastSelectedCell:FSAlbumViewCell! = nil
    var type:AlbumPickerType = .AddPost
    var optionsContainerView:UIView! = UIView()
     var headerView:UIView! = nil
    var album:AlbumModel! = nil
    var superView:UIView! = nil
    var isShowGallery:Bool = false
    var photoGalleryView:PhotoGalleryView! = nil
    var libraryString:String = "Camera Roll"
     var addPost:Bool = false
    var needToScroll:Bool  = true
    var isNewuser:Bool = false
    var userData:UserModel! = nil
    @IBOutlet weak var collectionView: UICollectionView!
    var imageCropView: FAScrollView!
    var originalHeight:CGFloat! = nil
    var setheight:CGFloat!=nil
    @IBOutlet var imageCropViewContainer: UIView!
    
    @IBOutlet weak var collectionViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var imageCropViewConstraintTop: NSLayoutConstraint!
    weak var delegate: FSAlbumViewDelegate? = nil
    var allowMultipleSelection = false
    fileprivate var images      : PHFetchResult<PHAsset>!
    fileprivate var imageManager: PHCachingImageManager?
    fileprivate var previousPreheatRect: CGRect = .zero
    fileprivate let cellSize = CGSize(width: 100, height: 100)
    var sectioHeader:UIView! = nil
    var phAsset: PHAsset!
     let coverLabel = UILabel()
    var selectedImages: [UIImage] = []
    var selectedAssets: [PHAsset] = []
    var selectedIndexPath:IndexPath = IndexPath(row: 0, section: 0)
     var mode : PickerMode = .defaultPickerMode
    typealias CallBack = (Bool,String?)->Void
    var callBack:CallBack!
    let btnResize:UIButton = UIButton()
    var buttonContainerYOffset: NSLayoutConstraint!
    var tapGesture:UITapGestureRecognizer! = nil
    // Variables for calculating the position
    enum Direction {
        case scroll
        case stop
        case up
        case down
        case scrollUp
        case scrollDown
        case none
    }
    fileprivate var dragDirection = Direction.up
    fileprivate var scrollDragDirection = Direction.none
    private let imageCropViewOriginalConstraintTop: CGFloat = 0
    var imageCropViewMinimalVisibleHeight: CGFloat  = 60
    private var imaginaryCollectionViewOffsetStartPosY: CGFloat = 0.0
    private var cropBottomY: CGFloat  = 0.0
    private var dragStartPos: CGPoint = CGPoint.zero
    private let dragDiff: CGFloat     = 20.0
    var isFirsTime:Bool  = true
    var hideLabelTimer = Timer()
    
    
    static func instance(type:AlbumPickerType) -> FSAlbumView {
        if type == .Cover {
             return UINib(nibName: "FSAlbumView", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! FSAlbumView
        }
        return UINib(nibName: "NewFSAlbumView", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! FSAlbumView
    }
    func setCoverImage(image:UIImage) {
        self.perform(#selector(reset),with:nil,afterDelay: 0.5)
    }
    
    func  reset()  {
        if self.images.count > 0 {
            changeImage(images[images.count-1])
            self.layoutIfNeeded()
            if !isNewuser {
                coverLabel.alpha = 1.0
                self.hideLabelTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(hideLabel), userInfo: nil, repeats: false)
            }
            self.selectedIndexPath = IndexPath(row: 0, section: 0)
            self.collectionView.reloadData()
            self.needToScroll = false
            self.collectionView.selectItem(at: self.selectedIndexPath, animated: false, scrollPosition: .top)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        var numberOfRows:CGFloat = 4.0
        if type == .Cover {
            numberOfRows = 3.0
        }
        let frame : CGRect = self.frame
        let margin  = (frame.width - 90 * numberOfRows) / 6.0
        return UIEdgeInsetsMake(10, margin, 10, margin) // margin between cells
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width:self.frame.size.width, height:300)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        // Create header
        if (kind == UICollectionElementKindSectionHeader) {
            // Create Header
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CustomHeader", for: indexPath)
            headerView.backgroundColor = UIColor.white
            headerView.frame = CGRect(x:0, y:0, width:self.frame.size.width, height:headerView.frame.size.height)
            self.sectioHeader = headerView
            var profileImage:UIImageView! = headerView.viewWithTag(1001) as? UIImageView
            if profileImage == nil && (!self.isNewuser)  {
                
                let controlView:ProfieControlsView = ProfieControlsView()
                controlView.frame = CGRect(x:0,y:imageCropViewContainer.frame.size.height-34.0,width:self.frame.size.width,height:34.0)
                controlView.backgroundColor = UIColor.clear
                headerView.addSubview(controlView)
                
                let profileCoverImage = UIImageView()
                profileCoverImage.clipsToBounds = true
                profileCoverImage.backgroundColor = UIColor.clear
                profileCoverImage.frame = CGRect(x:19.0,y:self.imageCropViewContainer.frame.size.height-64,width:104,height:104)
                profileCoverImage.layer.cornerRadius = profileCoverImage.frame.size.width/2.0
                profileCoverImage.layer.borderColor = UIColor(red:214/255.0,green:1/255.0,blue:1/255.0,alpha:1.0).cgColor
                profileCoverImage.layer.borderWidth = 0
                headerView.addSubview(profileCoverImage)
                profileImage = UIImageView()
                profileImage.clipsToBounds = true
                profileImage.contentMode = .scaleAspectFill
                
                if let imageData = UserDefaults.standard.value(forKey: kUserProfileImage),
                    let image = UIImage(data: imageData as! Data){
                    profileImage.image = image
                }else{
                    profileImage.setImageWithDownload(self.userData.getUserProfile().url())
                }
                
                profileImage.tag = 1001
                profileImage.backgroundColor = UIColor.white
                profileImage.layer.borderColor = UIColor.white.cgColor
                profileImage.layer.borderWidth = 1
                profileImage.frame = CGRect(x:23.0,y:self.imageCropViewContainer.frame.size.height-60.0,width:96.0,height:96.0)
                profileImage.layer.cornerRadius = profileImage.frame.size.width/2.0
                headerView.addSubview(profileImage)
                
                let textContainer = UIView()
                textContainer.frame = CGRect(x:profileImage.frame.origin.x+profileImage.frame.size.width+36,y:profileImage.frame.origin.y+20.0,width:self.frame.size.width-(profileImage.frame.origin.x+profileImage.frame.size.width+30+14),height:profileImage.frame.size.height)
                headerView.addSubview(textContainer)
                
                let cameraButton = UIButton()
                cameraButton.setImage(UIImage(named:"cover_camera"), for: .normal)
                cameraButton.imageEdgeInsets = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0)
                cameraButton.frame = CGRect(x:self.frame.size.width-23-36,y:profileImage.frame.origin.y+10.0,width:36.0,height:36)
                cameraButton.layer.cornerRadius = cameraButton.frame.size.width/2.0
                cameraButton.layer.shadowColor  = UIColor.black.cgColor
                cameraButton.layer.shadowOpacity = 0.2
                cameraButton.layer.shadowRadius = 2.0
                cameraButton.layer.shadowOffset = CGSize(width:2,height:2)
                cameraButton.backgroundColor = UIColor.white
                headerView.addSubview(cameraButton)
                let numberOfRows:CGFloat = 3.0
                let width:CGFloat  =  textContainer.frame.size.width/numberOfRows
                var xOffset:CGFloat = 0.0
                let displacement:CGFloat = 5.0
                var label = UILabel()
                label.font = UIFont.applyBold(fontSize: 16.0)
                label.textColor = UIColor.black
                label.textAlignment = .center
                label.text = userData.rackCount
                label.frame =  CGRect(x:xOffset+displacement,y:textContainer.frame.size.height/2.0-8.0,width:width-2.0*displacement,height:16.0)
                textContainer.addSubview(label)
                label = UILabel()
                label.textAlignment = .center
                label.font = UIFont.applyRegular(fontSize: 10.7)
                label.textColor = UIColor(red:24.0/255.0,green:24.0/255.0,blue:24.0/255.0,alpha:1.0)
                label.text = "racked"
                label.frame =  CGRect(x:xOffset+displacement,y:textContainer.frame.size.height/2.0+9.0,width:width-2.0*displacement,height:16.0)
                textContainer.addSubview(label)
                xOffset = xOffset + width
                
                label = UILabel()
                label.textAlignment = .center
                label.font = UIFont.applyBold(fontSize: 16.0)
                label.textColor = UIColor.black
                label.text = userData.followersCount
                label.frame =  CGRect(x:xOffset+displacement,y:textContainer.frame.size.height/2.0-8.0,width:width-2.0*displacement,height:16.0)
                textContainer.addSubview(label)
                
                label = UILabel()
                label.textAlignment = .center
                label.font = UIFont.applyRegular(fontSize: 10.7)
                label.textColor = UIColor(red:24.0/255.0,green:24.0/255.0,blue:24.0/255.0,alpha:1.0)
                label.text = "followers "
                label.frame =  CGRect(x:xOffset+displacement,y:textContainer.frame.size.height/2.0+9.0,width:width-2.0*displacement + 2,height:16.0)
                textContainer.addSubview(label)
                xOffset = xOffset + width
                
                label = UILabel()
                label.font = UIFont.applyBold(fontSize: 16.0)
                label.textColor = UIColor.black
                label.text = userData.followingCount
                label.textAlignment = .center
                label.frame =  CGRect(x:xOffset+displacement,y:textContainer.frame.size.height/2.0-8.0,width:width-2.0*displacement,height:16.0)
                textContainer.addSubview(label)
                
                label = UILabel()
                label.font = UIFont.applyRegular(fontSize: 10.7)
                label.textColor = UIColor(red:24.0/255.0,green:24.0/255.0,blue:24.0/255.0,alpha:1.0)
                label.text = "following"
                label.textAlignment = .center
                label.frame =  CGRect(x:xOffset+displacement,y:textContainer.frame.size.height/2.0+9.0,width:width-2.0*displacement + 2,height:16.0)
                textContainer.addSubview(label)
                
                xOffset = xOffset + width
                
                let nameLabel = UILabel()
                nameLabel.font = UIFont.applyBold(fontSize: 16.0)
                nameLabel.textColor = UIColor.black
                
                nameLabel.text = userData.displayName
                nameLabel.frame =  CGRect(x:23.0,y:profileImage.frame.size.height+profileImage.frame.origin.y+16.0,width:276.0,height:25.0)
                headerView.addSubview(nameLabel)
                
                // *** Create instance of `NSMutableParagraphStyle`
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.minimumLineHeight = 17.5
                paragraphStyle.maximumLineHeight = 17.5
                paragraphStyle.alignment = .left
                
                let attrString = NSMutableAttributedString(string: userData.bioTxt)
                attrString.addAttribute(NSFontAttributeName, value: UIFont.applyRegular(fontSize: 14.0), range: NSRange(location: 0, length: attrString.length))
                attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:24.0/255.0,green:24.0/255.0,blue:24.0/255.0,alpha:1.0), range: NSRange(location: 0, length: attrString.length))
                attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: attrString.length))
               
                let bioLabel = UILabel()
                bioLabel.attributedText = attrString
                bioLabel.numberOfLines = 0
                bioLabel.frame =  CGRect(x:23.0,y:nameLabel.frame.size.height+nameLabel.frame.origin.y+9,width:self.frame.size.width-46,height:0)
                headerView.addSubview(bioLabel)
                bioLabel.sizeToFit()
                
            }
            
            if !isNewuser  {
                headerView.insertSubview(imageCropViewContainer, at: 0)
            }
            
            reusableView = headerView
        }
        return reusableView!
    }
    
    func cameraButtonAction(){
        self.imageCropView.isScrollEnabled = true
        imageCropViewConstraintTop.constant = imageCropViewOriginalConstraintTop
        collectionViewConstraintHeight.constant = self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height
        self.delegate?.cameraSelected()
    }
    
    func hideLabel() {
        UIView.animate(withDuration: 0.2) {
            self.hideLabelTimer.invalidate()
            self.coverLabel.alpha  = 0.0
        }
    }
    
    func cropButtonAction(){
        if imageCropView.imageView.image != nil {
            imageCropView.zoomWithoutAnimation()
        }
    }
    
    func resetCamera()  {
        self.imageCropView.isScrollEnabled = true
        tapGesture.isEnabled = false
        imageCropViewConstraintTop.constant = imageCropViewOriginalConstraintTop
        
        collectionViewConstraintHeight.constant = self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height
        
        self.optionsContainerView.frame = CGRect(x:0,y:self.imageCropViewContainer.frame.size.height-50.0,width:self.optionsContainerView.frame.size.width,height:self.optionsContainerView.frame.size.height)
        
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        
                        self.layoutIfNeeded()
        }, completion: nil)
        collectionView.scrollToItem(at: self.selectedIndexPath, at: .top, animated: false)
    }
    
    func addButtonBar() {
          self.optionsContainerView.frame = CGRect(x:0,y:self.imageCropViewContainer.frame.size.height-50.0,width:self.optionsContainerView.frame.size.width,height:self.optionsContainerView.frame.size.height)
        self.imageCropViewContainer.addSubview(self.optionsContainerView)
        self.imageCropViewContainer.bringSubview(toFront: self.optionsContainerView)
    }
    
    func captureVisibleRect() -> UIImage{
        
        var croprect = CGRect.zero
        let xOffset = (imageCropView.imageToDisplay?.size.width)! / imageCropView.contentSize.width;
        let yOffset = (imageCropView.imageToDisplay?.size.height)! / imageCropView.contentSize.height;
        
        croprect.origin.x = imageCropView.contentOffset.x * xOffset;
        croprect.origin.y = imageCropView.contentOffset.y * yOffset;
        
        let normalizedWidth = (imageCropView?.frame.width)! / (imageCropView?.contentSize.width)!
        let normalizedHeight = (imageCropView?.frame.height)! / (imageCropView?.contentSize.height)!
        
        croprect.size.width = imageCropView.imageToDisplay!.size.width * normalizedWidth
        croprect.size.height = imageCropView.imageToDisplay!.size.height * normalizedHeight
        
        let imageRef: CGImage? = imageCropView.imageView.image?.cgImage?.cropping(to: croprect)
        let cropped = UIImage(cgImage: imageRef!)
       // return cropped
        let imageRef2 = cropped.cgImage
        UIGraphicsBeginImageContextWithOptions(cropped.size, false, 0)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        // Set the quality level to use when rescaling
        context?.interpolationQuality = .high
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: croprect.height)
        context?.concatenate(flipVertical)
        croprect.origin.x = 0
        croprect.origin.y = 0
        croprect.size     = cropped.size
        context?.draw(imageRef2!, in: croprect)
        // Get the resized image from the context and a UIImage
        let newImageRef: CGImage = context!.makeImage()!
        let newImage = UIImage(cgImage: newImageRef)
        UIGraphicsEndImageContext()
        return newImage
       
    }
    
    func initialize() {
        
        if images != nil { return }
		self.isHidden = false

        setheight = 50
        originalHeight = optionsContainerView.frame.origin.y
        
        if type == .Cover{
            imageCropViewContainer = UIView()
            imageCropViewContainer.isUserInteractionEnabled = true
            imageCropViewContainer.frame = CGRect(x:0,y:0,width:self.frame.size.width,height:self.frame.size.width)
            imageCropViewContainer.clipsToBounds = true
            
            coverLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            coverLabel.textColor = UIColor.white
            coverLabel.text = "Your cover will appear here."
            coverLabel.font = UIFont(name:"Helvetica",size:16.0)
            coverLabel.textAlignment = .center
            coverLabel.layer.cornerRadius = 5.0
            coverLabel.clipsToBounds = true
            coverLabel.frame = CGRect(x:50.0,y:imageCropViewContainer.frame.size.height/2.0-16.0,width:imageCropViewContainer.frame.size.width-100.0,height:36.0)
            imageCropViewContainer.addSubview(coverLabel)
            self.hideLabelTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(hideLabel), userInfo: nil, repeats: false)
        }
        
        self.mode = .profilePickerMode
        if type == .AddPost {
             self.mode = .imagePostPickerMode
        }
        imageCropView = FAScrollView.init(frame:imageCropViewContainer.bounds)
        imageCropView.backgroundColor = UIColor.white
        imageCropViewContainer.addSubview(imageCropView)
        imageCropView.updateLayout()
        
        if type == .PhotoPicker {
            let radius: Double = (Double(imageCropViewContainer.frame.size.width) / 2)
            let path = UIBezierPath(roundedRect: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(imageCropViewContainer.frame.size.width), height: CGFloat(imageCropViewContainer.frame.size.width)), cornerRadius: 0)
            let circlePath = UIBezierPath(roundedRect: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(2.0 * radius), height: CGFloat(2.0 * radius)), cornerRadius: CGFloat(radius))
            path.append(circlePath)
            path.usesEvenOddFillRule = false
            let fillLayer = CAShapeLayer()
            fillLayer.path = path.cgPath
            fillLayer.fillRule = kCAFillRuleEvenOdd
            fillLayer.fillColor = UIColor.black.cgColor
            fillLayer.opacity = 0.50
            imageCropViewContainer.layer.addSublayer(fillLayer)
        }
        
        if type == .AddPost {
            imageCropViewContainer.isUserInteractionEnabled = true
            btnResize.frame = CGRect(x:15.0,y:imageCropViewContainer.frame.size.height-60.0,width:50.0,height:50.0)
            btnResize.setImage(UIImage(named:"btnResize"), for: .normal)
            btnResize.imageView?.contentMode = .scaleAspectFit
            btnResize.backgroundColor = UIColor.white.withAlphaComponent(0.4)
            btnResize.addTarget(self, action: #selector(cropButtonAction), for: .touchUpInside)
            btnResize.layer.cornerRadius = btnResize.frame.size.width/2.0
            btnResize.clipsToBounds = true
            imageCropViewContainer.addSubview(btnResize)
        }
       
       
        if type != .Cover{
             self.imageCropViewContainer.bringSubview(toFront: btnResize)
            tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(resetCamera))
            tapGesture.isEnabled = false
            imageCropViewContainer.addGestureRecognizer(tapGesture)
            var ratio = 1.0
            if type == .AddPost {
                imageCropViewMinimalVisibleHeight = 110.0
                ratio = Double((self.frame.size.width+50.0)/self.frame.size.width)
            }
            imageCropViewContainer.addConstraint(
                NSLayoutConstraint(item: imageCropViewContainer,
                                   attribute: NSLayoutAttribute.height,
                                   relatedBy: NSLayoutRelation.equal,
                                   toItem: imageCropViewContainer,
                                   attribute: NSLayoutAttribute.width,
                                   multiplier: CGFloat(ratio),
                                   constant: 0))
            layoutSubviews()
            let panGesture      = UIPanGestureRecognizer(target: self, action: #selector(FSAlbumView.panned(_:)))
            panGesture.delegate = self
            collectionView.addGestureRecognizer(panGesture)
            collectionViewConstraintHeight.constant = self.frame.height - imageCropViewContainer.frame.height - imageCropViewOriginalConstraintTop
            imageCropViewConstraintTop.constant = 00
          self.optionsContainerView.frame = CGRect(x:0,y:self.imageCropViewContainer.frame.size.height-50.0,width:self.optionsContainerView.frame.size.width,height:self.optionsContainerView.frame.size.height)
            self.imageCropViewContainer.addSubview(self.optionsContainerView)
            self.imageCropViewContainer.bringSubview(toFront: self.optionsContainerView)
          //
        }else{
            self.imageCropViewContainer.bringSubview(toFront: coverLabel)
            var height:CGFloat = 15.0 + 38.0 + 16.0 + 7.5 + 0.0
            height = height + self.userData.bioTxt.getHeight(withConstrainedWidth: self.frame.size.width-46.0, font: UIFont.applyRegular(fontSize: 14.0))
          
            let flow = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
            flow.headerReferenceSize = CGSize(width:self.frame.size.width,height:self.imageCropViewContainer.frame.size.height+height+20)
            collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CustomHeader")
        }
        dragDirection = Direction.up
        
        collectionView.register(UINib(nibName: "FSAlbumViewCell", bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: "FSAlbumViewCell")
        self.collectionView.showsVerticalScrollIndicator   = false
        self.collectionView.showsHorizontalScrollIndicator = false
		collectionView.backgroundColor                     = UIColor.white
        collectionView.allowsMultipleSelection             = false
        checkPhotoAuth()
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            images =  imagesManager().getImages()
        } else{
            images = PHAsset.fetchAssets(with: .image, options: nil)
        }
        if images.count == 0 {
           images = PHAsset.fetchAssets(with: .image, options: nil)
        }
        if self.images.count > 0 {
            self.album = AlbumModel.init(name: "Camera Roll", count: self.images.count, collection: nil, asset: self.images.lastObject!)
            self.changeImage(self.images[self.images.count-1])
            self.selectedIndexPath = IndexPath(row: 0, section: 0)
            self.collectionView.reloadData()
        }
        PHPhotoLibrary.shared().register(self)
        
    }

    deinit {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    func isSquareImage() -> Bool{
        let image = imageCropView.imageToDisplay
        if image?.size.width == image?.size.height || mode == .defaultPickerMode || mode == .profilePickerMode {
            return true
        }
        else { return false
        }
    }
    @objc func panned(_ sender: UITapGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.began {
         //   self.optionsContainerView.alpha = 0.0
            let view    = sender.view
            let loc     = sender.location(in: view)
            let subview = view?.hitTest(loc, with: nil)
            
            if subview == imageCropView && imageCropViewConstraintTop.constant == imageCropViewOriginalConstraintTop {
                return
            }
            dragStartPos = sender.location(in: self)
            cropBottomY = self.imageCropViewContainer.frame.origin.y + self.imageCropViewContainer.frame.height
            // Move
            if dragDirection == Direction.stop {
                dragDirection = (imageCropViewConstraintTop.constant == imageCropViewOriginalConstraintTop) ? Direction.up : Direction.down
            }
            // Scroll event of CollectionView is preferred.
            if (dragDirection == Direction.up   && dragStartPos.y < cropBottomY + dragDiff) ||
                (dragDirection == Direction.down && dragStartPos.y > cropBottomY) {
                dragDirection = Direction.stop
                self.imageCropView.isScrollEnabled = false
                
            } else {
                self.imageCropView.isScrollEnabled = true
            }
        } else if sender.state == UIGestureRecognizerState.changed {
            let currentPos = sender.location(in: self)
            
            if dragDirection == Direction.up && currentPos.y < cropBottomY - dragDiff {
                
                imageCropViewConstraintTop.constant = max(imageCropViewMinimalVisibleHeight - self.imageCropViewContainer.frame.height, currentPos.y + dragDiff - imageCropViewContainer.frame.height)
 
                collectionViewConstraintHeight.constant = min(self.frame.height - imageCropViewMinimalVisibleHeight, self.frame.height - imageCropViewConstraintTop.constant - imageCropViewContainer.frame.height)
                
            } else if dragDirection == Direction.down && currentPos.y > cropBottomY {
                
                imageCropViewConstraintTop.constant = min(imageCropViewOriginalConstraintTop, currentPos.y - imageCropViewContainer.frame.height)
 
                collectionViewConstraintHeight.constant = max(self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height, self.frame.height - imageCropViewConstraintTop.constant - imageCropViewContainer.frame.height )
                
            } else if dragDirection == Direction.stop && collectionView.contentOffset.y < 0 {
                
                dragDirection = Direction.scroll
                imaginaryCollectionViewOffsetStartPosY = currentPos.y
                
            } else if dragDirection == Direction.scroll {
                
                imageCropViewConstraintTop.constant = imageCropViewMinimalVisibleHeight - self.imageCropViewContainer.frame.height + currentPos.y - imaginaryCollectionViewOffsetStartPosY
                collectionViewConstraintHeight.constant = max(self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height, self.frame.height - imageCropViewConstraintTop.constant - imageCropViewContainer.frame.height)
            }
            
        } else {
            
            imaginaryCollectionViewOffsetStartPosY = 0.0
            
            if sender.state == UIGestureRecognizerState.ended &&
                dragDirection == Direction.stop {
              
                self.imageCropView.isScrollEnabled = true
                return
            }
            
            let currentPos = sender.location(in: self)
            
            if currentPos.y < cropBottomY - dragDiff &&
                imageCropViewConstraintTop.constant != imageCropViewOriginalConstraintTop {
                self.imageCropView.isScrollEnabled = false
                imageCropViewConstraintTop.constant = imageCropViewMinimalVisibleHeight - self.imageCropViewContainer.frame.height
                collectionViewConstraintHeight.constant = self.frame.height - imageCropViewMinimalVisibleHeight
                
                UIView.animate(withDuration: 0.3,
                               delay: 0.0,
                               options: UIViewAnimationOptions.curveEaseOut,
                               animations: {
                            
                                self.layoutIfNeeded()
                                
                }, completion: nil)
                
                tapGesture.isEnabled = true
                dragDirection = Direction.down
                
            } else {
                
                self.imageCropView.isScrollEnabled = true
                imageCropViewConstraintTop.constant = imageCropViewOriginalConstraintTop
                collectionViewConstraintHeight.constant = self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height
                
                UIView.animate(withDuration: 0.3,
                               delay: 0.0,
                               options: UIViewAnimationOptions.curveEaseOut,
                               animations: {
                                self.layoutIfNeeded()
                                
                }, completion: nil)
                tapGesture.isEnabled = false
                dragDirection = Direction.up
                
            }
            
        }
        
    }
    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FSAlbumViewCell", for: indexPath) as! FSAlbumViewCell
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        cell.isSelected = false
        if self.selectedIndexPath == indexPath {
            self.lastSelectedCell = cell
            cell.isSelected = true
        }
        let asset = self.images[self.images.count - ((indexPath as NSIndexPath).item+1)]
            let options = PHImageRequestOptions()
            options.deliveryMode = .fastFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = true
            self.imageManager?.requestImage(for: asset, targetSize: self.cellSize, contentMode: .aspectFill, options: options) {
                                                result, info in
                    DispatchQueue.main.async(execute: {
                      if cell.tag == currentTag {
                            cell.image = result
                      }
                    })
            }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images == nil ? 0 : images.count
    }
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        var numberOfRows:CGFloat = 4.0
        if type == .Cover {
            numberOfRows = 3.0
        }
        let width = (collectionView.frame.width - numberOfRows) / numberOfRows
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        optionsContainerView.frame.origin.y=originalHeight
        self.selectedIndexPath = indexPath
        if self.type == .Cover {
             self.collectionView.reloadData()
             self.collectionView.contentOffset = CGPoint.zero
             changeImage(images[images.count - ((indexPath as NSIndexPath).row+1)])
             coverLabel.alpha = 1.0
             self.hideLabelTimer.invalidate()
             self.hideLabelTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(hideLabel), userInfo: nil, repeats: false)
        }else {
            if self.lastSelectedCell != nil {
                lastSelectedCell.isSelected = false
            }
            self.imageCropView.isScrollEnabled = true
            tapGesture.isEnabled = false
            let cell:FSAlbumViewCell = collectionView.cellForItem(at: indexPath) as! FSAlbumViewCell
            cell.isSelected = true
            lastSelectedCell = cell
            self.optionsContainerView.alpha = 1.0
    
            if Int((cell.imageView.image?.size.height)!) < Int((cell.imageView.image?.size.width)!) && (cell.imageView.image?.size.width)! > self.imageCropView.frame.size.width {
                self.imageCropView.imageToDisplay = cell.imageView.image
            } else {
                changeImage(images[images.count - ((indexPath as NSIndexPath).row+1)])
            }
            imageCropViewConstraintTop.constant = imageCropViewOriginalConstraintTop
            collectionViewConstraintHeight.constant = self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height
             self.optionsContainerView.frame = CGRect(x:0,y:self.imageCropViewContainer.frame.size.height-50.0,width:self.optionsContainerView.frame.size.width,height:self.optionsContainerView.frame.size.height)
            UIView.animate(withDuration: 0.1,
                           delay: 0.0,
                           options: UIViewAnimationOptions.curveEaseOut,
                           animations: {
                            
                            self.layoutIfNeeded()
            }, completion: nil)
        
            if scrollDragDirection == Direction.scrollDown {
                collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            }
            
            if scrollDragDirection == Direction.scrollUp {
                collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
            }
            
            dragDirection = Direction.up
            scrollDragDirection = Direction.none
        }
        
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    // MARK: - ScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scrollVelocity = collectionView.panGestureRecognizer.velocity(in: collectionView.superview)
        if (scrollVelocity.y > 0.0) {
            scrollDragDirection = Direction.scrollUp
        } else if (scrollVelocity.y < 0.0) {
            scrollDragDirection = Direction.scrollDown
        }
        
        if scrollView == collectionView {
            if self.images.count  > 0 {
              self.updateCachedAssets()
            }
        }
        
    }

    
    func showPhotoGallery()  {
        if !isShowGallery {
            isShowGallery = true
            if photoGalleryView == nil  {
                photoGalleryView = PhotoGalleryView.init(frame: self.superView.bounds,album:album)
                photoGalleryView.frame  = CGRect(x:0,y:self.frame.size.height,width:self.superView.frame.size.width,height:self.superView.frame.size.height)
                photoGalleryView.callBack = {(albumModel) in
                    self.album  = albumModel
                    if  self.album.collection == nil {
                        self.images = PHAsset.fetchAssets(with: .image, options: nil)
                    }else{
                        self.images = PHAsset.fetchAssets(in: self.album.collection! as! PHAssetCollection, options: nil)
                    }
                    

                    self.collectionView.reloadData()
                    if self.images.count > 0 {
                        self.changeImage(self.images.lastObject!)
                        self.selectedIndexPath = IndexPath(row: 0, section: 0)
                
                        self.collectionView.selectItem(at:  self.selectedIndexPath, animated: false, scrollPosition: .top)
                    }
                   
                    
                 
                    self.isShowGallery = false
                    self.libraryString = albumModel.name
                    UIView.animate(withDuration: 0.2, animations: {
                        self.photoGalleryView.frame  = CGRect(x:0,y:self.frame.size.height,width:self.superView.frame.size.width,height:self.superView.frame.size.height)
                    })
                    
                    if self.callBack != nil {
                        self.callBack(self.isShowGallery,self.libraryString)
                    }
                    
                }
                self.superView.addSubview(photoGalleryView)
            }
            self.superView.bringSubview(toFront: photoGalleryView)
            UIView.animate(withDuration: 0.2, animations: {
                self.photoGalleryView.frame  = CGRect(x:0,y:0,width:self.superView.frame.size.width,height:self.superView.frame.size.height)
            })
            
            if self.callBack != nil {
                self.callBack(self.isShowGallery,self.libraryString)
            }
        }else {
              isShowGallery = false
            UIView.animate(withDuration: 0.2, animations: {
                self.photoGalleryView.frame  = CGRect(x:0,y:self.frame.size.height,width:self.superView.frame.size.width,height:self.superView.frame.size.height)
            })
            
            if self.callBack != nil {
                self.callBack(self.isShowGallery,self.libraryString)
            }
        }
       
    }
    
    
    //MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        DispatchQueue.main.async {
            guard let collectionChanges = changeInstance.changeDetails(for: self.images) else {
            return
        }
            
            self.selectedImages.removeAll()
            self.selectedAssets.removeAll()
            self.images = collectionChanges.fetchResultAfterChanges
            let collectionView = self.collectionView!
            if self.imageCropView.imageView.image == nil {
                if self.images.count > 0 {
                    self.changeImage(self.images[self.images.count-1])
                }
            }
            if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
                collectionView.reloadData()
            } else {
               // collectionView.performBatchUpdates({
                
                    if let removedIndexes = collectionChanges.removedIndexes,
                        removedIndexes.count != 0 {
                        //print("before:", self.selectedIndexPath)
                        var index = self.selectedIndexPath.row - removedIndexes.count
                        index = index < 0 ? 0 : index
                        self.selectedIndexPath = IndexPath(row: index, section: 0)
                        //print("after:", self.selectedIndexPath)
                        //collectionView.deleteItems(at: removedIndexes.aapl_indexPathsFromIndexesWithSection(0))
                    }
                
                
                    if let insertedIndexes = collectionChanges.insertedIndexes,
                        insertedIndexes.count != 0 {
                        //print("before:", self.selectedIndexPath)
                        let index = self.selectedIndexPath.row + insertedIndexes.count
                        self.selectedIndexPath = IndexPath(row: index, section: 0)
                        //print("after:", self.selectedIndexPath)
                        //collectionView.insertItems(at: insertedIndexes.aapl_indexPathsFromIndexesWithSection(0))
                        
                    }
                
                
                    if let changedIndexes = collectionChanges.changedIndexes,
                        changedIndexes.count != 0 {
                        //collectionView.reloadItems(at: changedIndexes.aapl_indexPathsFromIndexesWithSection(0))
                        DispatchQueue.main.async(execute: {
                            self.collectionView.reloadData()
                        })
                    }
                 

                /*
                }, completion: { (_) -> Void in
                    DispatchQueue.main.async(execute: {
                        if let collection = self.collectionView {
                            collection.reloadData()
                        }
                    })
                })
 */
            }
            
            self.resetCachedAssets()
        }
    }
}

internal extension UICollectionView {
    
    func aapl_indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath] {
        
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElements(in: rect)
        if (allLayoutAttributes?.count ?? 0) == 0 {return []}
        
        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(allLayoutAttributes!.count)
        
        for layoutAttributes in allLayoutAttributes! {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath)
        }
        
        return indexPaths
    }
}

internal extension IndexSet {
    
    func aapl_indexPathsFromIndexesWithSection(_ section: Int) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(self.count)
        (self as NSIndexSet).enumerate({idx, stop in
            indexPaths.append(IndexPath(item: idx, section: section))
        })
        return indexPaths
    }
}

private extension FSAlbumView {
    
    func changeImage(_ asset: PHAsset) {
        
        self.phAsset = asset
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        self.imageManager?.requestImage(for: asset,targetSize: PHImageManagerMaximumSize,contentMode: .aspectFill, options: options) {
            result, info in
            
               DispatchQueue.main.async(execute: {
                self.imageCropView.mode = self.mode
                self.imageCropView.imageToDisplay = result
                 if let result = result, !self.selectedAssets.contains(asset) {
                        self.selectedAssets.append(asset)
                        self.selectedImages.append(result)
                        }
              })
                                            
        }
    }
    // Check the status of authorization for PHPhotoLibrary
    func checkPhotoAuth() {
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            switch status {
            case .authorized:
                self.imageManager = PHCachingImageManager()
                DispatchQueue.main.async {
                    self.delegate?.albumViewCameraRollAuthorized()
                    if let images = self.images, images.count > 0 {
                        self.changeImage(images[images.count-1])
                          self.selectedIndexPath = IndexPath(row: 0, section: 0)
                        if !self.isNewuser && !self.addPost {
                            self.coverLabel.alpha = 1.0
                            self.hideLabelTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.hideLabel), userInfo: nil, repeats: false)
                        }
                        self.album = AlbumModel.init(name: "Camera Roll", count: self.images.count, collection: nil, asset: self.images.lastObject!)
                    }
                     self.collectionView.reloadData()
                }
            case .restricted, .denied:
                DispatchQueue.main.async(execute: { () -> Void in
                    self.delegate?.albumViewCameraRollUnauthorized()
                })
            default:
                break
            }
        }
    }
    // MARK: - Asset Caching
    func resetCachedAssets() {
        imageManager?.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect.zero
    }
    func updateCachedAssets() {
        guard let collectionView = self.collectionView else { return }
        var preheatRect = collectionView.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -0.5 * preheatRect.height)
        let delta = abs(preheatRect.midY - self.previousPreheatRect.midY)
        var numberOfRows:CGFloat = 4.0
        if type == .Cover {
             numberOfRows = 3.0
        }
        if delta > collectionView.bounds.height / numberOfRows {
            var addedIndexPaths: [IndexPath]   = []
            var removedIndexPaths: [IndexPath] = []
            self.computeDifferenceBetweenRect(
                self.previousPreheatRect,
                andRect: preheatRect,
                removedHandler: {removedRect in
                    let indexPaths = self.collectionView.aapl_indexPathsForElementsInRect(removedRect)
                    removedIndexPaths += indexPaths
                
            }, addedHandler: {addedRect in
                let indexPaths = self.collectionView.aapl_indexPathsForElementsInRect(addedRect)
                addedIndexPaths += indexPaths
            })
            let assetsToStartCaching       = self.assetsAtIndexPaths(addedIndexPaths)
            let assetsToStopCaching        = self.assetsAtIndexPaths(removedIndexPaths)
            let options = PHImageRequestOptions()
            options.deliveryMode           = .fastFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous          = false
            DispatchQueue.main.async {
                self.imageManager?.startCachingImages(for: assetsToStartCaching, targetSize: self.cellSize,contentMode: .aspectFill,options: options)
                self.imageManager?.stopCachingImages(for: assetsToStopCaching,  targetSize:self.cellSize, contentMode: .aspectFill, options: options)
            }
            self.previousPreheatRect = preheatRect
        }
    }
    
    func computeDifferenceBetweenRect(_ oldRect: CGRect, andRect newRect: CGRect, removedHandler: (CGRect)->Void, addedHandler: (CGRect)->Void) {
        
        if newRect.intersects(oldRect) {
            
            let oldMaxY = oldRect.maxY
            let oldMinY = oldRect.minY
            let newMaxY = newRect.maxY
            let newMinY = newRect.minY
            
            if newMaxY > oldMaxY {
            
                let rectToAdd = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.size.width, height: (newMaxY - oldMaxY))
                addedHandler(rectToAdd)
            }
            
            if oldMinY > newMinY {
            
                let rectToAdd = CGRect(x: newRect.origin.x, y: newMinY, width: newRect.size.width, height: (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
            
            if newMaxY < oldMaxY {
            
                let rectToRemove = CGRect(x: newRect.origin.x, y: newMaxY, width: newRect.size.width, height: (oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            
            if oldMinY < newMinY {
            
                let rectToRemove = CGRect(x: newRect.origin.x, y: oldMinY, width: newRect.size.width, height: (newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
            
        } else {
            
            addedHandler(newRect)
            removedHandler(oldRect)
        }
    }
    
    func assetsAtIndexPaths(_ indexPaths: [IndexPath]) -> [PHAsset] {
        
        if indexPaths.count == 0 { return [] }
        
        var assets: [PHAsset] = []
        
        assets.reserveCapacity(indexPaths.count)
        
        for indexPath in indexPaths {
        
            let asset = self.images[images.count-((indexPath as NSIndexPath).item+1)]
            assets.append(asset)
            
        }
        
        return assets
    }
    


}
