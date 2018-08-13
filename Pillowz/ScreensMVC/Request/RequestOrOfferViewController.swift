//
//  RequestViewController.swift
//  Pillowz
//
//  Created by Samat on 10.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD
import FirebaseDatabase

class RequestOrOfferViewController: PillowzViewController, UITableViewDataSource, UITableViewDelegate, BargainViewDelegate, RequestOptionsTableViewCellDelegate, ComplainTableViewCellDelegate, AgreeToOfferTableViewCellDelegate, RejectRequestOrOfferTableViewCellDelegate, CreateReviewTableViewCellDelegate, RequestSpaceInfoTableViewCellDelegate, UserTableViewCellDelegate, RequestOrOfferBottomViewDelegate {
    
    /*
    offer
    if realtor
        can cancel
        can bargain if bargain
    if client
        can approve
        can bargain if bargain
    
    personal request
    if realtor
        can accept
        can reject
        can bargain if bargain
    if client
        can cancel
        can bargain if bargain
    
    open request
    if realtor
        can offer
        can hide
    if client
        can cancel
        can open offer
    */
    
    var request:Request! {
        didSet {
            if (requestType == nil) {
                requestType = request!.req_type
                offersCount = request!.offers_count
                newPricesCount = request!.new_prices_count
                newOffersCount = request!.new_offers_count
                rentType = request!.rent_type
            } else {
                request!.req_type = requestType
                request!.offers_count = offersCount
                request!.new_prices_count = newPricesCount
                request!.new_offers_count = newOffersCount
                request!.rent_type = rentType
            }
            
            if (offer == nil) {
                showRequestOrOfferData()
            } else {
                let vc = self.navigationController!.viewControllers[1] as! RequestOrOfferViewController
                vc.request = request
                vc.tableView.reloadData()

                for iteratingOffer in request!.offers! {
                    if (offer!.id! == iteratingOffer.id!) {
                        offer = iteratingOffer
                        
                        return
                    }
                }
            }
        }
    }
    
    var requestId:Int?
    var offerId:Int?

    var requestType:RequestType?
    var offersCount:Int?
    var newPricesCount:Int?
    var newOffersCount:Int?
    var rentType:RENT_TYPES?

    var offer:Offer? {
        didSet {
            didLoad = true
            
            viewOffer()
            
            showRequestOrOfferData()
        }
    }
    
    var isShowingRealtorOffers = false
    
    var didLoad:Bool = false
    
    let tableView = UITableView()

    let cancelButton = UIButton()
    
    var tableViewDataSource:[Any] = []
    
    let topBackButton = UIButton()
    let topCancelButton = UIButton()
    
    let bottomView = RequestOrOfferBottomView()
    
    let topGradient = UIImageView()

    var rightButton: UIButton!
    
    var ref: DatabaseReference!

    var isLoading = false
    
    var handle:UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = ""
        
