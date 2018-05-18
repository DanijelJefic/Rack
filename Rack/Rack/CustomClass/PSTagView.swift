//
//  PSTagView.swift
//  Rack
//
//  Created by hyperlink on 01/06/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

@objc protocol PSTagViewTapDelegate {
    @objc func tapOnTagDelegate(_ sender : Any)
}

@objc protocol PSTagViewDelDelegate {
    @objc func tapOnDeleteDelegate(_ sender : PSTagView)
}


let minimumCharacter : Int = 30
class PSTagView: UIView {

    //------------------------------------------------------
    
    //MARK: - Class Variable
    var tagName : String = ""
    var lbl = UILabel()
    var panGesture = UIPanGestureRecognizer()
    var deleteBtn : UIButton?
    
    var cLayer = CAShapeLayer()
    var pathCurrentX = CGFloat()

    var parrentView = UIImageView()
    var tagLocation = CGPoint()
    var tagDetail : Any?
    var tagType : searchFlagType = .brand
    var delegate : PSTagViewTapDelegate? = nil
    var delDelegate: PSTagViewDelDelegate? = nil

    
    //------------------------------------------------------
    
    //MARK: - Intializer Method
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(tagName:String,x: CGFloat,y:CGFloat,parrentView: UIImageView,tagDetail : Any?)
    {

        self.tagDetail = tagDetail
        
        //to set minimum character limit
        var lblWidth = tagName.sizeOfString(font: UIFont.applyMedium(fontSize: 12.0)).width + 10
        if tagName.characters.count > minimumCharacter {
            
            let range =  tagName.rangeOfComposedCharacterSequences(for: tagName.startIndex..<tagName.index(tagName.startIndex, offsetBy: minimumCharacter))
            let tmpValue = tagName.substring(with: range).appending("")
            lblWidth = tmpValue.sizeOfString(font: UIFont.applyMedium(fontSize: 12.0)).width + 10
            
        }
        let lblHeight = tagName.sizeOfString(font: UIFont.applyMedium(fontSize: 12.0)).height + 8

        self.parrentView = parrentView
        lbl = UILabel(frame: CGRect(x: 0
            , y: 0
            , width:  lblWidth
            , height: lblHeight)
        )
        lbl.font = UIFont.applyMedium(fontSize: 12.0)
        lbl.text = tagName
        lbl.textAlignment = .center
        lbl.textColor = UIColor.white
        lbl.layer.borderColor = UIColor.clear.cgColor
        lbl.layer.borderWidth = 0.0

        super.init(frame: CGRect(x: x , y: y , width: lbl.frame.width, height: lbl.frame.height))

        cLayer.path = createTriangle().cgPath
        cLayer.fillColor = UIColor(red: 0.0 / 255.0 , green: 0.0 / 255.0 , blue: 0.0 / 255.0, alpha: 0.80).cgColor
        self.layer.addSublayer(cLayer)
        
        pathCurrentX = (cLayer.path?.currentPoint.x)!

        self.backgroundColor = UIColor(red: 0.0 / 255.0 , green: 0.0 / 255.0 , blue: 0.0 / 255.0, alpha: 0.80)
        self.layer.cornerRadius = 5.0

        
        if self.parrentView.frame.height - self.frame.height + 5  <= y + self.frame.height
        {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            cLayer.path = downTriangle(x: cLayer.path!.currentPoint.x , y: self.frame.height + 5.0).cgPath
            CATransaction.commit()
            
            self.center = CGPoint(x: x, y: y - self.frame.height  + 5.0)
        }
        else
        {
            self.center = CGPoint(x: x, y: y + self.frame.height / 2 + 5.0)
        }
        self.addSubview(lbl)

        
        
        deleteBtn = UIButton(frame: CGRect(x: 0, y: 0, width: lblHeight, height: lblHeight))
        deleteBtn?.backgroundColor = UIColor.clear
        deleteBtn?.setImage(#imageLiteral(resourceName: "btnTagClose"), for: .normal)
        deleteBtn?.contentHorizontalAlignment = .right
        deleteBtn?.isHidden = true
        deleteBtn?.addTarget(self, action: #selector(self.btnDeleteClick(_:)), for: .touchUpInside)
        
        let heightDeleteBtn = NSLayoutConstraint(item: self.deleteBtn!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1
            , constant: lblHeight)
        let widthDeleteBtn = NSLayoutConstraint(item: self.deleteBtn!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: lblHeight)
        let yCenterDeleteBtn = NSLayoutConstraint(item: self.deleteBtn!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 1.5)
        let trailingDeleteBtn = NSLayoutConstraint(item: self.deleteBtn!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -3)
        
        self.addConstraints([heightDeleteBtn,widthDeleteBtn,trailingDeleteBtn,yCenterDeleteBtn])
        deleteBtn?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(deleteBtn!)
        
        //Tag Location
        tagLocation = CGPoint(x: self.frame.origin.x + self.cLayer.path!.currentPoint.x, y: self.frame.origin.y - 5)
        
        
        // CustomView user click disable
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showButton(_:))))
        
        
        if self.layer.frame.origin.x <= 0
        {
            self.frame.origin.x = 5.0
        }
        if (self.layer.frame.width + self.frame.origin.x)  >= parrentView.frame.width
        {
            self.frame.origin.x = parrentView.frame.width - self.frame.width - 5.0
        }
        if self.layer.frame.origin.y <= 0
        {
            self.frame.origin.y = 0
        }
        if (self.layer.frame.height + self.frame.origin.y)  >= parrentView.frame.height
        {
            self.frame.origin.y = parrentView.frame.height - self.frame.height
        }
        
