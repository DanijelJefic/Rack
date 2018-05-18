
//  Itemself.swift
//  Rack
//  Created by saroj  on 10/04/18.
//  Copyright © 2018 Hyperlink. All rights reserved.


import UIKit
import ActiveLabel
class ItemCell: UITableViewCell {
    @IBOutlet weak var containerView : UIView!
    @IBOutlet weak var imgProfile : UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblPostType: UILabel!
    @IBOutlet weak var lblTime    : UILabel!
    @IBOutlet weak var btnDot     : UIButton!
    @IBOutlet weak var imgPost    : UIImageView!
    @IBOutlet weak var btnLikeBig : UIButton!
    @IBOutlet weak var buttonView : UIView!
    @IBOutlet weak var lblLike    : UILabel!
    @IBOutlet weak var btnLike    : UIButton!
    @IBOutlet weak var lblComment : UILabel!
    @IBOutlet weak var btnComment : UIButton!
    @IBOutlet weak var lblRepost  : UILabel!
    @IBOutlet weak var btnRepost  : UIButton!
    @IBOutlet weak var lblWant    : UILabel!
    @IBOutlet weak var btnWant    : UIButton!
    @IBOutlet weak var lblDetail  : ActiveLabel!
    @IBOutlet weak var imgLine    : UIImageView!
    @IBOutlet weak var collectionViewTag: UICollectionView!
    //PostImage Height
    @IBOutlet weak var constImageHeight: NSLayoutConstraint!
    @IBOutlet weak var lineTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var constCollectionHeight: NSLayoutConstraint!

