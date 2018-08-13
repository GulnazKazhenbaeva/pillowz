//
//  DatePickerTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 02.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol DatePickerTableViewCellDelegate {
    func didPickDate(date:Date)
}

class DatePickerTableViewCell: StringValueTableViewCell {
    let datePickerView = UIDatePicker()
    private var chosenDate:Date? {
        didSet {
            valuePickerTextField.text = dateFormatter.string(from: chosenDate!)
        }
    }
    var profileViewController:UserProfileViewController!

    let dateFormatter = DateFormatter()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        dateFormatter.dateFormat = "dd.MM.yyyy"

        isSmallHeader = true
        
        valuePickerTextField.isEnabled = true
        valuePickerTextField.inputView = datePickerView
        
        datePickerView.datePickerMode = .date
        DesignHelpers.setStyleForDatePicker(datePicker: datePickerView)

        datePickerView.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker){
        chosenDate = sender.date
        
        profileViewController.didPickDate(date: chosenDate!)
    }

    override func fillWithObject(object: AnyObject) {
        profileViewController = object as! UserProfileViewController
        
        if (profileViewController.birthdayField.value != "") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"

            let date = dateFormatter.date(from: profileViewController.birthdayField.value)

            if (date != nil) {
                chosenDate = date
            }
        }
        
        if (profileViewController.user_id != nil) {
            valuePickerTextField.isUserInteractionEnabled = false
            valuePickerTextField.placeholder = "Не указано"
        }
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
