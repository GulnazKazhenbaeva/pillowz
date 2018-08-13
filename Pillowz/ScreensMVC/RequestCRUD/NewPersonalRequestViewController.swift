
//
//  NewPersonalRequestViewController.swift
//  Pillowz
//
//  Created by Samat on 13.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

class NewPersonalRequestViewController: PillowzViewController, SaveActionDelegate, DateAndTimePickerViewControllerDelegate, RequestOrOfferBottomViewDelegate {
    
    let bottomView = RequestOrOfferBottomView()
    
    var space:Space!

    var price:Int? {
        didSet {
            bottomView.priceLabel.text = price!.description + "₸"
            
            newPricePickerView.callPickValueClosure = false
            newPricePickerView.value = price!
            newPricePickerView.callPickValueClosure = true
        }
    }
    var rent_type:RENT_TYPES? {
        didSet {
            self.rentTypeButton.setTitle(Price.getDisplayNameForRentType(rent_type: rent_type!, isForPrice: false)["ru"]!, for: .normal)
            self.fromDate = nil
            self.tillDate = nil
            
            self.datesButton.setTitle("Выберите даты", for: .normal)
            self.datesButton.setTitleColor(.black, for: .normal)
        }
    }
    var start_time:Int?
    var end_time:Int?
    var bargain:Bool!
    
    let dateFormatter = DateFormatter()
    var fromDate:Date? {
        didSet {
            if (fromDate != nil) {
                start_time = Int(fromDate!.timeIntervalSince1970)
                
                if (rent_type == .HALFDAY) {
                    tillDate = fromDate?.add(.init(seconds: 0, minutes: 0, hours: 12, days: 0, weeks: 0, months: 0, years: 0))
                } else if (rent_type == .MONTHLY) {
                    tillDate = fromDate?.add(.init(seconds: 0, minutes: 0, hours:0, days: 0, weeks: 0, months: 1, years: 0))
                }
            }
        }
    }
    var tillDate:Date? {
        didSet {
            if (tillDate != nil) {
                end_time = Int(tillDate!.timeIntervalSince1970)

                price = space.calculateTotalPriceFor(rent_type!, startTimestamp: start_time!, endTimestamp: end_time!)
            } else {
                price = 0
            }
            
            if let start_time = start_time, let end_time = end_time {
                let title = Request.getStringForRentType(UserLastUsedValuesForFieldAutofillingHandler.shared.rentType, startTime: start_time, endTime: end_time, shouldGoToNextLine: false, includeRentTypeText: false)
                
                datesButton.setTitle(title, for: .normal)
                datesButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
            }
            
            self.bottomView.periodLabel.text = Request.getPeriodString(start_time: self.start_time, end_time: self.end_time, rent_type: self.rent_type)
        }
    }

    let scrollView = UIScrollView()
    let contentView = UIView()

    let rentTypeButton = UIButton()
    let datesButton = UIButton()
    let guestsButton = UIButton()
    
    let periodAndGuestsHeaderLabel = UILabel()
    let priceHeaderLabel = UILabel()

    let bargainLabel = UILabel()
    let bargainPickerSwitch = UISwitch()
    
    let newPricePickerView = IntValuePickerView(initialValue: 500, step: 500, additionalText: "₸")
    let newPriceLabel = UILabel()
    
    var guests_count:[String:Int] = ["adult_guest":2, "child_guest":0, "baby_guest":0] {
        didSet {
            if (guests_count["adult_guest"] != 0 || guests_count["child_guest"] != 0 || guests_count["baby_guest"] != 0) {
                var fullText = ""
                
                if (guests_count["adult_guest"] != 0) {
                    fullText.append(String(guests_count["adult_guest"]!)+" взрослых, ")
                }
                
                if (guests_count["child_guest"] != 0) {
                    fullText.append(String(guests_count["child_guest"]!)+" детей, ")
                }
                
                fullText = String(fullText.dropLast(2))
                
                self.guestsButton.setTitle(fullText, for: .normal)
            }
        }
    }
    
    var shouldUpdatePrice = false
    
    var rentTypeTextLabel = UILabel()
    var datesTextLabel = UILabel()
    var guestsTextLabel = UILabel()
    
