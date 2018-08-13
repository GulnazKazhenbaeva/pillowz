//
//  GuestsPickerModalView.swift
//  Pillowz
//
//  Created by Samat on 28.05.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class GuestsPickerModalView: UIView {
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    let guestsCountCrudVM = CreateEditObjectTableViewGenerator()
    var fields:[AnyObject] = []
    var headers:[String] = []
    var adults:Int = 2
    var childs:Int = 0 {
        didSet {
            adultsField.value = String(adults)
            childsField.value = String(childs)
        }
    }
    var babies:Int = 0
    let adultsField = Field()
    let childsField = Field()
    let babiesField = Field()
    
    var vc:NewPersonalRequestViewController! {
        didSet {
            guestsCountCrudVM.viewController = vc
            guestsCountCrudVM.options = [:]
            generateGuestsCountFields()
            guestsCountCrudVM.headers = headers
            guestsCountCrudVM.object = fields as AnyObject
            
            guestsCountCrudVM.tableView.removeFromSuperview()
            whiteAlertView.addSubview(guestsCountCrudVM.tableView)
            
            guestsCountCrudVM.tableView.snp.removeConstraints()
            guestsCountCrudVM.tableView.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(20)
                make.left.equalToSuperview()
                make.right.equalToSuperview()

                let numberOfGuestsRows = fields.count
                make.height.equalTo(30 + numberOfGuestsRows*50)
            }
            guestsCountCrudVM.tableView.bounces = false
            guestsCountCrudVM.tableView.isScrollEnabled = false
        }
    }
    
    
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
            make.height.equalTo(200)
        }
    }
    
    func generateGuestsCountFields() {
        adultsField.param_name = "adultsField"
        adultsField.multiLanguageName = ["ru": "Взрослые", "en":"Взрослые"]
        
        adultsField.value = String(adults)
        
        adultsField.didPickFieldValueClosure = { (newValue) in
            let number = newValue as! Int
            self.adults = number
            self.adultsField.value = String(number)
        }
        adultsField.type = "IntegerField"
        fields.append(adultsField)
        headers.append("Сколько гостей?")
        
        addChildField()
    }
    
    func addChildField() {
        childsField.param_name = "childsField"
        childsField.multiLanguageName = ["ru": "Дети", "en":"Дети"]
        
        childsField.value = String(childs)
        
        childsField.didPickFieldValueClosure = { (newValue) in
            let number = newValue as! Int
            self.childs = number
            self.childsField.value = String(number)
            
        }
        childsField.type = "IntegerField"
        fields.append(childsField)
        headers.append("")
    }
    
    func show() {
        let window = UIApplication.shared.keyWindow!
        
        window.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        vc.guests_count = ["adult_guest":adults, "child_guest":childs]
        
        self.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
