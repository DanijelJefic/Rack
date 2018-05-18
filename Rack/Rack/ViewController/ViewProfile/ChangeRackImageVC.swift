//
//  ChangeRackImageVC.swift
//  Rack
//
//  Created by GS Bit Labs on 2/13/18.
//  Copyright © 2018 Hyperlink. All rights reserved.
//

import UIKit

class ChangeRackImageVC: UIViewController {

    let colum : Float = 3.0,spacing :Float = 1.0
    var rackItemsArr = NSMutableArray()
    var arrayItemData: [ItemModel] = []
    var dictFromParent = ItemModel()
    typealias NewRackAdded = (String, String)->Void
    var newRackAdded:NewRackAdded!
    var selectedRackId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = AppColor.primaryTheme
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: nil, title: "Select Rack")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: nil, title: "Select Rack")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: nil, title: "Select Rack")
    }
    func leftButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    

}

//MARK: - CollectionView Delegate DataSource -
extension ChangeRackImageVC : PSCollectinViewDelegateDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayItemData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //value 2 - is left and right padding of collection view
        //value 1 - is spacing between two cell collection view
        let value = floorf((Float(kScreenWidth - 2) - (colum - 1) * spacing) / colum);
        return CGSize(width: Double(value), height: Double(value))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let objAtIndex = arrayItemData[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RackFolderListCell", for: indexPath) as! RackFolderListCell
        
        cell.image.contentMode = .scaleAspectFill
        cell.image.clipsToBounds = true
        
        cell.image.setImageWithDownload(objAtIndex.image.url())
        
        if objAtIndex.itemId == self.selectedRackId {
            cell.selectedView.alpha = 0.5
        }else{
            cell.selectedView.alpha = 0
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let objAtIndex = arrayItemData[indexPath.row]
        if self.newRackAdded != nil {
            self.newRackAdded(objAtIndex.image, objAtIndex.itemId)
        }

        self.navigationController?.popViewController(animated: true)
        
    }
    
}