    let bargainCopyrightLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Персональная заявка"
        
        
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
            make.width.equalTo(Constants.screenFrame.size.width)
            make.height.equalTo(700)
        }
        
        contentView.addSubview(periodAndGuestsHeaderLabel)
        periodAndGuestsHeaderLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-Constants.basicOffset*2)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(27)
        }
        periodAndGuestsHeaderLabel.textColor = Constants.paletteBlackColor
        periodAndGuestsHeaderLabel.font = UIFont.init(name: "OpenSans-Bold", size: 15)!
        periodAndGuestsHeaderLabel.text = "Период и гости"
        
        contentView.addSubview(rentTypeButton)
        rentTypeButton.setTitle("", for: .normal)
        self.applyBasicButtonDesign(rentTypeButton)
        rentTypeButton.snp.makeConstraints { (make) in
            make.top.equalTo(periodAndGuestsHeaderLabel.snp.bottom).offset(13)
            make.height.equalTo(40)
            make.width.equalTo(200)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        rentTypeButton.addTarget(self, action: #selector(rentTypeButtonTapped), for: .touchUpInside)
        
        if (space != nil) {
            for price in space!.prices! {
                if (price.price != nil && price.rent_type == UserLastUsedValuesForFieldAutofillingHandler.shared.rentType) {
                    rent_type = price.rent_type!
                    break
                }
            }
            
            if rent_type == nil {
                for price in space!.prices! {
                    if (price.price != nil) {
                        rent_type = price.rent_type!
                        break
                    }
                }
            }
        }
        
        contentView.addSubview(rentTypeTextLabel)
        rentTypeTextLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-90)
            make.centerY.equalTo(rentTypeButton.snp.centerY)
            make.height.equalTo(26)
        }
        rentTypeTextLabel.clipsToBounds = false
        rentTypeTextLabel.font = UIFont.init(name: "OpenSans-Regular", size: 11)!
        rentTypeTextLabel.textColor = Constants.paletteBlackColor
        rentTypeTextLabel.text = "Тип периода"
        
        
        
        contentView.addSubview(datesButton)
        self.applyBasicButtonDesign(datesButton)
        if let startTime = Filter.shared.startTime, let endTime = Filter.shared.endTime, rent_type == UserLastUsedValuesForFieldAutofillingHandler.shared.rentType {
            fromDate = Date(timeIntervalSince1970: TimeInterval(startTime))
            tillDate = Date(timeIntervalSince1970: TimeInterval(endTime))
        } else {
            var newStartDate = Date().add(.init(seconds: 0, minutes: 0, hours: 2, days: 0, weeks: 0, months: 0, years: 0))
            
            if (rent_type == .MONTHLY) {
                newStartDate = Date().add(.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 1, months: 0, years: 0))
            }
            
            let roundedStartDate = Calendar.current.date(bySetting: .minute, value: 0, of: newStartDate)
            
            fromDate = roundedStartDate
            
            if (rent_type == .HALFDAY) {
                tillDate = fromDate!.add(.init(seconds: 0, minutes: 0, hours: 12, days: 0, weeks: 0, months: 0, years: 0))
            } else if (rent_type == .DAILY) {
                tillDate = fromDate!.add(.init(seconds: 0, minutes: 0, hours: 0, days: 1, weeks: 0, months: 0, years: 0))
            } else if (rent_type == .MONTHLY) {
                tillDate = fromDate!.add(.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 1, years: 0))
            }
        }
        datesButton.snp.makeConstraints { (make) in
            make.top.equalTo(rentTypeButton.snp.bottom).offset(10)
            make.height.equalTo(40)
            make.width.equalTo(200)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        datesButton.addTarget(self, action: #selector(pickDateTapped), for: .touchUpInside)
        
        
        contentView.addSubview(datesTextLabel)
        datesTextLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-90)
            make.centerY.equalTo(datesButton.snp.centerY)
            make.height.equalTo(26)
        }
        datesTextLabel.clipsToBounds = false
        datesTextLabel.font = UIFont.init(name: "OpenSans-Regular", size: 11)!
        datesTextLabel.textColor = Constants.paletteBlackColor
        datesTextLabel.text = "Период"
        
        
        contentView.addSubview(guestsButton)
        self.applyBasicButtonDesign(guestsButton)
        guestsButton.snp.makeConstraints { (make) in
            make.top.equalTo(datesButton.snp.bottom).offset(10)
            make.height.equalTo(40)
            make.width.equalTo(200)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        guestsButton.setTitle("2 взрослых", for: .normal)
        guestsButton.addTarget(self, action: #selector(guestsButtonTapped), for: .touchUpInside)

        
        

        
        contentView.addSubview(guestsTextLabel)
        guestsTextLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-90)
            make.centerY.equalTo(guestsButton.snp.centerY)
            make.height.equalTo(26)
        }
        guestsTextLabel.clipsToBounds = false
        guestsTextLabel.font = UIFont.init(name: "OpenSans-Regular", size: 11)!
        guestsTextLabel.textColor = Constants.paletteBlackColor
        guestsTextLabel.text = "Гости"
        
        
        contentView.addSubview(priceHeaderLabel)
        priceHeaderLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-Constants.basicOffset*2)
            make.height.equalTo(20)
            make.top.equalTo(guestsButton.snp.bottom).offset(30)
        }
        priceHeaderLabel.textColor = Constants.paletteBlackColor
        priceHeaderLabel.font = UIFont.init(name: "OpenSans-Bold", size: 15)!
        priceHeaderLabel.text = "Цена"
        
        
        contentView.addSubview(newPriceLabel)
        newPriceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-90)
            make.top.equalTo(priceHeaderLabel.snp.bottom).offset(15)
            make.height.equalTo(26)
        }
        newPriceLabel.clipsToBounds = false
        newPriceLabel.font = UIFont.init(name: "OpenSans-Regular", size: 11)!
        newPriceLabel.textColor = Constants.paletteBlackColor
        newPriceLabel.text = "Цена"
        
        contentView.addSubview(newPricePickerView)
        newPricePickerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.screenFrame.size.width - Constants.basicOffset-138)
            make.centerY.equalTo(newPriceLabel.snp.centerY)
            make.width.equalTo(138)
            make.height.equalTo(20)
        }
        newPricePickerView.didPickValueClosure = { (newValue) in
            self.price = newValue as? Int
        }
        
        contentView.addSubview(bargainLabel)
        bargainLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-90)
            make.top.equalTo(newPriceLabel.snp.bottom).offset(24)
            make.height.equalTo(26)
        }
        bargainLabel.clipsToBounds = false
        bargainLabel.font = UIFont.init(name: "OpenSans-Regular", size: 11)!
        bargainLabel.textColor = Constants.paletteBlackColor
        bargainLabel.text = "Возможен торг"
        
        contentView.addSubview(bargainPickerSwitch)
        bargainPickerSwitch.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.screenFrame.size.width - Constants.basicOffset-51)
            make.width.equalTo(51)
            make.height.equalTo(31)
            make.centerY.equalTo(bargainLabel.snp.centerY)
        }
        bargainPickerSwitch.onTintColor = Constants.paletteVioletColor
        bargainPickerSwitch.addTarget(self, action: #selector(bargainValueChanged), for: .valueChanged)
        
        
        
        contentView.addSubview(bargainCopyrightLabel)
        bargainCopyrightLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(81)
            make.top.equalTo(bargainPickerSwitch.snp.bottom).offset(12)
        }
        bargainCopyrightLabel.textColor = Constants.paletteLightGrayColor
        bargainCopyrightLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        bargainCopyrightLabel.text = "Чтобы торг был эффективным, предлагайте разумную цену. \n\nПомните, Pillowz не берет с вас комиссию."
        bargainCopyrightLabel.numberOfLines = 0
        bargainCopyrightLabel.textAlignment = .center
        
        dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        
        
        
        self.view.addSubview(self.bottomView)
        self.bottomView.snp.makeConstraints({ (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(59)
        })
        self.bottomView.agreeButton.setTitle("Забронировать", for: .normal)
//        self.bottomView.agreeButton.backgroundColor = UIColor(hexString: "#E2E2E2")
        self.bottomView.delegate = self
        self.bottomView.periodLabel.text = Request.getPeriodString(start_time: self.start_time, end_time: self.end_time, rent_type: self.rent_type)
        
        let leftButton: UIButton = UIButton(type: .custom)
        leftButton.setImage(UIImage(named: "close"), for: .normal)
        leftButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        leftButton.frame = CGRect(x:0, y:0, width:44, height:44)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        newPricePickerView.isEnabled = false
        
        bargainPickerSwitch.setOn(true, animated: true)
        bargainValueChanged()
    }
    
    @objc func guestsButtonTapped() {
        let guestsView = GuestsPickerModalView()
        guestsView.vc = self
        guestsView.adults = self.guests_count["adult_guest"]!
        guestsView.childs = self.guests_count["child_guest"]!
        guestsView.show()
    }
    
    @objc func rentTypeButtonTapped() {
        let view = RentTypePickerView()
        
        var availableRentTypes:[RENT_TYPES] = []
        
        for price in space!.prices! {
            if (price.price != nil) {
                availableRentTypes.append(price.rent_type!)
            }
        }
        view.rentTypes = availableRentTypes
        view.didPickRentTypeClosure = { (rentType) in
            self.rent_type = rentType
        }
        view.show()
    }
    
    func applyBasicButtonDesign(_ button:UIButton) {
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hexString: "#E2E2E2").cgColor
        button.setTitleShadowColor(.clear, for: .normal)
        button.titleLabel?.font = UIFont.init(name: "OpenSans-SemiBold", size: 15)!
        button.setTitleColor(Constants.paletteVioletColor, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8)
    }
    
    @objc func bargainValueChanged() {
        if !bargainPickerSwitch.isOn {
            price = space.calculateTotalPriceFor(rent_type!, startTimestamp: start_time!, endTimestamp: end_time!)
        }
        
        newPricePickerView.isEnabled = bargainPickerSwitch.isOn
    }
    
    @objc func closeTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
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
    
    func didPickStartDate(_ startDate: Date, endDate: Date?) {
        self.fromDate = startDate
        
        if (rent_type != .HALFDAY && rent_type != .MONTHLY) {
            self.tillDate = endDate
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayCurrentStateOfRequest()
    }
    
    func displayCurrentStateOfRequest() {
        if (rent_type != nil) {
            if (shouldUpdatePrice) {
                price = space.calculateTotalPriceFor(rent_type!, startTimestamp: start_time!, endTimestamp: end_time!)
                
                if (bargain == nil) {
                    bargain = false
                }
                
                shouldUpdatePrice = false
            }
        }
        
        if (guests_count["adult_guest"] != 0 || guests_count["child_guest"] != 0 || guests_count["baby_guest"] != 0) {
            var fullText = ""
            
            if (guests_count["adult_guest"] != 0) {
                fullText.append(String(guests_count["adult_guest"]!)+" взрослых, ")
            }
            
            if (guests_count["child_guest"] != 0) {
                fullText.append(String(guests_count["child_guest"]!)+" детей, ")
            }
            
            if (guests_count["baby_guest"] != 0) {
                fullText.append(String(guests_count["baby_guest"]!)+" младенцев, ")
            }
            
            fullText = String(fullText.dropLast(2))
            
            //guestsField.setCustomText(text: fullText)
            
//            let cell = self.rentTypeCrudVM.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ListPickerTableViewCell
//            cell?.nameLabel.textColor = Constants.paletteVioletColor
        }
        
        if (price != nil) {
            var fullText = String(price!)+"₸"
            
            if (bargain != nil && bargain) {
                fullText = fullText + " (торг)"
            }
            
            //periodField.setCustomText(text: fullText)
            
//            self.rentTypeCrudVM.tableView.reloadData()
//
//            let cell = self.rentTypeCrudVM.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? ListPickerTableViewCell
//            cell?.nameLabel.textColor = Constants.paletteVioletColor
        }
    }
    
    func agreeTapped() {
        if (isValid()) {
            actionButtonTapped()
        }
    }
    
    func actionButtonTapped() {
        if (!User.isLoggedIn()) {
            self.navigationController?.pushViewController(GuestRoleViewController(), animated: true)
            
            return
        }

        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        RequestAPIManager.createPersonalRequestForSpaceId(spaceId: space.space_id.intValue, price: price!, bargain: bargainPickerSwitch.isOn.description, startTime: start_time!, endTime: end_time!, rentType: rent_type!.rawValue, guests_count: guests_count) { (requestObject, error) in
            MBProgressHUD.hide(for: self.view, animated: true)

            if (error == nil) {
                MainTabBarController.shared.selectedIndex = 2
                
                let vc = (MainTabBarController.shared.viewControllers![2] as! UINavigationController).viewControllers.first as! RequestsListViewController
                vc.page = 1
                vc.loadNextPage()
                
                self.navigationController?.dismiss(animated: true, completion: nil)

                let infoView = ModalInfoView(titleText: "Отлично! Ваша заявка успешно создана и будет активна в течение 24 часов.", descriptionText: "Владелец жилья уже получил уведомление и скоро Вам ответит. Теперь Ваша заявка находится в разделе “Мои заявки”, где Вы можете отслеживать ее статус.")
                
                infoView.addButtonWithTitle("Посмотреть заявку", action: {
                    if let request = requestObject as? Request, let _ = request.request_id {
                        let requestVC = RequestOrOfferViewController()
                        
                        RequestUpdateFirebaseListener.shared.requestVC = requestVC
                        RequestUpdateFirebaseListener.shared.request = request

                        requestVC.request = request
                        UIApplication.topViewController()?.navigationController?.pushViewController(requestVC, animated: true)                        
                    }
                })
                
                infoView.show()
            } else {
                
            }
        }
    }
    
    func isValid() -> Bool {
        if (price == nil || start_time == nil || end_time == nil || rent_type == nil) {
            if start_time == nil || end_time == nil {
                DesignHelpers.makeToastWithText("Выберите даты")
            }
            
            if price == nil {
                DesignHelpers.makeToastWithText("Заполните цену")
            }
            
            return false
        }
        
        return true
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
