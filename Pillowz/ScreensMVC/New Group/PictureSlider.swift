//
//  PictureSlider.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 02.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD
import ImageViewer
import SDWebImage

struct DataItem {
    let imageView: UIImageView
    let galleryItem: GalleryItem
}

extension UIImageView: DisplaceableView {}

class PictureSlider: UIView, UIScrollViewDelegate {
    var space:Space! {
        didSet {
            self.setupImages(imagesArray: space.images!)
            self.numberOfImagesLabel.text = "/" + String(space.images!.count)
            if (space.images!.count==0) {
                self.currentImageIndex = 0
            }
            
            favorite = space.favourite!
            
            if (shouldUseImageViewer) {
                self.setupImageViewer()
            }
            
            
            let currentRentType:RENT_TYPES = UserLastUsedValuesForFieldAutofillingHandler.shared.rentType
            
            priceLabel.text = space.getSmallPricesTextForRentType(currentRentType)
            
            rentTypeLabel.text = Price.getDisplayNameForRentType(rent_type: currentRentType, isForPrice: false, isForSpaceView: true)["ru"]!

            let priceLabelWidth = priceLabel.text!.width(withConstraintedHeight: 20, font: priceLabel.font)
            let rentTypeLabelWidth = rentTypeLabel.text!.width(withConstraintedHeight: 20, font: rentTypeLabel.font)
            
            priceRentTypeLabelBackgroundView.snp.updateConstraints { (make) in
                make.width.equalTo(priceLabelWidth + rentTypeLabelWidth + 20 + 6 + 22)
            }
            
            if space.additional_features == "" {
                additionalFeaturesButton.isHidden = true
            } else {
                additionalFeaturesButton.isHidden = false
            }
        }
    }
    
    var shouldUseImageViewer = false
    
    var favorite:Bool! {
        didSet {
            let favoriteImage = (favorite) ? UIImage(named: "selectedFavorite") : UIImage(named: "unselectedFavorite")
            self.favoriteButton.setImage(favoriteImage, for: .normal)
        }
    }
    
    var items: [DataItem] = []
    var tapGestureRecognizers: [UITapGestureRecognizer] = []
    
    let priceTapGestureRecognizer = UITapGestureRecognizer()
    let priceRentTypeLabelBackgroundView = UIView()
    let priceLabel = UILabel()
    let rentTypeLabel = UILabel()
    let dropDownImageView = UIImageView()

    let scrollView = UIScrollViewSuperTaps()
    var imageViews:[UIImageView] = []
    
