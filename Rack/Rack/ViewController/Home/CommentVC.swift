//
//  CommentVC.swift
//  Rack
//
//  Created by hyperlink on 30/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import ActiveLabel

let minCommentViewSize : CGFloat = 50.0
let maxCommentViewSize : CGFloat = 100.0

class CommentVC: UIViewController,UITextViewDelegate {

    enum RackCellType : String {
        case normalCell
        case multiImageCell
        case repostCell
    }
    
    //MARK:- Outlet
    
    @IBOutlet weak var tblComment: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tvComment: UITextView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var constBottomViewHeight: NSLayoutConstraint!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    
    var arrayCommentData                    : [CommentModel] = [CommentModel]()
    var page                                : Int = 1
    var delegate                            : CommentViewDelegate?
    var dictFromParent                      : ItemModel = ItemModel()
    var copyDictFromParent                  : ItemModel = ItemModel()
    var hmc                                 : GGHashtagMentionController = GGHashtagMentionController()
    var isWSCalling                         : Bool = true
    //------------------------------------------------------
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(kNotificationUserDetailsUpdate)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {

        tblComment.estimatedRowHeight = 95
        tblComment.rowHeight = UITableViewAutomaticDimension
        
        hmc = GGHashtagMentionController.init(textView: tvComment, delegate: self)
        
        
        btnSend.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 12.0), titleLabelColor: UIColor.black)
        tvComment.applyStyle(textFont: UIFont.applyRegular(fontSize: 12.0), textColor: UIColor.black)
        tvComment.delegate = self

        btnSend.isEnabled = false
        btnSend.alpha = 0.5

        constBottomViewHeight.constant = minCommentViewSize
        
        //setup for autoPullTorefresh and paggination
        self.setupPullToRefresh()
        
        self.perform(#selector(self.addLoaderWithDelay), with: nil, afterDelay: 0.3)
        
        
         self.navigationController?.customize()
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
    }

    func scrollToBottom(){
        if arrayCommentData.count > 0 {
            let indexPath = IndexPath(row: self.arrayCommentData.count - 1, section: 0)
            self.tblComment.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    func setupPullToRefresh() {
        
        //top
        self.tblComment.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
            
            if self.isWSCalling {
                self.isWSCalling = false
                
                let requestModel = RequestModel()
                requestModel.item_id = self.dictFromParent.itemId
                requestModel.page = String(format: "%d", (self.page))
                
                //call API for top data
                self.callCommentListAPI(requestModel,
                                        withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                            
                                            //stop pagination
                                            self.tblComment.ins_endPullToRefresh()
                                            
                                            if isSuccess {
                                                
                                                let array = CommentModel.modelsFromDictionaryArray(array: jsonResponse!.arrayValue)
                                                self.arrayCommentData.insert(contentsOf: array.reversed(), at: 0)
                                                self.tblComment.reloadData()
                                                
                                                if self.page == 1 {
                                                    self.perform(#selector(self.scrollToBottom), with: nil, afterDelay: 0.0)
                                                }
                                                
                                            } else {
                                                if self.page == 1 {
                                                    if (jsonResponse?.stringValue) != nil {
                                                        GFunction.shared.showPopup(with: (jsonResponse?.stringValue)!, forTime: 2, withComplition: {
                                                        }, andViewController: self)
                                                    }
                                                }
                                            }
                })
            }
        }
    }
    
    func setUpDetailText(_ lblDetail : ActiveLabel, userName : String) {
        
        let customTypeMention = ActiveLabel.CustomActiveTypes.mention
        lblDetail.enabledTypes = [.hashtag,customTypeMention]
        lblDetail.customize { (label : ActiveLabel) in
            label.customColor[customTypeMention] = AppColor.secondaryTheme
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var attribute = attributes
                switch type {
                case customTypeMention:
                    attribute[NSFontAttributeName] = UIFont.applyBold(fontSize: 11.0)
                    attribute[NSForegroundColorAttributeName] = AppColor.textB
                    break
                case .hashtag :
                    attribute[NSFontAttributeName] = UIFont.applyRegular(fontSize: 11.0)
                    attribute[NSForegroundColorAttributeName] = AppColor.textB
                    break
                default: ()
                }
                return attribute
            }
            
            
            label.handleCustomTap(for: customTypeMention) {
                //print("CustomType \($0)")
                
                let objData = ["user_name" : $0]
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                vc.userData = UserModel(fromJson: JSON(objData))
                vc.userData?.userId = ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            label.handleHashtagTap({ ( str : String) in
                //print("HashTag : \(str)")
            })
            
            
            
            label.handleMentionTap({ (str : String) in
                //print("Mention : \(str)")
                
                let objData = ["user_name" : str]
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                vc.userData = UserModel(fromJson: JSON(objData))
                vc.userData?.userId = ""
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
    }
    
    func userNameSingleTap(_ sender : UITapGestureRecognizer) {
        
        let index = (sender.view?.tag)!
        
        let dictAtIndex = self.arrayCommentData[index] as CommentModel
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.viewType = .other
        vc.fromPage = .otherPage
        vc.userData = UserModel(fromJson: JSON(dictAtIndex.toDictionary()))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func profileImgSingleTap(_ sender : UITapGestureRecognizer) {
        
        let index = (sender.view?.tag)!
        
        let dictAtIndex = self.arrayCommentData[index] as CommentModel
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.viewType = .other
        vc.fromPage = .otherPage
        vc.userData = UserModel(fromJson: JSON(dictAtIndex.toDictionary()))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addLoaderWithDelay() {
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.tblComment.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.tblComment.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
        
        self.tblComment.ins_beginPullToRefresh()
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationUserDetailsUpdate(_ notification : Notification) {
        
        guard let _ = tblComment else {
            return
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblComment.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callCommentListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/comment_list
         
         Parameter   : item_id
         
         Optional    : page
         
         Comment     : This api will used for item wise comment listing.
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodItemCommentList
            , parameter: requestModel.toDictionary()
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            self.isWSCalling = true
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    block(true,response[kData])
                    self.page = (self.page) + 1
                    
                    break
                    
                default:
                    //stop pagination
                    self.tblComment.ins_endInfinityScroll(withStoppingContentOffset: true)
                    block(false,response[kMessage])
                    
                    break
                }
            } else {
                
                block(false,nil)
            }
        }
    }
    
    func callSendCommentAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/add_comment
         
         Parameter   : comment,item_id
         
         Optional    : parent_id
         
         Comment     : This api will used for sending comment.
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodSendComment
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
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
    
    func callDeleteCommentAPI(_ requestModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/delete_comment
         
         Parameter   : comment_id
         
         Optional    : 
         
         Comment     : This api will used for user delete comment.
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodDeleteComment
            , parameter: requestModel.toDictionary()
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    break
                    
                default:
                    
                    break
                }
            } else {
                
            }
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendClicked(_ sender: UIButton) {
        
        let commentData : CommentModel = CommentModel()
        commentData.comment = tvComment.text!
        
        tvComment.text = ""
        self.view.endEditing(true)
        btnSend.isEnabled = false
        btnSend.alpha = 0.5
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        commentData.displayName = UserModel.currentUser.displayName
        commentData.userName = UserModel.currentUser.getUserName()
        commentData.userId = UserModel.currentUser.userId
        commentData.insertdate = Date().formatdateUTC(dt: dateFormatter.string(from: Date()), dateFormat: "YYYY-MM-dd HH:mm:ss", formatChange: "YYYY-MM-dd HH:mm:ss")
        commentData.profileThumb = UserModel.currentUser.getUserProfile()
        
        arrayCommentData.append(commentData)
        tblComment.reloadData()

        constBottomViewHeight.constant = minCommentViewSize
        UIView.animate(withDuration: 0.2) { 
            self.view.layoutIfNeeded()
        }

        self.scrollToBottom()
        
        let requestModel = RequestModel()
        requestModel.item_id = self.dictFromParent.itemId
        requestModel.comment = commentData.comment
        
        self.dictFromParent.commentCount = String(Int(self.dictFromParent.commentCount)! + 1)
        self.dictFromParent.commentData.append(commentData)
        self.dictFromParent.loginUserComment = true
        
        //call API for bottom data
        self.callSendCommentAPI(requestModel,
                                withCompletion: { (isSuccess : Bool) in
                                    
                                    //Google Analytics
                                    let category = "UI"
                                    let action = "\(UserModel.currentUser.displayName!) commented on item \(self.dictFromParent.itemId!)"
                                    let lable = ""
                                    googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: self.title)
                                    
                                    //Google Analytics
 
        })
    }
    
    func btnChatReplayClicked(_ sender : UIButton) {
        
        guard let indexPath = sender.buttonIndexPath  else {
            return
        }
        
 /*       guard let cell = tblComment.cellForRow(at: indexPath) as? CommentCell else {
            return
        }
  */
        let dictAtIndex : CommentModel = arrayCommentData[indexPath.row]

        tvComment.becomeFirstResponder()
        tvComment.text = "@\(dictAtIndex.getUserName()) "

    }
    
    func btnDotClicked(_ sender : UIButton) {
        
        guard let indexPath = sender.buttonIndexPath else {
            return
        }
        
        guard let cell = tblComment.cellForRow(at: indexPath) as? CommentCell else {
            return
        }
        
        let dictAtIndex : CommentModel = arrayCommentData[indexPath.row]
        
        /*
         1. Logged in user's post and logged in user's comment -> [Report, Delete, Cancel]
         2. Logged in user's comment -> [Delete, Cancel]
         3. If it doesn't satisfy any of the above mentioned condition's then -> [Report, Cancel]
         */
        
        if dictAtIndex.userId != UserModel.currentUser.userId && self.dictFromParent.userId == UserModel.currentUser.userId {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionReport = UIAlertAction(title: "Report", style: .default) { (action : UIAlertAction) in
                //new page
            }
            
            let actionBlock = UIAlertAction(title: "Delete", style: .default) { (action : UIAlertAction) in
                
                AlertManager.shared.showAlertTitle(title: "", message: "Delete this comment?", buttonsArray: ["Delete","Cancel"]) { (buttonIndex : Int) in
                    switch buttonIndex {
                    case 0 :
                        
                        if let index = self.dictFromParent.commentData.index(of: self.arrayCommentData[indexPath.row]) {
                            self.dictFromParent.commentData.remove(at: index)
                        }
                        
                        self.arrayCommentData.remove(at: indexPath.row)
                        self.tblComment.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        
                        self.tblComment.reloadData()
                        
                        let requestModel = RequestModel()
                        requestModel.comment_id = dictAtIndex.commentId
                        
                        self.dictFromParent.commentCount = String(Int(self.dictFromParent.commentCount)! - 1)
                        
                        let arrayLoggedUsersComment = self.arrayCommentData.filter({ (objComment : CommentModel) -> Bool in
                            
                            if objComment.userId == UserModel.currentUser.userId {
                                return true
                            } else {
                                return false
                            }
                            
                        })
                        
                        if arrayLoggedUsersComment.isEmpty {
                            self.dictFromParent.loginUserComment = false
                        } else {
                            self.dictFromParent.loginUserComment = true
                        }
                        
                        let cellType = RackCellType(rawValue: self.copyDictFromParent.rackCell)
                        if cellType == .normalCell {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.dictFromParent)
                        }else{
                            self.copyDictFromParent.parentItem = self.dictFromParent
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.copyDictFromParent)
                        }
                        
                        self.callDeleteCommentAPI(requestModel)
                        
                        break
                    case 1:
                        
                        break
                    default :
                        break
                    }
                }
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                
            }
            
            actionSheet.addAction(actionReport)
            actionSheet.addAction(actionBlock)
            actionSheet.addAction(actionCancel)
            
            self.present(actionSheet, animated: true, completion: nil)
            
        } else if dictAtIndex.userId == UserModel.currentUser.userId {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionBlock = UIAlertAction(title: "Delete", style: .default) { (action : UIAlertAction) in
                
                AlertManager.shared.showAlertTitle(title: "", message: "Delete this comment?", buttonsArray: ["Delete","Cancel"]) { (buttonIndex : Int) in
                    switch buttonIndex {
                    case 0 :
                        
                        let index = self.dictFromParent.commentData.index(where: { (objComment : CommentModel) -> Bool in
                            if let _ = dictAtIndex.commentId {
                                return dictAtIndex.commentId == objComment.commentId
                            } else {
                                return false
                            }
                        })
                        
                        if let _ = index {
                            self.dictFromParent.commentData.remove(at: index!)
                        }
                        
                        self.arrayCommentData.remove(at: indexPath.row)
                        self.tblComment.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        
                        self.tblComment.reloadData()
                        
                        let requestModel = RequestModel()
                        requestModel.comment_id = dictAtIndex.commentId
                        
                        self.dictFromParent.commentCount = String(Int(self.dictFromParent.commentCount)! - 1)
                        
                        let arrayLoggedUsersComment = self.arrayCommentData.filter({ (objComment : CommentModel) -> Bool in
                            
                            if objComment.userId == UserModel.currentUser.userId {
                                return true
                            } else {
                                return false
                            }
                            
                        })
                        
                        if arrayLoggedUsersComment.isEmpty {
                            self.dictFromParent.loginUserComment = false
                        } else {
                            self.dictFromParent.loginUserComment = true
                        }
                        
                        let cellType = RackCellType(rawValue: self.copyDictFromParent.rackCell)
                        if cellType == .normalCell {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.dictFromParent)
                        }else{
                            self.copyDictFromParent.parentItem = self.dictFromParent
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.copyDictFromParent)
                        }
                        
                        self.callDeleteCommentAPI(requestModel)
                        
                        break
                    case 1:
                        
                        break
                    default :
                        break
                    }
                }
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                
            }
            
            actionSheet.addAction(actionBlock)
            actionSheet.addAction(actionCancel)
            
            self.present(actionSheet, animated: true, completion: nil)
            
        } else {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionReport = UIAlertAction(title: "Report", style: .default) { (action : UIAlertAction) in
                //new page
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                
            }
            
            actionSheet.addAction(actionReport)
            actionSheet.addAction(actionCancel)
            
            self.present(actionSheet, animated: true, completion: nil)
            
        }
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Textview Delegate method
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.perform(#selector(self.scrollToBottom), with: nil, afterDelay: 0.0)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newLength = textView.text.characters.count + text.characters.count - range.length
        
        if (range.location == 0 && text == " ") || (range.location == 0 && text == "\n") {
            return false
        }
        
        if newLength <= 9999 {
            
        } else {
            return false
        }

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        //72 is SEND Button and textview leading padding.
        //10 textview top and bottom padding
        let textSize = textView.sizeThatFits(CGSize(width: kScreenWidth - 72, height: CGFloat(MAXFLOAT)))
        constBottomViewHeight.constant = (textSize.height + 10 < minCommentViewSize) ? minCommentViewSize : (textSize.height + 10) < maxCommentViewSize ? (textSize.height + 10) : maxCommentViewSize

        if textView.text == "" {
            btnSend.isEnabled = false
            btnSend.alpha = 0.5
        } else {
            btnSend.isEnabled = true
            btnSend.alpha = 1.0
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = AppColor.primaryTheme
      self.tblComment.backgroundColor = AppColor.primaryTheme

        setUpView()
        self.tvComment.keyboardDistanceFromTextField = 0
        
        //Google Analytics
        
        let category = "UI"
        let action = "\(UserModel.currentUser.displayName!) view item \(dictFromParent.itemId!)'s comments"
        let lable = ""
        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: self.title)
        
        //Google Analytics
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "COMMENTS")

        //TabBarHidden:true
        self.tabBarController?.tabBar.isHidden = true
        
        
        //Google Analytics
         
        let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: self.title)
        
        //Google Analytics
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.setAnimationsEnabled(false)
        self.tvComment.becomeFirstResponder()
        UIView.setAnimationsEnabled(true)
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "COMMENTS")

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        let cellType = RackCellType(rawValue: copyDictFromParent.rackCell)
        if cellType == .normalCell {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.dictFromParent)
        }else{
            self.copyDictFromParent.parentItem = self.dictFromParent
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.copyDictFromParent)
        }
    }
}

