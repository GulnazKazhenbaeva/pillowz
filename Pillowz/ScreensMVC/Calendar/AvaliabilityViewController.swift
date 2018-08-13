//
//  AvaliabilityViewController.swift
//  Pillowz
//
//  Created by Samat on 04.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import FSCalendar
import XLPagerTabStrip
import DateToolsSwift

class BookingViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, IndicatorInfoProvider, UIGestureRecognizerDelegate {
    var space: Space!
    
    var itemInfo: IndicatorInfo = "Calendar"
    var selectedDateView = SelectedDateView()
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    
    var bookings:[Book] = [] {
        didSet {
            calendar.reloadData()
        }
    }
    
    fileprivate weak var calendar: FSCalendar!
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendar.select(Date())
    }
    
    func getBooking() {
        guard let interval = Calendar.current.dateInterval(of: .month, for: Date()) else { return }
       
        SpaceAPIManager.getBookingForSpace(self.space.space_id.intValue, timestamp_start: Int(interval.start.timeIntervalSince1970), timestamp_end: Int(interval.end.timeIntervalSince1970)) { (responseObject) in
            
        }
    }
    
    override func loadView() {
        super.loadView()
        
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
        view.addSubview(calendar)
        calendar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(64)
            make.height.equalTo(300)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        calendar.appearance.selectionColor = DesignHelpers.currentMainColor()
        calendar.appearance.todayColor = UIColor.red
        calendar.appearance.titleDefaultColor = UIColor.lightGray
        calendar.appearance.titleSelectionColor = .white
        calendar.appearance.headerTitleColor = DesignHelpers.currentMainColor()
        calendar.appearance.weekdayTextColor = DesignHelpers.currentMainColor()
        calendar.allowsMultipleSelection = true
        calendar.dataSource = self
        calendar.delegate = self
        calendar.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.clipsToBounds = true // Remove top/bottom line

        self.calendar = calendar
        
        self.view.addGestureRecognizer(self.scopeGesture)
        //self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendar.scope = .month
        
        self.view.addSubview(selectedDateView)
        selectedDateView.snp.makeConstraints { (make) in
            make.top.equalTo(calendar.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints { (make) in
            make.height.equalTo(bounds.height)
            // Do other updates
        }
        self.view.layoutIfNeeded()
    }
    
    private func configureVisibleCells() {
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        
        let diyCell = (cell as! DIYCalendarCell)
        // Custom today circle
        diyCell.circleImageView.isHidden = !self.gregorian.isDateInToday(date)
        // Configure selection layer
        if position == .current {
            var selectionType = SelectionType.none
            
            if calendar.selectedDates.contains(date) {
                let previousDate = self.gregorian.date(byAdding: .day, value: -1, to: date)!
                let nextDate = self.gregorian.date(byAdding: .day, value: 1, to: date)!
                if calendar.selectedDates.contains(date) {
                    if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(nextDate) {
                        selectionType = .middle
                    }
                    else if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(date) {
                        selectionType = .rightBorder
                    }
                    else if calendar.selectedDates.contains(nextDate) {
                        selectionType = .leftBorder
                    }
                    else {
                        selectionType = .single
                    }
                }
            }
            else {
                selectionType = .none
            }
            if selectionType == .none {
                diyCell.selectionLayer.isHidden = true
                return
            }
            diyCell.selectionLayer.isHidden = false
            diyCell.selectionType = selectionType
            
        } else {
            diyCell.circleImageView.isHidden = true
            diyCell.selectionLayer.isHidden = true
        }
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: position)
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //print("did select date \(self.formatter.string(from: date))")
        self.configureVisibleCells()
        
        
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        //print("did deselect date \(self.formatter.string(from: date))")
        self.configureVisibleCells()
    }
    
    func showAddBookingView() {
        
    }
    
    
    
    
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func doSomething(){
        print("Tapped")
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

