//
//  CommentView.swift
//  Rack
//
//  Created by hyperlink on 31/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

protocol CommentViewDelegate {
    func sendCommentDelegate(_ data : Any?)
}


class CommentView: UIView {

    @IBOutlet var view      : UIView!
    @IBOutlet var contentView : UIView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var tvComment: UITextView!
    @IBOutlet weak var btnSend: UIButton!
    
    var delegate                            : CommentViewDelegate?
    var dictFromParent                      : ItemModel = ItemModel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibSetUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibSetUp()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.cornerRadius = 10.0
        contentView.clipsToBounds = true
        lblUserName.applyStyle(labelFont: UIFont.applyBold(fontSize: 12.0), labelColor: AppColor.text)
        btnCancel.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 11.0), titleLabelColor: AppColor.btnTitle)
        btnSend.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 11.0), titleLabelColor: AppColor.btnTitle, borderColor: AppColor.secondaryTheme, borderWidth: 0.5, state: UIControlState())
        tvComment.applyStyle(textFont: UIFont.applyRegular(fontSize: 12.0), textColor: AppColor.btnTitle)
        tvComment.inputAccessoryView = self.addToolBar(self)
        tvComment.delegate = self
    }
    
    private func nibSetUp() {
        
        view = loadViewFromNib()
                self.awakeFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)

    }
    
    private func loadViewFromNib() -> UIView {
    
    let bundel = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundel)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
    
    //MARK: - API CALL
    
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
    
    //MARK: - Other Method
    
    func setUpData(_ data : Any?) {
     
        if let dict = data as? CommentModel {
         
            lblUserName.text = "\(dict.getUserName())"
            tvComment.text = "@\(dict.getUserName()) "
        }
        
        tvComment.becomeFirstResponder()
   
    }
    
    func showAnimationMethod() {
        self.alpha = 0.0
        self.contentView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1.0)
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
            self.contentView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }
    }
    
    func closeAnimationMethod(completion: @escaping (Bool) -> Void) {
        
        tvComment.resignFirstResponder()

        self.alpha = 1.0
        self.contentView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        
        UIView.animate(withDuration: 0.3
            , animations: {
                self.alpha = 0.0
                self.contentView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1.0)
        }) { (complete : Bool) in
            completion(complete)
        }
    }
    
    @IBAction func btnCloseClicked(_ sender : UIButton) {
        
        closeAnimationMethod { (complete) in
            self.removeFromSuperview()
        }
        
    }

    @IBAction func btnSendClicked(_ sender : UIButton) {
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let commentData : CommentModel = CommentModel()
        commentData.comment = tvComment.text!
        commentData.displayName = UserModel.currentUser.displayName
        commentData.userName = UserModel.currentUser.getUserName()
        commentData.userId = UserModel.currentUser.userId
        commentData.insertdate = Date().formatdateUTC(dt: dateFormatter.string(from: Date()), dateFormat: "YYYY-MM-dd HH:mm:ss", formatChange: "YYYY-MM-dd HH:mm:ss")
        commentData.profileThumb = UserModel.currentUser.getUserProfile()
        
        self.view.endEditing(true)
        let requestModel = RequestModel()
        requestModel.item_id = self.dictFromParent.itemId
        requestModel.comment = tvComment.text
        self.dictFromParent.commentCount = String(Int(self.dictFromParent.commentCount)! + 1)
        self.dictFromParent.commentData.append(commentData)
        self.dictFromParent.loginUserComment = true
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.dictFromParent)
        
        //call API for bottom data
        self.callSendCommentAPI(requestModel,
                                withCompletion: { (isSuccess : Bool) in
                                    self.tvComment.text = ""
                                    
        })
        
        closeAnimationMethod { (complete) in
//            if let _ = self.delegate{
//                self.delegate?.sendCommentDelegate(self.dictFromParent)
//            }
        }
        
    }
    
    func addToolBar(_ viewController : UIView) -> UIToolbar {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        toolBar.backgroundColor = UIColor.white
        
        let button = UIButton(frame: CGRect(x: kScreenWidth - 60, y: 0, width: 60, height: 44))
        button.setTitle("Done", for: .normal)
        button.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 14.0,isAspectRasio: false), titleLabelColor: AppColor.btnTitle)
        button.titleLabel?.textAlignment = .right
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        let fixSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(customView: button)
        toolBar.setItems([fixSpace,done], animated: false)
        toolBar.sizeToFit()
        return toolBar
    }
    
    func close() {
        tvComment.resignFirstResponder()
    }

}

extension CommentView : UITextViewDelegate {
    
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
        
        if textView.text == "" {
            btnSend.isEnabled = false
            btnSend.alpha = 0.5
        } else {
            btnSend.isEnabled = true
            btnSend.alpha = 1.0
        }
    }
}