    var pinchGesture = UIPinchGestureRecognizer()
    var panGesture = UIPanGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgProfile.applyStype(cornerRadius: self.imgProfile.frame.size.height  / 2)
        self.lblUserName.applyStyle(labelFont: UIFont.applyArialBold(fontSize: 12.0), labelColor: AppColor.textB)
        self.lblPostType.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0), labelColor: AppColor.textB)
        self.lblTime.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0), labelColor: AppColor.textLightGray)
        self.lblDetail.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 11.0), labelColor: UIColor.black)
        self.lblLike.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 11.0,isAspectRasio: true), labelColor: AppColor.textLightGray)
        self.lblComment.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 11.0,isAspectRasio: true), labelColor: AppColor.textLightGray)
        self.lblRepost.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 11.0,isAspectRasio: true), labelColor: AppColor.textLightGray)
        self.lblWant.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 11.0,isAspectRasio: true), labelColor: AppColor.textB)
        self.btnLikeBig.isHidden = true
        self.collectionViewTag.isHidden = true
    }
    override func setSelected(_ selected: Bool, animated: Bool){
        super.setSelected(selected, animated: animated)

    }
    
    func configureCell(dictFromParent:ItemModel, controller : RackDetailVC) {

            self.collectionViewTag.delegate   = controller
            self.collectionViewTag.dataSource = controller
        
            for  _ in self.subviews {
                //subView.gestureRecognizers?.removeAll()
            }
            //singletap configuration for profileview
            var profileViewGesture = UITapGestureRecognizer()
            profileViewGesture = UITapGestureRecognizer(target: controller, action: #selector(RackDetailVC.profileViewSingleTap(_:)))
            profileViewGesture.numberOfTapsRequired = 1
            profileViewGesture.numberOfTouchesRequired = 1
            self.imgProfile.addGestureRecognizer(profileViewGesture)
            self.imgProfile.isUserInteractionEnabled = true
            
            var usernameGesture = UITapGestureRecognizer()
            usernameGesture = UITapGestureRecognizer(target: controller, action: #selector(RackDetailVC.profileViewSingleTap(_:)))
            usernameGesture.numberOfTapsRequired = 1
            usernameGesture.numberOfTouchesRequired = 1
            self.lblUserName.addGestureRecognizer(usernameGesture)
            self.lblUserName.isUserInteractionEnabled = true
            
            //singletap configuration for likelabel
            let likeLabelGesture = UITapGestureRecognizer(target: controller, action: #selector(RackDetailVC.likeLabelSingleTap(_:)))
            likeLabelGesture.numberOfTapsRequired = 1
            likeLabelGesture.numberOfTouchesRequired = 1
            self.lblLike.addGestureRecognizer(likeLabelGesture)
            self.lblLike.isUserInteractionEnabled = true
            
            let repostLabelGesture = UITapGestureRecognizer(target: controller, action: #selector(RackDetailVC.repostLabelSingleTap(_:)))
            repostLabelGesture.numberOfTapsRequired = 1
            repostLabelGesture.numberOfTouchesRequired = 1
            self.lblRepost.addGestureRecognizer(repostLabelGesture)
            self.lblRepost.isUserInteractionEnabled = true
            
            //singletap configuration
            let singleTapGesture = UITapGestureRecognizer(target: controller, action: #selector(RackDetailVC.imagePostSingleTap(_:)))
            singleTapGesture.numberOfTapsRequired = 1
            singleTapGesture.numberOfTouchesRequired = 1
            self.imgPost.addGestureRecognizer(singleTapGesture)
            self.imgPost.isUserInteractionEnabled = true
            
            //doubletap configuration
            let  doubleTapGesture = UITapGestureRecognizer(target: controller, action: #selector(RackDetailVC.imagePostDoubleTap(_:)))
            doubleTapGesture.numberOfTapsRequired = 2
            doubleTapGesture.numberOfTouchesRequired = 1
            self.imgPost.addGestureRecognizer(doubleTapGesture)
            self.imgPost.isUserInteractionEnabled = true
            
            //pinchGesture Configuration
           self.pinchGesture = UIPinchGestureRecognizer(target: controller, action: #selector(RackDetailVC.imagePostPinchGesture(_:)))
            self.imgPost.addGestureRecognizer(self.pinchGesture)
            self.imgPost.isUserInteractionEnabled = true
            self.pinchGesture.scale = 1
            self.pinchGesture.delegate = controller
            // pinchGesture .require(toFail: )
            
            //pan gesture configuration
            self.panGesture = UIPanGestureRecognizer(target: controller, action: #selector(RackDetailVC.imagePostPanGesture(sender:)))
            self.panGesture.delegate = controller
            self.imgPost.addGestureRecognizer(self.panGesture)
            
            //fail single when double tap perform
            singleTapGesture .require(toFail: doubleTapGesture)
            //data setup
            self.imgProfile.setImageWithDownload(dictFromParent.getUserProfile().url())
            self.lblUserName.text = dictFromParent.getUserName()
            
            if let rackName = dictFromParent.rackData.rackName {
                self.lblPostType.text = "\(rackName)"
                
                let tapGesture = UITapGestureRecognizer(target: controller, action: #selector(RackDetailVC.tapOnRackName(_:)))
                tapGesture.numberOfTapsRequired = 1
                tapGesture.numberOfTouchesRequired = 1
                self.lblPostType.addGestureRecognizer(tapGesture)
                self.lblPostType.isUserInteractionEnabled = true
            }
            self.lblTime.text = dictFromParent.calculatePostTime()
            if dictFromParent.caption.count > 0 {
                self.lblDetail.text = "\(dictFromParent.getUserName()) \(dictFromParent.caption!)"
            }else {
                self.lblDetail.text = ""
            }
            self.lineTopConstraint.constant = 9.0
            self.lblDetail.isHidden = false
            if dictFromParent.caption.count == 0 {
                self.lblDetail.isHidden = true
                self.lineTopConstraint.constant = -14.0
            }
            self.btnDot.addTarget(controller, action: #selector(RackDetailVC.btnPostDotClicked(_:)), for: .touchUpInside)
            self.lblLike.text = GFunction.shared.getProfileCount(dictFromParent.likeCount)
            self.lblComment.text = GFunction.shared.getProfileCount(dictFromParent.commentCount)
            self.lblRepost.text = GFunction.shared.getProfileCount(dictFromParent.repostCount)
            
            /*
             //1. Tableview stucking issue. So solve out using image height constant.
             //        imgPost.image = (dictFromParent["img"] as! UIImage).imageScale(scaledToWidth: kScreenWidth)
             */
            //Manage using height constant.
            
            let width  : Float = Float(dictFromParent.width)!
            let height : Float = Float(dictFromParent.height)!
            //constImageHeight.constant = kScreenWidth / CGFloat(width) * CGFloat(height)
            
            let heightConstant = kScreenWidth / CGFloat(width) * CGFloat(height)
            
            if Float(heightConstant) > Float(kScreenHeight - 108) {
                self.constImageHeight.constant = kScreenWidth
                self.imgPost.contentMode = .scaleAspectFill
            } else {
                self.constImageHeight.constant = kScreenWidth / CGFloat(width) * CGFloat(height)
                self.imgPost.contentMode = .scaleToFill
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.imgPost.setImageWithDownload(dictFromParent.image.url())
            }
            
            self.imgPost.clipsToBounds = true
            self.lblDetail.numberOfLines = 0
            
            controller.setUpDetailText(self.lblDetail, userName : dictFromParent.caption.count > 0 ? dictFromParent.getUserName() : "", obj: dictFromParent)
            
            self.btnLike.isSelected = dictFromParent.loginUserLike
            
            if self.btnLike.isSelected {
                self.btnLike.tintColor = .red
            }else{
                self.btnLike.tintColor = .black
            }
            
            self.btnComment.isSelected = dictFromParent.loginUserComment
            
            //want button state management
            self.btnWant.isSelected = dictFromParent.loginUserWant
            
            //repost button state management
            self.btnRepost.isSelected = dictFromParent.loginUserRepost
            
            //1. owner's user item, dont show repost button
            //2. from ws if repost = no, dont show repost button
            if dictFromParent.userId != UserModel.currentUser.userId {
                if dictFromParent.repost == "yes" {
                    self.btnRepost.isUserInteractionEnabled = true
                    self.btnRepost.tintColor = UIColor.colorFromHex(hex: kColorLightGray)
                } else {
                    self.btnRepost.isUserInteractionEnabled = false
                    self.btnRepost.tintColor = UIColor.colorFromHex(hex: kColorLightGray)
                }
            }else{
                self.btnRepost.isUserInteractionEnabled = false
                self.btnRepost.tintColor = UIColor.colorFromHex(hex: kColorLightGray)
            }
            
            //want button state management
            //1. owner's user item, dont show want button
            if dictFromParent.userId == UserModel.currentUser.userId {
                self.btnWant.isHidden = true
                self.lblWant.isHidden = true
            } else {
                self.btnWant.isHidden = false
                self.lblWant.isHidden = false
            }
        self.btnRepost.addTarget(controller, action: #selector(RackDetailVC.btnRepostClicked(_:)), for: .touchUpInside)
        self.btnLike.addTarget(controller, action: #selector(RackDetailVC.btnLikeClicked(_:)), for: .touchUpInside)
        self.btnComment.addTarget(controller, action: #selector(RackDetailVC.btnCommentClicked(_:)), for: .touchUpInside)
        self.btnWant.addTarget(controller, action: #selector(RackDetailVC.btnWantClicked(_:)), for: .touchUpInside)
        
           controller.arrayTagType = controller.arrayTagType.filter({ (objTag : Dictionary<String, Any>) -> Bool in
                let detail = (dictFromParent.tagDetail!).toDictionary()
                return detail[(objTag[kAction] as! TagType).rawValue] != nil && (detail[(objTag[kAction] as! TagType).rawValue] as! [Dictionary<String, Any>]).count > 0
            })
            
            if dictFromParent.userId != dictFromParent.ownerUid {
                controller.arrayTagType.insert(["img" : #imageLiteral(resourceName: "iconUserPost") ,kAction : TagType.none], at: 0)
            }
            //CollectionView Height Management. if User tag option will be dynamic.For Now its static if dyanamic then uncomment following code.
            let collectionHeight = (controller.arrayTagType.count * controller.collectionCellHeight) //+ ((arrayTagType.count - 1) * collectionCellSpacing)
            self.constCollectionHeight.constant = CGFloat(collectionHeight)
            
            self.collectionViewTag.isHidden = false
            self.imgLine.layoutIfNeeded()
            self.containerView.layoutIfNeeded()
        
            // add spacing between characters
            let valueCharSpace: CGFloat = 0.5
            self.lblUserName.addCharacterSpacing(value: valueCharSpace)
            self.lblPostType.addCharacterSpacing(value: valueCharSpace)
            self.lblTime.addCharacterSpacing(value: valueCharSpace)
            self.lblLike.addCharacterSpacing(value: valueCharSpace)
            self.lblComment.addCharacterSpacing(value: valueCharSpace)
            self.lblRepost.addCharacterSpacing(value: valueCharSpace)
            self.lblDetail.addCharacterSpacing(value: valueCharSpace)
         NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.autoHideTagCollectionOptionView), object: nil)
         self.perform(#selector(self.autoHideTagCollectionOptionView), with: nil, afterDelay: 5.0)
        
   }
    
    func autoHideTagCollectionOptionView() {
            self.collectionViewTag.alpha = 1.0
            UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveLinear, animations: {
                self.collectionViewTag.alpha = 0.0
                
            }, completion: { (isComplete : Bool) in
                self.collectionViewTag.isHidden = true
                self.collectionViewTag.alpha = 1.0
            })
    }
  }

extension RackRepostCell {
    
    func configureCell(item : ItemModel,viewController: RackDetailVC) {
        self.static_containerView.backgroundColor = .white
        self.lblUserName.text = item.getUserName()
        if let rackName = item.rackData.rackName {
            self.lblPostType.text = "\(rackName)"
        }
        let str = item.caption.count > 0 ? "\(item.caption!)" : ""
        self.lblDetail.text = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let tapGesture = UITapGestureRecognizer(target: viewController, action: #selector(RackDetailVC.profileViewSingleTap(_:)))
        self.lblUserName.isUserInteractionEnabled = true
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.lblUserName.addGestureRecognizer(tapGesture)
        //comment lable click management. Hast Tag , UserName and mentioned user
        self.lblDetail.numberOfLines = 0
        viewController.setUpDetailText(self.lblDetail,userName : item.caption.count > 0 ? item.getUserName() : "", obj : item)
        
        if item.caption.count == 0 {
            self.lblDetail.isHidden = true
            self.constLblDetailHeight.constant = 0
            self.staticContainerYPos.constant = 0
        } else {
            let lblHeight = self.lblDetail.text!.getHeight(withConstrainedWidth: (kScreenWidth-18), font: UIFont.applyBold(fontSize: 12.0))
            self.constLblDetailHeight.constant = lblHeight
            self.lblDetail.isHidden = false
            self.staticContainerYPos.constant = 8
        }
        
        self.lblTime.text = item.calculatePostTime()
        self.btnDot.addTarget(viewController, action: #selector(RackDetailVC.btnPostDotClicked(_:)), for: .touchUpInside)
        
        // add spacing between characters
        let valueCharSpace: CGFloat = 0.5
        self.lblUserName.addCharacterSpacing(value: valueCharSpace)
        self.lblPostType.addCharacterSpacing(value: valueCharSpace)
        self.lblTime.addCharacterSpacing(value: valueCharSpace)
        
        if let staticObjAtIndex = item.parentItem {
            guard staticObjAtIndex.profile != nil else {
                return
            }
            self.static_lblUserName.text = staticObjAtIndex.getUserName()
            if let rackName = staticObjAtIndex.rackData.rackName {
                self.static_lblPostType.text = "\(rackName)"
            }
        self.static_imgPost.setImageWithDownload(staticObjAtIndex.image.url()/*, itemData : objAtIndex*/)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.static_imgProfile.setImageWithDownload(staticObjAtIndex.profile.url())
            })
        self.static_lblTime.text = staticObjAtIndex.calculatePostTime()
            self.selectionStyle = .none
            //Manage using height constant.
            let width  : Float = Float(item.width)!
            let height : Float = Float(item.height)!
            let heightConstant = kScreenWidth / CGFloat(width) * CGFloat(height)
            if Float(heightConstant) > Float(kScreenHeight - 108) {
                self.static_constImageHeight.constant = kScreenWidth
                self.static_imgPost.contentMode = .scaleAspectFill
            } else {
                self.static_constImageHeight.constant = kScreenWidth / CGFloat(width) * CGFloat(height)
                self.static_imgPost.contentMode = .scaleToFill
            }
            let str = staticObjAtIndex.caption.count > 0 ? "\(staticObjAtIndex.getUserName()) \(staticObjAtIndex.caption!)" : ""
            self.static_lblDetail.text = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.static_lblDetail.numberOfLines = 0
          viewController.setUpDetailText(self.static_lblDetail,userName : staticObjAtIndex.caption.count > 0 ? staticObjAtIndex.getUserName() : "", obj : staticObjAtIndex)
            if staticObjAtIndex.caption.count == 0 {
                self.static_lblDetail.isHidden = true
                self.static_constLblDetailYPos.constant = 0
                self.static_constLblDetailHeight.constant = 0
            } else {
                let lblHeight = self.static_lblDetail.text!.getHeight(withConstrainedWidth: (kScreenWidth-18), font: UIFont.applyBold(fontSize: 12.0))
                self.static_constLblDetailHeight.constant = lblHeight
                self.static_lblDetail.isHidden = false
                self.static_constLblDetailYPos.constant = 8
            }
            //like button state management
            self.static_btnLike.isSelected = staticObjAtIndex.loginUserLike
            if self.static_btnLike.isSelected {
                self.static_btnLike.tintColor = .red
            }else{
                self.static_btnLike.tintColor = .black
            }
            self.static_btnComment.isSelected = staticObjAtIndex.loginUserComment
            self.static_btnWant.isSelected = staticObjAtIndex.loginUserWant
            self.static_btnRepost.isSelected = staticObjAtIndex.loginUserRepost
            if staticObjAtIndex.userId == UserModel.currentUser.userId {
                self.static_btnWant.isHidden = true
            } else {
                self.static_btnWant.isHidden = false
            }
            if item.userId != UserModel.currentUser.userId {
                self.static_btnRepost.isUserInteractionEnabled = true
            }else{
                self.static_btnRepost.isUserInteractionEnabled = false
            }
            self.static_btnRepost.tintColor = UIColor.colorFromHex(hex: kColorLightGray)
            self.static_btnLikeBig.isHidden = true
            self.static_lblLike.text = GFunction.shared.getProfileCount(staticObjAtIndex.likeCount)
            self.static_lblComment.text = GFunction.shared.getProfileCount(staticObjAtIndex.commentCount)
            self.static_lblRepost.text = GFunction.shared.getProfileCount(staticObjAtIndex.repostCount)
            self.static_btnLike.addTarget(viewController, action: #selector(RackDetailVC.btnLikeClicked(_:)), for: .touchUpInside)
            self.static_btnComment.addTarget(viewController, action: #selector(RackDetailVC.btnCommentClicked(_:)), for: .touchUpInside)
            self.static_btnRepost.addTarget(viewController, action: #selector(RackDetailVC.btnRepostClicked(_:)), for: .touchUpInside)
            self.static_btnWant.addTarget(viewController, action: #selector(RackDetailVC.btnWantClicked(_:)), for: .touchUpInside)
    
            // add spacing between characters
            let valueCharSpace: CGFloat = 0.5
            self.static_lblUserName.addCharacterSpacing(value: valueCharSpace)
            self.static_lblPostType.addCharacterSpacing(value: valueCharSpace)
            self.static_lblTime.addCharacterSpacing(value: valueCharSpace)
            self.static_lblLike.addCharacterSpacing(value: valueCharSpace)
            self.static_lblComment.addCharacterSpacing(value: valueCharSpace)
            self.static_lblRepost.addCharacterSpacing(value: valueCharSpace)
            self.static_lblDetail.addCharacterSpacing(value: valueCharSpace)
        }
     
            self.lblPostType.removeGestureRecognizer(self.lblPostTypeGesture)
            self.static_lblPostType.removeGestureRecognizer(self.static_lblPostTypeGesture)
            self.static_imgProfile.removeGestureRecognizer(self.static_imgProfileGesture)
            self.static_imgPost.removeGestureRecognizer(self.singleTapGesture)
            self.static_imgPost.removeGestureRecognizer(self.doubleTapGesture)
            self.static_imgPost.removeGestureRecognizer(self.pinchGesture)
            self.static_imgPost.removeGestureRecognizer(self.panGesture)
            self.lblPostTypeGesture = UITapGestureRecognizer(target: viewController, action: #selector(RackDetailVC.tapOnRackName(_:)))
            self.lblPostTypeGesture.numberOfTapsRequired = 1
            self.lblPostTypeGesture.numberOfTouchesRequired = 1
            self.lblPostType.addGestureRecognizer(self.lblPostTypeGesture)
            self.lblPostType.isUserInteractionEnabled = true
        
            //singletap configuration for profileview
            self.static_usernameGesture = UITapGestureRecognizer(target: viewController, action: #selector(RackDetailVC.profileViewSingleTap(_:)))
            self.static_usernameGesture.numberOfTapsRequired = 1
            self.static_usernameGesture.numberOfTouchesRequired = 1
            self.static_lblUserName.addGestureRecognizer(self.static_usernameGesture)
            self.static_lblUserName.isUserInteractionEnabled = true
            
        
            
            //singletap configuration for likelabel
            self.static_likeLabelGesture = UITapGestureRecognizer(target: viewController, action: #selector(RackDetailVC.likeLabelSingleTap(_:)))
            self.static_likeLabelGesture.numberOfTapsRequired = 1
            self.static_likeLabelGesture.numberOfTouchesRequired = 1
            self.static_lblLike.addGestureRecognizer(self.static_likeLabelGesture)
            self.static_lblLike.isUserInteractionEnabled = true
        
            
            
            //singletap configuration for likelabel
            self.static_repostLabelGesture = UITapGestureRecognizer(target: viewController, action: #selector(RackDetailVC.repostLabelSingleTap(_:)))
            self.static_repostLabelGesture.numberOfTapsRequired = 1
            self.static_repostLabelGesture.numberOfTouchesRequired = 1
            self.static_lblRepost.addGestureRecognizer(self.static_repostLabelGesture)
            self.static_lblRepost.isUserInteractionEnabled = true

            self.static_imgProfileGesture = UITapGestureRecognizer(target: viewController, action: #selector(RackDetailVC.profileViewSingleTap(_:)))
            self.static_imgProfileGesture.numberOfTapsRequired = 1
            self.static_imgProfileGesture.numberOfTouchesRequired = 1
            self.static_imgProfile.addGestureRecognizer(self.static_imgProfileGesture)
            self.static_imgProfile.isUserInteractionEnabled = true
        
            self.static_lblPostTypeGesture = UITapGestureRecognizer(target: viewController, action: #selector(RackDetailVC.tapOnRackName(_:)))
            self.static_lblPostTypeGesture.numberOfTapsRequired = 1
            self.static_lblPostTypeGesture.numberOfTouchesRequired = 1
            self.static_lblPostType.addGestureRecognizer(self.static_lblPostTypeGesture)
            self.static_lblPostType.isUserInteractionEnabled = true
        
            //singletap configuration
            self.singleTapGesture = UITapGestureRecognizer(target: viewController, action: #selector(RackDetailVC.imagePostSingleTap(_:)))
            self.singleTapGesture.numberOfTapsRequired = 1
            self.singleTapGesture.numberOfTouchesRequired = 1
            self.static_imgPost.addGestureRecognizer(self.singleTapGesture)
            self.static_imgPost.isUserInteractionEnabled = true

            //doubletap configuration
            self.doubleTapGesture = UITapGestureRecognizer(target: viewController, action: #selector(RackDetailVC.imagePostDoubleTap(_:)))
            self.doubleTapGesture.numberOfTapsRequired = 2
            self.doubleTapGesture.numberOfTouchesRequired = 1
            self.static_imgPost.addGestureRecognizer(self.doubleTapGesture)
            self.static_imgPost.isUserInteractionEnabled = true
    
            //fail single when double tap perform
            self.singleTapGesture .require(toFail: self.doubleTapGesture)
            
            //pinchGesture Configuration
            self.pinchGesture = UIPinchGestureRecognizer(target: viewController, action: #selector(RackDetailVC.imagePostPinchGesture(_:)))
            self.pinchGesture.delegate = self
            self.static_imgPost.addGestureRecognizer(self.pinchGesture)
            self.static_imgPost.isUserInteractionEnabled = true
            self.pinchGesture.scale = 1
        
            self.panGesture = UIPanGestureRecognizer(target: viewController, action: #selector(RackDetailVC.imagePostPanGesture(sender:)))
            self.panGesture.delegate = viewController
            self.static_imgPost.addGestureRecognizer(self.panGesture)
            
      
    }
  
}