        self.getRequest()
    }
    
    func configureFirebaseReference() {
        var currentRequestId:Int
        
        if let nonNilRequestId = requestId {
            currentRequestId = nonNilRequestId
        } else {
            currentRequestId = request.request_id!
        }
        
//        isConfiguredFirebase = true
        
        ref = Database.database().reference().child("request_updates").child(String(currentRequestId))
        
        ref.observe(DataEventType.value, with: { (snapshot) in
            self.getRequest()
        })
    }
    
    deinit {
        if offer != nil {
            RequestUpdateFirebaseListener.shared.offerVC = nil
        } else {
            RequestUpdateFirebaseListener.shared.requestVC = nil
            RequestUpdateFirebaseListener.shared.request = nil
            RequestUpdateFirebaseListener.shared.requestId = nil
        }
    }
    
    func showRequestOrOfferData() {
        if (!didLoad) {
            return
        }
        
        setupDataSource()
        self.tableView.reloadData()
    }
    
    func getRequest() {
        if isLoading {
            return
        }
        
        if (offer != nil || (didLoad && isShowingRealtorOffers)) {
            setupTopUI()

            showRequestOrOfferData()

            return
        }
        
        var requestId = request?.request_id

        if (requestId == nil) {
            requestId = self.requestId
        }

        if (requestId == nil) {
            return
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)

        isLoading = true

        RequestAPIManager.getSingleRequest(request_id: requestId!) { (requestObject, error) in
            self.isLoading = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                MBProgressHUD.hide(for: self.view, animated: true)
            }

            if (error == nil) {
                self.didLoad = true

                self.request = requestObject as? Request

                if self.request.req_type == .PERSONAL || self.offer != nil {
                    self.navigationController?.setNavigationBarHidden(true, animated: true)
                }

                self.setupTopUI()
                
                if (self.request!.offers != nil) {
                    var realtorOffers:[Offer] = []

                    var completedOffer:Offer?

                    for requestOffer in self.request!.offers! {
                        realtorOffers.append(requestOffer)

                        if (requestOffer.status == .COMPLETED) {
                            completedOffer = requestOffer
                        }
                    }

                    if (realtorOffers.count == 1 || completedOffer != nil) && self.offer == nil {
                        let vc = RequestOrOfferViewController()
                        vc.request = self.request

                        if (completedOffer != nil) {
                            vc.offer = completedOffer!
                        } else {
                            vc.offer = realtorOffers[0]
                        }

                        self.navigationController?.pushViewController(vc, animated: false)
                    } else if (realtorOffers.count > 1) {

                    }
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func setupTopUI() {
        let isCompleted = request?.status == .COMPLETED || request?.status == .COMPLETED_WITH_OTHER || request?.status == .CLIENT_REJECTED || request?.status == .REALTOR_REJECTED || request?.status == .MAX_ITERATIONS_EXCEEDED || request?.status == .REQUEST_TIMED_OUT
        
        if (self.request.req_type == .OPEN && self.offer == nil) {
            self.navigationController?.navigationBar.isHidden = false
            
            if (!isCompleted) {
                rightButton = UIButton(type: .custom)
                if (User.currentRole == .client) {
                    rightButton.setTitle("отменить", for: .normal)
                    rightButton.setTitleColor(Constants.paletteBlackColor, for: .normal)
                    rightButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
                } else {
                    rightButton.setTitle("Предложить", for: .normal)
                    rightButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
                    rightButton.titleLabel?.font = UIFont.init(name: "OpenSans-Bold", size: 13)!
                }
                rightButton.addTarget(self, action: #selector(self.cancelOrOfferTapped), for: .touchUpInside)
                rightButton.frame = CGRect(x:0, y:0, width:100, height:30)
                let rightBarButton = UIBarButtonItem(customView: rightButton)
                self.navigationItem.rightBarButtonItem = rightBarButton
            }
        } else {
            self.view.addSubview(topGradient)
            topGradient.snp.makeConstraints({ (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(64)
            })
            topGradient.image = #imageLiteral(resourceName: "appbar_gradient")
            
            self.view.addSubview(self.topBackButton)
            self.topBackButton.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.top.equalToSuperview().offset(20)
                make.width.height.equalTo(44)
            }
            self.topBackButton.setImage(#imageLiteral(resourceName: "backWhite"), for: .normal)
            self.topBackButton.addTarget(self, action: #selector(self.backTapped), for: .touchUpInside)
            
            self.view.addSubview(self.topCancelButton)
            self.topCancelButton.snp.makeConstraints({ (make) in
                make.right.equalToSuperview()
                make.top.equalToSuperview().offset(20)
                make.height.equalTo(44)
                make.width.equalTo(100)
            })
            
            if (User.currentRole == .client) {
                self.topCancelButton.setTitle("отменить", for: .normal)
            } else {
                self.topCancelButton.setTitle("отказать", for: .normal)
            }
            self.topCancelButton.setTitleColor(.white, for: .normal)
            self.topCancelButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
            self.topCancelButton.addTarget(self, action: #selector(self.cancelOrOfferTapped), for: .touchUpInside)
            
            self.view.addSubview(self.bottomView)
            self.bottomView.snp.makeConstraints({ (make) in
                make.bottom.left.right.equalToSuperview()
                make.height.equalTo(59)
            })

            self.tableView.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(-20)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(bottomView.snp.top)
            }
            
            if (offer != nil) {
                self.bottomView.priceLabel.text = offer!.agreePrice.formattedWithSeparator + "₸"
            } else {
                self.bottomView.priceLabel.text = request!.agreePrice.formattedWithSeparator + "₸"
            }
            
            self.bottomView.periodLabel.text = self.request.getRequestPeriodString()
            self.bottomView.delegate = self
        }
        
        self.topCancelButton.isHidden = isCompleted
        
        if let rightButton = self.rightButton {
            rightButton.isHidden = isCompleted
        }
        
        let isWaitingForAnswer = (User.currentRole == .client && (request?.status == .NOT_VIEWED || request?.status == .VIEWED)) || (User.currentRole == .realtor && (request?.status == .REALTOR_OFFER || request?.status == .REALTOR_OFFER_VIEWED))

        let shouldHideBottomView = (offer == nil && isWaitingForAnswer) || (request.status == .COMPLETED || offer?.status == .COMPLETED)
        
        if shouldHideBottomView {
            self.bottomView.isHidden = shouldHideBottomView
            self.bottomView.snp.updateConstraints({ (make) in
                make.height.equalTo(0)
            })
        }
    }
    
    func viewOffer() {
        RequestAPIManager.viewOffer(self.offer!.id!) { (responseObject, error) in
            
        }
    }
    
    func setupDataSource() {
        tableViewDataSource = []
        
        if (request.req_type == .OPEN && offer == nil) {
            if (User.currentRole == .realtor) {
                tableViewDataSource.append("requestOpenName")
                tableViewDataSource.append("requestInfo")
                tableViewDataSource.append("requestDetails")
                
                if (isShowingRealtorOffers) {
                    for offer in request.offers! {
                        tableViewDataSource.append(offer)
                    }
                } else {
                    tableViewDataSource.append("user")
                    
                    if (request.offers?.count != 0) {
                        tableViewDataSource.append("myOffers")
                    }
                }
            } else {
                tableViewDataSource.append("requestOpenName")
                
                tableViewDataSource.append("requestInfo")
                tableViewDataSource.append("requestDetails")
                
                if (request.offers?.count != 0) {
                    tableViewDataSource.append("offersHeader")
                }
                
                for offer in request.offers! {
                    tableViewDataSource.append(offer)
                }
            }
        } else {
            tableViewDataSource.append("photos")
            tableViewDataSource.append("spaceInfo")
            
            tableViewDataSource.append("user")
            
            tableViewDataSource.append("requestInfo")
            
            if (request.bargain!) {
                tableViewDataSource.append("bargain")
                
                var priceHistory:[[String:Any]]?
                
                if let request = request {
                    priceHistory = request.price_histories
                }
                
                if let offer = offer {
                    priceHistory = offer.price_histories
                }
                
                if let _ = priceHistory {
                    let isCompleted = request?.status == .COMPLETED || request?.status == .COMPLETED_WITH_OTHER || request?.status == .CLIENT_REJECTED || request?.status == .REALTOR_REJECTED || request?.status == .MAX_ITERATIONS_EXCEEDED || request?.status == .REQUEST_TIMED_OUT

                    if !isCompleted {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change 2 to desired number of seconds
                            self.tableView.scrollToRow(at: IndexPath(item:self.tableViewDataSource.count-1, section: 0), at: .bottom, animated: true)
                        }
                    }
                }
            }
            
            if request.req_type == .PERSONAL && request.can_review {
                tableViewDataSource.append("review")
                tableViewDataSource.append("complain")
            } else if let space = offer?.space, space.can_review {
                tableViewDataSource.append("review")
                tableViewDataSource.append("complain")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let nonNilRequest = self.request, nonNilRequest.req_type == .PERSONAL {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
        
        if offer != nil {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
        }
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(SpacePicturesTableViewCell.classForCoder(), forCellReuseIdentifier: "photos")
        tableView.register(RequestSpaceInfoTableViewCell.classForCoder(), forCellReuseIdentifier: "spaceInfo")
        tableView.register(UserTableViewCell.classForCoder(), forCellReuseIdentifier: "user")
        tableView.register(RequestInfoTableViewCell.classForCoder(), forCellReuseIdentifier: "requestInfo")
        tableView.register(BargainTableViewCell.classForCoder(), forCellReuseIdentifier: "bargain")
        tableView.register(ComplainTableViewCell.classForCoder(), forCellReuseIdentifier: "complain")
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "regularCell")
        tableView.register(HeaderIncludedTableViewCell.classForCoder(), forCellReuseIdentifier: "header")
        tableView.register(SpaceOfferTableViewCell.classForCoder(), forCellReuseIdentifier: "SpaceOfferTableViewCell")
        
        tableView.separatorColor = .clear
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 120
    }
    
    @objc func offerTapped() {
        let offerVC = NewOfferViewController()
        offerVC.request = request
        self.navigationController?.pushViewController(offerVC, animated: true)
    }
    
    func complainTapped() {
        let vc = CreateFeedbackViewController()
        
        if offer != nil {
            vc.offer_id = offer?.id
        } else {
            vc.request_id = request.request_id
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func createReviewTapped() {
        if User.currentRole == .client {
            let vc = SpaceAndUserReviewViewController()
            
            vc.request = self.request!
            
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let userReviewVC = CreateReviewViewController()
            userReviewVC.isUser = true
            userReviewVC.user_id = self.request!.otherUser.user_id!
            userReviewVC.superVC = self
            self.navigationController?.pushViewController(userReviewVC, animated: true)
        }
    }
    
    func chatTapped() {
        if (request.status == .COMPLETED || offer?.status == .COMPLETED) {
            let chatVC = ChatViewController()
            chatVC.hidesBottomBarWhenPushed = true

            if (offer == nil) {
                chatVC.room = request!.chat_room!
            } else {
                chatVC.room = offer!.chat_room!
            }
            
            self.navigationController?.pushViewController(chatVC, animated: true)
        } else {
            let infoView = ModalInfoView(titleText: "Данная функция будет доступна после одобрения заявки", descriptionText: "")
            
            infoView.addButtonWithTitle("OK", action: {
                
            })
            
            infoView.show()
        }
    }
    
    func callTapped() {
        if (request.status == .COMPLETED || offer?.status == .COMPLETED) {
            var phone:String = ""
            
            if let offer = offer {
                phone = offer.otherUser.phone!
            } else {
                phone = request!.otherUser.phone!
            }
            
            if let phoneCallURL = URL(string: "tel://\(phone)") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    
                }
            } else {
                let infoView = ModalInfoView(titleText: "Не удается вызвать указанный номер:" + phone, descriptionText: "Свяжитесь с сервисом техподдержки если владелец недоступен, мы решим данную проблему")
                
                infoView.addButtonWithTitle("OK", action: {
                    
                })
                
                infoView.show()
            }
        } else {
            let infoView = ModalInfoView(titleText: "Данная функция будет доступна после одобрения заявки", descriptionText: "")
            
            infoView.addButtonWithTitle("OK", action: {
                
            })
            
            infoView.show()
        }
    }

    @objc func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = tableViewDataSource[indexPath.row]
        
        if (object is String) {
            let string = object as! String
            
            let cell = getCellForString(string)
            
            cell.addSeparatorView()
            
            cell.selectionStyle = .none
            
            return cell
        } else if (object is Offer) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpaceOfferTableViewCell") as! SpaceOfferTableViewCell
            
            let offer = object as! Offer
            
            cell.request = request
            cell.offer = offer
            
            var viewed = true
            if (User.currentRole == .realtor && !offer.realtor_viewed) {
                viewed = false
            }
            if (User.currentRole == .client && !offer.client_viewed) {
                viewed = false
            }
            
            cell.spaceOfferView.unreadDotView.isHidden = viewed
            
            cell.addSeparatorView()

            cell.selectionStyle = .none
            
            return cell
        }

        return UITableViewCell()
    }
    
    func getCellForString(_ string:String) -> UITableViewCell {
        var isAccepted:Bool
        
        if (offer != nil) {
            isAccepted = (offer!.status == .COMPLETED)
        } else {
            isAccepted = (request!.status == .COMPLETED)
        }
        
        if (string=="photos") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "photos") as! SpacePicturesTableViewCell
            cell.pictureSliderView.shouldUseImageViewer = true
            
            var space:Space
            if (request.req_type! == .PERSONAL) {
                space = request.space!
            } else {
                space = offer!.space!
            }
            
            cell.space = space
            
            return cell
        } else if (string=="user") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "user") as! UserTableViewCell
            cell.delegate = self
            var otherUser:User
            
            if (offer == nil) {
                otherUser = request!.otherUser
            } else {
                otherUser = offer!.otherUser
            }

            cell.user = otherUser
            
            if (request.status == .COMPLETED || offer?.status == .COMPLETED) {
                cell.callButton.backgroundColor = Constants.paletteVioletColor
                cell.chatButton.backgroundColor = Constants.paletteVioletColor
            } else {
                cell.callButton.backgroundColor = Constants.paletteLightGrayColor
                cell.chatButton.backgroundColor = Constants.paletteLightGrayColor
            }
            
            cell.delegate = self
            
            return cell
        } else if (string=="bargain") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bargain") as! BargainTableViewCell
            cell.delegate = self
            
            cell.fillWithOffer(offer, fillingRequest: request)
                        
            return cell
        } else if (string=="offersHeader") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! HeaderIncludedTableViewCell
            
            if (User.currentRole == .client) {
                if request!.offers!.count == 0 {
                    cell.header = ""
                } else {
                    cell.header = "Предложения"
                }
            } else {
                cell.header = "Ваши предложения (" + String(request!.offers!.count) + ")"
            }
            
            return cell
        } else if (string == "requestInfo") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "requestInfo") as! RequestInfoTableViewCell
            
            cell.numberOfGuestsLabel.text = request.getNumberOfGuests().description + " " + Helpers.returnSuffix(count: request.getNumberOfGuests(), type: "guest")
            cell.numberOfDaysLabel.text = request.getRequestPeriodString()
            
            let periodText = Request.getStringForRentType(request.rent_type!, startTime: request.start_time!, endTime: request.end_time!, shouldGoToNextLine: false, includeRentTypeText: false)
            cell.periodLabel.text = periodText
            cell.priceLabel.text = request.price?.formattedWithSeparator
            cell.timeLabel.text = request.getRequestActiveTimeLeftText()
            
            if let space = request.space {
                cell.ownerPriceLabel.text = space.calculateTotalPriceFor(request.rent_type!, startTimestamp: request.start_time!, endTimestamp: request.end_time!).formattedWithSeparator + "₸" + " по тарифу владельца"
            }
            
            cell.idLabel.text = "ID: " + String(request.request_id!)
            
            return cell
        } else if (string == "spaceInfo" || string == "requestOpenName") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "spaceInfo") as! RequestSpaceInfoTableViewCell
            
            cell.delegate = self 
            cell.shouldShowLookButton = (offer != nil || request.req_type == .PERSONAL)
            
            cell.fieldsLabel.text = request.address
            
            if cell.shouldShowLookButton {
                if offer != nil {
                    cell.title = offer?.space?.name
                    cell.fieldsLabel.text = offer?.space?.open_name
                    cell.addressLabel.text = offer?.space?.address
                } else {
                    cell.title = request.space?.name
                    cell.fieldsLabel.text = request.space?.open_name
                    cell.addressLabel.text = request.space?.address
                }
                
                cell.lookButton.isHidden = false
            } else {
                cell.title = request.open_name
                cell.lookButton.isHidden = true
            }
            
            let status = Request.getStatusText(isOffer: (offer != nil), request: self.request, offer: offer)
            cell.subtitleLabel.text = status.0
            cell.subtitleLabel.textColor = status.1
            cell.subtitleLabel.font = status.2
            
            return cell
        } else if (string=="complain" || string=="review" || string=="requestDetails" || string=="myOffers") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "regularCell")!
            
            if (string=="complain") {
                if (User.currentRole == .client) {
                    cell.textLabel?.text = "Пожаловаться на владельца"
                } else {
                    cell.textLabel?.text = "Пожаловаться на клиента"
                }
            } else if (string=="requestDetails") {
                cell.textLabel?.text = "Детали заявки"
            } else if (string=="review") {
                cell.textLabel?.text = "Оставить отзыв"
            } else if (string=="myOffers") {
                if (request.offers!.count > 0) {
                    cell.textLabel?.text = "Мои предложения (" + String(request.offers!.count) + ")"
                } else {
                    
                }
            }
            
            cell.textLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 17)
            cell.textLabel?.textColor = Constants.paletteBlackColor
            cell.accessoryType = .disclosureIndicator

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
            let offer = object as! Offer
            
            //marking as viewed
            offer.client_viewed = true
            offer.realtor_viewed = true
            if let cell = tableView.cellForRow(at: indexPath) as? SpaceOfferTableViewCell {
                cell.spaceOfferView.unreadDotView.isHidden = true
            }
            
            let vc = RequestOrOfferViewController()
            vc.request = self.request
            vc.offer = offer
            
            RequestUpdateFirebaseListener.shared.offerVC = vc
            
            self.navigationController?.pushViewController(vc, animated: true)
        } else if (object is String) {
            let string = object as! String
            
            if (string == "user") {
                let profileVC = UserProfileViewController()
                profileVC.user_id = request!.otherUser.user_id!
                self.navigationController?.pushViewController(profileVC, animated: true)
            } else if (string=="complain") {
                complainTapped()
            } else if (string=="requestDetails") {
                openRequestDetailsTapped()
            } else if (string=="review") {
                createReviewTapped()
            } else if (string=="myOffers") {
                openRealtorMyOffers()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let object = tableViewDataSource[indexPath.row]
        
        if (object is String) {
            let string = object as! String
            
            if (string=="user") {
                return UITableViewAutomaticDimension
            } else if (string=="bargain") {
                return 225
            } else if (string=="photos") {
                return UITableViewAutomaticDimension
            } else if (string == "requestInfo") {
                return UITableViewAutomaticDimension
            } else if (string == "spaceInfo" || string == "requestOpenName") {
                return UITableViewAutomaticDimension
            } else if (string=="complain" || string=="review" || string=="requestDetails" || string=="myOffers") {
                return 56
            } else if (string=="offersHeader") {
                return 66
            }
        } else if (object is Offer) {
            return 160
        }
        
        return 200
    }
    
    func openRealtorMyOffers() {
        if (request.offers!.count > 0) {
            let vc = RequestOrOfferViewController()
            
            vc.request = self.request
            vc.didLoad = true
            vc.isShowingRealtorOffers = true
            
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            
        }
    }
    
    @objc func openSpaceTapped() {
        let vc = SpaceViewController()
        vc.isOpenedFromRequest = true
        
        if (offer == nil) {
            vc.space = request!.space!
        } else {
            vc.space = offer!.space!
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func agreeTapped() {
        if self.offer == nil {
            self.request?.agreeTapped { (responseObject, error) in
                if (error == nil) {
                    self.didLoad = true
                    
                    DesignHelpers.makeToastWithText("Сделка совершена")
                    
                    self.request = responseObject as? Request
                }
            }
        } else {
            self.offer?.agreeTapped(completion: { (responseObject, error) in
                if (error == nil) {
                    self.didLoad = true
                    
                    DesignHelpers.makeToastWithText("Сделка совершена")
                    
                    self.request = responseObject as? Request
                }
            })
        }
    }
    
    func offerNewPriceTapped(newPrice: Int) {
        if self.offer == nil {
            self.request?.offerNewPriceTapped(newPrice: newPrice, completion: { (responseObject, error) in
                if (error == nil) {
                    self.didLoad = true
                    
                    DesignHelpers.makeToastWithText("Цена предложена")

                    self.request = responseObject as? Request
                }
            })
        } else {
            self.offer?.offerNewPriceTapped(newPrice: newPrice, completion: { (responseObject, error) in
                if (error == nil) {
                    self.didLoad = true

                    DesignHelpers.makeToastWithText("Цена предложена")

                    self.request = responseObject as? Request
                }
            })
        }
    }
    
    func openRequestDetailsTapped() {
        let vc = RequestDetailsViewController()
        
        vc.request = self.request
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func rejectTapped() {
        if self.offer == nil {
            self.request?.rejectTapped { (responseObject, error) in
                if (error == nil) {
                    DesignHelpers.makeToastWithText("Заявка отклонена")

                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            self.offer?.rejectTapped(completion: { (responseObject, error) in
                if (error == nil) {
                    DesignHelpers.makeToastWithText("Предложение отклонено")
                    
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    @objc func hideTapped() {
        self.request?.hideTapped(completion: { (responseObject, error) in
            if (error == nil) {
                DesignHelpers.makeToastWithText("Заявка скрыта")

                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    @objc func cancelOrOfferTapped() {
        if (User.currentRole == .client) {
            rejectTapped()
        } else {
            if (self.request.req_type == .OPEN && self.offer == nil) {
                
                if User.isLoggedIn() {
                    offerTapped()
                } else {
                    let infoView = ModalInfoView(titleText: "Вы не зарегистрированы", descriptionText: "Для того, чтобы сделать предложение нужно войти")
                    
                    infoView.addButtonWithTitle("Войти", action: {
                        self.navigationController?.pushViewController(GuestRoleViewController(), animated: true)
                    })
                    
                    infoView.show()
                }
            } else {
                rejectTapped()
            }
        }
    }
    
}

