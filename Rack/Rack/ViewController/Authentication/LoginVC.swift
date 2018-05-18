//
//  LoginVC.swift
//  Rack
//
//  Created by hyperlink on 28/04/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import IQKeyboardManagerSwift


struct ScreenSize
{
  static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
  static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
  static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
  static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}
struct DeviceType
{
  
  static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
  static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
  static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
  static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
  static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
  static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad
}

import UIKit
import ActiveLabel
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

extension LoginVC: GIDSignInUIDelegate,GIDSignInDelegate{
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
      
      self.fbModel = FacebookModel()
      self.fbModel?.email = email
      
      self.fbModel?.firstName = fullName
      self.fbModel?.id = userId
      self.fbModel?.lastName = ""
      self.fbModel?.name = fullName
      
      
      
      let requestModel : RequestModel = RequestModel()
      requestModel.google_id = userId
      requestModel.login_type = "G"
      requestModel.device_type = "I"
      requestModel.device_token = GFunction.shared.getDeviceToken()
      requestModel.email = email
      
      self.callLoginUserAPI(requestModel)
      
    } else {
      //AlertManager.shared.showAlertTitle(title: "Google Error"
      //  ,message: error.localizedDescription)
      return
      // //print("\(error.localized)")
    }
  }
}

class LoginVC: UIViewController, UITextFieldDelegate{
  
  //
  @IBOutlet weak var tutorialBGView: UIView!
  @IBOutlet weak var scrollView1: UIScrollView!
  @IBOutlet weak var frameBGView: UIView!
  @IBOutlet weak var scrollView2: UIScrollView!
  @IBOutlet weak var frameImageView: UIImageView!
  
  @IBOutlet weak var lbl1: UILabel!
  @IBOutlet weak var lbl2: UILabel!
  @IBOutlet weak var lbl3: UILabel!
  @IBOutlet weak var lbl4: UILabel!
  
  
  @IBOutlet weak var pageControl: UIPageControl!
  

  //MARK:- Outlet
  @IBOutlet weak var btnFB: UIButton!
  @IBOutlet weak var btnLogin: UIButton!
  @IBOutlet weak var btnForgotPassword: UIButton!
  @IBOutlet weak var btnShow: UIButton!
  @IBOutlet weak var btnSignUp: UIButton!
  
  @IBOutlet weak var txtEmail: UITextField!
  @IBOutlet weak var txtPassword: UITextField!
  
  @IBOutlet weak var viewEmail: UIView!
  @IBOutlet weak var viewPassword: UIView!
  
  
  // let frameImageView = UIImageView()
  @IBOutlet weak var textContainer : CustomTextContainer!
  
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
  
  @IBAction func googleSigninButtonaction(_ sender: Any) {
    
    if (GIDSignIn.sharedInstance().currentUser != nil){
      GIDSignIn.sharedInstance().signOut()
    }
    
    
    GIDSignIn.sharedInstance().uiDelegate = self
    GIDSignIn.sharedInstance().delegate = self
    GIDSignIn.sharedInstance().signIn()
    
  }
  
