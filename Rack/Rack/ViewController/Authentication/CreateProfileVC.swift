//
//  CreateProfileVC.swift
//  Rack
//
//  Created by hyperlink on 01/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import AFNetworking

class CreateProfileVC: UIViewController,UITextFieldDelegate,UITextViewDelegate {
    
    //MARK:- Outlet
    
  @IBOutlet weak var bgView2: UIView!
  @IBOutlet weak var bgView1: UIView!
  @IBOutlet weak var bgView3: UIView!
  
  @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var textContainer: CustomTextContainer!
    
    @IBOutlet weak var btnEditProfile: UIButton!
    
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtDisplayName: UITextField!
    @IBOutlet weak var tvBio: UITextView!
    
    @IBOutlet weak var ivProfile: UIImageView!
    
    @IBOutlet weak var lblCountCharacter: UILabel!
    
    @IBOutlet weak var lblUserNameAvailabality: UILabel!
    @IBOutlet weak var idicatorView: UIView!
    
    
    @IBOutlet weak var imageAspec: NSLayoutConstraint!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var btnSave: UIButton!
    var imagePicker : UIImagePickerController = UIImagePickerController()
    var fromPage = PageFrom.defaultScreen
    
    var userData = UserModel()
    var timer = Timer()
    var isValidUserName : Bool = false
    var isValidDisplayName : Bool = false
    var isValidImage : Bool = false
    
    var fbModel : FacebookModel? = nil
    var imageProfile : UIImage = UIImage() // to check user profile image change or not at edit profile time
    
    
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
    
