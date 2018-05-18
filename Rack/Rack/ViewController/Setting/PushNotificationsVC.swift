//
//  PushNotificationsVC.swift
//  Rack
//
//  Created by GS Bit Labs on 1/18/18.
//  Copyright © 2018 Hyperlink. All rights reserved.
//

import UIKit


class PushNotificationsVC: UIViewController {
    
    @IBOutlet weak var tblNotifications: UITableView!
    let arrNotificationData = ["Likes": ["Off", "From People | Follow", "From Everyone"], "Comments": ["Off", "From People | Follow", "From Everyone"], "Reposts": ["Off", "From People | Follow", "From Everyone"], "Follow Requests": ["Off", "From Everyone"], "Photos of You": ["From People | Follow", "From Everyone"], "New followers": ["Off", "From Everyone"]]
    
    var objectArray: [Objects] = [Objects(sectionName: "Likes", sectionObjects: []), Objects(sectionName: "Comments", sectionObjects: []), Objects(sectionName: "Reposts", sectionObjects: []), Objects(sectionName: "Follow Requests", sectionObjects: []), Objects(sectionName: "Photos of You", sectionObjects: []), Objects(sectionName: "New Followers", sectionObjects: [])]
    
    var selectionArray: [Int] = [2,2,2,1,1,1]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppColor.primaryTheme
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = AppColor.primaryTheme
      
        for (key, value) in arrNotificationData {
            let data = Objects(sectionName: key, sectionObjects: value)
            switch key {
            case "Likes":
                objectArray.remove(at: 0)
                objectArray.insert(data, at: 0)
            case "Comments":
                objectArray.remove(at: 1)
                objectArray.insert(data, at: 1)
            case "Reposts":
                objectArray.remove(at: 2)
                objectArray.insert(data, at: 2)
            case "Follow Requests":
                objectArray.remove(at: 3)
                objectArray.insert(data, at: 3)
            case "Photos of You":
                objectArray.remove(at: 4)
                objectArray.insert(data, at: 4)
            case "New followers":
                objectArray.remove(at: 5)
                objectArray.insert(data, at: 5)
            default:
                break
            }
        }
        
        guard UserModel.currentUser.settings == nil else {
            selectionArray = UserModel.currentUser.settings.getsettings()
        tblNotifications.reloadData()
            return
        } 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: BarButton(title : "Done"), title: "Push Notifications")
    }
    
    //MARK:- Action Method
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    func rightButtonClicked() {
  
        APICall.shared.POST(strURL: kMethodSaveSettings
            , parameter: self.getSettingDictionary()
            , withErrorAlert: true
            , withLoader: true
            , constructingBodyWithBlock: nil
            , withBlock: { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
                
                if (error == nil) {
                let response = JSON(response ?? [:])
                UserModel.currentUser.settings = UserSettings(fromJson: response[kData])
                UserModel.currentUser.saveUserDetailInDefaults()
                _ = self.navigationController?.popViewController(animated: true)

                } else {
                    AlertManager.shared.showPopUpAlert("", message: error?.localizedDescription, forTime: 2.0, completionBlock: { (Int) in
                    })
                }
        })
    }
    
    func getSettingDictionary() -> [String:String] {
        var dict : [String:String] = [:]
        for index in 0..<selectionArray.count {
            var valueString : String = "everyone"
        if objectArray[index].sectionObjects[selectionArray[index]] == "From People | Follow"{
            valueString = "following"
        } else if objectArray[index].sectionObjects[selectionArray[index]] == "Off"{
            valueString = "off"
            }
            
        switch index {
            case 0:
                dict["likes"] = valueString
               break
            case 1:
                dict["comments"] = valueString
                break
            case 2:
                dict["reposts"] = valueString
                break
            case 3:
                dict["requests"] = valueString
                break
            case 4:
                dict["photos"] = valueString
                break
            default:
                dict["followers"] = valueString
            break
                
            }
        }
        return dict
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension PushNotificationsVC : PSTableDelegateDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return objectArray.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderCell
        cell.lblName.text = objectArray[section].sectionName
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (40 * kHeightAspectRasio)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (30 * kHeightAspectRasio)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectArray[section].sectionObjects.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PushNotificationsCell
        
        cell.lblOptions.text = objectArray[indexPath.section].sectionObjects[indexPath.row]
        cell.imgView.image = UIImage(named: "roundTick")
        cell.imgView.isHidden = true
        if selectionArray[indexPath.section] == indexPath.row{
            cell.imgView.isHidden = false
        }
       if indexPath.row == objectArray[indexPath.section].sectionObjects.count-1 {
            cell.viewSeprator.isHidden = false
        }else{
            cell.viewSeprator.isHidden = true
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionArray[indexPath.section] = indexPath.row
        tableView.reloadData()
    }
    
}

class PushNotificationsCell: UITableViewCell {
    @IBOutlet weak var lblOptions: UILabel!
    @IBOutlet weak var viewSeprator: UIView!
    @IBOutlet weak var imgView: UIImageView!
}

struct ObjectSetup {
    var sectionValue: String!
    var rowValue: String!
}

struct Objects {
    var sectionName : String!
    var sectionObjects : [String]!
}

