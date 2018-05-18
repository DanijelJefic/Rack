//
//  ChangePasswordVC.swift
//  Rack
//
//  Created by hyperlink on 10/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {

    //MARK:- Outlet
    
    @IBOutlet weak var txtCurrentPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnUpdatePassword: UIButton!

    @IBOutlet weak var textContainer : CustomTextContainer!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    
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
        
        //Apply Textfiled setup
        txtCurrentPassword.applyStyle(textFont: UIFont.applyRegular(fontSize: 12.0), textColor: AppColor.text)
        txtNewPassword.applyStyle(textFont: UIFont.applyRegular(fontSize: 12.0), textColor: AppColor.text)
        txtConfirmPassword.applyStyle(textFont: UIFont.applyRegular(fontSize: 12.0), textColor: AppColor.text)
        
        txtCurrentPassword.setAttributedPlaceHolder(placeHolderText: "Current Password", color: AppColor.placeHolder)
        txtNewPassword.setAttributedPlaceHolder(placeHolderText: "New Password", color: AppColor.placeHolder)
        txtConfirmPassword.setAttributedPlaceHolder(placeHolderText: "Confirm Password", color: AppColor.placeHolder)
        
        btnUpdatePassword.applyStyle(
            titleLabelFont: UIFont.applyBold(fontSize: 13.0)
            , titleLabelColor: AppColor.text
            , borderColor: AppColor.secondaryTheme
        )
        
         self.navigationController?.customize()

    }
    
    func validateView() -> Dictionary<String,String>? {
        
        var message : Dictionary<String,String>? = nil
        
        if txtCurrentPassword.text == "" {
            message = [kError:"Oops!",kMessage:"Please enter current password"]
        } else if txtNewPassword.text == "" {
            message = [kError:"Oops!",kMessage:"Please enter new password"]
        } else if txtNewPassword.text!.characters.count < 6 {
            message = [kError:"Password length!",kMessage:"New password must contain at least 6 characters"]
        } else if txtConfirmPassword.text == "" {
            message = [kError:"Oops!",kMessage:"Please enter confirm password"]
        } else if txtNewPassword.text != txtConfirmPassword.text {
            message = [kError:"Password mismatch!",kMessage:"New Password and confirm password not matched"]
        }
        
        return message
        
    }
    
    
    //------------------------------------------------------
    
    //MARK: API Call
    
    func callChangePassWordAPI(_ requestModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : user/changepassword
         
         Parameter   : old_password,new_password
         
         Optional    :
         
         Comment     : This api will used for change the user password.
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodChangePassword
            , parameter: requestModel.toDictionary()
            , withLoader: true
            , withBlock: { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
                
                if (error == nil) {
                    let response = JSON(response ?? [:])
                    let status = response[kCode].stringValue
                    
                    switch(status) {
                        
                    case success:
                        
//                        _ = self.navigationController?.popViewController(animated: true)
//                        GFunction.shared.showPopUpAlert(response[kMessage].stringValue, forTime: 2, completionBlock: { (time:Int) in
//                        })
                        
                        AlertManager.shared.showAlertTitle(title: "Success", message: response[kMessage].stringValue, buttonsArray: ["Ok"]) { (buttonIndex : Int) in
                            switch buttonIndex {
                            case 0 :
                                _ = self.navigationController?.popViewController(animated: true)
                                break
                            default :
                                break
                            }
                        }
                        
                        break
                    default :
                        GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                        break
                    }
                    
                    
                }
        })
        
    }


    //------------------------------------------------------
    
    //MARK:- Action Method
    
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnUpdatePasswordClicked(_ sender: UIButton) {

        let message = self.validateView()
        
        //Success Validation
        if (message == nil) {
            
            self.view.endEditing(true)

            let requestModel = RequestModel()
            requestModel.old_password = txtCurrentPassword.text
            requestModel.new_password = txtNewPassword.text
            
            self.callChangePassWordAPI(requestModel)

            
        } else { // Error
            
            AlertManager.shared.showAlertTitle(title: message?[kError]! ,message: message?[kMessage]!)
            
        }


    }
    
    //MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        _ = text.characters.count + string.characters.count - range.length

        if range.location == 0 && string == " " {
            return false
        }

        return true
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTextFiled = textContainer.viewWithTag(textField.tag + 1)
        if textField.isEqual(txtConfirmPassword) {
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
      
      self.view.backgroundColor = AppColor.primaryTheme
      setUpView()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "CHANGE PASSWORD")
        
        
        //Google Analytics
        
        let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: self.title)
        
        //Google Analytics
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }


}
