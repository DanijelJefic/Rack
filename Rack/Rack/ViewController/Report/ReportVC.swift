//
//  ReportVC.swift
//  Rack
//
//  Created by hyperlink on 26/08/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class ReportVC: UIViewController {
    
    //MARK:- Outlet
    
    @IBOutlet weak var tblReport: UITableView!
    @IBOutlet weak var vwHeader: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    
    var arrayData =
        ["Abusive Language",
         "Inappropriate Content",
         "Harassment or bullying",
         "I just don`t like it"
    ]
    
    var reportType : ReportType = .item
    var reportId : String = ""
    var offenderId : String = ""
    var reason : String = ""
    
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
        lblTitle.applyStyle(labelFont: UIFont.applyBold(fontSize: 13.0), labelColor: AppColor.text)
   
     self.navigationController?.customize()
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callRequestReportAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/report
         
         Parameter   : offender_id(user_id of (profile,item,comment)),report_id (id of (profile,item,comment)),report_type(profile,item,comment),reason
         
         Optional    :
         
         Comment     : This api will used for user report the (item , profile and comment).
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodRequestReport
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    block(true,response[kMessage])
                    break
                    
                default:
                    
                    block(false,nil)
                    break
                }
            } else {
                AlertManager.shared.showPopUpAlert("", message: error?.localizedDescription, forTime: 2.0, completionBlock: { (Int) in
                })
                block(false,nil)
            }
        }
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func rightButtonClicked() {
        
        if reason != "" {
        
            let requestModel = RequestModel()
            requestModel.report_id = reportId
            requestModel.report_type = reportType.rawValue
            requestModel.offender_id = offenderId
            requestModel.reason = reason
            
            self.callRequestReportAPI(requestModel) { (isSuccess : Bool, jsonResponse : JSON?) in
                if isSuccess {
                    AlertManager.shared.showAlertTitle(title: "Thanks", message: jsonResponse!.stringValue, buttonsArray: ["OK"], completionBlock: { (Int) in
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        } else {
            AlertManager.shared.showAlertTitle(title: "Reason Needed", message: "Please select a reason for reporting.", buttonsArray: ["OK"], completionBlock: { (Int) in
                
            })
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = addBarButtons(btnLeft: BarButton(title : "Cancel"), btnRight: BarButton(title : "Submit"), title: "REPORT")
        
        //Google Analytics
        
        let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: self.title)
        
        //Google Analytics
    }
    
}

extension ReportVC : PSTableDelegateDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let objAtIndex = arrayData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell") as! ReportCell
        cell.selectionStyle = .none
        cell.lblText.text = objAtIndex.uppercased()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40*kHeightAspectRasio
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        reason = arrayData[indexPath.row].uppercased()
        tableView.cellForRow(at: indexPath)?.isSelected = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
}

//MARK: - ReportCell -

class ReportCell: UITableViewCell {
    
    @IBOutlet var lblText : UILabel!
    @IBOutlet var imgLine : UIImageView!
    
    override var isSelected: Bool {
        didSet {
            imgLine.backgroundColor = isSelected ? AppColor.secondaryTheme : UIColor.clear
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblText.applyStyle(labelFont: UIFont.applyRegular(fontSize: 13.0), labelColor: UIColor.colorFromHex(hex: kColorGray74))
    }
    
}