  func setUpView() {
    
    IQKeyboardManager.sharedManager().enable = true
    IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace = false
    IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 100.0
    
    mainScrollView.isScrollEnabled = true
    mainScrollView.keyboardDismissMode = .onDrag
    mainScrollView.delegate = self
    mainScrollView.showsVerticalScrollIndicator = false
    mainScrollView.showsHorizontalScrollIndicator = false
    
    lbl1.text = "Follow your friends and many different accounts."
    lbl1.textColor = UIColor(red:130.0/255.0,green:130.0/255.0,blue:130.0/255.0,alpha:1.0)
    lbl1.font = UIFont.applyRegular(fontSize: 10.5)
    
    lbl2.text = "Like, repost and save your favourite posts."
    lbl2.textColor = UIColor(red:130.0/255.0,green:130.0/255.0,blue:130.0/255.0,alpha:1.0)
    lbl2.font = UIFont.applyRegular(fontSize: 10.5)
    
    lbl3.text = "Track how many reposts you get."
    lbl3.textColor = UIColor(red:130.0/255.0,green:130.0/255.0,blue:130.0/255.0,alpha:1.0)
    lbl3.font = UIFont.applyRegular(fontSize: 10.5)
    
    lbl4.text = "Create and customize your own Racks."
    lbl4.textColor = UIColor(red:130.0/255.0,green:130.0/255.0,blue:130.0/255.0,alpha:1.0)
    lbl4.font = UIFont.applyRegular(fontSize: 11.5)
    
    pageControl.currentPageIndicatorTintColor = UIColor.black
    pageControl.pageIndicatorTintColor = UIColor.lightGray
    pageControl.numberOfPages = 4
    
    scrollView1.clipsToBounds = true
    scrollView2.clipsToBounds = true
    frameBGView.clipsToBounds = true
    frameBGView.layer.cornerRadius = 10.0
    
    GIDSignIn.sharedInstance().uiDelegate = self
    
    //self.textContainerYOffset.constant = self.view.frame.size.height-yOffset
    btnLogin.applyStyle(
      titleLabelFont : UIFont.applyRegular(fontSize: 15.0)
      , titleLabelColor : AppColor.text
      , cornerRadius: 3
      , backgroundColor: AppColor.primaryTheme
    )
    btnLogin.setTitle("Sign In", for: .normal)
    btnLogin.layer.cornerRadius = 5.0
    btnLogin.titleLabel?.font = UIFont.applyRegular(fontSize: 13.0)
    btnLogin.setTitleColor(UIColor(red:161.0/255.0, green:159.0/255.0,blue:159.0/255.0,alpha:1.0), for: .normal)
    btnLogin.setTitleColor(UIColor.white, for: .highlighted)
    btnLogin.backgroundColor = UIColor(red:37.0/255.0, green:37.0/255.0,blue:37.0/255.0,alpha:1.0)
    
    btnForgotPassword.applyStyle(
      titleLabelFont: UIFont.applyRegular(fontSize: 11.0)
      , titleLabelColor:UIColor(red:37.0/255.0, green:37.0/255.0,blue:37.0/255.0,alpha:1.0)
    )
    
    btnShow.applyStyle(
      titleLabelFont: UIFont.applyRegular(fontSize: 12.0)
      , titleLabelColor: UIColor.white
    )
    
    btnSignUp.applyStyle(
      titleLabelFont : UIFont.applyRegular(fontSize: 15.0)
      , titleLabelColor : UIColor(red:17.0/255.0, green:17.0/255.0,blue:17.0/255.0,alpha:1.0)
    )
    
    //Apply View setup
    viewEmail.applyViewShadow(cornerRadius: 5
      ,backgroundColor: UIColor.white
    )
    self.viewEmail.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
    self.viewEmail.layer.borderWidth = 0.5
    txtEmail.applyStyle(textFont: UIFont.applyRegular(fontSize: 13.0), textColor: AppColor.text)
    txtEmail.textAlignment = .center
    txtEmail.tintColor = UIColor.black
    viewEmail.layer.cornerRadius  = 5.0
    
    
    viewPassword.applyViewShadow(cornerRadius: 5
      ,backgroundColor: UIColor.white
      , backgroundOpacity: 0.9)
    
    self.viewPassword.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
    self.viewPassword.layer.borderWidth = 0.5
    txtPassword.applyStyle(textFont: UIFont.applyRegular(fontSize: 13.0), textColor: AppColor.text)
    txtPassword.textAlignment = .center
    txtPassword.tintColor = UIColor.black
    viewPassword.layer.cornerRadius  = 5.0
    
    //Apply Textfiled setup
    txtEmail.applyStyle(textFont: UIFont.applyRegular(fontSize: 12.0), textColor: AppColor.text)
    txtPassword.applyStyle(textFont: UIFont.applyRegular(fontSize: 12.0), textColor: AppColor.text)
    txtEmail.setAttributedPlaceHolder(placeHolderText: "email / username", color: AppColor.placeHolder)
    txtPassword.setAttributedPlaceHolder(placeHolderText: "password", color: AppColor.placeHolder)
    
  }
  
