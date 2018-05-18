//
//  ProfieControlsView.swift
//  Rack
//
//  Created by clicklabs on 17/12/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class ProfieControlsView: UIView {

  
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
      guard let context = UIGraphicsGetCurrentContext() else { return }
      context.beginPath()
      context.move(to: CGPoint(x: rect.maxX, y: rect.minY))
      context.addLine(to: CGPoint(x: rect.minX, y: 34.0))
      context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
      context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
      context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
      context.closePath()
      context.setFillColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
      context.setLineWidth(5.0)
      context.setStrokeColor(UIColor.white.cgColor)
      context.setStrokeColor(red: 2.0/255.0, green: 2.0/255.0, blue: 2.0/255.0, alpha: 1.0)
      context.fillPath()
      
      
  }
 

}
