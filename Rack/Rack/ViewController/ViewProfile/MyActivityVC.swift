//
//  MyActivityVC.swift
//  Rack
//
//  Created by hyperlink on 11/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import PeekView

class MyActivityVC: UIViewController {

    //MARK:- Outlet
    
    @IBOutlet weak var collectionView: UICollectionView!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    let colum : Float = 3.0,spacing :Float = 1.0
    var longGesture = UILongPressGestureRecognizer()
    var page                : Int = 1
    var arrayItemData       : [ItemModel] = []
    var isWSCalling         : Bool = true
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
    
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    func setUpView() {

        longGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        longGesture.minimumPressDuration = kMinimumPressDuration
        collectionView.addGestureRecognizer(longGesture)
        
        self.setupPullToRefresh()
        
        self.collectionView.ins_beginInfinityScroll()
        
        self.navigationController?.customize()
    }
    
    func setupPullToRefresh() {
        
        //bottom
        self.collectionView.ins_addInfinityScroll(withHeight: 0.1) { (scrollView) in
            
            if self.isWSCalling {
                self.isWSCalling = false
                
                //Call API
                let requestModel = RequestModel()
                requestModel.page = String(format: "%d", (self.page))
                
                self.callUserActivityAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                    scrollView?.ins_endInfinityScroll(withStoppingContentOffset: true)
                    
                    if isSuccess {
                        self.arrayItemData .append(contentsOf: ItemModel.modelsFromDictionaryArray(array: (jsonResponse?.arrayValue)!))
                        self.collectionView.reloadData()
                    }
                })
            }
        }
    }
    
    func handleLongPress(_ gesture : UILongPressGestureRecognizer) {
        
        if gesture.state == .ended {
            
            let window = UIApplication.shared.keyWindow
            
            for peekView in window!.subviews {
                
                if peekView is PeekView {
                    UIView.animate(withDuration: 0.3, animations: {
                        peekView.alpha = 0.0
                    }, completion: { (isComplete : Bool) in
                        peekView.removeFromSuperview()
                    })
                }
            }
            
            return
        }
        
        
        let point = gesture.location(in: collectionView)
        
        guard let indexPath = self.collectionView.indexPathForItem(at: point) else {
            return
        }
        //print(indexPath)
        
        let objAtIndex = arrayItemData[indexPath.row]
        
        let preViewVC = secondStoryBoard.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
        preViewVC.image = objAtIndex.image.url()
        
        PeekView.viewForController(parentViewController: self
            , contentViewController: preViewVC
            , expectedContentViewFrame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
            , fromGesture: gesture
            , shouldHideStatusBar: true
            , menuOptions: []
            , completionHandler: nil
            , dismissHandler: nil)
        
        
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callUserActivityAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : user/activity
         
         Parameter   :
         
         Optional    : page
         
         Comment     : This api will used for user delete comment.
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodUserActivity
            , parameter: requestModel.toDictionary()
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            self.isWSCalling = true
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    self.page = (self.page) + 1
                    block(true,response[kData])
                    break
                    
                default:
                    
                    self.collectionView.ins_endInfinityScroll(withStoppingContentOffset: true)
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
    
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = AppColor.primaryTheme
      self.collectionView.backgroundColor = AppColor.primaryTheme
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "MY ACTIVITY FEED")
        
        //Google Analytics
        
        let category = "UI"
        let action = "\(UserModel.currentUser.displayName!) view his activity"
        let lable = ""
        let screenName = "Settings - Activity Feed"
        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
        
        //Google Analytics
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }

}

extension MyActivityVC : PSCollectinViewDelegateDataSource {
    
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
        let cell : CustomImagePickerCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CustomImagePickerCell", for: indexPath) as! CustomImagePickerCell
        
        DispatchQueue.main.async {
            cell.img.setImageWithDownload(objAtIndex.image.url())
        }
      
        cell.contentView.backgroundColor = AppColor.primaryTheme
        cell.backgroundColor = AppColor.primaryTheme
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ItemDetailVC") as! RackDetailVC
        vc.dictFromParent = arrayItemData[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
 
}
