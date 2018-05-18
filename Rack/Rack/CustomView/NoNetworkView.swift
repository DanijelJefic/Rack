//
//  NoNetworkView.swift
//  Rack
//
//  Created by hyperlink on 13/06/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class NoNetworkView: UIView {

    
    @IBOutlet var view      : UIView!
    @IBOutlet weak var lblMessage: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibSetUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibSetUp()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        lblMessage.applyStyle(labelFont: UIFont.applyRegular(fontSize: 12.0), labelColor: UIColor.white)
        
    }
    
    private func nibSetUp() {
        
        view = loadViewFromNib()
        self.awakeFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
        
    }
    
    private func loadViewFromNib() -> UIView {
        
        let bundel = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundel)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
   
}
