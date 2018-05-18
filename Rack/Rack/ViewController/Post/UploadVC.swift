//
//  UploadVC.swift
//  Rack
//
//  Created by hyperlink on 25/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import AFNetworking
import FBSDKCoreKit
import FBSDKLoginKit
import PinterestSDK
import TMTumblrSDK

protocol SearchTagDelegate {
    func searchTagDelegateMethod(_ tagDetail : Any, tagType : TagType?);
}

protocol UploadCell {
    func didTap(tagType : TagType);
}

class UploadVC: UIViewController, UISearchBarDelegate {
    var guideView = GuideView()
    let categories             = NSMutableArray()
    var isImageSwitchChange    : Bool = false
    var isRepostSwitchChange   : Bool = true
    var rackImage:Any!         = nil
    var rackName:String        = ""
    typealias cellType         = uploadCellType
    typealias action           = TagType
    var postImageAddTagVC      :PostImageAddTagVC! = nil
    let categoriesVC           = CategoriesVC()
    let selectedCategories     = NSMutableArray()
    var page                   : Int = 1
    let activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView()
    var arrayItemData: [folderStructure] = []
    typealias EditCompletion = ()->Void
    var editCompletion: EditCompletion!
    //MARK:- Outlet
    @IBOutlet var tblPost      : UITableView!
    @IBOutlet var viewFooter   : UIView!
    @IBOutlet var lblShare     : UILabel!
    @IBOutlet var btnFacebook  : UIButton!
    @IBOutlet var btnPinterest : UIButton!
    @IBOutlet var btnTwitter   : UIButton!
    @IBOutlet var btnTumblr    : UIButton!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var imgPost      : UIImage!
    var dataToUpload : NSData!

    
    var arrayCellType : [Dictionary<String,Any>] = [
        [kCellType : cellType.postImageCell, kTitle : "", kImage : "", kAction : action.none],
        [kCellType : cellType.tagTypeCell, kTitle : "Tag Post", kImage :  #imageLiteral(resourceName: "iconTagWhite"), kAction : action.tagBrand],
        [kCellType : cellType.createRackCell, kTitle : "Select Rack", kImage :  #imageLiteral(resourceName: "iconRepostWhite"), kAction : action.none],
        [kCellType : cellType.switchTypeCell, kTitle : "Reposts", kImage :  #imageLiteral(resourceName: "iconRepostWhite"), kAction : action.none],
        [kCellType : cellType.switchTypeCell, kTitle : "Pin Image", kImage :  #imageLiteral(resourceName: "iconRepostWhite"), kAction : action.none],
         [kCellType : cellType.optionSelectionCell, kTitle : "Category", kImage :  #imageLiteral(resourceName: "iconTagWhite"), kAction : action.none],
        ]
    
    var arrayTagData : [Dictionary<String,[PSTagView]>] = [
        [TagType.none.rawValue : []]
        ,[TagType.tagBrand.rawValue : []]
        ,[TagType.tagItem.rawValue : []]
        ,[TagType.tagPeople.rawValue : []]
        ,[TagType.addLink.rawValue : []]
    ]
    
    var shareType : PostShareType = .main
    var dictFromParent : ItemModel? = nil
    var imgView = UIImageView()
    var hmc : GGHashtagMentionController = GGHashtagMentionController()
    var arraySocialKeys : [Dictionary<String , Dictionary<String,Any>>] = []
//    var completeAuthOp: FKDUNetworkOperation!
//    var checkAuthOp: FKDUNetworkOperation!
    
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
    
    func setUpData() {
        
        let indexPath = IndexPath(row: 2, section: 0)
        let cell = tblPost.cellForRow(at: indexPath) as! RackTableViewCell
        self.page = 1
        let requestModel = RequestModel()
        requestModel.user_id = UserModel.currentUser.userId
        requestModel.page = String(format: "%d", (self.page))
        cell.activiyIndicator.startAnimating()
        self.activityIndicatorView.frame = self.view.bounds
        self.callRackListAPI(requestModel, withCompletion: { (isSuccess) in
            if isSuccess {
                let objAtIndex = self.arrayItemData[0]
                self.rackName = objAtIndex.name
                self.rackImage = objAtIndex.thumbnail
            }else{
                self.rackName = "Rack"
                self.rackImage = self.imgPost
                let firstData = folderStructure.modelsFromLocalDictionary(rackname: self.rackName, image: self.rackImage as! UIImage)
                self.arrayItemData.append(contentsOf: firstData)
            }
            cell.activiyIndicator.stopAnimating()
            cell.activiyIndicator.isHidden = true
            self.tblPost.reloadData()
        })
        
    }
    
    func callRackListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/racklist
         
         Parameter   : user_id
         
         Optional    : page
         
         Comment     : This api will used for fetch User Racks
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodRackList
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    if self.page == 1{
                        self.arrayItemData.removeAll()
                    }
                    
                    let newData = (folderStructure.modelsFromDictionaryArray(array: response[kData].arrayValue))
                    self.arrayItemData.append(contentsOf: newData)
                    self.page = (self.page) + 1
                    block(true)
                    break
                    
                default:
                    
                    //stop pagination
                    if self.page == 1{
                        self.arrayItemData.removeAll()
                    }
                    
                    block(false)
                    
                    break
                }
            } else {
                
                block(false)
            }
        }
    }
    
    func setUpView() {
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height:0))
        customView.addSubview(viewFooter)
        customView.clipsToBounds = true
        customView.backgroundColor = UIColor.clear
        tblPost.tableFooterView = customView
        
