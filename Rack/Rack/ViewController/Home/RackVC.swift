//
//  RackVC.swift
//  Rack
//
//  Created by hyperlink on 19/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//


import UIKit
import Foundation
import ActiveLabel
import Crashlytics
import PinterestSDK
import FBSDKCoreKit
import FBSDKLoginKit

var constRackCell: UInt8 = 0
//MARK:- RackVC -
class RackVC: UIViewController {
    
    enum RackCellType : String {
        case normalCell
        case multiImageCell
        case repostCell
    }
    
    typealias cellType = RackCellType
    //MARK:- Outlet
    @IBOutlet var tblHome : UITableView!
    @IBOutlet var viewNoFollowerFound: UIView!
    @IBOutlet var btnFollow: UIButton!
    @IBOutlet var lblNoFollowersTitle: UILabel!
    @IBOutlet var lblNoFollowersMsg: UILabel!
    
    //------------------------------------------------------
    //MARK:- Class Variable
    
    var arrayItemData : [ItemModel] = []
    var normalCellPopUp : NormalCellPopUp = NormalCellPopUp(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
    var heightAtIndexPath = NSMutableDictionary()
    var arraySocialKeys      : [Dictionary<String , Dictionary<String,Any>>] = []
    var isWSCalling          : Bool = true
    var repostAddedIndexPath : IndexPath?
    var wantAddedIndexPath   : IndexPath?
    //------------------------------------------------------
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
        //remove observer
        NotificationCenter.default.removeObserver(kNotificationItemDetailUpdate)
        NotificationCenter.default.removeObserver(kNotificationItemDetailDelete)
        NotificationCenter.default.removeObserver(kNotificationNewPostAdded)
        NotificationCenter.default.removeObserver(kNotificationUserDetailsUpdate)
        NotificationCenter.default.removeObserver(kNotificationRepostCountUpdate)
        NotificationCenter.default.removeObserver(kNotificationUnfollow)
        NotificationCenter.default.removeObserver(kNotificationWant)
        NotificationCenter.default.removeObserver(kNotificationRackFeedUpdate)
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        
        //Navigation Bar setup
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //        tblHome.decelerationRate = UIScrollViewDecelerationRateNormal
        self.navigationController?.customize()
        self.view.backgroundColor = AppColor.primaryTheme
        self.navigationController?.customize()
        
        //view no followers found set up
        self.viewNoFollowerFound.backgroundColor = AppColor.primaryTheme
        btnFollow.applyStyle(titleLabelFont: nil, titleLabelColor: nil, cornerRadius: btnFollow.frame.size.height / 2, borderColor: AppColor.secondaryTheme, borderWidth: 0.0, state: UIControlState.normal)
        btnFollow.imageView?.contentMode = .scaleAspectFill
        btnFollow.setImage(UIImage(named:"follow_friend"), for: .normal)
        
        //setup for autoPullTorefresh and paggination
        self.setupPullToRefresh()
        
        self.perform(#selector(self.addLoaderWithDelayPullToRefresh), with: nil, afterDelay: 0.0)
        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.tblHome.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
        infinityIndicator.startAnimating()
        
        //TODO: Remove at WS calling time. Its just for prototype time
        //to hide tag collection options without collection
        //self.perform(#selector(autoHideTagCollectionOptionView), with: nil, afterDelay: 2.0)
        
        //add notification for comment update
        NotificationCenter.default.addObserver(self, selector: #selector(notificationItemDataUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationNewPostAdded(_:)), name: NSNotification.Name(rawValue: kNotificationNewPostAdded), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRepostCountUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationRepostCountUpdate), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationItemDataDelete(_:)), name: NSNotification.Name(rawValue: kNotificationItemDetailDelete), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUnfollow(_:)), name: NSNotification.Name(rawValue: kNotificationUnfollow), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationWant(_:)), name: NSNotification.Name(rawValue: kNotificationWant), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRackFeedUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationRackFeedUpdate), object: nil)
    }
    
    func addLoaderWithDelayPullToRefresh() {
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.tblHome.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.tblHome.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
        
        self.tblHome.ins_beginPullToRefresh()
    }
    
    func setupPullToRefresh() {
        
        //top
        self.tblHome.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
            let requestModel = RequestModel()
            requestModel.type = PageRefreshType.top.rawValue
            
            let firstItem : ItemModel?
            let lastItem : ItemModel?
            
            firstItem = self.arrayItemData.first
            lastItem = self.arrayItemData.last
            
            /*
             /*
             Data is added from app side, we dont get proper insertdate. So fetching insertdate of data that we got from WS
             */
             
             firstItem = self.arrayItemData.first(where: { (obj : ItemModel) -> Bool in
             if obj.dataFromWS == true {
             return true
             } else {
             return false
             }
             })*/
            
            if firstItem != nil {
                //                self.tblHome.isScrollEnabled = false
                if let insertDate = firstItem?.getInsertDate() {
                    let insertDate = Date().convertToLocal(sourceDate: insertDate)
                    requestModel.timestamp = insertDate.getTimeStampFromDate().string
                }
                if firstItem != nil {
                    if lastItem != firstItem {
                        if let insertDate = lastItem?.getInsertDate() {
                            let insertDate = Date().convertToLocal(sourceDate: insertDate)
                            requestModel.end_timestamp = insertDate.getTimeStampFromDate().string
                        }
                    }
                }
            } else {
                requestModel.type = PageRefreshType.bottom.rawValue
            }
            
            //call API for top data
            self.callItemListAPI(requestModel, withCompletion: { (isSuccess) in
                
                self.repostAddedIndexPath = nil
                self.wantAddedIndexPath = nil
                self.tblHome.ins_endPullToRefresh()
                
                
                /*
                 DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                 self.updateTimeofVisibleCell()
                 })
                 */
            })
        }
        
        //bottom
        self.tblHome.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            let requestModel = RequestModel()
            requestModel.type = PageRefreshType.bottom.rawValue
            
            /*
             Pass normalCell rackCell's type for down pagination
             From array
             */
            
            var lastItem : ItemModel?
            //            lastItem = self.arrayItemData.last
            
            lastItem = self.arrayItemData.reversed().first(where: { (obj : ItemModel) -> Bool in
                if obj.rackCell == RackCellType.normalCell.rawValue {
                    return true
                } else {
                    return false
                }
            })
            
            if lastItem != nil {
                if let insertDate = lastItem?.getInsertDate() {
                    let insertDate = Date().convertToLocal(sourceDate: insertDate)
                    requestModel.timestamp = insertDate.getTimeStampFromDate().string
                }
            }
            
            if let passLastItem = self.arrayItemData.last {
                if passLastItem.rackCell == RackCellType.multiImageCell.rawValue {
                    if let insertDate = passLastItem.getPassInsertDate() {
                        let insertDate = Date().convertToLocal(sourceDate: insertDate)
                        requestModel.pass_timestamp = insertDate.getTimeStampFromDate().string
                    }
                }
            }
            
            if self.isWSCalling {
                self.isWSCalling = false
                //call API for bottom data
                self.callItemListAPI(requestModel, withCompletion: { (isSuccess) in
                    
                })
            }
        }
    }
    
