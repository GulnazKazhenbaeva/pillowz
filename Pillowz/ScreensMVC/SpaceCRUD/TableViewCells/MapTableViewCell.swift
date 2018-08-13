//
//  MapTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 08.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import GoogleMaps

protocol MapTableViewCellDelegate {
    func openMapTapped()
}

class MapTableViewCell: HeaderIncludedTableViewCell {
    let mapView = MapView()
    let setAddressButton = UIButton()
    var delegate:MapTableViewCellDelegate?
    
    let centerPinView = UIImageView()
    let pillowzPinIcon = UIImageView()
    
    var space:Space! {
        didSet {
            setAddressButton.setTitle(space.getStringDistanceToCurrentUserLocation(), for: .normal)
        }
    }
    
    var shouldShowDistance = false {
        didSet {
            if (shouldShowDistance) {
                setAddressButton.setTitleColor(.lightGray, for: .normal)
                mapView.isUserInteractionEnabled = true
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(mapView)
        mapView.snp.makeConstraints { (make) in
            make.top.equalTo(headerLabel.snp.bottom).offset(16)
            make.height.equalTo(220)
            make.left.right.bottom.equalToSuperview()
        }
        mapView.isUserInteractionEnabled = false
        
        self.contentView.addSubview(setAddressButton)
        setAddressButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(headerLabel.snp.centerY)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        setAddressButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        setAddressButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
        setAddressButton.setTitle("Указать расположение", for: .normal)
        setAddressButton.addTarget(self, action: #selector(openMapTapped), for: .touchUpInside)
        setAddressButton.contentHorizontalAlignment = .right
        
        header = "На карте"
        
        
        mapView.addSubview(centerPinView)
        centerPinView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        //centerPinView.backgroundColor = .red
        centerPinView.fillImageView(image: #imageLiteral(resourceName: "pinBg"), color: Constants.paletteVioletColor) 
        centerPinView.contentMode = .scaleAspectFit
        
        centerPinView.addSubview(pillowzPinIcon)
        pillowzPinIcon.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        pillowzPinIcon.image = #imageLiteral(resourceName: "PillowzPinIcon")
        pillowzPinIcon.contentMode = .center
        
        //centerPinView.isHidden = false
    }
    
    @objc func openMapTapped() {
        delegate?.openMapTapped()
    }
    
    override func fillWithObject(object: AnyObject) {
        let dict = object as! [String:Any]
        
        let lat = dict["lat"] as! Double
        let lon = dict["lon"] as! Double
        
        if (dict["space"] != nil) {
            space = dict["space"] as! Space
        }
        
        
        if (lat != 0 && lon != 0) {
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 14)
            mapView.googleMapView.camera = camera
            
            //centerPinView.isHidden = false
            
            let position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let marker = GMSMarker(position: position)
            marker.title = "Объект"
            marker.iconView = centerPinView
            marker.tracksViewChanges = true
            marker.map = mapView.googleMapView
        }
        
        delegate = dict["VC"] as? MapTableViewCellDelegate
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
