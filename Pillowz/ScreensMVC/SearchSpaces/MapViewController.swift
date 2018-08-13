//
//  MapViewController.swift
//  Pillowz
//
//  Created by Samat on 01.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import GoogleMaps
import MBProgressHUD

let kClusterItemCount = 10000
let kCameraLatitude = 43.234235
let kCameraLongitude = 76.915326


class MapViewController: PillowzViewController, GMUClusterManagerDelegate, GMSMapViewDelegate, GMUClusterRendererDelegate {
    var spaces:[Space]! = []
    
    var recentlyLoadedSpaces:[Space]! = []
    
    private var clusterManager: GMUClusterManager!
    private var mapView: GMSMapView!
    
    var locationManager:MapLocationManager!
    
    var superViewController:SearchSpacesViewController! {
        didSet {
            horizontalSpacesList.superViewController = superViewController
        }
    }
    
    var ignoreMovingCameraAndDontLoadSpaces = false

    var tappedSpace:Space?
    var tappedCluster:GMUCluster?
    
    let horizontalSpacesList = HorizontalSpacesList()
    
    var searchFilterControlsView:SearchFilterControlsView!
    
    var isAllowedToGetSpaces = true
    var allowTimer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude, longitude: kCameraLongitude, zoom: 6.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView
        
        locationManager = MapLocationManager(mapView: mapView)
        
        // Set up the cluster manager with the supplied icon generator and
        // renderer.
        
        var numbers = [NSNumber(value: 2)]
        numbers.append(NSNumber(value: 5))
        numbers.append(NSNumber(value: 10))
        numbers.append(NSNumber(value: 20))
        numbers.append(NSNumber(value: 50))
        numbers.append(NSNumber(value: 100))
        numbers.append(NSNumber(value: 1000))
        
        let color = Constants.paletteVioletColor
        
        var colors = [UIColor]()
        for _ in numbers {
            colors.append(color)
        }
        
