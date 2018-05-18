//
//  SearchPeopleTagVC.swift
//  Rack
//
//  Created by hyperlink on 30/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class SearchPeopleTagVC: UIViewController {

    //MARK:- Outlet
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblSearch: UITableView!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var imageTagType : TagType = TagType.none
    var tapLocation  : CGPoint  = CGPoint()
    var delegate     : SearchTagDelegate?

    var arrayOperational : [FriendModel] = []
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
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.titleView = searchBar
        
        //search
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.delegate = self
        searchBar.tintColor = UIColor.colorFromHex(hex: kColorGray74)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
         self.navigationController?.customize()
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Notification Method
    
    func notificationUserDetailsUpdate(_ notification : Notification) {
        
        guard let _  = tblSearch else {
            return
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblSearch.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callSearchAPI(requestModel : RequestModel) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/search
         
         Parameter   : search_flag[discover,people,hashtag,brand,item]
         
         Optional    : search_value,page
         
         Comment     :
         
         
         ==============================
         
         */

        
        APICall.shared.POST(strURL: kMethodSearch
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            GFunction.shared.removeActivityIndicator()
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:

                    self.arrayOperational = FriendModel.modelsFromDictionaryArray(array: response[kData].arrayValue)
                    self.tblSearch.reloadData()
                    
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
      self.tblSearch.backgroundColor = AppColor.primaryTheme
      self.navigationController?.navigationBar.isTranslucent = false
      
      setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
        AppDelegate.shared.isSwipeBack = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.shared.isSwipeBack = false
    }
    
}

//MARK:- SearchBar Delegate -
extension SearchPeopleTagVC : UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let requestModel = RequestModel()
        
        requestModel.search_value = searchBar.text
        
        switch imageTagType {
        case .tagPeople:
            requestModel.search_flag = searchFlag.people.rawValue
            self.callSearchAPI(requestModel: requestModel)
            break
        default:
            print("Default One called...")
        }

    }
    
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.text = ""
        self.navigationController!.popViewController(animated: true
        )
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
}
    //MARK:- TableView Datasource Delegate -
extension SearchPeopleTagVC : PSTableDelegateDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOperational.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60*kHeightAspectRasio
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let objAtIndex = arrayOperational[indexPath.row] as FriendModel

        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
        cell.selectionStyle = .none
        cell.lblUserName.text = objAtIndex.getUserName()
        cell.lblDisplayName.text = objAtIndex.displayName
        
        
        
        cell.imgProfile.setImageWithDownload(objAtIndex.getUserProfile().url())
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        searchBar.resignFirstResponder()

        let objectAtIndex = arrayOperational[indexPath.row]
        if self.delegate != nil {
            self.delegate?.searchTagDelegateMethod([kID : objectAtIndex.id,kTitle : objectAtIndex.getUserName(),"tapLocation" : tapLocation],tagType: nil)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }

    
}

