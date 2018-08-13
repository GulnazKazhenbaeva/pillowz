//
//  RequestTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 09.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import DateToolsSwift
import MBProgressHUD

protocol RequestTableViewCellDelegate {
    func openUserWithId(_ userId:Int)
    func openOffersOfRequest(_ request:Request)
    func closeOffersOfRequest(_ request:Request)
    func moreTappedForRequest(_ request:Request)
}

class RequestTableViewCell: RequestAndOfferSwipeActionsHandlerTableViewCell, BargainViewDelegate, UserTableViewCellDelegate {
    var request:Request! {
        didSet {
            agreeButton.isHidden = true
            bargainView.isHidden = true
            completedView.isHidden = true
            cancelOrArchiveButton.isHidden = true
            self.scrollViewContentView.snp.updateConstraints { (make) in
                make.width.equalTo(Constants.screenFrame.size.width)
            }
            
            self.requestCellView.request = request
            
            scrollView.snp.updateConstraints { (make) in
                make.height.equalTo(requestCellView.calculatedHeight)
            }
            
            if User.currentRole == .client {
                self.cancelOrArchiveLabel.text = "отменить"
            } else {
                if self.request.req_type == .OPEN {
                    self.cancelOrArchiveLabel.text = "скрыть"
                } else {
                    self.cancelOrArchiveLabel.text = "отклонить"
                }
            }
            
            //THIS IS A BAD DECISION, BUT I'M DOING THIS BECAUSE THERE IS NO TIME FOR NOW
            cancelOrArchiveButton.backgroundColor = .white
            
            if request.offersAreOpenedInList {
                arrowImageView.image = #imageLiteral(resourceName: "upGreen")
            } else {
                arrowImageView.image = #imageLiteral(resourceName: "downGreen")
            }
            
            self.offersBackgroundView.isHidden = true
            
            if self.request.req_type == .OPEN {
                if self.request.offers!.count > 0 {
                    self.scrollView.snp.updateConstraints { (make) in
                        make.bottom.equalToSuperview().offset(-30)
                    }
                    
                    self.offersButton.setTitle(self.request.offers!.count.description + " предложений", for: .normal)
                    
                    self.offersBackgroundView.isHidden = false
                }
            } else {
                self.scrollView.snp.updateConstraints { (make) in
                    make.bottom.equalToSuperview().offset(0)
                }
            }
            
            
            
            self.scrollViewContentView.snp.updateConstraints { (make) in
                make.width.equalTo(Constants.screenFrame.size.width)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.configureSwipes()
            }
            
            self.scrollViewContentView.snp.updateConstraints { (make) in
                make.height.equalTo(requestCellView.calculatedHeight)
            }
        }
    }
    
    var favorite:Bool! {
        didSet {
            let favoriteImage = (favorite) ? #imageLiteral(resourceName: "loveRequestFilled") : #imageLiteral(resourceName: "loveRequest")
            self.requestCellView.favoriteButton.setImage(favoriteImage, for: .normal)
        }
    }
    
    var delegate:RequestTableViewCellDelegate? {
        didSet {
            self.requestCellView.delegate = delegate
        }
    }
    
    let requestCellView = RequestCellView()
    
