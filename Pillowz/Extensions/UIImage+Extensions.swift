//
//  UIImage+Extensions.swift
//  Pillowz
//
//  Created by Kazhenbayeva Gulnaz on 8/12/18.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

extension UIViewController {

    public func createImage(withName name: String) -> UIImage {
        return UIImage.init(named: name)!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    }
}
