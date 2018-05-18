//
//  RepostAddCaptionVC.swift
//  Rack
//
//  Created by GS Bit Labs on 2/22/18.
//  Copyright © 2018 Hyperlink. All rights reserved.
//

import UIKit
import AFNetworking

class RepostAddCaptionVC: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnCreateRackOutlet: UIButton!
    @IBOutlet weak var addCaptionView: UITextView!
    
    // Post View
    @IBOutlet weak var postContainerView: UIView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postUserProfile: UIImageView!
    @IBOutlet weak var postUsername: UILabel!
    @IBOutlet weak var postType: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    
    var _postUserProfile                  = UIImage()
    var _postUsername : String            = ""
    var _postType : String                = ""
    var _tvCaptionText : String           = ""
    var _dictFromParent : ItemModel?      = nil
    var _imgPost                          = UIImage()
    var searchActive : Bool               = false
    var filtered : [folderStructure]      = []
    var arrayItemData : [folderStructure] = []
    var headerCell: SelectRackHeaderCell? = nil
    var page      : Int                   = 1
    var isRackSelected: Bool              = false
    var rackName                          = String()
    var rackID                            = String()
    var isEdit                            = Bool()
    var arraySocialKeys : [Dictionary<String , Dictionary<String,Any>>]     = []
    let activityIndicatorView:UIActivityIndicatorView                       = UIActivityIndicatorView()
    
    typealias EditCompletion = ()->Void
    var editCompletion: EditCompletion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setUpData()
        
    }
    
    func setupView() {
        
        setRightLeftButton()
        
        addCaptionView.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
        postUserProfile.applyStype(cornerRadius: postUserProfile.frame.size.height / 2)
        
        if isEdit {
            addCaptionView.text = _dictFromParent?.caption
        }
        
        postUserProfile.image = self._postUserProfile
        postUsername.text = self._postUsername
        postType.text = self._postType
        postTextView.text = self._tvCaptionText
        postImageView.image = self._imgPost
        postTextView.isEditable = false
        postTextView.inputAccessoryView = UIToolbar().addToolBar(self)
        postTextView.applyStyle(textFont: UIFont.applyRegular(fontSize: 9.0), textColor: AppColor.createReckText)
        postTextView.contentInset = UIEdgeInsets(top: -10, left: -5, bottom: 0, right: 0)
        postTextView.delegate = self
        
    }
    
    
    func setUpData() {
        
        self.activityIndicatorView.frame = self.view.bounds
        self.activityIndicatorView.activityIndicatorViewStyle = .gray
        self.view.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        
        self.page = 1
        let requestModel = RequestModel()
        requestModel.user_id = UserModel.currentUser.userId
        requestModel.page = String(format: "%d", (self.page))
        
        self.callRackListAPI(requestModel, withCompletion: { (isSuccess) in
            if isSuccess {
//                self.isRackSelected = true
//                self.rackName = self.arrayItemData[0].name
//                self.filtered.append(self.arrayItemData[0])
                self.filtered = self.arrayItemData
            }
            
            self.tblView.reloadData()
        })
        
    }
    
    func setRightLeftButton()  {
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItems  = nil
        self.navigationItem.rightBarButtonItem = nil
        
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: nil, title: "Repost")
        
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
    
    // Top Bar Methods
    
    func shareButtonAction(){
        let image = self._imgPost
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func leftButtonClicked() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func rightButtonClicked() {
        
        view.endEditing(true)
        if isRackSelected == true || self.arrayItemData.count == 1 {
            
            let requestModel = RequestModel()
            requestModel.item_id = self._dictFromParent?.itemId
            requestModel.item_type = "rack"
            requestModel.repost = "yes"
            requestModel.share_type = "repost"
            requestModel.caption = addCaptionView.text!
            requestModel.folderName = self.filtered[0].name
            
            if isEdit {
                callEditItemAPI(requestModel)
            }else{
                callUploadItemAPI(requestModel)
            }
            
        }else{
            AlertManager.shared.showPopUpAlert("", message:"Please select rack", forTime: 2.0, completionBlock: { (Int) in
            })
        }
        
    }
    
    // MARK: API CALL
    
    //image compression
    func compressImage(image: UIImage, compressionRatio : Float) -> Data? {
        
        var compressionQuality: Float = compressionRatio
        var imageData = UIImageJPEGRepresentation(image, CGFloat(compressionQuality))
        while Float((imageData! as NSData).length)/1024.0/1024.0 > 0.15 && compressionQuality > 0.10 {
            compressionQuality -= 0.05
            imageData = UIImageJPEGRepresentation(image, CGFloat(compressionQuality))
        }
        
        return imageData
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
        
        guard let imageData : Data = self.compressImage(image: _imgPost, compressionRatio: 0.80) else {
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
                
                    let response = JSON(response ?? [:])
                    let status = response[kCode].stringValue
                    
                    switch(status) {
                        
                    case success:
                    
                        let requestModel = RequestModel()
                        requestModel.item_id = self._dictFromParent?.itemId
                        requestModel.social_keys = JSON(self.arraySocialKeys)
                        self.callItemSharingAPI(requestModel)
                        
                        //Google Analytics
                        
                        let category = "UI"
                        let action = "\(UserModel.currentUser.displayName!) uploaded an item"
                        let lable = ""
                        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: self.title)
                        
                        //Google Analytics
                        
                        self.dismiss(animated: true, completion: {
                            let obj = ItemModel(fromJson: response[kData])
                            obj.dataFromWS = false
                            obj.rackName = self.rackName
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRepostCountUpdate), object: obj)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNewPostAdded), object: obj)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationSetHomePage), object: nil)
                            
                            
                            
                        })
                        
                        break
                    default :
                        self.dismiss(animated: true, completion: {
                        })
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
                        let obj = ItemModel(fromJson: response[kData])
                        obj.dataFromWS = false
                        obj.rackName = self.rackName
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: obj)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRackWantEdit), object: obj)
                        
                        if self.rackName != self._dictFromParent?.rackData.rackName {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRackList), object: obj)
                            
                            if self.editCompletion != nil {
                                self.editCompletion()
                            }
                        }
                        
                        //Google Analytics
                        
                        let category = "UI"
                        let action = "\(UserModel.currentUser.displayName!) updated an item"
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
                }
                if (code != nil) {
                }
                if (error != nil) {
                }
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
            
            self.activityIndicatorView.stopAnimating()
            
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
    
    @IBAction func btnCreateNewRack(_ sender: AnyObject) {
        let createNewRackVC:CreateNewRackVC = storyboard?.instantiateViewController(withIdentifier: "CreateNewRackVC") as! CreateNewRackVC
        createNewRackVC.image = self._imgPost
        createNewRackVC.isPresent = true
        createNewRackVC.newRackAdded = {(text) in
            self.filtered.removeAll()
            let firstData = folderStructure.modelsFromLocalDictionary(rackname: text, image: self._imgPost )
            self.arrayItemData.append(contentsOf: firstData)
            self.isRackSelected = true
            self.rackName = self.arrayItemData[self.arrayItemData.count-1].name
            self.filtered.append(self.arrayItemData[self.arrayItemData.count-1])
            self.tblView.reloadData()
        }
        
        self.navigationController?.pushViewController(createNewRackVC, animated: true)
    }
    
}