    func setUpView() {
        
        //Apply button style
        btnEditProfile.applyStyle(
            titleLabelFont: UIFont.applyRegular(fontSize: 12.0)
            , titleLabelColor:  UIColor(red:146.0/255.0,green:146.0/255.0,blue:146.0/255.0,alpha:1.0)
        )
        
        
        //Apply Textfiled setup
        txtUserName.applyStyle(textFont: UIFont.applyRegular(fontSize: 12.0), textColor: AppColor.text)
        txtDisplayName.applyStyle(textFont: UIFont.applyRegular(fontSize: 12.0), textColor: AppColor.text)
        txtUserName.setAttributedPlaceHolder(placeHolderText: "Username", color: UIColor(red:146.0/255.0,green:146.0/255.0,blue:146.0/255.0,alpha:1.0))
        txtDisplayName.setAttributedPlaceHolder(placeHolderText: "Display name", color:UIColor(red:146.0/255.0,green:146.0/255.0,blue:146.0/255.0,alpha:1.0))
        txtUserName.tintColor = UIColor.black
        txtDisplayName.tintColor = UIColor.black
        tvBio.tintColor = UIColor.black
        
    
        
        //Apply Textview
        tvBio.text = "Bio"
        tvBio.backgroundColor = UIColor.clear
        tvBio.applyStyle(textFont: UIFont.applyRegular(fontSize: 12.0), textColor: AppColor.btnTitle)
        tvBio.textColor = UIColor(red:146.0/255.0,green:146.0/255.0,blue:146.0/255.0,alpha:1.0)
        
        tvBio.inputAccessoryView = UIToolbar().addToolBar(self)
        
        //Other font setup
        lblCountCharacter.applyStyle(labelFont: UIFont.applyRegular(fontSize: 12.0), labelColor: UIColor.colorFromHex(hex: kColorGray74))
        lblCountCharacter.textColor = UIColor(red:146.0/255.0,green:146.0/255.0,blue:146.0/255.0,alpha:1.0)
        lblCountCharacter.text = "0/200"
        
        //availablity label setup
        lblUserNameAvailabality.applyStyle(labelFont: UIFont.applyRegular(fontSize: 12.0))
        
        
        //profile image
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapOnProfileImage))
        tapGesture.numberOfTapsRequired = 1
        ivProfile.addGestureRecognizer(tapGesture)
        ivProfile.isUserInteractionEnabled = true
        ivProfile.tintColor = AppColor.secondaryTheme
      
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        ivProfile.layer.borderColor = UIColor(red:169.0/255.0,green:169.0/255.0,blue:169.0/255.0,alpha:1.0).cgColor
         ivProfile.applyStype(cornerRadius: ivProfile.frame.size.width / 2)
        self.ivProfile.layer.borderColor = UIColor(red:169.0/255.0,green:169.0/255.0,blue:169.0/255.0,alpha:1.0).cgColor
        self.ivProfile.layer.borderWidth = 1.0
        
        
         self.navigationController?.customize()
    }
    
    func setUpData() {
        
        //if Facebook Data avialble then set in.
        if let _ = self.fbModel {
            
            if let name = self.fbModel?.name {
                txtDisplayName.text = name
            }
            
            if let strUrl = self.fbModel?.picture.data.url {
                ivProfile.setImageWithDownload(strUrl.url())
                ivProfile.contentMode = .scaleAspectFill
                ivProfile.clipsToBounds = true
                ivProfile.applyStype(cornerRadius: ivProfile.frame.size.width / 2)
            }
        }
        
        switch fromPage {
        case .fromSettingPage:
            
            txtUserName.text = UserModel.currentUser.userName
            txtDisplayName.text = UserModel.currentUser.displayName
            tvBio.text = UserModel.currentUser.bioTxt
            
            self.ivProfile.image = nil
            self.ivProfile.contentMode = .scaleAspectFill
            self.ivProfile.clipsToBounds = true
            
            self.downloadImage(url: UserModel.currentUser.profile.url(), completion: { (isSuccess, image) in
                
                DispatchQueue.main.async(execute: {
                    if isSuccess {
                        self.imageProfile = image
                        _ = self.checkSaveButtonStatus()
                    }
                })
                
            })
            
            ivProfile.layer.borderColor = UIColor(red:169.0/255.0,green:169.0/255.0,blue:169.0/255.0,alpha:1.0).cgColor
            ivProfile.applyStype(cornerRadius: ivProfile.frame.size.width / 2)
            ivProfile.layer.borderWidth = 1.0
            
            //to manage save button status enable
            isValidUserName = true
            
            break
        case .defaultScreen:
            ivProfile.contentMode = .center
            break
        default:
            print("Default one called...")
        }
        
    }
    
    func tapOnProfileImage(_ sender : UITapGestureRecognizer) {
        sender.view?.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            sender.view?.isUserInteractionEnabled = true
        }
        self.openImagePickerSelection(sender)
    }
    
    func openImagePickerSelection(_ sender : Any) {
        
        let fusuma = FusumaViewController()
        fusuma.userData = userData
        fusuma.callBack = {(image) in
            
            self.ivProfile.image = image
            self.ivProfile.contentMode = .scaleAspectFill
            self.ivProfile.clipsToBounds = true
            _ = self.checkSaveButtonStatus()
            
        }
        
        fusuma.comingWhenTapOnImage = true
        fusuma.isNewuser = true;
        //fusuma.delegate = self
        fusuma.cropHeightRatio = 1.0
        fusuma.allowMultipleSelection = false
        fusumaSavesImage = true
        self.navigationController?.pushViewController(fusuma, animated: true)
        
        return
        
    }
    
    func downloadImage(url : URL? ,completion: @escaping (_ status : Bool , _ data : UIImage) -> Void) {
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            //print("Downloading Started")
            if let url = url {
                if let image = self.ivProfile.setImageWith(url)
                {
                    //print("Downloading Finished")
                    completion(true , image)
                }
            }
        })
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    func leftButtonClicked(){
        switch fromPage {
        case .defaultScreen:
            
            break
        case .fromSettingPage:
            if let _ = self.navigationController {
                _ = self.navigationController?.popViewController(animated: true)
            }
            break
        default:
            print("Default one called...")
        }
    }
    
    func rightButtonClicked() {
        
        view.endEditing(true)
        
        switch fromPage {
        case .defaultScreen:
            
            //Check save button status. And stop calling API
            if self.validateView() == true {
                _ = self.checkSaveButtonStatus()
                return
            }
            
            let requestModel : RequestModel = RequestModel()
            requestModel.user_id = userData.userId
            requestModel.user_name = txtUserName.text
            requestModel.display_name = txtDisplayName.text
            requestModel.bio_txt = tvBio.text == "Bio" ? "" : tvBio.text
            requestModel.device_token = GFunction.shared.getDeviceToken()
            requestModel.device_type = "I"
            
            self.callCreateProfileAPI(requestModel)
            
            break
        case .fromSettingPage:
            
            let requestModel : RequestModel = RequestModel()
            requestModel.user_id = UserModel.currentUser.userId
            requestModel.user_name = txtUserName.text
            requestModel.display_name = txtDisplayName.text
            requestModel.bio_txt = tvBio.text == "Bio" ? "" : tvBio.text
            self.callEditProfileAPI(requestModel)
            
            break
        default:
            print("Default one called...")
        }
        
    }
    
    
    @IBAction func btnProfileClicked(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            sender.isUserInteractionEnabled = true
        }
        self.openImagePickerSelection(sender)
    }
    
    func validateView() -> Bool {
        guard let image = ivProfile.image else {
            return true
        }
        let isUserDefaultImage = image.isEqualToImage(#imageLiteral(resourceName: "pencil"))
        
        let isError = false
        
        if isUserDefaultImage {
            return true
        } else if !isValidUserName {
            return true
        } else if txtDisplayName.text!.isEmpty {
            return true
        }
        
        return isError
    }
    
    func checkSaveButtonStatus() -> Bool {
        
        guard let _ = btnSave else {
            return false
        }
        
        //To handel image nil if image load from Facebook URL
        guard let image = ivProfile.image else {
            btnSave.isEnabled = false
            return false
        }
        
        //Check if user profile image, unique userName and displayName avialable then only save button enable.
        let isUserDefaultImage : Bool? = image.isEqualToImage(#imageLiteral(resourceName: "pencil"))
        
        if !isUserDefaultImage! {
            self.isValidImage = true
        }
        
        if !txtDisplayName.text!.isEmpty {
            isValidDisplayName = true
        }
        
        if !isUserDefaultImage! && isValidUserName && isValidDisplayName {
            btnSave.isEnabled = true
            return true
        } else {
            btnSave.isEnabled = false
            return false
        }
        
    }
    
    func checkUserName() {
        
        let requestModel = RequestModel()
        
        //to pass user ID
        switch fromPage {
        case .defaultScreen:
            requestModel.user_id = self.userData.userId;
            break
        case .fromSettingPage:
            requestModel.user_id = UserModel.currentUser.userId
            break
        default:break
        }
        
        requestModel.user_name = txtUserName.text
        
        //textfield blank then not require to call API
        if txtUserName.text!.isEmpty == true {
            return
        }else{
            
            let txtStr = txtUserName.text!
            let txtChars = Array(txtStr)
            guard (txtStr != "@" && !txtStr.isEmpty) else { return }
            
            if txtChars[1] == "." || txtChars[txtChars.count-1] == "." {
                self.lblUserNameAvailabality.textColor = UIColor.red
                self.lblUserNameAvailabality.text = "not allowed"
                return
            }
        }
        
        GFunction.shared.addActivityIndicator(view: idicatorView)
        self.callCheckUserNameAPI(requestModel) { (response,isValid) in
            
            GFunction.shared.removeActivityIndicator()
            if let _ = response {
                
                self.lblUserNameAvailabality.text = response?[kMessage].stringValue
                
                if isValid {
                    self.isValidUserName = true
                    self.lblUserNameAvailabality.textColor = AppColor.text 
                    
                    
                } else {
                    self.lblUserNameAvailabality.textColor = UIColor.red
                }
                
                _ = self.checkSaveButtonStatus()
                
            } else {
                self.lblUserNameAvailabality.text = ""
            }
            
        }
        
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callCreateProfileAPI(_ requestModel : RequestModel) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/create_profile
         
         Parameter   : user_id,user_name,display_name,bio_txt(max 200 char),device_type[A,I],device_token,profile(image for user)
         
         Optional    :
         
         Comment     : This api will used for create or update user profile (Setup 2).
         
         
         ==============================
         
         */
        
        var imageData : Data? = nil
        //If image not equal default Image
        let isUserDefaultImage = ivProfile.image?.isEqualToImage(#imageLiteral(resourceName: "pencil"))
        if !(isUserDefaultImage!) {
            imageData = compressImage(ivProfile.image!, compressionRatio: 0.8)
        }
        
        APICall.shared.CancelTask(url: kMethodCreateProfile)
        
        APICall.shared.POST(strURL: kMethodCreateProfile
            , parameter: requestModel.toDictionary()
            , withLoader: true
            , constructingBodyWithBlock: { (formData : AFMultipartFormData?) in
                
                if let _ = imageData {
                    formData!.appendPart(withFileData: imageData! as Data, name: "profile", fileName: "profile.jpeg", mimeType: "image/jpeg")
                }
                
        }) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    // Save UserProfile image in locally
                    UserDefaults.standard.set(imageData, forKey: kUserProfileImage)
                    
                    let fusuma = FusumaViewController()
                    fusuma.userData = UserModel(fromJson: response[kData])
                    //fusuma.delegate = self
                    fusuma.cropHeightRatio = 1.0
                    fusuma.allowMultipleSelection = false
                    fusumaSavesImage = true
                    self.navigationController?.pushViewController(fusuma, animated: true)
                    
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
    
    func callCheckUserNameAPI(_ requestModel : RequestModel , withBlock completion : @escaping (JSON?,Bool) -> Void)  {
        
        /*
         ===========API CALL===========
         
         Method Name : user/check_username
         
         Parameter   : user_name
         
         Optional    :
         
         Comment     : This api will used for check the User Name.
         
         
         ==============================
         
         */
        
        APICall.shared.PUT(strURL: kMethodCheckUsername
            ,parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    completion(response,true)
                    break
                    
                default :
                    //print(response[kMessage].stringValue)
                    completion(response,false)
                    break
                }
                
            } else {
                completion(nil,false)
            }
            
        }
        
    }
    
    func callEditProfileAPI(_ requestModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : user/create_profile
         
         Parameter   :
         
         Optional    : user_name,display_name,bio_txt,profile,wardrobes_id,wardrobes_image
         
         Comment     : This api will used for user update the user detail.
         
         
         ==============================
         
         */
        
        guard let ivProfileImage = ivProfile.image else {
            return
        }
        
        var imageData : Data? = nil
        //If image not equal default Image
        let isUserDefaultImage = ivProfileImage.isEqualToImage(self.imageProfile)
        if !(isUserDefaultImage) {
            imageData = compressImage(ivProfile.image!, compressionRatio: 0.8)
        }
        
        
        APICall.shared.POST(strURL: kMethodUserEdit
            , parameter: requestModel.toDictionary()
            , withLoader: true
            , constructingBodyWithBlock: { (formData : AFMultipartFormData?) in
                
                if let _ = imageData {
                    formData!.appendPart(withFileData: imageData! as Data, name: "profile", fileName: "profile.jpeg", mimeType: "image/jpeg")
                }
                
        }) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    // Save UserProfile image in locally
                    UserDefaults.standard.set(imageData, forKey: kUserProfileImage)
                    
                    let userData = UserModel(fromJson: response[kData])
                    //Save User Data into userDefaults.
                    userData.saveUserDetailInDefaults()
                    
                    //load latest data in to current User
                    UserModel.currentUser.getUserDetailFromDefaults()
                    
                    AlertManager.shared.showPopUpAlert("Edit Profile", message: response[kMessage].stringValue, forTime: 2.0, completionBlock: { (Int) in
                        if let _ = self.navigationController {
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    })
                    
                    //post notification to profile vc to update data
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationProfileUpdate), object: userData)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
                    
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
    
    
    func compressImage(_ image: UIImage, compressionRatio : Float) -> Data? {
        var compressionQuality: Float = compressionRatio
        var imageData = UIImageJPEGRepresentation(image, CGFloat(compressionQuality))
        while Float((imageData! as NSData).length)/1024.0/1024.0 > 0.10 && compressionQuality > 0.02 {
            compressionQuality -= 0.05
            imageData = UIImageJPEGRepresentation(image, CGFloat(compressionQuality))
        }
        return imageData
    }
    
    //------------------------------------------------------
    
    //MARK: - TextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.isEqual(txtUserName) {
            textField.text = "@"
            isValidUserName = false
            lblUserNameAvailabality.text = ""
            _ = self.checkSaveButtonStatus()
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //If Textfield have only one character "@" then clear textfield text
        if textField.isEqual(txtUserName) && txtUserName.text?.characters.count == 1 {
            textField.text = ""
            lblUserNameAvailabality.text = ""
        }
        
        _ = self.checkSaveButtonStatus()
    }
    
    func isValidInput(Input:String) -> Bool {
        let myCharSet=CharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.")
        let output: String = Input.trimmingCharacters(in: myCharSet.inverted)
        let isValid: Bool = (Input == output)
        //print("\(isValid)")
        
        return isValid
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        
        if newLength == 31 {
            return false
        }
        
        if range.location == 0 && string == " "  {
            return false
        }
        
        if textField.isEqual(txtUserName) {
            
            //To manage not removing @ sign
            if range.location == 1 && string == " " {
                return false
            }
            
            if string == " " {
                return false
            }
            
            if newLength != 0 {
                
                if timer.isValid {
                    timer.invalidate()
                }
                
                //to check save button status.
                isValidUserName = false
                
                self.lblUserNameAvailabality.text = ""
                
                timer = Timer.scheduledTimer(timeInterval: 0.5
                    , target: self
                    , selector: #selector(checkUserName), userInfo: txtUserName, repeats: false)
                
            }
            
            if newLength == 1 {
                
                if timer.isValid {
                    timer.invalidate()
                }
                
                //to check save button status.
                isValidUserName = false
                
                self.lblUserNameAvailabality.text = ""
                
                timer = Timer.scheduledTimer(timeInterval: 0.5
                    , target: self
                    , selector: #selector(checkUserName), userInfo: txtUserName, repeats: false)
                
            }
            
            if newLength == 1 && txtUserName.text!.characters.count > 2 {
                txtUserName.text = "@"
            }
            
            if let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange,
                                                           with: string)
                let arrChar = Array(updatedText)
                if updatedText.isEmpty {
                    txtUserName.text = "@"
                    return false
                }else{
                    if arrChar[0] != "@" {
                        return false
                    }
                }
            }
            
            return self.isValidInput(Input: string)

        } else if textField.isEqual(txtDisplayName) {
            if newLength <= 30 && newLength > 0{
                isValidDisplayName = true
            }else{
                isValidDisplayName = false
            }

            if self.isValidImage && isValidUserName && isValidDisplayName {
                btnSave.isEnabled = true
            } else {
                btnSave.isEnabled = false
            }
            
            return true
        }
        
        _ = self.checkSaveButtonStatus()
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTextFiled = textContainer.viewWithTag(textField.tag + 1)
        if textField.isEqual(txtDisplayName) {
            self.view.endEditing(true)
            //            tvBio.becomeFirstResponder()
        } else {
            nextTextFiled?.becomeFirstResponder()
        }
        
        return true
    }
    
    //------------------------------------------------------
    
    //MARK:- Textview Delegate method
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor =  AppColor.text
        if textView.text == "Bio" {
            tvBio.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            tvBio.text = "Bio"
            textView.textColor = UIColor(red:146.0/255.0,green:146.0/255.0,blue:146.0/255.0,alpha:1.0)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newLength = textView.text.characters.count + text.characters.count - range.length
        
        if (range.location == 0 && text == " ") || (range.location == 0 && text == "\n") {
            return false
        }
        
        if newLength <= 200 {
            
        } else {
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let lenght = textView.text.characters.count
        lblCountCharacter.text = "\(lenght)/200"
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
      bgView1.backgroundColor = .clear
      bgView1.layer.borderColor = UIColor(red:0.0/255.0,green:0.0/255.0,blue:0.0/255.0,alpha:0.08).cgColor
      bgView1.layer.cornerRadius = 5.0
      bgView1.layer.borderWidth = 0.7
      
      bgView2.backgroundColor = .clear
      bgView2.layer.borderColor = UIColor(red:0.0/255.0,green:0.0/255.0,blue:0.0/255.0,alpha:0.08).cgColor
      bgView2.layer.cornerRadius = 5.0
      bgView2.layer.borderWidth = 0.7
      
      bgView3.backgroundColor = .clear
      bgView3.layer.borderColor = UIColor(red:0.0/255.0,green:0.0/255.0,blue:0.0/255.0,alpha:0.08).cgColor
      bgView3.layer.cornerRadius = 5.0
      bgView3.layer.borderWidth = 0.7
      
      txtUserName.backgroundColor = .clear
      
      self.view.backgroundColor = AppColor.primaryTheme
      self.topView.backgroundColor = AppColor.primaryTheme
      self.navigationController?.navigationBar.barTintColor = AppColor.primaryTheme
      self.navigationController?.navigationBar.isTranslucent = true

        self.setUpView()
        self.setUpData()
        
        self.ivProfile.layer.borderColor = UIColor(red:169.0/255.0,green:169.0/255.0,blue:169.0/255.0,alpha:1.0).cgColor
        self.ivProfile.layer.borderWidth = 1.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Reuuire to save button disable. Button array getting from addBarButtons.
        var arrayButton = [UIButton]()
        
        //To manage navigation bar button. At edit profile and create Profile
        switch fromPage {
        case .defaultScreen:
            arrayButton = addBarButtons(btnLeft: nil, btnRight: BarButton(title: "Next", color: AppColor.btnTitle), title: "Create Profile",isSwipeBack: false)
            break
        case .fromSettingPage:
          arrayButton = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: BarButton(title: "Save", color: AppColor.btnTitle), title: "Edit Profile")
            break
        default:
            print("Default one called...")
        }
        
        //Apply rightBarButton reference to btnSave
        btnSave = arrayButton[1]
        
        //Google Analytics
        
        let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: self.title)
        
        //Google Analytics
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //ManageSave Button management
        _ = self.checkSaveButtonStatus()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}

