//
//  GExtension.swift
//  Rack
//
//  Created by hyperlink on 27/04/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

import ActiveLabel
import MBProgressHUD
import AFNetworking
import PinterestSDK

var constButtonIndexPath: UInt8 = 0

//MARK:- UIColor

extension UIColor {
    
    class func colorFromHex(hex: Int) -> UIColor {
        return UIColor(red: (CGFloat((hex & 0xFF0000) >> 16)) / 255.0, green: (CGFloat((hex & 0xFF00) >> 8)) / 255.0, blue: (CGFloat(hex & 0xFF)) / 255.0, alpha: 1.0)
    }
}

//MARK:- UIFont

extension UIFont {
    
    class func applyRegular(fontSize : CGFloat ,isAspectRasio : Bool = true) -> UIFont {
        
        if isAspectRasio {
            return UIFont.init(name: "Helvetica" , size: fontSize * kHeightAspectRasio)!
        } else {
            return UIFont.init(name: "Helvetica" , size: fontSize)!
        }

    }
    
    class func applyBold(fontSize : CGFloat ,isAspectRasio : Bool = true) -> UIFont {
        if isAspectRasio {
            return UIFont.init(name: "Helvetica-Bold" , size: fontSize * kHeightAspectRasio)!
        }else {
            return UIFont.init(name: "Helvetica-Bold" , size: fontSize)!
        }
    }
}

//MARK:- UIView

extension UIView {
    
    class func viewFromNibName(name: String) -> UIView? {
        let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        return views!.first as? UIView
    }
    
    func applyViewShadow(shadowOffset : CGSize? = nil
        , shadowColor : UIColor? = nil
        , shadowOpacity : Float? = nil
        , cornerRadius      : CGFloat? = nil
        , backgroundColor : UIColor? = nil
        , backgroundOpacity : Float? = nil)
    {
        
        if shadowOffset != nil {
            self.layer.shadowOffset = shadowOffset!
        }
        else {
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
        }
        
        
        if shadowColor != nil {
            self.layer.shadowColor = shadowColor?.cgColor
        } else {
            self.layer.shadowColor = UIColor.clear.cgColor
        }
        
        //For button border width
        if shadowOpacity != nil {
            self.layer.shadowOpacity = shadowOpacity!
        }
        else {
            self.layer.shadowOpacity = 0
        }
        
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
        }
        else {
            self.layer.cornerRadius = 0
        }
        
        if backgroundColor != nil {
            self.backgroundColor = backgroundColor!
        }
        else {
            self.backgroundColor = UIColor.clear
        }
        
        if backgroundOpacity != nil {
            self.alpha = CGFloat(backgroundOpacity!)
        }
        else {
            self.layer.opacity = 1
        }
        
