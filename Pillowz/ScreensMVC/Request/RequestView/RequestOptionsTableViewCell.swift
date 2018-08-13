//
//  RequestOptionsTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 17.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol RequestOptionsTableViewCellDelegate {
    func rejectTapped()
    func chatTapped()
    func callTapped()
}

class RequestOptionsTableViewCell: UITableViewCell {
    let rejectButton = UIButton()
    let chatButton = UIButton()
    let callButton = UIButton()
    let disabledTextLabel = UILabel()
    
    var request:Request? {
        didSet {
            setupEnabledViews()
        }
    }
    
    var offer:Offer? {
        didSet {
            setupEnabledViews()
        }
    }
    
    var delegate:RequestOptionsTableViewCellDelegate?

    var showRejectButton:Bool = true {
        didSet {
            rejectButton.isHidden = !showRejectButton
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    func setupViews() {
        self.contentView.addSubview(rejectButton)
        rejectButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo((Constants.screenFrame.size.width-2*Constants.basicOffset-10)/3)
            make.height.equalTo(60)
        }
        rejectButton.backgroundColor = .white
        rejectButton.layer.borderWidth = 1
        rejectButton.layer.borderColor = UIColor(hexString: "#F10C6F").cgColor
        rejectButton.layer.cornerRadius = 10
        rejectButton.setTitle("Отклонить", for: .normal)
        rejectButton.titleLabel?.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        rejectButton.addTarget(self, action: #selector(rejectTapped), for: .touchUpInside)
        rejectButton.setTitleColor(UIColor(hexString: "#F10C6F"), for: .normal)
        rejectButton.addCenterImage(#imageLiteral(resourceName: "reject"), color: UIColor(hexString: "#F10C6F"))

        self.contentView.addSubview(chatButton)
        chatButton.snp.makeConstraints { (make) in
            make.top.equalTo(rejectButton.snp.top)
            make.left.equalTo(rejectButton.snp.right).offset(5)
            make.width.equalTo((Constants.screenFrame.size.width-2*Constants.basicOffset-10)/3)
            make.height.equalTo(60)
        }
        chatButton.backgroundColor = Constants.paletteVioletColor
        chatButton.layer.cornerRadius = 10
        chatButton.setTitle("Чат", for: .normal)
        chatButton.titleLabel?.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        chatButton.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
        chatButton.isUserInteractionEnabled = true
        chatButton.addCenterImage(#imageLiteral(resourceName: "chat"), color: .white)

        self.contentView.addSubview(callButton)
        callButton.snp.makeConstraints { (make) in
            make.top.equalTo(rejectButton.snp.top)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.equalTo((Constants.screenFrame.size.width-2*Constants.basicOffset-10)/3)
            make.height.equalTo(60)
        }
        callButton.backgroundColor = Constants.paletteVioletColor
        callButton.layer.cornerRadius = 10
        callButton.setTitle("Позвонить", for: .normal)
        callButton.titleLabel?.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        callButton.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
        callButton.isUserInteractionEnabled = true
        callButton.addCenterImage(#imageLiteral(resourceName: "call"), color: .white)

        self.contentView.addSubview(disabledTextLabel)
        disabledTextLabel.snp.makeConstraints { (make) in
            make.top.equalTo(callButton.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(60)
            //make.bottom.equalToSuperview().offset(-20)
        }
        
        var text = "Написать или позвонить клиенту будет возможно только после одобрения заявки клиентом"
        
        if (User.currentRole == .client) {
            text = "Написать или позвонить арендодателю будет возможно только после одобрения заявки арендодателем"
        }
        
        disabledTextLabel.text = text
        disabledTextLabel.textColor = UIColor(white: 0, alpha: 0.5)
        disabledTextLabel.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        disabledTextLabel.numberOfLines = 0
        disabledTextLabel.isHidden = true
    }
    
    func setupEnabledViews() {
        var isAccepted:Bool
        
        if (offer != nil) {
            isAccepted = (offer!.status == .COMPLETED)
        } else {
            isAccepted = (request!.status == .COMPLETED)
        }

        if (!isAccepted) {
            disabledTextLabel.isHidden = false
            
            chatButton.backgroundColor = UIColor(hexString: "#B3B3B3")
            chatButton.isUserInteractionEnabled = false
            callButton.backgroundColor = UIColor(hexString: "#B3B3B3")
            callButton.isUserInteractionEnabled = false
            
            rejectButton.setTitleColor(UIColor(hexString: "#F10C6F"), for: .normal)
            rejectButton.layer.borderColor = UIColor(hexString: "#F10C6F").cgColor
            rejectButton.addCenterImage(#imageLiteral(resourceName: "reject"), color: UIColor(hexString: "#F10C6F"))
        } else {
            rejectButton.backgroundColor = UIColor(hexString: "#B3B3B3")
            rejectButton.layer.borderColor = UIColor.clear.cgColor
            rejectButton.isUserInteractionEnabled = false
            rejectButton.setTitleColor(.white, for: .normal)
            rejectButton.addCenterImage(#imageLiteral(resourceName: "reject"), color: .white)


            disabledTextLabel.isHidden = true
            
            chatButton.backgroundColor = Constants.paletteVioletColor
            chatButton.isUserInteractionEnabled = true
            callButton.backgroundColor = Constants.paletteVioletColor
            chatButton.isUserInteractionEnabled = true
        }
    }
    
    @objc func rejectTapped() {
        self.delegate?.rejectTapped()
    }

    @objc func chatTapped() {
        self.delegate?.chatTapped()
    }

    @objc func callTapped() {
        self.delegate?.callTapped()
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
