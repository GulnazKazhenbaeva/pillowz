//
//  SpaceCategoryPickerTableViewCell.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 27.07.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SpaceCategoryPickerTableViewCell: UITableViewCell {
    var backView = UIView()
    var imgView = UIImageView()
    var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "OpenSans-Regular", size: 16)
        label.textColor = Colors.black
        return label
    }()
    
    var title: String! {
        didSet {
            label.text = title
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        selectionStyle = .none
        addSubview(backView)
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 18
        backView.layer.borderColor = UIColor.init(hexString: "#F2F2F2").cgColor
        backView.layer.borderWidth = 1
        
        backView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(36)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        [imgView, label].forEach({backView.addSubview($0)})

        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 18
        imgView.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(36)
        }
        
        label.snp.makeConstraints { (make) in
            make.left.equalTo(imgView.snp.right).offset(20)
            make.right.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }
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
