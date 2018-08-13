//
//  AddressPickerViewController.swift
//  Pillowz
//
//  Created by Samat on 17.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import GooglePlaces
import MBProgressHUD

public typealias SaveAddressWithAPIClosure = (_ address: String, _ lon: Double?, _ lat:Double?, _ placeID:String?) -> Void
public typealias DeleteAddressClosure = () -> Void

class AddressPickerViewController: ValidationViewController, AddressPickerDelegate, UITextFieldDelegate {
    let mapButton = UIButton()
    var lat:Double?
    var lon:Double?
    var placeID:String?
    
    let whereHeaderLabel = UILabel()
    
    var address:String = ""
    
    var saveAddressWithAPIClosure:SaveAddressWithAPIClosure?
    
    let tableView = UITableView()
    var recentPlaces:[[String:Any]] = []
    let recentPlacesHeaderLabel = UILabel()
    
    let addressPickerView = AddressPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.addSubview(whereHeaderLabel)
        whereHeaderLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-Constants.basicOffset*2)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(64 + 10)
        }
        whereHeaderLabel.textColor = Constants.paletteBlackColor
        whereHeaderLabel.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        whereHeaderLabel.text = "Где ищете жилье?"
        
        self.view.addSubview(addressPickerView)
        addressPickerView.snp.makeConstraints { (make) in
            make.top.equalTo(whereHeaderLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-Constants.basicOffset*2)
            make.height.equalTo(50)
        }
        addressPickerView.saveAddressWithAPIClosure = { (address, lat, lon, placeID) in
            self.address = address
            self.addressPickerView.text = address
            
            self.lat = lat
            self.lon = lon
            self.placeID = placeID
        }
        
        self.view.addSubview(mapButton)
        mapButton.snp.makeConstraints { (make) in
            make.top.equalTo(addressPickerView.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        mapButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 0)
        mapButton.titleLabel?.font = UIFont.init(name: "OpenSans-Light", size: 14)!
        mapButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
        mapButton.setImage(UIImage(named: "mapViolet"), for: .normal)
        mapButton.setTitle("На карте", for: .normal)
        mapButton.addTarget(self, action: #selector(openMapTapped), for: .touchUpInside)
        
        self.view.addSubview(recentPlacesHeaderLabel)
        recentPlacesHeaderLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-Constants.basicOffset*2)
            make.height.equalTo(20)
            make.top.equalTo(mapButton.snp.bottom).offset(10)
        }
        recentPlacesHeaderLabel.textColor = Constants.paletteBlackColor
        recentPlacesHeaderLabel.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        recentPlacesHeaderLabel.text = "Недавние запросы"
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
            make.top.equalTo(recentPlacesHeaderLabel.snp.bottom).offset(10)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        
        recentPlaces = User.getRecentPlaces()
        
        self.view.bringSubview(toFront: saveButton)
        
        if (self.address != "") {
            addressPickerView.text = self.address
        }
    }
    
    override func saveWithAPI() {
        User.addRecentPlace(["address":self.addressPickerView.text, "lat":lat!, "lon":lon!])
        
        saveAddressWithAPIClosure?(self.addressPickerView.text, lat, lon, placeID)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func isValid() -> Bool {
        if (self.addressPickerView.text=="" ||
            lat == nil ||
            lon == nil) {
            return false
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        dataChanged = true
        
        return true
    }
    
    
    @objc func openMapTapped() {
        let vc = MapAddressPickerViewController()
        
        if (self.lat != nil) {
            let coordinate = CLLocationCoordinate2DMake(self.lat!, self.lon!)
            vc.centerPosition = coordinate
        }
        
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didPickAddress(address: String, lat: Double, lon: Double) {
        self.address = address
        self.addressPickerView.text = address
        
        self.lat = lat
        self.lon = lon
        dataChanged = true
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

extension AddressPickerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        let place = recentPlaces[indexPath.row]
        
        cell.textLabel?.text = place["address"] as? String
        cell.textLabel?.textColor = Constants.paletteBlackColor
        cell.textLabel?.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = recentPlaces[indexPath.row]
        
        addressPickerView.text = place["address"] as! String
        lat = place["lat"] as? Double
        lon = place["lon"] as? Double
    }
}

