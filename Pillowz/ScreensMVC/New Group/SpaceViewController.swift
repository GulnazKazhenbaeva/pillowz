//
//  SpaceViewController.swift
//  Pillowz
//
//  Created by Samat on 06.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class SpaceViewController: PillowzViewController, ReviewTableViewCellDelegate, UserTableViewCellDelegate {
    
    var space:Space!
    let createPersonalRequestButton = PillowzButton()
    let spaceTableView = UITableView()
    var isCollapsed: Bool = true
    
    var descriptionText = ""
    var additional_featuresText = ""
    var arrival_and_checkoutText = ""
    var cancellation_policyText = ""
    var depositText = ""

    var tableViewDataSource:[Any] = []

    var rulesFields:[Field]!
    
    var displayedComforts:[ComfortItem] = []
    var displayedRulesFields:[Field] = []

    var isOpenedFromRequest = false
    
    let topBackButton = UIButton()
    let topGradient = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Просмотр объекта"
        
        
        descriptionText = space.spaceDescription
        if (descriptionText=="") {
            descriptionText = "Описание отсутствует"
        }
        
        additional_featuresText = space.additional_features
        if (additional_featuresText=="") {
            additional_featuresText = "Описание отсутствует"
        }
        
        arrival_and_checkoutText = space.arrival_and_checkout
        if (arrival_and_checkoutText=="") {
            arrival_and_checkoutText = "Описание отсутствует"
        }
        
        cancellation_policyText = space.cancellation_policy
        if (cancellation_policyText=="") {
            cancellation_policyText = "Описание отсутствует"
        }

        depositText = space.deposit
        if (depositText=="") {
            depositText = "Описание отсутствует"
        }
        
        
        rulesFields = CategoriesHandler.getFieldsOfObject(object: space.rule!, shouldControlObject: false).0

        self.setupTableView()
        
        self.setupDataSource()
        
        if (!isOpenedFromRequest) {
            self.view.addSubview(createPersonalRequestButton)
            self.view.bringSubview(toFront: createPersonalRequestButton)
            PillowzButton.makeBasicButtonConstraints(button: createPersonalRequestButton, pinToTop: false)
            createPersonalRequestButton.addTarget(self, action: #selector(createPersonalRequest), for: .touchUpInside)
            createPersonalRequestButton.setTitle("Создать заявку", for: .normal)
        }
        
        self.view.addSubview(topGradient)
        topGradient.snp.makeConstraints({ (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(64)
        })
        topGradient.image = #imageLiteral(resourceName: "appbar_gradient")
        
        self.view.addSubview(topBackButton)
        topBackButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(44)
        }
        topBackButton.setImage(#imageLiteral(resourceName: "backWhite"), for: .normal)
        topBackButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        viewSpace()
    }
    
    @objc func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setupDataSource() {
        tableViewDataSource = []
        
        tableViewDataSource.append("photos")
        tableViewDataSource.append("title")
        if (space.spaceIcons.count > 0) {
            tableViewDataSource.append("icons")
        }
        tableViewDataSource.append("user")
        tableViewDataSource.append("description")
        
        if (space.additional_features != "") {
            tableViewDataSource.append("additional_features")
        }
        
        tableViewDataSource.append("map")
        
        if (space.arrival_and_checkout != "") {
            tableViewDataSource.append("arrival_and_checkout")
        }
        
        if (space.arrival_time != 0 || space.checkout_time != 0) {
            tableViewDataSource.append("arrival")
            tableViewDataSource.append("departure")
        }
        
        tableViewDataSource.append("calendar")
        tableViewDataSource.append("fields")
        
        for comfort in space.comforts! {
            if (comfort.checked == true) {
                tableViewDataSource.append(comfort)
                displayedComforts.append(comfort)
            }
        }
        
        for rulesField in rulesFields {
            if rulesField.type != "CharField" {
                tableViewDataSource.append(rulesField)
                displayedRulesFields.append(rulesField)
            }
        }
        
        tableViewDataSource.append("reviews")
        
        if (space.cancellation_policy != "") {
            tableViewDataSource.append("cancellation_policy")
        }
        
        if (space.deposit != "") {
            tableViewDataSource.append("deposit")
        }
        
        if space.shouldLetLeaveReviewAndComplain() {
            tableViewDataSource.append("complain")
            tableViewDataSource.append("review")
        }
        tableViewDataSource.append("user")
        tableViewDataSource.append("allSpaces")
    }
    
    func viewSpace() {
        SpaceAPIManager.viewSpace(space_id: self.space.space_id.intValue) { (responseObject, error) in
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spaceTableView.reloadData()
    }
    
    @objc func createPersonalRequest() {
        let vc = NewPersonalRequestViewController()
        vc.space = space
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    @objc func employmentCalendarValueLabelTapped(){
        let vc = SpaceCalendarViewController()
        vc.space = self.space
        vc.isOpenedByClient = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func chatTapped() {
//        if (request.status == .COMPLETED || offer?.status == .COMPLETED) {
//            let chatVC = ChatViewController()
//            chatVC.hidesBottomBarWhenPushed = true
//
//            if (offer == nil) {
//                chatVC.room = request!.chat_room!
//            } else {
//                chatVC.room = offer!.chat_room!
//            }
//
//            self.navigationController?.pushViewController(chatVC, animated: true)
//        } else {
//            let infoView = ModalInfoView(titleText: "Данная функция будет доступна после одобрения заявки", descriptionText: "")
//
//            infoView.addButtonWithTitle("OK", action: {
//
//            })
//
//            infoView.show()
//        }
    }
    
    func callTapped() {
//        if (request.status == .COMPLETED || offer?.status == .COMPLETED) {
//            var phone:String = ""
//
//            if let offer = offer {
//                phone = offer.otherUser.phone!
//            } else {
//                phone = request!.otherUser.phone!
//            }
//
//            if let phoneCallURL = URL(string: "tel://\(phone)") {
//                let application:UIApplication = UIApplication.shared
//                if (application.canOpenURL(phoneCallURL)) {
//                    application.open(phoneCallURL, options: [:], completionHandler: nil)
//                } else {
//
//                }
//            } else {
//                let infoView = ModalInfoView(titleText: "Не удается вызвать указанный номер:" + phone, descriptionText: "Свяжитесь с сервисом техподдержки если владелец недоступен, мы решим данную проблему")
//
//                infoView.addButtonWithTitle("OK", action: {
//
//                })
//
//                infoView.show()
//            }
//        } else {
//            let infoView = ModalInfoView(titleText: "Данная функция будет доступна после одобрения заявки", descriptionText: "")
//
//            infoView.addButtonWithTitle("OK", action: {
//
//            })
//
//            infoView.show()
//        }
    }
}

extension SpaceViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        self.view.addSubview(spaceTableView)
        spaceTableView.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        spaceTableView.delegate = self
        spaceTableView.dataSource = self
        spaceTableView.tableFooterView = UIView()
        spaceTableView.isUserInteractionEnabled = true
        
        spaceTableView.register(SpacePicturesTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(SpacePicturesTableViewCell.self))
        spaceTableView.register(SpaceFieldsIconsTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(SpaceFieldsIconsTableViewCell.self))
        spaceTableView.register(SpaceTitleTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(SpaceTitleTableViewCell.self))
        spaceTableView.register(SpacePricesTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(SpacePricesTableViewCell.self))
        spaceTableView.register(LongTextTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(LongTextTableViewCell.self))
        spaceTableView.register(MapTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(MapTableViewCell.self))
        spaceTableView.register(SpaceArrivalDepartureTimeTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(SpaceArrivalDepartureTimeTableViewCell.self))
        spaceTableView.register(SpaceEmploymentCalendarTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(SpaceEmploymentCalendarTableViewCell.self))
        spaceTableView.register(FieldsTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(FieldsTableViewCell.self))
        spaceTableView.register(ReviewTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(ReviewTableViewCell.self))
        spaceTableView.register(SpaceRentedUserTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(SpaceRentedUserTableViewCell.self))
        spaceTableView.register(SpaceRelatedHousingTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(SpaceRelatedHousingTableViewCell.self))
        spaceTableView.register(HeaderIncludedTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(HeaderIncludedTableViewCell.self))
        spaceTableView.register(UserTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(UserTableViewCell.self))
        spaceTableView.register(BooleanValuePickerTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(BooleanValuePickerTableViewCell.self))
        spaceTableView.separatorColor = UIColor(white: 0.0, alpha: 0.0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        let object = tableViewDataSource[indexPath.row]
        
        if (object is String) {
            let string = object as! String
            
            if (string == "photos") {
                let firstCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SpacePicturesTableViewCell.self)) as! SpacePicturesTableViewCell
                firstCell.pictureSliderView.shouldUseImageViewer = true
                firstCell.space = space
                cell = firstCell
            } else if (string == "title") {
                let secondCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SpaceTitleTableViewCell.self)) as! SpaceTitleTableViewCell
                secondCell.space = space
                cell = secondCell
            } else if (string == "icons") {
                let iconsCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SpaceFieldsIconsTableViewCell.self)) as! SpaceFieldsIconsTableViewCell
                
                iconsCell.spaceIcons = space.spaceIcons
                
                cell = iconsCell
            } else if (string == "price") {
                let thirdCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SpacePricesTableViewCell.self)) as! SpacePricesTableViewCell
                thirdCell.space = space
                cell = thirdCell
            } else if (string == "description" || string == "additional_features" || string == "arrival_and_checkout" || string == "cancellation_policy" || string == "deposit") {
                let fourthCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LongTextTableViewCell.self)) as! LongTextTableViewCell
                
                if string == "description" {
                    fourthCell.header = "Описание"
                    
                    fourthCell.initialValue = descriptionText
                } else if string == "additional_features" {
                    fourthCell.header = "Особенности жилья"
                    
                    fourthCell.initialValue = additional_featuresText
                } else if string == "arrival_and_checkout" {
                    fourthCell.header = "Условия прибытия и выезда"
                    
                    fourthCell.initialValue = arrival_and_checkoutText
                } else if string == "cancellation_policy" {
                    fourthCell.header = "Правила отмены бронирования"
                    
                    fourthCell.initialValue = cancellation_policyText
                } else if string == "deposit" {
                    fourthCell.header = "Страховой депозит"
                    
                    fourthCell.initialValue = depositText
                }
                
                fourthCell.textView.isUserInteractionEnabled = false
                cell = fourthCell
                cell.addSeparatorView()
            } else if (string == "map") {
                let mapCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MapTableViewCell.self)) as! MapTableViewCell
                
                mapCell.fillWithObject(object: ["lat":space.lat.doubleValue, "lon":space.lon.doubleValue, "VC":nil, "space":space] as AnyObject)
                mapCell.shouldShowDistance = true
                
                cell = mapCell
            } else if (string == "arrival") {
                let sixthCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SpaceArrivalDepartureTimeTableViewCell.self)) as! SpaceArrivalDepartureTimeTableViewCell
                sixthCell.type = .arrival
                sixthCell.space = space
                cell = sixthCell
                cell.addSeparatorView()
            } else if (string == "departure") {
                let seventhCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SpaceArrivalDepartureTimeTableViewCell.self)) as! SpaceArrivalDepartureTimeTableViewCell
                seventhCell.type = .departure
                seventhCell.space = space
                cell = seventhCell
                cell.addSeparatorView()
            } else if (string == "calendar") {
                let eighthCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SpaceEmploymentCalendarTableViewCell.self)) as! SpaceEmploymentCalendarTableViewCell
                let employmentCalendarValueLabelGesture = UITapGestureRecognizer(target: self, action: #selector(employmentCalendarValueLabelTapped))
                eighthCell.employmentCalendarValueLabel.addGestureRecognizer(employmentCalendarValueLabelGesture)
                
                cell = eighthCell
                cell.addSeparatorView()
            } else if (string == "fields") {
                let ninthCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(FieldsTableViewCell.self)) as! FieldsTableViewCell
                ninthCell.fields = Field.getNonEmptyFields(fields: space.fields!)
                ninthCell.header = "Характеристики объекта"
                
                cell = ninthCell
                cell.addSeparatorView()
            } else if (string == "complain") {
                let complainCell = UITableViewCell()
                
                complainCell.textLabel?.text = "Пожаловаться на объявление"
                complainCell.accessoryType = .disclosureIndicator
                
                cell = complainCell
                cell.addSeparatorView()
            } else if (string == "review") {
                let reviewCell = UITableViewCell()
                
                reviewCell.textLabel?.text = "Оставить отзыв"
                reviewCell.accessoryType = .disclosureIndicator

                cell = reviewCell
                cell.addSeparatorView()
            } else if (string == "reviews") {
                if (space.reviews?.count == 0) {
                    let headerCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(HeaderIncludedTableViewCell.self)) as! HeaderIncludedTableViewCell
                    
                    headerCell.header = "Отзывы отсутствуют"
                    
                    cell = headerCell
                } else {
                    let reviewCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ReviewTableViewCell.self)) as! ReviewTableViewCell
                    
                    reviewCell.space = space
                    reviewCell.review = space.reviews![0]
                    reviewCell.delegate = self
                    
                    cell = reviewCell
                }
            } else if (string == "user") {
                let userCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UserTableViewCell.self)) as! UserTableViewCell
                
                userCell.realtor = space.realtor!
                
                userCell.callButton.isHidden = true
                userCell.chatButton.isHidden = true
                
                cell = userCell
            } else if (string == "allSpaces") {
                
            }

        } else if (object is ComfortItem) {
            let comfort = object as! ComfortItem
            
            let boolCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(BooleanValuePickerTableViewCell.self)) as! BooleanValuePickerTableViewCell
            
            if (comfort === displayedComforts.first) {
                boolCell.header = "Удобства"
            } else {
                boolCell.header = ""
            }
            
            boolCell.removeSeparatorView()

            if (comfort === displayedComforts.last!) {
                boolCell.addSeparatorView()
            }
            
            boolCell.placeholder = comfort.name!
            
            boolCell.icon = comfort.logo_64x64
            
            boolCell.valuePickerSwitch.isHidden = true
            
            boolCell.nameLabel.snp.updateConstraints({ (make) in
                make.right.equalToSuperview().offset(-Constants.basicOffset)
            })
            
            cell = boolCell
        } else if (object is Field) {
            let field = object as! Field
            
            let boolCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(BooleanValuePickerTableViewCell.self)) as! BooleanValuePickerTableViewCell

            if (field === displayedRulesFields.first) {
                boolCell.header = "Правила владельца"
            } else {
                boolCell.header = ""
            }

            boolCell.removeSeparatorView()
            
            if (field === displayedRulesFields.last!) {
                boolCell.addSeparatorView()
            }
            
            boolCell.placeholder = field.name!
            
            boolCell.icon = field.icon
            boolCell.notAllowed = field.notAllowed
            
            boolCell.valuePickerSwitch.isHidden = true
            
            boolCell.nameLabel.snp.updateConstraints({ (make) in
                make.right.equalToSuperview().offset(-Constants.basicOffset)
            })

            cell = boolCell
        }

        if (cell == nil) {
            cell = UITableViewCell()
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let object = tableViewDataSource[indexPath.row]
        
        if (object is String) {
            let string = object as! String
            
            if (string == "photos") {
                return Constants.spaceImageHeight
            } else if (string == "title") {
                return 110
            } else if (string == "icons") {
                return 85
            } else if (string == "price") {
                let nonNilPrices:[Price] = space.getNonNilPrices()
                
                let numberOfRowsInPrices = (nonNilPrices.count+1)/2
                
                return CGFloat(numberOfRowsInPrices*62 + 24)
            } else if (string == "description" || string == "additional_features" || string == "arrival_and_checkout" || string == "cancellation_policy" || string == "deposit") {
                let font = UIFont.init(name: "OpenSans-Regular", size: 16)!
                
                if string == "description" {
                    var totalHeight:CGFloat = 75
                    
                    totalHeight = totalHeight + descriptionText.height(withConstrainedWidth: (Constants.screenFrame.size.width-2*Constants.basicOffset), font: font)
                    
                    return totalHeight
                } else if string == "additional_features" {
                    var totalHeight:CGFloat = 75
                    
                    totalHeight = totalHeight + additional_featuresText.height(withConstrainedWidth: (Constants.screenFrame.size.width-2*Constants.basicOffset), font: font)
                    
                    return totalHeight
                } else if string == "arrival_and_checkout" {
                    var totalHeight:CGFloat = 75
                    
                    totalHeight = totalHeight + arrival_and_checkoutText.height(withConstrainedWidth: (Constants.screenFrame.size.width-2*Constants.basicOffset), font: font)
                    
                    return totalHeight
                } else if string == "cancellation_policy" {
                    var totalHeight:CGFloat = 75
                    
                    totalHeight = totalHeight + cancellation_policyText.height(withConstrainedWidth: (Constants.screenFrame.size.width-2*Constants.basicOffset), font: font)
                    
                    return totalHeight
                } else if string == "deposit" {
                    var totalHeight:CGFloat = 75
                    
                    totalHeight = totalHeight + depositText.height(withConstrainedWidth: (Constants.screenFrame.size.width-2*Constants.basicOffset), font: font)
                    
                    return totalHeight
                }
            } else if (string == "map") {
                return 265
            } else if (string == "arrival") {
                return 60
            } else if (string == "departure") {
                return 60
            } else if (string == "calendar") {
                return 60
            } else if (string == "fields") {
                let numberOfRows = (Field.getNonEmptyFields(fields: space.fields!).count + 1)/2
                
                return CGFloat(15 + 62*numberOfRows + 40)
            } else if (string == "complain" || string == "review") {
                return 40
            } else if (string == "reviews") {
                if (space.reviews?.count == 0) {
                    return 60
                } else {
                    let text = space.reviews![0].text!
                    
                    return 178+text.height(withConstrainedWidth: Constants.screenFrame.size.width-2*Constants.basicOffset, font: UIFont.init(name: "OpenSans-Light", size: 14)!)
                }
            } else if (string == "user") {
//                return UITableViewAutomaticDimension
                return 126
            } else if (string == "allSpaces") {
                
            }
            
            return 200
        } else if (object is ComfortItem) {
            let comfort = object as! ComfortItem
            
            let width = Constants.screenFrame.size.width - 2*Constants.basicOffset - 36 - 16
            
            let nameHeight = comfort.name!.height(withConstrainedWidth: width, font: UIFont.init(name: "OpenSans-Light", size: 16)!)
            
            if (comfort === displayedComforts.first) {
                return nameHeight + 59 + 28
            }
            
            return nameHeight + 10 + 28
        } else if (object is Field) {
            let field = object as! Field
            
            let width = Constants.screenFrame.size.width - 2*Constants.basicOffset - 36 - 16

            let nameHeight = field.name!.height(withConstrainedWidth: width, font: UIFont.init(name: "OpenSans-Light", size: 16)!)

            if (field === displayedRulesFields.first) {
                return nameHeight + 59 + 28
            }
            
            return nameHeight + 10 + 28
        }
        
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = tableViewDataSource[indexPath.row]
        
        if (object is String) {
            let string = object as! String
            
            if (string == "user") {
                let profileVC = UserProfileViewController()
                profileVC.user_id = space.realtor!.user_id!
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
            
            if (string == "complain") {
                let vc = CreateFeedbackViewController()
                
                vc.space_id = space.space_id.intValue
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            if (string == "review") {
                let userReviewVC = CreateReviewViewController()
                userReviewVC.isUser = true
                userReviewVC.space_id = space.space_id.intValue
                userReviewVC.superVC = self
                self.navigationController?.pushViewController(userReviewVC, animated: true)
            }
        }
    }
    
    func showAllReviewsTapped() {
        let vc = ReviewsViewController()
        vc.reviews = space.reviews!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openUserWithId(_ userId: Int) {
        let profileVC = UserProfileViewController()
        profileVC.user_id = userId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}
