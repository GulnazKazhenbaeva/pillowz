//
//  SelectedDateView.swift
//  Pillowz
//
//  Created by Samat on 04.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import DateToolsSwift

protocol SelectedDateViewDelegate {
    func didPickDatesForHourlyRentType(_ startDate:Date, _ endDate:Date)
}

public enum SelectedDateViewMode {
    case view
    case chooseHours
}

class SelectedDateView: UIView {
    let scrollView = UIScrollView()
    let contentView = UIView()
    var times:[Int] = []
    
    var bookingViews:[UIView] = []
    
    var chooseHoursButtons:[UIButton] = []
    var mode:SelectedDateViewMode = .chooseHours
    
    var date:Date = Date() {
        didSet {
            clearView()
            addBookingViews()
        }
    }
    
    var bookings:[Book] = [] {
        didSet {
            addBookingViews()
        }
    }
    
    var startTime:Int?
    var endTime:Int?
    
    var chooseHoursDelegate:SelectedDateViewDelegate?
    
    var space:Space!
    
    var calculationLabelTag = 199
    var timeLabelTag = 299

    fileprivate let gregorian = Calendar(identifier: .gregorian)
    
    init(mode: SelectedDateViewMode) {
        super.init(frame: CGRect.zero)
        
        self.mode = mode
        
        self.backgroundColor = UIColor.white
        
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
            make.centerX.centerY.equalToSuperview()
        }

        for i in 8...23 {
            times.append(i)
        }
        
        for i in 0...7 {
            times.append(i)
        }
        
        var currentY:CGFloat = 18
        
        for time in times {
            if mode == .chooseHours {
                var hours = time
                
                if (hours<8) {
                    hours = hours + 24
                }
                
                let chooseHoursButton = UIButton()
                contentView.addSubview(chooseHoursButton)
                chooseHoursButton.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().offset(87)
                    make.top.equalToSuperview().offset(currentY-18)
                    make.right.equalToSuperview().offset(-Constants.basicOffset)
                    make.height.equalTo(55)
                }
                chooseHoursButton.tag = hours
                
                if (hours < Date().hour + 1 && date.daysAgo == 0 || date.daysAgo > 0) {
                    chooseHoursButton.setTitle("Время прошло", for: .normal)
                } else {
                    chooseHoursButton.setTitle("Свободно", for: .normal)
                }
                
                chooseHoursButton.addTarget(self, action: #selector(chooseHourButtonTapped(_ :)), for: .touchUpInside)
                
                chooseHoursButton.setTitleColor(.lightGray, for: .normal)

                chooseHoursButtons.append(chooseHoursButton)
            }
            
            let timeLabel = UILabel()
            contentView.addSubview(timeLabel)
            timeLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
            timeLabel.textAlignment = .right
            timeLabel.textColor = Constants.paletteBlackColor
            timeLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(10)
                make.top.equalToSuperview().offset(currentY)
                make.width.equalTo(45)
                make.height.equalTo(19)
            }
            timeLabel.text = String(time)+":00"
            
            //height of label
            currentY = currentY + 19
            
            //from label to separator
            currentY = currentY + 18
            
