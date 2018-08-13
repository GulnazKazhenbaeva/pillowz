//
//  RangeSliderPickerTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 25.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class RangeSliderPickerTableViewCell: HeaderIncludedTableViewCell, RangeSeekSliderDelegate {
    let rangeSlider = RangeSeekSlider()
    let isEnabledButton = UIButton()
    
    var didPickRangeValueClosure:DidPickRangeValueClosure!
    
    var field:Field!
    
    var min:Int = 0 {
        didSet {
            rangeSlider.minValue = CGFloat(min)
            rangeSlider.selectedMinValue = CGFloat(min)
        }
    }
    
    var max:Int = 100 {
        didSet {
            rangeSlider.maxValue = CGFloat(max)
            rangeSlider.selectedMaxValue = CGFloat(max)
        }
    }
    
    var isEnabled = true {
        didSet {
            setStyleEnabled(true)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(rangeSlider)
        rangeSlider.snp.makeConstraints { (make) in
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.bottom.equalToSuperview()
        }
        rangeSlider.lineHeight = 5
        rangeSlider.handleBorderWidth = 1
        rangeSlider.handleDiameter = 27
        rangeSlider.delegate = self
        
        self.contentView.addSubview(isEnabledButton)
        isEnabledButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(headerLabel.snp.centerY)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.equalTo(77)
            make.height.equalTo(28)
        }
        isEnabledButton.layer.cornerRadius = 14
        isEnabledButton.layer.borderWidth = 1
        isEnabledButton.setTitle("любой", for: .normal)
        isEnabledButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
        isEnabledButton.titleLabel?.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        isEnabledButton.isHidden = true
        
        isEnabledButton.addTarget(self, action: #selector(isEnabledTapped), for: .touchUpInside)
        
        isEnabled = true
        setStyleEnabled(isEnabled)
    }
    
    func setStyleEnabled(_ enabled:Bool) {
        if (enabled) {
            rangeSlider.tintColor = UIColor(hexString: "#EBEFF2")
            rangeSlider.colorBetweenHandles = Constants.paletteVioletColor
//            rangeSlider.tintColorBetweenHandles = Constants.paletteVioletColor
            rangeSlider.handleColor = .white
            rangeSlider.handleBorderColor = Constants.paletteVioletColor
            rangeSlider.minLabelColor = Constants.paletteBlackColor
            rangeSlider.maxLabelColor = Constants.paletteBlackColor
            
            isEnabledButton.layer.borderColor = UIColor.clear.cgColor
        } else {
            rangeSlider.tintColor = UIColor(hexString: "#EBEFF2")
//            rangeSlider.tintColorBetweenHandles = UIColor(hexString: "#EBEFF2")
            rangeSlider.handleColor = .white
            rangeSlider.handleBorderColor = UIColor(hexString: "#EBEFF2")
            rangeSlider.minLabelColor = UIColor(hexString: "#EBEFF2")
            rangeSlider.maxLabelColor = UIColor(hexString: "#EBEFF2")
            
            isEnabledButton.layer.borderColor = Constants.paletteVioletColor.cgColor
        }
    }
    
    @objc func isEnabledTapped() {
        isEnabled = !isEnabled
        
        if !isEnabled {
            didPickRangeValueClosure(nil, nil)
            
            rangeSlider.selectedMinValue = rangeSlider.minValue
            rangeSlider.selectedMaxValue = rangeSlider.maxValue
        }
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        if (!isEnabled) {
            isEnabled = true
        }
        didPickRangeValueClosure(Int(minValue), Int(maxValue))
        
        if (maxValue==rangeSlider.maxValue && minValue==rangeSlider.minValue) {
            isEnabled = false
        }
    }
        
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
