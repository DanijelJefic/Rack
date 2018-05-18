//
//  SelectCategoryVC.swift
//  Rack
//
//  Created by hyperlink on 16/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

protocol SelectCategoryDelegate {

    func selectCategoryDelegateMethod(indexPath : IndexPath , text : String)

}

class SelectCategoryVC: UIViewController {

    //MARK:- Outlet
    @IBOutlet var tblCategoty : UITableView!

    //------------------------------------------------------
    
    //MARK:- Class Variable
    var arrayCategory = NSMutableArray()
    var selectedIndexPath : IndexPath?
    var delegate : SelectCategoryDelegate?
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
        tblCategoty.tableFooterView = UIView()
        arrayCategory.addObjects(from: ["ALL" ,"Entertainment","Clothing","Shoes","Accessories","Beauty","Homeware","Decorative","Cars","Art","Lifestyle"])
        
        self.tblCategoty.isScrollEnabled = false
         self.navigationController?.customize()

    }
    
    func setSelectedIndex(_ indexPath : IndexPath?) {

        if let _ = indexPath {
            tblCategoty.selectRow(at: indexPath!, animated: false, scrollPosition: .none)
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }


}

extension SelectCategoryVC : PSTableDelegateDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCategory.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35 * kHeightAspectRasio
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let dictAtIndex = arrayCategory[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCategoryCell") as! SelectCategoryCell
        cell.lblText.text = dictAtIndex as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let dictAtIndex = arrayCategory[indexPath.row]

        tableView.cellForRow(at: indexPath)?.isSelected = true
        
        if let _ = delegate {
            self.delegate?.selectCategoryDelegateMethod(indexPath: indexPath ,text: dictAtIndex as! String)


            UIView.animate(withDuration: 0.6, animations: {
                self.view.frame.origin.y = -self.view.frame.size.height
                self.view.alpha = 0.0
            }, completion: { (isComplete : Bool) in
                
                if isComplete {
                    self.view.removeFromSuperview()
                self.view.alpha = 1.0
                }
            })

        }

        self.selectedIndexPath = indexPath
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
}

class SelectCategoryCell: UITableViewCell {
    @IBOutlet var lblText : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblText.applyStyle(labelFont: UIFont.applyBold(fontSize: 13.0), labelColor: AppColor.text)
    }

    override var isSelected: Bool {
        didSet {
            lblText.font = isSelected ? UIFont.applyBold(fontSize: 13.0) : UIFont.applyRegular(fontSize: 13.0)
        }
    }


}
