//
//  PostImageAddTagVC.swift
//  Rack
//
//  Created by hyperlink on 29/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class PostImageAddTagVC: UIViewController {

    let tagLabel:UILabel = UILabel()
    let brandsButton    = UIButton()
    let usersButton = UIButton()
    let linksButton = UIButton()
    let buttonContainerView:UIView = UIView()
    //MARK:- Outlet
    @IBOutlet var imgPost : UIImageView!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var postImage : UIImage = UIImage()
    var imageTagType : TagType = TagType.none
    var delegate    : SearchTagDelegate?
    var arrayTag : [PSTagView] = []
    
    var users:[PSTagView] = []
    var brands:[PSTagView] = []
    var links:[PSTagView] = []
    
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
    
    func brandsButtonAction(){
        if self.brandsButton.isSelected {
            return
        }
        
        self.imageTagType = .tagBrand
        self.brandsButton.isSelected = true
        self.usersButton.isSelected = false
        self.linksButton.isSelected = false
        self.usersButton.backgroundColor = UIColor.white
        self.linksButton.backgroundColor = UIColor.white
        self.brandsButton.backgroundColor = UIColor(red:54.0/255.0,green:54.0/255.0,blue:54.0/255.0,alpha:1.0)
        
        for subview in self.users {
            subview.removeFromSuperview()
        }
        
        for subview in self.links {
              subview.removeFromSuperview()
        }
        
        for subview in self.brands {
            imgPost.addSubview(subview)
        }
        
        UserDefaults.standard.set(1, forKey: "selectedButtonTag")
    }
    
    func usersButtonAction(){
        if self.usersButton.isSelected {
            return
        }
        self.imageTagType = .tagPeople
        self.brandsButton.isSelected = false
        self.usersButton.isSelected = true
        self.linksButton.isSelected = false
        self.brandsButton.backgroundColor = UIColor.white
        self.linksButton.backgroundColor = UIColor.white
        self.usersButton.backgroundColor = UIColor(red:54.0/255.0,green:54.0/255.0,blue:54.0/255.0,alpha:1.0)
        
        for subview in self.brands {
            subview.removeFromSuperview()
        }
        
        for subview in self.links {
            subview.removeFromSuperview()
        }
        
        for subview in self.users {
            imgPost.addSubview(subview)
        }
        
        UserDefaults.standard.set(2, forKey: "selectedButtonTag")
    }
    
    func linksButtonAction(){
        if self.linksButton.isSelected {
            return
        }
        self.imageTagType = .addLink
        self.brandsButton.isSelected = false
        self.usersButton.isSelected = false
        self.linksButton.isSelected = true
        self.brandsButton.backgroundColor = UIColor.white
        self.usersButton.backgroundColor = UIColor.white
        self.linksButton.backgroundColor = UIColor(red:54.0/255.0,green:54.0/255.0,blue:54.0/255.0,alpha:1.0)
        
        for subview in self.brands {
            subview.removeFromSuperview()
        }
        
        for subview in self.users {
            subview.removeFromSuperview()
        }
        
        for subview in self.links {
            imgPost.addSubview(subview)
        }
        
        UserDefaults.standard.set(3, forKey: "selectedButtonTag")
    }
    
    func setUpView() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnImage(_:)))
        tapGesture.numberOfTapsRequired = 1
        imgPost.isUserInteractionEnabled = true
        imgPost.addGestureRecognizer(tapGesture)
        imgPost.clipsToBounds = true
        
        imgPost.image = self.postImage.imageScale(scaledToWidth: kScreenWidth)
        
        
       
        buttonContainerView.frame = CGRect(x:0,y:imgPost.frame.origin.y+imgPost.frame.size.height+20,width:self.view.frame.size.width,height:36.0)
        buttonContainerView.backgroundColor = UIColor.white
        self.view.addSubview(buttonContainerView)
        buttonContainerView.layer.shadowColor = UIColor.black.cgColor
        buttonContainerView.layer.shadowRadius = 1.5
        buttonContainerView.layer.shadowOpacity = 0.2
        buttonContainerView.layer.shadowOffset = CGSize(width:0,height:1.0)
        
        self.imageTagType = .tagBrand
        brandsButton.setTitle("Tag Brand (0)", for: .normal)
        brandsButton.backgroundColor = UIColor(red:54.0/255.0,green:54.0/255.0,blue:54.0/255.0,alpha:1.0)
        brandsButton.setTitleColor(UIColor.black, for: .normal)
        brandsButton.setTitleColor(UIColor.white, for: .selected)
        brandsButton.addTarget(self, action: #selector(brandsButtonAction), for: .touchUpInside)
        brandsButton.titleLabel?.font = UIFont.applyRegular(fontSize: 12.0)
        brandsButton.frame  =  CGRect(x:0,y:0.0,width:self.view.frame.size.width/3.0,height:36.0)
        buttonContainerView.addSubview(brandsButton)
        brandsButton.isSelected = true
        
        //self.imageTagType = .tagPeople
        usersButton.setTitle("Tag People (0)", for: .normal)
        usersButton.addTarget(self, action: #selector(usersButtonAction), for: .touchUpInside)
//        usersButton.backgroundColor = UIColor(red:54.0/255.0,green:54.0/255.0,blue:54.0/255.0,alpha:1.0)
        usersButton.setTitleColor(UIColor.black, for: .normal)
        usersButton.setTitleColor(UIColor.white, for: .selected)
        usersButton.titleLabel?.font = UIFont.applyRegular(fontSize: 12.0)
        usersButton.frame  =  CGRect(x:self.view.frame.size.width/3.0,y:0.0,width:self.view.frame.size.width/3.0,height:36.0)
        buttonContainerView.addSubview(usersButton)
//        usersButton.isSelected = true
        
        linksButton.setTitle("Add Links (0)", for: .normal)
        linksButton.addTarget(self, action: #selector(linksButtonAction), for: .touchUpInside)
        linksButton.setTitleColor(UIColor.black, for: .normal)
        linksButton.setTitleColor(UIColor.white, for: .selected)
        linksButton.titleLabel?.font = UIFont.applyRegular(fontSize: 12.0)
        linksButton.frame  =  CGRect(x:2*self.view.frame.size.width/3.0,y:0.0,width:self.view.frame.size.width/3.0,height:36.0)
        buttonContainerView.addSubview(linksButton)
        
        
        tagLabel.text = "Tap photo to start tagging."
        tagLabel.textAlignment = .center
        tagLabel.font = UIFont.applyRegular(fontSize: 15.0)
        tagLabel.frame = CGRect(x:0,y:buttonContainerView.frame.origin.y+buttonContainerView.frame.size.height-40.0,width:self.view.frame.size.width,height:self.view.frame.size.height-(buttonContainerView.frame.origin.y+buttonContainerView.frame.size.height))
        self.view.addSubview(tagLabel)
        
        //Tag setup for editing
        for tagView in arrayTag {
            self.imgPost.addSubview(tagView)
        }
        
         self.navigationController?.customize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
          buttonContainerView.frame = CGRect(x:0,y:imgPost.frame.origin.y+imgPost.frame.size.height,width:self.view.frame.size.width,height:36.0)
            tagLabel.frame = CGRect(x:0,y:buttonContainerView.frame.origin.y+buttonContainerView.frame.size.height,width:self.view.frame.size.width,height:self.view.frame.size.height-(buttonContainerView.frame.origin.y+buttonContainerView.frame.size.height))
    }
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    func leftButtonClicked() {
 
    }
    
    func rightButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func tapOnImage(_ gesture : UITapGestureRecognizer) {
     
        if let imgView = gesture.view  as? UIImageView {
           
            switch imageTagType {
            case .tagBrand , .tagItem , .addLink:
                
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchTagTextVC") as! SearchTagTextVC
                vc.imageTagType = self.imageTagType
                vc.tapLocation = gesture.location(in: imgView)
                vc.delegate = self
                self.navigationController!.pushViewController(vc, animated: true)
                break

            case .tagPeople:
                
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchPeopleTagVC") as! SearchPeopleTagVC
                vc.imageTagType = self.imageTagType
                vc.tapLocation = gesture.location(in: imgView)
                vc.delegate = self
                self.navigationController!.pushViewController(vc, animated: true)
                break
            
            default:
                //print("Default Once called...")
                break
            }

        }
    }
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppColor.primaryTheme
        self.imgPost.backgroundColor = AppColor.primaryTheme
        self.navigationController?.navigationBar.isTranslucent = false
        
        setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: nil, btnRight: BarButton(title: "Done"), title: "Tag Post", isSwipeBack: false)
    }

}
    //MARK:- SearchTagDelegate -