//MARK:- TableView Delegate
extension RepostAddCaptionVC: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        var headerHeight:CGFloat = 0
        if isRackSelected {
            headerHeight = (83.0 * kHeightAspectRasio) - 44
        }else{
            headerHeight = 83.0 * kHeightAspectRasio
        }
        
        return headerHeight
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! SelectRackHeaderCell
        headerCell.barSearch.delegate = self
        
        if isRackSelected {
            headerCell.constSearchBarHeight.constant = 0
        }else{
            headerCell.constSearchBarHeight.constant = 44
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnSelectRack))
        headerCell.lblTitle.isUserInteractionEnabled = true
        tapGesture.numberOfTapsRequired = 1
        headerCell.lblTitle.addGestureRecognizer(tapGesture)
        
        return headerCell
    }
    
    func tapOnSelectRack() {
        isRackSelected = false
        filtered = self.arrayItemData
        self.tblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96 * kHeightAspectRasio
    }
    
    // MARK: - ScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scrollVelocity = tblView.panGestureRecognizer.velocity(in: tblView.superview)
        if (scrollVelocity.y > 0.0) {
            view.endEditing(true)
        } else if (scrollVelocity.y < 0.0) {
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as! SelectRackListCell
        
        let objAtIndex = filtered[indexPath.row]
        cell.folderName.text = objAtIndex.name
        
        if objAtIndex.rackId.isEmpty {
            cell.imgView.image = objAtIndex.localImage
        }else{
            cell.imgView.setImageWithDownload(objAtIndex.image.url())
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if filtered.count == 1 {
            isRackSelected = false
            filtered = self.arrayItemData
            self.tblView.reloadData()
            
            return
        }
        
        
        let objAtIndex = filtered[indexPath.row]
        self.rackName = filtered[indexPath.row].name
        self.filtered = self.arrayItemData.filter({(obj: folderStructure) -> Bool in
            if obj.rackId == objAtIndex.rackId {
                return true
            }else{
                return false
            }
        })
        
        isRackSelected = true
        self.tblView.reloadData()
        
    }
    
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tblView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tblView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.filtered = searchText.isEmpty ? self.arrayItemData : self.arrayItemData.filter({(obj: folderStructure) -> Bool in
            let tmp: NSString = obj.name! as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        self.tblView.reloadData()
        searchBar.becomeFirstResponder()
        
    }
    
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
}

//MARK:- TextField Delegate
extension RepostAddCaptionVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newLength = textView.text.count + text.count - range.length
        
        if newLength == 200 {
            return false
        }
        
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

