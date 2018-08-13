//
//  RentTypePickerView.swift
//  Pillowz
//
//  Created by Samat on 06.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

public typealias DidPickRentTypeClosure = (_ rentType:RENT_TYPES) -> Void

class RentTypePickerView: UIView, UITableViewDelegate, UITableViewDataSource {
    var rentTypes = RENT_TYPES.allValues {
        didSet {
            tableView.snp.updateConstraints { (make) in
                make.height.equalTo(rentTypes.count * 50)
            }
            
            whiteAlertView.snp.updateConstraints { (make) in
                make.height.equalTo(60 + rentTypes.count * 50)
            }
        }
    }
    let tableView = UITableView()
    
    var didPickRentTypeClosure:DidPickRentTypeClosure?
    let whiteAlertView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        whiteAlertView.backgroundColor = .white
        whiteAlertView.layer.cornerRadius = 3
        self.addSubview(whiteAlertView)
        whiteAlertView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalToSuperview()
            make.height.equalTo(210)
        }
        
        whiteAlertView.clipsToBounds = true
        
        let titleLabel = UILabel()
        
        whiteAlertView.addSubview(titleLabel)
        titleLabel.textColor = Constants.paletteBlackColor
        titleLabel.text = "На какой период вы хотите снять жилье?"
        titleLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 17)!
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(30)
        }
        
        whiteAlertView.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(150)
        }
        tableView.contentSize = CGSize(width: Constants.screenFrame.size.width-2*Constants.basicOffset-20, height: 200) //to disable horizontal scrolling

        self.tableView.contentInset = UIEdgeInsetsMake(0, Constants.basicOffset-15, 0, 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rentTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = Price.getDisplayNameForRentType(rent_type: rentTypes[indexPath.row], isForPrice: false)["ru"]
        cell.textLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        
        cell.selectionStyle = .none
        
        if (UserLastUsedValuesForFieldAutofillingHandler.shared.rentType == rentTypes[indexPath.row]) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserLastUsedValuesForFieldAutofillingHandler.shared.rentType = rentTypes[indexPath.row]
        
        didPickRentTypeClosure?(rentTypes[indexPath.row])
        
        self.removeFromSuperview()
    }
    
    func show() {
        let window = UIApplication.shared.keyWindow!
        window.addSubview(self)
        self.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
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
