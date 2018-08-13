//
//  RequestViewController.swift
//  Pillowz
//
//  Created by Samat on 10.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class RequestOrOfferViewController: PillowzViewController, UITableViewDataSource, UITableViewDelegate, SlidingContainerSliderViewDelegate, BargainTableViewCellDelegate, RequestOptionsTableViewCellDelegate, ComplainTableViewCellDelegate {
    var request:Request? {
        didSet {
            if (request!.offers != nil) {
                setupDataSource()
            }
        }
    }
    
    var offer:Offer? {
        didSet {
            setupDataSource()
        }
    }
        

    let tableView = UITableView()
    
    let topDetailView = UIView()
    let titleLabel = UILabel()
    let backButton = UIButton()
    let nameOrFieldsLabel = UILabel()
    let priceLabel = UILabel()
    let addressLabel = UILabel()
    let openSpaceButton = UIButton()
    
    let offerButton = UIButton()
    let hideButton = UIButton()
    
    var sliderView: SlidingContainerSliderView!

    var tableViewDataSource:[Any] = []
    
    var requestIndexPath:IndexPath!
    var offersIndexPath:IndexPath!
    var indexPaths:[IndexPath] = []
    
    var ignoreWillDisplayCell:Bool = false
    
    var numberOfCellsBeforeOffers: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = ""
        
        getRequest()
    }
    
    func setupDataSource() {
        if (offer == nil) {
            requestIndexPath = IndexPath(row: tableViewDataSource.count, section: 0)
            
            tableViewDataSource.append("user")
            
            if (request!.req_type! == .OPEN) {
                tableViewDataSource.append("options")
                tableViewDataSource.append("fields")
            }
            
            tableViewDataSource.append("guests")
            
            if (request!.req_type! == .OPEN) {
                tableViewDataSource.append("comforts")
                tableViewDataSource.append("rules")
            }
            
            if (request!.bargain!) {
                tableViewDataSource.append("bargain")
            }
            
            if (request!.req_type! != .OPEN) {
                tableViewDataSource.append("options")
            }
            
            tableViewDataSource.append("complain")
            
            offersIndexPath = IndexPath(row: tableViewDataSource.count, section: 0)
            
            if (request!.req_type! == .OPEN) {
                tableViewDataSource.append("offersHeader")
                
                numberOfCellsBeforeOffers = tableViewDataSource.count
                
                for offer in request!.offers! {
                    tableViewDataSource.append(offer)
                }
            }
            
            tableViewDataSource.append("emptyCell")
        } else {
            tableViewDataSource.append("user")

            if (request!.bargain!) {
                tableViewDataSource.append("bargain")
            } else {
                tableViewDataSource.append("options")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.sliderView.selectItemAtIndex(0)

        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func loadView() {
        super.loadView()
        
        
        
        self.view.addSubview(topDetailView)
        topDetailView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(300)
        }
        topDetailView.backgroundColor = DesignHelpers.currentMainColor()
        
        topDetailView.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.width.height.equalTo(44)
        }
        backButton.setImage(#imageLiteral(resourceName: "backWhite"), for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        topDetailView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(44)
        }
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        titleLabel.text = "Детали заявки"

        topDetailView.addSubview(nameOrFieldsLabel)
        nameOrFieldsLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(63)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(20)
        }
        nameOrFieldsLabel.textColor = .white
        nameOrFieldsLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        
        topDetailView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameOrFieldsLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(20)
        }
        priceLabel.textColor = .white
        priceLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        if (request!.req_type == .OPEN && offer == nil) {
            topDetailView.addSubview(addressLabel)
            addressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(priceLabel.snp.bottom).offset(10)
                make.left.equalToSuperview().offset(Constants.basicOffset)
                make.right.equalToSuperview().offset(-Constants.basicOffset)
                make.height.equalTo(20)
            }
            addressLabel.textColor = .white
            priceLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        } else {
            topDetailView.addSubview(openSpaceButton)
            openSpaceButton.snp.makeConstraints { (make) in
                make.top.equalTo(priceLabel.snp.bottom).offset(10)
                make.left.equalToSuperview().offset(Constants.basicOffset)
                make.width.equalTo(167)
                make.height.equalTo(36)
            }
            openSpaceButton.setTitleColor(.white, for: .normal)
            openSpaceButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .light)
            openSpaceButton.layer.cornerRadius = 18
            openSpaceButton.layer.borderWidth = 1
            openSpaceButton.layer.borderColor = UIColor.white.cgColor
            openSpaceButton.setTitle("Посмотреть объект", for: .normal)
            openSpaceButton.addTarget(self, action: #selector(openSpaceTapped), for: .touchUpInside)
        }
        
        sliderView = SlidingContainerSliderView(width: Constants.screenFrame.size.width, titles: ["Детали заявки", "Предложения"])
        sliderView.sliderDelegate = self
        self.view.addSubview(sliderView)
        sliderView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            
            if (request!.req_type! == .OPEN && User.currentRole == .realtor) {
                make.height.equalTo(50)
            } else {
                make.height.equalTo(0)
            }
            make.top.equalTo(topDetailView.snp.bottom).offset(0)
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(sliderView.snp.bottom).offset(0)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-49)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserTableViewCell.classForCoder(), forCellReuseIdentifier: "user")
        tableView.register(BargainTableViewCell.classForCoder(), forCellReuseIdentifier: "bargain")
        tableView.register(RequestOptionsTableViewCell.classForCoder(), forCellReuseIdentifier: "options")
        tableView.register(FieldsTableViewCell.classForCoder(), forCellReuseIdentifier: "fields")
        tableView.register(ComfortsOrRulesTableViewCell.classForCoder(), forCellReuseIdentifier: "icons")
        tableView.register(ComplainTableViewCell.classForCoder(), forCellReuseIdentifier: "complain")
        tableView.register(SpaceEditTableViewCell.classForCoder(), forCellReuseIdentifier: "SpaceEditTableViewCell")
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "offersHeader")
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 120
        
        
        self.view.addSubview(offerButton)
        offerButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-60)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.equalTo((Constants.screenFrame.size.width-2*Constants.basicOffset-10)/3)
            make.height.equalTo(60)
        }
        offerButton.backgroundColor = DesignHelpers.currentMainColor()
        offerButton.layer.cornerRadius = 10
        offerButton.setImage(#imageLiteral(resourceName: "offerSpace"), for: .normal)
        offerButton.setTitle("Предложить", for: .normal)
        offerButton.centerVertically()
        offerButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        offerButton.addTarget(self, action: #selector(offerTapped), for: .touchUpInside)
        
        self.view.addSubview(hideButton)
        hideButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-60)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo((Constants.screenFrame.size.width-2*Constants.basicOffset-10)/3)
            make.height.equalTo(60)
        }
        hideButton.backgroundColor = .clear
        hideButton.layer.cornerRadius = 10
        hideButton.layer.borderWidth = 1
        hideButton.layer.borderColor = DesignHelpers.currentMainColor().cgColor
        hideButton.fillImageView(image: #imageLiteral(resourceName: "hide"), color: DesignHelpers.currentMainColor())
        hideButton.setTitle("Скрыть", for: .normal)
        hideButton.centerVertically()
        hideButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        hideButton.setTitleColor(DesignHelpers.currentMainColor(), for: .normal)
        hideButton.addTarget(self, action: #selector(hideTapped), for: .touchUpInside)
        
        offerButton.isHidden = true
        hideButton.isHidden = true
    }
    
    @objc func offerTapped() {
        let offerVC = NewOfferViewController()
        offerVC.request = request
        self.navigationController?.pushViewController(offerVC, animated: true)
    }
    
    @objc func hideTapped() {
        
    }
    
    @objc func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func showTopDetailView(_ show:Bool) {
        self.view.layoutIfNeeded()
        
        if (show) {
            topDetailView.snp.updateConstraints({ (make) in
                make.height.equalTo(200)
            })
        } else {
            topDetailView.snp.updateConstraints({ (make) in
                make.height.equalTo(0)
            })
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = tableViewDataSource[indexPath.row]
        
        if (object is String) {
            let string = object as! String
            
            if (string=="user") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "user") as! UserTableViewCell
                
                return cell
            } else if (string=="bargain") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "bargain") as! BargainTableViewCell
                
                cell.delegate = self
                
                return cell
            } else if (string=="options") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "options") as! RequestOptionsTableViewCell
                
                cell.request = self.request
                cell.delegate = self
                
                return cell
            } else if (string=="rules" || string=="comforts") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "icons") as! ComfortsOrRulesTableViewCell
                
                if (string=="rules") {
                    cell.header = "Нужные правила дома"
                    cell.rules = request!.space_rule
                } else {
                    cell.header = "Нужные удобства"
                    cell.comforts = request!.comforts
                }
                
                return cell
            } else if (string=="complain") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "complain") as! ComplainTableViewCell
                
                cell.delegate = self
                
                return cell
            } else if (string=="fields" || string=="guests") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "fields") as! FieldsTableViewCell
                
                if (string=="fields") {
                    cell.header = "Снимет"
                    cell.fields = Field.getNonEmptyFields(fields: request!.fields!)
                } else {
                    cell.header = "Количество гостей"
                    cell.fields = request!.getGuestsFields()
                }
                
                cell.header = "Количество гостей"

                return cell
            } else if (string=="offersHeader") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "offersHeader")!
                
                cell.contentView.backgroundColor = .lightGray
                cell.textLabel?.text = "Предложения арендодателей (" + String(request!.offers!.count) + ")"
                
                return cell
            }
        } else if (object is Offer) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpaceEditTableViewCell") as! SpaceEditTableViewCell
            
            cell.space = self.request!.offers![indexPath.row-numberOfCellsBeforeOffers].space!
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = tableViewDataSource[indexPath.row]
        
        if (object is Offer) {
            let offerVC = OfferViewController()
            offerVC.offer = object as! Offer
            self.navigationController?.pushViewController(offerVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let object = tableViewDataSource[indexPath.row]
        
        if (object is String) {
            let string = object as! String
            
            if (string=="user") {
                return 90
            } else if (string=="bargain") {
                return 257
            } else if (string=="options") {
                return 150
            } else if (string=="rules" || string=="comforts") {
                return 110
            } else if (string=="complain") {
                return 40
            } else if (string=="fields" || string=="guests") {                
                if (string=="fields") {
                    return CGFloat(70 + 20*Field.getNonEmptyFields(fields: request!.fields!).count)
                } else {
                    let fields = request!.getGuestsFields()
                    
                    return CGFloat(70 + 20*fields.count)
                }
            } else if (string=="offersHeader") {
                return 50
            }
        } else {
            
        }
        
        return 200
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (!ignoreWillDisplayCell) {
            for currentPartIndexPath in indexPaths {
                if currentPartIndexPath.row==indexPath.row {
                    sliderView.selectItemAtIndex(indexPaths.index(of: indexPath)!)
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y <= 50) { // TOP
            showTopDetailView(true)
        } else {
            showTopDetailView(false)
        }
    }
    
    func getRequest() {
        RequestAPIManager.getSingleRequest(request_id: request!.request_id!) { (requestObject) in
            self.request = requestObject as? Request
            
            if (self.request!.req_type! == .OPEN) {
                self.nameOrFieldsLabel.text = Field.getShortFieldsDescriptionText(fields: self.request!.fields!)
                self.openSpaceButton.isHidden = true
                
                if (User.currentRole == .realtor) {
                    self.offerButton.isHidden = false
                    self.hideButton.isHidden = false
                }
            } else {
                
                self.openSpaceButton.isHidden = false
            }
            
            self.priceLabel.text = String(self.request!.price!)+"₸" + " " + Request.getStringForRentType(self.request!.rent_type!, startTime: self.request!.start_time, endTime: self.request!.end_time)

            self.addressLabel.text = self.request!.address!
            
            self.tableView.reloadData()
        }
    }
    
    func deleteRequest() {
        RequestAPIManager.deleteRequest(request_id: request!.request_id!) { (response) in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func slidingContainerSliderViewDidPressed(_ slidingtContainerSliderView: SlidingContainerSliderView, atIndex: Int) {
        ignoreWillDisplayCell = true
        
        sliderView.selectItemAtIndex(atIndex)

        self.tableView.scrollToRow(at: indexPaths[atIndex], at: .top, animated: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // do stuff 42 seconds later
            self.ignoreWillDisplayCell = false
        }
    }
    
    @objc func openSpaceTapped() {
        let vc = SpaceViewController()
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func agreeTapped() {
        var status:RequestStatus
        
        if (User.currentRole == .client) {
            status = .COMPLETED
        } else {
            status = .COMPLETED
        }
        
        RequestAPIManager.updatePersonalRequestStatus(request: self.request!, status: status) { (responseObject) in
            
        }
    }
    
    func offerNewPriceTapped(newPrice: Int) {
        RequestAPIManager.updatePersonalRequestPrice(request: self.request!, price: newPrice) { (responseObject) in
            
        }
    }
    
    func rejectTapped() {
        var status:RequestStatus
        
        if (User.currentRole == .client) {
            status = .CLIENT_REJECTED
        } else {
            status = .REALTOR_REJECTED
        }
        
        RequestAPIManager.updatePersonalRequestStatus(request: self.request!, status: status) { (responseObject) in
            
        }
    }
    
    func chatTapped() {
        let chatVC = ChatViewController()
        chatVC.room = request!.chat_room!
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func callTapped() {
//        if let phoneCallURL = URL(string: "tel://\(offer.space!.realtor!.contact_number!)") {
//            let application:UIApplication = UIApplication.shared
//            if (application.canOpenURL(phoneCallURL)) {
//                application.open(phoneCallURL, options: [:], completionHandler: nil)
//            } else {
//                
//            }
//        }
    }
    
    func complainTapped() {
        
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