        self.layer.masksToBounds = false
    }
    
    func addBottomBorderWithColor(color: UIColor,origin : CGPoint, width : CGFloat , height : CGFloat) -> CALayer {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:origin.x, y:self.frame.size.height - height, width:width, height:height)
        self.layer.addSublayer(border)
        return border
    }
    
    func removeAllPSTagView() {
     
        for subview in self.subviews {
            if subview is PSTagView {
                subview.removeFromSuperview()
            }
        }
        
    }

    //Shammering Methods
    func startShimmering() {
        let light = UIColor(white: CGFloat(0), alpha: CGFloat(0.1)).cgColor
        let dark = UIColor.black.cgColor
        let gradient = CAGradientLayer()
        gradient.colors = [dark, light, dark]
        gradient.frame = CGRect(x: CGFloat(-bounds.size.width), y: CGFloat(0), width: CGFloat(3 * bounds.size.width), height: CGFloat(bounds.size.height))
        gradient.startPoint = CGPoint(x: CGFloat(0.0), y: CGFloat(0.5))
        gradient.endPoint = CGPoint(x: CGFloat(1.0), y: CGFloat(0.525))
        // slightly slanted forward
        gradient.locations = [0.4, 0.5, 0.6]
        layer.mask = gradient
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1.5
        animation.repeatCount = MAXFLOAT
        gradient.add(animation, forKey: "shimmer")

    }
    
    func stopShimmering() {
        layer.mask = nil
    }
    
    func scaleAnimation(_ duration : Double! , scale : CGFloat!) {
        
        UIView.animate(withDuration: duration, animations: {
            
            self.superview?.isUserInteractionEnabled = false
            self.transform = CGAffineTransform(scaleX: 1 + scale, y: 1 + scale)
            
        }) { (isComplete : Bool) in
            
            UIView.animate(withDuration: duration, animations: {
                self.transform = CGAffineTransform(scaleX: 1 - scale, y: 1 - scale)
                
            }, completion: { (isComplete : Bool) in
                self.superview?.isUserInteractionEnabled = true
            })
        }
    }
    
    func setRightBadgeButton(_ lblText : String)
    {
        
        for view in self.subviews
        {
            if !view.isKind(of: UIImageView.self) {
                view.removeFromSuperview()
            }
        }
        
        if lblText == "0" {
            
            debugPrint(self.subviews.count)
            debugPrint(self.subviews)
            
            for view in self.subviews
            {
                if !view.isKind(of: UIImageView.self) {
                    view.removeFromSuperview()
                }
            }
        }
        else
        {
            self.layoutIfNeeded()
            
            let size = lblText.getWidth(withConstrainedHeight: CGFloat.greatestFiniteMagnitude, font: UIFont.applyRegular(fontSize: 10.0, isAspectRasio: false))
            
            debugPrint(self.frame)
            let lblCount     = UILabel(frame: CGRect(x: 0, y: 0, width: max(15, size + 5), height: 15))
            debugPrint(lblCount.frame)
            
            lblCount.text = lblText
            lblCount.backgroundColor = UIColor.white
            lblCount.textColor = UIColor.black
            lblCount.textAlignment = .center
            lblCount.font = UIFont.applyRegular(fontSize: 10.0, isAspectRasio: false)
            
            let PaddingView         = UIView(frame: CGRect(x: self.frame.width - 5, y: -5 , width: max(15, size + 5), height: 15))
            print(PaddingView)
            PaddingView.layer.cornerRadius = PaddingView.frame.height / 2
            PaddingView.layer.masksToBounds = true
            PaddingView.backgroundColor = UIColor.red
            PaddingView.addSubview(lblCount)
            
            self.addSubview(PaddingView)
            
            self.layoutIfNeeded()
        }
    }
    
}
//MARK:- UINavigationController
extension UINavigationController : UIGestureRecognizerDelegate {
    
    /*
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }    
 */
}

//MARK:- UIButton

extension UIButton {

    func applyStyle(
         titleLabelFont     : UIFont?  = nil
        , titleLabelColor   : UIColor? = nil
        , cornerRadius      : CGFloat? = nil
        , borderColor       : UIColor? = nil
        , borderWidth       : CGFloat? = 1.5
        , state             : UIControlState = UIControlState.normal
        , backgroundColor   : UIColor? = nil
        , backgroundOpacity : Float? = nil
        ) {
        
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
        }
        else {
            self.layer.cornerRadius = 0
        }
        
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
        
        if borderWidth != nil {
            self.layer.borderWidth = borderWidth!
        }
        else {
            self.layer.borderWidth = 0
        }

        if titleLabelFont != nil {
            self.titleLabel?.font = titleLabelFont
        }else {
            self.titleLabel?.font = UIFont.applyRegular(fontSize: 13.0)
        }
        
        if titleLabelColor != nil {
            self.setTitleColor(titleLabelColor, for: state)
        } else {
            self.setTitleColor(UIColor.colorFromHex(hex: kColorGray74), for: state)
        }
        
        if backgroundColor != nil {
            self.backgroundColor = backgroundColor!
        }
        else {
            self.backgroundColor = UIColor.clear
        }
        
