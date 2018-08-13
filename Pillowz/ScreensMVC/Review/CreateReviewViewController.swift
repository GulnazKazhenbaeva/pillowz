//
//  CreateReviewViewController.swift
//  Pillowz
//
//  Created by Samat on 15.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD
import XLPagerTabStrip

class CreateReviewViewController: PillowzViewController, UITableViewDelegate, UITableViewDataSource, SetRatingViewDelegate, IndicatorInfoProvider {
    var itemInfo: IndicatorInfo!

    let tableView = UITableView()
    let sendButton = PillowzButton()
    
    var isUser = false
    
    var request:Request! {
        didSet {
            user_id = request.user!.user_id!
            space_id = request.space!.space_id.intValue
        }
    }
    var user_id:Int!
    var space_id:Int!
    
    var content:[String] = []
    
    var text = ""
    var ratingValue = 1
    
    var superVC:UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserTableViewCell.classForCoder(), forCellReuseIdentifier: "user")
        tableView.register(RequestTableViewCell.classForCoder(), forCellReuseIdentifier: "space")
        tableView.register(HeaderTextTableViewCell.classForCoder(), forCellReuseIdentifier: "infoBlack")
        tableView.register(HeaderTextTableViewCell.classForCoder(), forCellReuseIdentifier: "infoGray")
        tableView.register(SetRatingTableViewCell.classForCoder(), forCellReuseIdentifier: "rating")
        tableView.register(LongTextTableViewCell.classForCoder(), forCellReuseIdentifier: "reviewTextField")
        tableView.register(EmptyTableViewCell.classForCoder(), forCellReuseIdentifier: "empty")
        tableView.separatorColor = UIColor(white: 0.0, alpha: 0.0)
        
        tableView.estimatedRowHeight = 120
        tableView.tableFooterView = UIView()

        self.view.addSubview(sendButton)
        PillowzButton.makeBasicButtonConstraints(button: sendButton, pinToTop: false)
        sendButton.addTarget(self, action: #selector(sendReviewTapped), for: .touchUpInside)
        sendButton.setTitle("Отправить", for: .normal)
        
//        if (isUser) {
//            content.append("user")
//        } else {
//            content.append("space")
//        }
        content.append("infoBlack")
        content.append("infoGray")
        content.append("rating")
        content.append("reviewTextField")
        content.append("empty")
    }
    
    @objc func sendReviewTapped() {
        if let user_id = user_id {
            ReviewAPIManager.leaveUserReview(text, value: ratingValue, user_id: user_id, completion: { (responseObject, error) in
                if (error == nil) {
                    DesignHelpers.makeToastWithText("Отзыв оставлен")

                    self.superVC.navigationController?.popViewController(animated: true)
                }
            })
        } else if let space_id = space_id {
            ReviewAPIManager.leaveSpaceReview(text, value: ratingValue, space_id: space_id, completion: { (responseObject, error) in
                if (error == nil) {
                    DesignHelpers.makeToastWithText("Отзыв оставлен")

                    self.superVC.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let showingCellContent = content[indexPath.row]
        
        let cell = getCellForCellContent(showingCellContent)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func getCellForCellContent(_ showingCellContent:String) -> UITableViewCell {
        if (showingCellContent == "user") {
            let cell = tableView.dequeueReusableCell(withIdentifier: showingCellContent) as! UserTableViewCell
            
            if let user = request?.user {
                cell.user = user
            }
            
            return cell
        } else if (showingCellContent == "space") {
            let cell = tableView.dequeueReusableCell(withIdentifier: showingCellContent) as! RequestTableViewCell
            
            if let request = request {
                cell.request = request
            }
            
            return cell
        } else if (showingCellContent == "infoBlack") {
            let cell = tableView.dequeueReusableCell(withIdentifier: showingCellContent) as! HeaderTextTableViewCell
            
            cell.headerTextLabel.font = UIFont.init(name: "OpenSans-Regular", size: 14)!
            cell.headerTextLabel.textColor = Constants.paletteBlackColor
            cell.headerText = "Найдите пару минут свободного времени и оставьте свой отзыв об этом владельце! Пишите отзывы максимально объективно и по существу. Не будьте слишком категоричны и эмоциональны, расскажите о видимых плюсах и минусах при работе с владельцем."
            
            cell.headerTextLabel.snp.updateConstraints({ (make) in
                make.top.equalToSuperview().offset(4)
                make.bottom.equalToSuperview().offset(-4)
            })
            
            return cell
        } else if (showingCellContent == "infoGray") {
            let cell = tableView.dequeueReusableCell(withIdentifier: showingCellContent) as! HeaderTextTableViewCell
            
            cell.headerTextLabel.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
            cell.headerTextLabel.textColor = UIColor(white: 0, alpha: 0.3)
            cell.headerText = "Все отзывы проходят модерацию. Отзывы содержащие оскорбления и нецензурные выражения, комментарии коммерческого и рекламного характера, а также малосодержательные отзывы будут удалены администрацией сервиса. Администрация сервисаоставляет за собой право исправлять орфографические и грамматические ошибки."
            
            cell.headerTextLabel.snp.updateConstraints({ (make) in
                make.top.equalToSuperview().offset(4)
                make.bottom.equalToSuperview().offset(-4)
            })

            return cell
        } else if (showingCellContent == "rating") {
            let cell = tableView.dequeueReusableCell(withIdentifier: showingCellContent) as! SetRatingTableViewCell
            
            cell.header = "Рейтинг"
            
            cell.setRatingView.delegate = self
            
            return cell
        } else if (showingCellContent == "reviewTextField") {
            let cell = tableView.dequeueReusableCell(withIdentifier: showingCellContent) as! LongTextTableViewCell
            
            cell.header = "Отзыв"
            cell.placeholder = "Напишите Ваш отзыв о владельце"
            cell.initialValue = ""
            cell.didPickValueClosure = { (newValue) in
                self.text = newValue as! String
            }
            
            return cell
        } else if (showingCellContent == "empty") {
            let cell = tableView.dequeueReusableCell(withIdentifier: showingCellContent) as! EmptyTableViewCell
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func didPickRatingValue(_ value: Int) {
        ratingValue = value
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
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