extension CreateProfileVC : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        ivProfile.contentMode = .scaleToFill
        ivProfile.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        ivProfile.applyStype(cornerRadius: ivProfile.frame.size.width / 2)
        
        _ = self.checkSaveButtonStatus()
        
    }
}

extension CreateProfileVC{
    func showCamera()  {
        
        let customCameraVC:CustomCameraVC = CustomCameraVC()
        customCameraVC.callBack = {(image) in
            self.ivProfile.contentMode = .scaleToFill
            self.ivProfile.image = image
            self.ivProfile.applyStype(cornerRadius: self.ivProfile.frame.size.width / 2)
            _ = self.checkSaveButtonStatus()
        }
        self.present(customCameraVC, animated: true, completion: nil)
        return
            
        
        imagePicker.view.backgroundColor = UIColor.white
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.isNavigationBarHidden = true
        imagePicker.isToolbarHidden = true
        imagePicker.showsCameraControls = false;
       // imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.edgesForExtendedLayout = UIRectEdge.all
        //imagePicker.extendedLayoutIncludesOpaqueBars = true;
        
        let screenSize:CGSize = UIScreen.main.bounds.size
        
        
        let cameraAspectRatio:CGFloat = 4.0 / 3.0;
        let imageWidth:CGFloat = CGFloat(floorf(Float(screenSize.width * cameraAspectRatio)));
        let scale:CGFloat = CGFloat(ceilf(Float((screenSize.height / imageWidth) * 80.0)) / 80.0);
        
        
        //imagePicker.cameraViewTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        
        // CGAffineTransformMakeScale(scale, scale);
        
        
        let overlayView = UIView()
        overlayView.frame = imagePicker.view.bounds
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
        
        imagePicker.cameraOverlayView  = overlayView
        
        
        
        present(imagePicker, animated: true, completion: nil)
        
        
        
        
    }
    
    
    func toogleCamera(){
        if self.imagePicker.cameraDevice == .front {
            UIView.transition(with: self.imagePicker.view, duration: 1.0, options: [.allowAnimatedContent, .transitionFlipFromLeft], animations: {
                self.imagePicker.cameraDevice = .rear
            }, completion: nil)
        }else {
            UIView.transition(with: self.imagePicker.view, duration: 1.0, options: [.allowAnimatedContent, .transitionFlipFromRight], animations: {
                self.imagePicker.cameraDevice = .front
            }, completion: nil)
        }
    }
    
    func toogleFlash(){
        if self.imagePicker.cameraFlashMode == UIImagePickerControllerCameraFlashMode.on {
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.off
        }else {
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.on
        }
    }
    func takePhoto(){
        imagePicker.takePicture()
    }
    func cancelButtonAction()  {
        dismiss(animated: true, completion: nil)
    }
}

extension CreateProfileVC : ChooseRectDelegate {
    
    func getSelectedReckDetail(data: Dictionary<String, Any>) {
        
        if let image = data[kImage] as? UIImage {
            ivProfile.contentMode = .scaleToFill
            ivProfile.image = image
            ivProfile.applyStype(cornerRadius: ivProfile.frame.size.width / 2)
        }
        _ = self.checkSaveButtonStatus()
        
    }
}
