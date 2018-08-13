//
//  FilterGenerator.swift
//  Pillowz
//
//  Created by Kazhenbayeva Gulnaz on 8/12/18.
//  Copyright © 2018 Samat. All rights reserved.
//


import UIKit
import SnapKit

//protocol TopMostCellListenerDelegate {
//    func willDisplayCellAtIndex(_ index:Int)
//}
//
//protocol FillableCellDelegate {
//    func fillWithObject(object:AnyObject)
//}
//
//protocol SaveActionDelegate {
//    func actionButtonTapped()
//}
//
//@objc protocol PropertyNames {
//    func getMultiLanguageNames() -> [String:Any]
//    @objc optional func getEditableKeys() -> [String]
//    @objc optional func getIcons() -> [String:String]
//}

class FilterTableViewGenerator: NSObject, UITableViewDelegate, UITableViewDataSource {
    var saveButton:PillowzButton?
    var delegate:SaveActionDelegate?
    
    var topMostCellListenerDelegate:TopMostCellListenerDelegate?
    
    var hasSaveAction:Bool = false {
        didSet {
            if (saveButton == nil) {
                saveButton = PillowzButton()
                viewController.view.addSubview(saveButton!)
                PillowzButton.makeBasicButtonConstraints(button: saveButton!, pinToTop: false)
                delegate = viewController as? SaveActionDelegate
                saveButton!.addTarget(self, action: #selector(saveActionTapped), for: .touchUpInside)
            }
        }
    }
    
    var hasExpandAction:Bool = false
    
    var headerView:UIView? {
        didSet {
            hasHeaderView = true
            
            if (hasHeaderView) {
                headers.insert("", at: 0)
                placeholders.insert("", at: 0)
                keys.insert("CustomView", at: 0)
            }
        }
    }
    var hasHeaderView:Bool = false
    
    @objc func saveActionTapped() {
        self.delegate?.actionButtonTapped()
    }
    
    var viewController:UIViewController! {
        didSet {
            tableView = UITableView()
            tableView.register(BooleanValuePickerTableViewCell.classForCoder(), forCellReuseIdentifier: "BooleanValue")
            tableView.register(IntValuePickerTableViewCell.classForCoder(), forCellReuseIdentifier: "IntValue")
            tableView.register(ListPickerTableViewCell.classForCoder(), forCellReuseIdentifier: "ObjectValue")
            tableView.register(RangeIntValuePickerTableViewCell.classForCoder(), forCellReuseIdentifier: "RangeValue")
            tableView.register(RangeSliderPickerTableViewCell.classForCoder(), forCellReuseIdentifier: "RangeSliderValue")
            tableView.register(StringValueTableViewCell.classForCoder(), forCellReuseIdentifier: "StringValue")
            tableView.register(LongTextTableViewCell.classForCoder(), forCellReuseIdentifier: "LongStringValue")
            tableView.register(HeaderIncludedTableViewCell.classForCoder(), forCellReuseIdentifier: "HeaderValue")
            tableView.register(ButtonActionTableViewCell.classForCoder(), forCellReuseIdentifier: "SaveButton")
            tableView.register(CustomViewTableViewCell.classForCoder(), forCellReuseIdentifier: "CustomView")
            tableView.register(ExpandActionTableViewCell.classForCoder(), forCellReuseIdentifier: "ExpandButton")
            tableView.register(EmptyTableViewCell.classForCoder(), forCellReuseIdentifier: "EmptyCell")
            tableView.register(HeaderTextTableViewCell.classForCoder(), forCellReuseIdentifier: "HeaderText")
            tableView.register(IntInputTableViewCell.classForCoder(), forCellReuseIdentifier: "IntInputValue")
            
            tableView.estimatedRowHeight = 120
            tableView.separatorColor = UIColor(white: 0.0, alpha: 0.0)
            
            viewController.view.addSubview(tableView)
            
            tableView.keyboardDismissMode = .onDrag
            viewController.automaticallyAdjustsScrollViewInsets = false
            tableView.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(0)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.tableFooterView = UIView()
        }
        
    }
    var tableView:UITableView!
    
    //this is the object we want to create/edit
    var object:AnyObject! {
        didSet {
            if object is Array<Any> {
                keys = []
                
                let array = object as! Array<Any>
                if (array.count>0) {
                    for object in array {
                        if (object is Field) {
                            let field = object as! Field
                            
                            if (field.isCustomCellField && (field.param_name==nil || field.param_name=="")) {
                                field.param_name = field.customCellClassString
                            }
                            
                            if (field.type == "InlineField") {
                                field.param_name = field.name
                            }
                            
                            keys.append(field.param_name!)
                        } else if (object is ComfortItem) {
                            let comfortItem = object as! ComfortItem
                            keys.append(comfortItem.name!)
                        }
                    }
                }
            }
            
            if (headers.count == 0) {
                headers = keys
            }
            placeholders = keys
            
            if (hasHeaderView) {
                headers.insert("", at: 0)
                placeholders.insert("", at: 0)
                keys.insert("CustomView", at: 0)
            }
            
            if (hasExpandAction) {
                headers.append("")
                placeholders.append("")
                keys.append("expandButton")
            }
            
            keys.append("EmptyCell")
            
            self.tableView.reloadData()
        }
    }
    
    //these are object keys that you want to control with this tableview
    var keys:[String] = []
    
    //these are header label texts that will be above each key
    var headers:[String] = []
    
    var placeholders:[String] = []
    
    //these will be additional options for specific fields - key of this dictionary is object key and value is option
    var options:[String:Any] = [:]
    
    var specialCaseCellsKeys:[String] = []
    
    var disableTextFields = false
    var isSmallHeaders = false
    
    func addSpecialCaseCell(cellClass:AnyClass, index:Int) {
        let className = String(describing: cellClass.self)
        
        tableView.register(cellClass, forCellReuseIdentifier: className)
        
        keys.insert(className, at: index)
        specialCaseCellsKeys.append(className)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell
        
        let key = keys[indexPath.row]
        
        let specialCaseCell = getCellForSpecialCases(key: key)
        
        var index = indexPath.row
        
        if (hasHeaderView) {
            index = index-1
        }
        
        let isIndexValid = headers.indices.contains(indexPath.row)
        var header:String
        if (isIndexValid) {
            header = headers[indexPath.row]
        } else {
            header = ""
        }
        
        if (specialCaseCell != nil) {
            cell = specialCaseCell!
        } else {
            if (object is [AnyObject]) {
                //getting correct index for field in array
                if (object as! [AnyObject])[0] is Field {
                    index = (object as! [AnyObject]).index(where: { (field) -> Bool in
                        if (field is Field) {
                            return (field as! Field).param_name == key
                        } else {
                            return (field as! ComfortItem).name == key
                        }
                    })!
                }
                
                cell = getCellForArrayValue(object: object, index: index, key: key, header: header)
                
                
                let array = object as! [AnyObject]
                
                if (array[index] is Field) && cell is HeaderIncludedTableViewCell {
                    let field = array[index] as! Field
                    let headerCell = cell as! HeaderIncludedTableViewCell
                    
                    if field.required {
                        headerCell.requiredFieldLabel.isHidden = false
                    } else {
                        headerCell.requiredFieldLabel.isHidden = true
                    }
                }
            } else {
                cell = getCellForObject(object:object, index:index, key:key, header: header)
            }
        }
        
        addSeparatorViewTo(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    func getCellForSpecialCases(key:String) -> UITableViewCell? {
        if specialCaseCellsKeys.contains(key) {
            let cell = tableView.dequeueReusableCell(withIdentifier: key)
            
            return cell
        }
        
        if (key == "expandButton") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandButton") as! ExpandActionTableViewCell
            
            cell.delegate = self.viewController as? ExpandActionTableViewCellDelegate
            
            return cell
        }
        
        if (key == "saveButton") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SaveButton") as! ButtonActionTableViewCell
            
            cell.delegate = self.viewController as? ButtonActionCellDelegate
            
            return cell
        }
        
        if (key == "CustomView") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomView") as! CustomViewTableViewCell
            
            cell.contentView.addSubview(headerView!)
            headerView?.snp.makeConstraints({ (make) in
                make.top.left.right.bottom.equalToSuperview()
                make.height.equalTo(200)
            })
            
            return cell
        }
        
        if (key == "EmptyCell") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell")
            
            return cell
        }
        
