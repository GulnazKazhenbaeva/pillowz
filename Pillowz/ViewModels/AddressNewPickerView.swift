//
//  AddressNewPickerViewController.swift
//  Pillowz
//
//  Created by MCQueen on 08.08.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import GooglePlaces
import MBProgressHUD


class AddressNewPickerViewController: UIView, UITextFieldDelegate, AddressPickerDelegate {
    
    let getCurrentLocationButton = UIButton()
    let openMapButton = UIButton()
    let deleteAddressButton = UIButton()
    let addressTextFieldBottomSeparatorView = UIView()
    let addressTextField = UITextField()
    
    var saveAddressWithAPIClosure: SaveAddressWithAPIClosure!
    var deleteAddressClosure: DeleteAddressClosure?
    
    
    var text:String {
        get {
            if (addressTextField.text == nil) {
                return ""
            }
            
            return addressTextField.text!
        }
        set {
            addressTextField.text = newValue
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        
        //addressTextField.borderStyle = .roundedRect
        
        addressTextField.layer.borderWidth = 1.0
        addressTextField.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1).cgColor
        addressTextField.layer.cornerRadius = 16
        
        self.addSubview(addressTextField)
        addressTextField.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.height.equalTo(34)
        }
        //addressTextField.placeholder = "Введите город, район или улицу"
        addressTextField.textAlignment = .center
        addressTextField.delegate = self
        addressTextField.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        addressTextField.textColor = Constants.paletteBlackColor
        
        addressTextField.attributedPlaceholder = "Введите город, район или улицу".attributedString(aligment: .center)
        
        self.addSubview(deleteAddressButton)
        deleteAddressButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(44)
            make.width.equalTo(30)
        }
        deleteAddressButton.setImage(#imageLiteral(resourceName: "clear"), for: .normal)
        deleteAddressButton.addTarget(self, action: #selector(deleteAddress), for: .touchUpInside)
        
        self.addSubview(openMapButton)
        openMapButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(addressTextField.snp.left).offset(-10)
            make.height.equalTo(34)
            make.width.equalTo(34)
        }
        openMapButton.setImage(#imageLiteral(resourceName: "Subtract"), for: .normal)
        openMapButton.addTarget(self, action: #selector(openMap), for: .touchUpInside)
        
        self.addSubview(addressTextFieldBottomSeparatorView)
        addressTextFieldBottomSeparatorView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(1)
        }
        addressTextFieldBottomSeparatorView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        
        self.bringSubview(toFront: getCurrentLocationButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openMap() {
        let vc = MapAddressPickerViewController()
        vc.delegate = self
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didPickAddress(address: String, lat: Double, lon: Double) {
        self.addressTextField.text = address
        
        self.saveAddressWithAPIClosure?(address, lat, lon, nil)
    }
    
    @objc func deleteAddress() {
        self.addressTextField.text = ""
        deleteAddressClosure?()
    }
    
    @objc func getCurrentPlace() {
        if (LocationManager.shared.currentLocation != nil) {
            let centerPosition = LocationManager.shared.currentLocation!
            
            let window = UIApplication.shared.delegate!.window!!
            
            MBProgressHUD.showAdded(to: window, animated: true)
            
            SVGeocoder.reverseGeocode(centerPosition) { (placemarks, response, error) in
                MBProgressHUD.hide(for: window, animated: true)
                
                if (error == nil) {
                    if placemarks!.count != 0 {
                        let placemark = placemarks![0] as! SVPlacemark
                        
                        let locality = placemark.locality
                        
                        if (locality != nil && locality != "") {
                            self.addressTextField.text = locality
                            
                            self.saveAddressWithAPIClosure?(locality!, centerPosition.latitude, centerPosition.longitude, nil)
                        } else if let fullAddress = placemark.formattedAddress {
                            self.addressTextField.text = fullAddress
                            
                            self.saveAddressWithAPIClosure?(fullAddress, centerPosition.latitude, centerPosition.longitude, nil)
                        } else {
                            DesignHelpers.makeToastWithText("Не удалось определить местоположение")
                        }
                    }
                } else {
                    DesignHelpers.makeToastWithText("Не удалось определить местоположение")
                }
            }
        } else {
            DesignHelpers.makeToastWithText("Не удалось определить местоположение")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        autocompleteController.modalPresentationStyle = .custom
        autocompleteController.modalTransitionStyle = .crossDissolve
        UIApplication.topViewController()?.present(autocompleteController, animated: true, completion: nil)
    }
}

extension AddressNewPickerViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.addressTextField.text = place.name
        
        self.saveAddressWithAPIClosure?(place.name, place.coordinate.latitude, place.coordinate.longitude, place.placeID)
        
        UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension String {
    func attributedString(aligment: NSTextAlignment) -> NSAttributedString {
        return NSAttributedString(text: self, aligment: aligment)
    }
}

extension NSAttributedString {
    convenience init(text: String, aligment: NSTextAlignment) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = aligment
        self.init(string: text, attributes: [NSAttributedStringKey.paragraphStyle: paragraphStyle])
    }
}