    func callAfterServiceResponse(_ data : JSON, pageRefresh : PageRefreshType?) {
        guard pageRefresh != nil else {
            return
        }
        
        switch pageRefresh! {
        case .top:
            
            let tempData = ItemModel.modelsFromDictionaryArray(array: data.arrayValue)
            _ = tempData.filter({ (obj : ItemModel) -> Bool in
                let predict = NSPredicate(format: "itemId = %@",obj.itemId!)
                let temp = arrayItemData.filter({ predict.evaluate(with: $0) })
                /* When to add item
                 //1. No match with item_id in existing data
                 //2. Add item only if multiimagecell's item_data is not empty
                 */
                if temp .isEmpty {
                    if (obj.itemData .isEmpty) && obj.rackCell == RackCellType.multiImageCell.rawValue {
                        ////print("//dont insert empty data")
                    } else {
                        arrayItemData.insert(obj, at: 0)
                    }
                }
                    /* When to replace or remove item
                     //1. if match with item_id in existing data, replace that data to obj
                     //2. Remove item if multiimagecell's item_data is empty
                     */
                else {
                    if let index = arrayItemData.index(of: temp[0]) {
                        if obj.itemData .isEmpty && obj.rackCell == RackCellType.multiImageCell.rawValue {
                            
                            if let index = arrayItemData.index(of: temp[0]) {
                                arrayItemData.remove(at: index)
                            }
                        }else {
                            arrayItemData[index] = obj
                        }
                    }
                    else {
                        ////print("Something went wrong in pull to refresh top.")
                    }
                }
                return true
            })
            
            
            let arraySort = arrayItemData.sorted(by: { (obj1 : ItemModel, obj2 : ItemModel) -> Bool in
                return obj1.insertdate > obj2.insertdate
            })
            arrayItemData = arraySort
            
            
            self.tblHome.reloadData()
            if arrayItemData.count == 0 {
                self.tblHome.bounces = false
                self.addNoFollowersFoundView()
            }
            
            break
        case .bottom:
            
            
            
            let tempData = ItemModel.modelsFromDictionaryArray(array: data.arrayValue)
            _ = tempData.filter({ (obj : ItemModel) -> Bool in
                let predict = NSPredicate(format: "itemId = %@",obj.itemId!)
                let temp = arrayItemData.filter({ predict.evaluate(with: $0) })
                /* When to add item
                 //1. No match with item_id in existing data
                 //2. Add item only if multiimagecell's item_data is not empty
                 */
                if temp .isEmpty {
                    if (obj.itemData .isEmpty) && obj.rackCell == RackCellType.multiImageCell.rawValue {
                        ////print("//dont insert empty data")
                    } else {
                        arrayItemData.insert(obj, at: 0)
                    }
                }
                    /* When to replace or remove item
                     //1. if match with item_id in existing data, replace that data to obj
                     //2. Remove item if multiimagecell's item_data is empty
                     */
                else {
                    if let index = arrayItemData.index(of: temp[0]) {
                        if obj.itemData .isEmpty && obj.rackCell == RackCellType.multiImageCell.rawValue {
                            
                            if let index = arrayItemData.index(of: temp[0]) {
                                arrayItemData.remove(at: index)
                            }
                        }else {
                            arrayItemData[index] = obj
                        }
                    }
                    else {
                        ////print("Something went wrong in pull to refresh top.")
                    }
                }
                return true
            })
            let arraySort = arrayItemData.sorted(by: { (obj1 : ItemModel, obj2 : ItemModel) -> Bool in
                return obj1.insertdate > obj2.insertdate
            })
            arrayItemData = arraySort
            self.tblHome.ins_endInfinityScroll(withStoppingContentOffset: true)
            self.tblHome.reloadData()
            break
        }
    }
    
    
    func setUpDetailText(_ lblDetail : ActiveLabel, userName : String, obj : ItemModel) {
        /*
         \b - consider full word
         ^ - starting with username
         */
        let customType1 = ActiveType.custom(pattern: "^(\\b)\(userName)(\\b)")
        let customType2 = ActiveLabel.CustomActiveTypes.hashtag
        let customTypeMention = ActiveLabel.CustomActiveTypes.mention
        
        lblDetail.enabledTypes = [customType1, .mention, customType2, customTypeMention]
        
        lblDetail.customize { (label : ActiveLabel) in
            
            label.customColor[customType1] = AppColor.text
            
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var attribute = attributes
                switch type {
                case customType1, customTypeMention, .mention :
                    attribute[NSFontAttributeName] = UIFont.applyArialBold(fontSize: 11.0)
                    attribute[NSForegroundColorAttributeName] = AppColor.textB
                    break
                case customType2 :
                    attribute[NSFontAttributeName] = UIFont.applyArialRegular(fontSize: 11.0)
                    attribute[NSForegroundColorAttributeName] = AppColor.textB
                    break
                case .hashtag :
                    attribute[NSFontAttributeName] = UIFont.applyArialRegular(fontSize: 11.0)
                    attribute[NSForegroundColorAttributeName] = AppColor.textB
                    break
                default: ()
                }
                return attribute
            }
            
            label.handleCustomTap(for: customType1) {
                //print("CustomType \($0)")
                
                let objData = ["user_name" : $0]
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                vc.userData = UserModel(fromJson: JSON(objData))
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            label.handleCustomTap(for: customType2) {
                //print("Custom HashTag : \($0)")
                
                let objAtIndex = ["name" : $0.replacingOccurrences(of: "#", with: "")]
                
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchDetailVC") as! SearchDetailVC
                vc.searchFlagType = searchFlagType.hashtag.rawValue
                vc.searchData = SearchText(fromJson: JSON(objAtIndex))
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            label.handleHashtagTap({ ( str : String) in
                //print("HashTag : \(str)")
            })
            
            label.handleMentionTap({ (str : String) in
                //print("Mention : \(str)")
                
                let objData = ["user_name" : str]
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                vc.userData = UserModel(fromJson: JSON(objData))
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
    }
    
    func repostLabelSingleTap(_ sender : UITapGestureRecognizer) {
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            
            //let indexPath
            if let indexPath = tblHome.indexPath(for: cell) {
                if arrayItemData[indexPath.row].repostCount == "0" || arrayItemData[indexPath.row].repostCount == "" {
                    return
                }
                let objRepostersVC = secondStoryBoard.instantiateViewController(withIdentifier: "RepostersVC") as! RepostersVC
                objRepostersVC.dictFromParent.itemId = arrayItemData[indexPath.row].itemId
                self.navigationController?.pushViewController(objRepostersVC, animated: true)
                
            }
            
        }else if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackRepostCell {
            //let indexPath
            if let indexPath = tblHome.indexPath(for: cell) {
                if arrayItemData[indexPath.row].parentItem.repostCount == "0" || arrayItemData[indexPath.row].parentItem.repostCount == "" {
                    return
                }
                let objRepostersVC = secondStoryBoard.instantiateViewController(withIdentifier: "RepostersVC") as! RepostersVC
                objRepostersVC.dictFromParent.itemId = arrayItemData[indexPath.row].parentItem.itemId
                self.navigationController?.pushViewController(objRepostersVC, animated: true)
            }
        }
    }
    
    func likeLabelSingleTap(_ sender : UITapGestureRecognizer) {
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            
            //let indexPath
            if let indexPath = tblHome.indexPath(for: cell) {
                if arrayItemData[indexPath.row].likeCount == "0" || arrayItemData[indexPath.row].likeCount == "" {
                    return
                }
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "LikeListVC") as! LikeListVC
                vc.dictFromParent = ItemModel(fromJson: JSON(arrayItemData[indexPath.row].toDictionary()))
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
        }else if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackMultiImageCell {
            //let indexPath
            if let indexPath = tblHome.indexPath(for: cell) {
                //print("Like Action :- Rack Multiple Cell \(indexPath)")
            }
        }else if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackRepostCell {
            //let indexPath
            if let indexPath = tblHome.indexPath(for: cell) {
                if arrayItemData[indexPath.row].parentItem.likeCount == "0" || arrayItemData[indexPath.row].parentItem.likeCount == "" {
                    return
                }
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "LikeListVC") as! LikeListVC
                vc.dictFromParent = ItemModel(fromJson: JSON(arrayItemData[indexPath.row].parentItem.toDictionary()))
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    func profileViewSingleTap(_ sender : UITapGestureRecognizer) {
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            
            if let indexPath = tblHome.indexPath(for: cell) {
                
                //Require to change view type according to POST type. At WS parsing time
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                vc.userData = UserModel(fromJson: JSON(arrayItemData[indexPath.row].toDictionary()))
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }else if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackRepostCell {
            
            if let indexPath = tblHome.indexPath(for: cell) {
                
                var objAtIndex = arrayItemData[indexPath.row]
                
                if sender == cell.static_imgProfileGesture || sender == cell.static_usernameGesture{
                    objAtIndex = arrayItemData[indexPath.row].parentItem
                }
                
                //Require to change view type according to POST type. At WS parsing time
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                vc.userData = UserModel(fromJson: JSON(objAtIndex.toDictionary()))
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }else if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackMultiImageCell {
            
            if let indexPath = tblHome.indexPath(for: cell) {
                
                //Require to change view type according to POST type. At WS parsing time
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                vc.userData = UserModel(fromJson: JSON(arrayItemData[indexPath.row].toDictionary()))
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func imagePostSingleTap(_ sender : UITapGestureRecognizer) {
        
        /*
         cancelPreviousPerformRequests -
         */
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.autoHideTagCollectionOptionView), object: nil)
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            if let indexPath = tblHome.indexPath(for: cell) {
                cell.imgPost.removeAllPSTagView()
                cell.collectionViewTag.isHidden = !cell.collectionViewTag.isHidden
            }
        }
        
    }
    
    
    func imagePostDoubleTap(_ sender : UITapGestureRecognizer) {
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            
            if let indexPath = tblHome.indexPath(for: cell) {
                
                let dictAtIndex : ItemModel = self.arrayItemData[indexPath.row]
                
                let bigHeart = UIButton(frame: cell.btnLikeBig.frame)
                bigHeart.setImage(#imageLiteral(resourceName: "btnLikeBig"), for: .normal)
                bigHeart.tintColor = .red
                self.tblHome.addSubview(bigHeart)
                self.tblHome.bringSubview(toFront: bigHeart)
                var tapLocation = sender.location(in: cell.contentView)
                let rectOfCellInTableView =  self.tblHome.rectForRow(at: indexPath)
                tapLocation.y = tapLocation.y + rectOfCellInTableView.origin.y
                
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
 
                cell.btnLike.isSelected = true
                cell.btnLike.tintColor = .red
                
                if !dictAtIndex.loginUserLike {
                    
                    dictAtIndex.likeCount = "\(Int(dictAtIndex.likeCount)! + 1)"
                    
                    self.arrayItemData[indexPath.row] = dictAtIndex
                    cell.lblLike.text = GFunction.shared.getProfileCount(dictAtIndex.likeCount)
                    
                    self.tblHome.beginUpdates()
                    self.tblHome.endUpdates()
                }
                
                UIView.animate(withDuration: 0.7, animations: {
                    
                    cell.btnLike.scaleAnimation(0.15, scale: -0.05)
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
                        bigHeart.removeFromSuperview()
            
                        if !dictAtIndex.loginUserLike {
                            
                            dictAtIndex.loginUserLike = true
                            
                            let requestModel = RequestModel()
                            requestModel.item_id = dictAtIndex.itemId
                            requestModel.is_like = cell.btnLike.isSelected ? StatusType.like.rawValue : StatusType.unlike.rawValue
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: dictAtIndex)
                            
                            self.callLikeAPI(requestModel,
                                             withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                                
                            })
                        }
                    })
                }
            }
        }else if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackRepostCell {
            
            if let indexPath = tblHome.indexPath(for: cell) {
                
                let dictAtIndex : ItemModel = self.arrayItemData[indexPath.row].parentItem
                
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
                
                cell.static_btnLike.isSelected = true
                cell.static_btnLike.tintColor = .red
                
                if !dictAtIndex.loginUserLike {
                    
                    dictAtIndex.likeCount = "\(Int(dictAtIndex.likeCount)! + 1)"
                    
                    self.arrayItemData[indexPath.row].parentItem = dictAtIndex
                    cell.static_lblLike.text = GFunction.shared.getProfileCount(dictAtIndex.likeCount)
                    
                    self.tblHome.beginUpdates()
                    self.tblHome.endUpdates()
                }
                
                UIView.animate(withDuration: 0.7, animations: {
                    
                    cell.static_btnLike.scaleAnimation(0.15, scale: -0.05)
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
                        cell.static_btnLikeBig.alpha = 1.0
                        cell.static_btnLikeBig.isHidden = true
                        if !dictAtIndex.loginUserLike {
                            dictAtIndex.loginUserLike = true
                            let requestModel = RequestModel()
                            requestModel.item_id = dictAtIndex.itemId
                            requestModel.is_like = cell.static_btnLike.isSelected ? StatusType.like.rawValue : StatusType.unlike.rawValue
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: dictAtIndex)
                            
                            self.callLikeAPI(requestModel,
                                             withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                                
                            })
                        }
                    })
                }
            }
        }
    }
    
    // PinchGestureRecognizer Method
    func imagePostPinchGesture(_ sender: UIPinchGestureRecognizer) {
        
        if sender.state == .changed || sender.state == .began {
            tblHome.isScrollEnabled = false
        }else{
            tblHome.isScrollEnabled = true
        }
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            //indexpath
            if let _ = tblHome.indexPath(for: cell) {
                TMImageZoom.shared().gestureStateChanged(sender, withZoom: cell.imgPost)
            }
            
            if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
                TMImageZoom.shared().gestureStateChanged(sender, withZoom: cell.imgPost)
            }
        }
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackRepostCell {
            //indexpath
            if let _ = tblHome.indexPath(for: cell) {
                TMImageZoom.shared().gestureStateChanged(sender, withZoom: cell.static_imgPost)
            }
            
            if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
                TMImageZoom.shared().gestureStateChanged(sender, withZoom: cell.static_imgPost)

            }
        }
        
    }
    
    func imagePostPanGesture(sender:UIPanGestureRecognizer){
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            guard cell.pinchGesture.state == .began || cell.pinchGesture.state == .changed || cell.pinchGesture.state == .ended else {return}
            //indexpath
            if let _ = tblHome.indexPath(for: cell) {
                TMImageZoom.shared().moveImage(sender)
            }
        }
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackRepostCell {
            guard cell.pinchGesture.state == .began || cell.pinchGesture.state == .changed || cell.pinchGesture.state == .ended else {return}
            //indexpath
            if let _ = tblHome.indexPath(for: cell) {
                TMImageZoom.shared().moveImage(sender)
            }
            
        }
    }
    
    func autoHideTagCollectionOptionView() {
        
        /*
         max visible cell's timer would start
         */
        
        let visibleRect = CGRect(origin: tblHome.contentOffset, size: tblHome.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath: IndexPath = tblHome.indexPathForRow(at: visiblePoint) {
            if let rackCell = tblHome.cellForRow(at: visibleIndexPath) as? RackCell {
                
                rackCell.collectionViewTag.alpha = 1.0
                UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveLinear, animations: {
                    rackCell.collectionViewTag.alpha = 0.0
                    
                }, completion: { (isComplete : Bool) in
                    rackCell.collectionViewTag.isHidden = true
                    rackCell.collectionViewTag.alpha = 1.0
                })
            }
        }
        
    }
    
    func updateTimeofVisibleCell() {
        
        if let visibleIndexPath = tblHome.indexPathsForVisibleRows {
            for indexPath in visibleIndexPath {
                
                if let cell = tblHome.cellForRow(at: indexPath) as? RackCell {
                    let objAtIndex = arrayItemData[indexPath.row]
                    cell.lblTime.text = objAtIndex.calculatePostTime()
                }else if let cell = tblHome.cellForRow(at: indexPath) as? RackMultiImageCell {
                    let objAtIndex = arrayItemData[indexPath.row]
                    cell.lblTime.text = objAtIndex.calculatePostTime()
                }else if let cell = tblHome.cellForRow(at: indexPath) as? RackRepostCell {
                    let objAtIndex = arrayItemData[indexPath.row]
                    cell.lblTime.text = objAtIndex.calculatePostTime()
                    cell.static_lblTime.text = objAtIndex.parentItem.calculatePostTime()
                }
                
            }
            
        }
        
    }
    
    func addGestureToCell(is_repost : Bool, rackCell : RackCell, cell : RackRepostCell  ) {
        if !is_repost {
            rackCell.imgProfile.removeGestureRecognizer(rackCell.imgProfileGesture)
            rackCell.lblPostType.removeGestureRecognizer(rackCell.lblPostTypeGesture)
            rackCell.lblLike.removeGestureRecognizer(rackCell.likeLabelGesture)
            rackCell.lblRepost.removeGestureRecognizer(rackCell.repostLabelGesture)
            
            rackCell.imgPost.removeGestureRecognizer(rackCell.singleTapGesture)
            rackCell.imgPost.removeGestureRecognizer(rackCell.doubleTapGesture)
            rackCell.imgPost.removeGestureRecognizer(rackCell.pinchGesture)
            rackCell.imgPost.removeGestureRecognizer(rackCell.panGesture)
            //singletap configuration for profileview
            rackCell.imgProfileGesture = UITapGestureRecognizer(target: self, action: #selector(profileViewSingleTap(_:)))
            rackCell.imgProfileGesture.numberOfTapsRequired = 1
            rackCell.imgProfileGesture.numberOfTouchesRequired = 1
            rackCell.imgProfile.addGestureRecognizer(rackCell.imgProfileGesture)
            rackCell.imgProfile.isUserInteractionEnabled = true
            //Set Cell on gesture objc_
            objc_setAssociatedObject(rackCell.imgProfileGesture, &constRackCell, rackCell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            //singletap configuration for profileview
            rackCell.usernameGesture = UITapGestureRecognizer(target: self, action: #selector(profileViewSingleTap(_:)))
            rackCell.usernameGesture.numberOfTapsRequired = 1
            rackCell.usernameGesture.numberOfTouchesRequired = 1
            rackCell.lblUserName.addGestureRecognizer(rackCell.usernameGesture)
            rackCell.lblUserName.isUserInteractionEnabled = true
            //Set Cell on gesture objc_
            objc_setAssociatedObject(rackCell.usernameGesture, &constRackCell, rackCell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            //singletap configuration for likelabel
            rackCell.likeLabelGesture = UITapGestureRecognizer(target: self, action: #selector(likeLabelSingleTap(_:)))
            rackCell.likeLabelGesture.numberOfTapsRequired = 1
            rackCell.likeLabelGesture.numberOfTouchesRequired = 1
            rackCell.lblLike.addGestureRecognizer(rackCell.likeLabelGesture)
            rackCell.lblLike.isUserInteractionEnabled = true
            //Set Cell on gesture objc_
            objc_setAssociatedObject(rackCell.likeLabelGesture, &constRackCell, rackCell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            //singletap configuration for likelabel
            rackCell.repostLabelGesture = UITapGestureRecognizer(target: self, action: #selector(repostLabelSingleTap(_:)))
            rackCell.repostLabelGesture.numberOfTapsRequired = 1
            rackCell.repostLabelGesture.numberOfTouchesRequired = 1
            rackCell.lblRepost.addGestureRecognizer(rackCell.repostLabelGesture)
            rackCell.lblRepost.isUserInteractionEnabled = true
            //Set Cell on gesture objc_
            objc_setAssociatedObject(rackCell.repostLabelGesture, &constRackCell, rackCell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            
            rackCell.lblPostTypeGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnRackName(_:)))
            rackCell.lblPostTypeGesture.numberOfTapsRequired = 1
            rackCell.lblPostTypeGesture.numberOfTouchesRequired = 1
            rackCell.lblPostType.addGestureRecognizer(rackCell.lblPostTypeGesture)
            rackCell.lblPostType.isUserInteractionEnabled = true
            //Set Cell on gesture objc_
            objc_setAssociatedObject(rackCell.lblPostTypeGesture, &constRackCell, rackCell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            //singletap configuration
            rackCell.singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePostSingleTap(_:)))
            rackCell.singleTapGesture.numberOfTapsRequired = 1
            rackCell.singleTapGesture.numberOfTouchesRequired = 1
            rackCell.imgPost.addGestureRecognizer(rackCell.singleTapGesture)
            rackCell.imgPost.isUserInteractionEnabled = true
            //Set rackCell on gesture objc_
            objc_setAssociatedObject(rackCell.singleTapGesture, &constRackCell, rackCell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            //doubletap configuration
            rackCell.doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePostDoubleTap(_:)))
            rackCell.doubleTapGesture.numberOfTapsRequired = 2
            rackCell.doubleTapGesture.numberOfTouchesRequired = 1
            rackCell.imgPost.addGestureRecognizer(rackCell.doubleTapGesture)
            rackCell.imgPost.isUserInteractionEnabled = true
            //Set Cell on gesture objc_
            objc_setAssociatedObject(rackCell.doubleTapGesture, &constRackCell, rackCell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            //fail single when double tap perform
            rackCell.singleTapGesture .require(toFail: rackCell.doubleTapGesture)
            
            //pinchGesture Configuration
            rackCell.pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(imagePostPinchGesture(_:)))
            rackCell.pinchGesture.delegate = self
            rackCell.imgPost.addGestureRecognizer(rackCell.pinchGesture)
            rackCell.imgPost.isUserInteractionEnabled = true
            rackCell.pinchGesture.scale = 1
            objc_setAssociatedObject(rackCell.pinchGesture, &constRackCell, rackCell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            rackCell.panGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePostPanGesture(sender:)))
            rackCell.panGesture.delegate = self
            rackCell.imgPost.addGestureRecognizer(rackCell.panGesture)
            objc_setAssociatedObject(rackCell.panGesture, &constRackCell, rackCell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        } else {
            cell.lblPostType.removeGestureRecognizer(cell.lblPostTypeGesture)
            cell.static_lblPostType.removeGestureRecognizer(cell.static_lblPostTypeGesture)
            cell.static_imgProfile.removeGestureRecognizer(cell.static_imgProfileGesture)
            cell.static_imgPost.removeGestureRecognizer(cell.singleTapGesture)
            cell.static_imgPost.removeGestureRecognizer(cell.doubleTapGesture)
            cell.static_imgPost.removeGestureRecognizer(cell.pinchGesture)
            cell.static_imgPost.removeGestureRecognizer(cell.panGesture)
            cell.lblPostTypeGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnRackName(_:)))
            cell.lblPostTypeGesture.numberOfTapsRequired = 1
            cell.lblPostTypeGesture.numberOfTouchesRequired = 1
            cell.lblPostType.addGestureRecognizer(cell.lblPostTypeGesture)
            cell.lblPostType.isUserInteractionEnabled = true
            
            //Set Cell on gesture objc_
            objc_setAssociatedObject(cell.lblPostTypeGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            //singletap configuration for profileview
            cell.static_usernameGesture = UITapGestureRecognizer(target: self, action: #selector(profileViewSingleTap(_:)))
            cell.static_usernameGesture.numberOfTapsRequired = 1
            cell.static_usernameGesture.numberOfTouchesRequired = 1
            cell.static_lblUserName.addGestureRecognizer(cell.static_usernameGesture)
            cell.static_lblUserName.isUserInteractionEnabled = true
            
            //Set Cell on gesture objc_
            objc_setAssociatedObject(cell.static_usernameGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            //singletap configuration for likelabel
            cell.static_likeLabelGesture = UITapGestureRecognizer(target: self, action: #selector(likeLabelSingleTap(_:)))
            cell.static_likeLabelGesture.numberOfTapsRequired = 1
            cell.static_likeLabelGesture.numberOfTouchesRequired = 1
            cell.static_lblLike.addGestureRecognizer(cell.static_likeLabelGesture)
            cell.static_lblLike.isUserInteractionEnabled = true
            
            //Set Cell on gesture objc_
            objc_setAssociatedObject(cell.static_likeLabelGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            
            
            //singletap configuration for likelabel
            cell.static_repostLabelGesture = UITapGestureRecognizer(target: self, action: #selector(repostLabelSingleTap(_:)))
            cell.static_repostLabelGesture.numberOfTapsRequired = 1
            cell.static_repostLabelGesture.numberOfTouchesRequired = 1
            cell.static_lblRepost.addGestureRecognizer(cell.static_repostLabelGesture)
            cell.static_lblRepost.isUserInteractionEnabled = true
            
            //Set Cell on gesture objc_
            objc_setAssociatedObject(cell.static_repostLabelGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            
            
            
            cell.static_imgProfileGesture = UITapGestureRecognizer(target: self, action: #selector(profileViewSingleTap(_:)))
            cell.static_imgProfileGesture.numberOfTapsRequired = 1
            cell.static_imgProfileGesture.numberOfTouchesRequired = 1
            cell.static_imgProfile.addGestureRecognizer(cell.static_imgProfileGesture)
            cell.static_imgProfile.isUserInteractionEnabled = true
            
            //Set Cell on gesture objc_
            objc_setAssociatedObject(cell.static_imgProfileGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            cell.static_lblPostTypeGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnRackName(_:)))
            cell.static_lblPostTypeGesture.numberOfTapsRequired = 1
            cell.static_lblPostTypeGesture.numberOfTouchesRequired = 1
            cell.static_lblPostType.addGestureRecognizer(cell.static_lblPostTypeGesture)
            cell.static_lblPostType.isUserInteractionEnabled = true
            
            //Set Cell on gesture objc_
            objc_setAssociatedObject(cell.static_lblPostTypeGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            //singletap configuration
            cell.singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePostSingleTap(_:)))
            cell.singleTapGesture.numberOfTapsRequired = 1
            cell.singleTapGesture.numberOfTouchesRequired = 1
            cell.static_imgPost.addGestureRecognizer(cell.singleTapGesture)
            cell.static_imgPost.isUserInteractionEnabled = true
            
            //Set Cell on gesture objc_
            objc_setAssociatedObject(cell.singleTapGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            //doubletap configuration
            cell.doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePostDoubleTap(_:)))
            cell.doubleTapGesture.numberOfTapsRequired = 2
            cell.doubleTapGesture.numberOfTouchesRequired = 1
            cell.static_imgPost.addGestureRecognizer(cell.doubleTapGesture)
            cell.static_imgPost.isUserInteractionEnabled = true
            
            //Set Cell on gesture objc_
            objc_setAssociatedObject(cell.doubleTapGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            //fail single when double tap perform
            cell.singleTapGesture .require(toFail: cell.doubleTapGesture)
            
            //pinchGesture Configuration
            cell.pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(imagePostPinchGesture(_:)))
            cell.pinchGesture.delegate = self
            cell.static_imgPost.addGestureRecognizer(cell.pinchGesture)
            cell.static_imgPost.isUserInteractionEnabled = true
            cell.pinchGesture.scale = 1
            
            objc_setAssociatedObject(cell.pinchGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            cell.panGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePostPanGesture(sender:)))
            cell.panGesture.delegate = self
            cell.static_imgPost.addGestureRecognizer(cell.panGesture)
            
            objc_setAssociatedObject(cell.panGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func showAnimationMethod() {
        self.view.addSubview(self.normalCellPopUp)
        self.normalCellPopUp.isHidden = true
        self.normalCellPopUp.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1.0)
        
        UIView.animate(withDuration: 0.1
            , animations: {
                self.normalCellPopUp.isHidden = false
                self.normalCellPopUp.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }) { (complete : Bool) in
            
        }
    }
    
    func addNoFollowersFoundView() {
        self.viewNoFollowerFound.frame = self.tblHome.frame
        if !self.tblHome.subviews.contains(self.viewNoFollowerFound) {
            self.tblHome.addSubview(self.viewNoFollowerFound)
        }
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationWant(_ notification : Notification) {
        /*
         Unwant -> delete it from table
         */
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        let notiItemData = jsonData
        
        let predict = NSPredicate(format: "ownerUid LIKE %@ AND shareType == want",notiItemData.ownerUid!)
        let temp = arrayItemData.filter({ predict.evaluate(with: $0) })
        
        if !temp.isEmpty {
            if let index = self.arrayItemData.index(of: temp[0]) {
                self.arrayItemData.remove(at: index)
                self.tblHome.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
                
                self.tblHome.reloadData()
            }
        }
    }
    
    func notificationItemDataUpdate(_ notification : Notification) {
        /* Notification Post Method call
         1. Comment VC add msg
         2. Comment view add msg
         3. Update want or unwant
         */
        
        //        //print("============Notification Method Called=================")
        //        //print(notification.object!)
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        let notiItemData = jsonData
        //change main data
        
        arrayItemData = arrayItemData.map { (objFollow : ItemModel) -> ItemModel in
            if objFollow.parentId != "0" && objFollow.parentId != "" {
                if objFollow.parentItem.itemId == notiItemData.itemId && notiItemData.isFolderUpdated != true {
                    objFollow.parentItem = notiItemData
                    return objFollow
                }else if objFollow.rackData.rackId == notiItemData.rackId && notiItemData.isFolderUpdated == true  {
                    objFollow.rackData.rackName = notiItemData.rackName
                    return objFollow
                }else if objFollow.parentItem.rackData != nil && objFollow.parentItem.rackData.rackId == notiItemData.rackId && notiItemData.isFolderUpdated == true  {
                    objFollow.parentItem.rackData.rackName = notiItemData.rackName
                    return objFollow
                }else{
                    
                    if objFollow.itemId == notiItemData.itemId && notiItemData.isFolderUpdated != true {
                        return notiItemData
                    }else{
                        return objFollow
                    }
                    
                }
            }else{
                if objFollow.itemId == notiItemData.itemId && notiItemData.isFolderUpdated != true{
                    return notiItemData
                }else if objFollow.rackData.rackId == notiItemData.rackId && notiItemData.isFolderUpdated == true {
                    objFollow.rackData.rackName = notiItemData.rackName
                    return objFollow
                }else{
                    return objFollow
                }
            }
        }
        self.tblHome.reloadData()
    }
    
    func notificationItemDataDelete(_ notification : Notification) {
        
        //        //print("============Notification Method Called=================")
        //        //print(notification.object!)
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        let notiItemData = jsonData
        //change main data
        
        arrayItemData = arrayItemData.filter { (objFollow : ItemModel) -> Bool in
            if objFollow.parentId != "0" && objFollow.parentId != "" {
                if objFollow.itemId == notiItemData.itemId && notiItemData.isFolderUpdated != true {
                    return false
                }else if objFollow.rackData.rackId == notiItemData.rackId && notiItemData.isFolderUpdated == true  {
                    return false
                }else if objFollow.parentItem.rackData != nil && objFollow.parentItem.rackData.rackId == notiItemData.rackId && notiItemData.isFolderUpdated == true  {
                    return false
                }else{
                    return true
                }
            }else{
                if objFollow.itemId == notiItemData.itemId && notiItemData.isFolderUpdated != true{
                    return false
                }else if objFollow.rackData.rackId == notiItemData.rackId && notiItemData.isFolderUpdated == true {
                    return false
                }else{
                    return true
                }
            }
        }
        
        arrayItemData = arrayItemData.filter({ (objFollow : ItemModel) -> Bool in
            
            let cellType = RackCellType(rawValue: objFollow.rackCell)
            
            switch cellType! {
            case .normalCell, .repostCell:
                return true
            case .multiImageCell:
                
                objFollow.itemData = objFollow.itemData.filter({ (objFollow : ItemModel) -> Bool in
                    if objFollow.itemId == notiItemData.itemId {
                        return false
                    } else {
                        return true
                    }
                })
                
                /*
                 Like carousel would display only if item data count is greater or equal to 5
                 else remove that block from newsfeed
                 
                 Updated count is shown after item is deleted that exists in like carousel
                 */
                if objFollow.itemData.count >= 5 {
                    objFollow.userLikeCount = "LIKED \(objFollow.itemData.count) ITEMS"
                } else {
                    return false
                }
                
                return true
            case .repostCell:
                return false
            }
        })
        
        //        UIView.animate(withDuration: 0.0, animations: {
        //            DispatchQueue.main.async {
        self.tblHome.reloadData()
        //            }
        //        }, completion: { (Bool) in
        ////            self.view.layoutIfNeeded()
        //        })
        
        if arrayItemData.count == 0 {
            self.tblHome.bounces = false
            self.addNoFollowersFoundView()
        }
    }
    
    
    func notificationRackFeedUpdate(_ notification : Notification) {
        self.viewNoFollowerFound.removeFromSuperview()
        self.perform(#selector(self.addLoaderWithDelayPullToRefresh), with: nil, afterDelay: 0.0)
    }
    
    
    func notificationNewPostAdded(_ notification : Notification) {
        /* Notification Post Method call
         1. Comment VC add msg
         2. Comment view add msg
         */
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        let notiItemData = jsonData
        arrayItemData.insert(notiItemData, at: 0)
        self.tblHome.reloadData()
        //self.tblHome.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.automatic)
        self.tblHome.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: false)
        self.tblHome.bounces = true
        self.viewNoFollowerFound.removeFromSuperview()
    }
    
    func notificationUserDetailsUpdate(_ notification : Notification) {
        
        guard let _  = tblHome else {
            return
        }
        self.tblHome.reloadData()
    }
    
    func notificationRepostCountUpdate(_ notification : Notification) {
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        let notiItemData = jsonData
        //change main data
        arrayItemData = arrayItemData.map { (objFollow : ItemModel) -> ItemModel in
            
            if notiItemData.shareType == PostShareType.repost.rawValue && notiItemData.subParentId == objFollow.itemId {
                objFollow.loginUserRepost = true
            }
            
            if objFollow.itemId == notiItemData.parentId || objFollow.itemId == notiItemData.itemId || objFollow.parentId == notiItemData.parentId {
                objFollow.repostCount = notiItemData.repostCount
                return objFollow
            } else {
                return objFollow
            }
        }
        
        arrayItemData = arrayItemData.filter({ (objFollow : ItemModel) -> Bool in
            
            let cellType = RackCellType(rawValue: objFollow.rackCell)
            
            switch cellType! {
            case .normalCell:
                return true
            case .multiImageCell:
                
                objFollow.itemData = objFollow.itemData.map { (objFollow : ItemModel) -> ItemModel in
                    
                    if notiItemData.shareType == PostShareType.repost.rawValue && notiItemData.subParentId == objFollow.itemId {
                        objFollow.loginUserRepost = true
                    }
                    
                    if objFollow.itemId == notiItemData.parentId || objFollow.itemId == notiItemData.itemId || objFollow.parentId == notiItemData.parentId {
                        objFollow.repostCount = notiItemData.repostCount
                        return objFollow
                    } else {
                        return objFollow
                    }
                }
                return true
            case .repostCell:
                return true
            }
        })
        
        self.tblHome.reloadData()
        
    }
    
    func notificationUnfollow(_ notification : Notification) {
        
        guard let jsonData   = notification.object as? Any else {
            return
        }
        
        let notiItemData = UserModel(fromJson: notification.object as! JSON)
        
        let predict1 = NSPredicate(format: "userId != %@",notiItemData.userId)
        
        self.arrayItemData = self.arrayItemData.filter({ predict1.evaluate(with: $0) })
        
        if self.arrayItemData.isEmpty {
            self.tblHome.bounces = false
            self.addNoFollowersFoundView()
        }else{
            self.tblHome.bounces = true
            self.viewNoFollowerFound.removeFromSuperview()
        }
        
        self.tblHome.reloadData()
        
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callItemListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/itemlist
         
         Parameter   : type[top,down]
         
         Optional    : timestamp, pass_timestamp
         
         Comment     : This api will used for any user get follower and following list.
         
         ==============================
         */
        
        APICall.shared.PUT(strURL: kMethodItemList
            , parameter: requestModel.toDictionary()
            , withErrorAlert : false
        ) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            self.isWSCalling = true
            if (error == nil) {
                
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    self.callAfterServiceResponse(response[kData],pageRefresh: PageRefreshType(rawValue: requestModel.type)!)
                    self.tblHome.bounces = true
                    block(true)
                    
                    break
                    
                case myfeedlistempty:
                    self.tblHome.ins_endInfinityScroll(withStoppingContentOffset: true)
                    self.tblHome.bounces = false
                    self.arrayItemData.removeAll()
                    self.tblHome.reloadData()
                    self.addNoFollowersFoundView()
                    
                    block(false)
                    break
                    
                default:
                    self.tblHome.ins_endInfinityScroll(withStoppingContentOffset: true)
                    
                    block(false)
                    break
                }
            } else {
                self.tblHome.ins_endInfinityScroll(withStoppingContentOffset: true)
                
                block(false)
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
                    
                    //Google Analytics
                    
                    let category = "UI"
                    let action = "\(UserModel.currentUser.displayName!) liked an item"
                    let lable = ""
                    let screenName = "Feed"
                    googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                    
                    //Google Analytics
                    
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
    
    func callWantAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : item/itemwant
         
         Parameter   : item_id
         
         Optional    :
         
         Comment     : This api will used for user to save particular item to want list.
         
         ==============================
         */
        
        APICall.shared.CancelTask(url: kMethodWantList)
        
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
    
    func callUserDataAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : user/user_data
         
         Parameter   : user_name
         
         Optional    :
         
         Comment     : This api will used for user can view user by username
         
         
         ==============================
         
         */
        
        APICall.shared.PUT(strURL: kMethodUserData
            , parameter: requestModel.toDictionary()
            , withErrorAlert : false
        ) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    block(true,response[kData])
                    break
                    
                default:
                    
                    block(false, nil)
                    break
                }
            } else {
                block(false, nil)
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
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    func btnDotTapped(_ sender : UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if let dictAtIndex = arrayItemData[indexPath.row] as? ItemModel {
            
            if let cell = tblHome.cellForRow(at: indexPath) as? RackCell {
                
                guard cell.imgPost.image != nil && cell.imgPost.image!.size != CGSize.zero else {
                    return
                }
                
                self.dotButtonClicked(dictFromParent: dictAtIndex, imgPost: cell.imgPost.image!, imgProfile: UIImage(), isRepost: false)
                
            }
            
            if let cell = tblHome.cellForRow(at: indexPath) as? RackRepostCell {
                
                guard cell.static_imgPost.image != nil && cell.static_imgPost.image!.size != CGSize.zero else {
                    return
                }
                
                guard cell.static_imgProfile.image != nil && cell.static_imgProfile.image!.size != CGSize.zero else {
                    return
                }
                
                self.dotButtonClicked(dictFromParent: dictAtIndex, imgPost: cell.static_imgPost.image!, imgProfile: cell.static_imgProfile.image!, isRepost: true)
                
            }
            
        }
        
    }
    
    func dotButtonClicked(dictFromParent: ItemModel, imgPost: UIImage, imgProfile: UIImage, isRepost: Bool) {
        
        if dictFromParent.userId == UserModel.currentUser.userId {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionDelete = UIAlertAction(title: "Delete Post", style: .default) { (action : UIAlertAction) in
                AlertManager.shared.showAlertTitle(title: "", message: "Delete this post? This cannot be undone.", buttonsArray: ["Delete","Cancel"]) { (buttonIndex : Int) in
                    switch buttonIndex {
                    case 0 :
                        
                        let requestModel = RequestModel()
                        requestModel.item_id = dictFromParent.itemId
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailDelete), object: dictFromParent)
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
                                requestModel.item_id = dictFromParent.itemId
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
                vc.reportId = dictFromParent.itemId
                vc.reportType = .item
                vc.offenderId = dictFromParent.userId
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                
            }
            
            actionSheet.addAction(actionReport)
            actionSheet.addAction(actionCancel)
            
            self.present(actionSheet, animated: true, completion: nil)
        }
        
    }
    
    func btnLikeClicked(_ sender : UIButton) {
        
        guard let indexPath = sender.buttonIndexPath  else {
            return
        }
        
        let objAtIndex = arrayItemData[indexPath.row]
        let cellType = RackCellType(rawValue: objAtIndex.rackCell)
        
        if cellType == .normalCell {
            guard let cell = tblHome.cellForRow(at: indexPath) as? RackCell else {
                return
            }
            //            cell.btnLike.scaleAnimation(0.15, scale: -0.05)
            
            let dictAtIndex : ItemModel = arrayItemData[indexPath.row]
            let status = dictAtIndex.loginUserLike!
            dictAtIndex.loginUserLike = !status
            
            if !status {
                cell.btnLike.tintColor = .red
                cell.btnLike.tumblerLikeAnimation(view: cell.buttonView)
            }else{
                cell.btnLike.tintColor = .black
            }
            
            cell.btnLike.isSelected = !status
            dictAtIndex.likeCount = cell.btnLike.isSelected ? "\(Int(dictAtIndex.likeCount)! + 1)" : "\(Int(dictAtIndex.likeCount)! - 1)"
            arrayItemData[indexPath.row] = dictAtIndex
            
            cell.lblLike.text = GFunction.shared.getProfileCount(dictAtIndex.likeCount)
            
            let requestModel = RequestModel()
            requestModel.item_id = dictAtIndex.itemId
            requestModel.is_like = cell.btnLike.isSelected ? StatusType.like.rawValue : StatusType.unlike.rawValue
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: dictAtIndex)
            
            self.callLikeAPI(requestModel,
                             withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
            })
        }else{
            guard let cell = tblHome.cellForRow(at: indexPath) as? RackRepostCell else {
                return
            }
            let dictAtIndex : ItemModel = arrayItemData[indexPath.row].parentItem
            let status = dictAtIndex.loginUserLike!
            dictAtIndex.loginUserLike = !status
            
            if !status {
                cell.static_btnLike.tintColor = .red
                cell.static_btnLike.tumblerLikeAnimation(view: cell.static_buttonView)
            }else{
                cell.static_btnLike.tintColor = .black
            }
            
            cell.static_btnLike.isSelected = !status
            dictAtIndex.likeCount = cell.static_btnLike.isSelected ? "\(Int(dictAtIndex.likeCount)! + 1)" : "\(Int(dictAtIndex.likeCount)! - 1)"
            arrayItemData[indexPath.row].parentItem = dictAtIndex
            
            cell.static_lblLike.text = GFunction.shared.getProfileCount(dictAtIndex.likeCount)
            
            let requestModel = RequestModel()
            requestModel.item_id = dictAtIndex.itemId
            requestModel.is_like = cell.static_btnLike.isSelected ? StatusType.like.rawValue : StatusType.unlike.rawValue
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: dictAtIndex)
            
            self.callLikeAPI(requestModel,
                             withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
            })
        }
        
    }
    
    func btnCommentClicked(_ sender : UIButton) {
        
        guard let indexPath = sender.buttonIndexPath  else {
            return
        }
        
        let objAtIndex = arrayItemData[indexPath.row]
        let cellType = RackCellType(rawValue: objAtIndex.rackCell)
        
        if cellType == .normalCell {
            guard let cell = tblHome.cellForRow(at: indexPath) as? RackCell else {
                return
            }
            
            let dictAtIndex : ItemModel = arrayItemData[indexPath.row]
            
            cell.btnComment.scaleAnimation(0.15, scale: -0.05)
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
            vc.dictFromParent = dictAtIndex
            vc.copyDictFromParent = dictAtIndex
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            guard let cell = tblHome.cellForRow(at: indexPath) as? RackRepostCell else {
                return
            }
            
            let dictAtIndex : ItemModel = arrayItemData[indexPath.row].parentItem
            cell.static_btnComment.scaleAnimation(0.15, scale: -0.05)
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
            vc.dictFromParent = dictAtIndex
            vc.copyDictFromParent = dictAtIndex
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        
    }
    
    func btnRepostClicked(_ sender : UIButton) {
        
        guard let indexPath = sender.buttonIndexPath  else {
            return
        }
        
        let objAtIndex = arrayItemData[indexPath.row]
        let cellType = RackCellType(rawValue: objAtIndex.rackCell)
        
        if cellType == .normalCell {
            
            
            
            guard let cell = tblHome.cellForRow(at: indexPath) as? RackCell else {
                return
            }
            cell.repostBtnGuideView.tipDismiss(forAnim: .aRepostPhoto)
            cell.repostBtnGuideView.saveTapActivity(forAnim: .aRepostPhoto)
            guard cell.imgPost.image != nil && cell.imgPost.image!.size != CGSize.zero else {
                return
            }
            
            let dictAtIndex : ItemModel = self.arrayItemData[indexPath.row]
            if !dictAtIndex.loginUserRepost {
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let quickRepost = UIAlertAction(title: "Quick Repost", style: .default) { (action : UIAlertAction) in
                    cell.btnRepost.scaleAnimation(0.15, scale: -0.05)
                    let objAtIndex = self.arrayItemData[indexPath.row]
                    let obj = secondStoryBoard.instantiateViewController(withIdentifier: "QuickRepostVC") as! QuickRepostVC
                    if let imgPost = cell.imgPost.image {
                        obj._imgPost = imgPost
                    }
                    obj._tvCaptionText = objAtIndex.caption
                    obj.rackName = objAtIndex.rackData.rackName
                    obj._dictFromParent = objAtIndex
                    
                    let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
                    navigationController.navigationBar.barStyle = .default
                    self.present(navigationController, animated: true, completion: nil)
                }
                
                let repostWithCaption = UIAlertAction(title: "Repost & Add Caption", style: .default) { (action : UIAlertAction) in
                    let objAtIndex = self.arrayItemData[indexPath.row]
                    if !objAtIndex.loginUserRepost {
                        let obj = secondStoryBoard.instantiateViewController(withIdentifier: "RepostAddCaptionVC") as! RepostAddCaptionVC
                        if let imgPost = cell.imgPost.image {
                            obj._imgPost = imgPost
                        }
                        if let imgProfile = cell.imgProfile.image {
                            obj._postUserProfile = imgProfile
                        }
                        obj._postUsername = cell.lblUserName.text!
                        obj._postType = cell.lblPostType.text!
                        obj._tvCaptionText = objAtIndex.caption
                        obj._dictFromParent = objAtIndex
                        
                        let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
                        navigationController.navigationBar.barStyle = .default
                        self.present(navigationController, animated: true, completion: nil)
                    }
                }
                
                let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                }
                
                actionSheet.addAction(quickRepost)
                actionSheet.addAction(repostWithCaption)
                actionSheet.addAction(actionCancel)
                
                self.present(actionSheet, animated: true, completion: nil)
            }
            
        }else{
            
            guard let cell = tblHome.cellForRow(at: indexPath) as? RackRepostCell else {
                return
            }
            guard cell.static_imgPost.image != nil && cell.static_imgPost.image!.size != CGSize.zero else {
                return
            }
            
            let dictAtIndex : ItemModel = self.arrayItemData[indexPath.row].parentItem
            if !dictAtIndex.loginUserRepost {
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let quickRepost = UIAlertAction(title: "Quick Repost", style: .default) { (action : UIAlertAction) in
                    cell.static_btnRepost.scaleAnimation(0.15, scale: -0.05)
                    if let objAtIndex = self.arrayItemData[indexPath.row].parentItem {
                        let obj = secondStoryBoard.instantiateViewController(withIdentifier: "QuickRepostVC") as! QuickRepostVC
                        if let imgPost = cell.static_imgPost.image {
                            obj._imgPost = imgPost
                        }
                        obj._tvCaptionText = objAtIndex.caption
                        obj.rackName = objAtIndex.rackData.rackName
                        obj._dictFromParent = objAtIndex
                        
                        let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
                        navigationController.navigationBar.barStyle = .default
                        self.present(navigationController, animated: true, completion: nil)
                    }
                }
                
                let repostWithCaption = UIAlertAction(title: "Repost & Add Caption", style: .default) { (action : UIAlertAction) in
                    
                    let dictAtIndex : ItemModel = self.arrayItemData[indexPath.row].parentItem
                    if !dictAtIndex.loginUserRepost {
                        if let objAtIndex = self.arrayItemData[indexPath.row].parentItem {
                            let obj = secondStoryBoard.instantiateViewController(withIdentifier: "RepostAddCaptionVC") as! RepostAddCaptionVC
                            if let imgPost = cell.static_imgPost.image {
                                obj._imgPost = imgPost
                            }
                            if let imgProfile = cell.static_imgProfile.image {
                                obj._postUserProfile = imgProfile
                            }
                            obj._postUsername = cell.static_lblUserName.text!
                            obj._postType = cell.static_lblPostType.text!
                            obj._tvCaptionText = objAtIndex.caption
                            obj._dictFromParent = objAtIndex
                            
                            let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
                            navigationController.navigationBar.barStyle = .default
                            self.present(navigationController, animated: true, completion: nil)
                        }
                    }
                }
                
                let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                }
                
                actionSheet.addAction(quickRepost)
                actionSheet.addAction(repostWithCaption)
                actionSheet.addAction(actionCancel)
                
                self.present(actionSheet, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func btnWantClicked(_ sender : UIButton)  {
        
        guard let indexPath = sender.buttonIndexPath  else {
            return
        }
        
        let objAtIndex = arrayItemData[indexPath.row]
        let cellType = RackCellType(rawValue: objAtIndex.rackCell)
        
        if cellType == .normalCell {
            
            guard let cell = tblHome.cellForRow(at: indexPath) as? RackCell else {
                return
            }
            cell.btnWant.scaleAnimation(0.15, scale: -0.05)
            
            cell.saveBtnGuideView.tipDismiss(forAnim: .aSaveRack)
            cell.saveBtnGuideView.saveTapActivity(forAnim: .aSaveRack)
            
            let status = objAtIndex.loginUserWant!
            if !status {
                let obj = secondStoryBoard.instantiateViewController(withIdentifier: "FoldersListVC") as! FoldersListVC
                
                guard cell.imgPost.image != nil else {
                    return
                }
                
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
                
                cell.btnWant.isSelected = !status
                objAtIndex.loginUserWant = !status
                
                self.callWantAPI(requestModel,
                                 withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                    if isSuccess {
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationProfileUpdate), object: nil)
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: objAtIndex)
                                    } else {}
                })
            }
            
        }else{
            
            guard let cell = tblHome.cellForRow(at: indexPath) as? RackRepostCell else {
                return
            }
            
            cell.static_btnWant.scaleAnimation(0.15, scale: -0.05)
            if let objAtIndex = arrayItemData[indexPath.row].parentItem {
                
                let status = objAtIndex.loginUserWant!
                if !status {
                    let obj = secondStoryBoard.instantiateViewController(withIdentifier: "FoldersListVC") as! FoldersListVC
                    
                    guard cell.static_imgPost.image != nil else {
                        return
                    }
                    
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
                    
                    cell.static_btnWant.isSelected = !status
                    objAtIndex.loginUserWant = !status
                    
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
    
    @IBAction func btnNoFollower(_ sender: UIButton) {
        let vc : FollowFriendVC = mainStoryBoard.instantiateViewController(withIdentifier: "FollowFriendVC") as! FollowFriendVC
        vc.userData = UserModel.currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //------------------------------------------------------
    
    //MARK:- ScrollView Delegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        if scrollView .isEqual(tblHome) {
            
            /*
             cancelPreviousPerformRequests -
             */
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.autoHideTagCollectionOptionView), object: nil)
            self.perform(#selector(self.autoHideTagCollectionOptionView), with: nil, afterDelay: 5.0)
        }
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        /*if scrollView .isEqual(scrollViewMain){
         currentImageView.translatesAutoresizingMaskIntoConstraints = false
         return currentImageView
         }*/
        return nil
    }
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:- Check whether to show onboarding or no
        //        let requestModel = RequestModel()
        //        requestModel.tutorial_type = tutorialFlag.Newsfeed.rawValue
        //        GFunction.shared.getTutorialState(requestModel) { (isSuccess: Bool) in
        //            if isSuccess {
        //                let onBoarding = mainStoryBoard.instantiateViewController(withIdentifier: "OnboardingBaseVC") as! OnboardingBaseVC
        //                onBoarding.tutorialType = .Newsfeed
        //                self.present(onBoarding, animated: false, completion: nil)
        //            } else {
        //
        //            }
        //        }
        
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = addBarButtons(btnLeft: nil, btnRight: nil, title: "", isSwipeBack: false)
       
        let image = UIImage(named: "logoSmall")
        let imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.black
        self.navigationItem.titleView = imageView // UIImageView(image: #imageLiteral(resourceName: "logoSmall"))
        
        //Google Analytics
        let category = "UI"
        let action = "\(UserModel.currentUser.displayName!) view feeds"
        let lable = ""
        let screenName = "Feed"
        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
        //Google Analytics
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = addBarButtons(btnLeft: nil, btnRight: nil, title: "", isSwipeBack: false)
        if let indxPaths = tblHome.indexPathsForVisibleRows
        {
            for indx in indxPaths {
                if indx == repostAddedIndexPath || indx == wantAddedIndexPath {
                    tblHome.reloadRows(at: [indx], with: .none)
                }
            }
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        if let visibleIndexPaths = tblHome.indexPathsForVisibleRows {
            for indexPath in visibleIndexPaths {
                if indexPath == self.repostAddedIndexPath && indexPath == self.wantAddedIndexPath {
                    guard let cell = tblHome.cellForRow(at: indexPath) as? RackCell else {
                        return
                    }
            cell.repostBtnGuideView.tipDismiss(forAnim: .aRepostPhoto)
            cell.saveBtnGuideView.tipDismiss(forAnim: .aSaveRack)
                }
            }
        }
    }
    
    
}

extension RackVC : PSTableDelegateDataSource/*, UITableViewDataSourcePrefetching*/ {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayItemData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let objAtIndex = arrayItemData[indexPath.row]
        let cellType = RackCellType(rawValue: objAtIndex.rackCell)
        
        switch cellType! {
        case .normalCell:
            return UITableViewAutomaticDimension
        case .multiImageCell:
            return (kScreenWidth / 3.2) + (60.0)
        case .repostCell:
            return UITableViewAutomaticDimension
        }
    }
    
    /*
     Like flickering issue solution
     Please dont remove this code - Start
     */
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
            return CGFloat(height.floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Like flickering issue solution
        let height = NSNumber(value: Float(cell.frame.size.height))
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
        let objAtIndex = arrayItemData[indexPath.row]
        let cellType = RackCellType(rawValue: objAtIndex.rackCell)
        switch cellType! {
        case .normalCell:
            if let cell = cell as? RackCell {
                cell.imgPost.setImageWithDownload(objAtIndex.image.url())
                cell.imgProfile.setImageWithDownload(objAtIndex.getUserProfile().url())
                let width  : Float = Float(objAtIndex.width)!
                let height : Float = Float(objAtIndex.height)!
                let heightConstant = kScreenWidth / CGFloat(width) * CGFloat(height)
                if Float(heightConstant) > Float(kScreenHeight - 108) {
                    cell.constImageHeight.constant = kScreenWidth
                    cell.imgPost.contentMode = .scaleAspectFill
                    
                } else {
                    cell.constImageHeight.constant = kScreenWidth / CGFloat(width) * CGFloat(height)
                    cell.imgPost.contentMode = .scaleToFill
                }
            }
        case .repostCell:
            if let cell = cell as? RackRepostCell {
                cell.static_imgPost.setImageWithDownload(objAtIndex.image.url())
                cell.static_imgProfile.setImageWithDownload(objAtIndex.getUserProfile().url())
                let width  : Float = Float(objAtIndex.width)!
                let height : Float = Float(objAtIndex.height)!
                let heightConstant = kScreenWidth / CGFloat(width) * CGFloat(height)
                if Float(heightConstant) > Float(kScreenHeight - 108) {
                    cell.static_constImageHeight.constant = kScreenWidth
                    cell.static_imgPost.contentMode = .scaleAspectFill
                    
                } else {
                    cell.static_constImageHeight.constant = kScreenWidth / CGFloat(width) * CGFloat(height)
                    cell.static_imgPost.contentMode = .scaleToFill
                }
            }
        default:
            break
        }
    }
    
    // Cell configuration code, shared by -tableView:cellForRowAtIndexPath: and reconfigureVisibleCells
    func configureNormalCell(cell: RackCell, forRowAtIndexPath indexPath: IndexPath) {
        
        let objAtIndex = arrayItemData[indexPath.row]
        cell.imgPost.setImageWithDownload(objAtIndex.image.url())
        
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            cell.imgProfile.setImageWithDownload(objAtIndex.getUserProfile().url())
        })
        
        cell.selectionStyle = .none
        
        DispatchQueue.main.async {
            cell.saveBtnGuideView.tipDismiss(forAnim: .aSaveRack)
            cell.repostBtnGuideView.tipDismiss(forAnim: .aRepostPhoto)
        }
        
        //Manage using height constant.
        let width  : Float = Float(objAtIndex.width)!
        let height : Float = Float(objAtIndex.height)!
        let heightConstant = kScreenWidth / CGFloat(width) * CGFloat(height)
        
        if Float(heightConstant) > Float(kScreenHeight - 108) {
            cell.constImageHeight.constant = kScreenWidth
            cell.imgPost.contentMode = .scaleAspectFill
        } else {
            cell.constImageHeight.constant = kScreenWidth / CGFloat(width) * CGFloat(height)
            cell.imgPost.contentMode = .scaleToFill
        }
        
        cell.lblUserName.text = objAtIndex.getUserName()
        if let rackName = objAtIndex.rackData.rackName {
            cell.lblPostType.text = "\(rackName)"
        }
        
        cell.lblTime.text = objAtIndex.calculatePostTime()
        cell.btnDot.tag = indexPath.row
        
        let str = objAtIndex.caption.count > 0 ? "\(objAtIndex.getUserName()) \(objAtIndex.caption!)" : ""
        cell.lblDetail.text = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        //comment lable click management. Hast Tag , UserName and mentioned user
        cell.lblDetail.numberOfLines = 0
        self.setUpDetailText(cell.lblDetail,userName : objAtIndex.caption.count > 0 ? objAtIndex.getUserName() : "", obj : objAtIndex)
        
        if objAtIndex.caption.count == 0 {
            cell.lblDetail.isHidden = true
            cell.constLblDetailHeight.constant = 0
            cell.constLblDetailYPos.constant = 0
        } else {
            let lblHeight = cell.lblDetail.text!.getHeight(withConstrainedWidth: (kScreenWidth-18), font: UIFont.applyBold(fontSize: 12.0))
            cell.constLblDetailHeight.constant = lblHeight
            cell.lblDetail.isHidden = false
            cell.constLblDetailYPos.constant = 8
        }
        
        //like button state management
        cell.btnLike.isSelected = objAtIndex.loginUserLike
        if cell.btnLike.isSelected {
            cell.btnLike.tintColor = .red
        }else{
            cell.btnLike.tintColor = .black
        }
        
        cell.btnComment.isSelected = objAtIndex.loginUserComment
        
        //want button state management
        cell.btnWant.isSelected = objAtIndex.loginUserWant
        
        //repost button state management
        cell.btnRepost.isSelected = objAtIndex.loginUserRepost
        
        //1. owner's user item, dont show repost button
        //2. from ws if repost = no, dont show repost button
        if objAtIndex.userId != UserModel.currentUser.userId {
            if objAtIndex.repost == "yes"  {
                cell.btnRepost.isUserInteractionEnabled = true
                cell.btnRepost.isHidden = false
                cell.btnRepost.tintColor = .lightGray
                cell.lblRepost.isHidden = false
                
                if (repostAddedIndexPath == nil || indexPath.row == repostAddedIndexPath?.row) && !objAtIndex.loginUserRepost {
                    repostAddedIndexPath = indexPath
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                        if let imageView = cell.btnRepost.imageView {
                            cell.repostBtnGuideView.addTip(.top, forView: imageView, withinSuperview: self.tblHome, textType: .tRepostPhoto, forAnim: .aRepostPhoto)
                            cell.repostBtnGuideView.addAnimation(imageView, withinSuperview: false, forAnim: .aRepostPhoto)
                        }
                    })
                }
            } else {
                cell.btnRepost.isUserInteractionEnabled = false
                cell.btnRepost.isHidden = false
                cell.btnRepost.tintColor = UIColor.colorFromHex(hex: kColorLightGray)
                cell.lblRepost.isHidden = false
            }
        } else {
            cell.btnRepost.isUserInteractionEnabled = false
            cell.btnRepost.isHidden = false
            cell.btnRepost.tintColor = UIColor.colorFromHex(hex: kColorLightGray)
            cell.lblRepost.isHidden = false
        }
        
        //want button state management
        //1. owner's user item, dont show want button
        if objAtIndex.userId == UserModel.currentUser.userId {
            cell.btnWant.isHidden = true
        } else {
            cell.btnWant.isHidden = false
            if (wantAddedIndexPath == nil || indexPath.row == wantAddedIndexPath?.row) && !objAtIndex.loginUserWant{
                wantAddedIndexPath = indexPath
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    if let imageView = cell.btnWant.imageView {
                        cell.saveBtnGuideView.addTip(.bottom, forView: imageView, withinSuperview: self.tblHome, textType: .tSaveRack, forAnim: .aSaveRack)
                        cell.saveBtnGuideView.addAnimation(imageView, withinSuperview: true, forAnim: .aSaveRack)
                    }
                })
            }
        }
        
        cell.lblLike.text = GFunction.shared.getProfileCount(objAtIndex.likeCount)
        cell.lblComment.text = GFunction.shared.getProfileCount(objAtIndex.commentCount)
        cell.lblRepost.text = GFunction.shared.getProfileCount(objAtIndex.repostCount)
        cell.btnLikeBig.isHidden = true
        cell.collectionViewTag.isHidden = false
        
        //addAction for cell button
        cell.btnDot.removeTarget(nil, action: nil, for: .allEvents)
        cell.btnComment.removeTarget(nil, action: nil, for: .allEvents)
        cell.btnRepost.removeTarget(nil, action: nil, for: .allEvents)
        cell.btnWant.removeTarget(nil, action: nil, for: .allEvents)
        cell.btnDot.addTarget(self, action: #selector(btnDotTapped(_:)), for: .touchUpInside)
        cell.btnLike.addTarget(self, action: #selector(btnLikeClicked(_:)), for: .touchUpInside)
        cell.btnComment.addTarget(self, action: #selector(btnCommentClicked(_:)), for: .touchUpInside)
        cell.btnRepost.addTarget(self, action: #selector(btnRepostClicked(_:)), for: .touchUpInside)
        cell.btnWant.addTarget(self, action: #selector(btnWantClicked(_:)), for: .touchUpInside)
        //add indexpth in to buttonIndex
        cell.btnLike.buttonIndexPath     = indexPath
        cell.btnComment.buttonIndexPath  = indexPath
        cell.btnRepost.buttonIndexPath   = indexPath
        cell.btnWant.buttonIndexPath     = indexPath
        
        // add spacing between characters
        let valueCharSpace: CGFloat = 0.5
        cell.lblUserName.addCharacterSpacing(value: valueCharSpace)
        cell.lblPostType.addCharacterSpacing(value: valueCharSpace)
        cell.lblTime.addCharacterSpacing(value: valueCharSpace)
        cell.lblLike.addCharacterSpacing(value: valueCharSpace)
        cell.lblComment.addCharacterSpacing(value: valueCharSpace)
        cell.lblRepost.addCharacterSpacing(value: valueCharSpace)
        cell.lblDetail.addCharacterSpacing(value: valueCharSpace)
        
        
        //remove All subview of image
        cell.imgPost.removeAllPSTagView()
        
        cell.configureCollectionViewForTag(objAtIndex)
        
        //To manage click of tag option collection click in to rack VC
        cell.tagOptionSelectionSelection = { tagIndexPath , type in
            //             //print("Item Indedx Path ",indexPath.row,"Tag Index path :",tagIndexPath.row)
            
            cell.imgPost.removeAllPSTagView()
            cell.collectionViewTag.isHidden = true
            
            switch type {
                
            case .none:
                //             //print("Require to handel User Post...")
                
                if let userData = objAtIndex as? ItemModel {
                    //Require to change view type according to POST type. At WS parsing time
                    let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                    vc.viewType = .other
                    vc.fromPage = .otherPage
                    
                    let userData = UserModel()
                    userData.userId = objAtIndex.ownerUid
                    vc.userData = UserModel(fromJson: JSON(userData.toDictionary()))
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                break
            case .tagBrand ,.tagItem ,.tagPeople, .addLink:
                
                //Change Datasource and Also change parameter of showTagOnImage at service time.
                
                //For Passing Tag Taga With Image
                let scaleFactor = cell.imgPost.image?.getPostImageScaleFactor(kScreenWidth)
                
                guard cell.imgPost.image != nil else {
                    return
                }
                
                if let tagData = objAtIndex.tagDetail {
                    
                    if type.rawValue == TagType.tagBrand.rawValue {
                        
                        let detail = tagData.brandTag
                        let tagDetail = SimpleTagModel.dictArrayFromModelArray(array: detail!)
                        
                        let tagView = PSTagView.showTagOnImage(tagDetail, parentView: cell.imgPost, mainImage : cell.imgPost.image!, searchType: searchFlagType.brand)
                        for singleTag in tagView {
                            singleTag.delegate = self
                            cell.imgPost.addSubview(singleTag)
                        }
                    } else if type.rawValue == TagType.tagItem.rawValue {
                        
                        let detail = tagData.itemTag
                        let tagDetail = SimpleTagModel.dictArrayFromModelArray(array: detail!)
                        
                        let tagView = PSTagView.showTagOnImage(tagDetail, parentView: cell.imgPost, mainImage : cell.imgPost.image!, searchType: searchFlagType.item)
                        for singleTag in tagView {
                            singleTag.delegate = self
                            cell.imgPost.addSubview(singleTag)
                        }
                    } else if type.rawValue == TagType.addLink.rawValue {
                        
                        let detail = tagData.linkTag
                        let tagDetail = LinkTagModel.dictArrayFromModelArray(array: detail!)
                        let tagView = PSTagView.showTagOnImage(tagDetail, parentView: cell.imgPost, mainImage : cell.imgPost.image!, searchType: searchFlagType.link)
                        for singleTag in tagView {
                            singleTag.delegate = self
                            cell.imgPost.addSubview(singleTag)
                        }
                    } else if type.rawValue == TagType.tagPeople.rawValue {
                        
                        let detail = tagData.userTag
                        let tagDetail = PeopleTagModel.dictArrayFromModelArray(array: detail!)
                        let tagView = PSTagView.showTagOnImage(tagDetail, parentView: cell.imgPost, mainImage : cell.imgPost.image!, searchType: searchFlagType.people)
                        for singleTag in tagView {
                            singleTag.delegate = self
                            cell.imgPost.addSubview(singleTag)
                        }
                    }
                }
                break
            default:
                break
            }
            
        }
        self.addGestureToCell(is_repost: false, rackCell: cell, cell: RackRepostCell())
    }
    
    func configureMultiImageCell(cell: RackMultiImageCell, forRowAtIndexPath indexPath: IndexPath) {
        
        let objAtIndex = arrayItemData[indexPath.row]
        cell.configureMultiImageCell(objAtIndex.itemData)
        cell.imgProfile.setImageWithDownload(objAtIndex.getUserProfile().url())
        cell.lblUserName.text = objAtIndex.getUserName()
        cell.lblPostType.text = objAtIndex.userLikeCount
        cell.lblTime.text = objAtIndex.calculatePostTime()
        
        //singletap configuration for profileview
        cell.imgProfileGesture = UITapGestureRecognizer(target: self, action: #selector(profileViewSingleTap(_:)))
        cell.imgProfileGesture.numberOfTapsRequired = 1
        cell.imgProfileGesture.numberOfTouchesRequired = 1
        cell.imgProfile.addGestureRecognizer(cell.imgProfileGesture)
        cell.imgProfile.isUserInteractionEnabled = true
        
        //Set Cell on gesture objc_
        objc_setAssociatedObject(cell.imgProfileGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        //singletap configuration for profileview
        cell.usernameGesture = UITapGestureRecognizer(target: self, action: #selector(profileViewSingleTap(_:)))
        cell.usernameGesture.numberOfTapsRequired = 1
        cell.usernameGesture.numberOfTouchesRequired = 1
        cell.lblUserName.addGestureRecognizer(cell.usernameGesture)
        cell.lblUserName.isUserInteractionEnabled = true
        
        //Set Cell on gesture objc_
        objc_setAssociatedObject(cell.usernameGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // add spacing between characters
        let valueCharSpace: CGFloat = 0.5
        cell.lblUserName.addCharacterSpacing(value: valueCharSpace)
        cell.lblPostType.addCharacterSpacing(value: valueCharSpace)
        cell.lblTime.addCharacterSpacing(value: valueCharSpace)
        
        //Getting Index From collectionview selected indexpath
        cell.multiImageSelection = { imageIndexPath in
            
            if self.arrayItemData.count != 0 && indexPath.row < self.arrayItemData.count {
                if imageIndexPath.row < self.arrayItemData[indexPath.row].itemData.count && self.arrayItemData[indexPath.row].itemData.count != 0{
                    let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ItemDetailVC") as! RackDetailVC
                    vc.dictFromParent = (self.arrayItemData[indexPath.row]).itemData[imageIndexPath.row]
                    self.navigationController?.pushViewController(vc, animated: true)
                
                }
                
            }
            }
    }
    
    func configureRepostCell(cell: RackRepostCell, forRowAtIndexPath indexPath: IndexPath) {
        
        let objAtIndex = arrayItemData[indexPath.row]
        cell.static_containerView.backgroundColor = .white
        cell.lblUserName.text = objAtIndex.getUserName()
        
        if let rackName = objAtIndex.rackData.rackName {
            cell.lblPostType.text = "\(rackName)"
        }
        
        let str = objAtIndex.caption.count > 0 ? "\(objAtIndex.caption!)" : ""
        cell.lblDetail.text = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileViewSingleTap(_:)))
        cell.lblUserName.isUserInteractionEnabled = true
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        cell.lblUserName.addGestureRecognizer(tapGesture)
        
        //Set Cell on gesture objc_
        objc_setAssociatedObject(tapGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        //comment lable click management. Hast Tag , UserName and mentioned user
        cell.lblDetail.numberOfLines = 0
        self.setUpDetailText(cell.lblDetail,userName : objAtIndex.caption.count > 0 ? objAtIndex.getUserName() : "", obj : objAtIndex)
        
        if objAtIndex.caption.count == 0 {
            cell.lblDetail.isHidden = true
            cell.constLblDetailHeight.constant = 0
            cell.staticContainerYPos.constant = 0
        } else {
            let lblHeight = cell.lblDetail.text!.getHeight(withConstrainedWidth: (kScreenWidth-18), font: UIFont.applyBold(fontSize: 12.0))
            cell.constLblDetailHeight.constant = lblHeight
            cell.lblDetail.isHidden = false
            cell.staticContainerYPos.constant = 8
        }
        
        cell.lblTime.text = objAtIndex.calculatePostTime()
        cell.btnDot.addTarget(self, action: #selector(btnDotTapped(_:)), for: .touchUpInside)
        cell.btnDot.tag = indexPath.row
        
        // add spacing between characters
        let valueCharSpace: CGFloat = 0.5
        cell.lblUserName.addCharacterSpacing(value: valueCharSpace)
        cell.lblPostType.addCharacterSpacing(value: valueCharSpace)
        cell.lblTime.addCharacterSpacing(value: valueCharSpace)
        
        if let staticObjAtIndex = objAtIndex.parentItem {
            
            guard staticObjAtIndex.profile != nil else {
                return
            }
            
            cell.static_lblUserName.text = staticObjAtIndex.getUserName()
            
            if let rackName = staticObjAtIndex.rackData.rackName {
                cell.static_lblPostType.text = "\(rackName)"
            }
            
            cell.static_imgPost.setImageWithDownload(staticObjAtIndex.image.url()/*, itemData : objAtIndex*/)
            
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                cell.static_imgProfile.setImageWithDownload(staticObjAtIndex.profile.url())
            })
            
            cell.static_lblTime.text = staticObjAtIndex.calculatePostTime()
            
            cell.selectionStyle = .none
            
            //Manage using height constant.
            let width  : Float = Float(objAtIndex.width)!
            let height : Float = Float(objAtIndex.height)!
            let heightConstant = kScreenWidth / CGFloat(width) * CGFloat(height)
            
            if Float(heightConstant) > Float(kScreenHeight - 108) {
                cell.static_constImageHeight.constant = kScreenWidth
                cell.static_imgPost.contentMode = .scaleAspectFill
            } else {
                cell.static_constImageHeight.constant = kScreenWidth / CGFloat(width) * CGFloat(height)
                cell.static_imgPost.contentMode = .scaleToFill
            }
            
            let str = staticObjAtIndex.caption.count > 0 ? "\(staticObjAtIndex.getUserName()) \(staticObjAtIndex.caption!)" : ""
            cell.static_lblDetail.text = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            //comment lable click management. Hast Tag , UserName and mentioned user
            cell.static_lblDetail.numberOfLines = 0
            self.setUpDetailText(cell.static_lblDetail,userName : staticObjAtIndex.caption.count > 0 ? staticObjAtIndex.getUserName() : "", obj : staticObjAtIndex)
            
            if staticObjAtIndex.caption.count == 0 {
                cell.static_lblDetail.isHidden = true
                cell.static_constLblDetailYPos.constant = 0
                cell.static_constLblDetailHeight.constant = 0
            } else {
                let lblHeight = cell.static_lblDetail.text!.getHeight(withConstrainedWidth: (kScreenWidth-18), font: UIFont.applyBold(fontSize: 12.0))
                cell.static_constLblDetailHeight.constant = lblHeight
                cell.static_lblDetail.isHidden = false
                cell.static_constLblDetailYPos.constant = 8
            }
            
            //like button state management
            cell.static_btnLike.isSelected = staticObjAtIndex.loginUserLike
            if cell.static_btnLike.isSelected {
                cell.static_btnLike.tintColor = .red
            }else{
                cell.static_btnLike.tintColor = .black
            }
            
            cell.static_btnComment.isSelected = staticObjAtIndex.loginUserComment
            //want button state management
            cell.static_btnWant.isSelected = staticObjAtIndex.loginUserWant
            //repost button state management
            cell.static_btnRepost.isSelected = staticObjAtIndex.loginUserRepost
            //want button state management
            
            //1. owner's user item, dont show want button
            if staticObjAtIndex.userId == UserModel.currentUser.userId {
                cell.static_btnWant.isHidden = true
            } else {
                cell.static_btnWant.isHidden = false
            }
            
            //1. owner's user item, dont show repost button
            //2. from ws if repost = no, dont show repost button
            if objAtIndex.userId != UserModel.currentUser.userId {
                cell.static_btnRepost.isUserInteractionEnabled = true
            }else{
                cell.static_btnRepost.isUserInteractionEnabled = false
            }
            cell.static_btnRepost.tintColor = UIColor.colorFromHex(hex: kColorLightGray)
            
            cell.static_btnLikeBig.isHidden = true
            
            cell.static_lblLike.text = GFunction.shared.getProfileCount(staticObjAtIndex.likeCount)
            cell.static_lblComment.text = GFunction.shared.getProfileCount(staticObjAtIndex.commentCount)
            cell.static_lblRepost.text = GFunction.shared.getProfileCount(staticObjAtIndex.repostCount)
            cell.static_btnLike.addTarget(self, action: #selector(btnLikeClicked(_:)), for: .touchUpInside)
            cell.static_btnComment.addTarget(self, action: #selector(btnCommentClicked(_:)), for: .touchUpInside)
            cell.static_btnRepost.addTarget(self, action: #selector(btnRepostClicked(_:)), for: .touchUpInside)
            cell.static_btnWant.addTarget(self, action: #selector(btnWantClicked(_:)), for: .touchUpInside)
            
            //add indexpth in to buttonIndex
            cell.static_btnLike.buttonIndexPath = indexPath
            cell.static_btnComment.buttonIndexPath = indexPath
            cell.static_btnRepost.buttonIndexPath = indexPath
            cell.static_btnWant.buttonIndexPath = indexPath
            
            // add spacing between characters
            let valueCharSpace: CGFloat = 0.5
            cell.static_lblUserName.addCharacterSpacing(value: valueCharSpace)
            cell.static_lblPostType.addCharacterSpacing(value: valueCharSpace)
            cell.static_lblTime.addCharacterSpacing(value: valueCharSpace)
            cell.static_lblLike.addCharacterSpacing(value: valueCharSpace)
            cell.static_lblComment.addCharacterSpacing(value: valueCharSpace)
            cell.static_lblRepost.addCharacterSpacing(value: valueCharSpace)
            cell.static_lblDetail.addCharacterSpacing(value: valueCharSpace)
            
        }
        
        self.addGestureToCell(is_repost: true, rackCell:RackCell() , cell: cell)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objAtIndex = arrayItemData[indexPath.row]
        let cellType = RackCellType(rawValue: objAtIndex.rackCell)
        if arrayItemData.count - 5 == indexPath.row {
            self.tblHome.ins_beginInfinityScroll()
        }
        if cellType == .normalCell {
            let cell =  tableView.dequeueReusableCell(withIdentifier:"idRackCell", for: indexPath) as! RackCell
            self.configureNormalCell(cell: cell, forRowAtIndexPath: indexPath)
            return cell
        }else if cellType == .multiImageCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "idRackMultiImageCell", for: indexPath) as! RackMultiImageCell
            configureMultiImageCell(cell: cell, forRowAtIndexPath: indexPath)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "idRackRepostCell", for: indexPath) as! RackRepostCell
            configureRepostCell(cell: cell, forRowAtIndexPath: indexPath)
            return cell
        }
    }
    
    func tapOnRackName(_ sender: UITapGestureRecognizer){
        
        var objAtIndex = ItemModel()
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            if let indexPath = tblHome.indexPath(for: cell) {
                objAtIndex = arrayItemData[indexPath.row]
            }
        }else if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackRepostCell {
            if let indexPath = tblHome.indexPath(for: cell) {
                if sender == cell.lblPostTypeGesture {
                    objAtIndex = arrayItemData[indexPath.row]
                }else{
                    objAtIndex = arrayItemData[indexPath.row].parentItem
                }
            }
        }else{
            return
        }
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "RackFolderListVC") as! RackFolderListVC
        
        vc.userData = UserModel(fromJson: JSON(objAtIndex.toDictionary()))
        if objAtIndex.userId == UserModel.currentUser.userId {
            vc.viewType = .me
        } else {
            vc.viewType = .other
        }
        vc.dictFromParent = objAtIndex.rackData
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

extension RackVC : PSTagViewTapDelegate {
    
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

extension RackVC : NormalCellPopUpDelegate {
    func handleBtnClick(btn : NormalCellType, data : ItemModel, img : UIImage) {
        
        if btn == .edit {
            
            let obj = secondStoryBoard.instantiateViewController(withIdentifier: "UploadVC") as! UploadVC
            obj.imgPost = img
            obj.dictFromParent = data
            obj.shareType = .main
            
            let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
            navigationController.navigationBar.barStyle = .default
            self.present(navigationController, animated: true, completion: nil)
            
        } else if btn == .report {
            
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
            vc.reportId = data.userId
            vc.reportType = .item
            vc.offenderId = data.userId
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            //            //print("Button delete pressed")
        }
    }
}

extension RackVC : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}



//MARK:-
//MARK:- RackCell -
//MARK:-
class RackCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var profileView : UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblPostType: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnDot: UIButton!
    
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var btnLikeBig: UIButton!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var lblRepost: UILabel!
    @IBOutlet weak var btnRepost: UIButton!
    @IBOutlet weak var btnWant: UIButton!
    @IBOutlet weak var lblDetail: ActiveLabel!
    
    @IBOutlet weak var collectionViewTag: UICollectionView!
    @IBOutlet weak var constCollectionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var constImageHeight: NSLayoutConstraint!
    @IBOutlet var constLblDetailHeight: NSLayoutConstraint!
    @IBOutlet var constLblDetailYPos: NSLayoutConstraint!
    @IBOutlet var constlineSepratorYPos: NSLayoutConstraint!
    
    var repostBtnGuideView = GuideView()
    var saveBtnGuideView = GuideView()
    
    var arrayTagType : [Dictionary<String,Any>] = [Dictionary<String,Any>]()
    //To manage dyanamic hegith width for tag collectionView
    let collectionCellHeight = 30
    let collectionCellSpacing = 5
    var lblPostTypeGesture = UITapGestureRecognizer()
    var imgProfileGesture  = UITapGestureRecognizer()
    var usernameGesture    = UITapGestureRecognizer()
    var likeLabelGesture   = UITapGestureRecognizer()
    var repostLabelGesture = UITapGestureRecognizer()
    var doubleTapGesture   = UITapGestureRecognizer()
    var singleTapGesture   = UITapGestureRecognizer()
    var pinchGesture       = UIPinchGestureRecognizer()
    var panGesture         = UIPanGestureRecognizer()
    var tagOptionSelectionSelection :((IndexPath,TagType) -> Void)?
    
    /*var isZooming = false
     var originalImageCenter:CGPoint?
     var pan = UIPanGestureRecognizer()*/
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        // fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgProfile.applyStype(cornerRadius: imgProfile.frame.size.height / 2)
        lblUserName.applyStyle(labelFont: UIFont.applyArialBold(fontSize: 12.0), labelColor: AppColor.textB)
        lblPostType.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0), labelColor: AppColor.textB)
        lblTime.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0), labelColor: AppColor.textLightGray)
        btnLikeBig.isHidden = true
        lblLike.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 11.0,isAspectRasio: true), labelColor: AppColor.textLightGray)
        lblComment.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 11.0,isAspectRasio: true), labelColor: AppColor.textLightGray)
        lblRepost.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 11.0,isAspectRasio: true), labelColor: AppColor.textLightGray)
        lblDetail.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 11.0), labelColor: UIColor.black)
        
        collectionViewTag.dataSource = self
        collectionViewTag.delegate = self
        collectionViewTag.isHidden = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func btnTapAnimation(_ sender : UIView) {
        
        UIView.animate(withDuration: 3.0, animations: {
            
            self.contentView.isUserInteractionEnabled = false
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            
        }) { (isComplete : Bool) in
            
            UIView.animate(withDuration: 3.0, animations: {
                sender.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                
            }, completion: { (isComplete : Bool) in
                self.contentView.isUserInteractionEnabled = true
            })
        }
    }
    
    func configureCollectionViewForTag(_ sender : Any?) {
        /* ===========================================================
         //TODO: Configuration CollectionView from cellForRowAtIndexPath of tableView.
         =========================================================== */
        
        arrayTagType = [
            ["img" : #imageLiteral(resourceName: "iconUserPost") ,kAction : TagType.none],
            ["img" : #imageLiteral(resourceName: "iconTag") ,kAction : TagType.tagBrand],
            ["img" : #imageLiteral(resourceName: "iconProdTag") ,kAction : TagType.tagItem],
            ["img" : #imageLiteral(resourceName: "iconUserTag") ,kAction : TagType.tagPeople],
            ["img" : #imageLiteral(resourceName: "iconAddLink") ,kAction : TagType.addLink]
        ]
        
        let itemDetail = (sender as! ItemModel)
        
        let tagDetail = itemDetail.tagDetail
        
        arrayTagType = arrayTagType.filter({ (objTag : Dictionary<String, Any>) -> Bool in
            let detail = tagDetail?.toDictionary()
            return detail![(objTag[kAction] as! TagType).rawValue] != nil && (detail![(objTag[kAction] as! TagType).rawValue] as! [Dictionary<String, Any>]).count > 0
        })
        
        if itemDetail.userId != itemDetail.ownerUid {
            arrayTagType.insert(["img" : #imageLiteral(resourceName: "iconUserPost") ,kAction : TagType.none], at: 0)
        }
        
        collectionViewTag.reloadData()
        
        //CollectionView Height Management. if User tag option will be dynamic.For Now its static if dyanamic then uncomment following code.
        let collectionHeight = (arrayTagType.count * collectionCellHeight) //+ ((arrayTagType.count - 1) * collectionCellSpacing)
        self.constCollectionHeight.constant = CGFloat(collectionHeight)
    }
    
}

class RackRepostCell: UITableViewCell{
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblPostType: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnDot: UIButton!
    @IBOutlet weak var lblDetail: ActiveLabel!
    @IBOutlet var constLblDetailHeight: NSLayoutConstraint!
    @IBOutlet var staticContainerYPos: NSLayoutConstraint!
    
    // Repost View Static Outlets
    @IBOutlet weak var static_containerView: UIView!
    @IBOutlet var static_profileView : UIView!
    @IBOutlet weak var static_imgProfile: UIImageView!
    @IBOutlet weak var static_lblUserName: UILabel!
    @IBOutlet weak var static_lblPostType: UILabel!
    @IBOutlet weak var static_lblTime: UILabel!
    @IBOutlet weak var static_imgPost: UIImageView!
    
    @IBOutlet weak var static_buttonView: UIView!
    @IBOutlet weak var static_lblLike: UILabel!
    @IBOutlet weak var static_lblComment: UILabel!
    @IBOutlet weak var static_lblRepost: UILabel!
    @IBOutlet weak var static_lblDetail: ActiveLabel!
    
    @IBOutlet weak var static_btnLikeBig: UIButton!
    @IBOutlet weak var static_btnLike: UIButton!
    @IBOutlet weak var static_btnComment: UIButton!
    @IBOutlet weak var static_btnRepost: UIButton!
    @IBOutlet weak var static_btnWant: UIButton!
    
    @IBOutlet weak var static_constImageHeight: NSLayoutConstraint!
    @IBOutlet var static_constLblDetailHeight: NSLayoutConstraint!
    @IBOutlet var static_constLblDetailYPos: NSLayoutConstraint!
    
    var lblPostTypeGesture = UITapGestureRecognizer()
    var static_lblPostTypeGesture = UITapGestureRecognizer()
    var static_imgProfileGesture = UITapGestureRecognizer()
    var imgProfileGesture = UITapGestureRecognizer()
    var static_usernameGesture = UITapGestureRecognizer()
    var static_likeLabelGesture = UITapGestureRecognizer()
    var static_repostLabelGesture = UITapGestureRecognizer()
    var doubleTapGesture = UITapGestureRecognizer()
    var singleTapGesture = UITapGestureRecognizer()
    var pinchGesture = UIPinchGestureRecognizer()
    var panGesture = UIPanGestureRecognizer()
    
    var tagOptionSelectionSelection :((IndexPath,TagType) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblUserName.applyStyle(labelFont: UIFont.applyArialBold(fontSize: 12.0), labelColor: AppColor.textB)
        lblPostType.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0), labelColor: AppColor.textB)
        lblTime.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0), labelColor: AppColor.textLightGray)
        
        lblDetail.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 11.0), labelColor: UIColor.black)
        
        // Repost View variables
        static_imgProfile.applyStype(cornerRadius: static_imgProfile.frame.size.height / 2)
        
        static_lblUserName.applyStyle(labelFont: UIFont.applyArialBold(fontSize: 12.0), labelColor: AppColor.textB)
        static_lblPostType.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0), labelColor: AppColor.textB)
        static_lblTime.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0), labelColor: AppColor.textLightGray)
        
        static_lblLike.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0,isAspectRasio: true), labelColor: AppColor.textLightGray)
        static_lblComment.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0,isAspectRasio: true), labelColor: AppColor.textLightGray)
        static_lblRepost.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0,isAspectRasio: true), labelColor: AppColor.textLightGray)
        
        static_lblDetail.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 11.0), labelColor: UIColor.black)
        
    }
    
    func btnTapAnimation(_ sender : UIView) {
        
        UIView.animate(withDuration: 3.0, animations: {
            
            self.contentView.isUserInteractionEnabled = false
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            
        }) { (isComplete : Bool) in
            
            UIView.animate(withDuration: 3.0, animations: {
                sender.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                
            }, completion: { (isComplete : Bool) in
                self.contentView.isUserInteractionEnabled = true
            })
        }
    }
    
}

extension RackCell : PSCollectinViewDelegateDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayTagType.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dictAtIndex = arrayTagType[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RackTagCell", for: indexPath) as! RackTagCell
        cell.imgIcon.image = dictAtIndex["img"] as? UIImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dictAtIndex = arrayTagType[indexPath.row]
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell!.scaleAnimation(0.15, scale: -0.05)
        
        //manage tag in rack vc
        self.tagOptionSelectionSelection!(indexPath,dictAtIndex[kAction] as! TagType)
    }
    
}

//MARK:- RackTagCell -
class RackTagCell: UICollectionViewCell {
    
    @IBOutlet var imgIcon : UIImageView!
    
}

//MARK:- RackMultiImageCell -
class RackMultiImageCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var profileView : UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblPostType: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var collectionImage: UICollectionView!
    
    var imgProfileGesture  = UITapGestureRecognizer()
    var usernameGesture = UITapGestureRecognizer()
    var multiImageSelection :((IndexPath) -> Void)?
    var arrayImage : [ItemModel] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgProfile.applyStype(cornerRadius: imgProfile.frame.size.height / 2)
        lblUserName.applyStyle(labelFont: UIFont.applyArialBold(fontSize: 12.0), labelColor: AppColor.textB)
        lblPostType.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0), labelColor: AppColor.text)
        lblTime.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0), labelColor: AppColor.textLightGray)
        
        collectionImage.delegate = self
        collectionImage.dataSource = self
    }
    
    func configureMultiImageCell(_ sender : [ItemModel]?) {
        
        if let _ = sender {
            self.arrayImage = sender!
            collectionImage.reloadData()
        }
        
    }
}

extension RackMultiImageCell : PSCollectinViewDelegateDataSource/*, UICollectionViewDataSourcePrefetching*/ {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? RackCollectioCell {
            cell.imgView.setImageWithDownload(self.arrayImage[indexPath.row].image.url())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RackCollectioCell", for: indexPath) as! RackCollectioCell
        cell.imgView.setImageWithDownload(self.arrayImage[indexPath.row].image.url())
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kScreenWidth / 3.2, height: (kScreenWidth / 3.2))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Call in to RackVC TableView CellForRowAtIndex
        self.multiImageSelection!(indexPath)
    }
}

//MARK:- RackCollectioCell -
class RackCollectioCell: UICollectionViewCell {
    
    @IBOutlet var imgView : UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.contentMode = .scaleAspectFill
    }
    
}

extension UILabel {
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }
}

