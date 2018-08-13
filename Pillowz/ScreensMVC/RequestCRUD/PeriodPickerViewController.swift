//
//  PeriodPickerViewController.swift
//  Pillowz
//
//  Created by Samat on 17.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

public typealias SavePeriodWithAPIClosure = (_ timestampStart: Int?, _ timestampEnd: Int?, _ rentType:RENT_TYPES) -> Void

enum PeriodPickerViewControllerMode {
    case request
    case booking
}

class PeriodPickerViewController: ValidationViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, DateAndTimePickerViewControllerDelegate {
    //pickerview vars
    var pickerViewComponentHeight:CGFloat = 30
    var pickerViewComponentWidth:CGFloat = 46
    var rotationAngle:CGFloat!
    var hours:[Int] = [1,2,3,4,5,6,7,8,9,10,11]
    let hoursPickerView = UIPickerView()
    let hoursPickerViewTopLabel = UILabel()
    let hoursPickerViewBottomLabel = UILabel()
    let hoursPickerViewTopPointerImageView = UIImageView()
    let hoursPickerViewBottomPointerImageView = UIImageView()
    
    let crudVM = CreateEditObjectTableViewGenerator()
    
    let scrollView = UIScrollView()
    
    var mode:PeriodPickerViewControllerMode = .request {
        didSet {
            handleBookingViews()
        }
    }
    var space:Space?
    
    var start_time:Int?
    var end_time:Int?

    var fromDate:Date? {
        didSet {
            if (fromDate != nil) {
                self.fromField.setTitle(dateFormatter.string(from: fromDate!), for: .normal)
                
                start_time = Int(fromDate!.timeIntervalSince1970)

                if (rent_type == .HALFDAY) {
                    tillDate = fromDate?.add(.init(seconds: 0, minutes: 0, hours: 12, days: 0, weeks: 0, months: 0, years: 0))
                } else if (rent_type == .MONTHLY) {
                    tillDate = fromDate?.add(.init(seconds: 0, minutes: 0, hours:0, days: 0, weeks: 0, months: 1, years: 0))
                }
            } else {
                self.fromField.setTitle("не выбрано", for: .normal)
            }
        }
    }
    var tillDate:Date? {
        didSet {
            if (tillDate != nil) {
                self.tillField.setTitle(dateFormatter.string(from: tillDate!), for: .normal)
                
                end_time = Int(tillDate!.timeIntervalSince1970)
                
                if (space != nil) {
                    totalPaymentView.payment = space!.calculateTotalPriceFor(rent_type, startTimestamp: start_time!, endTimestamp: end_time!)
                }
            } else {
                self.tillField.setTitle("не выбрано", for: .normal)
                totalPaymentView.payment = 0
            }
        }
    }
    
    let fromLabel = UILabel()
    let fromField = UIButton()
    
    let tillLabel = UILabel()
    let tillField = UIButton()
    
    let fromTillDatesHeaderLabel = UILabel()
    
    let dateFormatter = DateFormatter()

    let numberOfGuestsLabel = UILabel()
    let numberOfGuestsValuePickerView = IntValuePickerView(initialValue: 0, step: 1, additionalText: "")
    
    
    let totalPaymentView = TotalPaymentView()

    var rent_type:RENT_TYPES = .DAILY {
        didSet {
            didSetRentType()
        }
    }
    
    var fields:[Field] = []
    var headers:[String] = []

    let rentTypeField = Field()
    
    var savePeriodWithAPIClosure:SavePeriodWithAPIClosure?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if (space != nil) {
            for price in space!.prices! {
                if (price.rent_type != nil) {
                    rent_type = price.rent_type!
                    break
                }
            }
        }
        
        totalPaymentView.payment = 0
        
        rotationAngle = -90 * (.pi/180)

        dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        hoursPickerView.dataSource = self
        hoursPickerView.delegate = self
        
        var choices:[Choice] = []
        
        for rentType in RENT_TYPES.allValues {
            let choice = Choice()
            choice.value = String(rentType.rawValue)
            choice.multiLanguageName = Price.getDisplayNameForRentType(rent_type: rentType, isForPrice: false)

            if (space != nil) {
                let price = space!.getPriceFor(rentType)
                if (price != 0) {
                    choices.append(choice)
                }
            } else {
                choices.append(choice)
            }
        }
        
        rentTypeField.setCustomText(text: Price.getDisplayNameForRentType(rent_type: rent_type, isForPrice: false)["ru"]!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.didSetRentType() //just to call setter
        }
        
        rentTypeField.type = "ChoiceField"
        rentTypeField.param_name = "Период"
        rentTypeField.multiLanguageName = ["ru": "Период", "en":"Период"]
        rentTypeField.choices = choices
        rentTypeField.didPickFieldValueClosure = { (newValue) in
            let choice = newValue as! Choice
            
            self.rent_type = RENT_TYPES(rawValue: Int(choice.value!)!)!
        }
        
