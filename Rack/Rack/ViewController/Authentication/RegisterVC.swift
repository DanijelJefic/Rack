//
//  RegisterVC.swift
//  Rack
//
//  Created by hyperlink on 01/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import ActiveLabel
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

extension RegisterVC:GIDSignInUIDelegate,GIDSignInDelegate{
    @nonobjc func signInWillDispatch(signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                     withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            //let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            //let givenName = user.profile.givenName
            //let familyName = user.profile.familyName
            let email = user.profile.email
            
  
            let requestModel : RequestModel = RequestModel()
            requestModel.fb_id = userId
            requestModel.login_type = "F"
            requestModel.device_type = "I"
            requestModel.device_token = GFunction.shared.getDeviceToken()
            requestModel.email = email
           
            //let json = JSON(dicFacebook)
            self.fbModel = FacebookModel()
            self.fbModel?.email = email
        
            self.fbModel?.firstName = fullName
            self.fbModel?.id = userId
            self.fbModel?.lastName = ""
            self.fbModel?.name = fullName
            
         
            
            
            
            
            self.callLoginUserAPI(requestModel)
            
        } else {
            //AlertManager.shared.showAlertTitle(title: "Google Error"
            //  ,message: error.localizedDescription)
            return
            // //print("\(error.localized)")
        }
    }
}

class RegisterVC: UIViewController, UITextFieldDelegate{
    
    //MARK:- Outlet
    @IBOutlet weak var btnFB: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnShow: UIButton!
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPassword: UIView!
    
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var lblPrivacyPolicy: ActiveLabel!
    @IBOutlet weak var lblWelcomeTo: UILabel!

  @IBOutlet weak var googButton: UIButton!
  @IBOutlet weak var textContainer : CustomTextContainer!
    
  @IBAction func googleButtonClicked(_ sender: Any) {
    
    if (GIDSignIn.sharedInstance().currentUser != nil){
        GIDSignIn.sharedInstance().signOut()
    }
    
    
    GIDSignIn.sharedInstance().uiDelegate = self
    GIDSignIn.sharedInstance().delegate = self
    GIDSignIn.sharedInstance().signIn()
  }
  //------------------------------------------------------
    
    //MARK:- Class Variable
    var fbModel : FacebookModel? = nil
    
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
        btnFB.applyStyle(
            titleLabelFont: UIFont.applyRegular(fontSize: 15.0)
            , titleLabelColor: UIColor.white
            , backgroundColor: UIColor.clear)
      
        
        btnRegister.applyStyle(
            
            titleLabelFont : UIFont.applyRegular(fontSize: 13.0)
            , titleLabelColor : AppColor.text
            , cornerRadius: 5.0
            , backgroundColor: AppColor.primaryTheme
            
        )
        btnRegister.backgroundColor = UIColor.black
        btnRegister.layer.cornerRadius = 5.0
        btnRegister.setTitleColor(UIColor.white, for: .normal)
        btnRegister.setTitleColor(UIColor.lightGray, for: .highlighted)
        btnRegister.setTitle("Sign Up", for: .normal)
        btnRegister.layer.cornerRadius = 5.0
        btnRegister.titleLabel?.font = UIFont.applyRegular(fontSize: 13.0)
        btnRegister.setTitleColor(UIColor(red:161.0/255.0, green:159.0/255.0,blue:159.0/255.0,alpha:1.0), for: .normal)
        btnRegister.setTitleColor(UIColor.white, for: .highlighted)
        btnRegister.backgroundColor = UIColor(red:37.0/255.0, green:37.0/255.0,blue:37.0/255.0,alpha:1.0)
        
        
        btnShow.applyStyle(
            titleLabelFont: UIFont.applyRegular(fontSize: 12.0)
            , titleLabelColor: AppColor.text
        )
        
        //Apply View setup
        viewEmail.applyViewShadow(cornerRadius: 4.0
            ,backgroundColor: AppColor.primaryTheme
            , backgroundOpacity: 0.9)
        viewPassword.applyViewShadow(cornerRadius: 4.0
            ,backgroundColor: AppColor.primaryTheme
            , backgroundOpacity: 0.9)
        
