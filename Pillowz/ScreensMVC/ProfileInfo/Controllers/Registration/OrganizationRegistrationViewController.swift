//
//  OrganizationRegistrationViewController.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 11/3/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

protocol OrganizationRegistrationPageDelegate: class {
    func signUpAction(organization: Realtor)
    func uploadPhoto()
}

class OrganizationRegistrationViewController: RegistrationViewController, UploadCertificatePageDelegate {
    
    var certificates:[Certificate] = []
    
    var rtype: RealtorType = .owner {
        didSet {
            //        hotelRegistrationViewController.rtype = 3
            //        realEstateAgencyViewController.rtype = 2
            print("OrganizationRegistrationViewController: rtype was changed to \(rtype)")
        }
    }
    var registrationForm: RegistrationForm!
    var dataViewHeight: CGFloat = 543
    let nameField = PillowTextField(keyboardType: .default, placeholder: "Ваше имя?*")
    let organizationNameField = PillowTextField(keyboardType: .default, placeholder: "Наименование организации*")
    let businessIdField = PillowTextField(keyboardType: .numberPad, placeholder: "БИН*")
    let contactNumberField = PillowTextField(keyboardType: .numberPad, placeholder: "Контактный телефон*")
    let addressField = PillowTextField(keyboardType: .default, placeholder: "Адрес")
    let emailField = PillowTextField(keyboardType: .emailAddress, placeholder: "Контактный email")
    let certificateField = PillowTextField(keyboardType: .default, placeholder: "")
    let phoneNumberView = PhoneNumberView()
    let passwordField = PillowTextField(keyboardType: .default, placeholder: "Введите пароль*")
    let showPasswordLabel = UILabel()
    let uploadButton: UIButton = {
        let button = UIButton()
        button.semanticContentAttribute = .forceRightToLeft
        button.titleLabel?.font = UIFont.init(name: "OpenSans-Light", size: 12)!
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 3, 0, -3)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 3)
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 3)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("3 файла", for: .normal)
        button.setImage(UIImage.init(named: "Right arrow"), for: .normal)
        return button
    }()
    
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
                emailField.text = RegistrationViewController.shared.socialNetworkInfo!["email"]!
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func uploadCertificate(){
        let uploadCertificatePage = UploadCertificatePage()
        uploadCertificatePage.delegate = self
        uploadCertificatePage.certificates = self.certificates
        navigationController?.pushViewController(uploadCertificatePage, animated: true)
    }
    
    @objc func showPasswordAction(){
        self.passwordField.isSecureTextEntry = !self.passwordField.isSecureTextEntry
        showPasswordLabel.text = (self.passwordField.isSecureTextEntry) ? "Показать" : "Скрыть"
    }
    
    @objc func nextButtonTapped() {
        if realtorModeCompletion == false {
            signUpAction()
        } else {
            //TO DO: Send additional realtor data to server
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func signUpAction(){
        var phone:String
        
        phone = phoneNumberView.text
        
        guard let name = nameField.text,
              let organizationName = organizationNameField.text,
              let businessId = businessIdField.text,
              let contactNumber = contactNumberField.text,
              let address = addressField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !name.isEmpty, !organizationName.isEmpty, !businessId.isEmpty, !contactNumber.isEmpty, !address.isEmpty,
                 !email.isEmpty, !phone.isEmpty, !password.isEmpty
            else {
                print("One of the field is empty")
                return
        }
                
        let organization = Realtor(business_name: organizationName, verified: false, person_name: "", full: false, contact_number: contactNumber, certificate: "", business_id: businessId, person_id: "", address: address, email: email, rtype_display: "", rtype: self.rtype, certificates: certificates)
        
        AuthorizationAPIManager.signUp(as: organization, username:phone, name:name, password:password, country:phoneNumberView.country!.iso!, withSocialNetwork: haveSocialNetwork) { (user, error) in
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
    
    func didUploadCertificates(_ certificates: [Certificate]) {
        self.certificates = certificates
    }
}


extension OrganizationRegistrationViewController {
    func setupNavigationBar() {
        if rtype == .agency {
            navigationItem.title = "Агенство недвижимости"
        } else if rtype == .hotel {
            navigationItem.title = "Гостиница/Хостел"
        }
    }
    func setupViews() {
        if realtorModeCompletion {
            dataViewHeight = 353
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
        let space: CGFloat = 20
        
        if realtorModeCompletion == false {
            registrationForm.dataView.addSubview(nameField)
            nameField.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(space)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.8)
                make.height.equalTo(height)
            }
        }
        
        registrationForm.dataView.addSubview(organizationNameField)
        organizationNameField.snp.makeConstraints { (make) in
            if realtorModeCompletion == false {
                make.top.equalTo(nameField.snp.bottom).offset(space)
            } else {
                make.top.equalToSuperview().offset(space)
            }
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(height)
        }
        
        registrationForm.dataView.addSubview(businessIdField)
        businessIdField.snp.makeConstraints { (make) in
            make.top.equalTo(organizationNameField.snp.bottom).offset(space)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(height)
        }
        
        registrationForm.dataView.addSubview(contactNumberField)
        contactNumberField.snp.makeConstraints { (make) in
            make.top.equalTo(businessIdField.snp.bottom).offset(space)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(height)
        }
        
        registrationForm.dataView.addSubview(emailField)
        emailField.autocapitalizationType = .none
        emailField.snp.makeConstraints { (make) in
            make.top.equalTo(contactNumberField.snp.bottom).offset(space)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(height)
        }
        
        registrationForm.dataView.addSubview(addressField)
        addressField.snp.makeConstraints { (make) in
            make.top.equalTo(emailField.snp.bottom).offset(space)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(height)
        }
        
        registrationForm.dataView.addSubview(certificateField)
        certificateField.text = "Свидетельство"
        certificateField.textColor = UIColor.black.withAlphaComponent(0.87)
        certificateField.font = UIFont.init(name: "OpenSans-Regular", size: 16)!
        certificateField.isEnabled = false
        certificateField.snp.makeConstraints { (make) in
            make.top.equalTo(addressField.snp.bottom).offset(space)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(height)
        }
        
        registrationForm.dataView.addSubview(uploadButton)
        uploadButton.addTarget(self, action: #selector(uploadCertificate), for: .touchUpInside)
        uploadButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(certificateField)
            make.right.equalTo(certificateField.snp.right)
        }
        
        if realtorModeCompletion == false {
            registrationForm.dataView.addSubview(phoneNumberView)
            phoneNumberView.snp.makeConstraints { (make) in
                make.top.equalTo(certificateField.snp.bottom).offset(20)
                make.leading.equalTo(nameField)
                make.height.equalTo(height)
                make.right.equalTo(nameField)
            }
            
            registrationForm.dataView.addSubview(passwordField)
            passwordField.autocapitalizationType = .none
            passwordField.isSecureTextEntry = true
            passwordField.snp.makeConstraints { (make) in
                make.top.equalTo(phoneNumberView.snp.bottom).offset(space)
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
                make.right.equalTo(passwordField.snp.right).offset(5)
            }
        }
    }
}