        if backgroundOpacity != nil {
            self.layer.opacity = backgroundOpacity!
        }
        else {
            self.layer.opacity = 1
        }
        
    }
    
    var buttonIndexPath: IndexPath? {
        get {
            return objc_getAssociatedObject(self, &constButtonIndexPath) as? IndexPath
        }
        set {
            objc_setAssociatedObject(self, &constButtonIndexPath, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

//MARK:- UILabel

extension UILabel {
    
    func applyStyle(
          labelFont      : UIFont?  = nil
        , labelColor     : UIColor? = nil
        , cornerRadius   : CGFloat? = nil
        , borderColor    : UIColor? = nil
        , borderWidth    : CGFloat? = nil
        , labelShadow    : CGSize? = nil
        ) {
        
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
        }
        else {
            self.layer.cornerRadius = 0
        }
        
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
        
        if borderWidth != nil {
            self.layer.borderWidth = borderWidth!
        }
        else {
            self.layer.borderWidth = 0
        }
        
        if labelFont != nil {
            self.font = labelFont
        }else {
            self.font = UIFont.applyRegular(fontSize: 13.0)
        }
        
        if labelColor != nil {
            self.textColor = labelColor
        } else {
            self.textColor = UIColor.colorFromHex(hex: kColorGray74)
        }
        
        if labelShadow != nil {
            self.shadowOffset = labelShadow!
        } else {
            self.shadowOffset = CGSize.zero
        }
        
    }
    
    ///Find the index of character (in the attributedText) at point
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
      
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
    
}

//MARK:- UITextField

extension UITextField {
    
    
    func applyStyle(
          textFont    : UIFont?  = nil
        , textColor   : UIColor? = nil
        , cornerRadius       : CGFloat? = nil
        , borderColor       : UIColor? = nil
        , borderWidth       : CGFloat? = nil
        ) {
        
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
        }
        else {
            self.layer.cornerRadius = 0
        }
        
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
        
        if borderWidth != nil {
            self.layer.borderWidth = borderWidth!
        }
        else {
            self.layer.borderWidth = 0
        }
        
        if textFont != nil {
            self.font = textFont
        }else {
            self.font = UIFont.applyRegular(fontSize: 13.0)
        }
        
        if textColor != nil {
            self.textColor = textColor
        } else {
             self.textColor = UIColor.colorFromHex(hex: kColorGray74)
        }
        
    }
    
    func setAttributedPlaceHolder(placeHolderText : String , color : UIColor) {
        self.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: [NSForegroundColorAttributeName : color])
    }
    
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    

   
}
//MARK:- UITextView

extension UITextView {
    
    
    func applyStyle(
        textFont    : UIFont?  = nil
        , textColor   : UIColor? = nil
        , cornerRadius       : CGFloat? = nil
        , borderColor       : UIColor? = nil
        , borderWidth       : CGFloat? = nil
        ) {
        
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
        }
        else {
            self.layer.cornerRadius = 0
        }
        
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
        
        if borderWidth != nil {
            self.layer.borderWidth = borderWidth!
        }
        else {
            self.layer.borderWidth = 0
        }
        
        if textFont != nil {
            self.font = textFont
        }else {
            self.font = UIFont.applyRegular(fontSize: 13.0)
        }
        
        if textColor != nil {
            self.textColor = textColor
        } else {
            self.textColor = UIColor.colorFromHex(hex: kColorGray74)
        }
        
    }
    
}

//extension UIImageView {
//    func set(with urlString: String){
//        guard let url = URL.init(string: urlString) else {
//            return
//        }
//        let resource = ImageResource(downloadURL: url, cacheKey: urlString)
//        self.kf.setImage(with: resource)
//    }
//}

//MARK: - UIImageView Extension

extension UIImageView {
    
    func applyStype(cornerRadius : CGFloat? = nil
        , borderColor : UIColor? = nil
        , borderWidth : CGFloat? = nil
        ) {
        
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
            self.clipsToBounds = true
        }
        else {
            self.layer.cornerRadius = 0
        }
        
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
        