    let numberOfImagesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "OpenSans-Regular", size: 13)
        return label
    }()
    
    let currentImageIndexLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.paletteVioletColor
        label.font = UIFont(name: "OpenSans-SemiBold", size: 13)
        return label
    }()
    let favoriteButton = UIButton()
    var gradientImageView = UIImageView()
    
    var currentImageIndex:Int = 1 {
        didSet {
            currentImageIndexLabel.text = String(currentImageIndex)
        }
    }
    
    let additionalFeaturesButton = UIButton()
    
    var isHorizontalCollectionView = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(scrollView)
        scrollView.backgroundColor = .white
        scrollView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(Constants.spaceImageHeight)
        }
        scrollView.showsHorizontalScrollIndicator = false
        
        self.addSubview(gradientImageView)
        gradientImageView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Constants.spaceImageHeight)
        }
        gradientImageView.image = #imageLiteral(resourceName: "gradient")
        
        if User.isLoggedIn() {
            self.addSubview(favoriteButton)
            favoriteButton.backgroundColor = .clear
            favoriteButton.setImage(#imageLiteral(resourceName: "unselectedFavorite"), for: .normal)
            favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
            favoriteButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(scrollView).offset(-16)
                make.trailing.equalTo(scrollView).offset(-Constants.basicOffset)
                make.width.equalTo(28)
                make.height.equalTo(28)
            }
        }
        
        self.addSubview(numberOfImagesLabel)
        numberOfImagesLabel.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.bottom)
            make.centerX.equalToSuperview().offset(5)
        }
        
        self.addSubview(currentImageIndexLabel)
        currentImageIndexLabel.snp.makeConstraints { (make) in
            make.right.equalTo(numberOfImagesLabel.snp.left)
            make.bottom.equalTo(numberOfImagesLabel.snp.bottom)
        }
        
        self.addSubview(priceRentTypeLabelBackgroundView)
        priceRentTypeLabelBackgroundView.snp.makeConstraints { (make) in
            make.height.equalTo(28)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.bottom.equalToSuperview().offset(-12-15)
            make.width.equalTo(145)
        }
        priceRentTypeLabelBackgroundView.backgroundColor = .white
        priceRentTypeLabelBackgroundView.layer.cornerRadius = 5
        priceRentTypeLabelBackgroundView.clipsToBounds = true
        
        priceTapGestureRecognizer.addTarget(self, action: #selector(showPricesTapped))
        priceRentTypeLabelBackgroundView.addGestureRecognizer(priceTapGestureRecognizer)
        
        priceRentTypeLabelBackgroundView.addSubview(priceLabel)
        priceLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 15)!
        priceLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(100)
        }
        priceLabel.textColor = .black
        priceLabel.textAlignment = .left
        
        priceRentTypeLabelBackgroundView.addSubview(rentTypeLabel)
        rentTypeLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 10)!
        rentTypeLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(3)
            make.right.equalToSuperview().offset(-29)
            make.width.equalTo(100)
        }
        rentTypeLabel.textColor = Constants.paletteLightGrayColor
        rentTypeLabel.textAlignment = .right
        
        priceRentTypeLabelBackgroundView.addSubview(dropDownImageView)
        dropDownImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview().offset(2)
            make.width.equalTo(10)
            make.height.equalTo(5)
        }
        dropDownImageView.image = #imageLiteral(resourceName: "dropDown")
        
        self.addSubview(additionalFeaturesButton)
        additionalFeaturesButton.setImage(#imageLiteral(resourceName: "additionalFeatures"), for: .normal)
        additionalFeaturesButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.height.equalTo(30)
        }
        additionalFeaturesButton.isHidden = true
        additionalFeaturesButton.addTarget(self, action: #selector(openAdditionalFeatures), for: .touchUpInside)
    }
    
    @objc func openAdditionalFeatures() {
        let infoView = ModalInfoView(titleText: "Особенности жилья", descriptionText: space.additional_features)
        
        infoView.addButtonWithTitle("ОК", action: {

        })
        
        infoView.show()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        currentImageIndex = Int(page) + 1
    }
    
    @objc func didTapFavorite() {
        let window = UIApplication.shared.delegate!.window!!
        
        MBProgressHUD.showAdded(to: window, animated: true)
        
        let favorite = !space.favourite!
        
        SearchAPIManager.markSpace(space: space, asFavorite: favorite) { (spaceObject, error) in
            MBProgressHUD.hide(for: window, animated: true)
            
            if (error == nil) {
                self.favorite = favorite
                self.space.favourite = favorite
            }
        }
    }
    
    @objc func showPricesTapped() {
        guard var globalPoint = priceRentTypeLabelBackgroundView.superview?.convert(priceRentTypeLabelBackgroundView.frame.origin, to: nil) else {
            return
        }
        
        globalPoint.y = globalPoint.y + 30
        
        let pricesView = SpacePricesListView(space: space, point: globalPoint)
        let window = UIApplication.shared.keyWindow!
        window.addSubview(pricesView)
        pricesView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    func setupImages(imagesArray: Array<Image>?) {
        currentImageIndex = 1
        
        var currentX:CGFloat = 0
        let screenWidth = Constants.screenFrame.size.width
        
        for imageView in imageViews {
            imageView.removeFromSuperview()
        }
        imageViews = []
        
        for image in imagesArray! {
            let imageView = UIImageView()
            imageView.backgroundColor = .white
            imageView.contentMode = .scaleAspectFill
            self.scrollView.addSubview(imageView)
            imageView.snp.makeConstraints({ (make) in
                make.left.equalToSuperview().offset(currentX)
                make.top.equalToSuperview().offset(0)
                
                if (isHorizontalCollectionView) {
                    make.width.equalTo(Constants.oneSpaceWidthInHorizontalCollectionView)
                } else {
                    make.width.equalTo(screenWidth)
                }
                make.height.equalTo(300)
            })
            
            if (isHorizontalCollectionView) {
                currentX = currentX + Constants.oneSpaceWidthInHorizontalCollectionView
            } else {
                currentX = currentX + screenWidth
            }
            
            imageViews.append(imageView)
            
            imageView.sd_setImage(with: URL(string: image.image!), placeholderImage: UIImage())
        }
        
        let width = currentX
        
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: width, height: 150)
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
        
        //library crashed if first image is nil, so we need to do this
        if let image = items.first?.imageView.image, image.size.width != 0 {
            UIApplication.topViewController()?.presentImageGallery(galleryViewController)
        } else {
            DesignHelpers.makeToastWithText("Не удалось загрузить изображения")
        }
    }
    
    class func galleryConfiguration() -> GalleryConfiguration {
        
        return [
            
            GalleryConfigurationItem.closeButtonMode(.builtIn),
            
            GalleryConfigurationItem.pagingMode(.standard),
            GalleryConfigurationItem.presentationStyle(.displacement),
            GalleryConfigurationItem.hideDecorationViewsOnLaunch(false),
            
            GalleryConfigurationItem.swipeToDismissMode(.vertical),
            GalleryConfigurationItem.toggleDecorationViewsBySingleTap(false),
            GalleryConfigurationItem.activityViewByLongPress(false),
            
            GalleryConfigurationItem.overlayColor(UIColor(white: 0.035, alpha: 1)),
            GalleryConfigurationItem.overlayColorOpacity(1),
            GalleryConfigurationItem.overlayBlurOpacity(1),
            GalleryConfigurationItem.overlayBlurStyle(UIBlurEffectStyle.light),
            
            GalleryConfigurationItem.videoControlsColor(.white),
            
            GalleryConfigurationItem.maximumZoomScale(8),
            GalleryConfigurationItem.swipeToDismissThresholdVelocity(500),
            
            GalleryConfigurationItem.doubleTapToZoomDuration(0.15),
            
            GalleryConfigurationItem.blurPresentDuration(0.5),
            GalleryConfigurationItem.blurPresentDelay(0),
            GalleryConfigurationItem.colorPresentDuration(0.25),
            GalleryConfigurationItem.colorPresentDelay(0),
            
            GalleryConfigurationItem.blurDismissDuration(0.1),
            GalleryConfigurationItem.blurDismissDelay(0.4),
            GalleryConfigurationItem.colorDismissDuration(0.45),
            GalleryConfigurationItem.colorDismissDelay(0),
            
            GalleryConfigurationItem.itemFadeDuration(0.3),
            GalleryConfigurationItem.decorationViewsFadeDuration(0.15),
            GalleryConfigurationItem.rotationDuration(0.15),
            
            GalleryConfigurationItem.displacementDuration(0.55),
            GalleryConfigurationItem.reverseDisplacementDuration(0.25),
            GalleryConfigurationItem.displacementTransitionStyle(.springBounce(0.7)),
            GalleryConfigurationItem.displacementTimingCurve(.linear),
            
            GalleryConfigurationItem.statusBarHidden(true),
            GalleryConfigurationItem.displacementKeepOriginalInPlace(false),
            GalleryConfigurationItem.displacementInsetMargin(50)
        ]
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }

}

extension PictureSlider: GalleryDisplacedViewsDataSource {
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        return items[index].imageView
    }
}

extension PictureSlider: GalleryItemsDataSource {
    func itemCount() -> Int {
        return items.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        let urlString = space.images![index].image!
        let url = URL(string: urlString)
        
        return GalleryItem.image { callback in
            self.sd_internalSetImage(with: url, placeholderImage: nil, options: SDWebImageOptions.refreshCached, operationKey: nil, setImageBlock: { (image, date) in
                if image != nil {
                    callback(image)
                } else {
                    callback(UIImage())
                }
            }, progress: nil, completed: nil)
        }
    }
}

