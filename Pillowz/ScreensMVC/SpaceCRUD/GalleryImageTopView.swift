//
//  GalleryImageTopView.swift
//  Pillowz
//
//  Created by Samat on 16.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

protocol GalleryImageTopViewDelegate {
    func deleteImageTapped()
}

class GalleryImageTopView: UIView {
    let deleteButton = UIButton()
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var delegate:GalleryImageTopViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(-13)
            make.right.equalToSuperview().offset(-60)
            make.width.height.equalTo(44)
        }
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        deleteButton.setImage(#imageLiteral(resourceName: "deleteImageIcon"), for: .normal)
    }
    
    @objc func deleteTapped() {
        delegate?.deleteImageTapped()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
