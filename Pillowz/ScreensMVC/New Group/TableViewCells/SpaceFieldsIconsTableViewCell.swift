//
//  SpaceFieldsIconsTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 11.02.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SpaceFieldsIconsTableViewCell: UITableViewCell {
    var spaceIcons:[SpaceIcon]! {
        didSet {
            setupIcons()
        }
    }
    
    var scrollView = UIScrollView()
    var iconsViews:[UIView] = []
    
    func setupIcons() {
        for view in iconsViews {
            view.removeFromSuperview()
        }
        
        var currentX:CGFloat = Constants.basicOffset
        
        for spaceIcon in spaceIcons {
            let iconImageView = UIImageView()
            scrollView.addSubview(iconImageView)
            iconImageView.snp.makeConstraints({ (make) in
                make.top.equalToSuperview().offset(10)
                make.width.equalTo(60)
                make.height.equalTo(35)
                make.left.equalToSuperview().offset(currentX)
            })
            iconImageView.contentMode = .center
            iconImageView.sd_setImage(with: URL(string: spaceIcon.logo_64x64), completed: { (image, error, _, _) in
                if (error == nil) {
                    let smallerImage = UIImageView.resizeImage(image: image!, targetSize: CGSize(width: 30, height: 28))
                    
                    iconImageView.fillImageView(image: smallerImage, color: Constants.paletteVioletColor)
                }
            })

            let iconNameLabel = UILabel()
            scrollView.addSubview(iconNameLabel)
            iconNameLabel.snp.makeConstraints({ (make) in
                make.top.equalTo(iconImageView.snp.bottom).offset(5)
                make.width.equalTo(60)
                make.height.equalTo(14)
                make.left.equalToSuperview().offset(currentX)
            })
            iconNameLabel.font = UIFont.init(name: "OpenSans-Light", size: 12)!
            iconNameLabel.textColor = Constants.paletteBlackColor
            iconNameLabel.textAlignment = .center
            iconNameLabel.text = spaceIcon.icon_name
            
            iconsViews.append(iconImageView)
            iconsViews.append(iconNameLabel)

            currentX = currentX + 60 + 12
        }
        
        scrollView.contentSize = CGSize(width: currentX, height: 8)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(85)
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
