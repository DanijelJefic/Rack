//
//  RackFolderListVC.swift
//  Rack
//
//  Created by GS Bit Labs on 2/2/18.
//  Copyright © 2018 Hyperlink. All rights reserved.
//

import UIKit
import PeekView

class RackFolderListVC: UIViewController {
    let activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var collectionView: UICollectionView!
    //------------------------------------------------------
    //MARK:- Class Variable
    var headerView               : FolderListBanner!
    var headerButton:UIButton                       = UIButton()
    var dropDownImage:UIImageView                   = UIImageView()
    var constant                 : CGFloat = 0.0
    let colum                    : Float = 3.0,spacing :Float = 1.0
    //To manage navigation bar button
    var fromPage                                    = PageFrom.defaultScreen
    var tapGesture                                  = UITapGestureRecognizer()
    var longGesture                                 = UILongPressGestureRecognizer()
    var viewType                                    = profileViewType.me
    var dictFromParent            : ItemModel       = ItemModel()
    var userData                  : UserModel?      = nil
    var arrayItemData             : [ItemModel]     = []
    var arrayTempItemData         : [ItemModel]     = []
    var page                      : Int = 1
    var isWSCalling               : Bool            = true
    
    typealias RackViewUpdate = (String)->Void
    var rackViewUpdate:RackViewUpdate!
    //------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.isHidden = true
        self.view.backgroundColor = AppColor.primaryTheme
        self.collectionView.backgroundColor = AppColor.primaryTheme
        self.setUpView()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.setUpData()
        }

        self.collectionView.register(UINib(nibName: "FolderListBanner", bundle: nil), forCellWithReuseIdentifier: "headerCell")
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.activityIndicatorView.frame = self.view.bounds
        
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: BarButton(title: dictFromParent.rackViews, image: #imageLiteral(resourceName: "iconViews")), title: nil, isSwipeBack: true)

        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.collectionView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.collectionView.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: BarButton(title: dictFromParent.rackViews, image: #imageLiteral(resourceName: "iconViews")), title: nil, isSwipeBack: true)
    }
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(kNotificationItemDetailDelete)
        NotificationCenter.default.removeObserver(kNotificationRackWantEdit)
        NotificationCenter.default.removeObserver(kNotificationNewPostAdded)
        NotificationCenter.default.removeObserver(kNotificationRackList)
    }
    
    //MARK:- Custom Method
    
    func setUpView() {
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        let rackName = self.dictFromParent.rackName
        
        switch self.viewType{
        case .me:
            headerButton.setTitle(rackName! + " ", for: .normal)
            headerButton.setImage(UIImage(named:"pencil_icon"), for: .normal)
            headerButton.isUserInteractionEnabled = true
        case .other:
            headerButton.setTitle(rackName!, for: .normal)
            headerButton.isUserInteractionEnabled = false
        }
        
        headerButton.frame = CGRect(x:0,y:0,width:200,height:18)
        headerButton.titleLabel?.font = UIFont.applyRegular(fontSize: 15.5)
        headerButton.setTitleColor(UIColor.black, for: .normal)
        headerButton.addTarget(self, action: #selector(editButtonClicked), for: .touchUpInside)
        headerButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        
        headerButton.imageView?.contentMode = .scaleAspectFit
        headerButton.imageView?.frame = CGRect(x: 0, y: 0, width: 5, height: 5)
        headerButton.semanticContentAttribute = .forceRightToLeft

        self.navigationItem.titleView = headerButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationItemDelete(_:)), name: NSNotification.Name(rawValue: kNotificationItemDetailDelete), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationEditItemDetails(_:)), name: NSNotification.Name(rawValue: kNotificationRackWantEdit), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationEditItemDetails(_:)), name: NSNotification.Name(rawValue: kNotificationNewPostAdded), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationItemDelete(_:)), name: NSNotification.Name(rawValue: kNotificationRackList), object: nil)

        
        self.navigationController?.customize()
        //add notification for profile update
        
        self.activityIndicatorView.frame = self.view.bounds
        self.activityIndicatorView.activityIndicatorViewStyle = .gray
        self.view.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        
        self.setupPullToRefresh()
        
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.collectionView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.collectionView.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
        
    }
    
    func editButtonClicked()  {
        let objEditRackFolderVC:EditRackFolderVC = storyboard?.instantiateViewController(withIdentifier: "EditRackFolderVC") as! EditRackFolderVC
        objEditRackFolderVC.arrayItemData = self.arrayTempItemData
        objEditRackFolderVC.dictFromParent = self.dictFromParent
        objEditRackFolderVC.completion = {() in
            self.navigationController?.popToRootViewController(animated: true)
        }
        let navigationController:UINavigationController = UINavigationController(rootViewController:objEditRackFolderVC )
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func setUpData() {
        
        //to check user current User come from other user profile.
        if self.userData?.userId == UserModel.currentUser.userId && (fromPage != .defaultScreen) {
            viewType = .me
            fromPage = .fromSettingPage // to setup navigation bar button
        }
        
        self.page = 1
        let requestModel = RequestModel()
        requestModel.user_id = self.userData?.userId
        requestModel.rack_id = self.dictFromParent.rackId
        requestModel.page = String(format: "%d", (self.page))
        self.callRackListAPI(requestModel, withCompletion: { (isSuccess) in
            
        })
        
    }
    
    func setupPullToRefresh() {
        self.activityIndicatorView.frame = self.view.bounds

        self.collectionView.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
            
            self.page = 1
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            requestModel.rack_id = self.dictFromParent.rackId
            requestModel.page = String(format: "%d", (self.page))
            self.callRackListAPI(requestModel, withCompletion: { (isSuccess) in
                scrollView?.ins_endPullToRefresh()
            })
            
        }
        
        //bottom
        self.collectionView.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            
            if self.isWSCalling {
                self.isWSCalling = false
                
                let requestModel = RequestModel()
                requestModel.user_id = self.userData?.userId
                requestModel.rack_id = self.dictFromParent.rackId
                requestModel.page = String(format: "%d", (self.page))
                self.callRackListAPI(requestModel, withCompletion: { (isSuccess) in
                    
                })
            }
            
        }
        
    }
    
    func notificationItemDelete(_ notification : Notification) {
        /* Notification Post Method call
         1. Update Want List
         2. Add new item
         */
        
        switch viewType {
        case .me:
            
            var notiWantData = ItemModel()
            
            if let jsonData   = notification.object as? JSON {
                notiWantData = ItemModel(fromJson: jsonData)
            } else if let jsonData   = notification.object as? ItemModel {
                notiWantData = jsonData
            } else {
                return
            }
            
//            let notiUpdateDataRackName = notiWantData.rackData.rackName
//            let dictFromParentRackName = dictFromParent.rackName
//            if notiWantData.userId == userData?.userId && notiUpdateDataRackName == dictFromParentRackName {
//                return
//            }
            
            if dictFromParent.rackItemId == notiWantData.itemId && !arrayItemData.isEmpty {
                dictFromParent.rackItemId = arrayItemData[0].itemId
                dictFromParent.rackImage = arrayItemData[0].image
                self.arrayItemData = self.arrayItemData.filter({(obj: ItemModel) -> Bool in
                    if obj.itemId != arrayItemData[0].itemId {
                        return true
                    }else{
                        return false
                    }
                })
                arrayTempItemData = self.arrayItemData
                headerView = nil
                collectionView.reloadData()
                
            }else{
                self.arrayItemData = self.arrayItemData.filter({(obj: ItemModel) -> Bool in
                    if obj.itemId != notiWantData.itemId {
                        return true
                    }else{
                        return false
                    }
                })
                
                arrayTempItemData = self.arrayItemData
                collectionView.reloadData()
            }
            
            break
        case .other:
            
            break
        }
        
    }
    
    func notificationEditItemDetails(_ notification : Notification) {
        /*
         Item Details update
         */
        
        var notiUpdateData = ItemModel()
        
        if let jsonData   = notification.object as? JSON {
            notiUpdateData = ItemModel(fromJson: jsonData)
        } else if let jsonData   = notification.object as? ItemModel {
            notiUpdateData = jsonData
        } else {
            return
        }
        
        let notiUpdateDataRackName = notiUpdateData.rackName
        let dictFromParentRackName = dictFromParent.rackName
        if notiUpdateData.userId == userData?.userId && notiUpdateDataRackName == dictFromParentRackName && notiUpdateData.pinImage == "1" {
            dictFromParent.rackItemId = notiUpdateData.itemId
            dictFromParent.rackImage = notiUpdateData.image
            dictFromParent.rackUpdated = notiUpdateData.insertdate
            headerView = nil
            collectionView.reloadData()
            
        }else if notiUpdateData.userId == userData?.userId && notiUpdateDataRackName != dictFromParentRackName {
            return
        }
        
        switch viewType {
        case .me:
            
            self.page = 1
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            requestModel.rack_id = self.dictFromParent.rackId
            requestModel.page = String(format: "%d", (self.page))
            self.callRackListAPI(requestModel, withCompletion: { (isSuccess) in
                
            })
            
            break
        case .other:
            
            break
        }
        
    }

    func callRackListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/rackdetail
         
         Parameter   : user_id, rack_id
         
         Optional    : page
         
         Comment     : This api will used for fetch User Racks
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodRackDetail
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            self.activityIndicatorView.stopAnimating()
            self.isWSCalling = true
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                switch(status) {
                case success:
                    
                    self.dictFromParent.rackViews = response["view_count"].stringValue
                    _ = self.addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: BarButton(title: self.dictFromParent.rackViews, image: #imageLiteral(resourceName: "iconViews")), title: nil, isSwipeBack: true)
                    
                    if self.rackViewUpdate != nil {
                        self.rackViewUpdate(self.dictFromParent.rackViews)
                    }
                    
                    if self.page == 1{
                        self.arrayItemData.removeAll()
                        self.arrayTempItemData.removeAll()
                    }
                    
                    let newData = ItemModel.modelsFromDictionaryArray(array: response[kData].arrayValue)
                    self.arrayTempItemData.append(contentsOf: newData)
                    self.arrayItemData = self.arrayTempItemData.filter({(obj: ItemModel) -> Bool in
                        if obj.itemId != self.dictFromParent.rackItemId {
                            return true
                        }else{
                            return false
                        }
                    })
                    CATransaction.begin()
                    CATransaction.setCompletionBlock { () -> Void in
                        /*wait for endRefreshing animation to complete
                         before reloadData so table view does not flicker to top
                         then continue endRefreshing animation */
                        
                        self.collectionView.reloadData()
                    }
                    self.collectionView.ins_endInfinityScroll(withStoppingContentOffset: true)
                    CATransaction.commit()
                    
                    self.collectionView.isHidden = false
                    self.page = (self.page) + 1
                    
                    block(true)
                    break
                    
                default:
                    
                    //stop pagination
                    if self.page == 1{
                        self.arrayItemData.removeAll()
                        CATransaction.begin()
                        CATransaction.setCompletionBlock { () -> Void in
                            /*wait for endRefreshing animation to complete
                             before reloadData so table view does not flicker to top
                             then continue endRefreshing animation */
                            self.collectionView.reloadData()
                        }
                    }
                    
                    block(false)
                    break
                    
                }
            } else {
                
                self.collectionView.ins_endInfinityScroll(withStoppingContentOffset: true)
                block(false)
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - CollectionView Delegate DataSource -
extension RackFolderListVC : PSCollectinViewDelegateDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: kScreenWidth, height: kScreenWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if headerView == nil {
            
            if kind == UICollectionElementKindSectionHeader {
                let nib = UINib(nibName: "FolderListBanner", bundle: nil)
                collectionView.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: "headerCell")
                
                headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath) as! FolderListBanner
                
                let dateFormatter = DateFormatter()
                dateFormatter.formatterBehavior = .behavior10_4
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                
                let dateString = dictFromParent.rackUpdated
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                var date = dateFormatter.date(from: dateString!)
                
                if date == nil{
                    date = Date()
                }
                
                dateFormatter.dateFormat = "d MMM yyyy"
                let currentDate = dateFormatter.string(from: date!)
                
                headerView.setUpData(_image: dictFromParent.rackImage, _timeStamp: currentDate)
                headerView.rackPinButton.addTarget(self, action: #selector(didTapOnRackPinImage(_:)), for: .touchUpInside)
                
            }
            
        }
        return headerView
        
    }
    
    func didTapOnRackPinImage(_ sender: UIButton) {
        
        let objRackDetailVC = secondStoryBoard.instantiateViewController(withIdentifier: "ItemDetailVC") as? RackDetailVC
        objRackDetailVC?.isRackFolder    = true
        objRackDetailVC?.rackFolderCount = self.arrayTempItemData.count
        self.dictFromParent.itemId      = self.dictFromParent.rackItemId
        objRackDetailVC?.dictFromParent  = self.dictFromParent        
        
 self.navigationController?.pushViewController(objRackDetailVC!, animated: true)
        
    }
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RackFolderListCell", for: indexPath) as! RackFolderListCell
        cell.image.contentMode = .scaleAspectFill
        cell.image.clipsToBounds = true
        cell.image.setImageWithDownload(objAtIndex.thumbnail.url())
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        autoreleasepool { 
           let objRackDetailVC = secondStoryBoard.instantiateViewController(withIdentifier: "ItemDetailVC") as? RackDetailVC
            objRackDetailVC?.dictFromParent = self.arrayItemData[indexPath.row]
         self.navigationController?.pushViewController(objRackDetailVC!, animated:true)
        }
    }
   
}

class RackFolderListCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var selectedView: UIView!
    
    override func awakeFromNib() {
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
    }
    
}