  func validateView() -> Dictionary<String,String>? {
    
    var message : Dictionary<String,String>? = nil
    
    if txtEmail.text == "" {
      message = [kError:"Login",kMessage:"Please enter a valid email or username to login"]
    } else if txtPassword.text == "" {
      message = [kError:"Login",kMessage:"Please enter password"]
    }
    
    return message
    
  }
  
//  func tapOnPrivacyPlocyLabel(_ gesture : UITapGestureRecognizer) {
//
//    //            let lbl: UILabel? = (gesture.view?.hitTest(gesture.location(in: gesture.view), with: nil) as? UILabel)
//
//    if let range = lblPrivacyPolicy.text?.range(of: "Privacy Policy") {
//      let startIndex = lblPrivacyPolicy.text?.distance(from: lblPrivacyPolicy.text!.startIndex, to: range.lowerBound)
//      let range1 = NSMakeRange(startIndex!, "Privacy Policy".characters.count)
//
//      let tapLocation = gesture.location(in: lblPrivacyPolicy)
//      let index = lblPrivacyPolicy.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
//
//      if index > range1.location && index < range1.location + range1.length {
//        //print("Privacy Policy")
//      }
//
//    }
//
//    if let range = lblPrivacyPolicy.text?.range(of: "Terms of Service") {
//      let startIndex = lblPrivacyPolicy.text?.distance(from: lblPrivacyPolicy.text!.startIndex, to: range.lowerBound)
//      let range1 = NSMakeRange(startIndex!, "Terms of Service".characters.count)
//
//      let tapLocation = gesture.location(in: lblPrivacyPolicy)
//      let index = lblPrivacyPolicy.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
//
//      if index > range1.location && index < range1.location + range1.length {
//        //print("Terms&condition")
//      }
//
//    }
//
//  }
  
  //------------------------------------------------------
  
  //MARK:- API Call
  
  func callLoginUserAPI(_ requestModel : RequestModel) {
    
    UserDefaults.standard.set(nil, forKey: kUserProfileBanner)
    UserDefaults.standard.set(nil, forKey: kUserProfileImage)
    
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
            
            //user token receive only in login/signup API only.
            //So require to save token after two these API
            userData.saveUserSessionInToDefaults()
            
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
                //fusuma.delegate = self
                fusuma.cropHeightRatio = 1.0
                fusuma.allowMultipleSelection = false
                fusumaSavesImage = true
                
                //self.present(fusuma, animated: true, completion: nil)
                //let chooseRackVc : ChooseRackVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseRackVC") as! ChooseRackVC
                //chooseRackVc.userData = UserModel(fromJson: response[kData])
                self.navigationController?.pushViewController(fusuma, animated: true)

                
//              let vc : ChooseRackVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseRackVC") as! ChooseRackVC
//              vc.userData = userData
//              self.navigationController?.pushViewController(vc, animated: true)
              
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
              GFunction.shared.userLogin(AppDelegate.shared.window)
              break
            default:
                
              break
            }
            break
          default :
            AlertManager.shared.showAlertTitle(title: "Login", message: response[kMessage].stringValue, buttonsArray: ["OK"], completionBlock: { (Int) in
              
            })
            
