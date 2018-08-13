//
//  SpaceCalendarDelegate.swift
//  Pillowz
//
//  Created by Samat on 24.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import FSCalendar
import DateToolsSwift
import MBProgressHUD

class SpaceCalendarDelegate: NSObject, FSCalendarDataSource {
    var space: Space! {
        didSet {
            if bookings.count == 0 {
                getBooking()
            }
        }
    }
    
    var calendar: FSCalendar! {
        didSet  {
            calendar.appearance.selectionColor = Constants.paletteVioletColor
            calendar.appearance.titleTodayColor = .black
            calendar.appearance.titleDefaultColor = UIColor.lightGray
            calendar.appearance.titleSelectionColor = Constants.paletteVioletColor
            calendar.appearance.headerTitleColor = Constants.paletteVioletColor
            calendar.appearance.weekdayTextColor = Constants.paletteVioletColor
            calendar.appearance.eventDefaultColor = Constants.paletteVioletColor
            calendar.appearance.eventSelectionColor = Constants.paletteVioletColor
            calendar.allowsMultipleSelection = false
            self.calendar.scope = .month
            calendar.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
            calendar.clipsToBounds = true // Remove top/bottom line
            calendar.appearance.titleFont = UIFont(name: "OpenSans-Regular", size: 16)
            
            calendar.dataSource = self
        }
    }
    
    var bookings:[Book] = [] {
        didSet {
            if let calendar = calendar {
                calendar.reloadData()
            }
        }
    }
    
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    
    var dateAndTimePickingMode = false
    var startDate:Date? {
        didSet {
            endDate = nil
            //self.configureVisibleCells()
        }
    }
    var endDate:Date? {
        didSet {
            //self.configureVisibleCells()
        }
    }
    var rentType:RENT_TYPES!

    var isLoading = false
    