//MARK: - TableView Delegate Datasource -
extension CommentVC : PSTableDelegateDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCommentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dictAtIndex = arrayCommentData[indexPath.row] as CommentModel
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        cell.selectionStyle = .none
        cell.lblUserName.text = dictAtIndex.getUserName()
        cell.lblComment.text = dictAtIndex.comment
        self.setUpDetailText(cell.lblComment,userName : dictAtIndex.getUserName())
        cell.ivProfile.setImageWith(dictAtIndex.getUserProfile().url())
        cell.lblTime.text = dictAtIndex.calculatePostTime()
        cell.btnDot.buttonIndexPath = indexPath
        cell.btnReplay.buttonIndexPath = indexPath
        cell.btnReplay.addTarget(self, action: #selector(btnChatReplayClicked(_:)), for: .touchUpInside)
        cell.btnDot.addTarget(self, action: #selector(btnDotClicked(_:)), for: .touchUpInside)
        
        cell.lblUserName.tag = indexPath.row
        //singletap configuration for profileview
        cell.userNameLabelGesture = UITapGestureRecognizer(target: self, action: #selector(userNameSingleTap(_:)))
        cell.userNameLabelGesture.numberOfTapsRequired = 1
        cell.userNameLabelGesture.numberOfTouchesRequired = 1
        cell.lblUserName.addGestureRecognizer(cell.userNameLabelGesture)
        cell.lblUserName.isUserInteractionEnabled = true
        
        cell.ivProfile?.tag = indexPath.row
        //singletap configuration for profileview
        cell.profileImgGesture = UITapGestureRecognizer(target: self, action: #selector(profileImgSingleTap(_:)))
        cell.profileImgGesture.numberOfTapsRequired = 1
        cell.profileImgGesture.numberOfTouchesRequired = 1
        cell.ivProfile?.addGestureRecognizer(cell.profileImgGesture)
        cell.ivProfile?.isUserInteractionEnabled = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let dictAtIndex = arrayCommentData[indexPath.row] as CommentModel
//
//        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
//        vc.viewType = .other
//        vc.fromPage = .otherPage
//        vc.userData = UserModel(fromJson: JSON(dictAtIndex.toDictionary()))
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension CommentVC : GGHashtagMentionDelegate {
    
    func hashtagMentionController(_ hashtagMentionController: GGHashtagMentionController!, onHashtagWithText text: String!, range: NSRange) {
        
    }
    
    func hashtagMentionController(_ hashtagMentionController: GGHashtagMentionController!, onMentionWithText text: String!, range: NSRange) {
        if text.characters.count > 0 {
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchPeopleCaptionVC") as! SearchPeopleCaptionVC
            vc.imageTagType = TagType.tagPeople
            vc.delegate = self
            vc.searchBar.text = text
            
            vc.completion = {(_ tagUser: Any) -> Void in
                if let name = PeopleTagModel(fromJson: JSON(tagUser)).name {
                    self.tvComment.text = (self.tvComment.text as NSString?)?.replacingCharacters(in: range, with: name as String)
                    self.tvComment.text = self.tvComment.text + " "
                } else {
                    self.tvComment.text = (self.tvComment.text as NSString?)?.replacingCharacters(in: range, with: "")
                }
            }
            
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func hashtagMentionControllerDidFinishWord(_ hashtagMentionController: GGHashtagMentionController!) {
        
    }
}

extension CommentVC : SearchCaptionDelegate {
    
    func searchCaptionDelegateMethod(_ tagDetail: Any,tagType : TagType?) {
        
        let name = PeopleTagModel(fromJson: JSON(tagDetail)).name
        self.tvComment.text = "\(self.tvComment.text!)\(name!) "
    }
}

//MARK: - CommentCell -
class CommentCell : UITableViewCell {
    
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblComment: ActiveLabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnReplay: UIButton!
    @IBOutlet weak var btnDot: UIButton!
    @IBOutlet weak var constImageHeight: NSLayoutConstraint!
    
    var userNameLabelGesture = UITapGestureRecognizer()
    var profileImgGesture = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        //Change only constant value to increase decrease size of profile image. Don't change constraint.
//        constImageHeight.constant = 50 * kHeightAspectRasio
//        ivProfile.applyStype(cornerRadius: (50 * kHeightAspectRasio) / 2)
        constImageHeight.constant = ivProfile.frame.size.height
        ivProfile.applyStype(cornerRadius: ivProfile.frame.size.height  / 2)
        ivProfile.layoutIfNeeded()
        lblUserName.applyStyle(labelFont: UIFont.applyBold(fontSize: 13.0), labelColor: AppColor.textB)
        lblComment.applyStyle(labelFont: UIFont.applyRegular(fontSize: 12.0), labelColor: AppColor.textB)
        lblTime.applyStyle(labelFont: UIFont.applyRegular(fontSize: 10.0), labelColor: AppColor.textB)
        
        btnReplay.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 11.0), titleLabelColor: AppColor.textB)

      self.backgroundColor = AppColor.primaryTheme
      self.contentView.backgroundColor = AppColor.primaryTheme

    }
    

}