        self.layoutIfNeeded()
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureEvent(sender:)))
        self.addGestureRecognizer(panGesture)

    }
    
    init(tagName:String,x: CGFloat,y:CGFloat,parrentView: UIImageView,tagDetai : Any?, searchType : searchFlagType)
    {
        
        self.tagDetail = tagDetai
        self.tagType = searchType
        
        //to set minimum character limit
        var lblWidth = tagName.sizeOfString(font: UIFont.applyRegular(fontSize: 12.0)).width + 10
        if tagName.characters.count > minimumCharacter {
            
            let range =  tagName.rangeOfComposedCharacterSequences(for: tagName.startIndex..<tagName.index(tagName.startIndex, offsetBy: minimumCharacter))
            let tmpValue = tagName.substring(with: range).appending("")
            lblWidth = tmpValue.sizeOfString(font: UIFont.applyRegular(fontSize: 12.0)).width + 10
            
        }
        let lblHeight = tagName.sizeOfString(font: UIFont.applyRegular(fontSize: 12.0)).height + 8
        
        self.parrentView = parrentView
        lbl = UILabel(frame: CGRect(x: 0
            , y: 0
            , width:  lblWidth
            , height: lblHeight)
        )
        lbl.font = UIFont.applyRegular(fontSize: 12.0)
        lbl.text = tagName
        lbl.textAlignment = .center
        lbl.textColor = UIColor.white
        lbl.layer.borderColor = UIColor.clear.cgColor
        lbl.layer.borderWidth = 0.0
        
        super.init(frame: CGRect(x: x , y: y , width: lbl.frame.width, height: lbl.frame.height))
        
        cLayer.path = createTriangle().cgPath
        cLayer.fillColor = UIColor(red: 0.0 / 255.0 , green: 0.0 / 255.0 , blue: 0.0 / 255.0, alpha: 0.80).cgColor
        self.layer.addSublayer(cLayer)
        
        pathCurrentX = (cLayer.path?.currentPoint.x)!
        
        self.backgroundColor = UIColor(red: 0.0 / 255.0 , green: 0.0 / 255.0 , blue: 0.0 / 255.0, alpha: 0.80)
        self.layer.cornerRadius = 5.0
        
        
        if self.parrentView.frame.height - self.frame.height + 5  <= y + self.frame.height
        {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            cLayer.path = downTriangle(x: cLayer.path!.currentPoint.x , y: self.frame.height + 5.0).cgPath
            CATransaction.commit()
            
            self.center = CGPoint(x: x, y: y - self.frame.height  + 5.0)
        }
        else
        {
            self.center = CGPoint(x: x, y: y + self.frame.height / 2 + 5.0)
        }
        self.addSubview(lbl)
        
        //Tag Location
        tagLocation = CGPoint(x: self.frame.origin.x + self.cLayer.path!.currentPoint.x, y: self.frame.origin.y - 5)
        
        
        // CustomView user click disable
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showButton(_:))))
        
        
        if self.layer.frame.origin.x <= 0
        {
            self.frame.origin.x = 5.0
        }
        if (self.layer.frame.width + self.frame.origin.x)  >= parrentView.frame.width
        {
            self.frame.origin.x = parrentView.frame.width - self.frame.width - 5.0
        }
        if self.layer.frame.origin.y <= 0
        {
            self.frame.origin.y = 0
        }
        if (self.layer.frame.height + self.frame.origin.y)  >= parrentView.frame.height
        {
            self.frame.origin.y = parrentView.frame.height - self.frame.height
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnTagView(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
        
        self.layoutIfNeeded()
        
    }
    
    init(tagName:String,point:CGPoint,parrentView: UIImageView)
    {
        
        //to set minimum character limit
        var lblWidth = tagName.sizeOfString(font: UIFont.applyRegular(fontSize: 12.0)).width + 10
        if tagName.characters.count > minimumCharacter {
            
            let range =  tagName.rangeOfComposedCharacterSequences(for: tagName.startIndex..<tagName.index(tagName.startIndex, offsetBy: minimumCharacter))
            let tmpValue = tagName.substring(with: range).appending("")
            lblWidth = tmpValue.sizeOfString(font: UIFont.applyRegular(fontSize: 12.0)).width + 10
            
        }
        let lblHeight = tagName.sizeOfString(font: UIFont.applyRegular(fontSize: 12.0)).height + 8
        
        super.init(frame: CGRect(x: 0, y: 0, width: lblWidth, height: lblHeight))
        
        self.parrentView = parrentView
        lbl = UILabel(frame: CGRect(x: 0
            , y: 0
            , width:  lblWidth
            , height: lblHeight)
        )
        lbl.font = UIFont.applyRegular(fontSize: 12.0)
        lbl.text = tagName
        lbl.textAlignment = .center
        lbl.textColor = UIColor.white
        lbl.layer.borderColor = UIColor.clear.cgColor
        lbl.layer.borderWidth = 0.0
        self.addSubview(lbl)
        
    
        cLayer.path = createTriangle().cgPath
        cLayer.fillColor = UIColor(red: 0.0 / 255.0 , green: 0.0 / 255.0 , blue: 0.0 / 255.0, alpha: 0.80).cgColor
        self.layer.addSublayer(cLayer)
        
        pathCurrentX = (cLayer.path?.currentPoint.x)!
        if point.x < lblWidth/2 {
            
            self.frame.origin.x = 0
            cLayer.path = moveTriangle(x: point.x.roundTo(places: 2)).cgPath
            
        } else if (point.x + (lblWidth / 2)) > kScreenWidth {
            self.frame.origin.x = (kScreenWidth - lblWidth)
            cLayer.path = moveTriangle(x: self.parrentView.frame.size.width + (lblWidth / 2).roundTo(places: 2) - point.x.roundTo(places: 2)).cgPath
        } else {

            self.frame.origin.x = point.x - lblWidth/2
            self.frame.origin.y = point.y + lblHeight/2 + 5.0
        }

        if self.parrentView.frame.size.height < (point.y + (lblHeight/2) + 5) {
            self.frame.origin.y = (point.y - lblHeight - 5)
            cLayer.path = downTriangle(x: cLayer.path!.currentPoint.x ,y: self.frame.height + 5.0).cgPath

        } else {
            self.frame.origin.y = point.y + 5
        }
        
        self.backgroundColor = UIColor(red: 0.0 / 255.0 , green: 0.0 / 255.0 , blue: 0.0 / 255.0, alpha: 0.80)
        self.layer.cornerRadius = 5.0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnTagView(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
        
        self.layoutIfNeeded()
        
    }

    class func showTagOnImage(_ tagData : Array<Any>,parentView : UIImageView,mainImage : UIImage, searchType : searchFlagType) -> [PSTagView]{
        
        var psTagView : [PSTagView] = []
        
        for tag in tagData {
         
            if let tag = tag as? Dictionary<String, Any> {
                
                let point = CGPoint(x: Double.init((tag["x_axis"] as! String))!, y: Double.init((tag["y_axis"] as! String))!)
                let scaleFactor = mainImage.getDeviceWiseImageScaleFactor(kScreenWidth)
                
                psTagView.append(
                    PSTagView(tagName: tag["name"] as! String, x: point.x * scaleFactor, y: point.y * scaleFactor, parrentView: parentView, tagDetai: tag, searchType : searchType)
                    
//                    PSTagView(tagName: tag["name"] as! String, point: CGPoint(x: point.x * scaleFactor, y: point.y * scaleFactor), parrentView: parentView)
                )
            } else {
                //print("Please check tagData response...")
            }
            
        }
        
        return psTagView
    }
    
    
    //------------------------------------------------------
    
    //MARK: - Arrow Movement Method
    
    func createTriangle() -> UIBezierPath
    {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.frame.width / 2 , y: -5.0 ))
        path.addLine(to: CGPoint(x: self.frame.width/2 - 5.0 , y: 0.0))
        path.addLine(to: CGPoint(x: self.frame.width/2 + 5.0 , y: 0.0))
        path.close()
        return path
    }
    func moveTriangle(x:CGFloat) -> UIBezierPath
    {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x, y: -5.0 ))
        path.addLine(to: CGPoint(x: x - 5.0 , y: 0.0))
        path.addLine(to: CGPoint(x: x + 5.0 , y: 0.0))
        path.close()
        return path
        
    }
    
    func downTriangle(x: CGFloat,y:CGFloat) -> UIBezierPath
    {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x, y: y))
        path.addLine(to: CGPoint(x: x - 5.0 , y: y - 5.0))
        path.addLine(to: CGPoint(x: x + 5.0 , y: y - 5.0))
        path.close()
        return path
    }

    func upTriangle(x:CGFloat,y:CGFloat) -> UIBezierPath
    {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x, y: y))
        path.addLine(to: CGPoint(x: x - 5.0 , y: 0.0))
        path.addLine(to: CGPoint(x: x + 5.0 , y: 0.0))
        path.close()
        return path
    }
    
    //------------------------------------------------------
    
    //MARK: - Ation Methods
    
    func showButton(_ sender: UITapGestureRecognizer)
    {
        //to
        self.superview?.bringSubview(toFront: self)
        
        self.deleteBtn?.isHidden = !self.deleteBtn!.isHidden
        if self.deleteBtn!.isHidden
        {
            
            UIView.animate(withDuration: 0.5, animations: {

                if (self.frame.origin.x + self.frame.size.width >= kScreenWidth - 10)
                {
                    self.frame.origin.x = self.frame.origin.x + 10
                    if self.parrentView.frame.height - self.frame.height + 5  <= (sender.view?.frame.origin.y)! + self.frame.height
                    {
                        self.cLayer.path = self.downTriangle(x: (self.cLayer.path?.currentPoint.x)! - 10,y:self.frame.height + 5.0 ).cgPath
                    }
                    else
                    {
                        self.cLayer.path = self.upTriangle(x: (self.cLayer.path?.currentPoint.x)! - 10,y: -5.0 ).cgPath
                    }
                }
               
                self.frame.size.width = self.frame.width - 10
                self.layoutIfNeeded()
                self.parrentView.layoutIfNeeded()
            })
            
        }
        else
        {
            self.deleteBtn?.alpha = 0.0
            
            UIView.animate(withDuration: 0.5, animations: {
                self.frame.size.width = self.frame.width + 10

                if (self.frame.origin.x + self.frame.size.width > kScreenWidth)
                {
                    
                    if self.parrentView.frame.height - self.frame.height + 5  <= (sender.view?.frame.origin.y)! + self.frame.height
                    {
                        self.cLayer.path = self.downTriangle(x: (self.cLayer.path?.currentPoint.x)! + 10,y:self.frame.height + 5.0 ).cgPath
                    }
                    else
                    {
                        self.cLayer.path = self.upTriangle(x: (self.cLayer.path?.currentPoint.x)! + 10,y: -5.0).cgPath
                    }
                    self.frame.origin.x = self.frame.origin.x - 10
                }
                
                self.deleteBtn?.alpha = 1.0
                self.layoutIfNeeded()
                self.parrentView.layoutIfNeeded()
                
            }, completion: { (isComplete : Bool) in
                
                if isComplete {
                    self.deleteBtn?.alpha = 1.0
                }
                
            })
            
        }
        
    }
    
    func tapOnTagView(_ gesture : UITapGestureRecognizer) {
        
        if let _ = self.delegate {
            self.delegate?.tapOnTagDelegate(gesture.view!)
        } else {
            //print("Not response...")
        }
    }
    
    func btnDeleteClick(_ sender: UIButton)
    {
        
        if let _ = self.delDelegate {
            self.delDelegate?.tapOnDeleteDelegate(self)
        } else {
            //print("Not response...")
        }
        
//        self.removeFromSuperview()
    }

    func panGestureEvent(sender: UIPanGestureRecognizer)
    {
        let translation = sender.translation(in: self.parrentView)
        let velocity = sender.velocity(in: self.parrentView)
        if sender.state == .changed
        {
            
            //            sender.view?.frame = (sender.view?.convert((sender.view?.frame)!, to: self.superview))!
            
            
            
            // //print("translation :\(translation.x) selftranslation :\(selftranslation.x) velocity :\(velocity.x) selfvelocity :\(selfvelocity.x)")
            if sender.view!.frame.origin.x + translation.x >= 0 &&  sender.view!.frame.origin.x + translation.x + sender.view!.frame.width <= parrentView.frame.width && (cLayer.path?.currentPoint.x)! ==  pathCurrentX
            {
                ////print(translation.x)
                
                sender.view!.center.x = sender.view!.center.x + translation.x

            }
            
            // Left Side Arrow Move
            if (cLayer.path?.currentPoint.x)! != pathCurrentX && velocity.x >= 0 && sender.view!.frame.origin.x <= 5.0
            {
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                cLayer.path = moveTriangle(x: (cLayer.path?.currentPoint.x)! + 1).cgPath
                CATransaction.commit()
                //print("ok............")
            }
            // Center  Side Arrow Move
            if sender.view!.frame.origin.x <= 5.0 && (cLayer.path?.currentPoint.x)! > 10 &&  velocity.x <= 0
            {
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                cLayer.path = moveTriangle(x: (cLayer.path?.currentPoint.x)! - 1).cgPath
                CATransaction.commit()

                //print("currentPoint : \(cLayer.path?.currentPoint.x)\n")
                
            }
            
            // Right Side arrow Move
            if  self.frame.origin.x + self.frame.width >= self.parrentView.frame.width - 5.0 && (cLayer.path?.currentPoint.x)! < self.frame.width - 10 && velocity.x >= 0
            {
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                cLayer.path = moveTriangle(x: (cLayer.path?.currentPoint.x)! + 1).cgPath
                CATransaction.commit()
                //print(" Right ok............")
            }
            // Center Side Arrow move
            if self.frame.origin.x + self.frame.width >= self.parrentView.frame.width - 5.0 &&  velocity.x <= 0 && (cLayer.path?.currentPoint.x)! > pathCurrentX
            {
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                cLayer.path = moveTriangle(x: (cLayer.path?.currentPoint.x)! - 1).cgPath
                CATransaction.commit()
                //print("Right currentPoint : \(cLayer.path?.currentPoint.x)\n")
                
            }
            
            
            
            //                else if sender.view!.frame.origin.x >= 5.0 && (cLayer.path?.currentPoint.x)! > 10 && (cLayer.path?.currentPoint.x)! <= self.center.x
            //                {
            //                    CATransaction.begin()
            //                    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            //                    cLayer.path = moveTriangle(x: (cLayer.path?.currentPoint.x)! + 1).cgPath
            //                    CATransaction.commit()
            //
            //
            //                }

            if sender.view!.frame.origin.y - 5.0 + translation.y >= 0 &&  sender.view!.frame.origin.y + translation.y + sender.view!.frame.height <= parrentView.frame.height - 5
            {
                sender.view!.center.y = sender.view!.center.y + translation.y
                
            }
            // Arrow down side
            if self.parrentView.frame.height - self.frame.height + 5  <= (sender.view?.frame.origin.y)! + self.frame.height
            {
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                cLayer.path = downTriangle(x: cLayer.path!.currentPoint.x,y: self.frame.height + 5.0).cgPath
                CATransaction.commit()
                
                
                
            }
            else
            {
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                cLayer.path = upTriangle(x:cLayer.path!.currentPoint.x ,y: -5.0).cgPath
                CATransaction.commit()
                
            }
            
            sender.setTranslation(CGPoint.zero, in: self.parrentView)
            
            
        }
        if sender.state == .ended
        {
            //Tag location
            tagLocation = CGPoint(x: self.frame.origin.x + self.cLayer.path!.currentPoint.x, y: self.frame.origin.y - 5)
        }
        
    }

}

