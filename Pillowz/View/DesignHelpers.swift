//
//  DesignHelpers.swift
//  Pillowz
//
//  Created by Samat on 24.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SnapKit
import CRToast
import SevenSwitch

class DesignHelpers: NSObject {
    class func makeToastWithText(_ text:String) {
        let font = UIFont(name: "OpenSans-SemiBold", size: 16)!
        let textHeight = text.height(withConstrainedWidth: Constants.screenWidth - 20, font: font)
        let type: CRToastType = (textHeight > 44) ? .custom : .navigationBar
        var timeInterval: Double = (textHeight > 44) ? Double(textHeight * 1.5/44) : 1.5

        var options: [String: Any] = [kCRToastTextKey: text,
                                      kCRToastTextAlignmentKey: NSTextAlignment.center,
                                      kCRToastBackgroundColorKey: Constants.paletteVioletColor.withAlphaComponent(0.95),
                                      kCRToastAnimationInTypeKey: CRToastAnimationType.linear.rawValue,
                                      kCRToastAnimationOutTypeKey: CRToastAnimationType.linear.rawValue,
                                      kCRToastAnimationInDirectionKey: CRToastAnimationDirection.top.rawValue,
                                      kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.top.rawValue,
                                      kCRToastFontKey: font,
                                      kCRToastNotificationTypeKey: type.rawValue,
                                      kCRToastNotificationPresentationTypeKey: CRToastPresentationType.cover.rawValue,
                                      kCRToastAnimationInTimeIntervalKey: TimeInterval(0.2),
                                      kCRToastAnimationOutTimeIntervalKey: TimeInterval(0.2),
                                      kCRToastTimeIntervalKey: TimeInterval(timeInterval)]
        if type == .custom {
            options[kCRToastNotificationPreferredHeightKey] = NSNumber(value: Int(textHeight) + 20)
        }

        CRToastManager.dismissAllNotifications(true)
        
        CRToastManager.showNotification(options: options) {
            
        }
    }
    
    class func setStyleForDatePicker(datePicker:UIDatePicker) {
        datePicker.backgroundColor = .white
        datePicker.setValue(Constants.paletteVioletColor, forKey:"textColor")
    }
    
    class func setBasicSettingsForTabVC(viewController:ButtonBarPagerTabStripViewController) {
        viewController.automaticallyAdjustsScrollViewInsets = false
        
        //viewController.buttonBarView.selectedBar
        
        viewController.buttonBarView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview()
            make.height.equalTo(38)
        }
//
//        viewController.containerView.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(38)
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//            make.bottom.equalToSuperview()
//        }
        
        let separatorView = UIView()
        viewController.view.addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(38)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        separatorView.backgroundColor = UIColor(hexString: "#E0E0E0")
        
        // Do any additional setup after loading the view.
        viewController.buttonBarView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        viewController.buttonBarView.selectedBar.backgroundColor = Constants.paletteVioletColor
        viewController.settings.style.buttonBarBackgroundColor = UIColor(white: 1.0, alpha: 1.0)
        viewController.settings.style.buttonBarItemBackgroundColor = UIColor(white: 1.0, alpha: 1.0)
        //viewController.settings.style.selectedBarBackgroundColor = Constants.paletteVioletColor
        viewController.settings.style.buttonBarItemTitleColor = Constants.paletteBlackColor
        viewController.settings.style.buttonBarItemFont = UIFont(name: "OpenSans-Regular", size: 13)!
        viewController.settings.style.buttonBarMinimumLineSpacing = 0
        viewController.settings.style.buttonBarItemsShouldFillAvailableWidth = false
        //viewController.settings.style.buttonBarLeftContentInset = Constants.basicOffset
        //viewController.settings.style.buttonBarRightContentInset = 0
        viewController.settings.style.selectedBarHeight = 2
        //viewController.settings.style.buttonBarHeight = 1
        
//        viewController.changeCurrentIndexProgressive = { [weak viewController] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
//            guard changeCurrentIndex == true else { return }
//            oldCell?.label.textColor = Constants.paletteBlackColor //UIColor(white: 0.6, alpha: 0.5)
//            newCell?.label.textColor = Constants.paletteBlackColor
//        }
    }
    
    class func setStyleForRoleSwitch(roleSwitch:SevenSwitch) {
        roleSwitch.offLabel.text = "Владелец"
        roleSwitch.onLabel.text = "Гость"
        roleSwitch.offLabel.font = UIFont.init(name: "OpenSans-Regular", size: 17)
        roleSwitch.onLabel.font = UIFont.init(name: "OpenSans-Regular", size: 17)
        
        roleSwitch.thumbTintColor = .white
        roleSwitch.onThumbTintColor = UIColor(hexString: "#FA533C")
        roleSwitch.activeColor =  .white
        roleSwitch.inactiveColor =  UIColor(hexString: "#FA533C")
        roleSwitch.onTintColor =  .white
        roleSwitch.borderColor = UIColor.clear
        roleSwitch.onLabel.textColor = Constants.paletteBlackColor
        roleSwitch.offLabel.textColor = .white
        roleSwitch.shadowColor = .black
        roleSwitch.dropShadow()
    }
}

