//
//  AddAvailabilityView.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 11/8/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

protocol AvailabiltyViewDelegate: class {
    func addAvailability(timestampStart: Double, timestampEnd: Double)
}

class AddAvailabilityView: UIView {
    let actionView = UIView()
    
    let fromLabel = UILabel()
    let fromField = PillowTextField(keyboardType: .default, placeholder: "")
    
    let tillLabel = UILabel()
    let tillField = PillowTextField(keyboardType: .default, placeholder: "")
    
    let priceTitleLabel = UILabel()
    let priceLabel = UILabel()
    
    let countTitleLabel = UILabel()
    let countLabel = UILabel()
    
    let comissionTitleLabel = UILabel()
    let comissionLabel = UILabel()
    
    let totalTitleLabel = UILabel()
    let totalLabel = UILabel()
    
    let noteTextField = PillowTextField(keyboardType: .default, placeholder: "Примечание")
    let cancelButton = UIButton()
    let addButton = UIButton()

    let fromDatePickerView = UIDatePicker()
    let tillDatePickerView = UIDatePicker()
    
    private var fromDate = Date()
    private var tillDate = Date()
    
    weak var delegate: AvailabiltyViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        fromDatePickerView.datePickerMode = .date
        tillDatePickerView.datePickerMode = .date
        fromDatePickerView.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        tillDatePickerView.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        
        addSubview(actionView)
        actionView.backgroundColor = .white
        actionView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        actionView.addSubview(fromField)
        fromField.isEnabled = true
        fromField.inputView = fromDatePickerView
        fromField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-5)
            make.width.equalToSuperview().multipliedBy(0.7)
        }
        
        actionView.addSubview(fromLabel)
        fromLabel.text = "С"
        fromLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(fromField)
            make.leading.equalToSuperview().offset(5)
        }
        
        actionView.addSubview(tillField)
        tillField.inputView = tillDatePickerView
        tillField.snp.makeConstraints { (make) in
            make.top.equalTo(fromField.snp.bottom).offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.width.equalToSuperview().multipliedBy(0.7)
        }
        
        actionView.addSubview(tillLabel)
        tillLabel.text = "До"
        tillLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(tillField)
            make.leading.equalToSuperview().offset(5)
        }
        
        actionView.addSubview(priceTitleLabel)
        priceTitleLabel.text = "Стоимость за сутки:"
        priceTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(5)
            make.top.equalTo(tillLabel.snp.bottom).offset(10)
        }
        
        actionView.addSubview(priceLabel)
        priceLabel.text = "priceLabel"
        priceLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(priceTitleLabel)
            make.trailing.equalToSuperview().offset(-5)
        }
        
        actionView.addSubview(countTitleLabel)
        countTitleLabel.text = "Количество суток:"
        countTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(priceTitleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(5)
        }
        
        actionView.addSubview(countLabel)
        countLabel.text = "countlabel"
        countLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(countTitleLabel)
            make.trailing.equalToSuperview().offset(-5)
        }
        
        actionView.addSubview(comissionTitleLabel)
        comissionTitleLabel.text = "comissionTitleLabel"
        comissionTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(countTitleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(5)
        }
        
        actionView.addSubview(comissionLabel)
        comissionLabel.text = "comissionLabel"
        comissionLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(comissionTitleLabel)
            make.trailing.equalToSuperview().offset(-5)
        }
        
        actionView.addSubview(totalTitleLabel)
        totalTitleLabel.text = "totalTitleLabel"
        totalTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(comissionTitleLabel.snp.bottom)
            make.leading.equalToSuperview().offset(5)
        }
        
        actionView.addSubview(totalLabel)
        totalLabel.text = "totalLabel"
        totalLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(totalTitleLabel)
            make.trailing.equalToSuperview().offset(-5)
        }
        
        actionView.addSubview(noteTextField)
        noteTextField.snp.makeConstraints { (make) in
            make.top.equalTo(totalTitleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        actionView.addSubview(cancelButton)
        cancelButton.setTitleColor(Constants.paletteBlueColor, for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        cancelButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-5)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        actionView.addSubview(addButton)
        addButton.setTitleColor(Constants.paletteBlueColor, for: .normal)
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        addButton.setTitle("Add", for: .normal)
        addButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(10)
        }
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        if sender === self.fromDatePickerView {
            fromDate = sender.date
            self.fromField.text = dateFormatter.string(from: sender.date)
        } else {
            tillDate = sender.date
            self.tillField.text = dateFormatter.string(from: sender.date)
        }
        
    }
    
    @objc func cancelButtonAction(){
        self.removeFromSuperview()
    }
    
    @objc func addButtonAction(){
        guard let from = self.fromField.text,
        let till = self.tillField.text,
            !from.isEmpty, !till.isEmpty
        else {
            print("One of the field is empty")
            return
        }
        
        delegate?.addAvailability(timestampStart: fromDate.timeIntervalSince1970, timestampEnd: tillDate.timeIntervalSince1970)
        
        self.removeFromSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