            let separatorView = UIView()
            contentView.addSubview(separatorView)
            separatorView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(74)
                make.width.equalToSuperview()
                make.top.equalToSuperview().offset(currentY)
                make.height.equalTo(1)
            }
            separatorView.backgroundColor = Constants.paletteLightGrayColor
            
            //from separator to next label
            currentY = currentY + 18
        }
        
        currentY = currentY + 200 //adding space at bottom
        
        contentView.snp.remakeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(currentY)
        }
        
        scrollView.contentSize = CGSize(width: Constants.screenFrame.size.width, height: currentY)
    }
    
    func addBookingViews() {
        clearBookingViews()
        
        for book in bookings {
            addBookingViewFor(booking: book)
        }
    }
    
    func addBookingViewFor(booking:Book) {
        let bookingStartDate = Date(timeIntervalSince1970: TimeInterval(booking.timestamp_start))
        let bookingEndDate = Date(timeIntervalSince1970: TimeInterval(booking.timestamp_end))

        var startOfDate = self.gregorian.date(bySetting: .hour, value: 0, of: date)!
        startOfDate = startOfDate.add(.init(seconds: 0, minutes: 0, hours: 8, days: 0, weeks: 0, months: 0, years: 0))
        let endOfDate = startOfDate.add(.init(seconds: 0, minutes: 59, hours: 23, days: 0, weeks: 0, months: 0, years: 0))

        let bookingPeriod = TimePeriod(beginning: bookingStartDate, end: bookingEndDate)
        let dayPeriod = TimePeriod(beginning: startOfDate, end: endOfDate)
        
        var eventStartHour:Double
        var eventEndHour:Double
        
        if (dayPeriod.overlaps(with: bookingPeriod)) {
            if (dayPeriod.beginning!.isLater(than: bookingPeriod.beginning!)) {
                eventStartHour = Double(dayPeriod.beginning!.hour)
                eventStartHour = eventStartHour + Double(dayPeriod.beginning!.minute)/60
            } else {
                eventStartHour = Double(bookingPeriod.beginning!.hour)
                eventStartHour = eventStartHour + Double(bookingPeriod.beginning!.minute)/60
            }
            
            if (dayPeriod.end!.isEarlier(than: bookingPeriod.end!)) {
                eventEndHour = Double(dayPeriod.end!.hour)
                eventEndHour = eventEndHour + Double(dayPeriod.end!.minute)/60
            } else {
                eventEndHour = Double(bookingPeriod.end!.hour)
                eventEndHour = eventEndHour + Double(bookingPeriod.end!.minute)/60
            }
        } else {
            return
        }
        
        var bookingViewStartHour:Double
        var bookingViewEndHour:Double

        if (eventStartHour>=8) {
            bookingViewStartHour = eventStartHour - 8
        } else {
            bookingViewStartHour = eventStartHour + 16
        }
        
        if (eventEndHour>=8) {
            bookingViewEndHour = eventEndHour - 8
        } else {
            bookingViewEndHour = eventEndHour + 16
        }
        
        let bookingView = UserBookingView(full: true, book: booking)
        
        if (space != nil) {
            bookingView.backgroundColor = .lightGray
        }
        
        bookingView.book = booking
        
        self.contentView.addSubview(bookingView)
        
        bookingView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(87)
            make.top.equalToSuperview().offset(55*bookingViewStartHour)
            make.height.equalTo(55*(bookingViewEndHour - bookingViewStartHour))
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        bookingViews.append(bookingView)
    }
    
    func clearBookingViews() {
        for view in bookingViews {
            view.removeFromSuperview()
        }
    }

    func clearChooseHoursButtons() {
        for chooseHoursButton in chooseHoursButtons {
            chooseHoursButton.viewWithTag(calculationLabelTag)?.removeFromSuperview()
            chooseHoursButton.viewWithTag(timeLabelTag)?.removeFromSuperview()
            
            var hours = chooseHoursButton.tag
            
            if (hours<8) {
                hours = hours + 24
            }
            
            if (hours < Date().hour + 1 && date.isToday || date.daysAgo > 0) {
                chooseHoursButton.setTitle("Время прошло", for: .normal)
            } else {
                chooseHoursButton.setTitle("Свободно", for: .normal)
            }
            
            chooseHoursButton.backgroundColor = .clear
            chooseHoursButton.layer.mask = nil
            chooseHoursButton.layer.cornerRadius = 0
        }
    }
    
    func clearChosenPeriod() {
        clearChooseHoursButtons()
        clearChoosingHours()
    }
    
    func clearView() {
        clearBookingViews()
        clearChooseHoursButtons()
        clearChoosingHours()
    }
    
    func clearChoosingHours() {
        startTime = nil
        endTime = nil
    }
    
    func drawButtonsFilledOnChoosingHours() {
        clearChooseHoursButtons()
        
        if (startTime==nil || endTime==nil) {
            return
        }
        
        for button in chooseHoursButtons {
            var hours = button.tag
            
            if (hours<8) {
                hours = hours + 24
            }
            
            if (button.tag >= startTime! && button.tag < endTime!) {
                button.backgroundColor = Constants.paletteVioletColor
                button.setTitle("", for: .normal)
                
                if (button.tag == startTime!) {
                    let startOfCurrentDate = Calendar.current.startOfDay(for: date)
                    
                    let startDate = startOfCurrentDate.add(.init(seconds: 0, minutes: 0, hours: startTime!, days: 0, weeks: 0, months: 0, years: 0))
                    let endDate = startOfCurrentDate.add(.init(seconds: 0, minutes: 0, hours: endTime!, days: 0, weeks: 0, months: 0, years: 0))

                    let startTimestamp = Int(startDate.timeIntervalSince1970)
                    let endTimestamp = Int(endDate.timeIntervalSince1970)

                    let numberOfHours = endTime! - startTime!
                    var totalPrice = 0
                    
                    if (space != nil) {
                        totalPrice = space.calculateTotalPriceFor(.HOURLY, startTimestamp: startTimestamp, endTimestamp: endTimestamp)
                    }
                    
                    var calculationText = ""
                    if (space != nil) {
                        calculationText = String(numberOfHours) + " часа" + " • " + String(totalPrice) + "₸"
                    } else {
                        calculationText = String(numberOfHours) + " часа"
                    }
                    
                    let calculationLabel = UILabel()
                    calculationLabel.tag = calculationLabelTag
                    button.addSubview(calculationLabel)
                    calculationLabel.text = calculationText
                    calculationLabel.font = UIFont.init(name: "OpenSans-Bold", size: 16)!
                    calculationLabel.textColor = .white
                    calculationLabel.snp.makeConstraints({ (make) in
                        make.top.equalToSuperview().offset(10)
                        make.height.equalTo(20)
                        make.left.equalToSuperview().offset(16)
                        make.right.equalToSuperview().offset(-4)
                    })

                    let timeLabel = UILabel()
                    timeLabel.tag = timeLabelTag
                    button.addSubview(timeLabel)
                    timeLabel.text = "С " + String(startTime!)+":00" + " по " + String(endTime!)+":00"
                    timeLabel.font = UIFont.init(name: "OpenSans-Regular", size: 14)!
                    timeLabel.textColor = .white
                    timeLabel.snp.makeConstraints({ (make) in
                        make.top.equalTo(calculationLabel.snp.bottom).offset(2)
                        make.height.equalTo(20)
                        make.left.equalToSuperview().offset(16)
                        make.right.equalToSuperview().offset(-4)
                    })
                }
                
                if (button.tag == startTime! && button.tag == endTime! - 1) {
                    button.roundedAllButton()
                    
                    continue
                }
                
                if (button.tag == startTime) {
                    button.roundedTopButton()
                    
                    continue
                }
                
                if (button.tag == endTime! - 1) {
                    button.roundedBottomButton()
                    
                    continue
                }
            }
        }
    }
    
    @objc func chooseHourButtonTapped(_ button:UIButton) {
        //let time = button.tag
        
        var hours = button.tag
        
        if (hours<8) {
            hours = hours + 24
        }
        
        if (hours < Date().hour + 1 && date.isToday || date.daysAgo > 0) {
            DesignHelpers.makeToastWithText("Данный период нельзя выбрать")
            
            return
        }
        
        var changed = false
        
        if (startTime == nil || endTime == nil) {
            startTime = hours
            
            endTime = startTime! + 1
        } else {
            if (hours == startTime! - 1) {
                changed = true
                startTime = startTime! - 1
            }
            
            if (startTime! == endTime! - 1 && hours > endTime! && !changed) {
                changed = true
                endTime = hours + 1
            }
            
            if (hours == endTime! && !changed) {
                changed = true
                endTime = endTime! + 1
            }
            
            if (hours < startTime! - 1 && !changed) {
                changed = true
                startTime = hours
                
                endTime = startTime! + 1
            }
            
            if (hours > endTime! && !changed) {
                changed = true
                startTime = hours
                
                endTime = startTime! + 1
            }
        }
        
        let startOfCurrentDate = Calendar.current.startOfDay(for: date)
        
        let startDate = startOfCurrentDate.add(.init(seconds: 0, minutes: 0, hours: startTime!, days: 0, weeks: 0, months: 0, years: 0))
        let endDate = startOfCurrentDate.add(.init(seconds: 0, minutes: 0, hours: endTime!, days: 0, weeks: 0, months: 0, years: 0))
        
        chooseHoursDelegate?.didPickDatesForHourlyRentType(startDate, endDate)
        
        drawButtonsFilledOnChoosingHours()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension UIButton{
    func roundedTopButton() {
        let maskPath1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: [.topLeft , .topRight],
                                     cornerRadii:CGSize(width: 8, height: 8))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPath1.cgPath
        self.layer.mask = maskLayer1
    }
    
    func roundedBottomButton() {
        let maskPath1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: [.bottomLeft , .bottomRight],
                                     cornerRadii:CGSize(width: 8, height: 8))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPath1.cgPath
        self.layer.mask = maskLayer1
    }

    func roundedAllButton() {
        self.layer.cornerRadius = 8
    }
}
