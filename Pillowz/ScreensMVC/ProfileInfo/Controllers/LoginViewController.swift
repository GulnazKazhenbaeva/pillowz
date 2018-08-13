//
//  LoginViewController.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 10/24/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit
import GoogleSignIn
import MBProgressHUD

class LoginViewController: PillowzViewController, GIDSignInUIDelegate, SocialNetworksPickerViewDelegate, SocialNetworksHandlerDelegate {
    let logoView = UIView()
    let socialButtonsView = UIView()
    let textfieldsView = UIView()
    let signInView = UIView()
    let signUpView = UIView()
    
    let logoImageView = UIImageView()
    let phoneField = PhoneNumberTextfield()//PillowTextField(keyboardType: .phonePad, placeholder: "Номер телефона или email")
    let passwordField = PillowTextField(keyboardType: .emailAddress, placeholder: "Пароль")
    let forgotLabel = UILabel()
    let loginButton = PillowzButton()
//    let signupLabel = UILabel()

//    let changeRoleButton = UIButton()
    
//    let socialNetworksPickerView = SocialNetworksPickerView()
    let socialNetworksHandler = SocialNetworksHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socialNetworksHandler.delegate = self
        
        ProfileTabViewController.shared.navigationItem.title = "Профиль"
        
        if let token = FBSDKAccessToken.current() {
            print(token.tokenString)
        }
    
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
//    @objc func changeRoleTapped() {
//        if (User.currentRole == .realtor) {
//            User.currentRole = .client
//            changeRoleButton.setTitle("Перейти в режим риэлтора", for: .normal)
//        } else {
//            User.currentRole = .realtor
//            changeRoleButton.setTitle("Перейти в режим клиента", for: .normal)
//        }
//    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func loadView() {
        super.loadView()
        view.backgroundColor = Constants.paletteLightGrayColor
        setupViews()
    }
    
    @objc func signInAction(){
        if let phone = phoneField.text?.replacingOccurrences(of: " ", with: ""), let password = passwordField.text, !phone.isEmpty, !password.isEmpty {
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            AuthorizationAPIManager.signIn(username: phone, password: password) { (userObject, error) in
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if (error == nil) {
                    ProfileTabViewController.shared.setupDisplayingView()
                    
                    if let navigationController = self.navigationController {
                        for controller in navigationController.viewControllers as Array {
                            if controller.isKind(of: NewPersonalRequestViewController.self) {
                                self.navigationController?.popToViewController(controller, animated: true)
                                
                                return
                            }
                        }
                        
                        for controller in navigationController.viewControllers as Array {
                            if controller.isKind(of: OpenRequestStepsViewController.self) {
                                self.navigationController?.popToViewController(controller, animated: true)
                                
                                return
                            }
                        }
                        
                        for controller in navigationController.viewControllers as Array {
                            if controller.isKind(of: RequestOrOfferViewController.self) {
                                self.navigationController?.popToViewController(controller, animated: true)
                                
                                return
                            }
                        }
                    }

                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    @objc func forgotPasswordAction(){
        let viewController = ForgotPasswordViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func socialNetworkTapped(socialNetwork: SocialNetworkLinks) {
        // TO DO: through instagram registration code is not confirmed
        socialNetworksHandler.getTokenForSocialNetwork(socialNetwork)
    }
    
    func didPickToken(_ token: String, fromSocialNetwork socialNetwork: SocialNetworkLinks) {
        AuthorizationAPIManager.signUpViaSocialNetwork(socialNetwork, token: token, completion: { (userObject, error) in
            if (error == nil) {
                if (userObject is User) {
                    ProfileTabViewController.shared.setupDisplayingView()
                } else {
                    let socialNetworkInfo = userObject as! [String:String]
                                    
                    RegistrationViewController.shared.socialNetworkInfo = socialNetworkInfo
                    RegistrationViewController.shared.accessToken = token
                    RegistrationViewController.shared.socialType = socialNetwork
                    
                    let viewController = SignUpViewController()
                    ProfileTabViewController.shared.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            
        })
    }
}

extension LoginViewController {
    func setupViews() {
        let height = self.view.frame.height - 113
        view.addSubview(logoView)
        logoView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(height * 0.3)
        }
        
        logoView.addSubview(logoImageView)
        logoImageView.image = #imageLiteral(resourceName: "blackLogo")
        logoImageView.contentMode = .center
        logoImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
//        view.addSubview(socialButtonsView)
//        socialButtonsView.backgroundColor = .white
//        socialButtonsView.snp.makeConstraints { (make) in
//            make.height.equalTo(36 + 2*10)
//            make.left.right.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-15)
//        }
//        socialButtonsView.addSubview(socialNetworksPickerView)
//        socialNetworksPickerView.superViewController = self
//        socialNetworksPickerView.snp.makeConstraints { (make) in
//            make.top.left.bottom.right.equalToSuperview()
//        }
        
        view.addSubview(textfieldsView)
        textfieldsView.backgroundColor = .white
        textfieldsView.snp.makeConstraints { (make) in
            make.top.equalTo(logoImageView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(height * 0.225)
        }
        setupTextFields()
        
        view.addSubview(signInView)
        signInView.backgroundColor = .clear
        signInView.snp.makeConstraints { (make) in
            make.top.equalTo(textfieldsView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(height * 0.375/2)
        }
        
        signInView.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(signInAction), for: .touchUpInside)
        loginButton.setTitle("Войти", for: .normal)
        loginButton.titleLabel?.font = UIFont.init(name: "OpenSans-SemiBold", size: 13)!
        loginButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(40)
        }
        
        view.addSubview(signUpView)
        signUpView.backgroundColor = .clear
        signUpView.snp.makeConstraints { (make) in
            make.top.equalTo(signInView.snp.bottom)
            make.leading.trailing.height.equalTo(signInView)
        }
    }
    
    func setupTextFields() {
        let topSpace = (self.view.frame.height * 0.225)/3
        
        textfieldsView.addSubview(phoneField)
        phoneField.snp.makeConstraints { (make) in
            make.top.equalTo(topSpace - 18)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        textfieldsView.addSubview(passwordField)
        passwordField.autocapitalizationType = .none
        passwordField.isSecureTextEntry = true
        passwordField.snp.makeConstraints { (make) in
            make.top.equalTo(topSpace * 2 - 18)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        let forgotPasswordGesture = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordAction))
        textfieldsView.addSubview(forgotLabel)
        forgotLabel.isUserInteractionEnabled = true
        forgotLabel.addGestureRecognizer(forgotPasswordGesture)
        forgotLabel.textColor = Constants.paletteVioletColor
        forgotLabel.font = forgotLabel.font.withSize(15)
        forgotLabel.text = "Забыли?"
        forgotLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(passwordField)
            make.right.equalTo(passwordField.snp.right).offset(-5)
        }
    }
}