extension PostImageAddTagVC : SearchTagDelegate, PSTagViewDelDelegate {
    
    func tapOnDeleteDelegate(_ sender: PSTagView) {
        
        switch imageTagType {
        case .tagBrand , .tagItem:
            
            sender.removeFromSuperview()
            if brands.contains(sender) {
                if let index = brands.index(of: sender) {
                    brands.remove(at: index)
                }
            }
            
            self.brandsButton.setTitle(String(format:"Tag Brand (%i)",self.brands.count), for: .normal)
            
            break
            
        case .addLink:
            
            sender.removeFromSuperview()
            if links.contains(sender) {
                if let index = links.index(of: sender) {
                    links.remove(at: index)
                }
            }
            
            self.linksButton.setTitle(String(format:"Add Links (%i)",self.links.count), for: .normal)
            
            break
            
        case .tagPeople:
            
            sender.removeFromSuperview()
            if users.contains(sender) {
                if let index = users.index(of: sender) {
                    users.remove(at: index)
                }
            }
            
            self.usersButton.setTitle(String(format:"Tag People (%i)",self.users.count), for: .normal)
            
            break
        default:
            break
        }
        
        if self.delegate != nil {
            self.delegate?.searchTagDelegateMethod(imgPost.subviews,tagType:imageTagType)
        }
        
    }
    
    
    func searchTagDelegateMethod(_ tagDetail: Any, tagType : TagType?) {
        
        let dict = tagDetail as! Dictionary<String,Any>
        let tapLocation = dict["tapLocation"] as! CGPoint
        
        switch imageTagType {
        case .tagBrand , .tagItem:
         
            var jsonDict : Dictionary<String,Any> = dict 
            jsonDict["id"] = dict[kID]
            jsonDict["name"] = dict[kTitle]
            jsonDict["x_axis"] = tapLocation.x
            jsonDict["y_axis"] = tapLocation.y
            let tagDetail = SimpleTagModel(fromJson: JSON(jsonDict))

            let tag = PSTagView(tagName: dict[kTitle]! as! String , x: tapLocation.x, y: tapLocation.y, parrentView: imgPost,tagDetail: tagDetail)
            tag.delDelegate = self
            imgPost.addSubview(tag)

            self.brands.append(tag)
            
            self.brandsButton.setTitle(String(format:"Tag Brand (%i)",self.brands.count), for: .normal)
            
            if self.delegate != nil {
                self.delegate?.searchTagDelegateMethod(imgPost.subviews,tagType:imageTagType)
            }
            
            break

        case .addLink:

            var jsonDict : Dictionary<String,Any> = dict
            jsonDict["name"] = dict[kTitle]
            jsonDict["x_axis"] = tapLocation.x
            jsonDict["y_axis"] = tapLocation.y
            let tagDetail = LinkTagModel(fromJson: JSON(jsonDict))
            
            let tag = PSTagView(tagName: dict[kTitle]! as! String , x: tapLocation.x, y: tapLocation.y, parrentView: imgPost,tagDetail: tagDetail)
            tag.delDelegate = self
            imgPost.addSubview(tag)
            
            self.links.append(tag)
            
            self.linksButton.setTitle(String(format:"Add Links (%i)",self.links.count), for: .normal)
            
            if self.delegate != nil {
                self.delegate?.searchTagDelegateMethod(imgPost.subviews,tagType:imageTagType)
            }
            
            break

        case .tagPeople:

            var jsonDict : Dictionary<String,Any> = dict
            jsonDict["user_id"] = dict[kID]
            jsonDict["x_axis"] = tapLocation.x
            jsonDict["y_axis"] = tapLocation.y
            let tagDetail = PeopleTagModel(fromJson: JSON(jsonDict))
            
            let tag = PSTagView(tagName: dict[kTitle]! as! String , x: tapLocation.x, y: tapLocation.y, parrentView: imgPost,tagDetail: tagDetail)
            tag.delDelegate = self
            imgPost.addSubview(tag)
            
            self.users.append(tag)

            self.usersButton.setTitle(String(format:"Tag People (%i)",self.users.count), for: .normal)
            
            if self.delegate != nil {
                self.delegate?.searchTagDelegateMethod(imgPost.subviews,tagType:imageTagType)
            }
            
            break
        default:
            break
        }

    }
    
}
