
//
//  CalendarOfPlansViewController.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 13.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

class CalendarOfPlansViewController: PillowzViewController, BookingTableViewCellDelegate, BookingModalViewDelegate {
    var collectionView: UICollectionView! = nil
    let topView = UIView()
    
    let tableViewTitle: UILabel = {
        let label = UILabel()
        label.textColor = Constants.paletteBlackColor
        label.font = UIFont(name: "OpenSans-Bold", size: 15)
        label.text = "Ближайшие брони"
        return label
    }()
    
    let tableView = UITableView()
    
    let dateFormatter = DateFormatter()
    
    var spaces:[Space] = []
    
    var bookings:[Book] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    let loadingActivityView = UIActivityIndicatorView()
    
    var noInfoView:NoInfoTapPlusView!
    
    override func loadView() {
        super.loadView()
        setupViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Календарь планов"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
    }
    
    @objc func loadData() {
        getSpaces()
        getBookings()
    }
    
    func openSpace(_ space: Space) {
        let vc = SpaceCalendarViewController()
        vc.space = space
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openUserWithId(_ userId: Int) {
        let profileVC = UserProfileViewController()
        profileVC.user_id = userId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func getSpaces() {
        SpaceAPIManager.getSpaces { (object, error) in
            self.loadingActivityView.stopAnimating()
            
            self.tableView.refreshControl?.endRefreshing()
            
            if (error == nil) {
                self.spaces = []
                
                let allSpacesList = object as! [Space]
                
                for space in allSpacesList {
                    if space.status == .VISUAL || space.status == .ARCHIVED {
                        self.spaces.append(space)
                    }
                }
                
                self.tableViewTitle.isHidden = false
                
                if (self.spaces.count == 0) {
                    self.noInfoView = NoInfoTapPlusView(showPlus: false)
                    
                    self.noInfoView?.isHidden = false
                    
                    self.noInfoView.noInfoText = "Календарь планов появится когда у Вас появятся объекты недвижимости. Создайте объекты недвижимости."
                    self.view.addSubview(self.noInfoView)
                    self.noInfoView.snp.makeConstraints({ (make) in
                        make.edges.equalToSuperview()
                    })
                    self.noInfoView.actionClosure = { () in
                        MainTabBarController.shared.selectedIndex = 0
                    }
                    
                    self.noInfoView.actionButton.setTitle("Создать объект недвижимости", for: .normal)
                    self.noInfoView?.isHidden = false
                    
                    self.tableViewTitle.isHidden = true
                } else {
                    self.noInfoView?.isHidden = true
                }

                self.collectionView.reloadData()

                self.tableView.reloadData()
            } else {
                if let error = error as NSError? {
                    if error.code == 100 {
                        self.spaces = []
                        self.bookings = []
                        
                        self.tableView.reloadData()
                        self.collectionView.reloadData()
                        
                        self.tableViewTitle.isHidden = true
                        
                        self.noInfoView = NoInfoTapPlusView(showPlus: false)
                        self.noInfoView.noInfoText = "Для просмотра календаря планов войдите в аккаунт"
                        self.view.addSubview(self.noInfoView)
                        self.noInfoView.snp.makeConstraints({ (make) in
                            make.edges.equalToSuperview()
                        })
                        self.noInfoView.actionClosure = { () in
                            MainTabBarController.shared.navigationController?.pushViewController(GuestRoleViewController(), animated: true)                            
                        }
                        self.noInfoView?.isHidden = false
                        
                        self.tableViewTitle.isHidden = true
                    }
                }
            }
        }
    }
    
    func getBookings() {
        guard let user_id = User.shared.user_id else {
            return
        }
        
        let nowDate = Date()
        let monthAfterDate = nowDate.add(.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 1, years: 0))
        
        SpaceAPIManager.getBookingForUser(user_id, timestamp_start: Int(nowDate.timeIntervalSince1970), timestamp_end: Int(monthAfterDate.timeIntervalSince1970)) { (responseObject, error) in
            self.loadingActivityView.stopAnimating()
            
            self.tableView.refreshControl?.endRefreshing()
            
            if (error == nil) {
                self.bookings = responseObject as! [Book]
            }
        }
    }
    
    func deleteBookingTapped(_ book: Book) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        SpaceAPIManager.deleteBooking(bookId: book.book_id) { (responseObject, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if (error == nil) {
                DesignHelpers.makeToastWithText("Бронь удалена")
                
                let index = self.bookings.index(of: book)!
                
                self.bookings.remove(at: index)
                
                self.tableView.reloadData()
            }
        }
    }
}

extension CalendarOfPlansViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spaces.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as! CalendarCollectionViewCell
        
        cell.space = spaces[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 76*16/9, height: 76 + 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = SpaceCalendarViewController()
        vc.space = spaces[indexPath.item]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CalendarOfPlansViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookings.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(BookingTableViewCell.self), for: indexPath) as! BookingTableViewCell
        
        //for some reason buttons are not getting tapped
        //cell.contentView.isUserInteractionEnabled = false

        cell.delegate = self
        cell.book = bookings[indexPath.row]        

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = bookings[indexPath.row]
        //let vc = BookingRequestViewController()
        
        let view = BookingModalView()
        
        view.delegate = self
        view.book = book
       
        view.show()
    }
    
    func showSpacesList(_ show:Bool) {
        self.view.layoutIfNeeded()
        
        if (show) {
            topView.snp.updateConstraints { (make) in
                make.height.equalTo(130)
            }
        } else {
            topView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
        }
        
        UIView.animate(withDuration: 0.25) {
            
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollPos = scrollView.contentOffset.y
        
        if(scrollPos >= 40 /* or CGRectGetHeight(yourToolbar.frame) */){
            // Fully hide your toolbar
            showSpacesList(false)
        } else {
            // Slide it up incrementally, etc.
            showSpacesList(true)
        }
    }
}

extension CalendarOfPlansViewController {
    func setupViews() {
        topView.backgroundColor = .white
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(130)
        }
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = Constants.basicOffset
        flowLayout.minimumLineSpacing = Constants.basicOffset
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: flowLayout)
        collectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: "CalendarCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        topView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.bottom.equalToSuperview()
        }
        
        let bottomView = UIView()
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        bottomView.addSubview(tableViewTitle)
        tableViewTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(Constants.basicOffset)
        }
        
        bottomView.addSubview(tableView)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BookingTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(BookingTableViewCell.self))
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(tableViewTitle.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
        }
        
        self.view.addSubview(loadingActivityView)
        loadingActivityView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(100)
        }
        loadingActivityView.hidesWhenStopped = true
        loadingActivityView.activityIndicatorViewStyle = .gray
        loadingActivityView.startAnimating()
    }
}

