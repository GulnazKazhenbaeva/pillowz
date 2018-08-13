//
//  DateAndTimePickerViewController.swift
//  Pillowz
//
//  Created by Samat on 06.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import FSCalendar
import DateToolsSwift

@objc protocol DateAndTimePickerViewControllerDelegate {
    func didPickStartDate(_ startDate:Date, endDate:Date?)
    @objc optional func didClearDates()
}

class DateAndTimePickerViewController: StepViewController, FSCalendarDelegate, FSCalendarDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate, SelectedDateViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let spaceCalendarDelegate = SpaceCalendarDelegate()
    fileprivate weak var calendar: FSCalendar!
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    let dateFormatter = DateFormatter()
    
    var space:Space! {
        didSet {
            spaceCalendarDelegate.space = space
        }
    }
    
    var startDate:Date? {
        didSet {
            guard let startDate = startDate else {
                spaceCalendarDelegate.startDate = nil

                self.startTimeTextField.text = "не выбрано"

                return
            }
            
            let beginningOfDate = Calendar.current.startOfDay(for: Date())
            
            if startDate.isEarlier(than: beginningOfDate) {
                DesignHelpers.makeToastWithText("Данный период нельзя выбрать")
                
                self.startDate = nil
                self.endDate = nil
                
                spaceCalendarDelegate.startDate = startDate
                
                return
            }
            
            self.startTimeTextField.text = dateFormatter.string(from: startDate)

            if (rentType == .HALFDAY) {
                endDate = startDate.add(.init(seconds: 0, minutes: 0, hours: 12, days: 0, weeks: 0, months: 0, years: 0))
            } else if (rentType == .MONTHLY) {
                endDate = startDate.add(.init(seconds: 0, minutes: 0, hours:0, days: 0, weeks: 0, months: 1, years: 0))
            }
            
            spaceCalendarDelegate.startDate = startDate
        }
    }
    
    var endDate:Date? {
        didSet {
            if (startDate == nil) {
                endDate = nil
            }
            
            if (endDate != nil) {
                if (!self.chosenPeriodOverlapsWithBookings()) {
                    self.endTimeTextField.text = dateFormatter.string(from: endDate!)
                } else {
                    startDate = nil
                    endDate = nil
                    
                    selectedDateView.clearChosenPeriod()
                    
                    DesignHelpers.makeToastWithText("Данный период нельзя выбрать")
                }
            } else {
                self.endTimeTextField.text = "не выбрано"
            }
            
            spaceCalendarDelegate.endDate = endDate
            
            if let startDate = startDate, let endDate = endDate {
                CurrentNewOpenRequestValues.shared.startTime = Int(startDate.timeIntervalSince1970)
                CurrentNewOpenRequestValues.shared.endTime = Int(endDate.timeIntervalSince1970)
            }
            
            let _ = checkIfAllFieldsAreFilled()
        }
    }

    var rentType:RENT_TYPES! {
        didSet {
            spaceCalendarDelegate.rentType = rentType
            
            selectedDateView.isHidden = !(spaceCalendarDelegate.rentType == .HOURLY)
        }
    }
    
    var isForSteps = false
    
    let startTimeTextField = UITextField()
    let endTimeTextField = UITextField()

    let startLabel = UILabel()
    let endLabel = UILabel()
    
    let startTimePickerView = UIPickerView()
    let endTimePickerView = UIPickerView()
    var hours:[Int] = []

    var delegate:DateAndTimePickerViewControllerDelegate?
    
    let doneButton = PillowzButton()
    
    var selectedDateView = SelectedDateView(mode: .chooseHours)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for i in 0..<24 {
            hours.append(i)
        }
        startTimePickerView.dataSource = self
        startTimePickerView.delegate = self
        endTimePickerView.dataSource = self
        endTimePickerView.delegate = self

        let leftButton: UIButton = UIButton(type: .custom)
        leftButton.setImage(UIImage(named: "close"), for: .normal)
        leftButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        leftButton.frame = CGRect(x:0, y:0, width:44, height:44)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        
        dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        let isDays = (rentType == .DAILY)
        
        endLabel.isHidden = !isDays
        endTimeTextField.isHidden = !isDays
        
        let isMonth = (rentType == .MONTHLY)
        
        if isMonth {
            startLabel.isHidden = true
            startTimeTextField.isHidden = true

            endLabel.isHidden = true
            endTimeTextField.isHidden = true
        }
        
        spaceCalendarDelegate.space = self.space
        spaceCalendarDelegate.calendar = self.calendar
        spaceCalendarDelegate.dateAndTimePickingMode = true
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.selectedDateView.scrollView.panGestureRecognizer.require(toFail: self.scopeGesture)
        
        self.selectedDateView.chooseHoursDelegate = self
        self.selectedDateView.space = space
        
        let rightButton: UIButton = UIButton(type: .custom)
        rightButton.setTitle("сбросить", for: .normal)
        rightButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
        rightButton.titleLabel?.font = UIFont.init(name: "OpenSans-Bold", size: 13)!
        rightButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        rightButton.frame = CGRect(x:0, y:0, width:90, height:30)
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        if let startTime = CurrentNewOpenRequestValues.shared.startTime, let endTime = CurrentNewOpenRequestValues.shared.endTime {
            startDate = Date(timeIntervalSince1970: TimeInterval(startTime))
            endDate = Date(timeIntervalSince1970: TimeInterval(endTime))
            
            selectedDateView.date = endDate!
        } else {
            var newStartDate = Date().add(.init(seconds: 0, minutes: 0, hours: 2, days: 0, weeks: 0, months: 0, years: 0))
            
            if (rentType == .MONTHLY) {
                newStartDate = Date().add(.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 1, months: 0, years: 0))
            }
            
            let roundedStartDate = Calendar.current.date(bySetting: .minute, value: 0, of: newStartDate)

            startDate = roundedStartDate
            
            selectedDateView.date = startDate!
            
            if (rentType == .HOURLY) {
                endDate = startDate!.add(.init(seconds: 0, minutes: 0, hours: 6, days: 0, weeks: 0, months: 0, years: 0))
            } else if (rentType == .DAILY) {
                endDate = startDate!.add(.init(seconds: 0, minutes: 0, hours: 0, days: 1, weeks: 0, months: 0, years: 0))
            }
        }
    }
    
    @objc func closeTapped() {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func clearTapped() {
        startDate = nil
        endDate = nil
        
        self.calendar.setScope(.month, animated: true)
        
        self.calendar.reloadData()
        
        self.selectedDateView.clearChoosingHours()
        self.selectedDateView.clearView()
        self.selectedDateView.addBookingViews()

        delegate?.didClearDates?()
    }
    
    override func loadView() {
        super.loadView()

        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
        view.addSubview(calendar)
        calendar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(300)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        calendar.delegate = self
        calendar.swipeToChooseGesture.isEnabled = false // Swipe-To-Choose
        
        self.calendar = calendar
        
        
        self.view.addSubview(startTimeTextField)
        startTimeTextField.isEnabled = true
        startTimeTextField.inputView = startTimePickerView
        startTimeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self.calendar.snp.bottom).offset(10)
            make.height.equalTo(19)
            make.left.equalToSuperview().offset(Constants.screenFrame.size.width/2-Constants.basicOffset)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        startTimeTextField.font = UIFont.init(name: "OpenSans-Light", size: 15)!
        startTimeTextField.textColor = Constants.paletteBlackColor
        startTimeTextField.textAlignment = .right
        startTimeTextField.delegate = self
        startTimeTextField.text = "не выбрано"
        
        self.view.addSubview(startLabel)
        startLabel.text = "Заезд"
        startLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(startTimeTextField)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(19)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        startLabel.font = UIFont.init(name: "OpenSans-Light", size: 15)!
        startLabel.textColor = Constants.paletteBlackColor
        
        self.view.addSubview(endTimeTextField)
        endTimeTextField.inputView = endTimePickerView
        endTimeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(startTimeTextField.snp.bottom).offset(20)
            make.height.equalTo(19)
            make.left.equalToSuperview().offset(Constants.screenFrame.size.width/2-Constants.basicOffset)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        endTimeTextField.font = UIFont.init(name: "OpenSans-Light", size: 15)!
        endTimeTextField.textColor = Constants.paletteBlackColor
        endTimeTextField.textAlignment = .right
        endTimeTextField.delegate = self
        endTimeTextField.text = "не выбрано"
        endTimeTextField.isHidden = true
        
        self.view.addSubview(endLabel)
        endLabel.text = "Выезд"
        endLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(endTimeTextField)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(19)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        endLabel.font = UIFont.init(name: "OpenSans-Light", size: 15)!
        endLabel.textColor = Constants.paletteBlackColor
        endLabel.isHidden = true
        
        startTimePickerView.backgroundColor = .white
        startTimePickerView.setValue(Constants.paletteVioletColor, forKey:"textColor")
        endTimePickerView.backgroundColor = .white
        endTimePickerView.setValue(Constants.paletteVioletColor, forKey:"textColor")
        
        self.view.addSubview(selectedDateView)
        selectedDateView.snp.makeConstraints { (make) in
            make.top.equalTo(calendar.snp.bottom)
            make.bottom.equalToSuperview().offset(0)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        if !isForSteps {
            self.view.addSubview(doneButton)
            PillowzButton.makeBasicButtonConstraints(button: doneButton, pinToTop: false)
            doneButton.setTitle("Готово", for: .normal)
            doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints { (make) in
            make.height.equalTo(bounds.height)
            // Do other updates
        }
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        self.spaceCalendarDelegate.configure(cell: cell, for: date, at: position)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        print("selected dates is \(selectedDates)")
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        
        if (startDate != nil && endDate != nil || rentType == .HOURLY || rentType == .HALFDAY) {
            startDate = date

            if (rentType == .HOURLY) {
                self.calendar.setScope(.week, animated: true)

                selectedDateView.date = date
                selectedDateView.bookings = self.spaceCalendarDelegate.bookings
            } else if (rentType != .MONTHLY) {
                startTimeTextField.becomeFirstResponder()
                
                handleDatePicker(startTimePickerView)
            }
            
            endDate = nil
        } else {
            if (startDate == nil || rentType == .MONTHLY) {
                if rentType == .MONTHLY {
                    startDate = date

                    startDate = startDate?.add(.init(seconds: 0, minutes: 0, hours: 12, days: 0, weeks: 0, months: 0, years: 0))
                }
                
                if (rentType != .MONTHLY) {
                    startTimeTextField.becomeFirstResponder()
                    
                    handleDatePicker(startTimePickerView)
                }
            } else {
                if (date.isEarlier(than: startDate!)) {
                    startDate = date
                    
                    if (rentType != .MONTHLY) {
                        startTimeTextField.becomeFirstResponder()
                        
                        handleDatePicker(startTimePickerView)
                    }
                    
                    endDate = nil
                } else {
                    endDate = date
                    
                    if (rentType != .MONTHLY) {
                        endTimeTextField.becomeFirstResponder()
                        
                        handleDatePicker(endTimePickerView)
                    }
                }
            }
        }
        
        self.spaceCalendarDelegate.configureVisibleCells()
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        self.spaceCalendarDelegate.configureVisibleCells()
    }
    
    @objc func doneTapped() {
        let isDays = (rentType == .DAILY)

        if (isDays) {
            if (startDate == nil || endDate == nil){
                self.navigationController?.popViewController(animated: false)

                return
            }
        } else {
            if (startDate == nil) {
                self.navigationController?.popViewController(animated: false)

                return
            }
        }
        
        let beginningOfDate = Calendar.current.startOfDay(for: Date())

        if (startDate!.isEarlier(than: beginningOfDate)) {
            DesignHelpers.makeToastWithText("Данный период нельзя выбрать")

            startDate = nil
            endDate = nil
            
            return
        }
        
        if (isDays) {
            if (endDate!.isEarlier(than: startDate!)) {
                DesignHelpers.makeToastWithText("Данный период нельзя выбрать")
                
                endDate = nil
                
                return
            }
        }
        
        self.delegate?.didPickStartDate(startDate!, endDate: endDate)
        self.navigationController?.popViewController(animated: false)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hours.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(hours[row])+":00"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        handleDatePicker(pickerView)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @objc func handleDatePicker(_ sender: UIPickerView) {
        if (startDate != nil && sender === self.startTimePickerView) {
            startDate = Calendar.current.startOfDay(for: startDate!)
        } else if (startDate == nil && sender === self.startTimePickerView) {
            let selectedDate = calendar.selectedDate
            
            if (selectedDate != nil) {
                startDate = Calendar.current.startOfDay(for: selectedDate!)
            }
        }
        
        if (endDate != nil && sender === self.endTimePickerView) {
            endDate = Calendar.current.startOfDay(for: endDate!)
        } else if (endDate == nil && sender === self.endTimePickerView) {
            let selectedDate = calendar.selectedDate
            
            if (selectedDate != nil) {
                endDate = Calendar.current.startOfDay(for: selectedDate!)
            }
        }
        
        let hours = sender.selectedRow(inComponent: 0)
        
        if sender === self.startTimePickerView {
            startDate = startDate?.add(.init(seconds: 0, minutes: 0, hours: hours, days: 0, weeks: 0, months: 0, years: 0))
        } else {
            endDate = endDate?.add(.init(seconds: 0, minutes: 0, hours: hours, days: 0, weeks: 0, months: 0, years: 0))
        }
        
        if let startDate = startDate, startDate.isEarlier(than: Date().add(.init(seconds: 0, minutes: 0, hours: 1, days: 0, weeks: 0, months: 0, years: 0))) {
            self.startDate = nil
            endDate = nil
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.selectedDateView.scrollView.contentOffset.y <= -self.selectedDateView.scrollView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField === startTimeTextField) {
            if startDate?.day == Date().day {
                startTimePickerView.selectRow(Date().hour + 1, inComponent: 0, animated: false)
            } else {
                startTimePickerView.selectRow(14, inComponent: 0, animated: false)
            }
        } else {
            endTimePickerView.selectRow(12, inComponent: 0, animated: false)
        }
    }
    
    func didPickDatesForHourlyRentType(_ startDate: Date, _ endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }

    func chosenPeriodOverlapsWithBookings() -> Bool {
        let beginningOfDate = Calendar.current.startOfDay(for: Date())
        
        guard let startDate = startDate, let endDate = endDate else {
            return false
        }
        
        if (startDate.isEarlier(than: beginningOfDate)) {
            return true
        }
        
        for booking in self.spaceCalendarDelegate.bookings {
            let bookingStartDate = Date(timeIntervalSince1970: TimeInterval(booking.timestamp_start))
            let bookingEndDate = Date(timeIntervalSince1970: TimeInterval(booking.timestamp_end))
            
            let bookingPeriod = TimePeriod(beginning: bookingStartDate, end: bookingEndDate)
            let chosenPeriod = TimePeriod(beginning: startDate, end: endDate)
            
            if (chosenPeriod.overlaps(with: bookingPeriod)) {
                return true
            }
        }
        
        return false
    }
    
    override func checkIfAllFieldsAreFilled() -> Bool {
        let filled = (CurrentNewOpenRequestValues.shared.startTime != nil && CurrentNewOpenRequestValues.shared.endTime != nil)
        
        OpenRequestStepsViewController.shared.nextButton.isEnabled = filled
        
        if filled {
            OpenRequestStepsViewController.shared.nextButton.backgroundColor = UIColor(hexString: "#FA533C")
        }
        
        return filled
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

extension Date {
    func isBetweeen(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self) == self.compare(date2)
    }
}
