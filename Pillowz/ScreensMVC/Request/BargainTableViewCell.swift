//
//  BargainTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 17.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class BargainTableViewCell: UITableViewCell {
    var offer:Offer?
    
    var request:Request?
    
    var delegate:BargainViewDelegate? {
        didSet {
            bargainView.delegate = delegate
        }
    }
    
    let bargainView = BargainView(frame: .zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(bargainView)
        bargainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func fillWithOffer(_ fillingOffer:Offer?, fillingRequest:Request?) {
        self.offer = fillingOffer
        self.request = fillingRequest
        
        self.bargainView.fillWithOffer(fillingOffer, fillingRequest: fillingRequest)
        
        self.bargainView.isScrollEnabled = true
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
