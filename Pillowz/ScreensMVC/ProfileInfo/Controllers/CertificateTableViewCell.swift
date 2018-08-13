//
//  CertificateTableViewCell.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 12.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class CertificateTableViewCell: UITableViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        label.textColor = UIColor.black.withAlphaComponent(0.87)
        return label
    }()
    let imgView = UIImageView()
    
    var name: String! {
        didSet {
            nameLabel.text = name
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(imgView)
        imgView.image = UIImage.init(named: "file")
        imgView.contentMode = .scaleAspectFit
        imgView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(25)
            make.width.height.equalTo(25)
        }
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imgView.snp.right).offset(15)
            make.centerY.equalToSuperview()
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
