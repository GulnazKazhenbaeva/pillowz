//
//  SignUpController.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 10/24/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

class SignUpViewController: PillowzViewController {
    var topView = UIView()
    
    let firstCheckButton = UIButton()
    let clientLabel = UILabel()
    
    let secondCheckButton = UIButton()
    let ownerLabel = UILabel()
    
    var realtorModeCompletion: Bool = false
    
    override func loadView() {
        super.loadView()
        
        setupViews()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func firstCheckerButtonAction(){
        firstCheckButton.isSelected = true
        secondCheckButton.isSelected = false
        
        realtorModeCompletion = false
    }
    
    @objc func secondCheckerButtonAction(){
        secondCheckButton.isSelected = true
        firstCheckButton.isSelected = false
        
        realtorModeCompletion = false
    }
        
    @objc func openOwnerRegistrationPage() {
        let viewController = OwnerRegistrationViewController()
        viewController.realtorModeCompletion = false
        navigationController?.pushViewController(viewController, animated: true)
        
        User.currentRole = .realtor
    }
    
    @objc func moveToNextPage() {
        if firstCheckButton.isSelected {
            let nextPage = ClientRegistrationViewController()
            navigationController?.pushViewController(nextPage, animated: true)
        } else {
            openOwnerRegistrationPage()
        }
    }
}

extension SignUpViewController {
    func setupNavigationBar() {
        navigationItem.title = "Регистрация"

        let rightButton: UIButton = UIButton(type: .custom)
        rightButton.setTitle("Далее", for: .normal)
        rightButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
        rightButton.titleLabel?.font = UIFont.init(name: "OpenSans-SemiBold", size: 15)!
        rightButton.addTarget(self, action: #selector(moveToNextPage), for: .touchUpInside)
        rightButton.frame = CGRect(x:0, y:0, width:60, height:40)
        let rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func setupViews() {
        let labelArray = [clientLabel, ownerLabel]
        
        for label in labelArray {
            label.textColor = UIColor.init(hexString: "#333333")
            label.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        }
        
        if realtorModeCompletion == false {
            setupTopView()
        }
    }
    func setupTopView() {
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.left.right.equalToSuperview()
            make.height.equalTo(200)
        }
        
        topView.addSubview(clientLabel)
        clientLabel.text = "Я ищу жилье"
        clientLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(Constants.basicOffset)
            make.trailing.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(50)
        }
        
        topView.addSubview(firstCheckButton)
        firstCheckButton.setImage(UIImage.init(named: "unchecked"), for: .normal)
        firstCheckButton.setImage(UIImage.init(named: "checked"), for: .selected)
        firstCheckButton.isSelected = true
        firstCheckButton.addTarget(self, action: #selector(firstCheckerButtonAction), for: .touchUpInside)
        firstCheckButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(clientLabel.snp.height)
            make.centerY.equalTo(clientLabel)
            make.right.equalToSuperview()
        }
        
        topView.addSubview(ownerLabel)
        ownerLabel.text = "Я сдаю жилье"
        ownerLabel.snp.makeConstraints { (make) in
            make.leading.trailing.height.equalTo(clientLabel)
            make.top.equalTo(clientLabel.snp.bottom)
        }
        
        topView.addSubview(secondCheckButton)
        secondCheckButton.setImage(UIImage.init(named: "unchecked"), for: .normal)
        secondCheckButton.setImage(UIImage.init(named: "checked"), for: .selected)
        secondCheckButton.isSelected = false
        secondCheckButton.addTarget(self, action: #selector(secondCheckerButtonAction), for: .touchUpInside)
        secondCheckButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(firstCheckButton)
            make.centerY.equalTo(ownerLabel)
            make.right.equalToSuperview()
        }
    }
}
