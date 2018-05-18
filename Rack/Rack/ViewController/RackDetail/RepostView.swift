//
//  RepostView.swift
//  Rack
//
//  Created by GS Bit Labs on 2/27/18.
//  Copyright © 2018 Hyperlink. All rights reserved.
//

import Foundation
import UIKit
import ActiveLabel

class RepostView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblPostType: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnDot: UIButton!
    @IBOutlet weak var lblDetail: ActiveLabel!
    @IBOutlet var constLblDetailHeight: NSLayoutConstraint!

    // Repost View Static Outlets
    @IBOutlet weak var static_containerView: UIView!
    @IBOutlet var static_profileView : UIView!
    @IBOutlet weak var static_imgProfile: UIImageView!
    @IBOutlet weak var static_lblUserName: UILabel!
    @IBOutlet weak var static_lblPostType: UILabel!
    @IBOutlet weak var static_lblTime: UILabel!
    @IBOutlet weak var static_imgPost: UIImageView!
    
    @IBOutlet weak var static_buttonView: UIView!
    @IBOutlet weak var static_lblLike: UILabel!
    @IBOutlet weak var static_lblComment: UILabel!
    @IBOutlet weak var static_lblRepost: UILabel!
    @IBOutlet weak var static_lblDetail: ActiveLabel!
    
    @IBOutlet weak var static_btnLikeBig: UIButton!
    @IBOutlet weak var static_btnDot: UIButton!
    @IBOutlet weak var static_btnLike: UIButton!
    @IBOutlet weak var static_btnComment: UIButton!
    @IBOutlet weak var static_btnRepost: UIButton!
    @IBOutlet weak var static_btnWant: UIButton!
    
    @IBOutlet weak var static_constImageHeight: NSLayoutConstraint!
    @IBOutlet var static_constLblDetailHeight: NSLayoutConstraint!
    @IBOutlet var static_constLblDetailYPos: NSLayoutConstraint!
    @IBOutlet var staticContainerYPos: NSLayoutConstraint!
    
    var lblPostTypeGesture = UITapGestureRecognizer()
    var static_lblPostTypeGesture = UITapGestureRecognizer()
    var static_imgProfileGesture = UITapGestureRecognizer()
    var static_usernameGesture = UITapGestureRecognizer()
    var imgProfileGesture = UITapGestureRecognizer()
    var likeLabelGesture = UITapGestureRecognizer()
    var doubleTapGesture = UITapGestureRecognizer()
    var singleTapGesture = UITapGestureRecognizer()
    var pinchGesture = UIPinchGestureRecognizer()
    var panGesture = UIPanGestureRecognizer()
    
    var tagOptionSelectionSelection :((IndexPath,TagType) -> Void)?
    
    
    
    static func instance() -> RepostView {
        
        return UINib(nibName: "RepostView", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! RepostView
    }
    
    /*
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblUserName.applyStyle(labelFont: UIFont.applyArialBold(fontSize: 12.0), labelColor: AppColor.textB)
        lblPostType.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0), labelColor: AppColor.textB)
        lblTime.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0), labelColor: AppColor.textLightGray)
        
        lblDetail.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 11.0), labelColor: UIColor.black)
        
        // Repost View variables
        static_imgProfile.applyStype(cornerRadius: static_imgProfile.frame.size.height / 2)
        
        static_lblUserName.applyStyle(labelFont: UIFont.applyArialBold(fontSize: 12.0), labelColor: AppColor.textB)
        static_lblPostType.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0), labelColor: AppColor.textB)
        static_lblTime.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0), labelColor: AppColor.textLightGray)
        
        static_lblLike.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0,isAspectRasio: true), labelColor: AppColor.textLightGray)
        static_lblComment.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0,isAspectRasio: true), labelColor: AppColor.textLightGray)
        static_lblRepost.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 10.0,isAspectRasio: true), labelColor: AppColor.textLightGray)
        
        static_lblDetail.applyStyle(labelFont: UIFont.applyArialRegular(fontSize: 11.0), labelColor: UIColor.black)
        
    }
    */
    func btnTapAnimation(_ sender : UIView) {
        
        UIView.animate(withDuration: 3.0, animations: {
            
            self.isUserInteractionEnabled = false
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            
        }) { (isComplete : Bool) in
            
            UIView.animate(withDuration: 3.0, animations: {
                sender.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                
            }, completion: { (isComplete : Bool) in
                self.isUserInteractionEnabled = true
            })
        }
    }
    
}