        if borderWidth != nil {
            self.layer.borderWidth = borderWidth!
        }
        else {
            self.layer.borderWidth = 0
        }
    }
    
    

    func setImageWithDownload(_ url : URL, withIndicator isIndicator: Bool = true) {
//        self.setShowActivityIndicator(isIndicator)
//        self.setIndicatorStyle(.white)
        
        
        self.setImageWith(url, withIndicator: isIndicator)
        
//        self.setShowActivityIndicator(isIndicator)
//        self.setIndicatorStyle(.white)
//        self.kf.indicatorType = .activity
//        (self.kf.indicator?.view as? UIActivityIndicatorView)?.color = .white
////        self.image = nil
//        let resource = ImageResource(downloadURL: url, cacheKey: url.lastPathComponent)
//        self.kf.setImage(with: resource)
//
//        self.image = nil
////        self.image = ImageCache.default.retrieveImageInDiskCache(forKey: url.lastPathComponent)
//        let res = ImageResource(downloadURL: url, cacheKey: url.lastPathComponent)
//        self.kf.setImage(with: res, placeholder: nil, options: nil, progressBlock: nil) { (image, error, _, _) in
////            if error == nil && image != nil {
////                KingfisherManager.shared.cache.store(image!, forKey: url.lastPathComponent)
////            }
//        }
//
//        return
        
//        ImageCache.default.retrieveImage(forKey: url.lastPathComponent, options: nil) { (image, cacheType) in
//            if let image = image {
//                self.image = image
//            }
//        }
        
        

        
//        let cacheResult = ImageCache.default.isImageCached(forKey: url.lastPathComponent)
//        if cacheResult.cacheType == .memory {
//            self.image = ImageCache.default.retrieveImageInMemoryCache(forKey: url.lastPathComponent)
//        } else if cacheResult.cacheType == .disk {
//            self.image = ImageCache.default.retrieveImageInDiskCache(forKey: url.lastPathComponent)
//        } else {
//            self.image = nil
//            self.kf.indicatorType = .activity
//            (self.kf.indicator?.view as? UIActivityIndicatorView)?.color = .white
//            let res = ImageResource(downloadURL: url, cacheKey: url.lastPathComponent)
//            self.kf.setImage(with: res)
        
//            self.kf.setImage(with: res, placeholder: nil, options: [.processor(BlurImageProcessor(blurRadius: 4))], progressBlock: nil, completionHandler: nil)
//            self.kf.setImage(with: res, placeholder: nil, options: [.processor(BlurImageProcessor(blurRadius: 4))], progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
//                BlurImageProcessor(blurRadius: 4)
//            })
//        }
        
        //          SDWebImage Code
        
//                self.sd_setImage(with: url)
        //        self.sd_setImage(with: url, placeholderImage: UIImage(), options: [SDWebImageOptions.refreshCached, .continueInBackground, .retryFailed, .highPriority]) { (image, error, cacheType, url) in
        //        }
        
        //        self.sd_setImageWithPreviousCachedImage(with: url, placeholderImage: UIImage(), options: SDWebImageOptions.lowPriority, progress: { (a, b) in
        //
        //        }) { (image, error, catchType, url) in
        //
        //        }
        
//                self.sd_setImage(with: url, placeholderImage: UIImage(), options: [SDWebImageOptions.refreshCached, .continueInBackground, .retryFailed, .highPriority]) { (image, error, cacheType, url) in
//                    if let _ = image {
//                        self.image = image
//                    }
//                }
    }
}



//MARK:- Image Extension
extension UIImage {
    
    func isEqualToImage(_ image: UIImage) -> Bool {
        
        guard UIImagePNGRepresentation(self) != nil else {
            return false
        }
        
        guard UIImagePNGRepresentation(image) != nil else {
            return false
        }
        
        let data1: NSData = UIImagePNGRepresentation(self)! as NSData
        let data2: NSData = UIImagePNGRepresentation(image)! as NSData
        return data1.isEqual(data2)
    }
    
