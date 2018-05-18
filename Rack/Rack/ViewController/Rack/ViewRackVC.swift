//
//  ViewRackVC.swift
//  Rack
//
//  Created by hyperlink on 11/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import PeekView

class ViewRackVC: UIViewController {

    //MARK:- Outlet
    @IBOutlet weak var collectionView: UICollectionView!    

    @IBOutlet var viewHeader: UIView!
    @IBOutlet weak var btnHeader: UIButton!
    @IBOutlet weak var btnHeaderImage: UIButton!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    let colum               : Float = 3.0,spacing :Float = 1.0
    var longGesture         = UILongPressGestureRecognizer()
    var categotyVC          = secondStoryBoard.instantiateViewController(withIdentifier: "SelectCategoryVC") as! SelectCategoryVC
    var userData            : UserModel? = nil
    
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
        NotificationCenter.default.removeObserver(kNotificationRackWantEdit)
        NotificationCenter.default.removeObserver(kNotificationItemDetailDelete)
        NotificationCenter.default.removeObserver(kNotificationWant)
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
        
        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.collectionView.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
        infinityIndicator.startAnimating()

        //callAPI for first data
        self.collectionView.ins_beginInfinityScroll()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationItemDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationRackWantEdit), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationWant(_:)), name: NSNotification.Name(rawValue: kNotificationWant), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationItemDataDelete(_:)), name: NSNotification.Name(rawValue: kNotificationItemDetailDelete), object: nil)
        
