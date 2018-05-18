//
//  SettingVC.swift
//  Rack
//
//  Created by hyperlink on 09/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import MessageUI
import Messages

var constCellSwitchKey: UInt8 = 0

let kID             : String = "id"
let kTitle          : String = "title"
let kSubTitle       : String = "subTitle"
let kIsPushAction   : String = "kIsPushAction"
let kAction         : String = "kAction"
let kCellType       : String = "kCellType"


class SettingVC: UIViewController {

    //Other Setup
    enum settingCellType {
        case normalCell
        case switchTypeCell
        case switchTypeWithOutSubtitleCell
    }
    
    enum cellAction {
        case privateProfile
        case editProfile
        case changePassword
        case blockedUser
        case myActivity
        case pushNotification
        
        case aboutUs
        case TermsCondition
        case privacyPolicy
        case Tutorials
        case feedback
    }
    
    typealias cellType = settingCellType
    typealias action   = cellAction
    
    //MARK:- Outlet
    
    @IBOutlet weak var tblSetting: UITableView!
    
    @IBOutlet var viewFooter: UIView!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var arraySectionData = ["Account", "Help"]
    var arrayDataSoruce : [Dictionary<String,Any>] = [
        [kTitle:"Make my profile private", kSubTitle:"", kCellType:cellType.switchTypeCell, kIsPushAction:false, kAction:action.privateProfile],
        [kTitle:"Edit Profile", kSubTitle:"", kCellType:cellType.normalCell, kIsPushAction:true, kAction:action.editProfile],
        [kTitle:"Change Password", kSubTitle:"", kCellType:cellType.normalCell, kIsPushAction:true, kAction:action.changePassword],
        [kTitle:"Blocked Users", kSubTitle:"", kCellType:cellType.normalCell, kIsPushAction:true, kAction:action.blockedUser],
        [kTitle:"My Activity", kSubTitle:"", kCellType:cellType.normalCell, kIsPushAction:true, kAction:action.myActivity],
        [kTitle:"Push Notifications", kSubTitle:"", kCellType:cellType.normalCell, kIsPushAction:true, kAction:action.pushNotification]
    ]
    
    var arrayDataSoruce2 : [Dictionary<String,Any>] = [
        [kTitle:"About Us", kSubTitle:"", kCellType:cellType.normalCell, kIsPushAction:true, kAction:action.aboutUs]
        ,[kTitle:"Terms and Conditions", kSubTitle:"", kCellType:cellType.normalCell, kIsPushAction:true, kAction:action.TermsCondition]
        ,[kTitle:"Privacy Policy", kSubTitle:"", kCellType:cellType.normalCell, kIsPushAction:true, kAction:action.privacyPolicy]
        ,[kTitle:"Feedback", kSubTitle:"", kCellType:cellType.switchTypeWithOutSubtitleCell, kIsPushAction:false, kAction:action.feedback]
    ]
    // Add after Privacy Policy
    //,[kTitle:"Tutorials", kSubTitle:"", kCellType:cellType.switchTypeWithOutSubtitleCell, kIsPushAction:false, kAction:action.Tutorials]

    let isShowRack = UserModel.currentUser.showRack
    
    //------------------------------------------------------
    
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("Here we go...")
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {

        //TabBarHidden:true
        self.tabBarController?.tabBar.isHidden = true
        
        //TODO: Manage Remove Change Password if user login with facebook Account
        if UserModel.currentUser.loginType.uppercased() == "F" {
            arrayDataSoruce = arrayDataSoruce.filter { ( dictAtIndex : [String : Any]) -> Bool in
                if (dictAtIndex[kTitle] as? String) == "Change Password" {
                    return false
                }
                return true
            }
        }

         self.navigationController?.customize()
    }
    
