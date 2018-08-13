//
//  LongTextTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 28.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class LongTextTableViewCell: HeaderIncludedTableViewCell, UITextViewDelegate, EditableCellDelegate {
    let textView = UITextViewFixed()
    
    var didPickValueClosure:DidPickFieldValueClosure!
    var initialValue:String = "" {
        didSet {
            var topSpace:CGFloat
            
            if isSmallHeader {
                topSpace = 0
            } else {
                topSpace = 10
            }

            textView.snp.updateConstraints { (make) in
                make.top.equalTo(headerLabel.snp.bottom).offset(topSpace)
            }
            
            if initialValue == "" {
                textView.text = placeholderString
                textView.textColor = Constants.paletteLightGrayColor
            } else {
                textView.text = initialValue
                textView.textColor = UIColor.black
            }
        }
    }
    var placeholder:String = "" {
        didSet {
            placeholderString = placeholder
        }
    }
    private var placeholderString = "" 
    
    func didSetValue(value: String) {
        initialValue = value
    }
    
    func didSetCustomText(text: String) {
        initialValue = text
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.font = UIFont.init(name: "OpenSans-Regular", size: 16)!
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != placeholderString && textView.text != "" {
            didPickValueClosure(textView.text!)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Constants.paletteLightGrayColor {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderString
            textView.textColor = Constants.paletteLightGrayColor
        }
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

class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}