    func getBooking() {
        let nowDate = Date()
        
        var startDate:Date
        
        let monthBeforeDate = nowDate.subtract(.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 1, years: 0))
        let twoMonthAfterDate = nowDate.add(.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 1, years: 0))
        
        if (User.currentRole == .client) {
            startDate = nowDate
        } else {
            startDate = monthBeforeDate
        }
        
        if (space == nil) {
            return
        }
        
        if (isLoading) {
            return
        }
        
        isLoading = true
        
        let window = UIApplication.shared.delegate!.window!!
        
        MBProgressHUD.showAdded(to: window, animated: true)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        SpaceAPIManager.getBookingForSpace(self.space.space_id.intValue, timestamp_start: Int(startDate.timeIntervalSince1970), timestamp_end: Int(twoMonthAfterDate.timeIntervalSince1970)) { (responseObject, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.isLoading = false

            MBProgressHUD.hide(for: window, animated: true)

            if (error == nil) {
                self.bookings = responseObject as! [Book]
            }
        }
    }
    
    func configureVisibleCells() {
        guard let calendar = calendar else {
            return
        }
        
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let diyCell = (cell as! DIYCalendarCell)
        diyCell.circleImageView.isHidden = true
        diyCell.circleHourlyView.isHidden = true
        
        var selectionType = determineSelectionTypeForDate(date)
        
        let periodPickingSelectionType = determineSelectionTypeIfDateInSelectionPeriod(date)
        
        let cellIsInSelectingPeriod = (dateAndTimePickingMode && periodPickingSelectionType != .none)

        if (dateAndTimePickingMode) {
            if (periodPickingSelectionType != .none) {
                selectionType = periodPickingSelectionType
            }
        }
        
        if position == .current {
            diyCell.titleLabel.textColor = Constants.paletteBlackColor
        } else {
            diyCell.titleLabel.textColor = UIColor(hexString: "#E0E0E0")
        }
        
        if selectionType != .none {
            if selectionType == .single && periodPickingSelectionType == .none {
                diyCell.circleHourlyView.isHidden = false
                
                selectionType = .none
            } else {
                diyCell.titleLabel.textColor = .white
                diyCell.circleImageView.isHidden = true
            }
        }
        
        diyCell.selectionType = selectionType
        
        let isToday = self.gregorian.isDateInToday(date)
        
        if (isToday) {
            diyCell.titleLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        } else {
            diyCell.titleLabel.font = UIFont(name: "OpenSans-Regular", size: 13)
        }
        
        if (diyCell.isSelected && !cellIsInSelectingPeriod) {
            if (selectionType == .none) {
                diyCell.titleLabel.textColor = UIColor(hexString: "#FA3C3C")
            } else {
                diyCell.titleLabel.textColor = .white
                diyCell.selectionLayer.fillColor = UIColor(hexString: "#FA3C3C").cgColor
            }
        }
        
        if (cellIsInSelectingPeriod && dateAndTimePickingMode || !dateAndTimePickingMode) {
            diyCell.selectionLayer.fillColor = Constants.paletteVioletColor.cgColor
            diyCell.circleHourlyView.layer.borderColor = Constants.paletteVioletColor.cgColor
        } else {
            diyCell.selectionLayer.fillColor = UIColor(hexString: "#E0E0E0").cgColor
            diyCell.circleHourlyView.layer.borderColor = UIColor(hexString: "#E0E0E0").cgColor
        }
        
        diyCell.setNeedsLayout()
        diyCell.layoutIfNeeded()

        
        //diyCell.backgroundColor = .red
        
        //print("date - \(date.description), color - \(diyCell.selectionLayer.fillColor.debugDescription), selection type - \(diyCell.selectionType), is hidden - \(diyCell.selectionLayer.isHidden)")
    }
    
    func determineSelectionTypeForDate(_ date:Date) -> SelectionType {
        var selectionType = SelectionType.none
        
        if (self.dateBookings(date).count > 0) {
            let previousDate = self.gregorian.date(byAdding: .day, value: -1, to: date)!
            let nextDate = self.gregorian.date(byAdding: .day, value: 1, to: date)!
            
            if (haveOverlappingBooking(firstDate: date, secondDate: previousDate) && haveOverlappingBooking(firstDate: date, secondDate: nextDate)) {
                selectionType = .middle
            } else if (haveOverlappingBooking(firstDate: date, secondDate: previousDate)) {
                selectionType = .rightBorder
            } else if (haveOverlappingBooking(firstDate: date, secondDate: nextDate)) {
                selectionType = .leftBorder
            } else {
                selectionType = .single
            }
        } else {
            selectionType = .none
        }
        
        return selectionType
    }
    
    func determineSelectionTypeIfDateInSelectionPeriod(_ date:Date) -> SelectionType {
        var selectionType = SelectionType.none

        if (startDate != nil) {
            let beginningOfDate = Calendar.current.startOfDay(for: date)
            
            let beginningOfStartDate = Calendar.current.startOfDay(for: startDate!)
            
            var beginningOfEndDate:Date?
            if (endDate != nil) {
                beginningOfEndDate = Calendar.current.startOfDay(for: endDate!)
            }
            
            if (rentType == .DAILY) {
                if (beginningOfDate == beginningOfStartDate && endDate == nil) {
                    selectionType = .single
                } else if (beginningOfDate == beginningOfStartDate && endDate != nil) {
                    if (beginningOfStartDate == beginningOfEndDate) {
                        selectionType = .single
                    } else {
                        selectionType = .leftBorder
                    }
                } else if (beginningOfDate == beginningOfEndDate) {
                    selectionType = .rightBorder
                } else if (beginningOfEndDate != nil) {
                    if (beginningOfDate.isBetweeen(date: beginningOfStartDate, andDate: beginningOfEndDate!)) {
                        selectionType = .middle
                    }
                }
            } else {
                if (beginningOfDate == beginningOfStartDate) {
                    selectionType = .single
                }
            }
        } else {
            selectionType = .none
        }

        return selectionType
    }
    
    func dateBookings(_ date:Date) -> [Book] {
        var overlappingBookings:[Book] = []
        
        for book in bookings {
            let bookingStartDate = Date(timeIntervalSince1970: TimeInterval(book.timestamp_start))
            let bookingEndDate = Date(timeIntervalSince1970: TimeInterval(book.timestamp_end))
            
            let startOfDate = self.gregorian.date(bySetting: .hour, value: 8, of: date)!
            let endOfDate = self.gregorian.date(byAdding: .hour, value: 24, to: startOfDate)!
            
            let bookingPeriod = TimePeriod(beginning: bookingStartDate, end: bookingEndDate)
            let dayPeriod = TimePeriod(beginning: startOfDate, end: endOfDate)
            
            if (dayPeriod.overlaps(with: bookingPeriod)) {
                overlappingBookings.append(book)
            }
        }
        
        return overlappingBookings
    }
    
    func haveOverlappingBooking(firstDate:Date, secondDate:Date) -> Bool {
        let firstDateBookings = dateBookings(firstDate)
        let secondDateBookings = dateBookings(secondDate)
        
        for firstDayBook in firstDateBookings {
            for secondDateBook in secondDateBookings {
                if (firstDayBook === secondDateBook) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
}
