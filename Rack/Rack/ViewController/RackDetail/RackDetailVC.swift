//
//  RackDetailVC.swift
//  Rack
//
//  Created by hyperlink on 30/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import ActiveLabel
import FBSDKCoreKit
import FBSDKLoginKit

class RackDetailVC: UIViewController {
    
    enum RackCellType : String {
        case normalCell
        case multiImageCell
        case repostCell
    }
    
    typealias cellType = RackCellType
    var isEditComplete =  Bool()
    
    //MARK:- Outlet
    
    @IBOutlet weak var tblComment: UITableView!
    //------------------------------------------------------
    //MARK:- Class Variable
    var arrayTagType :[Dictionary<String,Any>] = {
        var array = [Dictionary<String,Any>]()
        array.append(["img" : #imageLiteral(resourceName: "iconUserPost") ,kAction : TagType.none])
        array.append(["img" : #imageLiteral(resourceName: "iconTag") ,kAction : TagType.tagBrand])
        array.append(["img" : #imageLiteral(resourceName: "iconProdTag") ,kAction : TagType.tagItem])
        array.append(["img" : #imageLiteral(resourceName: "iconUserTag") ,kAction : TagType.tagPeople])
        array.append(["img" : #imageLiteral(resourceName: "iconAddLink") ,kAction : TagType.addLink])
        return array
    }()
    
    //To manage dyanamic hegith width for tag collectionView
    let collectionCellHeight                = 30
    let collectionCellSpacing               = 5
    var dictFromParent : ItemModel          = ItemModel()
    var static_dictFromParent : ItemModel   = ItemModel()
    var rackFolderCount: Int                = Int()
    var isRackFolder: Bool = false
    var copyDictFromParent : ItemModel      = ItemModel()
    var likeLabelGesture                    = UITapGestureRecognizer()
    var isPullCalled                        = Bool()
    var arraySocialKeys : [Dictionary<String , Dictionary<String,Any>>] = []
    var _cellType:cellType!
    
    //------------------------------------------------------
    func tapOnRackName(_ tapgesture: UITapGestureRecognizer) {
        
        let objRackFolderListVC = secondStoryBoard.instantiateViewController(withIdentifier: "RackFolderListVC") as! RackFolderListVC
        if _cellType == .normalCell {
            objRackFolderListVC.userData = UserModel(fromJson: JSON(dictFromParent.toDictionary()))
            if dictFromParent.userId == UserModel.currentUser.userId {
                objRackFolderListVC.viewType = .me
            } else {
                objRackFolderListVC.viewType = .other
            }
            objRackFolderListVC.dictFromParent = dictFromParent.rackData
        }else{
            let indexPath = IndexPath(row: 0, section: 0)
            guard let cell = tblComment.cellForRow(at: indexPath) as? RackRepostCell else {
                return
            }
            
            if tapgesture == cell.lblPostTypeGesture {
                objRackFolderListVC.userData = UserModel(fromJson: JSON(dictFromParent.toDictionary()))
                if dictFromParent.userId == UserModel.currentUser.userId {
                    objRackFolderListVC.viewType = .me
                } else {
                    objRackFolderListVC.viewType = .other
                }
                objRackFolderListVC.dictFromParent = dictFromParent.rackData
            }else{
                objRackFolderListVC.userData = UserModel(fromJson: JSON(dictFromParent.parentItem.toDictionary()))
                if dictFromParent.parentItem.userId == UserModel.currentUser.userId {
                    objRackFolderListVC.viewType = .me
                } else {
                    objRackFolderListVC.viewType = .other
                }
                objRackFolderListVC.dictFromParent = dictFromParent.parentItem.rackData
            }
        }
   self.navigationController?.pushViewController(objRackFolderListVC, animated: true)
        
    }
    
    func btnPostDotClicked(_ sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: 0)

        if _cellType == .normalCell {
            
            guard let cell = tblComment.cellForRow(at: indexPath) as? ItemCell else {
                return
            }
        
            guard cell.imgPost.image != nil && cell.imgPost.image!.size != CGSize.zero else {
                return
            }
            self.dotButtonClicked(dictFromParent: dictFromParent, imgPost: cell.imgPost.image!, imgProfile: UIImage(), isRepost: false,cell: cell)
        }else{
            
            guard let cell = tblComment.cellForRow(at: indexPath) as? RackRepostCell else {
                return
            }
            
            guard cell.static_imgPost.image != nil && cell.static_imgPost.image!.size != CGSize.zero else {
                return
            }
            
            guard cell.static_imgProfile.image != nil && cell.static_imgProfile.image!.size != CGSize.zero else {
                return
            }
            
            self.dotButtonClicked(dictFromParent: dictFromParent, imgPost: cell.static_imgPost.image!, imgProfile: cell.static_imgProfile.image!, isRepost: true, cell:ItemCell())
            
        }
        
    }
    
    func dotButtonClicked(dictFromParent: ItemModel, imgPost: UIImage, imgProfile: UIImage, isRepost: Bool,cell : AnyObject) {
        let indexPath = IndexPath(row: 0, section: 0)
        if dictFromParent.userId == UserModel.currentUser.userId {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionDelete = UIAlertAction(title: "Delete Post", style: .default) { (action : UIAlertAction) in
                AlertManager.shared.showAlertTitle(title: "", message: "Delete this post? This cannot be undone.", buttonsArray: ["Delete","Cancel"]) { (buttonIndex : Int) in
                    switch buttonIndex {
                    case 0 :
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailDelete), object: self.dictFromParent)
                        let requestModel = RequestModel()
                        requestModel.item_id = self.dictFromParent.itemId
                        var objAtIndex = ItemModel()
                        if self._cellType == .normalCell {
                            guard let itemCell = self.tblComment.cellForRow(at: indexPath) as? ItemCell else {
                                return
                            }
                            if itemCell.btnWant.isSelected {
                                self.dictFromParent.loginUserWant = false
                            }
                            objAtIndex = dictFromParent
                        }else{
                            guard let cell = self.tblComment.cellForRow(at: indexPath) as? RackRepostCell else {
                                return
                             }
                            if cell.static_btnWant.isSelected {
                              self.dictFromParent.parentItem.loginUserWant = false
                            }
                            objAtIndex = dictFromParent.parentItem
                        }
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: objAtIndex)

                        
                        self.callDeleteItemAPI(requestModel, withCompletion: { (isSuccess : Bool) in
                            if isSuccess {
                                
                            }
                        })
                        break
                    case 1:
                        
                        break
                    default :
                        break
                    }
                }
            }
            
            let actionEdit = UIAlertAction(title: "Edit Post", style: .default) { (action : UIAlertAction) in
                if isRepost {
                    
                    if dictFromParent.caption.isEmpty {
                        let obj = secondStoryBoard.instantiateViewController(withIdentifier: "QuickRepostVC") as! QuickRepostVC
                        obj._imgPost = imgPost
                        obj._tvCaptionText = dictFromParent.parentItem.caption
                        obj.rackName = dictFromParent.parentItem.rackData.rackName
                        obj._dictFromParent = dictFromParent
                        obj.isEdit = true
                        obj.editCompletion = {
                            self.isEditComplete = true
                        }
                        
                        let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
                        navigationController.navigationBar.barStyle = .default
                        self.present(navigationController, animated: true, completion: nil)
                        
                    }else{
                        let obj = secondStoryBoard.instantiateViewController(withIdentifier: "RepostAddCaptionVC") as! RepostAddCaptionVC
                        obj._imgPost = imgPost
                        obj._postUserProfile = imgProfile
                        obj._postUsername = dictFromParent.parentItem.getUserName()
                        obj._postType = dictFromParent.parentItem.rackData.rackName
                        obj._tvCaptionText = dictFromParent.parentItem.caption
                        obj._dictFromParent = dictFromParent
                        obj.isEdit = true
                        obj.editCompletion = {
                            self.isEditComplete = true
                        }
                        
                        let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
                        navigationController.navigationBar.barStyle = .default
                        self.present(navigationController, animated: true, completion: nil)
                    }
                    
                }else{
                    let obj = secondStoryBoard.instantiateViewController(withIdentifier: "UploadVC") as! UploadVC
                    obj.imgPost        = imgPost
                    obj.dictFromParent = dictFromParent
                    obj.selectedCategories.add(dictFromParent.rackCategory)
                    obj.shareType      = .main
                    obj.editCompletion = {
                        self.isEditComplete = true
                    }
                    
                    let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
                    navigationController.navigationBar.barStyle = .default
                    self.present(navigationController, animated: true, completion: nil)
                }
                
            }
            
            let actionShare = UIAlertAction(title: "Share on Facebook", style: .default) { (action : UIAlertAction) in
                let loginManager : FBSDKLoginManager = FBSDKLoginManager()
                loginManager.logOut()
                loginManager.logIn(withPublishPermissions: ["publish_actions"], from: self) { (result, error) in
                    if (error == nil) {
                        let fbloginresult : FBSDKLoginManagerLoginResult = result!
                        if (fbloginresult.grantedPermissions != nil) {
                            if(fbloginresult.grantedPermissions.contains("publish_actions")) {
                                let fbAccessToken = FBSDKAccessToken.current().tokenString
                                self.arraySocialKeys = []
                                self.arraySocialKeys.append(["facebook" : ["access_token" : fbAccessToken!]])
                                let requestModel = RequestModel()
                                requestModel.item_id = self.dictFromParent.itemId
                                requestModel.social_keys = JSON(self.arraySocialKeys)
                                self.callItemSharingAPI(requestModel)
                            } else {
                                //   AlertManager.shared.showAlertTitle(title: "Facebook Error"
                                //     ,message: "Publish action not granted.")
                            }
                        }
                    }
                }
                
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                
            }
            actionSheet.addAction(actionDelete)
            actionSheet.addAction(actionEdit)
            actionSheet.addAction(actionShare)
            actionSheet.addAction(actionCancel)
            self.present(actionSheet, animated: true, completion: nil)
            
        } else {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let actionReport = UIAlertAction(title: "Report Post", style: .default) { (action : UIAlertAction) in
                
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
                vc.reportId = self.dictFromParent.itemId
                vc.reportType = .item
                vc.offenderId = self.dictFromParent.userId
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                
            }
            actionSheet.addAction(actionReport)
            actionSheet.addAction(actionCancel)
            self.present(actionSheet, animated: true, completion: nil)
        }
        
    }
    
    func setUpData() {
        //setup for autoPullTorefresh and paggination
        self.setupPullToRefresh()
        self.perform(#selector(self.addLoaderWithDelay), with: nil, afterDelay: 0.2)
    }
    
    func addLoaderWithDelay() {
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.tblComment.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.tblComment.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
        
        self.tblComment.ins_beginPullToRefresh()
    }
    
    func setUpDetailText(_ lblDetail : ActiveLabel, userName : String, obj : Any) {
        /*
         \b - consider full word
         ^ - starting with username
         */
        let customType1 = ActiveType.custom(pattern: "^(\\b)\(userName)(\\b)")
        let customType2 = ActiveLabel.CustomActiveTypes.hashtag
        let customTypeMention = ActiveLabel.CustomActiveTypes.mention
        
        lblDetail.enabledTypes = [customType1, .mention, customType2, customTypeMention]
        
        lblDetail.customize { (label : ActiveLabel) in
            
            label.customColor[customType1] = AppColor.textB
            
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var attribute = attributes
                switch type {
                    
                case customType1, customTypeMention, .mention :
                    attribute[NSFontAttributeName] = UIFont.applyBold(fontSize: 11.0)
                    attribute[NSForegroundColorAttributeName] = AppColor.textB
                    break
                case customType2 :
                    attribute[NSFontAttributeName] = UIFont.applyRegular(fontSize: 11.0)
                    attribute[NSForegroundColorAttributeName] = AppColor.textB
                    break
                case .hashtag :
                    attribute[NSFontAttributeName] = UIFont.applyRegular(fontSize: 11.0)
                    attribute[NSForegroundColorAttributeName] = AppColor.textB
                    break
                default: ()
                }
                return attribute
            }
            
            
            label.handleCustomTap(for: customType1) {
                let objData = ["user_name" : $0]
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                vc.userData = UserModel(fromJson: JSON(objData))
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            label.handleCustomTap(for: customType2) {
                let objAtIndex = ["name" : $0.replacingOccurrences(of: "#", with: "")]
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchDetailVC") as! SearchDetailVC
                vc.searchFlagType = searchFlagType.hashtag.rawValue
                vc.searchData = SearchText(fromJson: JSON(objAtIndex))
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            label.handleHashtagTap({ ( str : String) in
                
            })
            
            label.handleMentionTap({ (str : String) in
                let objData = ["user_name" : str]
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                vc.userData = UserModel(fromJson: JSON(objData))
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
        
    }
    func setupPullToRefresh() {
        self.tblComment.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
            let requestModel = RequestModel()
            requestModel.item_id = self.dictFromParent.itemId
            //call API for bottom data
            self.callItemDetailListAPI(requestModel,
            withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                        
                                        //stop pagination
                                        self.tblComment.ins_endPullToRefresh()
                                        
                                        if isSuccess {
                                            
                                            self.dictFromParent = ItemModel(fromJson: jsonResponse)
                                            self.dictFromParent.commentData = ItemModel(fromJson: jsonResponse).commentData.reversed()
                                                if !self.isPullCalled {
                                                UIView.animate(withDuration: 0.0, animations: {
                                                    DispatchQueue.main.async {
                                                        self.tblComment.reloadData()
                                                    }
                                                }, completion: { (Bool) in
                                                    self.tblComment.isHidden = false
                                                })
                                            }
                                            self._cellType = RackCellType(rawValue: self.dictFromParent.rackCell)
                                            

                                            
                                            if self._cellType != .normalCell {
                                                self.isPullCalled = true
                                            }
                                            
                                        } else {
                                            
                                        }
            })
        }
        
    }
    
    func profileViewSingleTap(_ sender : UITapGestureRecognizer) {
        let indexPath = IndexPath(row: 0, section: 0)
        let objProfileVC = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        objProfileVC.viewType = .other
        objProfileVC.fromPage = .otherPage
        if _cellType == .normalCell {
            objProfileVC.userData = UserModel(fromJson: JSON(dictFromParent.toDictionary()))
        }else{
            
            guard let cell = tblComment.cellForRow(at: indexPath) as? RackRepostCell else {
                return
            }
            
            if sender == cell.static_imgProfileGesture || sender == cell.static_usernameGesture {
                objProfileVC.userData = UserModel(fromJson: JSON(dictFromParent.parentItem.toDictionary()))
            }else{
                objProfileVC.userData = UserModel(fromJson: JSON(dictFromParent.toDictionary()))
            }
        }
        self.navigationController?.pushViewController(objProfileVC, animated: true)
        
    }
    
    func imagePostSingleTap(_ sender : UITapGestureRecognizer) {
        /*
         cancelPreviousPerformRequests -
         */
        
        let indexPath = IndexPath(row: 0, section: 0)
        guard let cell = tblComment.cellForRow(at: indexPath) as? ItemCell else {
            return
        }
        
      NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.autoHideTagCollectionOptionView), object: nil)
        if _cellType == .normalCell {
            cell.removeAllPSTagView()
            cell.collectionViewTag.isHidden = !cell.collectionViewTag.isHidden
        }
    }
    
    func imagePostDoubleTap(_ sender : UITapGestureRecognizer) {
        let indexPath = IndexPath(row: 0, section: 0)
        if _cellType == .normalCell {
            guard let cell = tblComment.cellForRow(at: indexPath) as? ItemCell else {
                return
            }
            let bigHeart = UIButton(frame: cell.btnLikeBig.frame)
                bigHeart.setImage(#imageLiteral(resourceName: "btnLikeBig"), for: .normal)
                bigHeart.tintColor = .red
                cell.contentView.addSubview(bigHeart)
                
                let tapLocation = sender.location(in: cell.contentView)
                let maxX = cell.imgPost.frame.size.width
                let minX = maxX - bigHeart.frame.size.width
                let tapX = tapLocation.x
                
                if tapX > minX {
                    bigHeart.frame.origin = CGPoint(x: minX, y: tapLocation.y - bigHeart.frame.size.width)
                }else if tapX < bigHeart.frame.size.height {
                    bigHeart.frame.origin = CGPoint(x: 0, y: tapLocation.y - bigHeart.frame.size.height)
                }else{
                    bigHeart.frame.origin = CGPoint(x: tapLocation.x, y: tapLocation.y - bigHeart.frame.size.height)
                    bigHeart.center.x = tapLocation.x
                }
          
            UIView.animate(withDuration: 0.7, animations: {
                
                cell.btnLike.scaleAnimation(0.15, scale: -0.05)
                bigHeart.superview?.isUserInteractionEnabled = false
                bigHeart.isHidden = false
                bigHeart.alpha = 1.0
                let originalTransform = bigHeart.transform
                let translatedTransform = originalTransform.translatedBy(x: 0.0, y: 0.0)
                bigHeart.transform = translatedTransform
                
            }) { (isComplete : Bool) in
                
                UIView.animate(withDuration: 0.7, animations: {
                    
                    bigHeart.alpha = 0.0
                    let originalTransform = bigHeart.transform
                    let translatedTransform = originalTransform.translatedBy(x: 0.0, y: -60.0)
                    bigHeart.transform = translatedTransform
                    
                }, completion: { (isComplete : Bool) in
                    bigHeart.alpha = 1.0
                    bigHeart.isHidden = true
                    bigHeart.superview?.isUserInteractionEnabled = true
                })
                
            }
            
            if !dictFromParent.loginUserLike {
                dictFromParent.loginUserLike = true
                dictFromParent.likeCount = "\(Int(dictFromParent.likeCount)! + 1)"
                cell.btnLike.isSelected = true
                cell.btnLike.tintColor = .red
                cell.lblLike.text = GFunction.shared.getProfileCount(dictFromParent.likeCount)
                let requestModel = RequestModel()
                requestModel.item_id = dictFromParent.itemId
                requestModel.is_like = cell.btnLike.isSelected ? StatusType.like.rawValue : StatusType.unlike.rawValue
                
                //to handel crash
                guard self.tblComment != nil else {
                    return
                }
                
                UIView.animate(withDuration: 0.0, animations: {
                    DispatchQueue.main.async {
                        self.tblComment.reloadData()
                    }
                }, completion: { (Bool) in
                    
                })
                
                self.callLikeAPI(requestModel,
                                 withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                    
                })
            }
            
        }else{
            let indexPath = IndexPath(row: 0, section: 0)

            guard let cell = tblComment.cellForRow(at: indexPath) as? RackRepostCell else {
                return
            }
            let tapLocation = sender.location(in: cell.static_imgPost)
            let maxX = cell.static_imgPost.frame.size.width
            let minX = maxX - cell.static_btnLikeBig.frame.size.width
            let tapX = tapLocation.x
            
            if tapX > minX{
                cell.static_btnLikeBig.frame.origin = CGPoint(x: minX, y: tapLocation.y + 15)
            }else if tapX < cell.static_btnLikeBig.frame.size.width {
                cell.static_btnLikeBig.frame.origin = CGPoint(x: 8, y: tapLocation.y + 15)
            }else{
                cell.static_btnLikeBig.frame.origin = CGPoint(x: tapLocation.x, y: tapLocation.y + 15)
                cell.static_btnLikeBig.center.x = tapLocation.x
            }
            
            UIView.animate(withDuration: 0.7, animations: {
                
                cell.static_btnLike.scaleAnimation(0.15, scale: -0.05)
                
                cell.static_btnLikeBig.superview?.isUserInteractionEnabled = false
                cell.static_btnLikeBig.isHidden = false
                cell.static_btnLikeBig.alpha = 1.0
                let originalTransform = cell.static_btnLikeBig.transform
                let translatedTransform = originalTransform.translatedBy(x: 0.0, y: 0.0)
                cell.static_btnLikeBig.transform = translatedTransform
                
            }) { (isComplete : Bool) in
                
                UIView.animate(withDuration: 0.7, animations: {
                    
                    cell.static_btnLikeBig.alpha = 0.0
                    let originalTransform = cell.static_btnLikeBig.transform
                    let translatedTransform = originalTransform.translatedBy(x: 0.0, y: -60.0)
                    cell.static_btnLikeBig.transform = translatedTransform
                    
                }, completion: { (isComplete : Bool) in
                    cell.static_btnLikeBig.isHidden = true
                    cell.static_btnLikeBig.alpha = 1.0
                    cell.static_btnLikeBig.superview?.isUserInteractionEnabled = true
                })
                
            }
            
            if let dictFromParent = self.dictFromParent.parentItem {
                
                if !dictFromParent.loginUserLike {
                    
                    dictFromParent.loginUserLike = true
                    dictFromParent.likeCount = "\(Int(dictFromParent.likeCount)! + 1)"
                    
                    cell.static_btnLike.isSelected = true
                    cell.static_btnLike.tintColor = .red

                    cell.static_lblLike.text = GFunction.shared.getProfileCount(dictFromParent.likeCount)
                    
                    //TODO:- Check in ios 9.0 (Table is animated even if animation is set to none)
                    //       self.tblHome.reloadRows(at: [indexPath], with: .none)
                    
                    let requestModel = RequestModel()
                    requestModel.item_id = dictFromParent.itemId
                    requestModel.is_like = cell.static_btnLike.isSelected ? StatusType.like.rawValue : StatusType.unlike.rawValue
                    
                    //to handel crash
                    guard self.tblComment != nil else {
                        return
                    }
                    self.callLikeAPI(requestModel,
                                     withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                        
                    })
                }
                
            }
            
        }
        
    }
    
    // PinchGestureRecognizer Method
    func imagePostPinchGesture(_ sender: UIPinchGestureRecognizer) {
        
        let indexPath = IndexPath(row: 0, section: 0)
       
        
        if sender.state == .began {
            AppDelegate.shared.isSwipeBack = false
        }
        
        if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
           AppDelegate.shared.isSwipeBack = true
        }
        
        if _cellType == .normalCell {
            guard let cell = tblComment.cellForRow(at: indexPath) as? ItemCell else {
                return
            }
            tblComment.isScrollEnabled = true
            if sender.state == .changed || sender.state == .began {
                tblComment.isScrollEnabled = false
            }
            TMImageZoom.shared().gestureStateChanged(sender, withZoom: cell.imgPost)
        }else{
            
            let indexPath = IndexPath(row: 0, section: 0)
            
            guard let cell = tblComment.cellForRow(at: indexPath) as? RackRepostCell else {
                return
            }
            
            if sender.state == .changed || sender.state == .began {
                tblComment.isScrollEnabled = false
            }else{
                tblComment.isScrollEnabled = true
            }
            
            TMImageZoom.shared().gestureStateChanged(sender, withZoom: cell.static_imgPost)
        }
        
    }
    
    func imagePostPanGesture(sender:UIPanGestureRecognizer){
        
        let indexPath = IndexPath(row: 0, section: 0)
        if _cellType == .normalCell {
            guard let cell = tblComment.cellForRow(at: indexPath) as? ItemCell else {
                return
            }
            guard cell.pinchGesture.state == .began || cell.pinchGesture.state == .changed || cell.pinchGesture.state == .ended else {return}
            TMImageZoom.shared().moveImage(sender)
            
        } else{
            guard let cell = tblComment.cellForRow(at: indexPath) as? RackRepostCell else {
                return
            }
            
            guard cell.pinchGesture.state == .began || cell.pinchGesture.state == .changed || cell.pinchGesture.state == .ended else {return}
            TMImageZoom.shared().moveImage(sender)
        }
        

    }
    
    func scrollToBottom(){
        //        DispatchQueue.global(qos: .background).async {
        let indexPath = IndexPath(row: dictFromParent.commentData.count, section: 0)
        self.tblComment.scrollToRow(at: indexPath, at: .bottom, animated: true)
        //        }
    }
    
    func likeLabelSingleTap(_ sender : UITapGestureRecognizer) {
        
        if _cellType == .normalCell {
            if dictFromParent.likeCount == "0" || dictFromParent.likeCount == "" {
                return
            }
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "LikeListVC") as! LikeListVC
            vc.dictFromParent = dictFromParent
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            if dictFromParent.parentItem.likeCount == "0" || dictFromParent.parentItem.likeCount == "" {
                return
            }
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "LikeListVC") as! LikeListVC
            vc.dictFromParent = dictFromParent.parentItem
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func repostLabelSingleTap(_ sender : UITapGestureRecognizer) {
        
        if _cellType == .normalCell {
            if dictFromParent.repostCount == "0" || dictFromParent.repostCount == "" {
                return
            }
            let objRepostersVC = secondStoryBoard.instantiateViewController(withIdentifier: "RepostersVC") as! RepostersVC
            objRepostersVC.dictFromParent.itemId = dictFromParent.itemId
            self.navigationController?.pushViewController(objRepostersVC, animated: true)
        }else if _cellType == .repostCell {
            if dictFromParent.parentItem.repostCount == "0" || dictFromParent.parentItem.repostCount == "" {
                return
            }
            let objRepostersVC = secondStoryBoard.instantiateViewController(withIdentifier: "RepostersVC") as! RepostersVC
            objRepostersVC.dictFromParent.itemId = dictFromParent.parentItem.itemId
            self.navigationController?.pushViewController(objRepostersVC, animated: true)
        }
    }
    
    func userNameSingleTap(_ sender : UITapGestureRecognizer) {
        
        let index = (sender.view?.tag)!
        let dictAtIndex = dictFromParent.commentData[index - 1] as CommentModel
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.viewType = .other
        vc.fromPage = .otherPage
        vc.userData = UserModel(fromJson: JSON(dictAtIndex.toDictionary()))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func profileImgSingleTap(_ sender : UITapGestureRecognizer) {
        
        let index = (sender.view?.tag)!
        let dictAtIndex = dictFromParent.commentData[index - 1] as CommentModel
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.viewType = .other
        vc.fromPage = .otherPage
        vc.userData = UserModel(fromJson: JSON(dictAtIndex.toDictionary()))
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func autoHideTagCollectionOptionView() {
        let _cellType = RackCellType(rawValue: dictFromParent.rackCell)
        if _cellType == nil {
            return
        }
        if _cellType == .normalCell {
            let indexPath = IndexPath(row: 0, section: 0)
            guard let cell = tblComment.cellForRow(at: indexPath) as? ItemCell else {
                return
            }
            cell.collectionViewTag.alpha = 1.0
            UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveLinear, animations: {
                cell.collectionViewTag.alpha = 0.0
                
            }, completion: { (isComplete : Bool) in
                cell.collectionViewTag.isHidden = true
                cell.collectionViewTag.alpha = 1.0
            })
        }
        
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationItemDataUpdate(_ notification : Notification) {
        /* Notification Post Method call
         1. Comment VC add msg
         2. Comment view add msg
         3. Update want or unwant
         */
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        let notiItemData = jsonData
        if dictFromParent.parentId != "0" && dictFromParent.parentId != "" {
            if dictFromParent.parentItem.itemId == notiItemData.itemId && notiItemData.isFolderUpdated != true {
                dictFromParent.parentItem = notiItemData
            }else if dictFromParent.rackData.rackId == notiItemData.rackId && notiItemData.isFolderUpdated == true  {
                dictFromParent.rackData.rackName = notiItemData.rackName
            }else if dictFromParent.parentItem.rackData != nil && dictFromParent.parentItem.rackData.rackId == notiItemData.rackId && notiItemData.isFolderUpdated == true  {
                dictFromParent.parentItem.rackData.rackName = notiItemData.rackName
            }else if dictFromParent.itemId == notiItemData.itemId && notiItemData.isFolderUpdated != true {
                dictFromParent = notiItemData
            }
            
            UIView.animate(withDuration: 0.0, animations: {
                DispatchQueue.main.async {
                    self.tblComment.reloadData()
                }
            }, completion: { (Bool) in
                
            })
        }else{
            if dictFromParent.itemId == notiItemData.itemId{
                if dictFromParent.itemId == notiItemData.itemId && notiItemData.isFolderUpdated != true{
                dictFromParent = notiItemData
                }else if dictFromParent.rackData.rackId == notiItemData.rackId && notiItemData.isFolderUpdated == true {
                    dictFromParent.rackData.rackName = notiItemData.rackName
                }
                
                UIView.animate(withDuration: 0.0, animations: {
                    DispatchQueue.main.async {
                        self.tblComment.reloadData()
                    }
                }, completion: { (Bool) in
                    
                })
            }
        }
        
    }
    
    func notificationUserDetailsUpdate(_ notification : Notification) {
        
        guard let _  = tblComment else {
            return
        }
        
        
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblComment.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }
    
    func notificationItemDataDelete(_ notification : Notification) {
       
        if isRackFolder {
            if rackFolderCount > 1 {
                self.navigationController?.popViewController(animated: true)
            }else{
                if let vwControllers = navigationController?.viewControllers {
                    for vc in vwControllers {
                        if vc is ProfileVC {
                            self.navigationController?.popToViewController(vc, animated: true)
                        }
                    }
                }
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func notificationRepostCountUpdate(_ notification : Notification) {
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        if jsonData.shareType == PostShareType.repost.rawValue && jsonData.subParentId == dictFromParent.itemId {
            dictFromParent.loginUserRepost = true
        }
        if  dictFromParent.itemId == jsonData.parentId || dictFromParent.itemId == jsonData.itemId || dictFromParent.parentId == jsonData.parentId {
            
            let cellType = RackCellType(rawValue: jsonData.rackCell)
            
            if cellType == .normalCell {
                dictFromParent.repostCount = jsonData.repostCount
            }else{
                if let parentItem = dictFromParent.parentItem {
                    parentItem.repostCount = jsonData.repostCount
                }else{
                    dictFromParent.repostCount = jsonData.repostCount
                }
            }
            
        } else {
            
        }
        DispatchQueue.main.async {
            self.tblComment.reloadData()
        }
       
        
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    func callWantAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : item/itemwant
         
         Parameter   : item_id
         
         Optional    :
         
         Comment     : This api will used for user to save particular item to want list.
         
         ==============================
        */
        
        APICall.shared.GET(strURL: kMethodWantList
            , parameter: requestModel.toDictionary()
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    block(true,response[kData])
                    break
                    
                default:
                    
                    block(false,nil)
                    break
                }
            } else {
                block(false,nil)
            }
        }
    }
    
    func callLikeAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : request/item_like
         
         Parameter   : is_like('like','unlike'),item_id
         
         Optional    :
         
         Comment     : This api will used for user like or unlike comment.
         
         ==============================
        */
        
        APICall.shared.POST(strURL: kMethodItemLike
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    block(true,response[kData])
                    
                    //Google Analytics
                    
                   // let category = "UI"
                    //let action = "\(UserModel.currentUser.displayName!) liked an item \(self.dictFromParent.itemId!) in detail"
                    //let lable = ""
                    //let screenName = "Item detail"
                    //googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                    
                    //Google Analytics
                    
                    break
                    
                default:
                    
                    block(false,nil)
                    break
                }
            } else {
                block(false,nil)
            }
        }
        
    }
    
    func callItemDetailListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/comment_list
         
         Parameter   : item_id
         
         Optional    : page
         
         Comment     : This api will used for item wise comment listing.
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodItemDetail
            , parameter: requestModel.toDictionary()
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    block(true,response[kData])
                    break
                    
                default:
                    //stop pagination
                    self.tblComment.ins_endPullToRefresh()
                    block(false,nil)
                    break
                }
            } else {
                
                block(false,nil)
            }
        }
    }
    
    func callDeleteCommentAPI(_ requestModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/delete_comment
         
         Parameter   : comment_id
         
         Optional    :
         
         Comment     : This api will used for user delete comment.
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodDeleteComment
            , parameter: requestModel.toDictionary()
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    break
                    
                default:
                    
                    break
                }
            } else {
                
            }
        }
    }
    
    func callDeleteItemAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/deleteitem
         
         Parameter   : item_id
         
         Optional    :
         
         Comment     : This api will used for user can deleted the item detail.
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodItemDelete
            , parameter: requestModel.toDictionary()
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    block(true)
                    break
                    
                default:
                    block(false)
                    break
                }
            } else {
                block(false)
            }
        }
    }
    
    func callItemSharingAPI(_ requestModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/sharing
         
         Parameter   : item_id,social_keys
         
         Optional    :
         
         Comment     : This api will used for item sharing
         
         ==============================
         */
        
        APICall.shared.POST(strURL: kMethodItemSharing
            , parameter: requestModel.toDictionary()
            , withErrorAlert: true
            , withLoader: false
            , constructingBodyWithBlock: { (formData) in
                
        }
            , withBlock: { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
                
        })
    }
    
    
    func removeNotification()  {
        NotificationCenter.default.removeObserver(kNotificationItemDetailUpdate)
        NotificationCenter.default.removeObserver(kNotificationUserDetailsUpdate)
        NotificationCenter.default.removeObserver(kNotificationItemDetailDelete)
        NotificationCenter.default.removeObserver(kNotificationRepostCountUpdate)
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    func leftButtonClicked() {
        self.removeNotification()
        
        if isRackFolder && self.isEditComplete {
            if rackFolderCount > 1 {
                self.navigationController?.popViewController(animated: true)
            }else{
                if let vwControllers = navigationController?.viewControllers {
                    for vc in vwControllers {
                        if vc is ProfileVC {
                            self.navigationController?.popToViewController(vc, animated: true)
                        }
                    }
                }
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
     func btnLikeClicked(_ sender : UIButton) {
        
        let indexPath = IndexPath(row: 0, section: 0)
        if _cellType == .normalCell {
            guard let cell = tblComment.cellForRow(at: indexPath) as? ItemCell else {
                return
            }
            cell.btnLike.scaleAnimation(0.15, scale: -0.05)
            let status = dictFromParent.loginUserLike!
            dictFromParent.loginUserLike = !status
            if !status {
                cell.btnLike.tintColor = .red
                cell.btnLike.tumblerLikeAnimation(view: cell.buttonView)
            }else{
                cell.btnLike.tintColor = .black
            }
            cell.btnLike.isSelected = !status
            dictFromParent.likeCount = cell.btnLike.isSelected ? "\(Int(dictFromParent.likeCount)! + 1)" : "\(Int(dictFromParent.likeCount)! - 1)"
            cell.lblLike.text = GFunction.shared.getProfileCount(dictFromParent.likeCount)
            let requestModel = RequestModel()
            requestModel.item_id = dictFromParent.itemId
            requestModel.is_like = cell.btnLike.isSelected ? StatusType.like.rawValue : StatusType.unlike.rawValue
            //to handel crash
            guard self.tblComment != nil else {
                return
            }
            self.tblComment.reloadData()
            self.callLikeAPI(requestModel,
                             withCompletion:
                { (isSuccess : Bool, jsonResponse : JSON?) in
                    
            })
        } else {
            guard let cell = tblComment.cellForRow(at: indexPath) as? RackRepostCell else {
                return
            }
            let itemObject : ItemModel = self.dictFromParent.parentItem
            let status = itemObject.loginUserLike!
            itemObject.loginUserLike = !status
            if !status {
            cell.static_btnLike.tintColor = .red
            cell.static_btnLike.tumblerLikeAnimation(view: cell.static_buttonView)
            }else{
              cell.static_btnLike.tintColor = .black
            }
            cell.static_btnLike.isSelected = !status
            
            dictFromParent.likeCount = cell.static_btnLike.isSelected ? "\(Int(dictFromParent.likeCount)! + 1)" : "\(Int(dictFromParent.likeCount)! - 1)"
            cell.static_lblLike.text = GFunction.shared.getProfileCount(dictFromParent.likeCount)
            
            let requestModel = RequestModel()
            requestModel.item_id = itemObject.itemId
            requestModel.is_like = cell.static_btnLike.isSelected ? StatusType.like.rawValue : StatusType.unlike.rawValue
            //to handel crash
            guard self.tblComment != nil else {
                return
            }
            self.callLikeAPI(requestModel,
                             withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
            })
        }
        
    }
    
     func btnCommentClicked(_ sender : UIButton) {
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        if _cellType == .normalCell {
            vc.dictFromParent = dictFromParent
        }else{
            vc.dictFromParent = dictFromParent.parentItem
        }
        vc.copyDictFromParent = dictFromParent
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
     func btnRepostClicked(_ sender : UIButton) {
        let indexPath = IndexPath(row: 0, section: 0)
        if _cellType == .normalCell {
            guard let cell = tblComment.cellForRow(at: indexPath) as? ItemCell else {
                return
            }
            guard cell.imgPost.image != nil && cell.imgPost.image!.size != CGSize.zero else {
                return
            }
            let dictAtIndex : ItemModel = self.dictFromParent
            if !dictAtIndex.loginUserRepost {
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let quickRepost = UIAlertAction(title: "Quick Repost", style: .default) { (action : UIAlertAction) in
                    cell.btnRepost.scaleAnimation(0.15, scale: -0.05)
                    let obj = secondStoryBoard.instantiateViewController(withIdentifier: "QuickRepostVC") as! QuickRepostVC
                    obj._imgPost = cell.imgPost.image!
                    obj._tvCaptionText = dictAtIndex.caption
                    obj.rackName = dictAtIndex.rackData.rackName
                    obj._dictFromParent = dictAtIndex
                    let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
                   navigationController.navigationBar.barStyle = .default
                    self.present(navigationController, animated: true, completion: nil)
                }
                
                let repostWithCaption = UIAlertAction(title: "Repost & Add Caption", style: .default) { (action : UIAlertAction) in
                    let objAtIndex = self.dictFromParent
                    let obj = secondStoryBoard.instantiateViewController(withIdentifier: "RepostAddCaptionVC") as! RepostAddCaptionVC
                    obj._imgPost = cell.imgPost.image!
                    obj._postUserProfile = cell.imgProfile.image!
                    obj._postUsername = cell.lblUserName.text!
                    obj._postType = cell.lblPostType.text!
                    obj._tvCaptionText = objAtIndex.caption
                    obj._dictFromParent = objAtIndex
                    let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
                    navigationController.navigationBar.barStyle = .default
                    self.present(navigationController, animated: true, completion: nil)
                }
                let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in }
                actionSheet.addAction(quickRepost)
                actionSheet.addAction(repostWithCaption)
                actionSheet.addAction(actionCancel)
                self.present(actionSheet, animated: true, completion: nil)
            }

        }else{
            
            guard let cell = tblComment.cellForRow(at: indexPath) as? RackRepostCell else {
                return
            }
            
            guard cell.static_imgPost.image != nil && cell.static_imgPost.image!.size != CGSize.zero else {
                return
            }
            let dictAtIndex : ItemModel = self.dictFromParent
            if !dictAtIndex.loginUserRepost {
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let quickRepost = UIAlertAction(title: "Quick Repost", style: .default) { (action : UIAlertAction) in
                    cell.static_btnRepost.scaleAnimation(0.15, scale: -0.05)
                    if let objAtIndex = self.dictFromParent.parentItem {
                        let obj = secondStoryBoard.instantiateViewController(withIdentifier: "QuickRepostVC") as! QuickRepostVC
                        obj._imgPost = cell.static_imgPost.image!
                        obj._tvCaptionText = objAtIndex.caption
                        obj.rackName = objAtIndex.rackData.rackName
                        obj._dictFromParent = objAtIndex
                        
                        let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
                        navigationController.navigationBar.barStyle = .default
                        self.present(navigationController, animated: true, completion: nil)
                    }
                }
                
                let repostWithCaption = UIAlertAction(title: "Repost & Add Caption", style: .default) { (action : UIAlertAction) in
                    if let objAtIndex = self.dictFromParent.parentItem {
                        let obj = secondStoryBoard.instantiateViewController(withIdentifier: "RepostAddCaptionVC") as! RepostAddCaptionVC
                        obj._imgPost = cell.static_imgPost.image!
                        obj._postUserProfile = cell.static_imgProfile.image!
                        obj._postUsername = cell.static_lblUserName.text!
                        obj._postType = cell.static_lblPostType.text!
                        obj._tvCaptionText = objAtIndex.caption
                        obj._dictFromParent = objAtIndex
                        
                        let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
                        navigationController.navigationBar.barStyle = .default
                        self.present(navigationController, animated: true, completion: nil)
                    }
                }
                let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in }
                actionSheet.addAction(quickRepost)
                actionSheet.addAction(repostWithCaption)
                actionSheet.addAction(actionCancel)
                self.present(actionSheet, animated: true, completion: nil)
            }
            
        }
        
    }
    
    
     func btnWantClicked(_ sender : UIButton) {
        let indexPath = IndexPath(row: 0, section: 0)
        if _cellType == .normalCell {
            guard let cell = tblComment.cellForRow(at: indexPath) as? ItemCell else {
                return
            }
           cell.btnWant.scaleAnimation(0.15, scale: -0.05)
            let objAtIndex = dictFromParent
            let status = objAtIndex.loginUserWant!
            if !status {
                let obj = secondStoryBoard.instantiateViewController(withIdentifier: "FoldersListVC") as! FoldersListVC
                obj._imgPost = cell.imgPost.image!
                obj.dictFromParent = objAtIndex
                obj.btnWantSelected = !status
                let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
                navigationController.navigationBar.barStyle = .default
                self.present(navigationController, animated: true, completion: nil)
                cell.btnWant.isSelected = false
                
            }else{
                let requestModel = RequestModel()
                requestModel.item_id = objAtIndex.itemId
                requestModel.type = !status ? StatusType.want.rawValue : StatusType.unwant.rawValue
                dictFromParent.loginUserWant = !status
                cell.btnWant.isSelected = !status
                self.callWantAPI(requestModel,
                                 withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                    if isSuccess {
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationProfileUpdate), object: nil)
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: objAtIndex)
                                    } else {}
                })
            }
            
        }else{
            
            guard let cell = tblComment.cellForRow(at: indexPath) as? RackRepostCell else {
                return
            }
            cell.static_btnWant.scaleAnimation(0.15, scale: -0.05)
            if let objAtIndex = dictFromParent.parentItem {
                let status = objAtIndex.loginUserWant!
                if !status {
                    let obj = secondStoryBoard.instantiateViewController(withIdentifier: "FoldersListVC") as! FoldersListVC
                    obj._imgPost = cell.static_imgPost.image!
                    obj.dictFromParent = objAtIndex
                    obj.btnWantSelected = !status
                    let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
                  navigationController.navigationBar.barStyle = .default
                    self.present(navigationController, animated: true, completion: nil)
                    cell.static_btnWant.isSelected = false
                }else{
                    let requestModel = RequestModel()
                    requestModel.item_id = objAtIndex.itemId
                    requestModel.type = !status ? StatusType.want.rawValue : StatusType.unwant.rawValue
                    dictFromParent.parentItem.loginUserWant = !status
                    cell.static_btnWant.isSelected = !status
                    self.callWantAPI(requestModel,
                                     withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                        if isSuccess {
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationProfileUpdate), object: nil)
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: objAtIndex)
                                        } else {}
                    })
                }
            }
        }
    }
    
    func btnChatReplayClicked(_ sender : UIButton) {
        guard let indexPath = sender.buttonIndexPath  else {
            return
        }
        guard let _ = tblComment.cellForRow(at: indexPath) as? CommentCell else {
            return
        }
        let dictAtIndex : CommentModel = dictFromParent.commentData[indexPath.row - 1]
        let commentView : CommentView = CommentView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        AppDelegate.shared.window!.addSubview(commentView)
        commentView.delegate = self
        commentView.dictFromParent = dictFromParent
        commentView.setUpData(dictAtIndex)
        commentView.showAnimationMethod()
        
    }
    
    func btnDotClicked(_ sender : UIButton) {
        
        guard let indexPath = sender.buttonIndexPath  else {
            return
        }
        
        guard let cell = tblComment.cellForRow(at: indexPath) as? CommentCell else {
            return
        }
        
        let dictAtIndex : CommentModel = dictFromParent.commentData[indexPath.row - 1]
        
        /*
         1. Logged in user's post and logged in user's comment -> [Report, Delete, Cancel]
         2. Logged in user's comment -> [Delete, Cancel]
         3. If it doesn't satisfy any of the above mentioned condition's then -> [Report, Cancel]
         */
        
        if dictAtIndex.userId != UserModel.currentUser.userId && self.dictFromParent.userId == UserModel.currentUser.userId {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionReport = UIAlertAction(title: "Report", style: .default) { (action : UIAlertAction) in
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
                vc.reportId = dictAtIndex.userId
                vc.reportType = .comment
                vc.offenderId = self.dictFromParent.userId
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            let actionBlock = UIAlertAction(title: "Delete", style: .default) { (action : UIAlertAction) in
                
                AlertManager.shared.showAlertTitle(title: "", message: "Delete this comment?", buttonsArray: ["Delete","Cancel"]) { (buttonIndex : Int) in
                    switch buttonIndex {
                    case 0 :
                        
                        self.dictFromParent.commentData.remove(at: indexPath.row - 1)
                        self.tblComment.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        
                        self.tblComment.reloadData()
                        
                        let requestModel = RequestModel()
                        requestModel.comment_id = dictAtIndex.commentId
                        
                        self.dictFromParent.commentCount = String(Int(self.dictFromParent.commentCount)! - 1)
                        
                        let arrayLoggedUsersComment = self.dictFromParent.commentData.filter({ (objComment : CommentModel) -> Bool in
                            
                            if objComment.userId == UserModel.currentUser.userId {
                                return true
                            } else {
                                return false
                            }
                            
                        })
                        
                        if arrayLoggedUsersComment.isEmpty {
                            self.dictFromParent.loginUserComment = false
                        } else {
                            self.dictFromParent.loginUserComment = true
                        }
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.dictFromParent)
                        
                        self.callDeleteCommentAPI(requestModel)
                        
                        break
                    case 1:
                        
                        break
                    default :
                        break
                    }
                }
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                
            }
            
            actionSheet.addAction(actionReport)
            actionSheet.addAction(actionBlock)
            actionSheet.addAction(actionCancel)
            
            self.present(actionSheet, animated: true, completion: nil)
            
        } else if dictAtIndex.userId == UserModel.currentUser.userId {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionBlock = UIAlertAction(title: "Delete", style: .default) { (action : UIAlertAction) in
                
                AlertManager.shared.showAlertTitle(title: "", message: "Delete this comment?", buttonsArray: ["Delete","Cancel"]) { (buttonIndex : Int) in
                    switch buttonIndex {
                    case 0 :
                        
                        self.dictFromParent.commentData.remove(at: indexPath.row - 1)
                        self.tblComment.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        
                        self.tblComment.reloadData()
                        
                        let requestModel = RequestModel()
                        requestModel.comment_id = dictAtIndex.commentId
                        
                        self.dictFromParent.commentCount = String(Int(self.dictFromParent.commentCount)! - 1)
                        
                        let arrayLoggedUsersComment = self.dictFromParent.commentData.filter({ (objComment : CommentModel) -> Bool in
                            
                            if objComment.userId == UserModel.currentUser.userId {
                                return true
                            } else {
                                return false
                            }
                            
                        })
                        
                        if arrayLoggedUsersComment.isEmpty {
                            self.dictFromParent.loginUserComment = false
                        } else {
                            self.dictFromParent.loginUserComment = true
                        }
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.dictFromParent)
                        
                        self.callDeleteCommentAPI(requestModel)
                        
                        break
                    case 1:
                        
                        break
                    default :
                        break
                    }
                }
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                
            }
            
            actionSheet.addAction(actionBlock)
            actionSheet.addAction(actionCancel)
            
            self.present(actionSheet, animated: true, completion: nil)
            
        } else {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionReport = UIAlertAction(title: "Report", style: .default) { (action : UIAlertAction) in
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
                vc.reportId = dictAtIndex.userId
                vc.reportType = .comment
                vc.offenderId = self.dictFromParent.userId
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                
            }
            
            actionSheet.addAction(actionReport)
            actionSheet.addAction(actionCancel)
            
            self.present(actionSheet, animated: true, completion: nil)
            
        }
        
    }
    
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = AppColor.secondaryTheme
        self.view.backgroundColor = AppColor.primaryTheme
         self.tblComment.backgroundColor = UIColor.white
        copyDictFromParent = dictFromParent
        self.tblComment.isHidden = true
        
        _cellType = RackCellType(rawValue: dictFromParent.rackCell)
        setUpData()
        //add notification for item data update
        NotificationCenter.default.addObserver(self, selector: #selector(notificationItemDataUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationItemDataDelete(_:)), name: NSNotification.Name(rawValue: kNotificationItemDetailDelete), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRepostCountUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationRepostCountUpdate), object: nil)
    }
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //.layoutIfNeeded()
        if !self.isPullCalled {
            self.tblComment.reloadData()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: dictFromParent.getUserName(), isSwipeBack: true)

        //Google Analytics
        let category = "UI"
        let action = "\(UserModel.currentUser.displayName!) see item \(self.dictFromParent.itemId!) in detail"
        let lable = ""
        let screenName = "Item Detail"
        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
        //Google Analytics
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: dictFromParent.getUserName(), isSwipeBack: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isEditComplete = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if copyDictFromParent != dictFromParent {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.dictFromParent)
        }
    }

    //MARK:- Memory Management Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        self.removeNotification()
    }
    
    //------------------------------------------------------
}

