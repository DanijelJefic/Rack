//
//  CommonClass.swift
//  Rack
//
//  Created by hyperlink on 11/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

//MARK:- Custom Class
class CustomTextContainer: UIView {
    
}

class BarButton : NSObject {
    var title : String?
    var image : UIImage?
    var color : UIColor?
    
    init(title : String? = nil, image: UIImage? = nil , color : UIColor? = nil ) {
        self.title = title == nil ? "" : title
        self.image = image == nil ? UIImage() : image
        self.color = color == nil ? AppColor.btnTitle : color
    }
    
}
