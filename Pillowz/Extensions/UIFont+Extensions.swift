//
//  UIFont+Extensions.swift
//  Pillowz
//
//  Created by Kazhenbayeva Gulnaz on 8/12/18.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

extension UIFont{

    struct OpenSans {
        static func regular() -> UIFont {
            return regular(size: 14)
        }
        
        static func regular(size: CGFloat) -> UIFont {
            return UIFont(name: "OpenSans-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        }
        
        static func bold() -> UIFont {
            return bold(size: 14)
        }
        
        static func bold(size: CGFloat) -> UIFont {
            return UIFont(name: "OpenSans-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }
        
        static func boldItalic() -> UIFont {
            return boldItalic(size: 14)
        }
        
        static func boldItalic(size: CGFloat) -> UIFont {
            return UIFont(name: "OpenSans-BoldItalic", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }
        
        static func italic() -> UIFont {
            return italic(size: 14)
        }
        
        static func italic(size: CGFloat) -> UIFont {
            return UIFont(name: "OpenSans-Italic", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }
        
        static func extraBold() -> UIFont {
            return extraBold(size: 14)
        }
        
        static func extraBold(size: CGFloat) -> UIFont {
            return UIFont(name: "OpenSans-ExtraBold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }
        
        static func extraBoldItalic() -> UIFont {
            return extraBoldItalic(size: 14)
        }
        
        static func extraBoldItalic(size: CGFloat) -> UIFont {
            return UIFont(name: "OpenSans-ExtraBoldItalic", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }
        
        static func light() -> UIFont {
            return light(size: 14)
        }
        
        static func light(size: CGFloat) -> UIFont {
            return UIFont(name: "OpenSans-Light", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }
        
        static func lightItalic() -> UIFont {
            return lightItalic(size: 14)
        }
        
        static func lightItalic(size: CGFloat) -> UIFont {
            return UIFont(name: "OpenSans-LightItalic", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }
        
        static func semiBold() -> UIFont {
            return semiBold(size: 14)
        }
        
        static func semiBold(size: CGFloat) -> UIFont {
            return UIFont(name: "OpenSans-SemiBold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }
    }
    

}