//MARK: - TableView Delegate Datasource -
extension RackDetailVC : PSTableDelegateDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if dictFromParent.rackData == nil {
            return 0
        }
        
        _cellType = RackCellType(rawValue: dictFromParent.rackCell)
        if _cellType == nil {
             return 0
        }
        return dictFromParent.commentData.count + 1
    }

   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        _cellType = RackCellType(rawValue: dictFromParent.rackCell)
        if _cellType != .repostCell && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
            cell.configureCell(dictFromParent: dictFromParent, controller: self)
            if self.navigationController?.visibleViewController is RackDetailVC {
                _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: self.dictFromParent.getUserName(), isSwipeBack: true)
            }
                return cell
        } else if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemRepostCell", for: indexPath) as! RackRepostCell
            if self.navigationController?.visibleViewController is RackDetailVC {
                _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: self.dictFromParent.getUserName(), isSwipeBack: true)
            }
            cell.configureCell(item: dictFromParent, viewController: self )

            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        if dictFromParent.commentData.count <= indexPath.row - 1 {
            return cell
        }
        let dictAtIndex = dictFromParent.commentData[indexPath.row - 1] as CommentModel
        cell.selectionStyle = .none
        cell.lblUserName.text = dictAtIndex.getUserName()
        cell.lblComment.text = dictAtIndex.comment
        self.setUpDetailText(cell.lblComment, userName: dictAtIndex.getUserName(), obj: dictAtIndex)
        cell.ivProfile.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        cell.ivProfile.setImageWith(dictAtIndex.getUserProfile().url())
        cell.lblTime.text = dictAtIndex.calculatePostTime()
        cell.btnDot.buttonIndexPath = indexPath
        cell.btnReplay.buttonIndexPath = indexPath
        
        cell.btnReplay.addTarget(self, action: #selector(btnChatReplayClicked(_:)), for: .touchUpInside)
        cell.btnDot.addTarget(self, action: #selector(btnDotClicked(_:)), for: .touchUpInside)
        
        cell.lblUserName.tag = indexPath.row
        //singletap configuration for profileview
        cell.userNameLabelGesture = UITapGestureRecognizer(target: self, action: #selector(userNameSingleTap(_:)))
        cell.userNameLabelGesture.numberOfTapsRequired = 1
        cell.userNameLabelGesture.numberOfTouchesRequired = 1
        cell.lblUserName.addGestureRecognizer(cell.userNameLabelGesture)
        cell.lblUserName.isUserInteractionEnabled = true
        
        cell.ivProfile?.tag = indexPath.row
        //singletap configuration for profileview
        cell.profileImgGesture = UITapGestureRecognizer(target: self, action: #selector(profileImgSingleTap(_:)))
        cell.profileImgGesture.numberOfTapsRequired = 1
        cell.profileImgGesture.numberOfTouchesRequired = 1
        cell.ivProfile?.addGestureRecognizer(cell.profileImgGesture)
        cell.ivProfile?.isUserInteractionEnabled = true
        
        return cell
    }
    
}
//MARK: - CollectionView Delegate Datasource -
extension RackDetailVC : PSCollectinViewDelegateDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayTagType.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dictAtIndex = arrayTagType[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RackTagCell", for: indexPath) as! RackTagCell
        
        guard _cellType != nil else {
            return cell
        }
        if _cellType == .normalCell {
            let _image = dictAtIndex["img"] as? UIImage
            cell.imgIcon.image = _image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dictAtIndex = arrayTagType[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath)
        cell!.scaleAnimation(0.15, scale: -0.05)
        let indexPath = IndexPath(row: 0, section: 0)
        guard let itemCell = tblComment.cellForRow(at: indexPath) as? ItemCell else {
            return
        }
        itemCell.imgPost.removeAllPSTagView()
        itemCell.collectionViewTag.isHidden = true
        let type = dictAtIndex[kAction] as! TagType
        switch type {
        case .none:
            if let userData = dictFromParent as? ItemModel {
                //Require to change view type according to POST type. At WS parsing time
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                let userDataPass = UserModel()
                userDataPass.userId = dictFromParent.ownerUid
                vc.userData = UserModel(fromJson: JSON(userDataPass.toDictionary()))
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
        case .tagBrand ,.tagItem ,.tagPeople, .addLink:
            
            guard itemCell.imgPost.image != nil else {
                return
            }
            
            //                For Passing Tag Taga With Image
            _ = itemCell.imgPost.image?.getPostImageScaleFactor(kScreenWidth)
            
            if let tagData = dictFromParent.tagDetail {
                
                if type.rawValue == TagType.tagBrand.rawValue {
                    
                    let detail = tagData.brandTag
                    let tagDetail = SimpleTagModel.dictArrayFromModelArray(array: detail!)
                    let tagView = PSTagView.showTagOnImage(tagDetail, parentView: itemCell.imgPost, mainImage : itemCell.imgPost.image!, searchType: searchFlagType.brand)
                    for singleTag in tagView {
                        singleTag.delegate = self
                        itemCell.imgPost.addSubview(singleTag)
                    }
                } else if type.rawValue == TagType.tagItem.rawValue {
                    
                    let detail = tagData.itemTag
                    let tagDetail = SimpleTagModel.dictArrayFromModelArray(array: detail!)
                    
                    let tagView = PSTagView.showTagOnImage(tagDetail, parentView: itemCell.imgPost, mainImage : itemCell.imgPost.image!, searchType: searchFlagType.item)
                    for singleTag in tagView {
                        singleTag.delegate = self
                        itemCell.imgPost.addSubview(singleTag)
                    }
                } else if type.rawValue == TagType.addLink.rawValue {
                    
                    let detail = tagData.linkTag
                    let tagDetail = LinkTagModel.dictArrayFromModelArray(array: detail!)
                    let tagView = PSTagView.showTagOnImage(tagDetail, parentView: itemCell.imgPost, mainImage : itemCell.imgPost.image!, searchType: searchFlagType.link)
                    for singleTag in tagView {
                        singleTag.delegate = self
                        itemCell.imgPost.addSubview(singleTag)
                    }
                } else if type.rawValue == TagType.tagPeople.rawValue {
                    
                    let detail = tagData.userTag
                    let tagDetail = PeopleTagModel.dictArrayFromModelArray(array: detail!)
                    let tagView = PSTagView.showTagOnImage(tagDetail, parentView: itemCell.imgPost, mainImage : itemCell.imgPost.image!, searchType: searchFlagType.people)
                    for singleTag in tagView {
                        singleTag.delegate = self
                        itemCell.imgPost.addSubview(singleTag)
                    }
                }
            }
            break
            
        default:
         break
        }
    }
    
}

extension RackDetailVC : CommentViewDelegate {
    
    func sendCommentDelegate(_ data: Any?) {
        dictFromParent = data as! ItemModel
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblComment.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }
}

extension RackDetailVC : PSTagViewTapDelegate {
    func tapOnTagDelegate(_ sender : Any) {
        let pstag = sender as! PSTagView
        switch pstag.tagType {
        case .brand:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchDetailVC") as! SearchDetailVC
            vc.searchFlagType = searchFlagType.brand.rawValue
            vc.searchData = SearchText(fromJson: JSON(pstag.tagDetail!))
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .people:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            vc.viewType = .other
            vc.fromPage = .otherPage
            vc.userData = UserModel(fromJson: JSON(pstag.tagDetail!))
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .item:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchDetailVC") as! SearchDetailVC
            vc.searchFlagType = searchFlagType.item.rawValue
            vc.searchData = SearchText(fromJson: JSON(pstag.tagDetail!))
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .link:
            var strLink = SearchText(fromJson: JSON(pstag.tagDetail!)).name
            if (strLink?.hasPrefix("http://"))! || (strLink?.hasPrefix("https://"))! {
                //link is correct
            } else {
                strLink = "http://\(strLink!)"
            }
            let link = strLink?.url()
            if UIApplication.shared.canOpenURL(link!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(link!, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(link!)
                }
            }
            
            break
            
        default:
            break
        }
    }
}
extension RackDetailVC : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
