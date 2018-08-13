//
//  CreateCompliantViewController.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 22.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

class CreateFeedbackViewController: PillowzViewController, ListPickerViewControllerDelegate {
    
    let sendButton = PillowzButton()
    
    var space_id:Int?
    var request_id:Int?
    var offer_id:Int?
    var user_id:Int?
    
    
    let reasonLabel: UILabel = {
        let label = UILabel()
        label.text = "Выберите причину"
        label.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        label.textColor = UIColor.black.withAlphaComponent(0.8)
        return label
    }()
    
    let reasonButton = UIButton()
    
    let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        label.textColor = UIColor.black.withAlphaComponent(0.8)
        label.text = "Описание"
        return label
    }()
    
    let descriptionTextView: TextViewWithPlaceholder = {
        let textView = TextViewWithPlaceholder()
        textView.placeholder = "Пожалуйста, расскажите нам подробно о случившемся, и мы сразу примем меры. Так вы поможете другим пользователям Pillowz в подобных ситуациях."
        textView.textValue = ""
        textView.font = UIFont.init(name: "OpenSans-Light", size: 14)!
        return textView
    }()
    
    let contactTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        label.textColor = UIColor.black.withAlphaComponent(0.8)
        label.text = "Контактный телефон"
        return label
    }()
    
    let phoneNumberView = PhoneNumberView()

    var selectedHeaderType:HeaderType = .ROUGH_TREATMENT {
        didSet {
            setTitleForSelectedHeaderType()
        }
    }
    
    override func loadView() {
        super.loadView()
        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = Constants.paletteLightGrayColor
        setupNavigationBar()
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.setTitle("Отправить", for: .normal)
    }
    
    @objc func selectHeaderTapped() {
        let listPickerVC = ListPickerViewController()
        
        var headerTypes:[Field] = []
        for headerType in HeaderType.allValues {
            let headerTypeField = Field()
            headerTypeField.value = String(headerType.rawValue)
            headerTypeField.multiLanguageName = Feedback.getDisplayNameForHeaderType(headerType: headerType)
            headerTypes.append(headerTypeField)
        }
        
        listPickerVC.values = headerTypes
        listPickerVC.delegate = self
        
        self.navigationController?.pushViewController(listPickerVC, animated: true)
    }
    
    func didPickValue(_ value: AnyObject) {
        let field = value as! Field
        selectedHeaderType = HeaderType(rawValue: Int(field.value)!)!
    }
    
    func setTitleForSelectedHeaderType() {
        reasonButton.setTitle(Feedback.getDisplayNameForHeaderType(headerType: selectedHeaderType)["ru"]!, for: .normal)
    }
    
    func didPickMultipleValues(_ values: [AnyObject]) {
        
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func sendButtonTapped() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        AuthorizationAPIManager.createFeedback(header: selectedHeaderType.rawValue, message: descriptionTextView.text!, contact_number: phoneNumberView.text, space_id:space_id, request_id:request_id, offer_id:offer_id, user_id:user_id) { (responseObject, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if (error == nil) {
                self.navigationController?.popViewController(animated: true)
                
                let infoView = ModalInfoView(titleText: "Нам жаль, что вам пришлось с этим столкнуться.", descriptionText: "Вашей жалобе присвоен уникальный номер-тикет. По нему вы сможете отслеживать статус своей жалобы в разделе профиля “Связь” - “Мои жалобы”. Мы обязательно обработаем вашу жалобу и свяжемся с вами.")
                
                infoView.addButtonWithTitle("OK", action: {
                    
                })
                
                infoView.show()
            }
        }
    }
}

extension CreateFeedbackViewController {
    
    func setupNavigationBar() {
        title = "Жалоба"
    }
    
    func setupViews() {
        self.view.addSubview(reasonLabel)
        reasonLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(21)
        }
        
        self.view.addSubview(reasonButton)
        setTitleForSelectedHeaderType()
        reasonButton.titleLabel?.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        reasonButton.setTitleColor(Constants.paletteBlackColor, for: .normal)
        reasonButton.contentHorizontalAlignment = .left
        reasonButton.addTarget(self, action: #selector(selectHeaderTapped), for: .touchUpInside)
        reasonButton.snp.makeConstraints { (make) in
            make.top.equalTo(reasonLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(20)
        }
        
        let reasonButtonImage = UIImageView()
        self.view.addSubview(reasonButtonImage)
        reasonButtonImage.image = UIImage.init(named: "arrow_down")
        reasonButtonImage.snp.makeConstraints { (make) in
            make.centerY.equalTo(reasonButton)
            make.right.equalTo(reasonButton.snp.right).offset(-5)
        }
        
        let separator1 = UIView()
        separator1.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.view.addSubview(separator1)
        separator1.snp.makeConstraints { (make) in
            make.top.equalTo(reasonButton.snp.bottom).offset(17)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(1)
        }
        
        self.view.addSubview(descriptionTitleLabel)
        descriptionTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(separator1.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        self.view.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionTitleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(90)
        }
        
        let separator2 = UIView()
        separator2.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.view.addSubview(separator2)
        separator2.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(17)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(1)
        }
        
        self.view.addSubview(contactTitleLabel)
        contactTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(separator2.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        self.view.addSubview(phoneNumberView)
        phoneNumberView.snp.makeConstraints { (make) in
            make.top.equalTo(contactTitleLabel.snp.bottom).offset(20)
            make.leading.equalTo(contactTitleLabel)
            make.height.equalTo(37)
            make.right.equalTo(contactTitleLabel)
        }
        
        self.view.addSubview(sendButton)
        self.view.bringSubview(toFront: sendButton)
        PillowzButton.makeBasicButtonConstraints(button: sendButton, pinToTop: false)
    }
}
