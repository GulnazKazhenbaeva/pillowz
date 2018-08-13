//
//  GuestRoleViewController.swift
//  Pillowz
//
//  Created by Samat on 26.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import Pastel
import SevenSwitch

class GuestRoleViewController: PillowzViewController {
    let topBackButton = UIButton()
    let roleSwitch = SevenSwitch()
    
//    let socialNetworksPickerView = SocialNetworksPickerView()
    
    let socialNetworksLabel = UILabel()
    let roleSwitchLabel = UILabel()

    let signInButton = UIButton()
    let signUpButton = UIButton()
    let orLabel = UILabel()
    
    let logoImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let pastelView = PastelView(frame: view.bounds)
        
        pastelView.startPastelPoint = .topLeft
        pastelView.endPastelPoint = .bottomRight

        pastelView.animationDuration = 2.0
        
        pastelView.setColors([UIColor(hexString: "#FA533C"),
                              Constants.paletteVioletColor])
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)

        self.view.addSubview(self.topBackButton)
        self.topBackButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(44)
        }
        self.topBackButton.setImage(#imageLiteral(resourceName: "backWhite"), for: .normal)
        self.topBackButton.addTarget(self, action: #selector(self.backTapped), for: .touchUpInside)
        
        
//        self.view.addSubview(socialNetworksPickerView)
//        //socialNetworksPickerView.superViewController = superViewController
//        socialNetworksPickerView.snp.makeConstraints { (make) in
//            make.height.equalTo(36 + 2*10)
//            make.left.right.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-15)
//        }
        
//        self.view.addSubview(socialNetworksLabel)
//        socialNetworksLabel.snp.makeConstraints { (make) in
//            make.height.equalTo(16)
//            make.left.right.equalToSuperview()
//            make.bottom.equalTo(socialNetworksPickerView.snp.top).offset(-8)
//        }
//        self.addInfoLabelStyle(socialNetworksLabel)
//        socialNetworksLabel.text = "Войти с помощью:"
        
        
        self.view.addSubview(self.roleSwitch)
        self.roleSwitch.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-25)
            make.centerX.equalToSuperview()
            make.height.equalTo(37)
            make.width.equalTo(170)
        }
        roleSwitch.addTarget(self, action: #selector(changeRole(_ :)), for: .valueChanged)
        DesignHelpers.setStyleForRoleSwitch(roleSwitch: roleSwitch)
        
        
        self.view.addSubview(roleSwitchLabel)
        roleSwitchLabel.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(roleSwitch.snp.top).offset(-8)
        }
        self.addInfoLabelStyle(roleSwitchLabel)
        roleSwitchLabel.text = "Режим"
        
        
        self.view.addSubview(signUpButton)
        signUpButton.snp.makeConstraints { (make) in
            make.width.equalTo(258)
            make.height.equalTo(38)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(roleSwitchLabel.snp.top).offset(-40)
        }
        self.addWhiteButtonStyle(signUpButton)
        signUpButton.setTitle("Зарегистрироваться", for: .normal)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        
        self.view.addSubview(orLabel)
        orLabel.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(signUpButton.snp.top).offset(-8)
        }
        self.addInfoLabelStyle(orLabel)
        orLabel.text = "или"
        
        
        self.view.addSubview(signInButton)
        signInButton.snp.makeConstraints { (make) in
            make.width.equalTo(258)
            make.height.equalTo(38)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(orLabel.snp.top).offset(-8)
        }
        self.addWhiteButtonStyle(signInButton)
        signInButton.setTitle("Войти", for: .normal)
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        
        
        self.view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.top.equalTo(topBackButton.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(signInButton.snp.top)
        }
        logoImageView.contentMode = .center
        logoImageView.image = #imageLiteral(resourceName: "splashLogo")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        roleSwitch.on = User.currentRole == .client
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func signInTapped() {
        let loginVC = LoginViewController()
        self.navigationController?.pushViewController(loginVC, animated: true)
    }

    @objc func signUpTapped() {
        RegistrationViewController.shared.socialNetworkInfo = nil
        RegistrationViewController.shared.accessToken = nil
        RegistrationViewController.shared.socialType = nil
        
        let viewController = SignUpViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func changeRole(_ sender:SevenSwitch) {
        if (sender.isOn()) {
            User.currentRole = .client
            
            let infoView = ModalInfoView(titleText: "Вы переходите в режим гостя", descriptionText: "В режиме гостя вы сможете выбрать нужное вам жилье и отправить на него персональную заявку. Также вы можете создать общую заявку и дождаться предложений от владельцев. В окне “Мои заявки” вы увидите их статус.")
            
            infoView.addButtonWithTitle("Перейти в поиск", action: {
                MainTabBarController.shared.selectedIndex = 0
                
                self.navigationController?.popToRootViewController(animated: true)
            })
            
            infoView.show()
        } else {
            User.currentRole = .realtor
            
            let infoView = ModalInfoView(titleText: "Вы переходите в режим владельца", descriptionText: "В режиме владельца вы сможете добавить свои объекты недвижимости, просматривать их статус и получать персональные заявки на них. Также вы можете выбирать клиентов среди общих заявок.")
            
            infoView.addButtonWithTitle("Перейти к заявкам", action: {
                MainTabBarController.shared.selectedIndex = 2
                
                self.navigationController?.popToRootViewController(animated: true)
            })
                        
            infoView.show()
        }
    }

    func addInfoLabelStyle(_ label:UILabel) {
        label.textColor = UIColor(white: 1, alpha: 0.5)
        label.textAlignment = .center
        label.font = UIFont.init(name: "OpenSans-Regular", size: 13)
    }
    
    func addWhiteButtonStyle(_ button:UIButton) {
        button.setTitleColor(Constants.paletteBlackColor, for: .normal)
        button.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 17)
        button.layer.cornerRadius = 19
        button.backgroundColor = .white
        button.dropShadow()
    }
    
    @objc func switchChanged(sender:SevenSwitch) {
        
    }
    
    @objc func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
