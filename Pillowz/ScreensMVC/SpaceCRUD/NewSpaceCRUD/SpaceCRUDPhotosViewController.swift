//
//  SpaceCRUDPhotosViewController.swift
//  Pillowz
//
//  Created by Samat on 04.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

class SpaceCRUDPhotosViewController: StepViewController, PhotoPickerDelegate, PhotosEditorViewDelegate {
    var photoPicker: PhotoPicker!
    
    let photosEditorView = PhotosEditorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.addSubview(photosEditorView)
        photosEditorView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        photosEditorView.space = SpaceEditorManager.sharedInstance.currentEditingSpace
        photosEditorView.viewController = self
        photosEditorView.delegate = self
        
        photoPicker = PhotoPicker(viewController: self, allowsMultiplePhotos: true)
        
        let _ = self.checkIfAllFieldsAreFilled()
    }
    
    override func checkIfAllFieldsAreFilled() -> Bool {
        SpaceEditorManager.sharedInstance.spaceCRUDVC!.nextButton.backgroundColor = Constants.paletteLightGrayColor
        
        var filled = true
        
        if SpaceEditorManager.sharedInstance.currentEditingSpace.images!.count < 4 {
            filled = false
        }
        
        SpaceEditorManager.sharedInstance.spaceCRUDVC!.nextButton.isEnabled = filled
        
        if filled {
            SpaceEditorManager.sharedInstance.spaceCRUDVC!.nextButton.backgroundColor = UIColor(hexString: "#FA533C")
        }
        
        return filled
    }
    
    func deleteImageTapped(_ image_id: Int) {
        let window = UIApplication.shared.delegate!.window!!

        MBProgressHUD.showAdded(to: window, animated: true)

        SpaceAPIManager.deleteSpaceImage(space_id: SpaceEditorManager.sharedInstance.currentEditingSpace.space_id.intValue, image_id: image_id) { (responseObject, error) in
            MBProgressHUD.hide(for: window, animated: true)
            
            if error == nil {
                var deletedImageIndex:Int!
                
                for image in SpaceEditorManager.sharedInstance.currentEditingSpace.images! {
                    if image_id == image.image_id {
                        deletedImageIndex = SpaceEditorManager.sharedInstance.currentEditingSpace.images!.index(of: image)!
                    }
                }
                
                SpaceEditorManager.sharedInstance.currentEditingSpace.images!.remove(at: deletedImageIndex)
                self.photosEditorView.space = SpaceEditorManager.sharedInstance.currentEditingSpace
                
                self.photosEditorView.collectionView.reloadData()
                
                let _ = self.checkIfAllFieldsAreFilled()
            }
        }
    }
    
    func didPickPhoto(image: UIImage) {
        
    }
    
    func didPickMultiplePhotos(images: [UIImage]) {
        if (images.count == 0) {
            return
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        SpaceAPIManager.uploadPhotos(images: images, toSpace: SpaceEditorManager.sharedInstance.currentEditingSpace!) { (imagesArray, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if (error == nil) {
                self.photosEditorView.space = SpaceEditorManager.sharedInstance.currentEditingSpace
                
                let _ = self.checkIfAllFieldsAreFilled()
            }
        }
    }
}
