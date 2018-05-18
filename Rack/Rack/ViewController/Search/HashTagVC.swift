//
//  HashTagVC.swift
//  Rack
//
//  Created by hyperlink on 19/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class HashTagVC: BaseViewController {

    //MARK:- Outlet
    
    @IBOutlet weak var tblHash: UITableView!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var delegate : SearchTextDelegate?
    
    var arrayOperational    : [SearchText] = []
    
    var page                : Int = 1
    var searchText          : String = ""
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
        self.delegate = self
        
//        self.callSearchAPI()
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callSearchAPI() {
        
        /*
         ===========API CALL===========
         
         Method Name : user/search
         
         Parameter   : search_flag[discover,people,hashtag,brand,item]
         
         Optional    : search_value,page
         
         Comment     :
         
         
         ==============================
         
         */
        
        let requestModel = RequestModel()
        requestModel.search_flag = searchFlag.hashtag.rawValue
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
                    
                    self.arrayOperational = SearchText.modelsFromDictionaryArray(array: response[kData].arrayValue)
                    self.tblHash.reloadData()
                    
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
      self.tblHash.backgroundColor = AppColor.primaryTheme

        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.parent?.parent is SearchVC {
            searchText = (self.parent?.parent as! SearchVC).searchBar.text!
        }
        
        if searchText == "" {
            arrayOperational = SearchText().getUserDetailFromDefaults(key: kHashSearchData)
            tblHash.reloadData()
        } else {
            self.callSearchAPI()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
}
extension HashTagVC : PSTableDelegateDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOperational.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let arrayAtIndex = arrayOperational[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrandCell") as! BrandCell
        cell.selectionStyle = .none
        cell.lblText.text = arrayAtIndex.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40*kHeightAspectRasio
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if arrayOperational.isEmpty {
            return
        }
        
        if self.parent?.parent is SearchVC {
            (self.parent?.parent as! SearchVC).searchBar.resignFirstResponder()
        }
        
        let objAtIndex = arrayOperational[indexPath.row]
        
        objAtIndex.saveUserDetailInDefaults(key: kHashSearchData)
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchDetailVC") as! SearchDetailVC
        vc.searchFlagType = searchFlagType.hashtag.rawValue
        vc.searchData = objAtIndex
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HashTagVC : SearchTextDelegate {
    
    func searchTextDelegateMethod(_ searchBar: UISearchBar) {
        //print(" HashTagVC :- \(searchBar.text!)")
        
        searchText = searchBar.text!
        
        if searchText == "" {
            arrayOperational = SearchText().getUserDetailFromDefaults(key: kHashSearchData)
        } else {
            self.callSearchAPI()
        }
        tblHash.reloadData()
    }
    
}
