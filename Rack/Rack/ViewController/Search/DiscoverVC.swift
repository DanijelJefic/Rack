//
//  DiscoverVC.swift
//  Rack
//
//  Created by hyperlink on 18/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import PeekView

class DiscoverVC: BaseViewController {

    //MARK:- Outlet
    
    @IBOutlet weak var collectionView: UICollectionView!
    //------------------------------------------------------
    
    //MARK:- Class Variable

    let colum : Float       = 3.0   ,spacing :Float         = 1.0
    var longGesture         = UILongPressGestureRecognizer()
    var delegate            : SearchTextDelegate?
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
        
//        NotificationCenter.default.removeObserver(kNotificationItemDetailUpdate)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        
//        if #available(iOS 10.0, *) {
//            collectionView?.prefetchDataSource = self
//        }
        
        longGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        longGesture.minimumPressDuration = kMinimumPressDuration
        collectionView.addGestureRecognizer(longGesture)
        
        self.delegate = self
        
        //setup for autoPullTorefresh and paggination
        self.setupPullToRefresh()
         self.navigationController?.customize()
        
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.collectionView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.collectionView.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
        
        self.callApiFromPage1()
        
    }
    
    func setupPullToRefresh() {
        
        self.collectionView.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
            
            //Call API
            
            self.page = 1
            let requestModel = RequestModel()
            requestModel.search_flag = "discover"
            requestModel.page = String(format: "%d", (self.page))
            
                //call API for top data
                self.callSearchAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                    scrollView?.ins_endPullToRefresh()
                    
                    if isSuccess {
                        self.arrayItemData = ItemModel.modelsFromDictionaryArray(array: (jsonResponse?.arrayValue)!)
                        
                        /*_ = self.arrayItemData.filter({ (obj : ItemModel) -> Bool in
                         
                         weak var img : UIImageView? = UIImageView()
                         img?.setImageWithDownload(obj.image.url())
                         
                         return true
                         })*/
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                        
                    }
                })
            
        }
        
        //bottom
        self.collectionView.ins_addInfinityScroll(withHeight: 0.1) { (scrollView) in
            
            func callSearch() {
                //Call API
                let requestModel = RequestModel()
                requestModel.search_flag = "discover"
                requestModel.page = String(format: "%d", (self.page))
                
                //call API for bottom data
                self.callSearchAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                    scrollView?.ins_endInfinityScroll(withStoppingContentOffset: true)
                    
                    if isSuccess {
                        let newData = ItemModel.modelsFromDictionaryArray(array: (jsonResponse?.arrayValue)!)
                        
                        self.arrayItemData .append(contentsOf: newData)
                        
                        /*
                         To download image out of visible cell's as per client's requirement, this code is implemented
 
                        
                        _ = newData.filter({ (obj : ItemModel) -> Bool in
                            
                            weak var img : UIImageView? = UIImageView()
                            img?.setImageWithDownload(obj.image.url())
                            
                            return true
                        })
                         */
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
//                        callSearch()
                    }
                })
            }
            
            if self.isWSCalling {
                self.isWSCalling = false
                callSearch()
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
    
    func callApiFromPage1() {
        self.page = 1
        self.arrayItemData.removeAll()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            
            //callAPI for first data
            self.collectionView.ins_beginInfinityScroll()
        }
    }

    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationItemDataUpdate(_ notification : Notification) {
        /* Notification Post Method call
         1. Comment VC add msg
         */
        
        //        //print("============Notification Method Called=================")
        //        //print(notification.object!)
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        let notiItemData = jsonData
        //change main data
        arrayItemData = arrayItemData.map { (objFollow : ItemModel) -> ItemModel in
            
            if objFollow.itemId == notiItemData.itemId {
                return notiItemData
            } else {
                return objFollow
            }
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }, completion: { (Bool) in
            
        })
        
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callSearchAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : user/search
         
         Parameter   : search_flag[discover,people,hashtag,brand,item]
         
         Optional    : search_value,page
         
         Comment     : This api will used for searching.
         
         ==============================
         */
        
        APICall.shared.POST(strURL: kMethodSearch
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
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
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if self.arrayItemData.isEmpty {
            self.callApiFromPage1()
        }
        
        self.collectionView.reloadData()
        /*
         Where there is search bar first responder on discover, move the tab to next tab
         As per client's reqirement
         */
        /*if self.parent?.parent is SearchVC {
            let searchVC = (self.parent?.parent as! SearchVC)
            let searchBar = searchVC.searchBar
            
            if (searchBar?.isFirstResponder)! {
                searchVC.pageviewController.setViewControllers([searchVC.arrayControllers[1]], direction: .forward, animated: false, completion: nil)
                searchVC._selectTab(tabIndex: 1, animate: true)
                searchVC.didChangeTabToIndex(searchVC.self, index: 1, fromTabIndex: 0)
            }
        }*/
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
}
extension DiscoverVC : PSCollectinViewDelegateDataSource {
    
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
        
        if indexPath.row == arrayItemData.count - 10 {
            self.collectionView.ins_beginInfinityScroll()
        }
        
    
        cell.img.setImageWithDownload(objAtIndex.thumbnail.url())

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row < arrayItemData.count {
            let objAtIndex = arrayItemData[indexPath.row]
            if let cell = cell as? CustomImagePickerCell {
                cell.img.setImageWithDownload(objAtIndex.thumbnail.url())
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ItemDetailVC") as! RackDetailVC
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "DiscoverListVC") as! DiscoverListVC
        vc.selectedIndexPath = indexPath
        vc.arrayItemData = self.arrayItemData
        vc.dictFromParent = arrayItemData[indexPath.row]
        vc.itemsAdded = { (arrItems) in
            self.arrayItemData = arrItems
            self.collectionView.reloadData()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
     func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // This will cancel all unfinished downloading task when the cell disappearing.
//        (cell as! CustomImagePickerCell).img.kf.cancelDownloadTask()
    }
    
}

extension DiscoverVC : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {

        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

    }

    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

    }
    
}

extension DiscoverVC : SearchTextDelegate {
    func searchTextDelegateMethod(_ searchBar: UISearchBar) {
        //print(" DisCover VC :- \(searchBar.text!)")
    }
}
//
//extension DiscoverVC: UICollectionViewDataSourcePrefetching {
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        let urls = indexPaths.flatMap {
//            arrayItemData[$0.row].image.url()
//        }
//        ImagePrefetcher(urls: urls).start()
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
//        let urls = indexPaths.flatMap {
//            arrayItemData[$0.row].image.url()
//        }
//        ImagePrefetcher(urls: urls).stop()
//    }
//}