        lblShare.applyStyle(labelFont: UIFont.applyBold(fontSize: 13.0), labelColor: AppColor.text)
        btnFacebook.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 13.0), titleLabelColor: AppColor.text)
        btnTumblr.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 13.0), titleLabelColor: AppColor.text)
        btnTwitter.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 13.0), titleLabelColor: AppColor.text)
        btnPinterest.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 13.0), titleLabelColor: AppColor.text)
         self.navigationController?.customize()
        if dictFromParent != nil {
            
            guard imgPost != nil && imgPost!.size != CGSize.zero else {
                return
            }
            
            imgView = UIImageView(image: imgPost.imageScale(scaledToWidth: kScreenWidth))
            //For Passing Tag Taga With Image
            let scaleFactor = imgPost.getPostImageScaleFactor(kScreenWidth)
            
            //===============================Brand Data
            
            var brandModel = (dictFromParent?.tagDetail.brandTag!)!
            
            //change image (x,y) to pass
            brandModel = SimpleTagModel.changeTagCondinateTomDeviceImageScaleFactor(brandModel, scaleFactor: Float(scaleFactor))
            
            //get all brand data
            let arrayBrandTag = SimpleTagModel.dictArrayFromModelArray(array: brandModel)
            
            //Convert [Dictionary<String,Any>] to [PSTagView]
            //ParentView => Main image parents frame
            
            var arrayPsTagBrand : [PSTagView]!
            arrayPsTagBrand = arrayBrandTag.map({ (obj : Dictionary<String,Any>) -> PSTagView in
                
                let point = CGPoint(x: Double.init((obj["x_axis"] as! String))!, y: Double.init((obj["y_axis"] as! String))!)
                var jsonDict : Dictionary<String,Any> = obj
                jsonDict["id"] = obj[kID]
                jsonDict["name"] = obj["name"]
                jsonDict["x_axis"] = point.x
                jsonDict["y_axis"] = point.y
                
                let tagDetail = SimpleTagModel(fromJson: JSON(jsonDict))
                
                return PSTagView(tagName: obj["name"] as! String, x: point.x, y: point.y, parrentView: UIImageView(frame: CGRect(x: 0, y: 0, width: imgView.frame.width, height: imgView.frame.height)), tagDetail: tagDetail)
            })
            
            arrayTagData[TagType.tagBrand.hashValue] = [TagType.tagBrand.rawValue : arrayPsTagBrand]
            
            //===============================Item Data
            
            var itemModel = (dictFromParent?.tagDetail.itemTag!)!
            
            //change image (x,y) to pass
            itemModel = SimpleTagModel.changeTagCondinateTomDeviceImageScaleFactor(itemModel, scaleFactor: Float(scaleFactor))
            
            //get all item data
            let arrayItemTag = SimpleTagModel.dictArrayFromModelArray(array: itemModel)
            
            //Convert [Dictionary<String,Any>] to [PSTagView]
            //ParentView => Main image parents frame
            
            var arrayPsTagItem : [PSTagView]!
            arrayPsTagItem = arrayItemTag.map({ (obj : Dictionary<String,Any>) -> PSTagView in
                
                let point = CGPoint(x: Double.init((obj["x_axis"] as! String))!, y: Double.init((obj["y_axis"] as! String))!)
                var jsonDict : Dictionary<String,Any> = obj
                jsonDict["id"] = obj[kID]
                jsonDict["name"] = obj["name"]
                jsonDict["x_axis"] = point.x
                jsonDict["y_axis"] = point.y
                
                let tagDetail = SimpleTagModel(fromJson: JSON(jsonDict))
                
                return PSTagView(tagName: obj["name"] as! String, x: point.x, y: point.y, parrentView: UIImageView(frame: CGRect(x: 0, y: 0, width: imgView.frame.width, height: imgView.frame.height)), tagDetail: tagDetail)
            })
            
            arrayTagData[TagType.tagItem.hashValue] = [TagType.tagItem.rawValue : arrayPsTagItem]
            
            //===============================Link
            
            var linkModel = (dictFromParent?.tagDetail.linkTag!)!
            
            //change image (x,y) to pass
            linkModel = LinkTagModel.changeTagCondinateTomDeviceImageScaleFactor(linkModel, scaleFactor: Float(scaleFactor))
            
            //get all link data
            let arrayLinkTag = LinkTagModel.dictArrayFromModelArray(array: linkModel)
            
            //Convert [Dictionary<String,Any>] to [PSTagView]
            //ParentView => Main image parents frame
            
            var arrayPsTagLink : [PSTagView]!
            arrayPsTagLink = arrayLinkTag.map({ (obj : Dictionary<String,Any>) -> PSTagView in
                
                let point = CGPoint(x: Double.init((obj["x_axis"] as! String))!, y: Double.init((obj["y_axis"] as! String))!)
                var jsonDict : Dictionary<String,Any> = obj
                jsonDict["id"] = obj[kID]
                jsonDict["name"] = obj["name"]
                jsonDict["x_axis"] = point.x
                jsonDict["y_axis"] = point.y
                
                let tagDetail = LinkTagModel(fromJson: JSON(jsonDict))
                
                return PSTagView(tagName: obj["name"] as! String, x: point.x, y: point.y, parrentView: UIImageView(frame: CGRect(x: 0, y: 0, width: imgView.frame.width, height: imgView.frame.height)), tagDetail: tagDetail)
            })
            
            arrayTagData[TagType.addLink.hashValue] = [TagType.addLink.rawValue : arrayPsTagLink]
            
            //===============================People
            
            var peopleModel = (dictFromParent?.tagDetail.userTag!)!
            
            //change image (x,y) to pass
            peopleModel = PeopleTagModel.changeTagCondinateTomDeviceImageScaleFactor(peopleModel, scaleFactor: Float(scaleFactor))
            
            //get all people data
            let arrayPeopleTag = PeopleTagModel.dictArrayFromModelArray(array: peopleModel)
            
            //Convert [Dictionary<String,Any>] to [PSTagView]
            //ParentView => Main image parents frame
            
            var arrayPsTagPeople : [PSTagView]!
            arrayPsTagPeople = arrayPeopleTag.map({ (obj : Dictionary<String,Any>) -> PSTagView in
                
                let point = CGPoint(x: Double.init((obj["x_axis"] as! String))!, y: Double.init((obj["y_axis"] as! String))!)
                var jsonDict : Dictionary<String,Any> = obj
                jsonDict["id"] = obj[kID]
                jsonDict["name"] = obj["name"]
                jsonDict["x_axis"] = point.x
                jsonDict["y_axis"] = point.y
                
                let tagDetail = PeopleTagModel(fromJson: JSON(jsonDict))
                
                return PSTagView(tagName: obj["name"] as! String, x: point.x, y: point.y, parrentView: UIImageView(frame: CGRect(x: 0, y: 0, width: imgView.frame.width, height: imgView.frame.height)), tagDetail: tagDetail)
            })
            
            arrayTagData[TagType.tagPeople.hashValue] = [TagType.tagPeople.rawValue : arrayPsTagPeople]
            
            /*
             1. Item Edit mode
             */
            if shareType == .main {
                
            }
        }
       
    }
    
    
    //image compression
    func compressImage(image: UIImage, compressionRatio : Float) -> Data? {
        
        if self.dataToUpload != nil {
            return self.dataToUpload! as Data
        }
        let compressionQuality: Float = compressionRatio
        let imageData = UIImageJPEGRepresentation(image, CGFloat(compressionQuality))
        if (Float((imageData! as NSData).length)/1024.0/1024.0 < 0.12){
            return imageData
        }
        return image.resize(true) as? Data
        
    }
    
    //------------------------------------------------------
    
    //MARK:- API Call
    
    func callUploadItemAPI(_ requestModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/uploaditem
         
         Parameter   : item_type,repost,image,share_type[main,repost]
         
         Optional    : caption,tag_brand,tag_people,add_link,hashtag,tag_item,item_id
         
         Comment     : This api will used for upload the new item.Below give few filed example
         tag_brand : [{"name":"Apple","x_axis":"2","y_axis":"3"},{"name":"Abc","x_axis":"2","y_axis":"3"}]
         tag_people : [{"user_id":"1","x_axis":"2","y_axis":"3"},{"user_id":"3","x_axis":"2","y_axis":"3"}]
         add_link : [{"name":"www.facebook.co.in","x_axis":"2","y_axis":"3"}]
         hashtag : abc,xyz,pqr tag_item : [{"name":"xyz","x_axis":"2","y_axis":"3"},{"name":"sadfsdf","x_axis":"2","y_axis":"3"}]
         if you passing share type in repost then passing item_id
         
         ==============================
        */
        
        var data : Data? = nil
        
        guard let _ = imgPost, (imgPost != nil || imgPost != UIImage()) && imgPost.size != CGSize.zero else {
            return
        }
        
        guard let imageData : Data = self.compressImage(image: imgPost, compressionRatio: 0.80) else {
            return
        }
        data = imageData

        APICall.shared.POST(strURL: kMethodUploadItem
            , parameter: requestModel.toDictionary()
            , withErrorAlert: true
            , withLoader: true
            , constructingBodyWithBlock: { (formData : AFMultipartFormData?) in
                formData!.appendPart(withFileData: data!, name: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
        }
            , withBlock: { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
                
                if (error == nil) {
                    self.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationSetHomePage), object: nil)
                    })
                    
                    let response = JSON(response ?? [:])
                    let status = response[kCode].stringValue
                    
                    switch(status) {
                        
                    case success:
                        
                        if self.shareType == .repost {
                            self.dictFromParent?.repostCount = "\(Int((self.dictFromParent?.repostCount)!)! + 1)"
                            self.dictFromParent?.loginUserRepost = true
                        }
                        
                        let obj = ItemModel(fromJson: response[kData])
                        obj.dataFromWS = false
                        obj.rackName = self.rackName
                        obj.pinImage = self.isImageSwitchChange ? "1" : "0"
                        
                        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRepostCountUpdate), object: obj)
                        
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNewPostAdded), object: obj)
                        
                        let requestModel = RequestModel()
                        requestModel.item_id = obj.itemId
                        requestModel.social_keys = JSON(self.arraySocialKeys)
                        self.callItemSharingAPI(requestModel)
                        
                        //Google Analytics
                        
                        let category = "UI"
                        let action = "\(UserModel.currentUser.displayName!) uploaded an item"
                        let lable = ""
                        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: self.title)

                        //Google Analytics
                        
                        break
                    default :
                        //print("Default One called.....Upload")
                        
                        AlertManager.shared.showPopUpAlert("", message: response[kMessage].stringValue, forTime: 2.0, completionBlock: { (Int) in
                        })
                        
                        break
                    }
                    
                } else {
                    AlertManager.shared.showPopUpAlert("", message: error?.localizedDescription, forTime: 2.0, completionBlock: { (Int) in
                    })
                }
        })
    }
    
    func callEditItemAPI(_ requestModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/edititem    
         
         Parameter   : item_type,repost,image,share_type[main,repost]
         
         Optional    : caption,tag_brand,tag_people,add_link,hashtag,tag_item,item_id
         
         Comment     : This api will used for upload the new item.Below give few filed example
         tag_brand : [{"name":"Apple","x_axis":"2","y_axis":"3"},{"name":"Abc","x_axis":"2","y_axis":"3"}]
         tag_people : [{"user_id":"1","x_axis":"2","y_axis":"3"},{"user_id":"3","x_axis":"2","y_axis":"3"}]
         add_link : [{"name":"www.facebook.co.in","x_axis":"2","y_axis":"3"}]
         hashtag : abc,xyz,pqr tag_item : [{"name":"xyz","x_axis":"2","y_axis":"3"},{"name":"sadfsdf","x_axis":"2","y_axis":"3"}]
         if you passing share type in repost then passing item_id
         
         ==============================
         */
        
        APICall.shared.POST(strURL: kMethodItemEdit
            , parameter: requestModel.toDictionary()
            , withErrorAlert: true
            , withLoader: true
            , constructingBodyWithBlock: { (formData : AFMultipartFormData?) in
                
        }
            , withBlock: { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
                
                if (error == nil) {
                    
                    self.dismiss(animated: true, completion: {
                    })
                    
                    let response = JSON(response ?? [:])
                    let status = response[kCode].stringValue
                    
                    switch(status) {
                        
                    case success:
                        if self.shareType == .repost {
                            self.dictFromParent?.repostCount = "\(Int((self.dictFromParent?.repostCount)!)! + 1)"
                            self.dictFromParent?.loginUserRepost = true
                        }
                        
                        let obj = ItemModel(fromJson: response[kData])
                        obj.dataFromWS = false
                        obj.rackName = self.rackName
                        obj.pinImage = self.isImageSwitchChange ? "1" : "0"

                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: obj)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRackWantEdit), object: obj)
                        
                        if self.rackName != self.dictFromParent?.rackData.rackName {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRackList), object: obj)
                            
                            if self.editCompletion != nil {
                                self.editCompletion()
                            }
                            
                        }
                        
                        //Google Analytics
                        
                        let category = "UI"
                        let action = "\(UserModel.currentUser.displayName!) updated item \(String(describing: self.dictFromParent?.itemId!))"
                        let lable = ""
                        let screenName = "Edit Item"
                        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                        
                        //Google Analytics
                        
                        break
                    default :
                        //print("Default One called.....Upload")
                        
                        AlertManager.shared.showPopUpAlert("", message: response[kMessage].stringValue, forTime: 2.0, completionBlock: { (Int) in
                        })
                        
                        break
                    }
                } else {
                    AlertManager.shared.showPopUpAlert("", message: error?.localizedDescription, forTime: 2.0, completionBlock: { (Int) in
                    })
                }
        })
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
            , constructingBodyWithBlock: { (formData : AFMultipartFormData?) in
                
        }
            , withBlock: { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
                if (response != nil) {
//                    //print(response)
                }
                if (code != nil) {
//                    //print(code)
                }
                if (error != nil) {
//                    //print(error?.localizedDescription)
                }
        })
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    func leftButtonClicked() {
        
        AlertManager.shared.showAlertTitle(title: "Discard?", message: "If you go back now, you will lose all changes", buttonsArray: ["Discard","CANCEL"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                //Discard clicked
                //print("Discard Clicked")
                //To By pass CameraPreviewVC, RackVC and RackDetailVC  in popViewController
                
                var isCreatPostInStack = false
                for vc in self.navigationController!.viewControllers {
                    
                    if vc.isKind(of: FusumaViewController.self) {
                        isCreatPostInStack = true
//                        UserDefaults.standard.set(true, forKey: "discard")
                        self.navigationController!.popToViewController(vc, animated: true)
                        break
                    }
                }
                
                //do as final step
                if !isCreatPostInStack {
                    _ = self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
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

        if rackName == "Loading..." {
            return
        }
        self.view.endEditing(true)
        if let _ = self.tblPost {
            self.tblPost.scrollsToTop = true
        }
        //TODO:- Take care of change indexpath if UI change. :)
        //Require to change index path if any index path add above to post selection type
        let indexPath1 = IndexPath(row: 0, section: 0)
        let indexPath2 = IndexPath(row: 1, section: 0)
        let indexPath7 = IndexPath(row: 3, section: 0)
        guard let cellImageCell = tblPost.cellForRow(at: indexPath1) as? PostCell else  {
            //print("first indexPath1 issue")
            return
        }
        guard let cellPostType = tblPost.cellForRow(at: indexPath2) as? PostCell else  {
            //print("first indexPath2 issue")
            return
        }
        
        guard let cellSwitchType = tblPost.cellForRow(at: indexPath7) as? PostCell else {
            //print("first indexPath7 issue")
            return
        }
        
        guard imgPost != nil && imgPost.size != CGSize.zero else {
            return
        }
        
        //For Passing Tag Taga With Image
        let scaleFactor = imgPost.getPostImageScaleFactor(kScreenWidth)
        
        /*
         for psView in arrayBrandTag! {
         //print("x : ",psView.tagLocation.x * scaleFactor)
         //print("y : ",psView.tagLocation.y * scaleFactor)
         //print("Data :",psView.tagDetail ?? "Not Found")
         }
         */
        //===============================Brand Data
        //get all brand data from source
        let arrayBrandTag = arrayTagData[TagType.tagBrand.hashValue][TagType.tagBrand.rawValue]
        
        //get tagdetail from PSTagView
        /*var brandDetailModel = arrayBrandTag?.map({ (psView : PSTagView) -> SimpleTagModel in
         return psView.tagDetail as? SimpleTagModel ?? SimpleTagModel()
         })*/
        
        /* Tags are dragged, This would take the latest x,y co-ordinates */
        //get tagdetail from PSTagView
        var brandDetailModel = arrayBrandTag?.map({ (psView : PSTagView) -> SimpleTagModel in
            
            let main = psView
            let sub = psView.tagDetail as! SimpleTagModel
            sub.xAxis = "\(main.tagLocation.x)"
            sub.yAxis = "\(main.tagLocation.y)"
            
            return sub
        })
        
        //change image (x,y) to pass
        brandDetailModel = SimpleTagModel.changeTagCondinateTomOrignalImageScaleFactor(brandDetailModel!, scaleFactor: Float(scaleFactor), imgPost: imgPost)
        
        //convert dict to array
        let branDetailArray = SimpleTagModel.dictArrayFromModelArray(array: brandDetailModel!)
        
        //convert to string
        let brandString = GFunction.shared.convertToJSONString(arrayData: branDetailArray)
        
        //===============================Item Data
        let arrayItemTag = arrayTagData[TagType.tagItem.hashValue][TagType.tagItem.rawValue]
        
        /*//get tagdetail from PSTagView
         var itemModel = arrayItemTag?.map({ (psView : PSTagView) -> SimpleTagModel in
         return psView.tagDetail as? SimpleTagModel ?? SimpleTagModel()
         })*/
        
        /* Tags are dragged, This would take the latest x,y co-ordinates */
        //get tagdetail from PSTagView
        var itemModel = arrayItemTag?.map({ (psView : PSTagView) -> SimpleTagModel in
            
            let main = psView
            let sub = psView.tagDetail as! SimpleTagModel
            sub.xAxis = "\(main.tagLocation.x)"
            sub.yAxis = "\(main.tagLocation.y)"
            return sub
        })
        
        //change image (x,y) to pass
        itemModel = SimpleTagModel.changeTagCondinateTomOrignalImageScaleFactor(itemModel!, scaleFactor: Float(scaleFactor), imgPost: imgPost)
        
        //convert dict to array
        let itemArray = SimpleTagModel.dictArrayFromModelArray(array: itemModel!)
        
        //convert to string
        let itemString = GFunction.shared.convertToJSONString(arrayData: itemArray)
        
        //===============================Link
        let arrayLinkTag = arrayTagData[TagType.addLink.hashValue][TagType.addLink.rawValue]
        
        /*//get tagdetail from PSTagView
         var linkModel = arrayLinkTag?.map({ (psView : PSTagView) -> LinkTagModel in
         return psView.tagDetail as? LinkTagModel ?? LinkTagModel()
         })*/
        
        /* Tags are dragged, This would take the latest x,y co-ordinates */
        //get tagdetail from PSTagView
        var linkModel = arrayLinkTag?.map({ (psView : PSTagView) -> LinkTagModel in
            //print(psView.tagLocation)
            
            let main = psView
            let sub = psView.tagDetail as! LinkTagModel
            sub.xAxis = "\(main.tagLocation.x)"
            sub.yAxis = "\(main.tagLocation.y)"
            return sub
        })
        
        //change image (x,y) to pass
        linkModel = LinkTagModel.changeTagCondinateTomOrignalImageScaleFactor(linkModel!, scaleFactor: Float(scaleFactor), imgPost: imgPost)
        
        //convert dict to array
        let linkArray = LinkTagModel.dictArrayFromModelArray(array: linkModel!)
        
        //convert to string
        let linkString = GFunction.shared.convertToJSONString(arrayData: linkArray)
        
        //===============================People
        let arrayPeopleTag = arrayTagData[TagType.tagPeople.hashValue][TagType.tagPeople.rawValue]
        
        /*//get tagdetail from PSTagView
         var peopleTagModel = arrayPeopleTag?.map({ (psView : PSTagView) -> PeopleTagModel in
         return psView.tagDetail as? PeopleTagModel ?? PeopleTagModel()
         })*/
        
        /* Tags are dragged, This would take the latest x,y co-ordinates */
        //get tagdetail from PSTagView
        var peopleTagModel = arrayPeopleTag?.map({ (psView : PSTagView) -> PeopleTagModel in
            //print(psView.tagLocation)
            
            let main = psView
            let sub = psView.tagDetail as! PeopleTagModel
            sub.xAxis = "\(main.tagLocation.x)"
            sub.yAxis = "\(main.tagLocation.y)"
            return sub
        })
        
        //change image (x,y) to pass
        peopleTagModel = PeopleTagModel.changeTagCondinateTomOrignalImageScaleFactor(peopleTagModel!, scaleFactor: Float(scaleFactor), imgPost: imgPost)
        
        //convert dict to array
        let peopleTagArray = PeopleTagModel.dictArrayFromModelArray(array: peopleTagModel!)
        
        //convert to string
        let peopleString = GFunction.shared.convertToJSONString(arrayData: peopleTagArray)
        
        //===============================HasgTag
        let arrayHashTag = cellImageCell.tvCaption.text.getHashtags()
        
        //convert to string
        let hashTagString = arrayHashTag?.joined(separator: ",")
 
        //check for share type. main or repost.
        switch shareType {
            
        case .main:
            
            let requestModel = RequestModel()
            requestModel.item_type = "rack"
            requestModel.repost = isRepostSwitchChange ? "yes" : "no"
            requestModel.share_type = shareType.rawValue
            requestModel.caption = cellImageCell.tvCaption.text
            requestModel.tag_brand = brandString
            requestModel.tag_people = peopleString
            requestModel.add_link = linkString
            requestModel.hashtag = hashTagString
            requestModel.tag_item = itemString
            requestModel.width = "\(imgPost.size.width)"
            requestModel.height = "\(imgPost.size.height)"
            requestModel.folderName = rackName
            requestModel.pinImage = isImageSwitchChange ? "1" : "0"
            requestModel.rack_category = self.selectedCategories.componentsJoined(by: "\n")
            
            if dictFromParent != nil {
                requestModel.item_id = dictFromParent?.itemId
                self.callEditItemAPI(requestModel)
            } else {
                self.callUploadItemAPI(requestModel)
            }
            
            break
        case .repost:
            
            let requestModel = RequestModel()
            requestModel.repost = isRepostSwitchChange ? "yes" : "no"
            requestModel.share_type = shareType.rawValue
            requestModel.caption = cellImageCell.tvCaption.text
            requestModel.tag_brand = brandString
            requestModel.tag_people = peopleString
            requestModel.add_link = linkString
            requestModel.hashtag = hashTagString
            requestModel.tag_item = itemString
            requestModel.item_id = dictFromParent?.itemId
            requestModel.width = "\(imgPost.size.width)"
            requestModel.height = "\(imgPost.size.height)"
            requestModel.folderName = rackName
            requestModel.pinImage = isImageSwitchChange ? "1" : "0"
            requestModel.rack_category = self.selectedCategories.componentsJoined(by: "\n")
            
            self.callUploadItemAPI(requestModel)
            
            break
        }
        
    }
    
    @IBAction func btnFacebookClicked(_ sender : UIButton) {
        
        let loginManager : FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        loginManager.logIn(withPublishPermissions: ["publish_actions"], from: self) { (result, error) in
            if (error == nil) {
                
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                
                if (fbloginresult.grantedPermissions != nil) {
                    if(fbloginresult.grantedPermissions.contains("publish_actions")) {
                        let fbAccessToken = FBSDKAccessToken.current().tokenString
                        //print("fbAccessToken \(String(describing: fbAccessToken))")
                        
                        self.arraySocialKeys.append(["facebook" : ["access_token" : fbAccessToken!]])
                        
                        self.btnFacebook.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 13.0), titleLabelColor: AppColor.text)

                    } else {
//                            AlertManager.shared.showAlertTitle(title: "Facebook Error"
//                                ,message: "Publish action not granted.")
                    }
                }
            }
        }
    }
    
    @IBAction func btnPintrestClicked(_ sender : UIButton) {
        
        /*
         TODO:-Please refer to readme.md if you find any issue of presenting view controller over window hierarchy
         */
        
        PDKClient.sharedInstance().authenticate(withPermissions: [PDKClientReadPublicPermissions,PDKClientWritePublicPermissions,PDKClientReadRelationshipsPermissions,PDKClientWriteRelationshipsPermissions], withSuccess: { (PDKResponseObject) in
            
            self.arraySocialKeys.append(["pinterest" : ["access_token" : PDKClient.sharedInstance().oauthToken]])
            
            self.btnPinterest.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 13.0), titleLabelColor: AppColor.text)
            
        }) { (Error) in
            AlertManager.shared.showAlertTitle(title: "Pinterest Error"
                ,message: Error?.localizedDescription)
        }
    }
    
    @IBAction func btnGmailClicked(_ sender : UIButton) {
        
    }
    
    @IBAction func btnFlickerClicked(_ sender : UIButton) {
        /*
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserAuthCallbackNotification"), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            let callBackURL: URL = notification.object as! URL
            self.completeAuthOp = FlickrKit.shared().completeAuth(with: callBackURL, completion: { (userName, userId, fullName, error) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    if ((error == nil)) {
                        
                    } else {
                        let alert = UIAlertView(title: "Error", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    _ = self.navigationController?.popToRootViewController(animated: true)
                });
            })
        }
        
        // Check if there is a stored token - You should do this once on app launch
        self.checkAuthOp = FlickrKit.shared().checkAuthorization { (userName, userId, fullName, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if ((error == nil)) {
                    
                } else {
                    
                }
            });
        }*/
    }
    
    @IBAction func btnTwitterClicked(_ sender : UIButton) {
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                //print("signed in as \(String(describing: session?.userName))");
                
                let authToken = session?.authToken
                let authTokenSecret = session?.authTokenSecret
                
                self.arraySocialKeys.append(["twitter" : ["access_token" : authToken!, "secret" : authTokenSecret!]])
                
                self.btnTwitter.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 13.0), titleLabelColor: AppColor.text)
                
            } else {
                //print("error: \(String(describing: error?.localizedDescription))");
            }
        })
    }
    
    @IBAction func btnTumblrClicked(_ sender : UIButton) {
       
        /*
        TMAPIClient.sharedInstance().authenticate("rack", from: self, callback: {(_ error: Error?) -> Void in
            // You are now authenticated (if !error)
            
            if error == nil {
                var blogName : String = ""
                TMAPIClient.sharedInstance().userInfo({ (response, error) in
                    if error == nil {
                        guard (response as? Dictionary<String,Any>) != nil else {
                            return
                        }
                        
                        guard (response as! Dictionary<String,Any>)["user"] as? Dictionary<String,Any> != nil else {
                            return
                        }
                        
                        guard ((response as! Dictionary<String,Any>)["user"] as! Dictionary<String,Any>) ["name"] as? String != nil else {
                            return
                        }
                        
                        blogName = ((response as! Dictionary<String,Any>)["user"] as! Dictionary<String,Any>)["name"] as! String + ".tumblr.com"
                        
                        self.arraySocialKeys.append(["tumblr" : ["oauth_token" : TMAPIClient.sharedInstance().oAuthToken!, "oauth_secret" : TMAPIClient.sharedInstance().oAuthTokenSecret!, "blogname" : blogName]])
                        
                        self.btnTumblr.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 13.0), titleLabelColor: AppColor.text)
                    }
                })
                
            } else {
                //print("error: \(String(describing: error?.localizedDescription))");
            }
        })*/
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
      UserDefaults.standard.set("", forKey: "captionText")
      UserDefaults.standard.set(0, forKey: "imageTagType")
      self.view.backgroundColor = AppColor.primaryTheme
      self.tblPost.backgroundColor = AppColor.primaryTheme
      self.navigationController?.navigationBar.isTranslucent = false
        //TODO:- Check whether to show onboarding or no
        self.dataToUpload =  self.compressImage(image: self.imgPost, compressionRatio: 0.8) as! NSData
      self.imgPost      = self.imgPost.resize(false) as! UIImage
      setUpView()
      setUpData()
    }

    
    func shareButtonAction(){
        let image = self.imgPost
        let imageToShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Google Analytics
        self.setRightLeftButton()

        let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: self.title)
        
        self.tblPost.reloadData()
        //Google Analytics
    }
    
    func setRightLeftButton()  {
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItems  = nil
        self.navigationItem.rightBarButtonItem = nil
        
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: nil, title: "Upload", isSwipeBack: false)
        
        let uploadButton = UIButton()
        uploadButton.setImage(UIImage(named:"upload"), for: .normal)
        uploadButton.contentHorizontalAlignment = .right
        uploadButton.clipsToBounds = true
        uploadButton.addTarget(self, action: #selector(self.shareButtonAction), for: .touchUpInside)
        uploadButton.imageView?.contentMode = .center
        uploadButton.imageView?.clipsToBounds = true
        uploadButton.frame = CGRect(x:0,y:0,width:30.0,height:30.0)
        let shareBarButtonItem = UIBarButtonItem.init(customView: uploadButton)
        
        let rightButton = UIButton(type: .custom)
        rightButton.contentHorizontalAlignment = .right
        rightButton.tintColor = UIColor.darkGray
        rightButton.setTitleColor(UIColor.black, for: .normal)
        rightButton.setTitleColor(UIColor.colorFromHex(hex: kColorGray74), for: .disabled)
        rightButton.setTitle("Share", for: .normal)
        rightButton.titleLabel?.font = UIFont.applyRegular(fontSize: 13.0)
        rightButton.addTarget(self, action: #selector(self.rightButtonClicked), for: .touchUpInside)
        
        rightButton.frame = CGRect(x: 0, y: CGFloat(0), width: CGFloat(50), height: 44)
        let shareButton = UIBarButtonItem.init(customView: rightButton)
        
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = [shareButton,shareBarButtonItem]
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    //------------------------------------------------------
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        kSeguePostTable
    }
    
}

