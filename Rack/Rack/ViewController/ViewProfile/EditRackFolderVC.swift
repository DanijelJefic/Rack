//
//  EditRackFolderVC.swift
//  Rack
//
//  Created by GS Bit Labs on 2/13/18.
//  Copyright © 2018 Hyperlink. All rights reserved.
//

import UIKit

class EditRackFolderVC: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    
    var arrayItemData: [ItemModel]       = []
    let categoriesVC                     = CategoriesVC()
    let selectedCategories               = NSMutableArray()
    typealias cellType                   = EditRackCellType
    var dictFromParent : ItemModel       = ItemModel()
    var userData       : UserModel?      = nil
    var _imgPost                         = UIImage()
    var selectedRackId                   = String()
    typealias CompletionHandeler = ()->Void
    var completion:CompletionHandeler!
    
    
    var arrayCellType : [Dictionary<String,Any>] = [
        [kCellType : cellType.pinImageCell, kTitle : "Pin a Photo"],
        [kCellType : cellType.rackNameCell, kTitle : "Rack Name"],
        [kCellType : cellType.categoryCell, kTitle : "Category"]
        ]
    
    deinit {
        
        //print("Edit Rack Folder VC...")
        NotificationCenter.default.removeObserver(kNotificationItemDetailDelete)
        NotificationCenter.default.removeObserver(kNotificationRackList)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = AppColor.primaryTheme
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = AppColor.primaryTheme
        self.tblView.backgroundColor = AppColor.primaryTheme
        NotificationCenter.default.addObserver(self, selector: #selector(notificationItemDelete(_:)), name: NSNotification.Name(rawValue: kNotificationItemDetailDelete), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationItemDelete(_:)), name: NSNotification.Name(rawValue: kNotificationRackList), object: nil)
        self.navigationController?.customize()
        selectedRackId = dictFromParent.rackItemId
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: BarButton(title: "Done"), title: "Edit Rack", isSwipeBack: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: BarButton(title: "Done"), title: "Edit Rack", isSwipeBack: false)
    }
    func rightButtonClicked() {
        let requestModel = RequestModel()
        requestModel.rack_id = self.dictFromParent.rackId
        requestModel.user_id = self.dictFromParent.userId
        requestModel.rack_name = self.dictFromParent.rackName
        requestModel.rack_image = (self.dictFromParent.rackImage as NSString).lastPathComponent
        requestModel.rack_category = self.dictFromParent.rackCategory
        
        self.callEditRackAPI(requestModel, withCompletion: { (isSuccess : Bool) in
            if isSuccess {
                self.dictFromParent.isFolderUpdated = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRackList), object: self.dictFromParent)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.dictFromParent)
            }
        })
        
    }

    func leftButtonClicked() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDeleteRack(_ sender: AnyObject){
        
        AlertManager.shared.showAlertTitle(title: "", message: "Delete this Rack? This cannot be undone.", buttonsArray: ["Delete","Cancel"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                
                let requestModel = RequestModel()
                requestModel.rack_id = self.dictFromParent.rackId
                requestModel.user_id = self.dictFromParent.userId
                
                self.callDeleteItemAPI(requestModel, withCompletion: { (isSuccess : Bool) in
                    if isSuccess {
                        self.dictFromParent.isFolderUpdated = true
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailDelete), object: self.dictFromParent)
                    }
                })
                
                break
            case 1:
                
                break
            default :
                break
            }
        }
        
    }
    
    func notificationItemDelete(_ notification : Notification) {
        self.navigationController?.dismiss(animated: false, completion: {
            if self.completion != nil {
                self.completion()
            }
        })
    }
    
    func callDeleteItemAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/deleteitem
         
         Parameter   : item_id
         
         Optional    :
         
         Comment     : This api will used for user can deleted the rack Folder.
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodRackDelete
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false, withLoader: true)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    block(true)
                    break
                    
                default:
                    block(false)
                    break
                }
            } else {
                block(false)
            }
        }
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callEditRackAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/edit_rack
         
         Parameter   : user_id,rack_id,rack_name,rack_image
         
         Optional    :
         
         Comment     : This api will used for user can update the rack Folder.
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodRackEdit
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false, withLoader: true)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    block(true)
                    break
                    
                default:
                    block(false)
                    if status == "3" {
                        AlertManager.shared.showPopUpAlert("", message: response[kMessage].stringValue, forTime: 2.0, completionBlock: { (Int) in
                        })
                    }
                    break
                }
            } else {
                block(false)
            }
        }
    }

}

