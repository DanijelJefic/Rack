//
//  CreateNewRackVC.swift
//  Rack
//
//  Created by GP on 08/01/18.
//  Copyright © 2018 Hyperlink. All rights reserved.
//

import UIKit

class CreateNewRackVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var txtField: UITextField!
    
    var isEditRack: Bool = false
    var rackName: String = ""
    var image:UIImage! = nil
    typealias NewRackAdded = (String)->Void
    var newRackAdded:NewRackAdded!
    
    
    var isPresent:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        imageView.image = image
        txtField.text = rackName
        txtField.autocorrectionType = .no
        txtField.returnKeyType = .done
        txtField.delegate = self
        txtField.font = UIFont.applyRegular(fontSize: 15.0)
        txtField.textColor = AppColor.createReckText
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isEditRack {
            _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: BarButton(title: "Done"), title: "Edit Rack")
            
        }else{
            _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: BarButton(title: "Done"), title: "Create Rack")
        }
    }

    func leftButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func rightButtonClicked() {
        let text:String = (self.txtField.text?.trimmingCharacters(in: .whitespaces))!
        if text.count > 0 {
            if self.newRackAdded != nil {
                self.newRackAdded(text)
            }
            
            if isPresent {
                self.navigationController?.popViewController(animated: true)
            }else{
                if let tempVC = navigationController?.viewControllers {
                    
                    for vc in tempVC {
                        if vc is UploadVC {
                            let uploadVC = vc as! UploadVC
                            uploadVC.rackName = text
                            uploadVC.rackImage = imageView.image
                            
                            let firstData = folderStructure.modelsFromLocalDictionary(rackname: text, image: imageView.image!)
                            uploadVC.arrayItemData.append(contentsOf: firstData)
                            
                            self.navigationController?.popToViewController(vc, animated: true)
                        }
                        
                        if vc is EditRackFolderVC {
                            self.navigationController?.popToViewController(vc, animated: true)
                        }
                        
                    }
                    
                }
                
            }
        }else{
            AlertManager.shared.showPopUpAlert("", message:"Please add rack name", forTime: 2.0, completionBlock: { (Int) in
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = txtField.text!.count + string.count - range.length
        
        if newLength == 25 {
            return false
        }
        return true
    }
    
}
