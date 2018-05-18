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

enum TextTips: String {
    case createRack = "Tap here to create your first Rack"
    case saveRack = "Tap here to save this to a Rack"
    case coverPhoto = "Tap here to change your cover photo"
    case newRack = "Tap here to create a new Rack"
    case followUser = "Tap here to follow and unfollow user"
    case repostPhoto = "Tap here to repost this photo"
    case repostingPhoto = "This is where you can find who is reposting your posts"
}

class TipView {
    static let shared = TipView()
    private init() {}
    
    private var tipView: EasyTipView!
    private var pulsator = Pulsator()
    
    func setup(_ position: EasyTipView.ArrowPosition, forView: UIView, textType: TextTips) {
        
        // Tip view setup
        var preferences                         = EasyTipView.Preferences()
        preferences.drawing.font                = UIFont.applyRegular(fontSize: 13.0)
        preferences.drawing.foregroundColor     = UIColor.white
        preferences.drawing.backgroundColor     = UIColor.darkGray
        preferences.drawing.arrowPosition       = position
        preferences.animating.showInitialAlpha  = 0
        
        tipView = EasyTipView(text: textType.rawValue, preferences: preferences)
        tipView.show(forView: forView)
        tipView.isUserInteractionEnabled = false
        
        // Pulse effect setup
        pulsator.numPulse                       = 4
        pulsator.backgroundColor                = UIColor.darkGray.cgColor
        pulsator.animationDuration              = 4.0
        pulsator.repeatCount                    = Float.infinity
        pulsator.radius                         = 25
        pulsator.position                       = forView.center
        forView.layer.addSublayer(pulsator)
        pulsator.start()
        
    }
    
    func tipDismiss() {
        tipView.dismiss()
        pulsator.stop()
    }
    
}
