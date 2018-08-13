//
//  CategoryEnum.swift
//  Pillowz
//
//  Created by Kazhenbayeva Gulnaz on 8/12/18.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

enum CategoryType: String {
    case common = "common"
    case house = "house"
    case flat = "flat"
    case room = "room"
    case bed = "bed"
    case hostel = "hostel"
    
    var title: String {
        switch self {
        case .house:
            return "Дом"
        case .flat:
            return "Квартира"
        case .room:
            return "Комната"
        case .bed:
            return "Сп. место"
        case .hostel:
            return "Хостел"
            
        default:
            return ""
        }
    }
    
    var image: UIImage! {
        switch self {
        case .house:
            return #imageLiteral(resourceName: "filter_house")
        case .flat:
            return #imageLiteral(resourceName: "filter_flat")
        case .room:
            return #imageLiteral(resourceName: "filter_house")
        case .bed:
            return #imageLiteral(resourceName: "filter_house")
        case .hostel:
            return #imageLiteral(resourceName: "filter_house")
            
        default:
            return #imageLiteral(resourceName: "filter_house")
        }
    }
    
    var icon: UIImage {
        return self.image.withRenderingMode(.alwaysTemplate)
    }
}
