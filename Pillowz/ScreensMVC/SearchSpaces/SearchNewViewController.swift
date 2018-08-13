//
//  SearchNewViewController.swift
//  Pillowz
//
//  Created by MCQueen on 08.08.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

class SearchNewViewController: UIViewController {
    
    var navigationBarView = UIView()
    var addressPickerView = AddressNewPickerViewController()
    var lastContentOffset:CGFloat!
    
    var shouldShowLoadingIndicator = false
    
    var superViewController: SearchSpacesViewController!
    var type = SpacesListViewControllerType.search
    
    var mainView = UIView()
    
    let posutButton = UIButton()
    let pomesButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(navigationBarView)
        navigationBarView.backgroundColor = .white
        navigationBarView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(-20)
            make.left.right.equalToSuperview()
            make.height.equalTo(108)
        }
        navigationBarView.dropShadow()
        
        navigationBarView.addSubview(addressPickerView)
        addressPickerView.saveAddressWithAPIClosure = { (address, lat, lon, placeID) in
            UserLastUsedValuesForFieldAutofillingHandler.shared.address = address
            UserLastUsedValuesForFieldAutofillingHandler.shared.lat = lat!
            UserLastUsedValuesForFieldAutofillingHandler.shared.lon = lon!
            
            self.shouldShowLoadingIndicator = true
        }
        addressPickerView.deleteAddressClosure = { () in
            UserLastUsedValuesForFieldAutofillingHandler.shared.address = ""
            UserLastUsedValuesForFieldAutofillingHandler.shared.lat = 0
            UserLastUsedValuesForFieldAutofillingHandler.shared.lon = 0
            
            self.shouldShowLoadingIndicator = true
        }
        addressPickerView.addressTextField.text = UserLastUsedValuesForFieldAutofillingHandler.shared.address
        addressPickerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(28)
            make.height.equalTo(40)
        }
        addressPickerView.addressTextFieldBottomSeparatorView.isHidden = true
        
        
        self.view.addSubview(mainView)
        mainView.backgroundColor = .white
        mainView.snp.makeConstraints { (make) in
            make.top.equalTo(addressPickerView.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        posutButton.setImage(#imageLiteral(resourceName: "posut"), for: .normal)
        mainView.addSubview(posutButton)
        posutButton.snp.makeConstraints { (make) in
            make.top.equalTo(mainView.snp.top)
            make.left.equalTo(mainView.snp.left).offset(16)
            make.right.equalTo(mainView.snp.right).offset(-16)
            make.height.equalTo(240)
        }
        
        pomesButton.setImage(#imageLiteral(resourceName: "golgosroch"), for: .normal)
        mainView.addSubview(pomesButton)
        pomesButton.snp.makeConstraints { (make) in
            make.top.equalTo(posutButton.snp.bottom).offset(16)
            make.left.equalTo(mainView.snp.left).offset(16)
            make.right.equalTo(mainView.snp.right).offset(-16)
            make.height.equalTo(240)
        }
    }
}
