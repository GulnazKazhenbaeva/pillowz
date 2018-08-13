//
//  PhoneNumberView.swift
//  Pillowz
//
//  Created by Samat on 13.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class PhoneNumberView: UIView, ListPickerViewControllerDelegate, UITextFieldDelegate {
    let phoneNumberTextField = PillowTextField(keyboardType: .phonePad, placeholder: "Ваш номер телефона*")
    let countryPickerButton = UIButton()
    let pickerImageView = UIImageView()
    let countryBottomSeparatorView = UIView()
    
    var country:Country? {
        didSet {
            self.countryPickerButton.setTitle(country!.code!, for: .normal)
        }
    }
    
    var text:String {
        get {
            if (country != nil) {
                return country!.code! + phoneNumberTextField.text!
            } else {
                return ""
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(countryPickerButton)
        countryPickerButton.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(55)
        }
        countryPickerButton.contentHorizontalAlignment = .left
        countryPickerButton.addTarget(self, action: #selector(pickCountryTapped), for: .touchUpInside)
        countryPickerButton.setTitleColor(Constants.paletteBlackColor, for: .normal)
        countryPickerButton.titleLabel?.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        
        self.addSubview(pickerImageView)
        pickerImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(50)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }
        pickerImageView.image = #imageLiteral(resourceName: "arrow_down")
        pickerImageView.contentMode = .center
        
        self.addSubview(phoneNumberTextField)
        phoneNumberTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(78)
            make.right.top.bottom.equalToSuperview()
        }
        phoneNumberTextField.delegate = self
        
        self.addSubview(countryBottomSeparatorView)
        countryBottomSeparatorView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(62)
            make.height.equalTo(1)
            make.bottom.equalToSuperview().offset(5)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadedCountries), name: Notification.Name(Constants.loadedCountriesNotification), object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if (CategoriesHandler.sharedInstance.countries.count != 0) {
                self.country = CategoriesHandler.sharedInstance.countries.first
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text!.count + (string.count - range.length)) > 10 {
            return false
        }
        
        return true
    }

    
    @objc func pickCountryTapped() {
        if (CategoriesHandler.sharedInstance.countries.count == 0) {
            CategoriesHandler.sharedInstance.getCountries()
        } else {
            openListVC()
        }
    }
    
    @objc func loadedCountries() {
        openListVC()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constants.loadedCountriesNotification), object: nil)
    }
    
    func openListVC() {
        let vc = ListPickerViewController()
        vc.values = CategoriesHandler.sharedInstance.countries
        vc.delegate = self
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didPickValue(_ value: AnyObject) {
        self.country = value as? Country
    }
    
    func didPickMultipleValues(_ values: [AnyObject]) {
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
