//
//  TextViewWithPlaceholder.swift
//  Pillowz
//
//  Created by Samat on 04.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class TextViewWithPlaceholder: UITextView, UITextViewDelegate {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.delegate = self
    }
    
    var placeholder:String = "" {
        didSet {
            placeholderString = placeholder
        }
    }
    private var placeholderString = ""
    
    var textValue: String! {
        didSet {
            if textValue == "" {
                self.text = placeholderString
                self.textColor = UIColor.lightGray
            } else {
                self.text = textValue
                self.textColor = UIColor.black
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderString
            textView.textColor = UIColor.lightGray
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
