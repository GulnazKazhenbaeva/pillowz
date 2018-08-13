//
//  SpaceCollectionViewCell.swift
//  Pillowz
//
//  Created by Samat on 07.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SpaceCollectionViewCell: UICollectionViewCell {
    var spaceView:SpaceView!
    
    var space:Space! {
        didSet {
            spaceView.space  = space
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if (spaceView == nil) {
            spaceView = SpaceView()
            spaceView.isHorizontalCollectionView = true
            self.contentView.addSubview(spaceView)
            spaceView.snp.makeConstraints { (make) in
                make.top.left.bottom.right.equalToSuperview()
            }
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