    func sendMail() {

        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["info@rackinternational.com.au"])
            composeVC.setSubject("Rack Feedback!")
            composeVC.setMessageBody("Rack App!", isHTML: false)
            present(composeVC, animated: true, completion:nil)
        }
        else {
            
            GFunction.shared.showPopup(with: "Email not configured", forTime: 2, withComplition: {
            }, andViewController: self)
        }
    }
    
    func shareApp() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionFB = UIAlertAction(title: "Facebook", style: .default) { (action : UIAlertAction) in
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                let mySLComposerSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                mySLComposerSheet?.setInitialText("Download Rack App today!\nDownload the Rack App now!")
                mySLComposerSheet?.add(URL(string: "https://itunes.apple.com/us/app/rack-ios/id1122994287?ls=1&mt=8"))
                
                mySLComposerSheet?.completionHandler = { (result:SLComposeViewControllerResult) -> Void in
                    switch result {
                    case SLComposeViewControllerResult.cancelled:
                        print("Post Canceled")
                        break
                        
                    case SLComposeViewControllerResult.done:
                        GFunction.shared.showPopup(with: "Shared successfully!", forTime: Int(2.0), withComplition: {
                        }, andViewController: self)
                        break
                    }
                }
                
                self.present(mySLComposerSheet!, animated: true, completion: nil)
            }
        }
        
        let actionEmail = UIAlertAction(title: "Email", style: .default) { (action : UIAlertAction) in

            if MFMailComposeViewController.canSendMail() {
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                // Configure the fields of the interface.
                composeVC.setToRecipients(["info@rackinternational.com.au"])
                composeVC.setSubject("Download Rack App today!")
                composeVC.setMessageBody("Download the Rack App now! https://itunes.apple.com/us/app/rack-ios/id1122994287?ls=1&mt=8", isHTML: false)
                self.present(composeVC, animated: true, completion: nil)
            }
            else {
                GFunction.shared.showPopup(with: "Email not configured", forTime: 2, withComplition: {
                }, andViewController: self)
            }
        }

        let actionSMS = UIAlertAction(title: "SMS", style: .default) { (action : UIAlertAction) in
            
            if MFMessageComposeViewController.canSendText() {
                let messageComposer = MFMessageComposeViewController()
                messageComposer.subject = "Download Rack App today!"
                let message: String = "Download the Rack App now! https://itunes.apple.com/us/app/rack-ios/id1122994287?ls=1&mt=8"
                messageComposer.body = message
                messageComposer.messageComposeDelegate = self
                self.present(messageComposer, animated: true, completion: { _ in })
            }
            else {
                GFunction.shared.showPopup(with: "SMS can not be send!", forTime: 2, withComplition: {
                }, andViewController: self)
            }

            
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
            
        }
        actionSheet.addAction(actionFB)
        actionSheet.addAction(actionEmail)
        actionSheet.addAction(actionSMS)
        actionSheet.addAction(actionCancel)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callLogoutAPI() {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/logout
         
         Parameter   :
         
         Optional    :
         
         Comment     : This api will used for user logout.
         
         
         ==============================
         
         */
        
        
        APICall.shared.GET(strURL: kMethodLogout
            , parameter: nil
            ,withLoader : true)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    GFunction.shared.userLogOut(AppDelegate.shared.window)
                    
                    //Google Analytics
                    
                    let category = "UI"
                    let action = "\(UserModel.currentUser.displayName!) logout his account"
                    let lable = ""
                    let screenName = "Settings-Logout"
                    googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                    
                    //Google Analytics

                    break
                default :
                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    break
                }
            }
            
        }
        
    }
    
    
    
    
    //MARK: - API Call
    
    func callDeactivateAcountAPI() {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/deactivate_account
         
         Parameter   :
         
         Optional    :
         
         Comment     : This api will used for user logout.
         
         
         ==============================
         
         */
       
        
        APICall.shared.PUT(strURL: kMethodDeactivate, parameter: nil) { (response, code, error) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                switch(status) {
                    case success:
                GFunction.shared.userLogOut(AppDelegate.shared.window)
                    //Google Analytics
                    let category = "UI"
                    let action = "\(UserModel.currentUser.displayName!) deactivated his account"
                    let lable = ""
                    let screenName = "Settings-Deactivate"
                    googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                    
                    //Google Analytics
                    
                    break
                default :
                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    break
                }
            }
        }
       
    }
    
    
    func callChangeAccountTypeAPI(requestModel : RequestModel, withCompletion block:@escaping (Bool,JSON?,String?) -> Void) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/profile_public
         
         Parameter   : public[public,private]
         
         Optional    :
         
         Comment     : This api will used for change the profile public or private.
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodProfilePublic
            , parameter: requestModel.toDictionary()
            , withErrorAlert : true
            )
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in

            if (error == nil) {
             
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    block(true, response[kData], response[kMessage].stringValue)

                    break
                default :
                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    block(false, nil, nil)
                    break
                }
            } else {

                block(false, nil, nil)
            }
            
            
        }
        
        
    }

    func callShowRackAPI(requestModel : RequestModel, withCompletion block:@escaping (Bool,JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : user/show_rack
         
         Parameter   : show_rack[yes,no]
         
         Optional    :
         
         Comment     : This api will used for user profile show the rack item or not.
         
         
         ==============================
         
         */
        
        APICall.shared.CancelTask(url: kMethodShowRack)
        
        APICall.shared.POST(strURL: kMethodShowRack
            , parameter: requestModel.toDictionary()
            , withErrorAlert : true
            )
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    block(true,response[kData])
                    
                    break
                default :
                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    block(false,nil)
                    break
                }
            } else {
                
                block(false,nil)
            }
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    func switchValueChanged(_ sender : UISwitch) {
    
        if let cell = objc_getAssociatedObject(sender, &constCellSwitchKey) as? SettingCell {

            if let indexPath = tblSetting.indexPath(for: cell) {
                
                let dictAtIndex = arrayDataSoruce[indexPath.row]
                let action = dictAtIndex[kAction] as! action
                
                switch action {
                case .privateProfile:
                    //Private Account

                    let requestModel = RequestModel()
                    requestModel.is_public = cell.btnSwitch.isOn ? profileType.kPrivate.rawValue : profileType.kPublic.rawValue
                    
                    cell.btnSwitch.isEnabled = false
                    self.callChangeAccountTypeAPI(requestModel: requestModel, withCompletion: { (isSuccess : Bool , jsonResponse : JSON?, message : String?) in

                        cell.btnSwitch.isEnabled = true

                        if isSuccess {

                            //Update status in current object
                            UserModel.currentUser.isPublic = jsonResponse!["is_public"].stringValue

                            //Override user object to update user status
                            UserModel.currentUser.saveUserDetailInDefaults()
                            
                            if message != nil {
                                GFunction.shared.showPopup(with: message!, forTime: 2, withComplition: {
                                }, andViewController: self)
                            }
                        }

                        //to rollback to actual status of user profile.
                        guard (cell.btnSwitch) != nil else {
                            return
                        }
                        cell.btnSwitch.setOn(UserModel.currentUser.isPrivateProfile(), animated: false)
                        
                        if !UserModel.currentUser.isPrivateProfile() {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserPrivacyPublic), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationProfileUpdate), object: nil)
                        }

                    })
                    
                    break

                default:
                    print("Default One called")
                    break
                }
            }
        }
    }
    
    @IBAction func btnDeactivatetClicked(_ sender : UIButton) {
        
        AlertManager.shared.showAlertTitle(title: "Deactivate", message: "Are you sure you want to deactivate your account?", buttonsArray: ["CANCEL","OK"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                //Cancel clicked
                break
            case 1:
                //Ok clicked
                self.callDeactivateAcountAPI()
                break
            default:
                break
            }
        }
    }
    @IBAction func btnLogOutClicked(_ sender : UIButton) {
        
        AlertManager.shared.showAlertTitle(title: "LOG OUT", message: "Are you sure you want to logout?", buttonsArray: ["CANCEL","OK"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                //Cancel clicked
                break
            case 1:
                //Ok clicked
                self.callLogoutAPI()

                break
            default:
                break
            }
            
        }
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppColor.primaryTheme
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = AppColor.primaryTheme
        //TODO:- Check whether to show onboarding or no
//        let requestModel = RequestModel()
//        requestModel.tutorial_type = tutorialFlag.Setting.rawValue
//        
//        GFunction.shared.getTutorialState(requestModel) { (isSuccess: Bool) in
//            if isSuccess {
//                let onBoarding = mainStoryBoard.instantiateViewController(withIdentifier: "OnboardingBaseVC") as! OnboardingBaseVC
//                onBoarding.tutorialType = .Setting
//                self.present(onBoarding, animated: false, completion: nil)
//            } else {
//                
//            }
//        }
         
        setUpView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "SETTINGS")
        
        
        //Google Analytics
        
        let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: self.title)
        
        //Google Analytics
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
        
    }
    
}