extension UIView {
    func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 2
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension UILabel {
    func setLightGrayStyle() {
        self.font = UIFont.init(name: "OpenSans-Regular", size: 10)!
        self.textColor = Constants.paletteLightGrayColor
    }
}

extension ConstraintMaker {
    public func aspectRatio(_ x: Int, by y: Int, self instance: ConstraintView) {
        self.width.equalTo(instance.snp.height).multipliedBy(x / y)
    }
}

extension UIButton {
    func addCenterImage(_ image:UIImage, color:UIColor) {
        let imageView = UIImageView()
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        imageView.fillImageView(image: image, color: color)
        imageView.contentMode = .center
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 35.0,
            left: 0.0,
            bottom: 0.0,
            right: 0.0
        )
    }
}

extension UIImageView {
    func fillImageView(image:UIImage, color:UIColor) {
        let originalImage = image
        //need this to color the stars as we need
        let templateImage = originalImage.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
    
    class func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 3.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension UIButton {
    func fillImageView(image:UIImage, color:UIColor) {
        let originalImage = image
        //need this to color the stars as we need
        let templateImage = originalImage.withRenderingMode(.alwaysTemplate)
        self.setImage(templateImage, for: .normal) 
        self.tintColor = color
    }
}


struct AppFontName {
    static let regular = "OpenSans-Regular"
    static let bold = "OpenSans-Bold"
    static let italic = "OpenSans-Italic"
}

extension UIFontDescriptor.AttributeName {
    static let nsctFontUIUsage =
        UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

extension UIFont {
    
    @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.regular, size: size)!
    }
    
    @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.bold, size: size)!
    }
    
    @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.italic, size: size)!
    }
    
    @objc convenience init(myCoder aDecoder: NSCoder) {
        if let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor {
            if let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String {
                var fontName = ""
                switch fontAttribute {
                case "CTFontRegularUsage":
                    fontName = AppFontName.regular
                case "CTFontEmphasizedUsage", "CTFontBoldUsage":
                    fontName = AppFontName.bold
                case "CTFontObliqueUsage":
                    fontName = AppFontName.italic
                default:
                    fontName = AppFontName.regular
                }
                self.init(name: fontName, size: fontDescriptor.pointSize)!
            }
            else {
                self.init(myCoder: aDecoder)
            }
        }
        else {
            self.init(myCoder: aDecoder)
        }
    }
    
    class func overrideInitialize() {
        if self == UIFont.self {
            let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:)))
            let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:)))
            method_exchangeImplementations(systemFontMethod!, mySystemFontMethod!)
            
            let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:)))
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:)))
            method_exchangeImplementations(boldSystemFontMethod!, myBoldSystemFontMethod!)
            
            let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:)))
            let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:)))
            method_exchangeImplementations(italicSystemFontMethod!, myItalicSystemFontMethod!)
            
            let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))) // Trick to get over the lack of UIFont.init(coder:))
            let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:)))
            method_exchangeImplementations(initCoderMethod!, myInitCoderMethod!)
        }
    }
}
