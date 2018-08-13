//
//  SpacePhotosCollectionViewCell.swift
//  Pillowz
//
//  Created by Samat on 22.02.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

protocol SpacePhotosCollectionViewCellDelegate {
    func pickPhotoTapped()
    //func deleteSpaceImageTapped(_ image_id:Int)
}

class SpacePhotosCollectionViewCell: UICollectionViewCell {
    let spaceImageView = UIImageView()

    let pickerButton:UIButton = UIButton()

    var delegate:SpacePhotosCollectionViewCellDelegate?
    
    var image:Image! {
        didSet {
            let shouldShowPickerButton = (image == nil)
            
            pickerButton.isHidden = !shouldShowPickerButton
            spaceImageView.isHidden = shouldShowPickerButton
            
            if (image == nil) {
                
            } else {
                spaceImageView.sd_setImage(with: URL(string: image.image), placeholderImage: UIImage())
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        self.contentView.addSubview(spaceImageView)
        spaceImageView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(8)
            make.bottom.right.equalToSuperview().offset(-8)
        }
        spaceImageView.contentMode = .scaleAspectFill
        spaceImageView.backgroundColor = .lightGray
        spaceImageView.layer.cornerRadius = 5
        spaceImageView.clipsToBounds = true
        spaceImageView.layer.masksToBounds = true
        
        pickerButton.removeFromSuperview()
        
        self.contentView.addSubview(pickerButton)
        pickerButton.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(8)
            make.bottom.right.equalToSuperview().offset(-8)
        }
        pickerButton.addTarget(self, action: #selector(pickPhotoTapped), for: .touchUpInside)
        pickerButton.setImage(#imageLiteral(resourceName: "addPhoto-1"), for: .normal)
        pickerButton.backgroundColor = UIColor.white
        pickerButton.layer.borderWidth = 1
        pickerButton.layer.borderColor = Constants.paletteVioletColor.cgColor
        pickerButton.layer.cornerRadius = 5
    }
    
    @objc func pickPhotoTapped() {
        delegate?.pickPhotoTapped()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
