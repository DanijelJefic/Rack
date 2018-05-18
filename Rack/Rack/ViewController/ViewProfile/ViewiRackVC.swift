//
//  ViewRackVC.swift
//  Rack
//
//  Created by hyperlink on 11/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import PeekView

class ViewiRackVC: UIViewController {

    //MARK:- Outlet
    @IBOutlet weak var collectionView: UICollectionView!    

    @IBOutlet var viewHeader: UIView!
    @IBOutlet weak var btnHeader: UIButton!
    @IBOutlet weak var btnHeaderImage: UIButton!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    let colum : Float = 3.0,spacing :Float = 1.0
    var longGesture = UILongPressGestureRecognizer()
    var categotyVC = secondStoryBoard.instantiateViewController(withIdentifier: "SelectCategoryVC") as! SelectCategoryVC
    var arrayItemData : [ItemModel] = []
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
        btnHeader.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 15.0, isAspectRasio: false), titleLabelColor: AppColor.text)
        
        categotyVC.delegate = self
        
        longGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        longGesture.minimumPressDuration = kMinimumPressDuration
        collectionView.addGestureRecognizer(longGesture)
        
        self.setupPullToRefresh()
        
         self.navigationController?.customize()
        
        
//        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
//        self.collectionView.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
//        infinityIndicator.startAnimating()
        
        //callAPI for first data
        self.collectionView.ins_beginInfinityScroll()
        
    }
    
    func setupPullToRefresh() {
        
        //bottom
        self.collectionView.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            let requestModel = RequestModel()
            requestModel.page = String(format: "%d", (self.page))
            
            self.callWantListAPI(requestModel, withCompletion: { (isSuccess) in
                
            })
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
        
        let preViewVC = secondStoryBoard.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
//        preViewVC.image = #imageLiteral(resourceName: "myBG.jpg")
        
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
    

    @IBAction func btnCategoryClicked(_ sender : UIButton) {

        if categotyVC.view.isDescendant(of: self.view) {
            btnHeaderImage.isSelected = false
            categotyVC.view.removeFromSuperview()
        } else {
            
            btnHeaderImage.isSelected = true
            
            categotyVC.willMove(toParentViewController: self)
            self.addChildViewController(categotyVC)
            categotyVC.didMove(toParentViewController: self)


            self.categotyVC.view.frame = CGRect(x: 0, y: -self.categotyVC.view.frame.size.height, width: kScreenWidth, height: self.view.frame.height)
            self.view.addSubview(self.categotyVC.view)
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .transitionCurlDown, animations: {

            self.categotyVC.view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: self.view.frame.height)
            }, completion: { (isComplete : Bool) in
                
            })

            //If SelectIndexPath nil then pass (0,0)
            if  categotyVC.selectedIndexPath != nil {
                categotyVC.setSelectedIndex(categotyVC.selectedIndexPath)
            } else {
                categotyVC.setSelectedIndex(IndexPath(item: 0, section: 0))
            }
        }
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callWantListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/rackwantlist
         
         Parameter   : user_id,item_type
         
         Optional    : page
         
         Comment     : This api will used for user send to new request
         
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodIWantList
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int, error : Error?) in
            
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
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

      _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: BarButton(title : ""), title: "iWANT")
        
        /*//TODO: As per client requirement remove functionality for category filtering view from navigation header
        btnHeader.setTitle("ALL", for: .normal
        self.navigationItem.titleView = viewHeader
         */
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: BarButton(title : ""), title: "iWANT")

    }

}
extension ViewiRackVC : PSCollectinViewDelegateDataSource {
    
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
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ItemDetailVC") as! RackDetailVC
        vc.dictFromParent = arrayItemData[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ViewiRackVC : SelectCategoryDelegate {
    
    func selectCategoryDelegateMethod(indexPath: IndexPath ,text : String) {
        categotyVC.selectedIndexPath = indexPath

        viewHeader.alpha = 0.0
        UIView.animate(withDuration: 0.6) {
            self.viewHeader.alpha = 1.0
            self.view.layoutIfNeeded()
        }

        btnHeader.setTitle(text, for: .normal)
        btnHeaderImage.isSelected = false

    }
}
