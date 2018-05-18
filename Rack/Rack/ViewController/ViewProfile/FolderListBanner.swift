//
//  FolderListBanner.swift
//  Rack
//
//  Created by GS Bit Labs on 2/7/18.
//  Copyright © 2018 Hyperlink. All rights reserved.
//

import Foundation
import UIKit


class FolderListBanner: UICollectionReusableView {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var rackPinButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = AppColor.primaryTheme
    }
    
    func setUpData(_image: String, _timeStamp: String) {
        image.setImageWithDownload(_image.url())
        timeStamp.text = "Updated \(_timeStamp)"
    }
    
}
