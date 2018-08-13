//
//  RequestFinishedViewController.swift
//  Pillowz
//
//  Created by Samat on 23.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class RequestFinishedViewController: PillowzViewController {
    let titleLabel = UILabel()
    let infoLabel = UILabel()
    let dismissButton = UIButton()
    let topDismissButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = Constants.paletteVioletColor
        
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(77)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(74)
        }
        titleLabel.textColor = .white
        titleLabel.text = "Отлично! Ваша заявка успешно создана и будет активна в течение 24 часов."
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 18)!
        titleLabel.numberOfLines = 0
        
        self.view.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(26)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(150)
        }
        infoLabel.textColor = .white
        infoLabel.text = "Теперь Вы можете просматривать\nпредложения от арендодателей.\n\nВыберите наиболее подходящее\nвам предложение и согласуйте\nдетали с арендодателем, написав ему\nсообщение, либо позвонив по номеру."
        infoLabel.textAlignment = .center
        infoLabel.font = UIFont.init(name: "OpenSans-Light", size: 14)!
        infoLabel.numberOfLines = 0

        self.view.addSubview(dismissButton)
        dismissButton.snp.makeConstraints { (make) in
            make.top.equalTo(infoLabel.snp.bottom).offset(26)
            make.centerX.equalToSuperview()
            make.width.equalTo(225)
            make.height.equalTo(40)
        }
        dismissButton.layer.cornerRadius = 20
        dismissButton.layer.borderColor = UIColor.white.cgColor
        dismissButton.layer.borderWidth = 1
        dismissButton.titleLabel?.textColor = .white
        dismissButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        dismissButton.setTitle("Посмотреть заявку", for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        self.view.addSubview(topDismissButton)
        topDismissButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(37)
            make.left.equalToSuperview().offset(17)
            make.width.height.equalTo(40)
        }
        topDismissButton.setImage(UIImage(named: "closeWhite"), for: .normal)
        topDismissButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
    }
    
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
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