    func imageScale(scaledToWidth i_width: CGFloat) -> UIImage {
        let oldWidth: CGFloat = CGFloat(self.size.width)
        let scaleFactor: CGFloat = i_width / oldWidth
        let newHeight: CGFloat = self.size.height * scaleFactor
        let newWidth: CGFloat = oldWidth * scaleFactor
        UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(newWidth), height: CGFloat(newHeight)), true, 0)
        self.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(newWidth), height: CGFloat(newHeight)))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func getPostImageScaleFactor(_ i_width: CGFloat) -> CGFloat {
        
        let oldWidth: CGFloat = CGFloat(self.size.width)
        let scaleFactor: CGFloat = oldWidth / i_width 
        return scaleFactor
    }
    
    func getDeviceWiseImageScaleFactor(_ i_width: CGFloat) -> CGFloat {
        
        let oldWidth: CGFloat = CGFloat(self.size.width)
        let scaleFactor: CGFloat =  i_width / oldWidth
        return scaleFactor
    }
}
//MARK :-
extension UIToolbar {
    
    func addToolBar(_ viewController : UIViewController) -> UIToolbar {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        toolBar.backgroundColor = UIColor.white
        
        let button = UIButton(frame: CGRect(x: kScreenWidth - 60, y: 0, width: 60, height: 44))
        button.setTitle("Done", for: .normal)
        button.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 14.0,isAspectRasio: false), titleLabelColor: UIColor.black)
        button.titleLabel?.textAlignment = .right
        button.addTarget(self, action: #selector(viewController.toolBarDoneButtonClicked), for: .touchUpInside)
        
        let fixSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(customView: button)
        toolBar.setItems([fixSpace,done], animated: false)
        toolBar.sizeToFit()
        return toolBar
    }
    
}

//MARK:- String
extension String {

    
    
    func getAttributedText ( defaultDic : Dictionary<String,Any> , attributeDic : Dictionary<String,Any>, attributedStrings : [String]) -> NSMutableAttributedString {
        
        let attributeText : NSMutableAttributedString = NSMutableAttributedString(string: self, attributes: defaultDic)
        for strRange in attributedStrings {
            if let range = self.range(of: strRange) {
                let startIndex = self.distance(from: self.startIndex, to: range.lowerBound)
                let range1 = NSMakeRange(startIndex, strRange.characters.count)
                attributeText.setAttributes(attributeDic, range: range1)
            }
        }
        return attributeText
    }
    
    func findHeightForText(text: String, havingWidth widthValue: CGFloat, havingHeight heightValue: CGFloat, andFont font: UIFont) -> CGSize {
        let result: CGFloat = font.pointSize + 4
        var size: CGSize = CGSize()
        if text.characters.count > 0 {
            
            let textSize: CGSize = CGSize(width: widthValue, height: (heightValue > 0.0) ? heightValue : CGFloat.greatestFiniteMagnitude)
            //Width and height of text area
            if #available(iOS 7, *) {
                //iOS 7
                let frame: CGRect = text.boundingRect(with: textSize, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
                
                size = CGSize(width: frame.size.width, height: frame.size.height + 1)
            }
            size.height = max(size.height, result)
            //At least one row
        }
        return size
    }
    
    func sizeOfString (font : UIFont) -> CGSize {
        return self.boundingRect(with: CGSize(width: Double.greatestFiniteMagnitude, height: Double.greatestFiniteMagnitude),
                                   options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                   attributes: [NSFontAttributeName: font],
                                   context: nil).size
    }
    
    func getHeight(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func getWidth(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.width
    }
    
    func url() -> URL {
        
        guard let url = URL(string: self) else {
            return URL(string : "www.google.co.in")!
        }
        return url
    }
    
    func getHashtags() -> [String]? {
        let hashtagDetector = try? NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        let results = hashtagDetector?.matches(in: self, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, self.utf16.count)).map { $0 }
        
        return results?.map({
            (self as NSString).substring(with: $0.rangeAt(1)).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        })
    }
    
    
}
//MARK:- Date 
extension Date {
 
