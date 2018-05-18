//
//  BrandVC.swift
//  Rack
//
//  Created by hyperlink on 18/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit


class BrandVC: BaseViewController {

    //MARK:- Outlet
    
    @IBOutlet weak var tblBrand: UITableView!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var delegate : SearchTextDelegate?
    
    var arrayOperational    : [SearchText] = []
//    var arrayOperational    : [[SearchText]] = []
    
    var page                : Int = 1
    var searchText          : String = ""
    var isWSCalling         : Bool = true
    
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
        
        self.tblBrand.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            scrollView?.ins_endInfinityScroll(withStoppingContentOffset: true)
            if self.isWSCalling {
                self.isWSCalling = false
                self.callSearchAPI()
            }
        }
        
        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.tblBrand.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
        infinityIndicator.startAnimating()
        
//        self.tblBrand.ins_beginInfinityScroll()
        
        arrayOperational.removeAll()
        tblBrand.reloadData()
        self.page = 1
        self.callSearchAPI()
    self.navigationController?.customize()
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
        requestModel.search_flag = searchFlag.brand.rawValue
        requestModel.search_value = searchText
        
        if searchText.characters.count > 0 {
            self.page = 1
        }
        
        requestModel.page = "\(self.page)"
        
        //print("page ====== \(self.page)")
        
        APICall.shared.POST(strURL: kMethodSearch
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            self.isWSCalling = true
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    if self.page == 1 || self.searchText.characters.count > 0 {
                        self.arrayOperational = []
                    }
                    
                    /*let arrayAlphabet = SearchText.modelsFromDictionaryArray(array: response[kData].arrayValue)
                    
                    let arrayInitial = arrayAlphabet.map({ (obj : SearchText) -> Character in
                        return obj.name.characters.count > 0  ? obj.name.uppercased().characters.first! : " "
                    })
                    
                    let arrayUniqueInitial = arrayInitial.unique.sorted()
                    
                    _ = arrayUniqueInitial.filter({ (char : Character) -> Bool in
                        
                        let predict = NSPredicate(format: "name BEGINSWITH[cd] %@","\(char)")
                        let temp = arrayAlphabet.filter({ predict.evaluate(with: $0) })
                        
                        if !temp.isEmpty {
                            self.arrayOperational.append(temp)
                        }
                        
                        return true
                    })*/
                    
                    let arrayData = SearchText.modelsFromDictionaryArray(array: response[kData].arrayValue)
                    self.arrayOperational.append(contentsOf: arrayData)
                    
                    self.tblBrand.reloadData()
                    
                    self.page = self.page + 1
                    break
                default :
                    //print(response[kMessage].stringValue)
                    
                    break
                }
            } else {
                
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
      self.tblBrand.backgroundColor = AppColor.primaryTheme
      self.navigationController?.view.backgroundColor = AppColor.primaryTheme
      
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.parent?.parent is SearchVC {
            searchText = (self.parent?.parent as! SearchVC).searchBar.text!
        }
        
        //TODO:- To maintain history in user defaults
        /*if searchText == "" {
            arrayOperational = SearchText().getUserDetailFromDefaults(key: kBrandSearchData)
            tblBrand.reloadData()
        } else {
            self.callSearchAPI()
        }*/
        
    }

}

extension BrandVC : PSTableDelegateDataSource {
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return arrayOperational.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return arrayOperational[section].count
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let headeView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 1.0))
//        let lineView : UIView = UIView(frame: CGRect(x: 0, y: -1 ,width: kScreenWidth, height: 1.0))
//        lineView.backgroundColor = UIColor.white
//        headeView.addSubview(lineView)
//        return headeView
//    }
    
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
        
        //TODO:- To maintain history in user defaults
        //objAtIndex.saveUserDetailInDefaults(key: kBrandSearchData)
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchDetailVC") as! SearchDetailVC
        vc.searchFlagType = searchFlagType.brand.rawValue
        vc.searchData = objAtIndex
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension BrandVC : SearchTextDelegate {
    
    func searchTextDelegateMethod(_ searchBar: UISearchBar) {
        
        searchText = searchBar.text!
        
        //TODO:- To maintain history in user defaults
        /*if searchText == "" {
            arrayOperational = SearchText().getUserDetailFromDefaults(key: kBrandSearchData)
        } else {
            self.callSearchAPI()
        }
         tblBrand.reloadData()
         */
        
        arrayOperational.removeAll()
        tblBrand.reloadData()
        self.page = 1
        self.callSearchAPI()
        
    }
}
    //MARK: - BrandCell -

class BrandCell: UITableViewCell {
    
    @IBOutlet var topLine : UIView!
    @IBOutlet var lblText : UILabel!
    @IBOutlet var bottompLine : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = AppColor.primaryTheme
        self.contentView.backgroundColor = AppColor.primaryTheme

        lblText.applyStyle(labelFont: UIFont.applyRegular(fontSize: 13.0), labelColor: AppColor.text)
    }
    
}

