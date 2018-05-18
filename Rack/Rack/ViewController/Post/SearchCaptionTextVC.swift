//
//  SearchTagTextVC.swift
//  Rack
//
//  Created by hyperlink on 29/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit



class SearchCaptionTextVC: UIViewController {

    //MARK:- Outlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblSearch: UITableView!

    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var lblSearchText: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var constTopHeight: NSLayoutConstraint!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var imageTagType : TagType = TagType.none
    var tapLocation  : CGPoint  = CGPoint()
    var delegate     : SearchCaptionDelegate?
    
    var arrayOperational : [SearchText] = []

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


        self.navigationItem.hidesBackButton = true
        self.navigationItem.titleView = searchBar

        //search
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.delegate = self
        searchBar.tintColor = UIColor.colorFromHex(hex: kColorGray74)

        constTopHeight.constant = 0
        btnNext.isHidden = true
        lblSearchText.applyStyle(labelFont: UIFont.applyRegular(fontSize: 12.0), labelColor: AppColor.text)
        
        
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

                    self.arrayOperational = SearchText.modelsFromDictionaryArray(array: response[kData].arrayValue)
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
    
    @IBAction func btnNextClicked(_ sender: UIButton) {

        searchBar.resignFirstResponder()
        if self.delegate != nil {
            self.delegate?.searchCaptionDelegateMethod([kID : "",kTitle : lblSearchText.text!],tagType: nil)
        }
            _ = self.navigationController?.popViewController(animated: true)
    }
    

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
extension SearchCaptionTextVC : UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //print(searchText)
        lblSearchText.text = searchText
        
        if searchText == "" {
            constTopHeight.constant = 0
            btnNext.isHidden = true
            UIView.animate(withDuration: 0.3, animations: { 
                self.view.layoutIfNeeded()
            })
        } else {
            constTopHeight.constant = 45
            btnNext.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
        //call API
        let requestModel = RequestModel()

        requestModel.search_value = searchBar.text

        switch imageTagType {
        case .tagBrand:
            requestModel.search_flag = searchFlag.brand.rawValue
            self.callSearchAPI(requestModel: requestModel)
            break
        case .tagItem:
            requestModel.search_flag = searchFlag.item.rawValue
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
        
        
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
}

    //MARK:- TableView Datasource Delegate -
extension SearchCaptionTextVC : PSTableDelegateDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOperational.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40*kHeightAspectRasio
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headeView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 1.0))
        let lineView : UIView = UIView(frame: CGRect(x: 0, y: -1 ,width: kScreenWidth, height: 1.0))
        lineView.backgroundColor = AppColor.secondaryTheme
        headeView.addSubview(lineView)
        return headeView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let objectAtIndex = arrayOperational[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrandCell") as! BrandCell
        cell.selectionStyle = .none
        cell.lblText.text = objectAtIndex.name
        
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchBar.resignFirstResponder()
        let objectAtIndex = arrayOperational[indexPath.row]

        if self.delegate != nil {
            self.delegate?.searchCaptionDelegateMethod([kID : objectAtIndex.id,kTitle : objectAtIndex.name],tagType: nil)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
}
