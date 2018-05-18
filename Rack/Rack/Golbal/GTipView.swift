//
//  CustomBorderButton.swift
//  BorderButton
//
//  Created by Rohit Pathak on 25/11/15.
//  Copyright © 2015 Rohit Pathak. All rights reserved.
//

import Foundation
import UIKit
import EasyTipView
import Pulsator

let kCreateRackAnimation        : String = "kCreateRackAnimation"
let kSaveRackAnimation          : String = "kSaveRackAnimation"
let kCoverPhotoAnimation        : String = "kCoverPhotoAnimation"
let kNewRackAnimation           : String = "kNewRackAnimation"
let kFollowUserAnimation        : String = "kFollowUserAnimation"
let kRepostPhotoAnimation       : String = "kRepostPhotoAnimation"
let kRepostingPhotoAnimation    : String = "kRepostingPhotoAnimation"

enum TextTips: String {
    case tCreateRack        = "Tap here to create your first Rack"
    case tSaveRack          = "Tap here to save this to a Rack"
    case tCoverPhoto        = "Tap here to change your cover photo"
    case tNewRack           = "Tap here to create a new Rack"
    case tFollowUser        = "Tap here to follow and unfollow user"
    case tRepostPhoto       = "Tap here to repost this photo"
    case tRepostingPhoto    = "This is where you can find who is reposting your posts"
}

enum animationLocation {
    case aCreateRack
    case aSaveRack
    case aCoverPhoto
    case aNewRack
    case aFollowUser
    case aRepostPhoto
    case aRepostingPhoto
}

class GuideView {
    
    private var tipView: EasyTipView!
    private var pulsator                = Pulsator()
    var  isSetupAnimation: Bool         = false
    var animationColor: UIColor         = UIColor.darkGray
    
    func addTip(_ position: EasyTipView.ArrowPosition, forView: UIView, withinSuperview: UIView, textType: TextTips, forAnim: animationLocation) {
        
        // Tip view setup
        var preferences                         = EasyTipView.Preferences()
        preferences.drawing.font                = UIFont.applyRegular(fontSize: 13.0)
        preferences.drawing.foregroundColor     = UIColor.white
        preferences.drawing.backgroundColor     = UIColor.darkGray
        preferences.drawing.arrowPosition       = position
        preferences.animating.showInitialAlpha  = 0
        
        let isTapped = getTapActivity(forAnim: forAnim)
        if !isTapped {
            
            let superView = withinSuperview.subviews
            for vw in superView {
                if vw is EasyTipView {
                    if self.tipView != nil {
                        self.tipView.dismiss()
                    }
                }
            }
            
            tipView = EasyTipView(text: textType.rawValue, preferences: preferences)
            tipView.show(animated: false, forView: forView, withinSuperview: withinSuperview)
            tipView.isUserInteractionEnabled = false
        }
        
    }
    
    func addTipOnItem(_ forItem: UIBarItem, withinSuperView: UIView, textType: TextTips, forAnim: animationLocation) {
        
        // Tip view setup
        var preferences                         = EasyTipView.Preferences()
        preferences.drawing.font                = UIFont.applyRegular(fontSize: 13.0)
        preferences.drawing.foregroundColor     = UIColor.white
        preferences.drawing.backgroundColor     = UIColor.darkGray
        preferences.drawing.arrowPosition       = .top
        preferences.animating.showInitialAlpha  = 0
        
        let isTapped = getTapActivity(forAnim: forAnim)
        if !isTapped {
            self.isSetupAnimation = true
            tipView = EasyTipView(text: textType.rawValue, preferences: preferences)
            tipView.show(animated: true, forItem: forItem, withinSuperView: withinSuperView)
            tipView.isUserInteractionEnabled = false
        }
    }
    
    func addAnimation(_ forView: UIView, withinSuperview: Bool, forAnim: animationLocation) {
        // Pulse effect setup
        pulsator.numPulse                       = 4
        pulsator.animationDuration              = 4.0
        pulsator.repeatCount                    = Float.infinity
        pulsator.radius                         = 25
        pulsator.position                       = forView.center
        pulsator.backgroundColor                = animationColor.cgColor
        
        let isTapped = getTapActivity(forAnim: forAnim)
        if !isTapped {
            pulsator.stop()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                if withinSuperview {
                    forView.superview?.layer.addSublayer(self.pulsator)
                }else{
                    forView.layer.superlayer?.insertSublayer(self.pulsator, below: forView.layer)
                }
                self.pulsator.start()
            })
        }
    }
    
    func tipDismiss(forAnim: animationLocation) {
        let isTapped = getTapActivity(forAnim: forAnim)
        if !isTapped && tipView != nil{
            tipView.dismiss()
            pulsator.stop()
        }
        
    }
    
    func saveTapActivity(forAnim: animationLocation) {
        switch forAnim {
        case .aCreateRack:
            UserDefaults.standard.set(true, forKey: kCreateRackAnimation)
        case .aCoverPhoto:
            UserDefaults.standard.set(true, forKey: kCoverPhotoAnimation)
        case .aNewRack:
            UserDefaults.standard.set(true, forKey: kNewRackAnimation)
        case .aFollowUser:
            UserDefaults.standard.set(true, forKey: kFollowUserAnimation)
        case .aRepostingPhoto:
            UserDefaults.standard.set(true, forKey: kRepostingPhotoAnimation)
        case .aRepostPhoto:
            UserDefaults.standard.set(true, forKey: kRepostPhotoAnimation)
        case .aSaveRack:
            UserDefaults.standard.set(true, forKey: kSaveRackAnimation)
        }
        UserDefaults.standard.synchronize()
    }
    
    func getTapActivity(forAnim: animationLocation) -> Bool {
        switch forAnim {
        case .aCreateRack:
            if let value = UserDefaults.standard.value(forKey: kCreateRackAnimation) as? Bool{
                return value
            }
        case .aCoverPhoto:
            if let value = UserDefaults.standard.value(forKey: kCoverPhotoAnimation) as? Bool{
                return value
            }
        case .aNewRack:
            if let value = UserDefaults.standard.value(forKey: kNewRackAnimation) as? Bool{
                return value
            }
        case .aFollowUser:
            if let value = UserDefaults.standard.value(forKey: kFollowUserAnimation) as? Bool{
                return value
            }
        case .aRepostingPhoto:
            if let value = UserDefaults.standard.value(forKey: kRepostingPhotoAnimation) as? Bool{
                return value
            }
        case .aRepostPhoto:
            if let value = UserDefaults.standard.value(forKey: kRepostPhotoAnimation) as? Bool{
                return value
            }
        case .aSaveRack:
            if let value = UserDefaults.standard.value(forKey: kSaveRackAnimation) as? Bool{
                return value
            }
        }
        return false
      }
    
}
