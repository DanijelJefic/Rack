//
//  CommentView.swift
//  Rack
//
//  Created by hyperlink on 31/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import AFNetworking
import PinterestSDK
import TMTumblrSDK

enum NormalCellType : String {
    case delete
    case edit
    case report
}

protocol NormalCellPopUpDelegate {
    func handleBtnClick(btn : NormalCellType, data : ItemModel, img : UIImage)
}

class NormalCellPopUp: UIView, UIGestureRecognizerDelegate {
    
    @IBOutlet var view                          : UIView!
    @IBOutlet var contentView                   : UIView!
    @IBOutlet var lblTitle                      : UILabel!
    @IBOutlet var btnEditPost                   : UIButton!
    @IBOutlet var btnDeletePost                 : UIButton!
    @IBOutlet var btnReportPost                 : UIButton!
    @IBOutlet var contentViewTopConstraint      : NSLayoutConstraint!
    @IBOutlet var btnFacebook                   : UIButton!
    @IBOutlet var btnTwitter                    : UIButton!
    
    var dictFromParent : ItemModel = ItemModel()
    var delegate : NormalCellPopUpDelegate? = nil
    var imgPost : UIImage = UIImage()
    var singleTapGesture = UITapGestureRecognizer()
    var arraySocialKeys : [Dictionary<String , Dictionary<String,Any>>] = []
//    var completeAuthOp: FKDUNetworkOperation!
//    var checkAuthOp: FKDUNetworkOperation!
    var webView: UIWebView!

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
        
        singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.singleTapGestureCalled(sender:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(singleTapGesture)
        
        lblTitle.applyStyle(labelFont: UIFont.applyBold(fontSize: 14.0), labelColor: UIColor.white)
        btnEditPost.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 12.0), titleLabelColor: UIColor.white, borderColor: UIColor.white, borderWidth: 1.0, state: UIControlState())
        btnDeletePost.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 12.0), titleLabelColor: UIColor.white, borderColor: UIColor.white, borderWidth: 1.0, state: UIControlState())
        btnReportPost.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 12.0), titleLabelColor: UIColor.white, borderColor: UIColor.white, borderWidth: 1.0, state: UIControlState())
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
    
    //MARK: - Other Method
    
    func setUpData(_ data : Any?) {
        
        if let dict = data as? ItemModel {
            
            dictFromParent = dict
            
            if dict.userId == UserModel.currentUser.userId {
                btnEditPost.isHidden = false
                btnDeletePost.isHidden = false
                btnReportPost.isHidden = true
            } else {
                btnEditPost.isHidden = true
                btnDeletePost.isHidden = true
                btnReportPost.isHidden = false
            }
        }
    }
    
    func singleTapGestureCalled(sender: UIGestureRecognizer) {
        
        close()
    }
    
    func close() {
        self.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        
        UIView.animate(withDuration: 0.1
            , animations: {
                self.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1.0)
        }) { (complete : Bool) in
            if complete {
                self.removeFromSuperview()
            }
        }
    }
    
    func callItemSharingAPI(_ requestModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/sharing
         
         Parameter   : item_id,social_keys
         
         Optional    :
         
         Comment     : This api will used for item sharing
         
         ==============================
         */
        
        APICall.shared.POST(strURL: kMethodItemSharing
            , parameter: requestModel.toDictionary()
            , withErrorAlert: true
            , withLoader: false
            , constructingBodyWithBlock: { (formData : AFMultipartFormData?) in
                
        }
            , withBlock: { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
                
        })
    }
    
    //------------------------------------------------------
    
    //MARK:- API Call 
    
    func callDeleteItemAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/deleteitem
         
         Parameter   : item_id
         
         Optional    :
         
         Comment     : This api will used for user can deleted the item detail.
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodItemDelete
            , parameter: requestModel.toDictionary()
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
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
    
    //MARK:- Action Method
    
    @IBAction func btnReportPost(_ sender: UIButton) {
        close()
        self.delegate?.handleBtnClick(btn: NormalCellType.report, data: self.dictFromParent, img: imgPost)
    }
    
    @IBAction func btnEditPost(_ sender: UIButton) {
        
        self.delegate?.handleBtnClick(btn: NormalCellType.edit, data: self.dictFromParent, img: imgPost)
        close()
    }
    
    @IBAction func btnDeletePost(_ sender: UIButton) {
        close()
        AlertManager.shared.showAlertTitle(title: "", message: "Delete this post? This cannot be undone.", buttonsArray: ["Delete","Cancel"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                
                let requestModel = RequestModel()
                requestModel.item_id = self.dictFromParent.itemId
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailDelete), object: self.dictFromParent)
                
                self.callDeleteItemAPI(requestModel, withCompletion: { (isSuccess : Bool) in
                    if isSuccess {
                        
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
    
    @IBAction func btnFacebook(_ sender: UIButton) {
        let loginManager : FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        loginManager.logIn(withPublishPermissions: ["publish_actions"], from: self.superview as? UIViewController) { (result, error) in
            if (error == nil) {
                
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                
                if (fbloginresult.grantedPermissions != nil) {
                    if(fbloginresult.grantedPermissions.contains("publish_actions")) {
                        let fbAccessToken = FBSDKAccessToken.current().tokenString
                        //print("fbAccessToken \(String(describing: fbAccessToken))")
                        
                        self.arraySocialKeys = []
                        self.arraySocialKeys.append(["facebook" : ["access_token" : fbAccessToken!]])
                        
                        let requestModel = RequestModel()
                        requestModel.item_id = self.dictFromParent.itemId
                        requestModel.social_keys = JSON(self.arraySocialKeys)
                        self.callItemSharingAPI(requestModel)
                        
                    } else {
                        //                            AlertManager.shared.showAlertTitle(title: "Facebook Error"
                        //                                ,message: "Publish action not granted.")
                    }
                }
                
                self.close()
            }
        }
    }
    
    @IBAction func btnTwitter(_ sender: UIButton) {
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                //print("signed in as \(String(describing: session?.userName))");
                
                let authToken = session?.authToken
                let authTokenSecret = session?.authTokenSecret
                
                self.arraySocialKeys = []
                self.arraySocialKeys.append(["twitter" : ["access_token" : authToken!, "secret" : authTokenSecret!]])
                
                let requestModel = RequestModel()
                requestModel.item_id = self.dictFromParent.itemId
                requestModel.social_keys = JSON(self.arraySocialKeys)
                self.callItemSharingAPI(requestModel)
                
            } else {
                //print("error: \(String(describing: error?.localizedDescription))");
            }
            
            self.close()
        })
    }
    
    @IBAction func btnPinterest(_ sender: UIButton) {
        PDKClient.sharedInstance().authenticate(withPermissions: [PDKClientReadPublicPermissions,PDKClientWritePublicPermissions,PDKClientReadRelationshipsPermissions,PDKClientWriteRelationshipsPermissions], withSuccess: { (PDKResponseObject) in
            
            self.arraySocialKeys = []
            
            self.arraySocialKeys.append(["pinterest" : ["access_token" : PDKClient.sharedInstance().oauthToken]])
            
            let requestModel = RequestModel()
            requestModel.item_id = self.dictFromParent.itemId
            requestModel.social_keys = JSON(self.arraySocialKeys)
            self.callItemSharingAPI(requestModel)
            
        }) { (Error) in
            AlertManager.shared.showAlertTitle(title: "Pinterest Error"
                ,message: Error?.localizedDescription)
        }
        
        self.close()
    }
    
    @IBAction func btnFlickr(_ sender: UIButton) {
        /*
        let callbackURLString = "rack://auth"
        
        // Begin the authentication process
        let url = URL(string: callbackURLString)
        FlickrKit.shared().beginAuth(withCallbackURL: url!, permission: FKPermission.write, completion: { (url, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if ((error == nil)) {
                    let urlRequest = NSMutableURLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
                    self.webView = UIWebView(frame: (AppDelegate.shared.window?.frame)!)
                    AppDelegate.shared.window?.addSubview(self.webView)
                    self.webView.loadRequest(urlRequest as URLRequest)
                } else {
                    let alert = UIAlertView(title: "Error", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            });
        })
         */
    }
    
//    func webView(_ webView: UIWebView, shouldStartLoadWithRequest request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        //If they click NO DONT AUTHORIZE, this is where it takes you by default... maybe take them to my own web site, or show something else
//
//        self.webView.removeFromSuperview()
//
//        let url = request.url
//
//        // If it's the callback url, then lets trigger that
//        if  !(url?.scheme == "http") && !(url?.scheme == "https") {
//            if (UIApplication.shared.canOpenURL(url!)) {
//                UIApplication.shared.openURL(url!)
//                return false
//            }
//        }
//        return true
//
//    }
    
    @IBAction func btnTumblr(_ sender: UIButton) {
        /*
        TMAPIClient.sharedInstance().authenticate("rack", from: self.superview?.viewController(), callback: {(_ error: Error?) -> Void in
            // You are now authenticated (if !error)
            
            if error == nil {
                var blogName : String = ""
                TMAPIClient.sharedInstance().userInfo({ (response, error) in
                    if error == nil {
                        guard (response as? Dictionary<String,Any>) != nil else {
                            return
                        }
                        
                        guard (response as! Dictionary<String,Any>)["user"] as? Dictionary<String,Any> != nil else {
                            return
                        }
                        
                        guard ((response as! Dictionary<String,Any>)["user"] as! Dictionary<String,Any>) ["name"] as? String != nil else {
                            return
                        }
                        
                        blogName = ((response as! Dictionary<String,Any>)["user"] as! Dictionary<String,Any>)["name"] as! String + ".tumblr.com"
                        
                        self.arraySocialKeys.append(["tumblr" : ["oauth_token" : TMAPIClient.sharedInstance().oAuthToken!, "oauth_secret" : TMAPIClient.sharedInstance().oAuthTokenSecret!, "blogname" : blogName]])
                        
                    }
                })
                
            } else {
                //print("error: \(String(describing: error?.localizedDescription))");
            }
        })*/
    }
}
