//
//  SpacePicturesTableViewCell.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 02.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class SpacePicturesTableViewCell: UITableViewCell {
    
    let pictureSliderView = PictureSlider()
    
    var space:Space! {
        didSet {
            pictureSliderView.space = space
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(pictureSliderView)
        pictureSliderView.backgroundColor = .clear
        pictureSliderView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Constants.spaceImageHeight + 50)
            make.bottom.equalToSuperview().offset(-15)
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
