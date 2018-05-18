//
//  SearchDetailVC.swift
//  Rack
//
//  Created by hyperlink on 31/07/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import PeekView

class SearchDetailVC: BaseViewController {

    //MARK:- Outlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    let colum               : Float = 3.0,spacing :Float = 1.0
    var longGesture         = UILongPressGestureRecognizer()
    
    var searchData          : SearchText? = nil
    var searchFlagType      : String = searchFlag.brand.rawValue
    var arrayItemData       : [ItemModel] = []
    var page                : Int = 1
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
    
    func setUpView() {
        
        longGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        longGesture.minimumPressDuration = kMinimumPressDuration
        collectionView.addGestureRecognizer(longGesture)
        
        self.setupPullToRefresh()
        
        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.collectionView.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
        infinityIndicator.startAnimating()
        
        //callAPI for first data
        self.collectionView.ins_beginInfinityScroll()
        
         self.navigationController?.customize()
    }
    
    func setupPullToRefresh() {
        
        //bottom
        self.collectionView.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            
            if self.isWSCalling {
                self.isWSCalling = false
            
                let requestModel = RequestModel()
                requestModel.search_id = self.searchData?.id
                requestModel.search_flag = self.searchFlagType
                requestModel.name = self.searchData?.name
                requestModel.page = String(format: "%d", (self.page))
                
                self.callSearchDetailListAPI(requestModel, withCompletion: { (isSuccess) in
                    
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
    
    func callAfterServiceResponse(_ data : JSON) {
        
        arrayItemData.append(contentsOf: ItemModel.modelsFromDictionaryArray(array: data.arrayValue))
        self.collectionView.ins_endInfinityScroll(withStoppingContentOffset: true)
        self.collectionView.reloadData()
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callSearchDetailListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : user/search_detail
         
         Parameter   : search_id,search_flag[hashtag,brand,item]
         
         Optional    : page
         
         Comment     : This api will used for user send to new request
         
         ==============================
         */
        
        APICall.shared.POST(strURL: kMethodSearchDetail
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            self.isWSCalling = true
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    self.callAfterServiceResponse(response[kData])
                    self.page = (self.page) + 1
                    
                    block(true)
                    break
                    
                default:
                    //stop pagination
                    self.collectionView.ins_removeInfinityScroll()
                    
                    block(false)
                    break
                }
            } else {
                
                block(false)
            }
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.navigationController?.view.backgroundColor = AppColor.primaryTheme
      self.view.backgroundColor = AppColor.primaryTheme
      self.collectionView.backgroundColor = AppColor.primaryTheme
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: BarButton(title : ""), title: searchData?.name)
        
        //Google Analytics
        
        let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: "Tag's Item List")
        
        //Google Analytics
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: BarButton(title : ""), title: searchData?.name)
    }
    
    
}
extension SearchDetailVC : PSCollectinViewDelegateDataSource {
    
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
        cell.img.setImageWithDownload(objAtIndex.image.url())
      cell.img.backgroundColor = AppColor.primaryTheme
      cell.backgroundColor = AppColor.primaryTheme
      cell.contentView.backgroundColor = AppColor.primaryTheme
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ItemDetailVC") as! RackDetailVC
        vc.dictFromParent = arrayItemData[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