//        if #available(iOS 10.0, *) {
//            self.collectionView.prefetchDataSource = self
//        } else {
//            // Fallback on earlier versions
//        }
    }
    
    func setupPullToRefresh() {
        /*
        let requestModel = RequestModel()
        requestModel.user_id = self.userData?.userId
        requestModel.item_type = (self.userData?.isShowRack())! ? StatusType.want.rawValue : StatusType.rack.rawValue
        requestModel.page = String(format: "%d", (self.page))
        
        self.callWantListAPI(requestModel, withCompletion: { (isSuccess,jsonResponse) in
            
            if isSuccess {
                
                //Google Analytics
                
                let category = "UI"
                let action = "\(String(describing: self.userData!.displayName!)) view \(self.userData!.isShowRack() ? "racked" : "want") items"
                let lable = ""
                let screenName = "User Profile -> \(self.userData!.isShowRack() ? "Rack" : "Want") Item"
                googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                
                //Google Analytics
                
            } else {
                if self.page == 1 {
                    if (jsonResponse?.stringValue) != nil {
                        GFunction.shared.showPopup(with: (jsonResponse?.stringValue)!, forTime: 2, withComplition: {
                        }, andViewController: self)
                    }
                }
            }
            
        })
 */
        //bottom
        self.collectionView.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            
            if self.isWSCalling {
                self.isWSCalling = false
                
                let requestModel = RequestModel()
                requestModel.user_id = self.userData?.userId
                requestModel.item_type = (self.userData?.isShowRack())! ? StatusType.want.rawValue : StatusType.rack.rawValue
                requestModel.page = String(format: "%d", (self.page))
                
                self.callWantListAPI(requestModel, withCompletion: { (isSuccess,jsonResponse) in
                    
                    if isSuccess {
                        
                        //Google Analytics
                        
                        let category = "UI"
                        let action = "\(String(describing: self.userData!.displayName!)) view \(self.userData!.isShowRack() ? "racked" : "want") items"
                        let lable = ""
                        let screenName = "User Profile -> \(self.userData!.isShowRack() ? "Rack" : "Want") Item"
                        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                        
                        //Google Analytics
                        
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
        
        let newData = ItemModel.modelsFromDictionaryArray(array: data.arrayValue)
        
        
//        if page == 1 {
        arrayItemData.append(contentsOf: newData)
        self.collectionView.ins_endInfinityScroll(withStoppingContentOffset: true)
        self.collectionView.reloadData()
       /* } else {
            _ = newData.filter { (obj : ItemModel) -> Bool in
                let index = IndexPath(row: self.arrayItemData.count, section: 0)
                self.arrayItemData.insert(obj, at: self.arrayItemData.count)
                self.collectionView.insertItems(at: [index])
                
                return true
                
            }
        }*/
        
        
        
        /*
         To download image out of visible cell's as per client's requirement, this code is implemented
 
        _ = newData.filter({ (obj : ItemModel) -> Bool in
            
            weak var img : UIImageView? = UIImageView()
            img?.setImageWithDownload(obj.image.url())
            
            return true
        })
         */
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationItemDetailsUpdate(_ notification : Notification) {
        
        //print("============Notification Method Called=================")
        //print(notification.object!)
        
        guard let _  = collectionView else {
            return
        }
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
//        arrayItemData = arrayItemData.map({ (obj : ItemModel) -> ItemModel in
//            if obj.itemId == jsonData.itemId {
//                return jsonData
//            } else {
//                return obj
//            }
//        })
        
        let predict = NSPredicate(format: "itemId LIKE %@",jsonData.itemId!)
        let temp = arrayItemData.filter({ predict.evaluate(with: $0) })
        
        if !temp.isEmpty {
            if let index = self.arrayItemData.index(of: temp[0]) {
                self.arrayItemData[index] = jsonData
            }
        } else {
            self.arrayItemData.insert(jsonData, at: 0)
        }
        
        /*
         item_type == rack && user default == show_rack on
         item_type == want && user default == show_rack off
         */
        arrayItemData = arrayItemData.filter({ (obj : ItemModel) -> Bool in
            if obj.itemType == "rack" && !UserModel.currentUser.isShowRack() {
                return true
            } else if obj.itemType == "want" && UserModel.currentUser.isShowRack() {
                return true
            }
            return false
        })
        
        self.collectionView.reloadData()

    }
    
    func notificationItemDataDelete(_ notification : Notification) {
        
        //        //print("============Notification Method Called=================")
        //        //print(notification.object!)
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        guard let _  = collectionView else {
            return
        }
        
        let notiItemData = jsonData
        //change main data
        
        arrayItemData = arrayItemData.filter { (objFollow : ItemModel) -> Bool in
            if objFollow.itemId == notiItemData.itemId {
                return false
            } else {
                return true
            }
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }, completion: { (Bool) in
            self.view.layoutIfNeeded()
        })
    }
    
    func notificationWant(_ notification : Notification) {
        //print("============Notification Method Called=================")
        //print(notification.object!)
        
        guard let _  = collectionView else {
            return
        }
        
        var notiWantData = ItemModel()
        
        if let jsonData   = notification.object as? JSON {
            notiWantData = ItemModel(fromJson: jsonData)
        } else if let jsonData   = notification.object as? ItemModel {
            notiWantData = jsonData
        } else {
            return
        }
        
        //        arrayItemData = arrayItemData.map({ (obj : ItemModel) -> ItemModel in
        //            if obj.itemId == jsonData.itemId {
        //                return jsonData
        //            } else {
        //                return obj
        //            }
        //        })
        
        let predict = NSPredicate(format: "itemId LIKE %@",notiWantData.itemId!)
        let temp = arrayItemData.filter({ predict.evaluate(with: $0) })
        
        if !temp.isEmpty {
            if let index = self.arrayItemData.index(of: temp[0]) {
                self.arrayItemData.remove(at: index)
            }
        } else {
            self.arrayItemData.insert(notiWantData, at: 0)
        }
        
        /*
         item_type == rack && user default == show_rack on
         item_type == want && user default == show_rack off
         */
        arrayItemData = arrayItemData.filter({ (obj : ItemModel) -> Bool in
            if obj.itemType == "rack" && !UserModel.currentUser.isShowRack() {
                return true
            } else if obj.itemType == "want" && UserModel.currentUser.isShowRack() {
                return true
            }
            return false
        })
        
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
    
    func callWantListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool,JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/rackwantlist
         
         Parameter   : user_id,item_type
         
         Optional    : page
         
         Comment     : This api will used for user send to new request
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodRackWantList
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
                    
                    block(true,response[kData])
                    break
                    
                default:
                    //stop pagination
                    self.collectionView.ins_removeInfinityScroll()
                    
                    block(false,response[kMessage])
                    break
                }
            } else {
                self.collectionView.ins_endInfinityScroll(withStoppingContentOffset: true)
                block(false,nil)
                
            }
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.view.backgroundColor = AppColor.primaryTheme
      self.navigationController?.navigationBar.barTintColor = AppColor.primaryTheme
      self.navigationController?.navigationBar.isTranslucent = false

        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (userData?.isShowRack())! {
            _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: BarButton(title : ""), title: "WANT LIST")
        } else {
            _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: BarButton(title : ""), title: "RACK")
        }
        
        /*//TODO: As per client requirement remove functionality for category filtering view from navigation header
        btnHeader.setTitle("ALL", for: .normal)
        self.navigationItem.titleView = viewHeader
         */
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        
    }

}
extension ViewRackVC : PSCollectinViewDelegateDataSource {
    
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

//extension ViewRackVC : UICollectionViewDataSourcePrefetching {
//    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
//        SDWebImagePrefetcher.shared().cancelPrefetching()
//    }
//
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        let urls = indexPaths.flatMap {
//            self.arrayItemData[$0.row].image.url()
//        }
//
//        SDWebImagePrefetcher.shared().prefetchURLs(urls)
//    }
//}

extension ViewRackVC : SelectCategoryDelegate {
    
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

/*extension ViewRackVC : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset: CGFloat = scrollView.contentOffset.y
        let maximumOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height + 20
        if maximumOffset - currentOffset <= 1 {
            
             self.setupPullToRefresh()
            
//            if isWSCalling {
//
//                isWSCalling = false
////                self.page += 1
//
//            }
        }
    }
}
*/
