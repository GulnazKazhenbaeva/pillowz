//
//  ReviewTableViewCell.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 11/25/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol ReviewTableViewCellDelegate {
    func showAllReviewsTapped()
    func openUserWithId(_ userId:Int)
}

class ReviewTableViewCell: HeaderIncludedTableViewCell {
    let userImageView = UIImageView()
    let rateView = RateView()
    let userNameLabel = UILabel()
    let userDetailLabel = UILabel()
    let reviewLabel = UILabel()
    let showAllReviewsButton = UIButton()
    let userInvisibleButton = UIButton()

    var space: Space! {
        didSet {
            //TODO: Put real values
            header = "Отзывы ("+String(space.reviews!.count)+")"
            
            if space.reviews!.count == 0 {
                header = "На это жилье еще никто не оставлял отзыв."
            }
            
            reviewLabel.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview().offset(-66)
            }
            showAllReviewsButton.isHidden = false
        }
    }
    
    var user: User! {
        didSet {
            //TODO: Put real values
            header = "Отзывы ("+String(user.reviews!.count)+")"
            
            if user.reviews!.count == 0 {
                header = "Похоже, этот пользователь здесь недавно. О нем еще не оставляли отзывов."
            }
            
            reviewLabel.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview().offset(-66)
            }
            showAllReviewsButton.isHidden = false
        }
    }
    
    var delegate:ReviewTableViewCellDelegate?
    
    var review:Review! {
        didSet {
            if (review.user!.avatar != nil) {
                userImageView.sd_setImage(with: URL(string: review.user!.avatar!), placeholderImage: UIImage())
            }
            rateView.setStars(stars: review.value!)
            
            userNameLabel.text = review.user!.name!

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            dateFormatter.timeZone = NSTimeZone.local

            //review.text = "Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It's also called placeholder (or filler) text. It's a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout. Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, so to deliberately render its content nonsensical; it's not genuine, correct, or comprehensible Latin anymore. While lorem ipsum's still resembles classical Latin, it actually has no meaning whatsoever. As Cicero's text doesn't contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original."
            
            userDetailLabel.text = review.user!.address! + ", " + dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(review.timestamp!)))
            reviewLabel.text = review.text
            reviewLabel.sizeToFit()
            
            reviewLabel.snp.updateConstraints { (make) in
                let height = review.text!.height(withConstrainedWidth: Constants.screenFrame.size.width-2*Constants.basicOffset, font: UIFont.init(name: "OpenSans-Light", size: 14)!)
                make.height.equalTo(height)
            }
        }
    }
    
    override func fillWithObject(object: AnyObject) {
        if object is UserProfileViewController {
            self.user = (object as! UserProfileViewController).user
            self.review = self.user.reviews![0]
        }
        
        self.delegate = object as? ReviewTableViewCellDelegate
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.contentView.addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(Constants.basicOffset)
            make.width.height.equalTo(40)
        }
        userImageView.layer.cornerRadius = 20
        userImageView.clipsToBounds = true
        userImageView.layer.masksToBounds = true
        userImageView.backgroundColor = Constants.paletteVioletColor
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor

        self.contentView.addSubview(userNameLabel)
        userNameLabel.font = UIFont.init(name: "OpenSans-Light", size: 14)!
        userNameLabel.textColor = Constants.paletteVioletColor
        userNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(userImageView.snp.top)
            make.height.equalTo(22)
            make.left.equalTo(userImageView.snp.right).offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        self.contentView.addSubview(userDetailLabel)
        userDetailLabel.font = UIFont.init(name: "OpenSans-Light", size: 14)!
        userDetailLabel.textColor = Constants.paletteBlackColor
        userDetailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(userImageView.snp.right).offset(Constants.basicOffset)
            make.height.equalTo(22)
            make.bottom.equalTo(userImageView.snp.bottom)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        self.contentView.addSubview(userInvisibleButton)
        userInvisibleButton.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(userDetailLabel.snp.bottom)
        }
        userInvisibleButton.addTarget(self, action: #selector(userTapped), for: .touchUpInside)
        
        self.contentView.addSubview(rateView)
        rateView.snp.makeConstraints { (make) in
            make.centerY.equalTo(userNameLabel)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(60)
        }
        
        self.contentView.addSubview(reviewLabel)
        reviewLabel.font = UIFont.init(name: "OpenSans-Light", size: 14)!
        reviewLabel.textColor = Constants.paletteBlackColor
        reviewLabel.numberOfLines = 0
        reviewLabel.snp.makeConstraints { (make) in
            make.top.equalTo(userImageView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        self.contentView.addSubview(showAllReviewsButton)
        showAllReviewsButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        showAllReviewsButton.setTitle("Посмотреть все отзывы", for: .normal)
        showAllReviewsButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
        showAllReviewsButton.snp.makeConstraints { (make) in
            make.top.equalTo(reviewLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(40)
        }
        showAllReviewsButton.addTarget(self, action: #selector(showAllReviewsAction), for: .touchUpInside)
        
        showAllReviewsButton.isHidden = true
    }
    
    @objc func userTapped() {
        self.delegate?.openUserWithId(self.review.user!.user_id!)
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }

    @objc func showAllReviewsAction(){
        delegate?.showAllReviewsTapped()
    }
}
