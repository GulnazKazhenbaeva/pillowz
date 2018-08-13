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

class SpaceCalendarViewController: PillowzViewController, FSCalendarDelegate, FSCalendarDataSource, IndicatorInfoProvider, UIGestureRecognizerDelegate, AddBookingViewDelegate {
    var space: Space!
    
    var itemInfo: IndicatorInfo = "Calendar"
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendar.select(Date())
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.selectedDateView.scrollView.panGestureRecognizer.require(toFail: self.scopeGesture)
        
        //self.selectedDateView.scrollView.setContentOffset(CGPoint(x: 20, y: 100), animated: true)
        
        self.title = space.name
        
        if (!isOpenedByClient) {
            let rightButton: UIButton = UIButton(type: .custom)
            rightButton.setImage(#imageLiteral(resourceName: "plus"), for: .normal)
            rightButton.addTarget(self, action: #selector(showAddBookingView), for: .touchUpInside)
            rightButton.frame = CGRect(x:0, y:0, width:35, height:44)
            let rightBarButton = UIBarButtonItem(customView: rightButton)
            self.navigationItem.rightBarButtonItem = rightBarButton
        }
        
        spaceCalendarDelegate.space = self.space
        spaceCalendarDelegate.calendar = self.calendar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        spaceCalendarDelegate.getBooking()
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
        calendar.delegate = self
        calendar.swipeToChooseGesture.isEnabled = true // Swipe-To-Choose

        self.calendar = calendar
        
        self.view.addSubview(selectedDateView)
        selectedDateView.snp.makeConstraints { (make) in
            make.top.equalTo(calendar.snp.bottom)
            make.bottom.equalToSuperview().offset(-49)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
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
        //print("did select date \(self.formatter.string(from: date))")
        self.calendar.scope = .week

        self.spaceCalendarDelegate.configureVisibleCells()
        
        selectedDateView.date = date
        selectedDateView.bookings = self.spaceCalendarDelegate.bookings
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        //print("did deselect date \(self.formatter.string(from: date))")
        self.spaceCalendarDelegate.configureVisibleCells()
    }
    
    @objc func showAddBookingView() {
        let vc = PeriodPickerViewController()
        vc.mode = .booking
        vc.space = space
        self.navigationController?.pushViewController(vc, animated: true)
//        let addBookingView = AddOrRemoveBookingView(date: calendar.selectedDate!, delegate: self, book: nil)
//        self.view.addSubview(addBookingView)
//        addBookingView.snp.makeConstraints { (make) in
//            make.top.left.bottom.right.equalToSuperview()
//        }
    }
    
    func didTapAddBookingForDate(_ date: Date) {
    }
    
    func didTapRemoveBooking(_ booking: Book) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        SpaceAPIManager.deleteBooking(bookId: booking.book_id) { (responseObject, error) in
            MBProgressHUD.hide(for: self.view, animated: true)

            if (error == nil) {
                
            }
        }
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