        if (key == "HeaderText") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderText") as! HeaderTextTableViewCell
            
            let currentIndex = keys.index(of: key)!
            cell.headerText = headers[currentIndex]
            
            return cell
        }
        
        return nil
    }
    
    func addSeparatorViewTo(cell:UITableViewCell, indexPath:IndexPath) {
        let key = keys[indexPath.row]
        
        let isHeaderIndexValid = headers.indices.contains(indexPath.row+1)
        let isNextKeyIndexValid = keys.indices.contains(indexPath.row+1)
        
        cell.removeSeparatorView()
        
        let currentCellIsHeader = type(of: cell) == HeaderIncludedTableViewCell.self
        
        var keyContainsHeaderFieldText = false
        if key.range(of:"HeaderField") != nil {
            keyContainsHeaderFieldText = true
        }
        
        
        if (currentCellIsHeader || keyContainsHeaderFieldText) {
            return
        }
        
        if (isNextKeyIndexValid) {
            let nextKey = keys[indexPath.row+1]
            
            var nextKeyContainsHeaderFieldText = false
            if nextKey.range(of:"HeaderField") != nil {
                nextKeyContainsHeaderFieldText = true
            }
            
            if (nextKey=="expandButton" || nextKey=="EmptyCell" || nextKeyContainsHeaderFieldText) {
                cell.addSeparatorView()
            }
        }
        
        if key != keys.last && isHeaderIndexValid {
            if (headers[indexPath.row+1] != "") {
                cell.addSeparatorView()
            }
        }
    }
    
    func getBoolCell(header:String, placeholder:String, initialValue:Bool?, didPickValueClosure:@escaping DidPickFieldValueClosure, field:Field?, comfort:ComfortItem?) -> BooleanValuePickerTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BooleanValue") as! BooleanValuePickerTableViewCell
        
        cell.isSmallHeader = self.isSmallHeaders
        
        cell.header = header
        
        cell.didPickValueClosure = didPickValueClosure
        if (initialValue != nil) {
            cell.initialValue = initialValue!
        } else {
            cell.initialValue = false
        }
        cell.placeholder = placeholder
        
        if (field != nil) {
            field?.delegate = cell
            
            cell.notAllowed = field?.notAllowed
            cell.icon = field?.icon
        }
        
        if (comfort != nil) {
            cell.icon = comfort?.logo_64x64
        }
        
        return cell
    }
    
    func getIntCell(header:String, placeholder:String, initialValue:Int?, didPickValueClosure:@escaping DidPickFieldValueClosure, field:Field?) -> IntValuePickerTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IntValue") as! IntValuePickerTableViewCell
        
        cell.isSmallHeader = self.isSmallHeaders
        
        cell.header = header
        cell.didPickValueClosure = didPickValueClosure
        
        cell.initialValue = initialValue
        
        cell.placeholder = placeholder
        
        return cell
    }
    
    func getIntInputCell(header:String, placeholder:String, initialValue:Int?, didPickValueClosure:@escaping DidPickFieldValueClosure, field:Field?) -> IntInputTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IntInputValue") as! IntInputTableViewCell
        
        cell.isSmallHeader = self.isSmallHeaders
        
        cell.header = header
        cell.didPickValueClosure = didPickValueClosure
        
        cell.initialValue = initialValue
        
        cell.placeholder = placeholder
        
        if (disableTextFields) {
            cell.valuePickerTextField.isUserInteractionEnabled = false
        }
        
        cell.unitLabel.text = field!.unit
        
        return cell
    }
    
    func getStringCell(header:String, placeholder:String, initialValue:String?, field:Field?, didPickValueClosure:@escaping DidPickFieldValueClosure) -> StringValueTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StringValue") as! StringValueTableViewCell
        
        field?.delegate = cell
        
        cell.isSmallHeader = self.isSmallHeaders
        
        cell.header = header
        cell.didPickValueClosure = didPickValueClosure
        if (initialValue != nil) {
            cell.initialValue = initialValue!
        }
        cell.placeholder = placeholder
        
        if (disableTextFields) {
            cell.valuePickerTextField.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    func getLongTextCell(header:String, placeholder:String, initialValue:String, field:Field?, didPickValueClosure:@escaping DidPickFieldValueClosure) -> LongTextTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LongStringValue") as! LongTextTableViewCell
        
        cell.isSmallHeader = self.isSmallHeaders
        
        field?.delegate = cell
        
        cell.header = header
        
        cell.placeholder = placeholder
        cell.initialValue = initialValue
        
        cell.didPickValueClosure = { (newValue) in
            let currentOffset = self.tableView.contentOffset
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            self.tableView.setContentOffset(currentOffset, animated: false)
            
            didPickValueClosure(newValue)
        }
        
        if (disableTextFields) {
            cell.textView.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    func getObjectCell(header:String, placeholder:String, initialValue:AnyObject?, values:[AnyObject]?, viewController:UIViewController, didPickListValueClosure:@escaping DidPickFieldValueClosure, field:Field?) -> ListPickerTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectValue") as! ListPickerTableViewCell
        
        cell.isSmallHeader = self.isSmallHeaders
        
        cell.placeholder = placeholder
        cell.header = header
        cell.didPickListValueClosure = didPickListValueClosure
        cell.value = initialValue
        cell.values = values
        cell.field = field
        
        field?.delegate = cell
        
        cell.didSelectClosure = { () -> Void in
            let listPicker = ListPickerViewController()
            listPicker.delegate = cell
            listPicker.values = cell.values! as [AnyObject]
            
            self.viewController.navigationController?.pushViewController(listPicker, animated: true)
        }
        
        if (disableTextFields) {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func getRangeCell(header:String, minPlaceholder:String, maxPlaceholder:String, minInitialValue:String, maxInitialValue:String, min:Int?, max:Int?, field:Field?, didPickRangeValueClosure:@escaping DidPickRangeValueClosure) -> HeaderIncludedTableViewCell {
        if (min == nil) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RangeValue") as! RangeIntValuePickerTableViewCell
            
            cell.isSmallHeader = self.isSmallHeaders
            
            cell.header = header
            cell.didPickRangeValueClosure = didPickRangeValueClosure
            cell.minPlaceholder = minPlaceholder
            cell.maxPlaceholder = maxPlaceholder
            
            if (minInitialValue != "") {
                cell.minInitialValue = Int(minInitialValue)!
            } else {
                cell.minValuePickerTextField.text = ""
            }
            
            if (maxInitialValue != "") {
                cell.maxInitialValue = Int(maxInitialValue)!
            } else {
                cell.maxValuePickerTextField.text = ""
            }
            
            if (disableTextFields) {
                cell.minValuePickerTextField.isUserInteractionEnabled = false
                cell.maxValuePickerTextField.isUserInteractionEnabled = false
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RangeSliderValue") as! RangeSliderPickerTableViewCell
            
            cell.isSmallHeader = self.isSmallHeaders
            
            cell.header = header
            cell.min = min!
            cell.max = max!
            
            if (minInitialValue != "") {
                cell.rangeSlider.selectedMinValue = CGFloat(Int(minInitialValue)!)
                
                cell.isEnabled = true
            }
            
            if (maxInitialValue != "") {
                cell.rangeSlider.selectedMaxValue = CGFloat(Int(maxInitialValue)!)
                
                cell.isEnabled = true
            }
            
            if (minInitialValue == "" && maxInitialValue == "") {
                cell.isEnabled = false
            }
            
            cell.didPickRangeValueClosure = didPickRangeValueClosure
            
            return cell
        }
    }
    
    func getHeaderCell(header:String) -> HeaderIncludedTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderValue") as! HeaderIncludedTableViewCell
        
        cell.isSmallHeader = self.isSmallHeaders
        
        cell.header = header
        cell.headerLabel.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-Constants.basicOffset*2)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(29)
            make.bottom.equalToSuperview()
        }
        
        return cell
    }
    
    func getCellForObject(object:AnyObject, index:Int, key:String, header:String) -> UITableViewCell {
        var cell:HeaderIncludedTableViewCell = HeaderIncludedTableViewCell()
        
        let value = object.value(forKeyPath: key)!
        
        if value is Bool {
            cell = getBoolCell(header: header, placeholder:placeholders[index], initialValue: value as? Bool, didPickValueClosure: { (newValue) in
                self.object.setValue(newValue, forKeyPath: self.keys[index])
            }, field: nil, comfort: nil)
            
            return cell
        } else if (value is NSNumber || value is Int) {
            let optionKeyExists = options.keys.contains(key)
            
            if (optionKeyExists) {
                let optionValue = options[key] as! String
                
                if (optionValue=="range") {
                    cell = getRangeCell(header: header, minPlaceholder:placeholders[index], maxPlaceholder:placeholders[index], minInitialValue:"0", maxInitialValue:"0", min: nil, max: nil, field: nil, didPickRangeValueClosure: { (minValue, maxValue) in
                        
                    })
                    
                    return cell
                }
            } else {
                cell = getIntCell(header: header, placeholder:placeholders[index], initialValue: value as? Int, didPickValueClosure: { (newValue) in
                    self.object.setValue(newValue, forKeyPath: self.keys[index])
                }, field: nil)
                
                return cell
            }
        } else if value is AnyClass {
            cell = getObjectCell(header: header, placeholder:placeholders[index], initialValue: value as AnyObject, values: [], viewController:viewController, didPickListValueClosure: { (newValue) in
                self.object.setValue(newValue, forKeyPath: self.keys[index])
            }, field: nil)
            
            return cell
        } else if value is String {
            let optionKeyExists = options.keys.contains(key)
            
            if (optionKeyExists) {
                let optionValue = options[key] as! String
                
                if (optionValue=="longText") {
                    cell = getLongTextCell(header: header, placeholder:placeholders[index], initialValue: value as! String, field:nil, didPickValueClosure: { (newValue) in
                        self.object.setValue(newValue, forKeyPath: self.keys[index])
                    })
                    
                    return cell
                }
            }
            
            cell = getStringCell(header: header, placeholder:placeholders[index], initialValue: value as? String, field: nil, didPickValueClosure: { (newValue) in
                self.object.setValue(newValue, forKeyPath: self.keys[index])
            })
            
            return cell
        }
        
        return cell
    }
    
    func getCellForArrayValue(object:AnyObject, index:Int, key:String, header:String) -> UITableViewCell {
        let array = object as! [AnyObject]
        
        if (array[index] is Field) {
            let field = array[index] as! Field
            
            //custom cells case
            if (field.isCustomCellField) {
                let className = field.customCellClassString!
                
                var cell = tableView.dequeueReusableCell(withIdentifier: className) as? FillableCellDelegate
                
                if (cell == nil) {
                    if let aClass: AnyClass = NSClassFromString("Pillowz."+className) {
                        tableView.register(aClass, forCellReuseIdentifier: className)
                        
                        cell = tableView.dequeueReusableCell(withIdentifier: className) as? FillableCellDelegate
                    }
                }
                
                if (cell is HeaderIncludedTableViewCell) {
                    (cell as! HeaderIncludedTableViewCell).isSmallHeader = self.isSmallHeaders
                    (cell as! HeaderIncludedTableViewCell).header = header
                }
                
                //not universal, but screw it for now
                if (cell is StringValueTableViewCell) {
                    (cell as! StringValueTableViewCell).placeholder = field.multiLanguageName!["ru"]!
                }
                
                cell?.fillWithObject(object: field.customCellObject!)
                
                return cell! as! UITableViewCell
            }
            
            if field.type=="IntegerField" {
                var isInput = false
                
                if (field.isInput != nil) {
                    if (field.isInput!) {
                        isInput = true
                    }
                }
                
                if (isInput) {
                    let cell = getIntInputCell(header: header, placeholder: field.name!, initialValue: Int(field.value), didPickValueClosure: field.didPickFieldValueClosure, field: field)
                    
                    return cell
                } else {
                    let cell = getIntCell(header: header, placeholder:field.name!, initialValue: Int(field.value), didPickValueClosure: field.didPickFieldValueClosure, field: field)
                    
                    return cell
                }
                
            } else if field.type=="CharField" {
                let optionKeyExists = options.keys.contains(key)
                
                if (optionKeyExists) {
                    let optionValue = options[key] as! String
                    
                    if (optionValue=="longText") {
                        let cell = getLongTextCell(header: header, placeholder:field.name!, initialValue: field.value, field: field, didPickValueClosure: field.didPickFieldValueClosure)
                        
                        return cell
                    }
                }
                
                let cell = getStringCell(header: header, placeholder:field.name!, initialValue: field.value, field:field, didPickValueClosure: field.didPickFieldValueClosure)
                
                return cell
            } else if field.type=="ChoiceField" {
                var placeholder:String
                
                if (field.customText != nil) {
                    placeholder = field.customText!
                } else {
                    placeholder = field.name!
                }
                
                let cell = getObjectCell(header: header, placeholder:placeholder, initialValue: field.selectedChoice, values: field.choices, viewController: viewController, didPickListValueClosure: field.didPickFieldValueClosure, field: field)
                
                return cell
            } else if field.type=="BooleanField" {
                var initialValue = field.value.toBool()
                
                let cell = getBoolCell(header: header, placeholder:field.name!, initialValue: initialValue, didPickValueClosure:field.didPickFieldValueClosure, field: field, comfort:nil)
                
                return cell
            } else if field.type=="InlineField" {
                let firstInitialValue = field.first!.value
                let secondInitialValue = field.second!.value
                
                let min = field.min
                let max = field.max
                
                let cell = getRangeCell(header: header, minPlaceholder:"От", maxPlaceholder: "До", minInitialValue:firstInitialValue, maxInitialValue:secondInitialValue, min: min, max: max, field: field, didPickRangeValueClosure: field.didPickRangeValueClosure!)
                
                return cell
            } else if field.type=="HeaderField" {
                let cell = getHeaderCell(header: header)
                
                return cell
            }
        } else if (array[index] is ComfortItem) {
            let comfortItem = array[index] as! ComfortItem
            
            let cell = getBoolCell(header: header, placeholder:comfortItem.name!, initialValue: comfortItem.checked, didPickValueClosure: { (newValue) in
                comfortItem.checked = newValue as? Bool
            }, field: nil, comfort:comfortItem)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        var index = indexPath.row
        if (hasHeaderView) {
            index = index-1
        }
        
        if (cell is ListPickerTableViewCell && !disableTextFields) {
            let listPickerCell = cell as! ListPickerTableViewCell
            
            let array = object as! Array<Any>
            
            let field = array[index] as! Field
            
            if (field.didSelectClosure != nil) {
                field.didSelectClosure!()
            } else {
                listPickerCell.didSelectClosure()
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let rows = self.tableView.indexPathsForVisibleRows
        
        if (rows != nil && rows?.count != 0) {
            let topVisibleIndexPath:IndexPath = rows![0]
            
            topMostCellListenerDelegate?.willDisplayCellAtIndex(topVisibleIndexPath.row)
        }
    }
}

extension UITableViewCell {
    func addSeparatorView() {
        removeSeparatorView()
        
        let separatorView = UIView()
        
        let separatorViewTag = 999
        
        separatorView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        separatorView.tag = separatorViewTag
        self.contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo(Constants.screenFrame.width-2*Constants.basicOffset)
            make.height.equalTo(1)
            make.bottom.equalToSuperview().offset(-1)
        }
    }
    
    func removeSeparatorView() {
        let separatorViewTag = 999
        self.contentView.viewWithTag(separatorViewTag)?.removeFromSuperview()
    }
}

extension String {
    func toBool() -> Bool {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return false
        }
    }
}
