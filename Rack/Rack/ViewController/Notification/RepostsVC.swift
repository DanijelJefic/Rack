//  RepostsVC.swift
//  Rack
//  Created by Gurpreet Singh on 25/02/18.
//  Copyright © 2018 Hyperlink. All rights reserved.

import UIKit
class RepostsVC: UIViewController {
    @IBOutlet weak var tblNotification: UITableView!
    @IBOutlet weak var tableViwHeaderView: UIView!
    
    var tableData : [RepostNotificationModel] = []
    var page                : Int = 1
    var isWSCalling         : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppColor.primaryTheme
        self.tblNotification.backgroundColor = AppColor.primaryTheme
        self.navigationController?.navigationBar.barTintColor = AppColor.primaryTheme
        self.navigationController?.navigationBar.isTranslucent = false
        setUpView()
        self.navigationController?.customize()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "Reposts", isSwipeBack: true)
        self.perform(#selector(self.addLoaderWithDelay), with: nil, afterDelay: 0.2)
        //Google Analytics
        let action = "\(UserModel.currentUser.displayName!) view Reposts"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: "Reposts")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "Reposts", isSwipeBack: true)

    }
    //MARK:- Action Method
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
//MARK:- Custom Method

func setUpView() {
    //Navigation Bar setup
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    tblNotification.tableFooterView = UIView()
    tblNotification.estimatedRowHeight = 95
    tblNotification.rowHeight = UITableViewAutomaticDimension
    self.navigationController?.customize()
    //setUp for pull to refresh
    self.setupPullToRefresh()
    self.navigationController?.customize()
    let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
    self.tblNotification.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
    infinityIndicator.startAnimating()
    self.callApi()
}

func addLoaderWithDelay() {
    let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
    self.tblNotification.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
    self.tblNotification.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
}

func callApi() {
    guard let _  = self.tblNotification else {
        return
    }
    self.tblNotification.ins_beginPullToRefresh()
}

func setupPullToRefresh() {
    
    //top
    self.tblNotification.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
        let requestModel = RequestModel()
        requestModel.repost_array = []
        //call API for top data
        self.callNotificationListAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
            self.tblNotification.ins_endPullToRefresh()
            if isSuccess {
                if self.tblNotification.tableHeaderView != self.tableViwHeaderView {
                    self.tblNotification.tableHeaderView = self.tableViwHeaderView
                }
                self.tableData = []
                for repost in jsonResponse!.arrayValue{
                    let  repostNotif : RepostNotificationModel = RepostNotificationModel(fromJson:repost)
                    self.tableData.append(repostNotif)
                }
                guard self.tblNotification != nil else {
                    return
                }
                self.tblNotification.reloadData()
            } else {
            }
        })
    }
    
    //bottom
    self.tblNotification.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
        let requestModel = RequestModel()
        requestModel.repost_array = self.tableData
        //call API for bottom data
        self.callNotificationListAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
            scrollView?.ins_endInfinityScroll(withStoppingContentOffset: true)
            if self.isWSCalling {
                self.isWSCalling = false
                if isSuccess {
                    for repost in jsonResponse!.arrayValue{
                        let  repostNotif : RepostNotificationModel = RepostNotificationModel(fromJson:repost)
                        self.tableData.append(repostNotif)
                    }
                    guard self.tblNotification != nil else {
                        return
                    }
                    self.tblNotification.reloadData()
                } else {
                }
            }
        })
    }
}
    
    //MARK: - API Call
    
    func callNotificationListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/reposts_list
         
         Parameter   : start
         
        Comment     : This api will used for user get the reposts list
         
         ==============================
         
         */
        
        APICall.shared.PUT(strURL: kMethodRepostNotificationList
            , parameter: requestModel.toDictionary()
            , withErrorAlert : false
        ) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            self.isWSCalling = true
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                switch(status) {
                case success:
                    self.page = self.page + 1
                    block(true,response[kData])
                    break
                case noDataFound:
                 self.tblNotification.ins_removeInfinityScroll()
                    if self.page == 1 {
                        GFunction.shared.showPopup(with: response[kMessage].stringValue, forTime: 2, withComplition: {
                        }, andViewController: self)
                    }
                    block(false,nil)
                    break
                default:
                self.tblNotification.ins_removeInfinityScroll()
                    block(false,nil)
                    break
                }
            } else {
                block(false,nil)
            }
        }
    }
}

extension RepostsVC : PSTableDelegateDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellHeight = 91.0
        return CGFloat(cellHeight)
    }
    
    func addBoldText(_ fullString: NSString, boldPartOfString: String, fontSize: CGFloat) -> NSAttributedString {
        let nonBoldFontAttribute = [NSFontAttributeName: UIFont.applyRegular(fontSize: fontSize)]
        let boldFontAttribute = [NSFontAttributeName: UIFont.applyBold(fontSize: fontSize)]
        let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
        boldString.addAttributes(boldFontAttribute, range: fullString.range(of: boldPartOfString as String))
        return boldString
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "repostsCell") as! RepostCell
            cell.selectionStyle = .none
        cell.configureRepost(repost: self.tableData[indexPath.row], and: self)
        
            return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repost = self.tableData[indexPath.row]
        let item : ItemModel = ItemModel()
        item.itemId = repost.itemId
        item.rackCell = "normalCell"
        item.userId = UserModel.currentUser.userId
        item.commentData = []
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ItemDetailVC") as! RackDetailVC
        vc.dictFromParent = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
  public func totalCountButtonClicked(_ sender : UIButton) {
    var cell = sender.superview?.superview as! RepostCell
    if cell .isKind(of: UITableView.self)  {
        cell = sender.superview as! RepostCell
    }
    let indexPath = tblNotification.indexPath(for: cell)
    let objRepostersVC = secondStoryBoard.instantiateViewController(withIdentifier: "RepostersVC") as! RepostersVC
    objRepostersVC.dictFromParent = tableData[indexPath!.row]
    self.navigationController?.pushViewController(objRepostersVC, animated: true)
  }
 public func newCountButtonClicked(_ sender : UIButton) {
    var cell = sender.superview?.superview as! RepostCell
    if cell .isKind(of: UITableView.self)  {
        cell = sender.superview as! RepostCell
    }
    let indexPath = tblNotification.indexPath(for: cell)
    if tableData[indexPath!.row].recentRepostCount != "0" {
        let objRepostersVC = secondStoryBoard.instantiateViewController(withIdentifier: "RepostersVC") as! RepostersVC
        objRepostersVC.dictFromParent = tableData[indexPath!.row]
        objRepostersVC.isNew = 1
        self.navigationController?.pushViewController(objRepostersVC, animated: true)
    }

    }
}

class RepostCell: UITableViewCell {
    @IBOutlet weak var totalCountButton: UIButton!
        @IBOutlet weak var newCountButton: UIButton!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var newRepostLabel: UILabel!
    @IBOutlet weak var totalRepostLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configureRepost(repost:RepostNotificationModel, and viewController : RepostsVC) {
        itemImageView.setImageWithDownload(repost.image.url(), withIndicator: true)
        newRepostLabel.text = repost.recentRepostCount
        totalRepostLabel.text = repost.repostCount
        totalCountButton.removeTarget(nil, action: nil, for: .allEvents)
        newCountButton.removeTarget(nil, action: nil, for: .allEvents)
        totalCountButton.addTarget(viewController, action: #selector(RepostsVC.totalCountButtonClicked(_:)), for: .touchUpInside)
        newCountButton.addTarget(viewController, action: #selector(RepostsVC.newCountButtonClicked(_:)), for: .touchUpInside)

    }
    
}




