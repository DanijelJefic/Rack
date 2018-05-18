
//
//  FolderVC.swift
//  Rack
//
//  Created by GS Bit Labs on 3/13/18.
//  Copyright © 2018 Hyperlink. All rights reserved.
//

import UIKit

class FoldersListVC: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnCreateRackOutlet: UIButton!
    
    var searchActive        : Bool = false
    var filtered            : [folderStructure] = []
    var arrayItemData       : [folderStructure] = []
    var dictFromParent      : ItemModel = ItemModel()
    var page                : Int = 1
    var _imgPost = UIImage()
    var btnWantSelected     : Bool = Bool()
    let activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView()
    var headerCell          : SelectRackHeaderCell? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: nil, title: "Select Rack")
        filtered = self.arrayItemData
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.setUpData()
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: nil, title: "Select Rack")        
    }
    func leftButtonClicked() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func setUpData() {
        
        self.activityIndicatorView.frame = self.view.bounds
        self.activityIndicatorView.activityIndicatorViewStyle = .gray
        self.view.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        
        self.page = 1
        let requestModel = RequestModel()
        requestModel.user_id = UserModel.currentUser.userId
        requestModel.page = String(format: "%d", (self.page))
        
        self.callRackListAPI(requestModel, withCompletion: { (isSuccess) in
            if isSuccess {
                self.filtered = self.arrayItemData
            }
            self.tblView.reloadData()
        })
        
    }
    
    func callRackListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/racklist
         
         Parameter   : user_id
         
         Optional    : page
         
         Comment     : This api will used for fetch User Racks
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodRackList
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            self.activityIndicatorView.stopAnimating()
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    if self.page == 1{
                        self.arrayItemData.removeAll()
                    }
                    
                    let newData = (folderStructure.modelsFromDictionaryArray(array: response[kData].arrayValue))
                    self.arrayItemData.append(contentsOf: newData)
                    self.page = (self.page) + 1
                    block(true)
                    break
                    
                default:
                    
                    //stop pagination
                    if self.page == 1{
                        self.arrayItemData.removeAll()
                    }
                    
                    block(false)
                    
                    break
                }
            } else {
                
                block(false)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    @IBAction func btnCreateNewRack(_ sender: AnyObject) {
        let createNewRackVC:CreateNewRackVC = storyboard?.instantiateViewController(withIdentifier: "CreateNewRackVC") as! CreateNewRackVC
        createNewRackVC.image = self._imgPost
        createNewRackVC.isPresent = true
        createNewRackVC.newRackAdded = {(text) in
            
            let firstData = folderStructure.modelsFromLocalDictionary(rackname: text, image: self._imgPost )
            self.arrayItemData.append(contentsOf: firstData)
            
            self.filtered = self.arrayItemData
            self.tblView.reloadData()
        }
        
        self.navigationController?.pushViewController(createNewRackVC, animated: true)
        
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    func callWantAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : item/itemwant
         
         Parameter   : item_id, 
         
         Optional    :
         
         Comment     : This api will used for user to save particular item to want list.
         
         ==============================
         */
        
        APICall.shared.GET(strURL: kMethodWantList
            , parameter: requestModel.toDictionary()
            ,withLoader : true)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    block(true,response[kData])
                    break
                    
                default:
                    
                    block(false,nil)
                    break
                }
            } else {
                block(false,nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension FoldersListVC: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 83.0 * kHeightAspectRasio
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! SelectRackHeaderCell
        headerCell.barSearch.delegate = self
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96 * kHeightAspectRasio
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as! SelectRackListCell
        
        let objAtIndex = filtered[indexPath.row]
        cell.folderName.text = objAtIndex.name
        
        if objAtIndex.rackId.isEmpty {
            cell.imgView.image = objAtIndex.localImage
        }else{
            cell.imgView.setImageWithDownload(objAtIndex.image.url())
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let requestModel = RequestModel()
        requestModel.item_id = dictFromParent.itemId
        let rackName = filtered[indexPath.row].name
        requestModel.folderName = rackName
        requestModel.type = btnWantSelected ? StatusType.want.rawValue : StatusType.unwant.rawValue
        
        self.callWantAPI(requestModel,
                         withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                            
                            if isSuccess {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationProfileUpdate), object: nil)
                                self.dictFromParent.loginUserWant = true
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.dictFromParent)
//                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNewPostAdded), object: self.dictFromParent)

                                DispatchQueue.main.async {
                                    if let rack = rackName {
                                        AlertManager.shared.showPopUpAlert("", message: "Saved to \(rack)", forTime: 2.0, completionBlock: { (Int) in
                                            self.navigationController?.dismiss(animated: true, completion: nil)
                                        })
                                    }
                                    
                                }
                                
                            } else {
                                
                            }
                            
        })
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tblView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tblView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.filtered = searchText.isEmpty ? self.arrayItemData : self.arrayItemData.filter({(obj: folderStructure) -> Bool in
            let tmp: NSString = obj.name! as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        //print(filtered)
        
        self.tblView.reloadData()
        searchBar.becomeFirstResponder()
        
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
}
