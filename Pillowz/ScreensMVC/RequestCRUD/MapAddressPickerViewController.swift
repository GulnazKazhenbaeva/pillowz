//
//  SpaceGEOViewController.swift
//  Pillowz
//
//  Created by Samat on 13.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import GooglePlaces

protocol AddressPickerDelegate {
    func didPickAddress(address:String, lat:Double, lon:Double)
}

class MapAddressPickerViewController: StepViewController, UITextFieldDelegate, GMSMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    let addressTextField = UITextField()
    let cancelPickingAddressButton = UIButton()
    let addressTextFieldBackgroundView = UIView()
    
    var centerPosition:CLLocationCoordinate2D?
    
    let centerPinView = UIImageView()
    let pillowzPinIcon = UIImageView()
    
    let placesClient = GMSPlacesClient()
    let filter = GMSAutocompleteFilter()
    
    var delegate:AddressPickerDelegate?
    var locationManager:MapLocationManager!
    private var mapView: GMSMapView!
    
    let addressesTableView = UITableView()
    
    var addresses:[GMSAutocompletePrediction] = []
    
    let addressLabelBackgroundView = UIView()
    let addressSearchImageView = UIImageView()
    let addressLabel = UILabel()
    let addressTextLabel = UILabel()
    let changeAddressTapGestureRecognizer = UITapGestureRecognizer()
    
    var isEditingSpace = false
    
    let doneButton = PillowzButton()
    
    var isAllowedToGetNewGeocodingValue = true
    var allowTimer:Timer!
    
    var canChangeAddress = true
    
    
    var didChooseFromGooglePlaces = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        filter.type = .address
        
        self.title = "Расположение объекта"
        
        let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude, longitude: kCameraLongitude, zoom: 12.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        self.view.addSubview(mapView)
        mapView.delegate = self
        mapView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
        }
        
        self.view.addSubview(addressLabelBackgroundView)
        addressLabelBackgroundView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(9)
            make.left.equalToSuperview().offset(6)
            make.right.equalToSuperview().offset(-6)
            make.height.equalTo(58)
        }
        addressLabelBackgroundView.layer.cornerRadius = 5
        addressLabelBackgroundView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        addressLabelBackgroundView.dropShadow()
        
        self.view.addSubview(addressTextFieldBackgroundView)
        addressTextFieldBackgroundView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.height.equalTo(50)
        }
        addressTextFieldBackgroundView.backgroundColor = .white
        addressTextFieldBackgroundView.isHidden = true
        
        addressTextFieldBackgroundView.addSubview(addressTextField)
        addressTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-44-12)
            make.height.equalTo(50)
        }
        addressTextField.delegate = self
        addressTextField.backgroundColor = .white
        addressTextField.addTarget(self, action: #selector(addressTextChanged), for: .editingChanged)
        addressTextField.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        addressTextField.textColor = Constants.paletteBlackColor
        
        addressTextFieldBackgroundView.addSubview(cancelPickingAddressButton)
        cancelPickingAddressButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(44)
            make.width.equalTo(30)
        }
        cancelPickingAddressButton.setImage(#imageLiteral(resourceName: "clear"), for: .normal)
        cancelPickingAddressButton.addTarget(self, action: #selector(cancelPickingAddress), for: .touchUpInside)
        
        self.view.addSubview(centerPinView)
        centerPinView.snp.makeConstraints { (make) in
            make.centerX.equalTo(mapView.snp.centerX)
            make.centerY.equalTo(mapView.snp.centerY).offset(-25)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        centerPinView.fillImageView(image: #imageLiteral(resourceName: "pinBg"), color: Constants.paletteVioletColor)
        centerPinView.contentMode = .bottom
        
        centerPinView.addSubview(pillowzPinIcon)
        pillowzPinIcon.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        pillowzPinIcon.image = #imageLiteral(resourceName: "PillowzPinIcon")
        pillowzPinIcon.contentMode = .center
        
        if (centerPosition != nil) {
            locationManager.shouldUpdateCamera = false
            mapView.camera = GMSCameraPosition.camera(withTarget: centerPosition!, zoom: 14)
        }
        
        self.view.addSubview(addressesTableView)
        addressesTableView.snp.makeConstraints { (make) in
            make.top.equalTo(addressTextField.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        addressesTableView.dataSource = self
        addressesTableView.delegate = self
        addressesTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        addressesTableView.backgroundColor = .white
        addressesTableView.isHidden = true
        addressesTableView.tableFooterView = UIView()

        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        
        addressLabelBackgroundView.addSubview(addressSearchImageView)
        addressSearchImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(33)
            make.left.equalToSuperview().offset(9)
        }
        addressSearchImageView.image = #imageLiteral(resourceName: "addressSearch")
        
        
        addressLabelBackgroundView.addSubview(addressTextLabel)
        addressTextLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(6)
            make.height.equalTo(20)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        addressTextLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 17)!
        addressTextLabel.textColor = Constants.paletteVioletColor
        addressTextLabel.textAlignment = .center
        addressTextLabel.text = "АДРЕС"
        
        
        addressLabelBackgroundView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-2)
            make.height.equalTo(30)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        addressLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 15)!
        addressLabel.textColor = Constants.paletteBlackColor
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 1
        addressLabel.adjustsFontSizeToFitWidth = true
        
        changeAddressTapGestureRecognizer.addTarget(self, action: #selector(changeAddressTapped))

        addressLabelBackgroundView.addGestureRecognizer(changeAddressTapGestureRecognizer)
        addressLabelBackgroundView.isUserInteractionEnabled = true
        
        self.view.bringSubview(toFront: addressTextField)
        
        locationManager = MapLocationManager(mapView: mapView)

        if (isEditingSpace) {
            locationManager.shouldUpdateCamera = false
            
            if SpaceEditorManager.sharedInstance.lat != 0 && SpaceEditorManager.sharedInstance.lon != 0 {
                addressLabel.text = SpaceEditorManager.sharedInstance.address
                
                mapView.camera = GMSCameraPosition.camera(withLatitude: SpaceEditorManager.sharedInstance.lat, longitude: SpaceEditorManager.sharedInstance.lon, zoom: 14)
            }
            
            canChangeAddress = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.canChangeAddress = true
            }
        } else {
            locationManager.shouldUpdateCamera = true
            
            self.view.addSubview(doneButton)
            PillowzButton.makeBasicButtonConstraints(button: doneButton, pinToTop: false)
            doneButton.setTitle("Готово", for: .normal)
            doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        }
        
        allowTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(allowToMakeGeocodingRequest), userInfo: nil, repeats: true)
    }
    
    @objc func cancelPickingAddress() {
        let shouldShowAddressesTableView = false
        
        self.addressTextFieldBackgroundView.isHidden = !shouldShowAddressesTableView
        self.addressesTableView.isHidden = !shouldShowAddressesTableView
        self.addressLabel.isHidden = shouldShowAddressesTableView
        
        self.addressTextField.resignFirstResponder()
    }
    
    @objc func allowToMakeGeocodingRequest() {
        isAllowedToGetNewGeocodingValue = true
    }
    
    @objc func doneTapped() {
        if let centerPosition = self.centerPosition {
            self.didPickAddress(address: self.addressTextField.text!, lat: centerPosition.latitude, lon: centerPosition.longitude)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func checkIfAllFieldsAreFilled() -> Bool {
        return true
    }
    
    @objc func changeAddressTapped() {
        if let spaceCRUDVC = SpaceEditorManager.sharedInstance.spaceCRUDVC, spaceCRUDVC.isPublished && !spaceCRUDVC.shouldSendToModerationWhileEditing {
            let infoView = ModalInfoView(titleText: "Изменение этих данных отправит объект недвижимости на модерацию", descriptionText: "Вы уверены, что хотите изменить данные об объекте недвижимости?")
            
            infoView.addButtonWithTitle("Да", action: {
                self.openAddressesList()
                SpaceEditorManager.sharedInstance.spaceCRUDVC!.shouldSendToModerationWhileEditing = true
            })
            
            infoView.addButtonWithTitle("Отмена", action: {

            })
            
            infoView.show()
            
            return
        }
        
        openAddressesList()
    }
    
    func openAddressesList() {
        let shouldShowAddressesTableView = true
        
        self.addressTextFieldBackgroundView.isHidden = !shouldShowAddressesTableView
        self.addressesTableView.isHidden = !shouldShowAddressesTableView
        self.addressLabel.isHidden = shouldShowAddressesTableView
        
        self.addressTextField.becomeFirstResponder()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if let spaceCRUDVC = SpaceEditorManager.sharedInstance.spaceCRUDVC, spaceCRUDVC.isPublished && !spaceCRUDVC.shouldSendToModerationWhileEditing {
            let infoView = ModalInfoView(titleText: "Изменение этих данных отправит объект недвижимости на модерацию", descriptionText: "Вы уверены, что хотите изменить данные об объекте недвижимости?")
            
            infoView.addButtonWithTitle("Да", action: {
                SpaceEditorManager.sharedInstance.spaceCRUDVC!.shouldSendToModerationWhileEditing = true
            })
            
            infoView.addButtonWithTitle("Отмена", action: {
                spaceCRUDVC.nextTapped()
            })
            
            infoView.show()
            
            return
        }
        
        centerPosition = position.target
        
        if !isAllowedToGetNewGeocodingValue || didChooseFromGooglePlaces {
            return
        }
        
        self.isAllowedToGetNewGeocodingValue = false

        SVGeocoder.reverseGeocode(centerPosition!) { (placemarks, response, error) in            
            if (error == nil) {
                if placemarks!.count != 0 {
                    let placemark = placemarks![0] as! SVPlacemark

                    self.addressLabel.text = placemark.formattedAddress
                    
                    if let thoroughfare = placemark.thoroughfare, let subThoroughfare = placemark.subThoroughfare {
                        self.addressTextField.text = thoroughfare + " " + subThoroughfare
                    } else {
                        self.addressTextField.text = placemark.formattedAddress
                    }
                    
                    self.didPickAddress(address: self.addressTextField.text!, lat: self.centerPosition!.latitude, lon: self.centerPosition!.longitude)
                }
            }
        }
    }
    
    func didPickAddress(address: String, lat:Double, lon:Double) {
        if !canChangeAddress {
            return
        }
        
        SpaceEditorManager.sharedInstance.address = address
        SpaceEditorManager.sharedInstance.lat = lat
        SpaceEditorManager.sharedInstance.lon = lon
        
        SpaceEditorManager.sharedInstance.spaceCRUDVC?.nextButton.isEnabled = true
        SpaceEditorManager.sharedInstance.spaceCRUDVC?.nextButton.backgroundColor = UIColor(hexString: "#FA533C")
        
        self.delegate?.didPickAddress(address: address, lat: lat, lon: lon)
    }
    
    @objc func addressTextChanged() {
        if let centerPosition = self.centerPosition {
            self.didPickAddress(address: self.addressTextField.text!, lat: centerPosition.latitude, lon: centerPosition.longitude)
        }
        
        placesClient.autocompleteQuery(self.addressTextField.text!, bounds: nil, filter: nil, callback: {(results, error) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            
            if let results = results {
                self.addresses.removeAll()

                for result in results {
                    self.addresses.append(result)
                    
                    //print("Result \(result.attributedFullText) with placeID \(result.placeID)")
                }

                if (self.addresses.count != 0) {
                    self.addressesTableView.reloadData()
                } else {

                }
            }
        })
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = addresses[indexPath.row].attributedPrimaryText.string
        cell.textLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 15)
        cell.textLabel?.textColor = Constants.paletteBlackColor
            
        cell.detailTextLabel?.text = addresses[indexPath.row].attributedSecondaryText?.string
        cell.detailTextLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 13)
        cell.detailTextLabel?.textColor = .lightGray

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let placeID = addresses[indexPath.row].placeID {
            placesClient.lookUpPlaceID(placeID) { (place, error) in
                if let place = place {
                    self.addressTextField.text = self.addresses[indexPath.row].attributedPrimaryText.string
                    self.addressLabel.text = self.addresses[indexPath.row].attributedPrimaryText.string

                    self.mapView.camera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: 14)
                    
                    let shouldShowAddressesTableView = false
                    
                    self.addressTextFieldBackgroundView.isHidden = !shouldShowAddressesTableView
                    self.addressesTableView.isHidden = !shouldShowAddressesTableView
                    self.addressLabel.isHidden = shouldShowAddressesTableView
                    
                    self.addressTextField.resignFirstResponder()
                    
                    self.didChooseFromGooglePlaces = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.didChooseFromGooglePlaces = false
                    }
                } else {
                    
                }
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