extension EditRackFolderVC: PSTableDelegateDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCellType.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let dictAtIndex = arrayCellType[indexPath.row]
        switch dictAtIndex[kCellType] as!   cellType {
        case .pinImageCell:
            return 150 * kHeightAspectRasio
        case .categoryCell , .rackNameCell:
            return 73 * kHeightAspectRasio
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dictAtIndex = arrayCellType[indexPath.row]
        switch dictAtIndex[kCellType] as! cellType {
        case .pinImageCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pinImage") as! EditRackVCCell
            cell.btnPinImage.addTarget(self, action: #selector(didTapOnPinImageChange), for: .touchUpInside)
            cell.btnPinImage.tag = indexPath.row
            
            cell.imgView.setImageWithDownload(dictFromParent.rackImage.url())
            
            return cell
            
        case .rackNameCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "rackName") as! EditRackVCCell
            cell.lblRackName.text = self.dictFromParent.rackName
            return cell
            
        case .categoryCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "category") as! EditRackVCCell
            cell.lblCategory.text = dictFromParent.rackCategory
            return cell
            
        }
        
    }
    
    func didTapOnPinImageChange(_ sender: UIButton) {
        let vc:ChangeRackImageVC = storyboard?.instantiateViewController(withIdentifier: "ChangeRackImageVC") as! ChangeRackImageVC
        vc.arrayItemData = self.arrayItemData
        vc.dictFromParent = self.dictFromParent
        vc.selectedRackId = self.selectedRackId
        
        vc.newRackAdded = {(imgUrl, id) in
            self.selectedRackId = id
            self.dictFromParent.rackImage = imgUrl
            self.tblView.reloadData()
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dictAtIndex = arrayCellType[indexPath.row]
        let _cellType = dictAtIndex[kCellType] as! cellType
        
        switch _cellType {
            
        case .pinImageCell:
            print("")
        case .rackNameCell:
            
            let indexPath1 = IndexPath(row: 0, section: 0)
            let cellPinImage = tableView.cellForRow(at: indexPath1) as! EditRackVCCell
            
            let cell = tableView.cellForRow(at: indexPath) as! EditRackVCCell
            
            let createNewRackVC:CreateNewRackVC = storyboard?.instantiateViewController(withIdentifier: "CreateNewRackVC") as! CreateNewRackVC
            createNewRackVC.isEditRack = true
            createNewRackVC.image = cellPinImage.imgView.image
            createNewRackVC.rackName = cell.lblRackName.text!
            createNewRackVC.newRackAdded = {(text) in
                self.dictFromParent.rackName = text
                self.tblView.reloadData()
            }
            
            self.navigationController?.pushViewController(createNewRackVC, animated: true)
            
        case .categoryCell:
            self.selectedCategories.removeAllObjects()
            categoriesVC.selectedCategories = self.selectedCategories
            categoriesVC.selectedData = { (text) -> Void in
                self.dictFromParent.rackCategory = text
                self.tblView.reloadData()
            }
            
            DispatchQueue.main.async(execute: {
                let navigationConteoller = UINavigationController.init(rootViewController: self.categoriesVC)
                navigationConteoller.navigationBar.isTranslucent = false
                self.present(navigationConteoller, animated: true, completion: nil)
            })
        }
        
    }
    
    
}

class EditRackVCCell: UITableViewCell{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnPinImage: UIButton!
    @IBOutlet weak var lblRackName: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
}