        //Apply Textfiled setup
        txtEmail.applyStyle(textFont: UIFont.applyRegular(fontSize: 13.0), textColor: AppColor.text)
        txtEmail.tintColor = UIColor.black
        txtEmail.textAlignment = .center
        viewEmail.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        viewEmail.layer.borderWidth = 0.5
        viewEmail.layer.cornerRadius = 5.0
      //  var leftView = UIView()
       // leftView.frame = CGRect(x:0,y:0,width:20.0,height:self.txtEmail.frame.size.height)
       // self.viewEmail.leftView = leftView
        //self.viewEmail.leftViewMode = .always
        
        
        txtPassword.applyStyle(textFont: UIFont.applyRegular(fontSize: 13.0), textColor: AppColor.text)
        txtPassword.tintColor = UIColor.black
        txtPassword.textAlignment = .center
        viewPassword.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        viewPassword.layer.borderWidth = 0.5
        viewPassword.layer.cornerRadius = 5.0
        
        //leftView = UIView()
        //leftView.frame = CGRect(x:0,y:0,width:20.0,height:self.txtEmail.frame.size.height)
        //self.txtPassword.leftView = leftView
        //self.txtPassword.leftViewMode = .always
        
        txtEmail.setAttributedPlaceHolder(placeHolderText: "email", color: AppColor.placeHolder)
        txtPassword.setAttributedPlaceHolder(placeHolderText: "password", color: AppColor.placeHolder)
        
        //txtPassword.setRightPaddingPoints(50)
        
        /*lblWelcomeTo.applyStyle(
            labelFont: UIFont.applyBold(fontSize: 17.0)
            , labelColor: UIColor.white
            , labelShadow: CGSize(width: 0, height: -3)
        )*/
        
