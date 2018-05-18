//
//  AboutInfoVC.swift
//  Rack
//
//  Created by hyperlink on 09/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class AboutInfoVC: UIViewController {

    enum cellAction {
        case termsAndConditions
        case privacyPolicy
        case about
        case tutorial
    }
    
    typealias action   = cellAction
    
    //MARK:- Outlet
    
    @IBOutlet weak var tblAbout: UITableView!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    let arrayDataSoruce : [Dictionary<String,Any>] = [
        [kTitle:"TERMS & CONDITIONS",kAction:action.termsAndConditions]
        ,[kTitle:"PRIVACY POLICY",kAction:action.privacyPolicy]
        ,[kTitle:"ABOUT",kAction:action.about]
        ,[kTitle:"TUTORIALS",kAction:action.tutorial]
    ]

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
        tblAbout.tableFooterView = UIView()
        
         self.navigationController?.customize()
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = AppColor.primaryTheme
      tblAbout.backgroundColor = AppColor.primaryTheme
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "ABOUT INFO")
        
        //Google Analytics

        let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: self.title)

        //Google Analytics
    }
    
    override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
        
    }
}


extension AboutInfoVC : PSTableDelegateDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDataSoruce.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return (50 * kHeightAspectRasio)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dictAtIndex = arrayDataSoruce[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutInfoCell") as! AboutInfoCell
        cell.lblInfo.text = dictAtIndex[kTitle] as? String
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let dictAtIndex = arrayDataSoruce[indexPath.row]
        let action = dictAtIndex[kAction] as! cellAction
        

        
        switch action {
        case .termsAndConditions:
            let webViewVC = secondStoryBoard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            webViewVC.urlType = .termsAndCondition
            self.navigationController?.pushViewController(webViewVC, animated: true)
            break
        case .privacyPolicy:
            let webViewVC = secondStoryBoard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            webViewVC.urlType = .privacyPolicy
            self.navigationController?.pushViewController(webViewVC, animated: true)
            break
        case .about:
            let webViewVC = secondStoryBoard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            webViewVC.urlType = .about
            self.navigationController?.pushViewController(webViewVC, animated: true)
            break
        case .tutorial:
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "TutorialVC") as! TutorialVC
            vc.fromPage = .fromSettingPage
            self.navigationController?.pushViewController(vc, animated: true)
            break
        }
    }
}


//MARK: - AboutInfoCell -
class AboutInfoCell: UITableViewCell {
    
    @IBOutlet weak var lblInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      self.backgroundColor = AppColor.primaryTheme
      self.contentView.backgroundColor = AppColor.primaryTheme

        lblInfo.applyStyle(labelFont: UIFont.applyBold(fontSize: 13.0), labelColor: AppColor.text)

    }
}
