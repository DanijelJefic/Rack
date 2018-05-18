
//  NotificationPopUP.swift
//  Created by saroj  on 16/05/18.

import UIKit
class NotificationPopUP: UIView {
    @IBOutlet weak var stackView:  UIStackView!
    var notificationCountArray : [[UIImage:String]] = []
    var triangle : TriangleView?

    static func instance() -> NotificationPopUP {
        
        
        let notificationPopUP = UINib(nibName: "NotificationPopUP", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! NotificationPopUP
        appDelegate().window?.addSubview(notificationPopUP)
        notificationPopUP.isHidden = true
        return notificationPopUP
    }
    
    
    public func reloadNotificationCounts(countsDict:[String:String]) {
        self.notificationCountArray = NotificationModel.setCountValues(countsDict)
        
        if self.notificationCountArray.count == 0 {
            return
        }
        
        var selfRect : CGRect = self.frame
        selfRect.origin.x     = 100.0
        selfRect.origin.y     = 100.0
        selfRect.size.height  = 35.0
        selfRect.size.width   = CGFloat(self.notificationCountArray.count * 42)
        self.frame = selfRect
        self.layer.cornerRadius = 3.0
        self.center = CGPoint(x: 0.69 * kScreenWidth, y:kScreenHeight == 812.0 ? kScreenHeight - 105.0 : kScreenHeight - 70.0)

        for views in self.stackView.subviews {
            views.isHidden = true
        }
        
        for index in 0..<self.notificationCountArray.count {
            guard let imageView = self.stackView.viewWithTag(index+100) as? UIImageView else {
                continue
            }
            guard let countLabel = self.stackView.viewWithTag(index+200) as? UILabel else {
                continue
            }
            imageView.isHidden = false
            countLabel.isHidden = false
            let dict : [UIImage:String] = self.notificationCountArray[index]
            let notificationImage = dict.keys.first
            imageView.image = notificationImage
            countLabel.text = dict[notificationImage!]!
    
        }
        self.isHidden = false
        self.layoutIfNeeded()
        
        if triangle != nil {
           triangle?.removeFromSuperview()
        }
        
        triangle = TriangleView(frame: CGRect(x: self.frame.size.width/2, y: selfRect.size.height, width: 10.0 , height: 7.0))
        triangle?.backgroundColor = .clear
        let angle =  Double.pi
        let tr = CGAffineTransform.identity.rotated(by: CGFloat(angle))
        triangle?.transform = tr
        self.addSubview(triangle!)
        
        self.fadeIn()
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: { (_timer) in
                self.fadeOut()
            })
        }
    }
}

class TriangleView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
                context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.closePath()
        
        context.setFillColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context.fillPath()
    }
}