    //--------------------------------------------------------------------------------------
    
    //MARK: - convert date to local
    
    func convertToLocal(sourceDate : Date)-> Date{
        
        let sourceTimeZone                                     = NSTimeZone(abbreviation: "UTC")//NSTimeZone(name: "America/Los_Angeles") EDT
        let destinationTimeZone                                = NSTimeZone.system
        
        //calc time difference
        let sourceGMTOffset         : NSInteger                = (sourceTimeZone?.secondsFromGMT(for: sourceDate as Date))!
        let destinationGMTOffset    : NSInteger                = destinationTimeZone.secondsFromGMT(for:sourceDate as Date)
        let interval                : TimeInterval             = TimeInterval(destinationGMTOffset-sourceGMTOffset)
        
        //set currunt date
        let date: Date                                          = Date(timeInterval: interval, since: sourceDate as Date)
        return date
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - convert date to utc
    
    func convertToUTC(sourceDate : Date)-> Date{
        
        let sourceTimeZone                                      = NSTimeZone.system
        let destinationTimeZone                                 = NSTimeZone(abbreviation: "UTC") //NSTimeZone(name: "America/Los_Angeles") EDT
        
        //calc time difference
        let sourceGMTOffset         : NSInteger                 = (sourceTimeZone.secondsFromGMT(for:sourceDate as Date))
        let destinationGMTOffset    : NSInteger                 = destinationTimeZone!.secondsFromGMT(for: sourceDate as Date)
        let interval                : TimeInterval              = TimeInterval(destinationGMTOffset-sourceGMTOffset)
        
        //set currunt date
        let date: Date                                        = Date(timeInterval: interval, since: sourceDate as Date)
        return date
    }
    
    //------------------------------------------------------
    
    //MARK: - DateFormat
    
    func formatdateLOCAL(dt: String,dateFormat: String,formatChange: String) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = self.convertToLocal(sourceDate: dateFormatter.date(from: dt)! as Date)
        dateFormatter.dateFormat = formatChange
        return dateFormatter.string(from: date as Date)
    }
    
    func formatdateUTC(dt: String,dateFormat: String,formatChange: String) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = self.convertToUTC(sourceDate: dateFormatter.date(from: dt)! as Date)
        dateFormatter.dateFormat = formatChange
        return dateFormatter.string(from: date as Date)
    }
    
    func getTimeStampFromDate() -> (double : Double,string : String) {
        let timeStamp = self.timeIntervalSince1970
        return (timeStamp,String(format: "%f", timeStamp))
    }
    
}


//MARK:- UIViewController
extension UIViewController : UINavigationControllerDelegate {
    
