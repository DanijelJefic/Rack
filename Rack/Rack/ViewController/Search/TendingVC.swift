//
//  TendingVC.swift
//  Rack
//
//  Created by hyperlink on 19/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class TendingVC: BaseViewController {

    //MARK:- Outlet
    
    @IBOutlet weak var tblTenting: UITableView!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var delegate : SearchTextDelegate?
    let arrayBranName = ["ADYN","Attila & O","Alexander McQueen","alto Clothing Co.","Balenciaga","Bulgari","Burberry","Balla","Bentley Stone","Calvin Klein","Chanel","Coach","Chbe","Dior","Diadora","Diamond Gang","Elliatt","executive Clothing Co.","Element"]
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
         self.navigationController?.customize()
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = AppColor.primaryTheme
      self.tblTenting.backgroundColor = AppColor.primaryTheme
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
}
extension TendingVC : PSTableDelegateDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayBranName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrandCell") as! BrandCell
        cell.selectionStyle = .none
        cell.lblText.text = arrayBranName[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40*kHeightAspectRasio
    }
    
}

extension TendingVC : SearchTextDelegate {
    
    func searchTextDelegateMethod(_ searchBar: UISearchBar) {
        //print(" TendingVC :- \(searchBar.text!)")
    }
    
}
