//
//  PhotoPicker.swift
//  Pillowz
//
//  Created by Samat on 03.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//
import UIKit
import TLPhotoPicker
import Photos
import MBProgressHUD

protocol PhotoPickerDelegate {
    var photoPicker:PhotoPicker! { get set }
    func didPickPhoto(image:UIImage)
    func didPickMultiplePhotos(images:[UIImage])
}
public typealias ImageLoadedCompletionBlock = (_ image:UIImage) -> Void

class PhotoPicker: NSObject, TLPhotosPickerViewControllerDelegate {
    var viewController:UIViewController!
    var delegate:PhotoPickerDelegate?
    var allowsMultiplePhotos: Bool = false
    
    init(viewController: UIViewController, allowsMultiplePhotos: Bool) {
        super.init()
        
        self.viewController = viewController
        self.delegate = viewController as? PhotoPickerDelegate
        
        self.allowsMultiplePhotos = allowsMultiplePhotos
        
        //configure.nibSet = (nibName: "CustomCell_Instagram", bundle: Bundle.main) // If you want use your custom cell..
    }
    
    func pickPhoto() {
//        let barButtonItemAppearance = UIBarButtonItem.appearance()
//        barButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)

        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == PHAuthorizationStatus.denied {
            openAlertForOpeningSettings()
        } else if status == PHAuthorizationStatus.restricted {
            openAlertForOpeningSettings()
        } else {
            let photoPickerViewController = TLPhotosPickerViewController()
            photoPickerViewController.delegate = self
            var configure = TLPhotosPickerConfigure()
            configure.allowedLivePhotos = false
            configure.allowedVideo = false
            configure.maxSelectedAssets = 9
            configure.allowedVideoRecording = false
            configure.singleSelectedMode = !allowsMultiplePhotos
            photoPickerViewController.configure = configure
            
            self.viewController.present(photoPickerViewController, animated: true, completion: nil)
        }
    }
    
    func openAlertForOpeningSettings() {
        let alert = UIAlertController(title: "Откройте доступ", message: "Pillowz нужен доступ в фотографиям", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.openSettingsToAllowPhotos()
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { action in
            
        }))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func openSettingsToAllowPhotos() {
        if let url = NSURL(string: UIApplicationOpenSettingsURLString) as URL? {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    //TLPhotosPickerViewControllerDelegate
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        let window = UIApplication.shared.delegate!.window!!
        
        MBProgressHUD.showAdded(to: window, animated: true)
        
        // use selected order, fullresolution image
        var images = [UIImage]()
        
        let downloadGroup = DispatchGroup()
        
        for asset in withTLPHAssets {
            downloadGroup.enter()

            self.getImage(phasset: asset) { (image) in
                downloadGroup.leave()
                
                images.append(image)
            }
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) { // 2
            MBProgressHUD.hide(for: window, animated: true)

            if (self.allowsMultiplePhotos) {
                self.delegate?.didPickMultiplePhotos(images: images)
            } else {
                if (images.count != 0) {
                    self.delegate?.didPickPhoto(image: images[0])
                }
            }
        }
    }
    
    func getImage(phasset: TLPHAsset?, completionBlock:@escaping ImageLoadedCompletionBlock) {
        guard let asset = phasset?.phAsset else {
            completionBlock(UIImage())
            
            let infoView = ModalInfoView(titleText: "Проблема с фотографией", descriptionText: "Что-то не то с форматом фотографий. Выберите другие фотографии.")
            
            infoView.addButtonWithTitle("OK", action: {
                
            })
            
            infoView.show()
            
            return
        }
        
        if let image = phasset!.fullResolutionImage {
            completionBlock(image)

            return
        }
        
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        options.version = .current
        options.resizeMode = .exact
        options.progressHandler = { (progress,error,stop,info) in
            //progressBlock(progress)
        }
        let _ = PHCachingImageManager().requestImageData(for: asset, options: options) { (imageData, dataUTI, orientation, info) in
            if let data = imageData,let _ = info {
                if let image = UIImage(data: data) {
                    completionBlock(image)
                } else {
                    self.showICloudAlert()
                    completionBlock(UIImage())
                }
            } else {
                self.showICloudAlert()
                completionBlock(UIImage())
            }
        }
    }
    
    func showICloudAlert() {
        let infoView = ModalInfoView(titleText: "Проблема с iCloud", descriptionText: "Не удалось загрузить фотографии с iCloud. Выберите другие фотографии, либо попробуйте выйти из iCloud и войти снова")
        
        infoView.addButtonWithTitle("OK", action: {
            
        })
        
        infoView.show()
    }
    
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
//        let barButtonItemAppearance = UIBarButtonItem.appearance()
//        barButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)

        // if you want to used phasset.
    }
    
    func photoPickerDidCancel() {
//        let barButtonItemAppearance = UIBarButtonItem.appearance()
//        barButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)

        // cancel
    }
    
    func dismissComplete() {
//        let barButtonItemAppearance = UIBarButtonItem.appearance()
//        barButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)

        // picker viewcontroller dismiss completion
    }
    
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        // exceed max selection
    }
}