        let iconGenerator = GMUDefaultClusterIconGenerator(buckets: numbers, backgroundColors: colors)
        
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                           renderer: renderer)

        // Generate and add random items to the cluster manager.
        putClusterPins()

        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
        
        
        self.view.addSubview(horizontalSpacesList)
        horizontalSpacesList.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(-0)
            make.height.equalTo(Constants.oneSpaceWidthInHorizontalCollectionView*180/340 + 90 + 28 + 40)
        }
        horizontalSpacesList.isHidden = true
        horizontalSpacesList.spaceLoaderClosure = { () in
            self.loadDisplayingSpaces()
        }
        
        searchFilterControlsView = SearchFilterControlsView(superViewController: superViewController, isForMap: true)
        self.view.addSubview(searchFilterControlsView)
        searchFilterControlsView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        allowTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(allowToGetSpaces), userInfo: nil, repeats: true)
    }
    
    @objc func allowToGetSpaces() {
        isAllowedToGetSpaces = true
    }
    
    func searchSpaces() {
        if !isAllowedToGetSpaces {
            return
        }
        
        isAllowedToGetSpaces = false
        
        let visibleRegion = mapView.projection.visibleRegion()
                
        let polygonString = "(" +
            String(format: "%.6f", visibleRegion.farLeft.longitude) + " " + String(format: "%.6f", visibleRegion.farLeft.latitude) + "," +
            String(format: "%.6f", visibleRegion.farRight.longitude) + " " + String(format: "%.6f", visibleRegion.farRight.latitude) + "," +
            String(format: "%.6f", visibleRegion.nearRight.longitude) + " " + String(format: "%.6f", visibleRegion.nearRight.latitude) + "," +
            String(format: "%.6f", visibleRegion.nearLeft.longitude) + " " + String(format: "%.6f", visibleRegion.nearLeft.latitude) + "," +
            String(format: "%.6f", visibleRegion.farLeft.longitude) + " " + String(format: "%.6f", visibleRegion.farLeft.latitude) +
        ")"
        
        SearchAPIManager.searchSpaces(filter: superViewController.filter, limit: 200, page: 0, polygonString: polygonString, favourite: false, only_count:false, completion: { (responseObject, error) in
            if (error == nil) {
                let loadedSpaces = (responseObject as! [Any])[0] as! [Space]
                
                DispatchQueue.main.async {
                    for loadedSpace in loadedSpaces {
                        let contains = self.spaces.contains(where: { (space) -> Bool in
                            return space.space_id.intValue == loadedSpace.space_id.intValue
                        })
                        
                        if (!contains) {
                            self.recentlyLoadedSpaces.append(loadedSpace)
                            self.spaces.append(loadedSpace)
                        }
                    }
                    
                    self.putClusterPins()
                    
                    self.ignoreMovingCameraAndDontLoadSpaces = false
                }
            }
        })
    }
    
    func loadDisplayingSpaces() {
        horizontalSpacesList.displayingSpaces = []
        horizontalSpacesList.isHidden = false
        horizontalSpacesList.isLoading = true
        
        var visibleSpaces:[Space] = []

        if (tappedSpace != nil) {
            visibleSpaces.append(tappedSpace!)
        } else {
            for item in tappedCluster!.items {
                let pin = item as! ClusteringPin
                visibleSpaces.append(pin.space)
            }
        }
        
        var spaceIds:[Int] = []
        
        for space in visibleSpaces {
            spaceIds.append(space.space_id.intValue)
        }
        
        SpaceAPIManager.getSpacesByIds(spaceIds) { (spacesObject, error) in
            self.horizontalSpacesList.isLoading = false

            if (error == nil) {
                DispatchQueue.main.async {
                    self.horizontalSpacesList.displayingSpaces = spacesObject as! [Space]
                }
            } else {
                self.horizontalSpacesList.loadFailed = true
            }
        }        
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (ignoreMovingCameraAndDontLoadSpaces) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // do stuff 42 seconds later
                self.ignoreMovingCameraAndDontLoadSpaces = false
            }
            
            return
        }
        
        self.horizontalSpacesList.isHidden = true
        
        searchSpaces()
    }
    
    // MARK: - GMUClusterManagerDelegate
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        if (mapView.camera.zoom >= 13) {
            tappedSpace = nil
            tappedCluster = cluster
            
            ignoreMovingCameraAndDontLoadSpaces = true
            
            loadDisplayingSpaces()
        } else {
            let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                     zoom: 13)
            let update = GMSCameraUpdate.setCamera(newCamera)
            mapView.moveCamera(update)
        }
        
        return false
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        let pin = clusterItem as! ClusteringPin
        
        tappedSpace = pin.space
        tappedCluster = nil
        
        ignoreMovingCameraAndDontLoadSpaces = true

        loadDisplayingSpaces()
        
        return false
    }
    
     //MARK: - GMUMapViewDelegate
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        return false
    }
    
    // MARK: - Private
    /// Randomly generates cluster items within some extent of the camera and adds them to the
    /// cluster manager.
    private func putClusterPins() {
        if (recentlyLoadedSpaces == nil) {
            return
        }
        
        for space in recentlyLoadedSpaces {
            let lat = space.lat.doubleValue
            let lng = space.lon.doubleValue
            let name = "Space \(space.name)"
            let item = ClusteringPin(position: CLLocationCoordinate2DMake(lat, lng), name: name)
            item.space = space
            
            clusterManager.add(item)
        }

        // Call cluster() after items have been added to perform the clustering and rendering on map.
        clusterManager.cluster()
        
        recentlyLoadedSpaces = []
    }
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if marker.userData is ClusteringPin {
            //let pin = marker.userData as! ClusteringPin
            //marker.title = pin.name
            let priceLabel = UILabel()
            priceLabel.text = (marker.userData as! ClusteringPin).space.getSmallPricesTextForRentType(UserLastUsedValuesForFieldAutofillingHandler.shared.rentType)
            priceLabel.font = UIFont.init(name: "OpenSans-Bold", size: 14)!
            priceLabel.backgroundColor = Constants.paletteVioletColor
            priceLabel.layer.cornerRadius = 14.0
            priceLabel.textColor = .white
            priceLabel.clipsToBounds = true
            priceLabel.textAlignment = .center
            let width = priceLabel.text!.width(withConstraintedHeight: 28, font: priceLabel.font)+16
            priceLabel.frame = CGRect(x: 0, y: 0, width: width, height: 28)
            
            let x = width/2 - 16
            let bottomTriangleView = UIView()
            bottomTriangleView.frame = CGRect(x: x, y: -4, width: 32, height: 32)
            bottomTriangleView.backgroundColor = Constants.paletteVioletColor
            bottomTriangleView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/4))
            
            let pinView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 35))
            pinView.addSubview(bottomTriangleView)
            pinView.addSubview(priceLabel)
            
            
            marker.iconView = pinView
            marker.appearAnimation = .none
        } else if marker.userData is GMUCluster {
            marker.appearAnimation = .none
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
