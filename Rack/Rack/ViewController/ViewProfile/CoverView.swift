//  CoverView.swift
//  Rack
//  Created by GS Bit Labs on 1/23/18.
//  Copyright © 2018 Hyperlink. All rights reserved.

import Foundation
import UIKit
class CoverView: UICollectionReusableView {
    @IBOutlet weak var saparatorTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var coverCircleBackground: UIView!
    @IBOutlet weak var coverCircleButton:     UIButton!
    @IBOutlet weak var coverCircleIcon:       UIImageView!
    @IBOutlet weak var rackImage: UIImageView!
    @IBOutlet weak var subContainer: UIView!
    @IBOutlet weak var imgShadow: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgProfileBackground: UIView!
    @IBOutlet weak var imgVerifyOtherProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var btnRacked: UIButton!
    @IBOutlet weak var btnFollower: UIButton!
    @IBOutlet weak var btnFollowing: UIButton!
    @IBOutlet weak var lblRacked: UILabel!
    @IBOutlet weak var lblFollower: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblBio: UILabel!

    //------------------------------------------------------
    //MARK:- Class Variable
    var viewType = profileViewType.me
    var _guideView = GuideView()
    let attributedDict : Dictionary<String,Any> = [NSFontAttributeName:UIFont.applyBold(fontSize: 15.7)
        ,NSForegroundColorAttributeName : UIColor.black
    ]
    let defaultDict : Dictionary<String,Any> = [NSFontAttributeName:UIFont.applyBold(fontSize: 15.7)
        ,NSForegroundColorAttributeName : AppColor.text
    ]
    var userData = UserModel()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = AppColor.primaryTheme
        self.frame = CGRect(x: 0, y: 0,width:kScreenWidth, height: 20000)
        self.layoutIfNeeded()
        btnView.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 10.0), titleLabelColor: UIColor.black)

    }
    
    func setUpData(_ userData : UserModel?) {
        guard let userData = userData else {
            return
        }
        self.userData = userData
        imgProfile.alpha = 1.0
        imgVerifyOtherProfile.isHidden = false
        switch viewType {
        case .me:
            imgProfileBackground.layer.borderColor = UIColor.red.cgColor
            imgProfileBackground.layer.borderWidth = 0
            imgProfile.layer.borderWidth = 0
            if !self.userData.isUserVerify() {
                imgVerifyOtherProfile.isHidden = true
            }
            coverCircleIcon.image = _Image.shared.camera
            
            break
        case .other:
            didChangeStatusOfFollow(self.userData)
            if !self.userData.isUserVerify() {
                imgVerifyOtherProfile.isHidden = true
            }
            
            break
        }
        //MARK:- PENDING
        //Other Data setup
        lblName.text = self.userData.displayName
        btnView.setTitle(GFunction.shared.getProfileCount(self.userData.viewCount), for: .normal)
        
        imgProfile.image = nil
        rackImage.image = nil
        
        
        imgProfile.setImageWithDownload(self.userData.getUserProfile().url())
        if appDelegate().coverImage != nil && self.userData.userId == UserModel.currentUser.userId {
            rackImage.image = appDelegate().coverImage
        }else{
            rackImage.setImageWithDownload(self.userData.wardrobesImage.url(), withIndicator: true)
        }
        
        rackImage.contentMode = .scaleAspectFill
        //bio data set
        lblBio.text = self.userData.bioTxt
        lblBio.font = UIFont.applyRegular(fontSize: 14.0)
        self.saparatorTopConstaint.constant = 8;
        if lblBio.text == "" {
          self.saparatorTopConstaint.constant = -2;
        }
        //Attribute dynamic text setup
        let racked = GFunction.shared.getProfileCount(self.userData.rackCount!) == "" ? "0" : GFunction.shared.getProfileCount(self.userData.rackCount!)
        lblRacked.text = racked
        let follower = GFunction.shared.getProfileCount(self.userData.followersCount!) == "" ? "0" : GFunction.shared.getProfileCount(self.userData.followersCount!)
        lblFollower.text = follower
        let following = GFunction.shared.getProfileCount(self.userData.followingCount!) == "" ? "0" : GFunction.shared.getProfileCount(self.userData.followingCount!)
        lblFollowing.text = following
    }
    
    func didChangeStatusOfFollow(_ userData : UserModel?) {
        guard let userData = userData else {
            return
        }
        self.userData = userData
        if self.userData.isFollowing.lowercased() == FollowType.follow.rawValue {
            imgProfileBackground.layer.borderColor = UIColor.red.cgColor
            imgProfileBackground.layer.borderWidth = 0
            imgProfile.layer.borderWidth = 0
            coverCircleBackground.backgroundColor = UIColor.black
            _guideView.animationColor = .white
            coverCircleIcon.image = _Image.shared.follow
            
        } else if self.userData.isFollowing.lowercased() == FollowType.following.rawValue {
            imgProfileBackground.layer.borderColor = UIColor.white.cgColor
            imgProfileBackground.layer.borderWidth = 0
            imgProfile.layer.borderWidth = 0
            coverCircleBackground.backgroundColor = UIColor.white
            _guideView.animationColor = .darkGray
            coverCircleIcon.image = _Image.shared.following
            
        } else if self.userData.isFollowing.lowercased() == FollowType.requested.rawValue {
            imgProfileBackground.layer.borderColor = UIColor.red.cgColor
            imgProfileBackground.layer.borderWidth = 0
            imgProfile.layer.borderWidth = 0
            coverCircleBackground.backgroundColor = UIColor.white
            _guideView.animationColor = .darkGray
            coverCircleIcon.image = _Image.shared.requested
            
        }else if self.userData.isFollowing.lowercased() == FollowType.unblock.rawValue{
            imgProfileBackground.layer.borderColor = UIColor.red.cgColor
            imgProfileBackground.layer.borderWidth = 0
            imgProfile.layer.borderWidth = 0
            coverCircleBackground.backgroundColor = UIColor.white
            _guideView.animationColor = .darkGray
            coverCircleIcon.image = _Image.shared.blocked
            
        } else {
            
            imgProfileBackground.layer.borderColor = UIColor.white.cgColor
            imgProfileBackground.layer.borderWidth = 0
            imgProfile.layer.borderWidth = 0
            coverCircleBackground.backgroundColor = UIColor.white
            _guideView.animationColor = .darkGray
            coverCircleIcon.image = _Image.shared.empty
        }
    }
    //------------------------------------------------------
    //MARK: Action Method
    
}

class _Image {
    static let shared = _Image()
    var camera = UIImage(named: "cover_camera")
    var follow = UIImage(named: "icnFollow")
    var following = UIImage(named: "icnFollowing")
    var blocked = UIImage(named: "icnBlocked")
    var requested = UIImage(named: "icnRequested")
    var empty = UIImage(named: "")
    private init() { }
}

// MARK: DesignableView
import UIKit
@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class DesignableButton: UIButton {
}

@IBDesignable
class DesignableLabel: UILabel {
}

@IBDesignable
class DesignableImage: UIImageView {
}

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}
