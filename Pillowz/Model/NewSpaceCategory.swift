//
//  NewSpaceCategory.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 27.07.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class NewSpaceCategory: NSObject {
    var name: String = ""
    var unselectedImage = UIImage()
    var selectedImage = UIImage()
    var value: String = ""
    
    init(name: String, unselectedImage: UIImage, selectedImage: UIImage, value: String) {
        self.name = name
        self.unselectedImage = unselectedImage
        self.selectedImage = selectedImage
        self.value = value
    }

}
