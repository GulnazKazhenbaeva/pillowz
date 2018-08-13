//
//  DIYCalendarCell.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 06/11/2016.
//  Copyright © 2016 wenchao. All rights reserved.
//

import Foundation
import FSCalendar
import UIKit

enum SelectionType : Int {
    case none
    case single
    case leftBorder
    case middle
    case rightBorder
}


class DIYCalendarCell: FSCalendarCell {
    
    weak var circleImageView: UIImageView!
    weak var selectionLayer: CAShapeLayer!
    weak var circleHourlyView: UIView!
    
    var selectionType: SelectionType = .none {
        didSet {
            if selectionType == .none {
                selectionLayer.isHidden = true
            } else {
                selectionLayer.isHidden = false
            }
        }
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel.frame = CGRect.zero
        
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = Constants.paletteVioletColor.cgColor
        selectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        self.selectionLayer = selectionLayer
        
        let circleImageView = UIImageView(image: UIImage(named: "circle")!)
        self.contentView.insertSubview(circleImageView, belowSubview: self.titleLabel)
        self.circleImageView = circleImageView
        self.circleImageView.contentMode = .center
        self.circleImageView.backgroundColor = .clear

        self.shapeLayer.isHidden = true
        
        let view = UIView(frame: self.bounds)
        view.backgroundColor = UIColor.clear
        self.backgroundView = view;
        
        self.titleLabel.textColor = .lightGray
        
        let circleHourlyView = UIView()
        self.contentView.addSubview(circleHourlyView)
        self.circleHourlyView = circleHourlyView
        self.circleHourlyView.layer.cornerRadius = (self.contentView.bounds.size.height-6)/2
        self.circleHourlyView.layer.borderWidth = 1
        self.circleHourlyView.layer.borderColor = Constants.paletteLightGrayColor.cgColor
        self.circleHourlyView.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.eventIndicator.isHidden = true

        self.backgroundView?.frame = self.bounds.insetBy(dx: 1, dy: 1)
        self.selectionLayer.frame = self.contentView.bounds
        self.titleLabel.frame = self.contentView.bounds
        self.circleHourlyView.frame = CGRect(x: self.contentView.bounds.size.width/2 - (self.contentView.bounds.size.height-6)/2, y: 3, width: self.contentView.bounds.size.height-6, height: self.contentView.bounds.size.height-6)
        
        
        var roundedRectBounds = self.selectionLayer.bounds
        roundedRectBounds.origin.y = 3
        roundedRectBounds.size.height = roundedRectBounds.size.height - 6
        
        if selectionType == .middle {
            self.selectionLayer.path = UIBezierPath(rect: roundedRectBounds).cgPath
        }
        else if selectionType == .leftBorder {
            self.selectionLayer.path = UIBezierPath(roundedRect: roundedRectBounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2, height: self.selectionLayer.frame.width / 2)).cgPath
        }
        else if selectionType == .rightBorder {
            self.selectionLayer.path = UIBezierPath(roundedRect: roundedRectBounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2, height: self.selectionLayer.frame.width / 2)).cgPath
        }
        else if selectionType == .single {
            let diameter: CGFloat = min(roundedRectBounds.height, self.selectionLayer.frame.width)
            self.selectionLayer.path = UIBezierPath(ovalIn: CGRect(x: self.contentView.frame.width / 2 - diameter / 2, y: self.contentView.frame.height / 2 - diameter / 2, width: diameter, height: diameter)).cgPath
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        // Override the build-in appearance configuration
        if self.isPlaceholder {
            self.titleLabel.textColor = UIColor.lightGray
        }
    }
    
}
