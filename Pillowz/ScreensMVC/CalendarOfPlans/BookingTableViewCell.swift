//
//  BookingTableViewCell.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 14.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol BookingTableViewCellDelegate {
    func openSpace(_ space:Space)
    func openUserWithId(_ userId:Int)
}

class BookingTableViewCell: UITableViewCell {
    var delegate:BookingTableViewCellDelegate?
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "OpenSans-Regular", size: 10)!
        label.textColor = Constants.paletteLightGrayColor
        return label
    }()
    
    let avatarImageView = UIImageView()
    
    let firstLine: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "OpenSans-SemiBold", size: 11)!
        label.textColor = Constants.paletteVioletColor
        return label
    }()
    
    let secondLine: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "OpenSans-SemiBold", size: 16)!
        label.textColor = Constants.paletteBlackColor
        return label
    }()
    
    let thirdLine: UILabel = {
        let label = UILabel()
        label.textColor = Constants.paletteBlackColor
        label.font = UIFont.init(name: "OpenSans-SemiBold", size: 11)!
        return label
    }()

    let openUserButton = UIButton()
    
    let openSpaceButton = UIButton()
    
    var user:User! {
        didSet {
            if (user.name != nil) {
                firstLine.attributedText = NSAttributedString(string: user.name!, attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
            }
            
            if (user.avatar != nil) {
                avatarImageView.sd_setImage(with: URL(string: user.avatar!), placeholderImage: UIImage())
            }
        }
    }

    var request:Request! {
        didSet {
            if (request.timestamp != nil) {
                thirdLine.text = request.open_price
                
                if (request.space == nil) {
                    for offer in request.offers! {
                        if (offer.status! == .COMPLETED) {
                            secondLine.text = offer.space!.name
                        }
                    }                    
                } else {
                    secondLine.text = request.space!.name
                }
                
                user = request.user!
                
                secondLine.isHidden = false
                thirdLine.isHidden = false
                avatarImageView.isHidden = false
                
                thirdLine.snp.updateConstraints { (make) in
                    make.bottom.equalToSuperview().offset(-10)
                }
            } else {
                thirdLine.snp.updateConstraints { (make) in
                    make.bottom.equalToSuperview().offset(10)
                }

                firstLine.text = "Забронировано Вами"
                secondLine.text = book.name
                    
                thirdLine.isHidden = true
                avatarImageView.isHidden = true
            }
        }
    }
    
    var book:Book! {
        didSet {
            let periodText = Request.getStringForRentType(book.rent_type, startTime: book.timestamp_start, endTime: book.timestamp_end, shouldGoToNextLine: false, includeRentTypeText: false)
            
            dateLabel.text = periodText
            
            request = book.request
        }
    }

    //var delegate:SpaceTableViewCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(15)
        }
        
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.masksToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        
        contentView.addSubview(firstLine)
        firstLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.top.equalTo(dateLabel.snp.bottom)
            make.height.equalTo(20)
        }
        
        contentView.addSubview(secondLine)
        secondLine.snp.makeConstraints { (make) in
            make.top.equalTo(firstLine.snp.bottom)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-12)
        }
        
        secondLine.addSubview(openSpaceButton)
        openSpaceButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        openSpaceButton.addTarget(self, action: #selector(openSpaceTapped), for: .touchUpInside)
        
        contentView.addSubview(thirdLine)
        thirdLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(secondLine.snp.bottom)
            make.height.equalTo(20)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        contentView.addSubview(openUserButton)
        openUserButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.top.equalTo(dateLabel.snp.bottom)
            make.height.equalTo(20)
        }
        openUserButton.addTarget(self, action: #selector(openUserTapped), for: .touchUpInside)
    }
    
    @objc func openSpaceTapped() {
        if (request.req_type == .PERSONAL) {
            self.delegate?.openSpace(request.space!)
        } else {
            for iteratingOffer in request.offers! {
                if (iteratingOffer.status! == .COMPLETED) {
                    self.delegate?.openSpace(iteratingOffer.space!)

                    return
                }
            }
        }
    }
    
    @objc func openUserTapped() {
        if let request = book.request, let user = request.user, let user_id = user.user_id {
            delegate?.openUserWithId(user_id)
        }
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }


}
