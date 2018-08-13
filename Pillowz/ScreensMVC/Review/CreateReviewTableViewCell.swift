//
//  CreateReviewTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 17.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

protocol CreateReviewTableViewCellDelegate {
    func createReviewTapped()
}

class CreateReviewTableViewCell: UITableViewCell {
    let createReviewLabel = UILabel()
    let createReviewImageView = UIImageView()
    let createReviewInvisibleButton = UIButton()

    var delegate:CreateReviewTableViewCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(createReviewLabel)
        createReviewLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        createReviewLabel.textColor = Constants.paletteVioletColor
        createReviewLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 13)!
        createReviewLabel.text = "Оставить отзыв"
        
        self.contentView.addSubview(createReviewImageView)
        createReviewImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }
        createReviewImageView.fillImageView(image: #imageLiteral(resourceName: "bigFilledStar"), color: Constants.paletteVioletColor)
        
        self.contentView.addSubview(createReviewInvisibleButton)
        createReviewInvisibleButton.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        createReviewInvisibleButton.addTarget(self, action: #selector(createReviewTapped), for: .touchUpInside)
    }
    
    @objc func createReviewTapped() {
        self.delegate?.createReviewTapped()
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