        fields.append(rentTypeField)
        headers.append("На какой период?")
        
        crudVM.viewController = self
        crudVM.object = fields as AnyObject
        crudVM.headers = headers
        
        
        
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
        }

        crudVM.tableView.removeFromSuperview()
        scrollView.addSubview(crudVM.tableView)
        
        crudVM.tableView.snp.removeConstraints()
        crudVM.tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview()
            make.width.equalTo(Constants.screenFrame.size.width)
            make.height.equalTo(80)
        }
        
        crudVM.tableView.bounces = false
        crudVM.tableView.isScrollEnabled = false

        scrollView.addSubview(fromTillDatesHeaderLabel)
        fromTillDatesHeaderLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-Constants.basicOffset*2)
            make.height.equalTo(20)
            make.top.equalTo(crudVM.tableView.snp.bottom).offset(32)
        }
        fromTillDatesHeaderLabel.textColor = Constants.paletteBlackColor
        fromTillDatesHeaderLabel.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        fromTillDatesHeaderLabel.text = "Даты"
        
        scrollView.addSubview(fromField)
        fromField.isEnabled = true
        fromField.snp.makeConstraints { (make) in
            make.top.equalTo(fromTillDatesHeaderLabel.snp.bottom).offset(10)
            make.height.equalTo(19)
            make.left.equalToSuperview().offset(Constants.screenFrame.size.width/2-Constants.basicOffset)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        fromField.titleLabel?.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        fromField.setTitleColor(Constants.paletteVioletColor, for: .normal)
        fromField.contentHorizontalAlignment = .right
        if (fromDate == nil) {
            fromField.setTitle("не выбрано", for: .normal)
        }
        fromField.addTarget(self, action: #selector(pickDateTapped), for: .touchUpInside)
        
        scrollView.addSubview(fromLabel)
        fromLabel.text = "Дата заезда"
        fromLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(fromField)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(19)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        fromLabel.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        fromLabel.textColor = Constants.paletteBlackColor

        scrollView.addSubview(tillField)
        tillField.snp.makeConstraints { (make) in
            make.top.equalTo(fromField.snp.bottom).offset(20)
            make.height.equalTo(19)
            make.left.equalToSuperview().offset(Constants.screenFrame.size.width/2-Constants.basicOffset)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        tillField.titleLabel?.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        tillField.setTitleColor(Constants.paletteVioletColor, for: .normal)
        tillField.contentHorizontalAlignment = .right
        if (tillDate == nil) {
            tillField.setTitle("не выбрано", for: .normal)
        }
        tillField.isHidden = true
        tillField.addTarget(self, action: #selector(pickDateTapped), for: .touchUpInside)

        scrollView.addSubview(tillLabel)
        tillLabel.text = "Дата выезда"
        tillLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(tillField)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(19)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        tillLabel.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        tillLabel.textColor = Constants.paletteBlackColor
        tillLabel.isHidden = true
        
        hoursPickerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
        scrollView.addSubview(hoursPickerView)
        hoursPickerView.frame = CGRect(x: -150, y: 230, width: Constants.screenFrame.size.width+300, height: pickerViewComponentHeight)
        
        
        scrollView.addSubview(hoursPickerViewTopLabel)
        hoursPickerViewTopLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(hoursPickerView.frame.origin.y-18)
            make.height.equalTo(18)
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
        }
        hoursPickerViewTopLabel.textAlignment = .center
        hoursPickerViewTopLabel.text = "на срок"
        hoursPickerViewTopLabel.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        hoursPickerViewTopLabel.textColor = UIColor(white: 0.0, alpha: 0.54)
        
        scrollView.addSubview(hoursPickerViewBottomLabel)
        hoursPickerViewBottomLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(hoursPickerView.frame.origin.y+hoursPickerView.frame.size.height)
            make.height.equalTo(18)
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
        }
        hoursPickerViewBottomLabel.textAlignment = .center
        hoursPickerViewBottomLabel.text = "часов"
        hoursPickerViewBottomLabel.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        hoursPickerViewBottomLabel.textColor = UIColor(white: 0.0, alpha: 0.54)
        
        scrollView.addSubview(hoursPickerViewTopPointerImageView)
        hoursPickerViewTopPointerImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(hoursPickerView.frame.origin.y-1)
            make.height.equalTo(5)
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
        }
        hoursPickerViewTopPointerImageView.image = #imageLiteral(resourceName: "down")
        hoursPickerViewTopPointerImageView.contentMode = .center

        scrollView.addSubview(hoursPickerViewBottomPointerImageView)
        hoursPickerViewBottomPointerImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(hoursPickerView.frame.origin.y+hoursPickerView.frame.size.height-5+1)
            make.height.equalTo(5)
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
        }
        hoursPickerViewBottomPointerImageView.image = #imageLiteral(resourceName: "up")
        hoursPickerViewBottomPointerImageView.contentMode = .center
        
        hoursPickerView.isHidden = true
        hoursPickerViewTopLabel.isHidden = true
        hoursPickerViewBottomLabel.isHidden = true
        hoursPickerViewTopPointerImageView.isHidden = true
        hoursPickerViewBottomPointerImageView.isHidden = true
        
        
