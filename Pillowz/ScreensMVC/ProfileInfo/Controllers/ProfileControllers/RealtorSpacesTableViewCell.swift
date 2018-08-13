//
//  RealtorSpacesTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 28.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

protocol RealtorSpacesTableViewCellDelegate {
    var horizontalSpacesList:HorizontalSpacesList! {get set}
    var spaceLoaderClosure:SpaceLoaderClosure! {get set}
    var superViewControllerForHorizontalSpacesList:UIViewController! {get set}
}

class RealtorSpacesTableViewCell: HeaderIncludedTableViewCell {
    let horizontalSpacesList = HorizontalSpacesList()
    var spaceLoaderClosure:SpaceLoaderClosure! {
        didSet {
            horizontalSpacesList.spaceLoaderClosure = spaceLoaderClosure
        }
    }

    override func fillWithObject(object: AnyObject) {
        var delegate = object as! RealtorSpacesTableViewCellDelegate
        delegate.horizontalSpacesList = horizontalSpacesList
        horizontalSpacesList.superViewController = delegate.superViewControllerForHorizontalSpacesList
        horizontalSpacesList.spaceLoaderClosure = delegate.spaceLoaderClosure
        horizontalSpacesList.spaceLoaderClosure()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        horizontalSpacesList.displayingSpaces = []
        horizontalSpacesList.isHidden = false
        horizontalSpacesList.cell = self
        
        self.contentView.addSubview(horizontalSpacesList)
        horizontalSpacesList.snp.makeConstraints { (make) in
            make.top.equalTo(headerLabel.snp.bottom).offset(16)
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(Constants.oneSpaceWidthInHorizontalCollectionView*180/340 + 90 + 28 + 40)
        }
        
        self.selectionStyle = .none
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
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
