//
//  UploadPhotoTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 01.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import ImageViewer
import SDWebImage

class UploadPhotoTableViewCell: UITableViewCell, FillableCellDelegate {
    let profileImageView = UIImageView()
    let uploadImageButton = UIButton()
    
    var profileViewController:UserProfileViewController!
    var tapGestureRecognizer:UITapGestureRecognizer!

    var items: [DataItem] = []

    func fillWithObject(object: AnyObject) {
        profileViewController = object as! UserProfileViewController
        
        if (User.shared.avatar != nil) {
            profileImageView.sd_setImage(with: URL(string: User.shared.avatar!), placeholderImage: UIImage())
            profileImageView.contentMode = .scaleAspectFill
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.basicOffset)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo((Constants.screenFrame.size.width-2*Constants.basicOffset)/310*190)
            make.bottom.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showGalleryImageViewer(_:)))
        profileImageView.backgroundColor = UIColor(hexString: "#F0F0F0")
        profileImageView.clipsToBounds = true
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        profileImageView.isUserInteractionEnabled = true
        
        let image = profileImageView.image ?? UIImage()

        var galleryItem: GalleryItem!
        galleryItem = GalleryItem.image { $0(image) }
        items.append(DataItem(imageView: profileImageView, galleryItem: galleryItem))


        let shouldShowUserProfile = (User.shared.realtor == nil || User.shared.realtor?.rtype == .agent || User.shared.realtor?.rtype == .owner)
        
        if (shouldShowUserProfile) {
            profileImageView.image = #imageLiteral(resourceName: "emptyPhoto")
        } else {
            profileImageView.image = #imageLiteral(resourceName: "emptyOrganization")
        }
        profileImageView.contentMode = .center
        
        self.contentView.addSubview(uploadImageButton)
        uploadImageButton.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageView.snp.top)
            make.right.equalTo(profileImageView.snp.right)
            make.width.height.equalTo(50)
        }
        uploadImageButton.setImage(UIImage(named: "addPhoto"), for: .normal)
        uploadImageButton.addTarget(self, action: #selector(pickPhotoTapped), for: .touchUpInside)
        
    }

    @objc func pickPhotoTapped() {
        let vc = profileViewController as! PhotoPickerDelegate
        vc.photoPicker.pickPhoto()
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

extension UploadPhotoTableViewCell: GalleryDisplacedViewsDataSource {
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        return items[index].imageView
    }
}

extension UploadPhotoTableViewCell: GalleryItemsDataSource {
    func itemCount() -> Int {
        return items.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        let urlString = profileViewController.user.avatar!
        let url = URL(string: urlString)
        
        return GalleryItem.image { callback in
            self.sd_internalSetImage(with: url, placeholderImage: nil, options: SDWebImageOptions.refreshCached, operationKey: nil, setImageBlock: { (image, date) in
                callback(image)
            }, progress: nil, completed: nil)
        }
    }
}

