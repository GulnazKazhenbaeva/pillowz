//
//  PhotosTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 01.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage
import ImageViewer

class PhotosTableViewCell: UITableViewCell, FillableCellDelegate, SpacePhotosCollectionViewCellDelegate {
    var collectionView: UICollectionView! = nil
    fileprivate var longPressGesture: UILongPressGestureRecognizer!

    var viewController:UIViewController!
    var space:Space? {
        didSet {
            if (space != nil) {
                self.images = space!.images!
            }
        }
    }
    
    var certificates:[Certificate]? {
        didSet {
            if (certificates != nil) {
                var images = [Image]()
                
                for certificate in certificates! {
                    let image = Image()
                    image.image = certificate.certificate_url
                    
                    images.append(image)
                }
                
                self.images = images
            }
        }
    }
    
    var images:[Image]! = [] {
        didSet {
            self.collectionView.reloadData()
            
            self.setupImageViewer()
        }
    }
    
    var imagesAfterSwapBeforeSavedToBackend:[Image] = []
    
    var items: [DataItem] = []
    var tapGestureRecognizers: [UITapGestureRecognizer] = []
    
    var imageViews:[UIImageView]! = []
        
    func fillWithObject(object: AnyObject) {
        let dict = object as! [String:Any]
        viewController = dict["VC"] as! UIViewController
        space = dict["Space"] as? Space
        certificates = dict["certificates"] as? [Certificate]
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 5
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: flowLayout)
        collectionView.register(SpacePhotosCollectionViewCell.self, forCellWithReuseIdentifier: "SpacePhotosCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        self.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
            make.height.equalTo(80)
        }
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPressGesture)
    }

    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    func pickPhotoTapped() {
        let vc = viewController as! PhotoPickerDelegate
        vc.photoPicker.pickPhoto()
    }
    
    func setupImageViewer() {
        tapGestureRecognizers = []
        items = []
        
        for imageView in imageViews {
            if (imageView.gestureRecognizers != nil) {
                for recognizer in imageView.gestureRecognizers! {
                    imageView.removeGestureRecognizer(recognizer)
                }
            }
            
            let image = imageView.image ?? UIImage()
            
            var galleryItem: GalleryItem!
            
            galleryItem = GalleryItem.image { $0(image) }
            
            items.append(DataItem(imageView: imageView, galleryItem: galleryItem))
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showGalleryImageViewer(_:)))
            imageView.addGestureRecognizer(tapGestureRecognizer)
            imageView.isUserInteractionEnabled = true
            
            tapGestureRecognizers.append(tapGestureRecognizer)
        }
    }
    
    @objc func showGalleryImageViewer(_ sender: UITapGestureRecognizer) {
        guard let displacedView = sender.view as? UIImageView else { return }
        
        guard let displacedViewIndex = items.index(where: { $0.imageView == displacedView }) else { return }
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: items.count)
        let footerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: items.count)
        
        let galleryViewController = GalleryViewController(startIndex: displacedViewIndex, itemsDataSource: self, itemsDelegate: nil, displacedViewsDataSource: self, configuration: PictureSlider.galleryConfiguration())
        galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView
        
        galleryViewController.launchedCompletion = { print("LAUNCHED") }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }
        
        galleryViewController.landedPageAtIndexCompletion = { index in
            print("LANDED AT INDEX: \(index)")
            
            headerView.count = self.items.count
            headerView.currentIndex = index
            footerView.count = self.items.count
            footerView.currentIndex = index
        }
        
        UIApplication.topViewController()?.presentImageGallery(galleryViewController)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
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

extension PhotosTableViewCell: GalleryDisplacedViewsDataSource {
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        return items[index].imageView
    }
}

extension PhotosTableViewCell: GalleryItemsDataSource {
    func itemCount() -> Int {
        return items.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        if let urlString = self.images[index].image {
            let url = URL(string: urlString)
            
            return GalleryItem.image { callback in
                self.sd_internalSetImage(with: url, placeholderImage: nil, options: SDWebImageOptions.refreshCached, operationKey: nil, setImageBlock: { (image, date) in
                    callback(image)
                }, progress: nil, completed: nil)
            }
        } else {
            return items[index].galleryItem
        }
    }
}

extension PhotosTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpacePhotosCollectionViewCell", for: indexPath) as! SpacePhotosCollectionViewCell

        if (indexPath.row == images.count) {
            cell.delegate = self
            cell.image = nil
        } else {
            cell.image = images[indexPath.item]
        }
        
        self.imageViews.append(cell.spaceImageView)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: collectionView.frame.size.height - 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if (indexPath.row == images.count) {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if (sourceIndexPath.item == images.count || destinationIndexPath.item == images.count) {
            collectionView.reloadData()
            
            return
        }
        
        imagesAfterSwapBeforeSavedToBackend = images
        
        let element = imagesAfterSwapBeforeSavedToBackend.remove(at: sourceIndexPath.item)
        imagesAfterSwapBeforeSavedToBackend.insert(element, at: destinationIndexPath.item)
        
        print("Starting Index: \(sourceIndexPath.item)")
        print("Ending Index: \(destinationIndexPath.item)")
        
        saveImages()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func saveImages() {
        SpaceAPIManager.saveImages(imagesAfterSwapBeforeSavedToBackend, toSpace: self.space!) { (responseObject, error) in
            if error == nil {
                self.images = responseObject as! [Image]
            } else {
                
            }
            
            self.collectionView.reloadData()
        }
    }
}

