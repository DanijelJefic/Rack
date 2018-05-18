//
//  CategoriesVC.swift
//  Rack
//
//  Created by GP on 07/01/18.
//  Copyright © 2018 Hyperlink. All rights reserved.
//

import UIKit

class CategoriesVC: UIViewController {
    
    let categories                          = NSMutableArray()
    var tableView:UITableView!              = nil
    var selectedCategories:NSMutableArray!  = nil
    typealias SelectedData                  = (String)->Void
    var selectedData:SelectedData!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categories.add("Animals and Pets")
         categories.add("Architecture")
         categories.add("Art")
         categories.add("Beauty")
         categories.add("Cars and Motorcycles")
         categories.add("Countries")
         categories.add("DIY")
         categories.add("Design")
         categories.add("Food and Drink")
         categories.add("Health and Fitness")
         categories.add("Hobbies")
         categories.add("Home decor")
         categories.add("Lifestyle")
         categories.add("Men’s Fashion")
         categories.add("Music")
         categories.add("Nature")
         categories.add("Religion")
         categories.add("Sport")
         categories.add("Travel")
         categories.add("Women's Fashion")
        
        self.tableView = UITableView.init(frame: self.view.bounds, style: .plain)
         self.tableView.tintColor = UIColor.black
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = UIColor.clear
        self.view.addSubview(self.tableView)
        
        
        self.navigationController?.customize()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: nil, title: "Categories")

    }
    

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.frame = self.view.bounds
    }
    
    func leftButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension CategoriesVC:UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "Cell")
            cell.selectionStyle = .none
            cell.textLabel?.font = UIFont.applyRegular(fontSize: 22.0)
            cell.textLabel?.textColor = UIColor.black
        }
        
        cell.textLabel?.text = categories[indexPath.row] as? String
        cell.accessoryType = .none
        
        if self.selectedCategories.contains( categories[indexPath.row]){
            cell.accessoryType = .checkmark
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            
            if self.selectedData != nil {
                self.selectedData(self.categories[indexPath.row] as! String)
            }
            
            self.selectedCategories.add(self.categories[indexPath.row])
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
}

extension CategoriesVC:UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46.0
    }
}