            break
          }
        } else {
          AlertManager.shared.showPopUpAlert("", message: error?.localizedDescription, forTime: 2.0, completionBlock: { (Int) in
          })
        }
    })
  }
  
  //------------------------------------------------------
  
  //MARK:- Action Method
  
  func leftButtonClicked()  {
    _ = self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func btnFBClicked(_ sender : UIButton) {
    
    //Google Analytics
    
    let category = "UI"
    let action = "Login with facebook button clicked"
    let lable = ""
    let screenName = "Login"
    googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
    
    //Google Analytics
    
    
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
                  
                  //                                    var fbAccessToken = FBSDKAccessToken.current().tokenString
                  //
                  //                                    //print("fbAccessToken \(fbAccessToken)")
                  
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
  
  @IBAction func btnLoginClicked(_ sender : UIButton) {
    
    let message = self.validateView()
    //Success Validation
    if (message == nil) {
      
      //Google Analytics
      
      let category = "UI"
      let action = "Login button clicked"
      let lable = ""
      let screenName = "Login"
      googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
      
      //Google Analytics
      
      //            GFunction.shared.userLogin(AppDelegate.shared.window!)
      self.view.endEditing(true)
        
      let requestModel : RequestModel = RequestModel()
      requestModel.usernm_email = txtEmail.text
      requestModel.password = txtPassword.text
      requestModel.login_type = "S"
      requestModel.device_type = "I"
      requestModel.device_token = GFunction.shared.getDeviceToken()
      self.callLoginUserAPI(requestModel)
      
        
      
    } else { // Error
      AlertManager.shared.showAlertTitle(title: message?[kError]! ,message: message?[kMessage]!)
    }
    
  }
  
  @IBAction func btnForgotPasswordClicked(_ sender : UIButton) {
    let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
    self.navigationController!.pushViewController(vc, animated: true)
  }
  
  @IBAction func btnShowClicked(_ sender : UIButton) {
    
    let isSecureEntry = txtPassword.isSecureTextEntry
    self.txtPassword.isSecureTextEntry = !self.txtPassword.isSecureTextEntry
    btnShow.setTitle(isSecureEntry ? "Hide" : "Show", for: .normal)
    
  }
  
  @IBAction func btnSignUpClicked(_ sender : UIButton) {
    let registerVC : RegisterVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
    self.navigationController?.pushViewController(registerVC, animated: true)
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
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
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
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if textField == txtEmail {
      IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 120.0
    }else {
      IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 79
    }
    return true
  }
  
  //------------------------------------------------------
  
  //MARK:- Life Cycle Method
  
  @IBOutlet weak var mainScrollView: UIScrollView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpView()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    GFunction.shared.removeUserDefaults(key: kLoginUserData)
    _ = addBarButtons(btnLeft: nil, btnRight: nil, title: "")
    self.navigationController?.isNavigationBarHidden = true
    
  }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = addBarButtons(btnLeft: nil, btnRight: nil, title: "")
        self.navigationController?.isNavigationBarHidden = true
    }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.isNavigationBarHidden = false
    if self.txtEmail != nil {
         self.txtEmail.resignFirstResponder()
    }
   if self.txtPassword != nil {
    self.txtPassword.resignFirstResponder()
    }
  }
  
 
  
  var scroll1 = false
  var scroll2 = true
  
  
}

extension LoginVC: UIScrollViewDelegate {
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    
    if scrollView == mainScrollView {
      return
    }
    
    if scrollView == self.scrollView1 {
      scroll1 = true
      scroll2 = false
    }else if scrollView == self.scrollView2 {
      scroll1 = false
      scroll2 = true
    }
    
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    if scrollView == mainScrollView {
      return
    }
    
    let width = scrollView.frame.size.width
    let page = (scrollView.contentOffset.x + (0.5 * width)) / width
    pageControl.currentPage = Int(page)
    
    if scroll1 {
      let factor = scrollView1.bounds.size.width /  scrollView2.bounds.size.width;
      let x = scrollView1.contentOffset.x
      var newContent = scrollView2.contentOffset
      newContent.x = x / factor
      scrollView2.contentOffset = newContent
    }else if scroll2 {
      let factor = scrollView1.bounds.size.width /  scrollView2.bounds.size.width;
      let x = scrollView2.contentOffset.x
      var newContent = scrollView1.contentOffset
      newContent.x = x * factor
      scrollView1.contentOffset = newContent
    }
  }
}
