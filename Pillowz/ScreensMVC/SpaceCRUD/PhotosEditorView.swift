//
//  PhotosEditorView.swift
//  Pillowz
//
//  Created by Samat on 04.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage
import ImageViewer
import MBProgressHUD

protocol PhotosEditorViewDelegate {
    func deleteImageTapped(_ image_id:Int)
}

class PhotosEditorView: UIView, SpacePhotosCollectionViewCellDelegate, GalleryImageTopViewDelegate {
    var collectionView: UICollectionView! = nil
    fileprivate var longPressGesture: UILongPressGestureRecognizer!

    var delegate:PhotosEditorViewDelegate?
    
    var viewController:UIViewController!
    var space:Space? {
        didSet {
            if (space != nil) {
                self.images = space!.images!
                
                if self.space!.images!.count >= 4 {
                    self.minimalNumberOfPhotosLabel.isHidden = true
                }
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.setupImageViewer()
            }
        }
    }
    
    var imagesAfterSwapBeforeSavedToBackend:[Image] = []
    
    var items: [DataItem] = []
    var tapGestureRecognizers: [UITapGestureRecognizer] = []
    
    var imageViews:[UIImageView]! = []
    
    var currentOpenedGalleryImage:Int!
    
    var galleryViewController:GalleryViewController!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let minimalNumberOfPhotosLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 5
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: flowLayout)
        collectionView.register(SpacePhotosCollectionViewCell.self, forCellWithReuseIdentifier: "SpacePhotosCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPressGesture)
        
        
        self.addSubview(minimalNumberOfPhotosLabel)
        minimalNumberOfPhotosLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.bottom.equalToSuperview().offset(-60)
            make.height.equalTo(250)
        }
        minimalNumberOfPhotosLabel.textColor = Constants.paletteLightGrayColor
        minimalNumberOfPhotosLabel.font = UIFont.init(name: "OpenSans-Regular", size: 15)!
        minimalNumberOfPhotosLabel.text = "Добавьте фотографии. Покажите свое жилье с лучшей стороны! Для этого загрузите минимум 4 фотографии.\n\nСовет: Чем привлекательнее фотографии вашего жилья, тем больше гостей захотят в нем жить. Подумайте о качестве и правильном освещении. Фотографировать лучше из угла."
        minimalNumberOfPhotosLabel.numberOfLines = 0
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
        if let spaceCRUDVC = SpaceEditorManager.sharedInstance.spaceCRUDVC, spaceCRUDVC.isPublished {
            let infoView = ModalInfoView(titleText: "Изменение этих данных отправит объект недвижимости на модерацию", descriptionText: "Вы уверены, что хотите изменить данные об объекте недвижимости?")
            
            infoView.addButtonWithTitle("Да", action: {
                let vc = self.viewController as! PhotoPickerDelegate
                vc.photoPicker.pickPhoto()
            })
            
            infoView.addButtonWithTitle("Отмена", action: {
                
            })
            
            infoView.show()
            
            return
        }
        
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
        
        let frame = CGRect(x: 0, y: 0, width: Constants.screenFrame.size.width, height: 44)
        let headerView = GalleryImageTopView(frame: frame)
        headerView.delegate = self
        let footerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: items.count)
        
        galleryViewController = GalleryViewController(startIndex: displacedViewIndex, itemsDataSource: self, itemsDelegate: nil, displacedViewsDataSource: self, configuration: PictureSlider.galleryConfiguration())
        galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView
        
        galleryViewController.launchedCompletion = { print("LAUNCHED") }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }
        
        galleryViewController.landedPageAtIndexCompletion = { index in
            print("LANDED AT INDEX: \(index)")
            
            self.currentOpenedGalleryImage = index
            
            footerView.count = self.items.count
            footerView.currentIndex = index
        }
        
        UIApplication.topViewController()?.presentImageGallery(galleryViewController)
    }
    
    func deleteImageTapped() {
        galleryViewController.dismiss(animated: true, completion: nil)
        
        let image = images[currentOpenedGalleryImage]
        
        delegate?.deleteImageTapped(image.image_id)
    }

    func didPickMultiplePhotos(images: [UIImage]) {
        if (images.count == 0) {
            return
        }
        
        MBProgressHUD.showAdded(to: self.viewController.view, animated: true)
        
        SpaceAPIManager.uploadPhotos(images: images, toSpace: SpaceEditorManager.sharedInstance.currentEditingSpace!) { (imagesArray, error) in
            MBProgressHUD.hide(for: self.viewController.view, animated: true)
            
            if (error == nil) {
                //let cell = self.crudVM.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PhotosTableViewCell
                self.space = SpaceEditorManager.sharedInstance.currentEditingSpace!
                
                if self.space!.images!.count >= 4 {
                    self.minimalNumberOfPhotosLabel.isHidden = true
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotosEditorView: GalleryDisplacedViewsDataSource {
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        return items[index].imageView
    }
}

extension PhotosEditorView: GalleryItemsDataSource {
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

extension PhotosEditorView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpacePhotosCollectionViewCell", for: indexPath) as! SpacePhotosCollectionViewCell
        
        if (indexPath.row == 0) {
            cell.delegate = self
            cell.image = nil
        } else {
            self.imageViews.append(cell.spaceImageView)

            cell.image = images[indexPath.item-1]
        }        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if (indexPath.row == 0) {
            return false
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if (sourceIndexPath.item == 0 || destinationIndexPath.item == 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Your code with delay
                collectionView.reloadData()
            }
            
            return
        }
        
        imagesAfterSwapBeforeSavedToBackend = images
        
        let element = imagesAfterSwapBeforeSavedToBackend.remove(at: sourceIndexPath.item-1)
        imagesAfterSwapBeforeSavedToBackend.insert(element, at: destinationIndexPath.item-1)
        
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