        //Other font setUp
//        lblOr.applyStyle(
//            labelFont: UIFont.applyRegular(fontSize: 15.0)
//            , labelColor: UIColor.white
//        )

//        lblPrivacyPolicy.applyStyle(labelFont: UIFont.applyRegular(fontSize: 12.0),
//                         labelColor: UIColor.colorFromHex(hex: kColorGray74)
//        )

        
    }
    
    func leftButtonClicked()  {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func validateView() -> Dictionary<String,String>? {
        
        var message : Dictionary<String,String>? = nil
        
        if txtEmail.text == "" {
            message = [kError:"Sign Up",kMessage:"Please enter email"]
        } else if !txtEmail.text!.isValidEmail() {
            message = [kError:"Sign Up",kMessage:"Please enter valid email"]
        } else if txtPassword.text == "" {
            message = [kError:"Sign Up",kMessage:"Please enter password"]
        } else if txtPassword.text!.characters.count < 6 {
            message = [kError:"Sign Up`",kMessage:"Password must contain at least 6 characters"]
        }

        return message
        
    }
    
    func tapOnPrivacyPlocyLabel(_ gesture : UITapGestureRecognizer) {
       
        return;
//            let lbl: UILabel? = (gesture.view?.hitTest(gesture.location(in: gesture.view), with: nil) as? UILabel)

        if let range = lblPrivacyPolicy.text?.range(of: "Privacy Policy") {
            let startIndex = lblPrivacyPolicy.text?.distance(from: lblPrivacyPolicy.text!.startIndex, to: range.lowerBound)
            let range1 = NSMakeRange(startIndex!, "Privacy Policy".characters.count)
            
            let tapLocation = gesture.location(in: lblPrivacyPolicy)
            let index = lblPrivacyPolicy.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
            
            if index > range1.location && index < range1.location + range1.length {
                //print("Privacy Policy")
            }
            
        }

        if let range = lblPrivacyPolicy.text?.range(of: "Terms of Service") {
            let startIndex = lblPrivacyPolicy.text?.distance(from: lblPrivacyPolicy.text!.startIndex, to: range.lowerBound)
            let range1 = NSMakeRange(startIndex!, "Terms of Service".characters.count)

            let tapLocation = gesture.location(in: lblPrivacyPolicy)
            let index = lblPrivacyPolicy.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
            
            if index > range1.location && index < range1.location + range1.length {
                //print("Terms&condition")
            }
            
        }

    }
    
    //------------------------------------------------------
    
    //MARK:- API Call
    
    func callRegisterUserAPI(_ requestModel : RequestModel) {

        /*
         ===========API CALL===========
         
         Method Name : user/signup
         
         Parameter   : email,password,device_type[A,I],device_token,login_type[F,S]
         
         Optional    :
         
         Comment     : This api will used for new user signup.
                       login_type = S,F (S :- Simple login and F :- facebook login)
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodSignup
            , parameter: requestModel.toDictionary()
            , withLoader: true
            , withBlock: { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
          
                if (error == nil) {
                    let response = JSON(response ?? [:])
                    let status = response[kCode].stringValue

                    switch(status) {
                        
                    case success:
                        
                        let userData = UserModel(fromJson: response[kData])
                        //user token receive only in login/signup API only.
                        //So require to save token after two these API
                        userData.saveUserSessionInToDefaults()

                        let createProfileVC : CreateProfileVC = mainStoryBoard.instantiateViewController(withIdentifier: "CreateProfileVC") as! CreateProfileVC
                        createProfileVC.userData = userData
                        
                        UserDefaults.standard.set(true, forKey: "newUser")
                        self.navigationController?.pushViewController(createProfileVC, animated: true)
                        
                        break
                    default :
                      // GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
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
    
    func callLoginUserAPI(_ requestModel : RequestModel) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/login
         
         Parameter   : device_type[A,I],device_token,login_type[F,S]
         
         Optional    : usernm_email,password,fb_id,email
         
         Comment     : This api will used for login app using fb and simaple both.
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodLogin
            , parameter: requestModel.toDictionary()
            , withLoader: true
            , withBlock: { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
                
                if (error == nil) {
                    let response = JSON(response ?? [:])
                    let status = response[kCode].stringValue
                    
                    switch(status) {
                        
                    case success:
                        
                        let userData = UserModel(fromJson: response[kData])
                        
                        switch(userData.signupStatus) {
                            
                        case userAuthStatu.profile.rawValue:
                            
                            let vc : CreateProfileVC = mainStoryBoard.instantiateViewController(withIdentifier: "CreateProfileVC") as! CreateProfileVC
                            vc.userData = userData
                            vc.fbModel = self.fbModel
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                            break
                            
                        case userAuthStatu.wardrobes.rawValue:
                            
                            let fusuma = FusumaViewController()
                            fusuma.userData = userData
                            fusuma.cropHeightRatio = 1.0
                            fusuma.allowMultipleSelection = false
                            fusumaSavesImage = true
                            
                            self.navigationController?.pushViewController(fusuma, animated: true)
                            
                            break
                            
                        case userAuthStatu.friend.rawValue:
                            
                            
                            let vc : FollowFriendVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowFriendVC") as! FollowFriendVC
                            vc.userData = userData
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                            break
                        case userAuthStatu.login.rawValue:
                            
                            //Save User Data into userDefaults.
                            userData.saveUserDetailInDefaults()
                            
                            // Disable TipViews or GuideViews
                            UserDefaults.standard.set(true, forKey: kCreateRackAnimation)
                            UserDefaults.standard.set(true, forKey: kCoverPhotoAnimation)
                            UserDefaults.standard.set(true, forKey: kNewRackAnimation)
                            UserDefaults.standard.set(true, forKey: kFollowUserAnimation)
                            UserDefaults.standard.set(true, forKey: kRepostingPhotoAnimation)
                            UserDefaults.standard.set(true, forKey: kRepostPhotoAnimation)
                            UserDefaults.standard.set(true, forKey: kSaveRackAnimation)
                            
                            //user token receive only in login/signup API only.
                            //So require to save token after two these API
                            userData.saveUserSessionInToDefaults()
                            
                            GFunction.shared.userLogin(AppDelegate.shared.window)
                            break
                        default:
                            //print("Default One called.....SingUP Status")
                            break
                        }
                        break
                    default :
                        GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                        break
                    }
                    
                } else {
                    AlertManager.shared.showPopUpAlert("", message: error?.localizedDescription, forTime: 2.0, completionBlock: { (Int) in
                    })
                }
        })
        
    }

    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //------------------------------------------------------
    
    //MARK:- Action Method
    @IBAction func btnFBClicked(_ sender : UIButton) {

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let loginManager : FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        loginManager.logIn(withReadPermissions: ["email","public_profile"], from: self) {
            (result, error) -> Void in
            
            if (error == nil){
                
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                
                if (fbloginresult.grantedPermissions != nil) {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        if((FBSDKAccessToken.current()) != nil){
                            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                                
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                
                                if (error == nil){
                                    //everything works print the user data
                                    //print("Facebook Result :", result as Any)
                                    
                                    let dicFacebook = result as! Dictionary<String, Any>
                                    
                                    let requestModel : RequestModel = RequestModel()
                                    requestModel.fb_id = dicFacebook["id"] as? String
                                    requestModel.login_type = "F"
                                    requestModel.device_type = "I"
                                    requestModel.device_token = GFunction.shared.getDeviceToken()
                                    
                                    //Check Facebook email validaation
                                    if let email = dicFacebook["email"] as? String {
                                        requestModel.email = email
                                    } else {
                                        
                                        AlertManager.shared.showAlertTitle(title: "Facebook Error"
                                            ,message: "By the looks of things, your Facebook account is not fully verified. Please verify your Facebook account, or alternatively register to Rack using an email address.")
                                        return
                                    }
                                    
                                    let json = JSON(dicFacebook)
                                    self.fbModel = FacebookModel(fromJson: json)
                                    
                                    self.callLoginUserAPI(requestModel)
                                    
                                }
                            })
                        }   
                    }
                }
            }
        }
    }
    
    @IBAction func btnRegisterClicked(_ sender : UIButton) {
        
        let message = self.validateView()
        
        //Success Validation
        if (message == nil) {
            
            self.view.endEditing(true)

            let requestModel : RequestModel = RequestModel()
            requestModel.email = txtEmail.text
            requestModel.password = txtPassword.text
            requestModel.login_type = "S"
            requestModel.device_type = "I"
            requestModel.device_token = GFunction.shared.getDeviceToken()
            self.callRegisterUserAPI(requestModel)
            
        } else { // Error

            AlertManager.shared.showAlertTitle(title: message?[kError]! ,message: message?[kMessage]!)
        }
        
    }
    
    @IBAction func btnShowClicked(_ sender : UIButton) {
        
        let isSecureEntry = txtPassword.isSecureTextEntry
        self.txtPassword.isSecureTextEntry = !self.txtPassword.isSecureTextEntry
        btnShow.setTitle(isSecureEntry ? "Hide" : "Show", for: .normal)
        
    }
    
    //------------------------------------------------------
    
    //MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        
        if !(textField.isEqual(txtPassword)) {
            if range.location == 0 && string == " " {
                return false
            }
        }
        
        if textField.isEqual(txtEmail) {
            if newLength <= 64 {
                
                /*let nameRegEx = "^[0-9]*"
                 let nameTest = NSPredicate(format: "SELF MATCHES %@",nameRegEx)
                 return nameTest.evaluate(with: string)*/
            } else {
                return false
            }
        }
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTextFiled = textContainer.viewWithTag(textField.tag + 1)
        if textField.isEqual(txtPassword) {
            self.view.endEditing(true)
        } else {
            nextTextFiled?.becomeFirstResponder()
        }
        
        return true
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: nil, title: "")
        self.navigationController?.isNavigationBarHidden = true
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: nil, title: "")
        self.navigationController?.isNavigationBarHidden = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

}
