//
//  AddressPickerTextField.swift
//  Pillowz
//
//  Created by Samat on 11.02.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import GooglePlaces
import MBProgressHUD

class AddressPickerView: UIView, UITextFieldDelegate {
    let getCurrentLocationButton = UIButton()
    let addressTextFieldBottomSeparatorView = UIView()
    let addressTextField = UITextField()
    
    var saveAddressWithAPIClosure:SaveAddressWithAPIClosure!

    init() {
        super.init(frame: CGRect.zero)
        
        self.addSubview(addressTextField)
        addressTextField.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-60)
        }
        addressTextField.placeholder = "Адрес"
        addressTextField.delegate = self
        addressTextField.font = UIFont.systemFont(ofSize: 16, weight: .light)
        addressTextField.textColor = Constants.paletteBlackColor
        
        self.addSubview(getCurrentLocationButton)
        getCurrentLocationButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.width.height.equalTo(50)
        }
        getCurrentLocationButton.setImage(#imageLiteral(resourceName: "detectLocation"), for: .normal)
        getCurrentLocationButton.addTarget(self, action: #selector(getCurrentPlace), for: .touchUpInside)
        
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
                        
                        self.saveAddressWithAPIClosure?(placemark.formattedAddress, centerPosition.latitude, centerPosition.longitude, nil)

                    }
                } else {
                    UIApplication.topViewController()?.view.makeToast("Не удалось определить местоположение")
                }
            }
        } else {
            
            UIApplication.topViewController()?.view.makeToast("Не удалось определить местоположение")
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

extension AddressPickerView: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.saveAddressWithAPIClosure?(place.name, place.coordinate.latitude, place.coordinate.longitude, place.placeID)
        
        UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
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

