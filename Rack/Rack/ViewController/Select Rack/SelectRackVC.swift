//
//  SelectRackVC.swift
//  Rack
//
//  Created by hyperlink on 02/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

protocol ChooseRectDelegate {
    
    func getSelectedReckDetail(data : Dictionary<String,Any>);
}

class SelectRackVC: UIViewController {

    //MARK:- Outlet
    @IBOutlet var carousel : iCarousel!
    @IBOutlet weak var pageControl: UIPageControl!
    //------------------------------------------------------

    
    //MARK:- Class Variable
    
    var arrayWardrobe : [WardrobesModel] = []
    var delegate : ChooseRectDelegate?
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

        carousel.backgroundColor = UIColor.clear
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = iCarouselTypeRotary

        
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = AppColor.secondaryTheme
        pageControl.currentPageIndicatorTintColor = UIColor.black

        carousel.reloadData()
        
        self.callWardrobeListAPI(RequestModel())
        self.navigationController?.customize()
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callWardrobeListAPI(_ requestModel : RequestModel) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/wardrobes_list
         
         Parameter   :
         
         Optional    : page
         
         Comment     : This api will display the wardrobes list.
         
         
         ==============================
         
         */
        
       
        APICall.shared.GET(strURL: kMethodWardrobesList
        , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int, error : Error?) in

            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                
                switch(status) {
                    
                case success:
                    self.arrayWardrobe = WardrobesModel.modelsFromDictionaryArray(array: response[kData].arrayValue)
                    self.pageControl.numberOfPages = self.arrayWardrobe.count
                    self.pageControl.currentPage = 0
                    self.carousel.reloadData()
                    
                    //Google Analytics
                    
                    let category = "UI"
                    let action = "\(UserModel.currentUser.displayName!) changed his rack"
                    let lable = ""
                    let screenName = "Settings - Select Rack"
                    googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                    
                    //Google Analytics
                    break
                    
                default:
                    break
                }
            } else {
                AlertManager.shared.showPopUpAlert("", message: error?.localizedDescription, forTime: 2.0, completionBlock: { (Int) in
                })
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
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        //Google Analytics
        
        let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: self.title)
        
        //Google Analytics
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}

extension SelectRackVC : iCarouselDelegate,iCarouselDataSource {
    
    func numberOfItems(in carousel: iCarousel!) -> UInt {
        return UInt(self.arrayWardrobe.count)
    }

    func carousel(_ carousel: iCarousel!, viewForItemAt index: UInt, reusing view: UIView!) -> UIView! {
        
        var itemView: UIImageView
        
        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
            itemView = view

        } else {
            //don't do anything specific to the index within
            //this `if ... else` statement because the view will be
            //recycled and used with other index values later
            

            let objAtIndex = self.arrayWardrobe[Int(index)]
            
            itemView = UIImageView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(250 * kHeightAspectRasio), height: CGFloat(250 * kHeightAspectRasio)))
            itemView.setImageWithDownload(objAtIndex.image.url())
            itemView.contentMode = .scaleAspectFill
            itemView.clipsToBounds = true
            
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        
        return itemView
        
    }
    
    func carouselItemWidth(_ carousel: iCarousel!) -> CGFloat {
        return 250 * kHeightAspectRasio
    }
    
    func carousel(_ carousel: iCarousel!, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        switch option {
        case iCarouselOptionFadeMin:
            return 0
        case iCarouselOptionFadeMax:
            return 0
        case iCarouselOptionFadeRange:
            return 2
        default:
            return value
        }
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel!) {
        pageControl.currentPage = carousel.currentItemIndex

//        if let _ = self.delegate {
//            self.delegate?.getSelectedReckDetail(data: arrayData[carousel.currentItemIndex])
//        }
    }
    
    func carouselDidScroll(_ carousel: iCarousel!) {
        pageControl.currentPage = carousel.currentItemIndex
    }
    
}