extension SettingVC : PSTableDelegateDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return arraySectionData.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderCell
        cell.lblName.text = arraySectionData[section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (30 * kHeightAspectRasio)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (50 * kHeightAspectRasio)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return arrayDataSoruce.count
        }else{
            return arrayDataSoruce2.count
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row < 6 {
            let dictAtIndex = arrayDataSoruce[indexPath.row] as Dictionary
            let cellType = dictAtIndex[kCellType] as! cellType
            
            switch cellType {
            case .switchTypeCell:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell3") as! SettingCell
                cell.lblTitle.text = dictAtIndex[kTitle] as? String

                cell.btnSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
                objc_setAssociatedObject(cell.btnSwitch, &constCellSwitchKey, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                cell.selectionStyle = .none

                //to manage profile type (public/private)
                cell.btnSwitch.setOn(UserModel.currentUser.isPrivateProfile(), animated: false)

                return cell

            default:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell2") as! SettingCell
                cell.lblTitle.text = dictAtIndex[kTitle] as? String
                
                if dictAtIndex[kIsPushAction] as! Bool == true {
                    cell.btnAction.isUserInteractionEnabled = false
                } else {
                    cell.btnAction.isUserInteractionEnabled = true
                }
                cell.selectionStyle = .none
                
                return cell
            }
            
        }else{
            
            let dictAtIndex = arrayDataSoruce2[indexPath.row] as Dictionary
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell2") as! SettingCell
            cell.lblTitle.text = dictAtIndex[kTitle] as? String
            
            if dictAtIndex[kIsPushAction] as! Bool == true {
                cell.btnAction.isUserInteractionEnabled = false
            } else {
                cell.btnAction.isUserInteractionEnabled = true
            }
            cell.selectionStyle = .none
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row < 6 {
            
            let dictAtIndex = arrayDataSoruce[indexPath.row]
            let action = dictAtIndex[kAction] as! action
            
            switch action {
            case .blockedUser:
                let blockVC = secondStoryBoard.instantiateViewController(withIdentifier: "BlockedUserVC") as! BlockedUserVC
                self.navigationController?.pushViewController(blockVC, animated: true)
                break
                
            case .myActivity:
                let myActivityVC = secondStoryBoard.instantiateViewController(withIdentifier: "MyActivityVC") as! MyActivityVC
                self.navigationController?.pushViewController(myActivityVC, animated: true)
                break
                
            case .changePassword:
                let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
                self.navigationController?.pushViewController(vc, animated: true)
                break
                
            case .editProfile:
                let vc = mainStoryBoard.instantiateViewController(withIdentifier: "CreateProfileVC") as! CreateProfileVC
                vc.fromPage = .fromSettingPage
                self.navigationController?.pushViewController(vc, animated: true)
                break
                
            case .pushNotification:
                let vc = mainStoryBoard.instantiateViewController(withIdentifier: "PushNotificationsVC") as! PushNotificationsVC
                self.navigationController?.pushViewController(vc, animated: true)
                break
                
            default:
                print("Default One Called...")
                break
            }
            
        }else{
            let dictAtIndex = arrayDataSoruce2[indexPath.row]
            let action = dictAtIndex[kAction] as! action
            
            switch action {
            case .feedback:
                self.sendMail()
                break
                
            case .aboutUs:
                let webViewVC = secondStoryBoard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                webViewVC.urlType = .about
                self.navigationController?.pushViewController(webViewVC, animated: true)
                break
                
            case .TermsCondition:
                let webViewVC = secondStoryBoard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                webViewVC.urlType = .termsAndCondition
                self.navigationController?.pushViewController(webViewVC, animated: true)
                break
                
            case .privacyPolicy:
                let webViewVC = secondStoryBoard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                webViewVC.urlType = .privacyPolicy
                self.navigationController?.pushViewController(webViewVC, animated: true)
                break
                
            case .Tutorials:
                let vc = mainStoryBoard.instantiateViewController(withIdentifier: "TutorialVC") as! TutorialVC
                vc.fromPage = .fromSettingPage
                self.navigationController?.pushViewController(vc, animated: true)
                break
                
            default:
                print("Default One Called...")
                break
            }
            
        }
        
    }

}

extension SettingVC : MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if result == .sent {
            GFunction.shared.alert(title: "", message: "Feedback sent!", cancelButton: "OK")
        }

        self.dismiss(animated: true, completion: nil)
    }
}
extension SettingVC : MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}


//------------------------------------------------------

//MARK: - Setting Cell -

class HeaderCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = AppColor.primaryTheme
        self.contentView.backgroundColor = AppColor.primaryTheme
    }
    
}

class SettingCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSwitch: UISwitch!
    @IBOutlet weak var btnAction: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      self.backgroundColor = AppColor.primaryTheme
      self.contentView.backgroundColor = AppColor.primaryTheme
    }
}

