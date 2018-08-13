//
//  ForgotPasswordViewController.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 10/24/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

class ForgotPasswordViewController: PillowzViewController {
    let guideLabel: UILabel = {
        let label = UILabel()
        label.text = "Укажите номер телефона для восстановления доступа"
        label.font = UIFont.init(name: "OpenSans-Regular", size: 16)!
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let dataView = UIView()
    let numberCodeField = PillowTextField(keyboardType: .default, placeholder: "")
    let phoneNumberField = PhoneNumberTextfield()//PillowTextField(keyboardType: .phonePad, placeholder: "Номер телефона или email*")
    let passwordField = PillowTextField(keyboardType: .default, placeholder: "Введите новый пароль*")
    let showPasswordLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.paletteVioletColor
        label.font = label.font.withSize(15)
        label.isUserInteractionEnabled = true
        label.text = "Показать"
        return label
    }()
    let nextButton = PillowzButton()
    
    override func loadView() {
        super.loadView()
        setupViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func showPasswordAction(){
        self.passwordField.isSecureTextEntry = !self.passwordField.isSecureTextEntry
        showPasswordLabel.text = (self.passwordField.isSecureTextEntry) ? "Показать" : "Скрыть"
    }

    @objc func moveToNextPage(){
        guard let phone = phoneNumberField.text?.replacingOccurrences(of: " ", with: ""),
              let newPassword = passwordField.text,
              !phone.isEmpty, !newPassword.isEmpty
        else {
            print("One of the field is empty")
            return
        }
        
        AuthorizationAPIManager.resetPassword(phone: phone, newPassword: newPassword) { (response, error) in
            if (error == nil) {
                let viewController = SignUpConfirmationViewController()
                viewController.userPhone = phone
                viewController.codeConfirmationMode = .resetPassword
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                let infoView = ModalInfoView(titleText: "Указанный номер телефона не зарегистрирован в Pillowz. ", descriptionText: "Проверьте правильность его написания или зарегистрируйте новый аккаунт.")
                
                infoView.addButtonWithTitle("OK", action: {

                })
                
                infoView.show()
            }
        }
    }
}

extension ForgotPasswordViewController {
    func setupNavigationBar() {
        navigationItem.title = "Забыли пароль?"
        
        let nextButton = UIBarButtonItem(title: "Далее", style: .plain, target: self, action: #selector(moveToNextPage))
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = Constants.paletteVioletColor
        self.navigationItem.rightBarButtonItem = nextButton
    }
    func setupViews() {
        view.addSubview(guideLabel)
        guideLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(128)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        view.addSubview(dataView)
        dataView.backgroundColor = .white
        dataView.snp.makeConstraints { (make) in
            make.top.equalTo(guideLabel.snp.bottom).offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(144)
        }
        
        dataView.addSubview(phoneNumberField)
        phoneNumberField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(37)
        }
        
        dataView.addSubview(passwordField)
        passwordField.autocapitalizationType = .none
        passwordField.isSecureTextEntry = true
        passwordField.snp.makeConstraints { (make) in
            make.top.equalTo(phoneNumberField.snp.bottom).offset(Constants.basicOffset)
            make.left.right.equalTo(phoneNumberField)
            make.height.equalTo(phoneNumberField.snp.height)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        let showPasswordLabelTap = UITapGestureRecognizer(target: self, action: #selector(showPasswordAction))
        dataView.addSubview(showPasswordLabel)
        showPasswordLabel.addGestureRecognizer(showPasswordLabelTap)
        showPasswordLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(passwordField)
            make.right.equalTo(passwordField.snp.right).offset(-5)
        }
    }
}
