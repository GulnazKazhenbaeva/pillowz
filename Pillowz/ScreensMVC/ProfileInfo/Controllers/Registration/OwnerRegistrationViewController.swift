//
//  OwnerRegistrationViewController.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 11/1/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit
import MBProgressHUD
import SevenSwitch

protocol OwnerRegistrationPageDelegate: class {
    func signUpAction(owner: Realtor)
}

class OwnerRegistrationViewController: RegistrationViewController, UITextFieldDelegate {
    var registrationForm: RegistrationForm!
    var dataViewHeight: CGFloat = 315
    let nameField = PillowTextField(keyboardType: .default, placeholder: "Ваше имя?*")
    let personIdField = PillowTextField(keyboardType: .numberPad, placeholder: "ИИН")
    let phoneNumberView = PhoneNumberView()
    let passwordField = PillowTextField(keyboardType: .default, placeholder: "Введите пароль*")
    let repeatPasswordField = PillowTextField(keyboardType: .default, placeholder: "Повторите пароль*")
    let showPasswordLabel = UILabel()
    
    var realtorModeCompletion: Bool = false
    
    override func loadView() {
        super.loadView()
        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
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
        
        personIdField.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text!.count + (string.count - range.length)) > 12 {
            return false
        }
        
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let scrollViewHeight = registrationForm.guideLabel.frame.height + dataViewHeight + registrationForm.nextButton.frame.height + 260
        registrationForm.scrollView.contentSize = CGSize(width: view.frame.width, height: scrollViewHeight)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    @objc func privacyPolicyLabelTapped() {
        let viewController = WebViewPageViewController()
        
        viewController.link = "https://pillowz.kz/terms"
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    @objc func showPasswordAction(){
        self.passwordField.isSecureTextEntry = !self.passwordField.isSecureTextEntry
        showPasswordLabel.text = (self.passwordField.isSecureTextEntry) ? "Показать" : "Скрыть"
    }
    
    @objc func nextButtonTapped() {
        if realtorModeCompletion == false {
            signUpAction()
        } else {
            updateUserPersonId()
        }
    }
    
    func updateUserPersonId() {
        guard let personId = personIdField.text, !personId.isEmpty
            else {
                DesignHelpers.makeToastWithText("Заполните все поля")
                return
        }
        
        let rtypeField = Field()
        rtypeField.param_name = "rtype"
        rtypeField.value = "0"
        
        let personIDField = Field()
        personIDField.param_name = "person_id"
        personIDField.value = personId
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        AuthorizationAPIManager.updateRealtorProfile(profileFields: [rtypeField, personIDField], completion: { (userObject, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if (error == nil) {
                DesignHelpers.makeToastWithText("Профиль обновлен")
                
                self.navigationController?.popToRootViewController(animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    ProfileTabViewController.shared.profileVC.changeRole(SevenSwitch())
                }
            }
        })
    }
    
    func signUpAction(){
        if passwordField.text != repeatPasswordField.text {
            DesignHelpers.makeToastWithText("Пароли не совпали")
            
            return
        }
        
        
        var phone:String
        
        phone = phoneNumberView.text
        
        guard let name = nameField.text,
            let personId = personIdField.text,
            let password = passwordField.text,
            !name.isEmpty, !personId.isEmpty, !phone.isEmpty, !password.isEmpty
            else {
                DesignHelpers.makeToastWithText("Заполните все поля")
                return
        }
        
        let owner = Realtor(business_name: "", verified: false, person_name: "", full: false, contact_number: "", certificate: "", business_id: "", person_id: personId, address: "", email: "", rtype_display: "", rtype: .owner, certificates:[])
        
        let window = UIApplication.shared.delegate!.window!!
        
        MBProgressHUD.showAdded(to: window, animated: true)
        
        AuthorizationAPIManager.signUp(as: owner, username:phone, name:name, password:password, country:phoneNumberView.country!.iso!, withSocialNetwork: haveSocialNetwork) { (user, error) in
            MBProgressHUD.hide(for: window, animated: true)
            
            if (error == nil) {
                if !RegistrationViewController.shared.hasPhone {
                    let confirmationPage = SignUpConfirmationViewController()
                    confirmationPage.userPhone = phone
                    confirmationPage.codeConfirmationMode = .signUp
                    self.navigationController?.pushViewController(confirmationPage, animated: true)
                } else {
                    ProfileTabViewController.shared.setupDisplayingView()
                }
            }
        }
    }
}

extension OwnerRegistrationViewController {
    func setupNavigationBar() {
        navigationItem.title = "Владелец"
    }
    func setupViews() {
        if realtorModeCompletion {
            dataViewHeight = 87
        }
        registrationForm = RegistrationForm(dataViewHeight: dataViewHeight, windowColor: Constants.paletteVioletColor)
        view.addSubview(registrationForm)
        registrationForm.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        if realtorModeCompletion {
            registrationForm.guideLabel.text = Constants.realtorModeCompletionText
            registrationForm.privacyPolicyLabel.isHidden = true
            registrationForm.nextButton.setTitle("Далее", for: .normal)
        }
        registrationForm.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        let showPrivacyPolicyGesture = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyLabelTapped))
        registrationForm.privacyPolicyLabel.addGestureRecognizer(showPrivacyPolicyGesture)
        
        setupTextFields()
    }
    func setupTextFields() {
        let height: CGFloat = 37
        if realtorModeCompletion == false {
            registrationForm.dataView.addSubview(nameField)
            nameField.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.8)
                make.height.equalTo(height)
            }
        }
        registrationForm.dataView.addSubview(personIdField)
        personIdField.snp.makeConstraints { (make) in
            if realtorModeCompletion == false {
                make.top.equalTo(nameField.snp.bottom).offset(20)
            } else {
                make.top.equalToSuperview().offset(20)
            }
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(height)
        }
        
        if realtorModeCompletion == false {
            registrationForm.dataView.addSubview(phoneNumberView)
            phoneNumberView.snp.makeConstraints { (make) in
                make.top.equalTo(personIdField.snp.bottom).offset(20)
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
}
