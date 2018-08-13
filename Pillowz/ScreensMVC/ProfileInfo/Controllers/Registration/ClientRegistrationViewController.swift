//
//  ClientRegistrationViewController.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 10/31/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit
import MBProgressHUD

class ClientRegistrationViewController: RegistrationViewController {
   
    var registrationForm: RegistrationForm!
    var dataViewHeight: CGFloat = 258
    let phoneNumberView = PhoneNumberView()
    let nameField = PillowTextField(keyboardType: .default, placeholder: "Ваше имя?*")
    let passwordField = PillowTextField(keyboardType: .default, placeholder: "Введите пароль*")
    let repeatPasswordField = PillowTextField(keyboardType: .default, placeholder: "Повторите пароль*")
    let showPasswordLabel = UILabel()
    
    override func loadView() {
        super.loadView()
        setupViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        checkForSocialNetworkData()
        
        if (RegistrationViewController.shared.socialNetworkInfo != nil) {
            if (RegistrationViewController.shared.socialNetworkInfo!["fullName"] != "") {
                nameField.text = RegistrationViewController.shared.socialNetworkInfo!["fullName"]!
            }
            
            if (self.edittedPhoneNumberWithoutCode != nil) {
                phoneNumberView.phoneNumberTextField.text = self.edittedPhoneNumberWithoutCode
            }
            
            if (RegistrationViewController.shared.socialNetworkInfo!["email"] != "") {
                //emailField.text = RegistrationViewController.shared.socialNetworkInfo!["email"]!
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let scrollViewHeight = registrationForm.guideLabel.frame.height + dataViewHeight + registrationForm.nextButton.frame.height + 260
        registrationForm.scrollView.contentSize = CGSize(width: view.frame.width, height: scrollViewHeight)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func showPasswordAction(){
        self.passwordField.isSecureTextEntry = !self.passwordField.isSecureTextEntry
        showPasswordLabel.text = (self.passwordField.isSecureTextEntry) ? "Показать" : "Скрыть"
    }
    
    @objc func privacyPolicyLabelTapped() {
        let viewController = WebViewPageViewController()
        
        viewController.link = "https://pillowz.kz/terms"
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func signUpAction(){
        if passwordField.text != repeatPasswordField.text {
            DesignHelpers.makeToastWithText("Пароли не совпали")
            
            return
        }
        
        var phone:String
        
        phone = phoneNumberView.text
        
        guard let name = nameField.text,
              let password = passwordField.text,
              let countryIso = phoneNumberView.country?.iso,
              !name.isEmpty, !phone.isEmpty, !password.isEmpty, !countryIso.isEmpty
        else {
            DesignHelpers.makeToastWithText("Заполните все поля")

            print("Error: one of the field is empty")
            return
        }
        
        let window = UIApplication.shared.delegate!.window!!
        
        MBProgressHUD.showAdded(to: window, animated: true)
        
        AuthorizationAPIManager.signUp(as: nil, username:phone, name:name, password:password, country:countryIso, withSocialNetwork: haveSocialNetwork) { (user, error) in
            MBProgressHUD.hide(for: window, animated: true)

            if (error == nil) {
                if !RegistrationViewController.shared.hasPhone {
                    let confirmationPage = SignUpConfirmationViewController()
                    confirmationPage.userPhone = phone
                    confirmationPage.userName = name
                    confirmationPage.codeConfirmationMode = .signUp
                    self.navigationController?.pushViewController(confirmationPage, animated: true)
                } else {
                    ProfileTabViewController.shared.setupDisplayingView()
                }
            }
        }
    }
}

extension ClientRegistrationViewController {
    func setupNavigationBar() {
        navigationItem.title = "Клиент"
    }
    func setupViews() {
        registrationForm = RegistrationForm(dataViewHeight: dataViewHeight, windowColor: Constants.paletteVioletColor)
        view.addSubview(registrationForm)
        registrationForm.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
        }
        let showPrivacyPolicyGesture = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyLabelTapped))
        registrationForm.privacyPolicyLabel.addGestureRecognizer(showPrivacyPolicyGesture)
        
        registrationForm.nextButton.addTarget(self, action: #selector(signUpAction), for: .touchUpInside)

        setupTextFields()
    }
    func setupTextFields() {
        let height: CGFloat = 37
        registrationForm.dataView.addSubview(nameField)
        nameField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(height)
        }
        
        registrationForm.dataView.addSubview(phoneNumberView)
        phoneNumberView.snp.makeConstraints { (make) in
            make.top.equalTo(nameField.snp.bottom).offset(20)
            make.leading.equalTo(nameField)
            make.height.equalTo(height)
            make.right.equalTo(nameField)
        }
        
        registrationForm.dataView.addSubview(passwordField)
        passwordField.autocapitalizationType = .none
        passwordField.isSecureTextEntry = true
        passwordField.snp.makeConstraints { (make) in
            make.top.equalTo(phoneNumberView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(height)
        }
        
        registrationForm.dataView.addSubview(repeatPasswordField)
        repeatPasswordField.autocapitalizationType = .none
        repeatPasswordField.isSecureTextEntry = true
        repeatPasswordField.snp.makeConstraints { (make) in
            make.top.equalTo(passwordField.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(height)
        }
        
        
        let showPasswordGesture = UITapGestureRecognizer(target: self, action: #selector(showPasswordAction))
        registrationForm.dataView.addSubview(showPasswordLabel)
        showPasswordLabel.textColor = Constants.paletteVioletColor
        showPasswordLabel.text = "Показать"
        showPasswordLabel.addGestureRecognizer(showPasswordGesture)
        showPasswordLabel.isUserInteractionEnabled = true
        showPasswordLabel.font = showPasswordLabel.font.withSize(15)
        showPasswordLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(passwordField)
            make.right.equalTo(passwordField.snp.right)
        }
    }
}
