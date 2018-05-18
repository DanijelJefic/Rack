//
//  NavigationController+Extension.swift
//  Rack
//
//  Created by GP on 12/12/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

extension UINavigationController{
    func customize(){
        
        let navigationFont               = UIFont.applyRegular(fontSize: 15.5)
        let navigationBarAppearace       = UINavigationBar.appearance()
       
        navigationBarAppearace.tintColor = UIColor.black
        let color1 = UIColor(red:250.0/255.0,green:250.0/255.0,blue:250.0/255.0,alpha:1.0)
        navigationBarAppearace.barTintColor = color1
       
        
        navigationBarAppearace.titleTextAttributes = [NSFontAttributeName:navigationFont,NSForegroundColorAttributeName:UIColor.black]
        
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage         = UIImage()
        self.navigationBar.layer.shadowOffset  = CGSize(width:0.0, height:1.0)
        self.navigationBar.layer.shadowRadius  = 2.0
        self.navigationBar.layer.shadowColor   = UIColor.black.cgColor
        self.navigationBar.layer.shadowOpacity = 0.15
        self.navigationBar.layer.masksToBounds = false
        self.navigationBar.isTranslucent       = false
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