//MARK:- TableView DataSource Delegate -
extension UploadVC : PSTableDelegateDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCellType.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let dictAtIndex = arrayCellType[indexPath.row]
        switch dictAtIndex[kCellType] as!   cellType {
        case .postImageCell:
            return 128 * kHeightAspectRasio
        case .tagTypeCell , .switchTypeCell:
            return 48 * kHeightAspectRasio
        case .createRackCell:
            return 137 * kHeightAspectRasio
        case .optionSelectionCell:
            if self.selectedCategories.count > 1 {
                return (CGFloat(self.selectedCategories.count)*18.0)+48.0+8.0
            }
            return (CGFloat(self.selectedCategories.count)*18.0)+48.0+8.0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dictAtIndex = arrayCellType[indexPath.row]
        switch dictAtIndex[kCellType] as! cellType {
        case .postImageCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell1") as! PostCell
            cell.imgPost.image = self.imgPost
            cell.selectionStyle = .none
            
            if let value = UserDefaults.standard.value(forKey: "captionText") as? String{
                 cell.tvCaption.text = value
            }
            
            cell.tvCaption.inputAccessoryView = UIToolbar().addToolBar(self)
            hmc = GGHashtagMentionController.init(textView: cell.tvCaption, delegate: self)
            cell.delegate = self
            
            if shareType == .main && dictFromParent != nil {
                cell.tvCaption.text = self.dictFromParent?.caption
            }
            
            return cell
            
        case .tagTypeCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell3") as! PostCell
            cell.lblTitle.text = dictAtIndex[kTitle] as? String
            return cell
            
        case .switchTypeCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell4") as! PostCell
            cell.lblTitle.text = dictAtIndex[kTitle] as? String
            cell.imgIcon.image = dictAtIndex[kImage] as? UIImage
            
            cell.btnSwitch.addTarget(self, action: #selector(didSwitchButtonStatusChange(_:)), for: .valueChanged)
            if cell.lblTitle.text == "Pin Image" {
                cell.imgIcon.image = nil
                cell.btnSwitch.isOn = isImageSwitchChange
                cell.btnSwitch.tag = 1
            }else{
                cell.btnSwitch.tag = 2
                
                if shareType == .main && dictFromParent != nil {
                    cell.btnSwitch.isOn = self.dictFromParent?.repost == "yes" ? true : false
                    isRepostSwitchChange = self.dictFromParent?.repost == "yes" ? true : false
                }
            }
            
            return cell
            
        case .createRackCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RackTableViewCell") as! RackTableViewCell
            cell.lblTitle.text = dictAtIndex[kTitle] as? String
            cell.folderName.text = self.rackName
            
            if let rackImage = (self.rackImage as? UIImage) {
                cell.imgView.image = rackImage
            }else{
                if let rackImage = (rackImage as? String) {
                    cell.imgView.setImageWithDownload(rackImage.url())
                }else{
                    cell.imgView.image = nil
                }
            }
            
            // #MARK:- Animation Setup
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                self.guideView.addTip(.top, forView: cell.folderName, withinSuperview: cell.contentView, textType: .tNewRack, forAnim: .aNewRack)
                self.guideView.addAnimation(cell.folderName, withinSuperview: true, forAnim: .aNewRack)
            })
            
            return cell
            
        case .optionSelectionCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell") as! CategoryTableViewCell
            cell.selectionStyle = .none
            cell.label.text = self.selectedCategories.componentsJoined(by: "\n")
            return cell
        }
        
    }
    
    func didSwitchButtonStatusChange(_ _switch: UISwitch) {
        if _switch.tag == 1 {
            isImageSwitchChange = !isImageSwitchChange
        }else{
            isRepostSwitchChange = !isRepostSwitchChange
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dictAtIndex = arrayCellType[indexPath.row]
        if  indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 4{
            return
        }
        if  dictAtIndex[kTitle] as? String == "Category" {
            self.selectedCategories.removeAllObjects()
            categoriesVC.selectedCategories = self.selectedCategories
            
            DispatchQueue.main.async(execute: {
                let navigationConteoller = UINavigationController.init(rootViewController: self.categoriesVC)
                navigationConteoller.navigationBar.isTranslucent = false
                self.present(navigationConteoller, animated: true, completion: nil)
            })
            
            return
            
        }
        
        if  dictAtIndex[kTitle] as? String == "Select Rack" {
            guideView.tipDismiss(forAnim: .aNewRack)
            guideView.saveTapActivity(forAnim: .aNewRack)

            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SelectRackListVC") as! SelectRackListVC
            vc._shareType = self.shareType
            vc._imgView = self.imgView
            vc._dictFromParent = self.dictFromParent
            vc._hmc = self.hmc
            vc._imgPost = self.imgPost
            vc.arrayItemData = self.arrayItemData
            
            let indexPath1 = IndexPath(row: 0, section: 0)
            guard let cellImageCell = tblPost.cellForRow(at: indexPath1) as? PostCell else  {
                //print("first indexPath1 issue")
                return
            }
            
            vc._tvCaptionText = cellImageCell.tvCaption.text
            vc.tvCaptionText = { (text) in
                UserDefaults.standard.set(text, forKey: "captionText")
            }
            
            vc.newRackSelected = {(text, image) in
                self.rackName = text
                self.rackImage = image
                
                self.tblPost.reloadData()
            }
            
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        if postImageAddTagVC == nil {
            postImageAddTagVC = secondStoryBoard.instantiateViewController(withIdentifier: "PostImageAddTagVC") as! PostImageAddTagVC
            postImageAddTagVC.postImage = imgPost
            postImageAddTagVC.delegate = self
            
        }
        
        
        //pass data to PostImageAddTagVC to display tag
        
        let tType = dictAtIndex[kAction] as! TagType
        postImageAddTagVC.arrayTag = arrayTagData[tType.hashValue][tType.rawValue]!
        
        let selectedButtonTag = UserDefaults.standard.integer(forKey: "selectedButtonTag")
        if selectedButtonTag > 0 {
            
            switch selectedButtonTag{
            case 1:
                postImageAddTagVC.imageTagType = .tagBrand
                self.navigationController!.pushViewController(postImageAddTagVC, animated: true)
                break
            case 2:
                postImageAddTagVC.imageTagType = .tagPeople
                self.navigationController!.pushViewController(postImageAddTagVC, animated: true)
                break
            case 3:
                postImageAddTagVC.imageTagType = .addLink
                self.navigationController!.pushViewController(postImageAddTagVC, animated: true)
                break
            default:
                break
            }
        }else{
            switch tType {
            case .tagBrand:
                postImageAddTagVC.imageTagType = .tagBrand
                self.navigationController!.pushViewController(postImageAddTagVC, animated: true)
                break
            case .tagItem:
                postImageAddTagVC.imageTagType = .tagItem
                self.navigationController!.pushViewController(postImageAddTagVC, animated: true)
                break
            case .tagPeople:
                postImageAddTagVC.imageTagType = .tagPeople
                self.navigationController!.pushViewController(postImageAddTagVC, animated: true)
                break
            case .addLink:
                postImageAddTagVC.imageTagType = .addLink
                self.navigationController!.pushViewController(postImageAddTagVC, animated: true)
                break
            case .none:
                //print("None Action")
                break
            default:
                break
            }
            
        }
        
    }
    
    
}

//MARK:- SearchTagDelegate -

extension UploadVC : SearchTagDelegate {
    
    func searchTagDelegateMethod(_ tagDetail: Any,tagType : TagType?) {
        
        //replace array data with specific tag data object
        if let tagViewCollection = tagDetail as? [PSTagView] {
            
            arrayTagData[tagType!.hashValue] = [tagType!.rawValue : tagViewCollection]

        } else {
            
            //print("Please check something gone to wrong...")
            
        }
        
    }
    
}

extension UploadVC : SearchCaptionDelegate {
    
    func searchCaptionDelegateMethod(_ tagDetail: Any,tagType : TagType?) {
        
        let name = PeopleTagModel(fromJson: JSON(tagDetail)).name
        
        let cell = tblPost.cellForRow(at: IndexPath(row: 0, section: 0)) as! PostCell
        cell.tvCaption.text = "\(cell.tvCaption.text!)\(name!) "
    }
}

extension UploadVC : UploadCell {
    func didTap(tagType : TagType) {
        
        switch tagType {
        case .tagPeople:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchPeopleCaptionVC") as! SearchPeopleCaptionVC
            vc.imageTagType = TagType.tagPeople
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
}

extension UploadVC : GGHashtagMentionDelegate {
    
    func hashtagMentionController(_ hashtagMentionController: GGHashtagMentionController!, onHashtagWithText text: String!, range: NSRange) {
        
    }
    
    func hashtagMentionController(_ hashtagMentionController: GGHashtagMentionController!, onMentionWithText text: String!, range: NSRange) {
        if text.characters.count > 0 {
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchPeopleCaptionVC") as! SearchPeopleCaptionVC
            vc.imageTagType = TagType.tagPeople
            vc.delegate = self
            vc.searchBar.text = text
            
            vc.completion = {(_ tagUser: Any) -> Void in
                
                if let name = PeopleTagModel(fromJson: JSON(tagUser)).name {
                    let cell = self.tblPost.cellForRow(at: IndexPath(row: 0, section: 0)) as! PostCell
                    cell.tvCaption.text = (cell.tvCaption.text as NSString?)?.replacingCharacters(in: range, with: name as String)
                    cell.tvCaption.text = cell.tvCaption.text + " "
                    UserDefaults.standard.set(cell.tvCaption.text, forKey: "captionText")
                    cell.tvCaption.becomeFirstResponder()
                } else {
                    let cell = self.tblPost.cellForRow(at: IndexPath(row: 0, section: 0)) as! PostCell
                    cell.tvCaption.text = (cell.tvCaption.text as NSString?)?.replacingCharacters(in: range, with: "")
                    UserDefaults.standard.set(cell.tvCaption.text, forKey: "captionText")
                    cell.tvCaption.becomeFirstResponder()
                }
                
            }
            
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func hashtagMentionControllerDidFinishWord(_ hashtagMentionController: GGHashtagMentionController!) {
        
    }
}

//MARK: - PostCell -

class PostCell: UITableViewCell , UITextViewDelegate {
    
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var tvCaption: UITextView!
    @IBOutlet weak var btnRack: UIButton!
    @IBOutlet weak var btnWant: UIButton!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSwitch: UISwitch!
    
    var delegate : UploadCell? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = AppColor.primaryTheme
        self.contentView.backgroundColor = AppColor.primaryTheme
      if imgIcon != nil {
        imgIcon.tintColor = AppColor.secondaryTheme
      }
      
        if self.reuseIdentifier == "PostCell1" {
            tvCaption.applyStyle(textFont: UIFont.applyRegular(fontSize: 13.0), textColor: AppColor.text)
            tvCaption.delegate = self
            
        }else if self.reuseIdentifier == "PostCell3" {
            lblTitle.applyStyle(labelFont: UIFont.applyRegular(fontSize: 15.0), labelColor: AppColor.text)
        }else if self.reuseIdentifier == "PostCell4" {
            lblTitle.applyStyle(labelFont: UIFont.applyRegular(fontSize: 15.0), labelColor: AppColor.text)
            imgIcon.contentMode = .center
        }
        
    }
    
    @IBAction func btnRackClicked(_ sender : UIButton) {
        
        if !btnRack.isSelected {
            
            btnWant.isSelected = false
            btnWant.scaleAnimation(0.3, scale: 0.05)
            btnWant.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 12.0), titleLabelColor: AppColor.text,  borderColor: UIColor.clear, borderWidth: 0.0, state: .normal)
            
            
            btnRack.isSelected = true
            btnRack.scaleAnimation(0.3, scale: -0.05)
            btnRack.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 12.0), titleLabelColor: AppColor.text,  borderColor: AppColor.borderColor, borderWidth: 1.5, state: .selected)
            
        }
    }
    
    @IBAction func btnWantClicked(_ sender : UIButton) {
        
        if !btnWant.isSelected {
            
            btnRack.isSelected = false
            btnRack.scaleAnimation(0.3, scale: 0.05)
            btnRack.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 12.0), titleLabelColor: AppColor.text,  borderColor: UIColor.clear, borderWidth: 0.0, state: .normal)
            
            btnWant.isSelected = true
            btnWant.scaleAnimation(0.3, scale: -0.05)
            btnWant.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 12.0), titleLabelColor: AppColor.text,  borderColor: AppColor.borderColor, borderWidth: 1.5, state: .selected)
        }
        
    }
    
    //------------------------------------------------------
    
    //MARK:- TextField Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UserDefaults.standard.set(textView.text!, forKey: "captionText")
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newLength = textView.text.characters.count + text.characters.count - range.length
        
        if (range.location == 0 && text == " ") || (range.location == 0 && text == "\n") {
            return false
        }
        
        //Uncomment this line if you want to limit the caption
        /*if newLength <= 200 {
         
         } else {
         return false
         }*/
        
        /*if text == "@" {
         //print("mention")
         
         delegate?.didTap(tagType: TagType.tagPeople)
         
         } else if text == "#" {
         //print("hashtag")
         }*/
        
        return true
    }
    
}