//        scrollView.addSubview(numberOfGuestsLabel)
//        numberOfGuestsLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(Constants.basicOffset)
//            make.top.equalTo(hoursPickerViewBottomLabel.snp.bottom).offset(25)
//            make.right.equalToSuperview().offset(-Constants.basicOffset)
//            make.height.equalTo(20)
//        }
//        numberOfGuestsLabel.text = "Количество гостей"
//        numberOfGuestsLabel.textColor = Constants.paletteBlackColor
//        numberOfGuestsLabel.font = UIFont.init(name: "OpenSans-Light", size: 16)!
//
//        scrollView.addSubview(numberOfGuestsValuePickerView)
//        numberOfGuestsValuePickerView.snp.makeConstraints { (make) in
//            make.right.equalTo(fromField.snp.right)
//            make.width.equalTo(97)
//            make.height.equalTo(40)
//            make.centerY.equalTo(numberOfGuestsLabel.snp.centerY)
//        }
        
        scrollView.addSubview(totalPaymentView)
        totalPaymentView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(85)
            
            if (mode == .booking) {
                make.top.equalTo(tillLabel.snp.bottom).offset(29)
            } else {
                make.top.equalTo(hoursPickerViewBottomLabel.snp.bottom).offset(29)
            }
        }
        

        self.automaticallyAdjustsScrollViewInsets = true
        
        self.view.bringSubview(toFront: self.saveButton)
        
        handleBookingViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (fromDate != nil) {
            self.fromField.setTitle(dateFormatter.string(from: fromDate!), for: .normal)
        }
        
        if (tillDate != nil) {
            self.tillField.setTitle(dateFormatter.string(from: tillDate!), for: .normal)
        }
    }
    
    func didSetRentType() {
        let isShowingHoursPickerView = false//(chosenRentType! == .HOURLY)
        let isShowingTillDate = (rent_type == .DAILY || rent_type == .HOURLY)
        
        hoursPickerView.isHidden = !isShowingHoursPickerView
        hoursPickerViewTopLabel.isHidden = !isShowingHoursPickerView
        hoursPickerViewBottomLabel.isHidden = !isShowingHoursPickerView
        hoursPickerViewTopPointerImageView.isHidden = !isShowingHoursPickerView
        hoursPickerViewBottomPointerImageView.isHidden = !isShowingHoursPickerView
        
        tillLabel.isHidden = !isShowingTillDate
        tillField.isHidden = !isShowingTillDate
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: Constants.screenFrame.size.width, height: 900)
    }
    
    override func saveWithAPI() {
        if (rent_type == .HALFDAY) {
            tillDate = fromDate?.add(.init(seconds: 0, minutes: 0, hours: 12, days: 0, weeks: 0, months: 0, years: 0))
        } else if (rent_type == .MONTHLY) {
            tillDate = fromDate?.add(.init(seconds: 0, minutes: 0, hours:0, days: 0, weeks: 0, months: 1, years: 0))
        }
        
        if (mode == .request) {
            savePeriodWithAPIClosure?(start_time, end_time, rent_type)
        } else {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            SpaceAPIManager.createBooking(spaceId: self.space!.space_id.intValue, timestampStart: start_time!, timestampEnd: end_time!, rent_type: rent_type.rawValue, price: 200, completion: { (responseObject, error) in
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if (error == nil) {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    override func isValid() -> Bool {
        if (fromDate == nil) {
            return false
        }
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fromField.resignFirstResponder()
        tillField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField === fromField) {
            fromDate = Date()
        } else {
            tillDate = Date()
        }
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hours.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerViewComponentWidth
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerViewComponentHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: pickerViewComponentWidth, height: pickerViewComponentHeight)
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: pickerViewComponentWidth, height: pickerViewComponentHeight)

        label.text = String(hours[row])
        label.textAlignment = .center
        
        label.transform = CGAffineTransform(rotationAngle: -rotationAngle)
        
        view.addSubview(label)
        
        return view
    }
    
    func handleBookingViews() {
        let showingBooking = (mode == .booking)
        
        //numberOfGuestsLabel.isHidden = !showingBooking
        //numberOfGuestsValuePickerView.isHidden = !showingBooking
        totalPaymentView.isHidden = !showingBooking
        
        if (showingBooking) {
            self.title = "Бронирование"
            self.saveButton.setTitle("Создать бронь", for: .normal)
        } else {
            self.title = ""
        }
    }

    func didPickStartDate(_ startDate: Date, endDate: Date?) {
        fromDate = startDate
        tillDate = endDate
    }
    
    @objc func pickDateTapped() {
        let vc = DateAndTimePickerViewController()
        vc.rentType = rent_type
        
        if (space != nil) {
            vc.space = space!
        }
        
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
