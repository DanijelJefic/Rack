//
//  PeopleVC.swift
//  Rack
//
//  Created by hyperlink on 18/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class PeopleVC: UIViewController {

    //MARK:- Outlet
    
    @IBOutlet weak var tblPeople: UITableView!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var arrayMainData       : [FriendModel] = []
    var arrayOperational    : [FriendModel] = []
    
    var page                : Int = 1
    var searchText          : String = ""
    
    var delegate            : SearchTextDelegate?
    //------------------------------------------------------
    
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(kNotificationUserDetailsUpdate)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        self.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
   
     self.navigationController?.customize()
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Notification Method
    
    func notificationUserDetailsUpdate(_ notification : Notification) {
        
        guard let _  = tblPeople else {
            return
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblPeople.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callSearchAPI(withFiltering isMainData : Bool) {
        
        /*
         ===========API CALL===========
         
         Method Name : user/search
         
         Parameter   : search_flag[discover,people,hashtag,brand,item]
         
         Optional    : search_value,page
         
         Comment     :
         
         
         ==============================
         
         */
        
        let requestModel = RequestModel()
        requestModel.search_flag = searchFlag.people.rawValue
        requestModel.search_value = searchText
        
        APICall.shared.POST(strURL: kMethodSearch
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    if isMainData {
                        self.arrayMainData = FriendModel.modelsFromDictionaryArray(array: response[kData].arrayValue)
                        self.arrayOperational = self.arrayMainData
                    } else {
                        self.arrayOperational = FriendModel.modelsFromDictionaryArray(array: response[kData].arrayValue)
                    }
                    self.tblPeople.reloadData()
                    
                    break
                default :
                    //print(response[kMessage].stringValue)
                    break
                }
            }
            
        }
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = AppColor.primaryTheme
      self.tblPeople.backgroundColor = AppColor.primaryTheme

        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.parent?.parent is SearchVC {
            searchText = (self.parent?.parent as! SearchVC).searchBar.text!
        }
        
        if searchText == "" {
            arrayOperational = FriendModel().getUserDetailFromDefaults()
            tblPeople.reloadData()
        } else {
            self.callSearchAPI(withFiltering: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }

}
extension PeopleVC : PSTableDelegateDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOperational.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let objAtIndex = arrayOperational[indexPath.row] as FriendModel
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
        cell.selectionStyle = .none
        cell.lblUserName.text = objAtIndex.getUserName()
        cell.lblDisplayName.text = objAtIndex.displayName
        cell.imgProfile.setImageWithDownload(objAtIndex.getUserProfile().url())
        
        //user verify or not
        if objAtIndex.isUserVerify() {
            cell.imgVerify.isHidden = false
        } else {
            cell.imgVerify.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60*kHeightAspectRasio
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if arrayOperational.isEmpty {
            return
        }
                
        if self.parent?.parent is SearchVC {
            (self.parent?.parent as! SearchVC).searchBar.resignFirstResponder()
        }
        
        let objAtIndex = arrayOperational[indexPath.row]
        
        objAtIndex.saveUserDetailInDefaults()
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.viewType = .other
        vc.fromPage = .otherPage
        vc.userData = UserModel(fromJson: JSON(objAtIndex.toDictionary()))
        vc.userData?.userId = objAtIndex.id
        vc.userData?.userName = objAtIndex.getUserName().uppercased()
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension PeopleVC : SearchTextDelegate {
    
    func searchTextDelegateMethod(_ searchBar: UISearchBar) {
        
        searchText = searchBar.text!
        
        if searchText == "" {
            arrayOperational = FriendModel().getUserDetailFromDefaults()
        } else {
            let predict = NSPredicate(format: "userName CONTAINS[cd] %@ OR userName LIKE[cd] %@",searchText, searchText)
            
            arrayOperational = arrayMainData.filter { predict.evaluate(with: $0) }
            
            self.callSearchAPI(withFiltering: false)
            
        }
        tblPeople.reloadData()
    }
}