class CategoryTableViewCell:UITableViewCell{
  
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = AppColor.primaryTheme
        self.contentView.backgroundColor = AppColor.primaryTheme
        label.applyStyle(labelFont: UIFont.applyRegular(fontSize: 15.0), labelColor: AppColor.text)
        lblTitle.applyStyle(labelFont: UIFont.applyRegular(fontSize: 15.0), labelColor: AppColor.text)
    }
}

class RackTableViewCell:UITableViewCell{
    
    @IBOutlet weak var folderName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var activiyIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = AppColor.primaryTheme
        self.contentView.backgroundColor = AppColor.primaryTheme
        folderName.applyStyle(labelFont: UIFont.applyRegular(fontSize: 15.0), labelColor: AppColor.text)
        lblTitle.applyStyle(labelFont: UIFont.applyRegular(fontSize: 15.0), labelColor: AppColor.text)
    }
    
}

class folderStructure: NSObject {
    
    var name: String!
    var image: String!
    var thumbnail: String!
    var localImage: UIImage!
    var rackId: String!
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        name = json["rack_name"].stringValue
        image = json["rack_image"].stringValue
        thumbnail = json["rack_image"].stringValue.replacingOccurrences(of: "items/", with:"items_thumbnail/" )
        rackId = json["rack_id"].stringValue
    }
    
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if name != nil{
            dictionary["rack_name"] = name
        }
        if image != nil{
            dictionary["rack_image"] = image
        }
        if rackId != nil{
            dictionary["rack_id"] = image
        }
        return dictionary
    }
    
    internal class func modelsFromDictionaryArray(array:[JSON]) -> [folderStructure] {
        var models:[folderStructure] = []
        for item in array
        {
            models.append(folderStructure(fromJson: item))
        }
        return models
    }
    
    
    
    internal class func modelsFromLocalDictionary(rackname:String, image:UIImage) -> [folderStructure] {
        var models:[folderStructure] = []
        
        let folderstructure = folderStructure(fromJson:[])
        folderstructure.name = rackname
        folderstructure.localImage = image
        folderstructure.rackId = ""
        models.append(folderstructure)
        
        return models
    }
    
    internal class func dictArrayFromModelArray(array:[folderStructure]) -> [Dictionary<String,Any>]
    {
        var arrayData : [Dictionary<String,Any>] = []
        for item in array
        {
            arrayData.append(item.toDictionary())
        }
        return arrayData
    }
    
}
extension UIImage {
    class func scaleImageWithDivisor(img: UIImage, divisor: CGFloat) -> UIImage {
        let size = CGSize(width: img.size.width/divisor, height: img.size.height/divisor)
        UIGraphicsBeginImageContext(size)
        img.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}

