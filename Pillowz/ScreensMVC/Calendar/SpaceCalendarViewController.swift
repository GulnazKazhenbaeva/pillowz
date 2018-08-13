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
import MBProgressHUD

class SpaceCalendarViewController: PillowzViewController, FSCalendarDelegate, FSCalendarDataSource, UIGestureRecognizerDelegate, AddBookingViewDelegate, DateAndTimePickerViewControllerDelegate {
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()

    var space: Space!
    
    //var itemInfo: IndicatorInfo = "Calendar"
    var selectedDateView = SelectedDateView(mode: .view)
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    
    let spaceCalendarDelegate = SpaceCalendarDelegate()
    fileprivate weak var calendar: FSCalendar!
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    var isOpenedByClient = false

    let createBookingButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendar.select(Date())
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.selectedDateView.scrollView.panGestureRecognizer.require(toFail: self.scopeGesture)
        
        self.title = space.name
        
        let titleViewButton = UIButton()
        titleViewButton.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        titleViewButton.addTarget(self, action: #selector(openSpace), for: .touchUpInside)
        var title = space.name
        if (title == "") {
            title = "Название отсутствует"
        }
        titleViewButton.setTitle(title, for: .normal)
        titleViewButton.setTitleColor(Constants.paletteBlackColor, for: .normal)
        
        self.navigationItem.titleView = titleViewButton
        
        if (!isOpenedByClient) {
            self.view.addSubview(createBookingButton)
            createBookingButton.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-Constants.basicOffset)
                make.right.equalToSuperview().offset(-Constants.basicOffset)
                make.width.height.equalTo(56)
            }
            createBookingButton.backgroundColor = UIColor(hexString: "#FF6B57")
            createBookingButton.setTitle("+", for: .normal)
            createBookingButton.titleLabel?.font = UIFont.init(name: "OpenSans-SemiBold", size: 36)
            createBookingButton.setTitleColor(.white, for: .normal)
            createBookingButton.layer.cornerRadius = 28
            createBookingButton.dropShadow()
            createBookingButton.addTarget(self, action: #selector(showAddBookingView), for: .touchUpInside)
        }
        
        spaceCalendarDelegate.calendar = self.calendar
        spaceCalendarDelegate.space = self.space
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //spaceCalendarDelegate.getBooking()
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
        calendar.swipeToChooseGesture.isEnabled = true // Swipe-To-Choose

        self.calendar = calendar
        
        self.view.addSubview(selectedDateView)
        selectedDateView.snp.makeConstraints { (make) in
            make.top.equalTo(calendar.snp.bottom)
            make.bottom.equalToSuperview().offset(0)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    @objc func openSpace() {
        let vc = SpaceViewController()
        vc.space = space
        self.navigationController?.pushViewController(vc, animated: true)
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
        
        self.calendar.setScope(.week, animated: true)
        
        self.spaceCalendarDelegate.configureVisibleCells()
        
        selectedDateView.date = date
        selectedDateView.bookings = self.spaceCalendarDelegate.bookings
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        self.spaceCalendarDelegate.configureVisibleCells()
    }
    
    @objc func showAddBookingView() {
        let view = RentTypePickerView()
        
        var availableRentTypes:[RENT_TYPES] = []
        for price in space!.prices! {
            if (price.price != nil && price.rent_type != .HOURLY) {
                availableRentTypes.append(price.rent_type!)
            }
        }
        
        view.rentTypes = availableRentTypes
        
        view.didPickRentTypeClosure = { (rentType) in
            let vc = DateAndTimePickerViewController()
            vc.spaceCalendarDelegate.bookings = self.spaceCalendarDelegate.bookings
            vc.space = self.space
            vc.rentType = rentType
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: false)
        }
        view.show()
    }
    
    func didPickStartDate(_ startDate: Date, endDate: Date?) {
        let bookingPriceAndCommentView = BookingPriceAndCommentView(initialPrice: self.space.offerPrice) { (price, comment) in
            let start_time = Int(startDate.timeIntervalSince1970)
            
            var endDate = endDate
            
            if (UserLastUsedValuesForFieldAutofillingHandler.shared.rentType == .HALFDAY) {
                endDate = startDate.add(.init(seconds: 0, minutes: 0, hours: 12, days: 0, weeks: 0, months: 0, years: 0))
            } else if (UserLastUsedValuesForFieldAutofillingHandler.shared.rentType == .MONTHLY) {
                endDate = startDate.add(.init(seconds: 0, minutes: 0, hours:0, days: 0, weeks: 0, months: 1, years: 0))
            }
            
            let end_time = Int(endDate!.timeIntervalSince1970)
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            SpaceAPIManager.createBooking(spaceId: self.space!.space_id.intValue, timestampStart: start_time, timestampEnd: end_time, rent_type: UserLastUsedValuesForFieldAutofillingHandler.shared.rentType.rawValue, price:price, completion: { (responseObject, error) in
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if (error == nil) {
                    //self.navigationController?.popViewController(animated: true)
                    let booking = responseObject as! Book
                    self.spaceCalendarDelegate.bookings.append(booking)
                    self.spaceCalendarDelegate.calendar.reloadData()
                }
            })
        }
        
        bookingPriceAndCommentView.show()
    }
    
    func didTapAddBookingForDate(_ date: Date) {
        
    }
    
    func didTapRemoveBooking(_ booking: Book) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        SpaceAPIManager.deleteBooking(bookId: booking.book_id) { (responseObject, error) in
            MBProgressHUD.hide(for: self.view, animated: true)

            if (error == nil) {
                DesignHelpers.makeToastWithText("Бронь удалена")
            }
        }
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

