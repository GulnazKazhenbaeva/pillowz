//
//  Extensions.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 04.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIColor {
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

public extension UITableView {
    public func beginRefreshing() {
        // Make sure that a refresh control to be shown was actually set on the view
        // controller and the it is not already animating. Otherwise there's nothing
        // to refresh.
        guard let refreshControl = refreshControl, !refreshControl.isRefreshing else {
            return
        }
        
        // Start the refresh animation
        refreshControl.beginRefreshing()
        
        // Make the refresh control send action to all targets as if a user executed
        // a pull to refresh manually
        refreshControl.sendActions(for: .valueChanged)
        
        // Apply some offset so that the refresh control can actually be seen
        let contentOffset = CGPoint(x: 0, y: -refreshControl.frame.height)
        setContentOffset(contentOffset, animated: true)
    }
    
    public func endRefreshing() {
        refreshControl?.endRefreshing()
    }
}

public extension UIImage {
    func rotateImage() -> UIImage {
        if (self.imageOrientation == UIImageOrientation.up ) {
            return self
        }
        
        UIGraphicsBeginImageContext(self.size)
        
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return copy!
    }
}


extension Int {
    var lastDigit: Int {
        get {
            var number = self
            var array = [Int]()
            while number > 0 {
                array.append(number % 10)
                number = number/10
            }
            array.reverse()
            return array.last!
        }
    }
    var firstDigit: Int {
        get {
            var number = self
            var array = [Int]()
            while number > 0 {
                array.append(number % 10)
                number = number/10
            }
            array.reverse()
            return array.first!
        }
    }
}

