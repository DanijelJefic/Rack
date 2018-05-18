//
//  ForgotPasswordVC.swift
//  Rack
//
//  Created by hyperlink on 29/04/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController,UITextFieldDelegate {

    //MARK:- Outlet
    
    @IBOutlet weak var lblInstruction: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnSendMail: UIButton!
    
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
        btnSendMail.applyStyle(
            titleLabelFont : UIFont.applyRegular(fontSize: 12.0)
            , titleLabelColor : AppColor.text
          ,borderColor : AppColor.text, borderWidth: 0.0
        )
        btnSendMail.setTitle("Send Email", for: .normal)
        btnSendMail.layer.cornerRadius = 5.0
        btnSendMail.titleLabel?.font = UIFont.applyRegular(fontSize: 13.0)
        btnSendMail.setTitleColor(UIColor(red:161.0/255.0, green:159.0/255.0,blue:159.0/255.0,alpha:1.0), for: .normal)
         btnSendMail.setTitleColor(UIColor.white, for: .highlighted)
        btnSendMail.backgroundColor = UIColor(red:37.0/255.0, green:37.0/255.0,blue:37.0/255.0,alpha:1.0)
        
        txtEmail.applyStyle(textFont: UIFont.applyRegular(fontSize: 13.0), textColor: AppColor.text)
        txtEmail.frame.size.height = 36.0
        txtEmail.textAlignment = .center
        txtEmail.layer.cornerRadius  = 5.0
        txtEmail.setAttributedPlaceHolder(placeHolderText: "Enter email", color: AppColor.placeHolder)

        //Other font setUp
        lblInstruction.applyStyle(
            labelFont: UIFont.applyRegular(fontSize: 11.5)
            , labelColor: AppColor.text
        )
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage         = UIImage()
         //self.navigationController?.customize()
    }
    
    func validateView() -> Dictionary<String,String>? {
        
        var message : Dictionary<String,String>? = nil
        
        if txtEmail.text == "" {
            message = [kError:"Email required!",kMessage:"Please enter email"]
        } else if !txtEmail.text!.isValidEmail() {
            message = [kError:"Valid email required!",kMessage:"Please enter valid email"]
        }
        
        return message
        
    }
    
    //------------------------------------------------------
    
    //MARK:- API Call
    
    func callForgotPassWordAPI() {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/forgotpassword
         
         Parameter   : Email
         
         Optional    :
         
         Comment     : This api will used for forgot password.
         
         
         ==============================
         
         */
        
        let requestModel = RequestModel()
        requestModel.email = txtEmail.text
        
        APICall.shared.POST(strURL: kMethodForgotPassword
            , parameter: requestModel.toDictionary()
            , withLoader: true
            , withBlock: { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
                
                if (error == nil) {
                    let response = JSON(response ?? [:])
                    let status = response[kCode].stringValue
                    
                    switch(status) {
                        
                    case success:
                        
                        AlertManager.shared.showPopUpAlert("Password Recovery", message: response[kMessage].stringValue, forTime: 3.0, completionBlock: { (Int) in
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                        
                        break
                    default :
                        
                        AlertManager.shared.showPopUpAlert("Password Recovery", message: response[kMessage].stringValue, forTime: 3.0, completionBlock: { (Int) in
                            _ = self.navigationController?.popViewController(animated: true)
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

    @IBAction func btnSendClicked(_ sender: UIButton) {

        let message = self.validateView()
        
        //Success Validation
        if (message == nil) {
            
            self.callForgotPassWordAPI()
            
        } else { // Error
            AlertManager.shared.showAlertTitle(title: message?[kError]!, message: message?[kMessage]!)
        }
    }

    //------------------------------------------------------
    
    //MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        
        if range.location == 0 && string == " " {
            return false
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
        if textField.isEqual(txtEmail) {
            self.view.endEditing(true)
        } else {
            nextTextFiled?.becomeFirstResponder()
        }
        
        return true
    }

    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.title = "FORGOT PASSWORD"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = AppColor.primaryTheme
        setUpView()
      self.navigationController?.navigationBar.tintColor = UIColor.black
      self.navigationController?.navigationBar.barTintColor = UIColor.white
      
      let barButton = UIBarButtonItem(title: "Backdd", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
      barButton.tintColor = UIColor.black
      self.navigationItem.leftBarButtonItems = [barButton]
        
        self.txtEmail.layer.cornerRadius = 5.0;
        self.txtEmail.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.txtEmail.layer.borderWidth = 0.5
        
        let leftView = UIView()
        leftView.frame = CGRect(x:0,y:0,width:20.0,height:self.txtEmail.frame.size.height)
        self.txtEmail.leftView = leftView
        self.txtEmail.leftViewMode = .always
        self.txtEmail.tintColor = UIColor.black

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      _ = addBarButtons(btnLeft: BarButton(title: "Back", color: UIColor.black), btnRight: nil, title: "FORGOT PASSWORD")
        self.title = "FORGOT PASSWORD"

        //Google Analytics
        
       // let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        //googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: self.title)
        
        //Google Analytics
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "FORGOT PASSWORD"
        _ = addBarButtons(btnLeft: BarButton(title: "Back", color: UIColor.black), btnRight: nil, title: "FORGOT PASSWORD")

    }


}
