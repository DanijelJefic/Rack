//
//  ReportAbuseView.swift
//  Kafou
//
//  Created by  on 22/02/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit


class ImageZoom: UIView {

    //--------------------------------------------------------------------------
    //MARK:- Outlets
    
    @IBOutlet var view                          : UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imgView: UIImageView!
    
    //--------------------------------------------------------------------------
    //MARK:- Varibles
    
    //--------------------------------------------------------------------------
    //MARK:- Action Method

    //--------------------------------------------------------------------------
    //MARK:- CustomMethod
    
    func setData(img : UIImage, sender : UIPinchGestureRecognizer) {
        imgView.image = img
        scrollView.zoomScale = sender.scale
    }
    
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
        scrollView.maximumZoomScale           = 2.5
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

extension ImageZoom: UIScrollViewDelegate, UIGestureRecognizerDelegate{
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.removeFromSuperview()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.removeFromSuperview()
    }
}