    @IBAction func btnBackClicked (_ sender : UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnBackButtonClicked (_ sender : UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func toolBarDoneButtonClicked() {
        self.view.endEditing(true)
    }
    
    // add BarButton
    func addBarButtons(btnLeft : BarButton? , btnRight : BarButton? , title : String? , isSwipeBack : Bool = true) -> [UIButton] {
        
        AppDelegate.shared.isSwipeBack = isSwipeBack

        if let _ = navigationController {
            AppDelegate.shared.transitionar.addTransition(forView: (navigationController?.topViewController?.view)!)
            navigationCOntroller = navigationController
            navigationController?.delegate = AppDelegate.shared.transitionar
        }
        
        let btnFont = UIFont.applyRegular(fontSize: 13.0, isAspectRasio: false)
 
        var arrButtons : [UIButton] = [UIButton(),UIButton()]
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)]
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)]
//        self.navigationItem.titleView = UIView()


        // setup for left button
        if btnLeft != nil {
            
            let leftButton = UIButton(type: .custom)
            leftButton.contentHorizontalAlignment = .left
            
            if btnLeft?.title == String() {
                
                if btnLeft?.image != UIImage() {
                    leftButton.setImage(btnLeft?.image, for: .normal)
                    leftButton.imageView?.contentMode = .scaleAspectFit
                }
                
            }else
            {
                
                leftButton.setTitleColor(btnLeft?.color, for: .normal)
                leftButton.setTitleColor(UIColor.colorFromHex(hex: kColorGray74), for: .disabled)
                leftButton.setTitle(btnLeft?.title, for: .normal)
                leftButton.titleLabel?.font = btnFont
            }

            leftButton.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(60), height: 44)
            let leftBtnSelector: Selector = NSSelectorFromString("leftButtonClicked")
            
            if responds(to: leftBtnSelector) {
                leftButton.addTarget(self, action: leftBtnSelector, for: .touchUpInside)
            }
            
            let leftItem = UIBarButtonItem(customView: leftButton)
            
            navigationItem.leftBarButtonItems = [leftItem]
            
            arrButtons.removeFirst()
            arrButtons.insert(leftButton, at:0)
            
        }
        
        
        // setup for right button
        
        if btnRight != nil {
            
            let rightButton = UIButton(type: .custom)
            
            rightButton.contentHorizontalAlignment = .right
            rightButton.tintColor = UIColor.darkGray
          
            if btnRight?.title == String() {
                
                if btnRight?.image != UIImage() {
                    rightButton.setImage(btnRight?.image, for: .normal)
                    rightButton.imageView?.contentMode = .scaleAspectFit
                }
                
            }else
            {
                rightButton.setTitleColor(btnRight?.color, for: .normal)
                rightButton.setTitleColor(UIColor.colorFromHex(hex: kColorGray74), for: .disabled)
                rightButton.setTitle(btnRight?.title, for: .normal)
                rightButton.titleLabel?.font = btnFont
            }

            rightButton.frame = CGRect(x: 0, y: CGFloat(0), width: CGFloat(60), height: 44)
            
            let rightBtnSelector: Selector = NSSelectorFromString("rightButtonClicked")
            
            if responds(to: rightBtnSelector) {
                rightButton.addTarget(self, action: rightBtnSelector, for: .touchUpInside)
                
            }
            
            let rightItem = UIBarButtonItem(customView: rightButton)
            
            navigationItem.rightBarButtonItems = [rightItem]
            arrButtons.removeLast()
            arrButtons.append(rightButton)
            
        }


//            let titleLabel = UILabel()
//            titleLabel.text = title
//            titleLabel.applyStyle(labelFont: UIFont.applyBold(fontSize: 17.0, isAspectRasio: false) , labelColor: UIColor.white)
//            titleLabel.sizeToFit()
//            navigationItem.titleView = titleLabel

        self.navigationItem.title = title

        
        return arrButtons
    }
}

//MARK: -
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

//MARK: -
extension Collection where Iterator.Element == String {
    var initials: [String] {
        return map{String($0.characters.prefix(1))}
    }
}

//MARK: -
extension Array where Element : Hashable {
    var unique: [Element] {
        return Array(Set(self))
    }
}

//MARK: -
extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

//MARK: -
extension ActiveLabel {
    struct CustomActiveTypes {
        static let hashtag: ActiveType = ActiveType.custom(pattern: "(?i)#[\\p{L}\\d]+")
//        static let mention: ActiveType = ActiveType.custom(pattern: "(?i)@[a-z0-9_-]+")
        static let mention: ActiveType = ActiveType.custom(pattern: "(?:^|\\s|$|[.])@[\\p{L}0-9_.]*")
        
        static let url: ActiveType = ActiveType.custom(pattern: "(?i)(https?://)*[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])")
    }
    
    struct RegexParser {
        static let hashtag: ActiveType = ActiveType.custom(pattern: "(?i)#[\\p{L}\\d]+")
        static let mention: ActiveType = ActiveType.custom(pattern: "(?:^|\\s|$|[.])@[\\p{L}0-9_.]*")
    }
    
    
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        default:                                        return identifier
        }
    }
    
}