    let offersSeparatorView = UIView()
    let offersBackgroundView = UIView()
    let arrowImageView = UIImageView()
    let offersButton = UIButton()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        scrollView.addSubview(requestCellView)
        requestCellView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(104)
            make.width.equalTo(Constants.screenFrame.size.width)
        }
        
        cancelOrArchiveButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        agreeButton.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)
        
        self.addSubview(offersBackgroundView)
        offersBackgroundView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(1)
            make.top.equalTo(scrollView.snp.bottom)
            make.height.equalTo(32)
        }
        
        offersBackgroundView.addSubview(offersSeparatorView)
        offersSeparatorView.backgroundColor = UIColor(hexString: "#E0E0E0")
        offersSeparatorView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        let image = #imageLiteral(resourceName: "downGreen")
        offersBackgroundView.addSubview(arrowImageView)
        arrowImageView.image = image
        arrowImageView.contentMode = .center
        arrowImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(50)
            make.width.height.equalTo(30)
        }
        
        offersBackgroundView.addSubview(offersButton)
        offersButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        offersButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25)
        offersButton.setTitleColor(UIColor(hexString: "#86CD3F"), for: .normal)
        offersButton.titleLabel?.font = UIFont.init(name: "OpenSans-SemiBold", size: 10)
        offersButton.addTarget(self, action: #selector(openCloseOffersTapped), for: .touchUpInside)
        
        bargainView.delegate = self
    }
    
    func configureSwipes() {
        if request.isActive() {
            self.cancelOrArchiveButton.backgroundColor = UIColor(hexString: "#FA533C")
            self.cancelOrArchiveButton.isHidden = false
            self.cancelOrArchiveIconImageView.image = #imageLiteral(resourceName: "cancelSwipeIcon")
            
            if self.request.status == .COMPLETED {
                self.completedView.isHidden = false
                
                self.completedView.delegate = self
                
                if self.request.req_type == .PERSONAL {
                    self.completedView.user = self.request.otherUser
                    self.completedView.priceLabel.text = String(self.request.agreePrice) + "₸"
                } else {
                    for offer in self.request.offers! {
                        if offer.status == .COMPLETED {
                            self.completedView.user = offer.otherUser
                            self.completedView.priceLabel.text = String(offer.agreePrice) + "₸"
                        }
                    }
                }
                
                self.scrollViewContentView.snp.updateConstraints { (make) in
                    make.width.equalTo(104 + Constants.screenFrame.size.width + 258)
                }
                
                //animate showing completed view
                if !RequestAndOfferSwipeActionsHandlerTableViewCell.getDidShowCompleted() {
                    self.animateLeftSwipe()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.animateRightSwipe()
                    }
                    
                    RequestAndOfferSwipeActionsHandlerTableViewCell.setDidShowCompleted(true)
                }
            } else {
                if self.request.req_type == .OPEN {
                    self.scrollViewContentView.snp.updateConstraints { (make) in
                        make.width.equalTo(104 + Constants.screenFrame.size.width)
                    }
                    
                    
                    //animate showing cancel button
                    var showed = false
                    if !RequestAndOfferSwipeActionsHandlerTableViewCell.getDidShowCancel() {
                        showed = true
                        
                        self.animateLeftSwipe()
                        
                        RequestAndOfferSwipeActionsHandlerTableViewCell.setDidShowCancel(true)
                    }
                    
                    //animate showing archive button
                    if !showed && !RequestAndOfferSwipeActionsHandlerTableViewCell.getDidShowArchive() {
                        self.animateLeftSwipe()
                        
                        RequestAndOfferSwipeActionsHandlerTableViewCell.setDidShowArchive(true)
                    }
                } else {
                    if self.request.bargain == true {
                        self.scrollViewContentView.snp.updateConstraints { (make) in
                            make.width.equalTo(104 + Constants.screenFrame.size.width + 258)
                        }
                        
                        self.bargainView.fillWithOffer(nil, fillingRequest: self.request)
                        
                        self.bargainView.isHidden = false
                        
                        
                        //animate showing bargain view
                        if !RequestAndOfferSwipeActionsHandlerTableViewCell.getDidShowBargain() {
                            self.animateLeftSwipe()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.animateRightSwipe()
                            }
                            
                            RequestAndOfferSwipeActionsHandlerTableViewCell.setDidShowBargain(true)
                        }
                    } else {
                        self.scrollViewContentView.snp.updateConstraints { (make) in
                            make.width.equalTo(104*2 + Constants.screenFrame.size.width)
                        }
                        
                        self.agreeButton.isHidden = false
                        
                        let justSentAnOffer = self.request.justSentAnOffer()
                        
                        if justSentAnOffer {
                            self.agreeButton.backgroundColor = Constants.paletteLightGrayColor
                            self.agreeButton.isEnabled = false
                            self.agreeLabel.text = "ответ ожидается"
                        } else {
                            self.agreeButton.backgroundColor = Constants.paletteVioletColor
                            self.agreeButton.isEnabled = true
                            self.agreeLabel.text = "забронировать"
                        }
                    }
                }
            }
        } else {
            self.cancelOrArchiveButton.isHidden = false
            
            self.scrollViewContentView.snp.updateConstraints { (make) in
                make.width.equalTo(104 + Constants.screenFrame.size.width)
            }

            self.requestCellView.snp.updateConstraints { (make) in
                make.left.equalToSuperview().offset(104)
            }
        }
        
        if request.isAbleToArchive() {
            self.cancelOrArchiveButton.backgroundColor = Constants.paletteLightGrayColor
            self.cancelOrArchiveIconImageView.image = #imageLiteral(resourceName: "archive")
            self.cancelOrArchiveLabel.text = "архивировать"
        }
        
        self.requestCellView.snp.updateConstraints { (make) in
            make.left.equalToSuperview().offset(104)
        }
        
        self.scrollView.setContentOffset(CGPoint(x: 104, y: 0), animated: false)
    }
    
    @objc func openCloseOffersTapped() {
        request.offersAreOpenedInList = !request.offersAreOpenedInList
        
        if request.offersAreOpenedInList {
            arrowImageView.image = #imageLiteral(resourceName: "upGreen")
            
            self.delegate?.openOffersOfRequest(self.request)
        } else {
            arrowImageView.image = #imageLiteral(resourceName: "downGreen")
            
            self.delegate?.closeOffersOfRequest(self.request)
        }
    }
    
    func rejectTapped() {
        cancelTapped()
    }
    
    func offerNewPriceTapped(newPrice: Int) {
        self.request.offerNewPriceTapped(newPrice: newPrice) { (responseObject, error) in
            if error == nil {
                self.request = responseObject as? Request
            }
        }
    }
    
    @objc func agreeTapped() {
        self.request.agreeTapped { (responseObject, error) in
            if error == nil {
                self.request = responseObject as? Request
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let rightOffset = CGPoint(x: self.scrollView.contentSize.width - self.scrollView.bounds.size.width, y:0)
                    self.scrollView.setContentOffset(rightOffset, animated: true)
                }
            }
        }
    }
    
    @objc func cancelTapped() {
        if self.request.req_type == .OPEN && User.currentRole != .client || self.request.isAbleToArchive() {
            self.request?.hideTapped(completion: { (responseObject, error) in
                if (error == nil) {
                    self.hideThisRequest()
                }
            })
        } else {
            self.request?.rejectTapped(completion: { (responseObject, error) in
                if (error == nil) {
                    self.hideThisRequest()
                }
            })
        }
    }
    
    func hideThisRequest() {
        let requestsVC = UIApplication.topViewController() as? RequestsListViewController
        let realtorRequestsVC = UIApplication.topViewController() as? RealtorRequestsViewController
        
        if let index = requestsVC?.dataSource.index(where: { (object) -> Bool in
            if let request = object as? Request {
                if request.request_id == self.request.request_id {
                    return true
                }
            }
            
            return false
        }) {
            requestsVC?.closeOffersOfRequest(request)
            requestsVC?.dataSource.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            requestsVC?.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        
        if let index = realtorRequestsVC?.allRequestsVC.dataSource.index(where: { (object) -> Bool in
            if let request = object as? Request {
                if request.request_id == self.request.request_id {
                    return true
                }
            }
            
            return false
        }) {
            realtorRequestsVC?.allRequestsVC.closeOffersOfRequest(request)
            realtorRequestsVC?.allRequestsVC.dataSource.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            realtorRequestsVC?.allRequestsVC.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        
        if let index = realtorRequestsVC?.myRequestsVC.dataSource.index(where: { (object) -> Bool in
            if let request = object as? Request {
                if request.request_id == self.request.request_id {
                    return true
                }
            }
            
            return false
        }) {
            realtorRequestsVC?.myRequestsVC.closeOffersOfRequest(request)
            realtorRequestsVC?.myRequestsVC.dataSource.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            realtorRequestsVC?.myRequestsVC.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func chatTapped() {
        if let chat_room = request.chat_room {
            let chatVC = ChatViewController()
            chatVC.hidesBottomBarWhenPushed = true

            chatVC.room = chat_room
            
            UIApplication.topViewController()?.navigationController?.pushViewController(chatVC, animated: true)
        } else {
            let infoView = ModalInfoView(titleText: "Чат недоступен", descriptionText: "Поле chat_room отсутствует")

            infoView.addButtonWithTitle("OK", action: {
                
            })
            
            infoView.show()
        }
        
    }
    
    func callTapped() {
        var phone:String = ""
        
        phone = request!.otherUser.phone!
        
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
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let leftSideOffsetToSnap:CGFloat = 50
        var middleOffsetToSnap:CGFloat = 124
        
        if request.req_type == .OPEN {
            if request.status == .COMPLETED {
                middleOffsetToSnap = (CGFloat(104) + Constants.screenFrame.size.width/2)
            } else {
                middleOffsetToSnap = 10000 //open request cannot be agreed
            }
        } else {
            if request.bargain == true {
                middleOffsetToSnap = (CGFloat(104) + Constants.screenFrame.size.width/2)
            } else {
                middleOffsetToSnap = CGFloat(124)
            }
        }
        
        if targetContentOffset.pointee.x < leftSideOffsetToSnap {
            targetContentOffset.pointee.x = 0
        } else if targetContentOffset.pointee.x > leftSideOffsetToSnap && targetContentOffset.pointee.x < middleOffsetToSnap {
            targetContentOffset.pointee.x = 104
        } else {
            targetContentOffset.pointee.x = 104 + Constants.screenFrame.size.width
        }
        
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        
        viewRequest()
    }
    
    func viewRequest() {
        if !self.requestCellView.unreadDotView.isHidden {
            RequestAPIManager.getSingleRequest(request_id: self.request.request_id!) { (requestObject, error) in
                self.request.client_viewed = true
                self.request.realtor_viewed = true
                self.requestCellView.unreadDotView.isHidden = true
            }
        }
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
