//
//  BlockedUserVC.swift
//  Rack
//
//  Created by hyperlink on 09/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class BlockedUserVC: UIViewController {

    //MARK:- Outlet
    
    @IBOutlet weak var tblUser: UITableView!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var arrayBlock    : [FollowModel] = []
    var page             : Int = 1
    
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

        self.setupPullToRefresh()
        self.perform(#selector(self.addLoaderWithDelay), with: nil, afterDelay: 0.3)
        
         self.navigationController?.customize()
    }
    
    func addLoaderWithDelay() {
        /*let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.tblUser.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.tblUser.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)*/
        
        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.tblUser.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
        infinityIndicator.startAnimating()
        
        //callAPI for first data
        self.tblUser.ins_beginInfinityScroll()
    }
    
    func setupPullToRefresh() {
     /*
        self.tblUser.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
            //Call API
            
            let requestModel = RequestModel()
            requestModel.page = String(format: "%d", (self.page))
            
            self.callBlockUserListAPI(requestModel, withCompletion: { (isSuccess : Bool) in
                scrollView?.ins_endPullToRefresh()
            })
        }*/
        
        //bottom
        self.tblUser.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            //Call API
            
            let requestModel = RequestModel()
            requestModel.page = String(format: "%d", (self.page))
            
            self.callBlockUserListAPI(requestModel, withCompletion: { (isSuccess : Bool) in
                scrollView?.ins_endPullToRefresh()
            })
        }
    }
    
    func callAfterServiceResponse(_ data : JSON) {
        
        arrayBlock.append(contentsOf: FollowModel.modelsFromDictionaryArray(array: data.arrayValue))
       
        guard tblUser != nil else {
            return
        }
       
        tblUser.reloadData()
        
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callBlockUserListAPI(_ requestModel : RequestModel, withCompletion block :((Bool) -> Void)?) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : "user/block_user"
         
         Parameter   :
         
         Optional    : page
         
         Comment     : This api will used for user get block user list.
         
         
         ==============================
         
         */
        
        
        APICall.shared.GET(strURL: kMethodBlockUser
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue

                switch(status) {
                   
                case success:

                    self.callAfterServiceResponse(response[kData])
                    
                    if let _ = block {
                        block!(true)
                    }
                    
                    break
                    
                default:
                    if self.page == 1 {
                        GFunction.shared.showPopup(with: response[kMessage].stringValue, forTime: 2, withComplition: {
                        }, andViewController: self)
                    }
                    
                    if let _ = block {
                        block!(false)
                    }
                    break
                }
            } else {
                if let _ = block {
                    block!(false)
                }
            }

        }
        
    }
    
    func callUpdateRequestAPI(_ requstModel : RequestModel
        , withCompletion block:@escaping (Bool,JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/update_request
         
         Parameter   : status[accepted,rejected,blocked,unfollow],user_id
         
         Optional    :
         
         Comment     : This api will used for user update the request.
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodUpdateRequest
            , parameter: requstModel.toDictionary())
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    GFunction.shared.showPopup(with: response[kMessage].stringValue, forTime: 2, withComplition: {
                    }, andViewController: self)
                    
                    block(true,response[kData])
                    break
                    
                default:
                    GFunction.shared.showPopup(with: response[kMessage].stringValue, forTime: 2, withComplition: {
                    }, andViewController: self)
                    
                    block(false,nil)
                    break
                }
            } else {
                block(false,nil)
            }
        }
    }

    
    //------------------------------------------------------
    
    //MARK:- Action Method
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = AppColor.primaryTheme
      self.tblUser.backgroundColor = AppColor.primaryTheme
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "BLOCKED USERS")
        
        //Google Analytics
        
        let category = "UI"
        let action = "\(UserModel.currentUser.displayName!) view his bocked users"
        let lable = ""
        let screenName = "Settings - Blocked users"
        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
        
        //Google Analytics
    }


}
//MARK: - TableView Delegate Datasource -
extension BlockedUserVC : PSTableDelegateDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayBlock.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let objAtIndex = arrayBlock[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell

        cell.selectionStyle = .none
        cell.lblUserName.text = objAtIndex.getUserName()
        cell.lblDisplayName.text = objAtIndex.displayName
        
        cell.btnStatus.setTitle(objAtIndex.isFollowing, for: .normal)
        
        cell.imgProfile.setImageWithDownload(objAtIndex.getUserProfile().url())

//        cell.btnStatus.setTitle("Unblock", for: .normal)
        cell.btnStatus.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 13.0), titleLabelColor: AppColor.text)

        cell.btnStatusClicked = {

            //Blocked...
            AlertManager.shared.showAlertTitle(title: "", message: "Do you wish to unblock this user?", buttonsArray: ["Cancel","Unblock"]) { (buttonIndex : Int) in
                switch buttonIndex {
                case 0 :
                    break
                case 1:
                    //UnBlock clicked
                   
                    //Api Call
                    let requestModel = RequestModel()
                    requestModel.user_id = objAtIndex.userId
                    requestModel.status = requestStatus.unfollow.rawValue
                    self.callUpdateRequestAPI(requestModel, withCompletion: { (isSuccess : Bool, response : JSON?) in
                        
                        if isSuccess {
                         
                            self.arrayBlock = self.arrayBlock.filter({ ( unBlockUser : FollowModel) -> Bool in
                                
                                if unBlockUser.userId == objAtIndex.userId {
                                    return false
                                }
                                return true
                            })
                            
                            self.tblUser.reloadData()
                        }
                    })
                    
                    break
                default :
                    break
                }
            }
            

        }

      cell.backgroundColor = AppColor.primaryTheme
      cell.contentView.backgroundColor = AppColor.primaryTheme
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 * kHeightAspectRasio
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objAtIndex = arrayBlock[indexPath.row]
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.viewType = .other
        vc.fromPage = .otherPage
        vc.userData = UserModel(fromJson: JSON(objAtIndex.toDictionary()))
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
    //MARK: - UserCell -
class UserCell : UITableViewCell {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblDisplayName: UILabel!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var imgVerify: UIImageView!
    
    var btnStatusClicked : (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()

      self.backgroundColor = AppColor.primaryTheme
      self.contentView.backgroundColor = AppColor.primaryTheme

        imgProfile.applyStype(cornerRadius: (45 * kHeightAspectRasio) / 2)
        
        lblUserName.applyStyle(labelFont: UIFont.applyBold(fontSize: 13.0), labelColor: AppColor.text)
        lblDisplayName.applyStyle(labelFont: UIFont.applyRegular(fontSize: 13.0), labelColor: AppColor.text)

    }
    
    @IBAction func btnStatusClicked(_ sender : UIButton) {
    
        if let btnAction = btnStatusClicked {
            btnAction()
        }
    }
}

