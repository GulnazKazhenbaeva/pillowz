//
//  Helpers.swift
//  Pillowz
//
//  Created by Samat on 19.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class Helpers: NSObject {
    class func returnSuffix(count: Int, type: String) -> String {
        var str = ""
        if (count % 10 == 1 && count != 11) {
            if type == "day" {
                str = "сутки"
            } else if type == "guest" {
                str = "гость"
            } else if type == "hour" {
                str = "час"
            } else if type == "month" {
                str = "месяц"
            }
        } else if count % 10 > 1 && count % 10 < 5 && count/10 != 1 {
            if type == "day" {
                str = "суток"
            } else if type == "guest" {
                str = "гостя"
            } else if type == "hour" {
                str = "часа"
            } else if type == "month" {
                str = "месяца"
            }
        } else {
            if type == "day" {
                str = "суток"
            } else if type == "guest" {
                str = "гостей"
            } else if type == "hour" {
                str = "часов"
            } else if type == "month" {
                str = "месяцев"
            }
        }
        return str
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension Int {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

