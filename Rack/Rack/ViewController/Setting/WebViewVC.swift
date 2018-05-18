//
//  WebViewVC.swift
//  Rack
//
//  Created by hyperlink on 09/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class WebViewVC: UIViewController {

    enum webViewURLType : String {
        case termsAndCondition = "TERMS & CONDITIONS"
        case privacyPolicy     = "PRIVACY POLICY"
        case about             = "ABOUT"
    }
    
    
    //MARK:- Outlet
    
    @IBOutlet var webView : UIWebView!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var urlType : webViewURLType = .termsAndCondition
    
    //------------------------------------------------------
    
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        webView.delegate = nil
        webView = nil
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    func setUpView() {

        self.navigationItem.title = urlType.rawValue
        switch urlType {
        case .termsAndCondition:
            webView.loadRequest(URLRequest(url: URL(string: kTerms)!))
            break
        case .privacyPolicy:
            webView.loadRequest(URLRequest(url: URL(string: kPrivacy)!))
            break
        case .about:
            webView.loadRequest(URLRequest(url: URL(string: kAbout)!))
            break
        }
        
        webView.delegate = self
        
         self.navigationController?.customize()
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
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: urlType.rawValue)
        
        //Google Analytics
        
        let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: self.title)
        
        //Google Analytics
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        

    }
}

extension WebViewVC : UIWebViewDelegate {
 
    //MARK:- WebView Delegate
    
    func webViewDidStartLoad(_ webView: UIWebView) {
     
        //print("Start")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {

        //print("Finish")
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        //print("Error")
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    //------------------------------------------------------
}
