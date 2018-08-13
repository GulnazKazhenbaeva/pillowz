//
//  SpaceTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 04.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit


class SpaceTableViewCell: UITableViewCell {
    
    var spaceView:SpaceView!
    
    var space:Space! {
        didSet {
            spaceView.space  = space
            
            spaceView.snp.updateConstraints { (make) in
                let nameHeight = space.name.height(withConstrainedWidth: Constants.screenFrame.size.width-2*Constants.basicOffset, font: UIFont.init(name: "OpenSans-Bold", size: 17)!)
                make.height.equalTo(Constants.spaceImageHeight + nameHeight + 85)
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        if (spaceView == nil) {
            spaceView = SpaceView()
            self.contentView.addSubview(spaceView)
            spaceView.snp.makeConstraints { (make) in
                make.top.left.bottom.right.equalToSuperview()
                make.height.equalTo(Constants.spaceImageHeight + 85)
            }
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
