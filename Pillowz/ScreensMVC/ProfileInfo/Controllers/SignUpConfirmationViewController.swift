//
//  SignUpConfirmationViewController.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 10/31/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

enum CodeConfirmationMode {
    case resetPassword
    case signUp
}

class SignUpConfirmationViewController: PillowzViewController {
    let guideLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "OpenSans-Regular", size: 16)!
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()
    let dataView = UIView()
    let codeField = PillowTextField(keyboardType: .numberPad, placeholder: "Введите полученный код")
    let timerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "OpenSans-SemiBold", size: 14)!
        label.textColor = UIColor.black.withAlphaComponent(0.38)
        label.textAlignment = .center
        return label
    }()
    let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Неверый код подтверждения."
        label.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        label.textColor = UIColor.init(hexString: "#F10C6F")
        return label
    }()
    let errorImageView = UIImageView(image: UIImage.init(named: "error"))
    var codeConfirmationMode: CodeConfirmationMode?
    var userPhone: String?
    var userName: String?
    var confirmButton = PillowzButton()
    
    var seconds = 30
    var timer = Timer()
    var isTimerRunning = false
    
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
        
        let timerLabelTap = UITapGestureRecognizer(target: self, action: #selector(timerLabelTapped))
        timerLabel.addGestureRecognizer(timerLabelTap)
        
        guideLabel.text = "Вам отправлен\nкод подтверждения на номер\n" + userPhone!
        timerLabel.text = "Отправить код повторно через \(seconds) сек"
        codeField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runTimer()
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if seconds != 0 {
            seconds -= 1
            timerLabel.text = "Отправить код повторно через \(seconds) сек"
        } else {
            timerLabel.text = "Отправить код повторно"
            timerLabel.textColor = Constants.paletteVioletColor
            timerLabel.isUserInteractionEnabled = true
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func timerLabelTapped() {
        //TO DO: send new code request
        seconds = 30
        timerLabel.text = "Отправить код повторно через \(seconds) сек"
        timerLabel.textColor = UIColor.black.withAlphaComponent(0.38)
        timerLabel.isUserInteractionEnabled = false
        runTimer()
    }
    
    func showErrorInfo() {
        self.errorLabel.isHidden = false
        self.errorImageView.isHidden = false
    }
    
    func hideErrorInfo() {
        self.errorLabel.isHidden = true
        self.errorImageView.isHidden = true
    }
    
    @objc func confirmAction(){
        guard let code = codeField.text, !code.isEmpty else {

            return
        }
        
        AuthorizationAPIManager.codeConfirmation(mode: self.codeConfirmationMode!, phone: self.userPhone!, code: code) { (userObject, error) in
            if (error == nil) {
                self.timer.invalidate()
                
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
                
                if User.currentRole == .realtor {
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    MainTabBarController.shared.selectedIndex = 0
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let vc = UIApplication.topViewController() as? RealtorSpacesViewController
                        vc?.createNewObjectTapped()
                    }
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                self.codeField.text = ""
                self.showErrorInfo()
            }
        }
    }
}

extension SignUpConfirmationViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        hideErrorInfo()
        return true
    }
}

extension SignUpConfirmationViewController {
    func setupNavigationBar() {
        if codeConfirmationMode == CodeConfirmationMode.signUp {
            navigationItem.title = "Завершение регистрации"
        } else {
            navigationItem.title = "Изменение пароля"
        }
    }
    func setupViews() {
        view.addSubview(guideLabel)
        guideLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(128)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        view.addSubview(dataView)
        dataView.backgroundColor = .white
        dataView.snp.makeConstraints { (make) in
            make.top.equalTo(guideLabel.snp.bottom).offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(103)
        }
        
        dataView.addSubview(codeField)
        codeField.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(37)
        }
        
        dataView.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(codeField.snp.bottom).offset(7)
            make.left.equalTo(codeField)
            make.height.equalTo(16)
        }
        
        dataView.addSubview(errorImageView)
        errorImageView.snp.makeConstraints { (make) in
            make.top.equalTo(codeField.snp.bottom).offset(7)
            make.right.equalTo(codeField)
            make.height.width.equalTo(15)
        }
        
        view.addSubview(timerLabel)
        let timerLabelGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(timerLabelTapped))
        timerLabel.addGestureRecognizer(timerLabelGesture)
        timerLabel.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        timerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dataView.snp.bottom).offset(37)
            make.left.equalToSuperview().offset(35)
            make.right.equalToSuperview().offset(-35)
            make.height.equalTo(36)
        }

        self.view.addSubview(confirmButton)
        PillowzButton.makeBasicButtonConstraints(button: confirmButton, pinToTop: false)
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        hideErrorInfo()
    }
}
