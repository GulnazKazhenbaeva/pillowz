//
//  UploadCertificatePage.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 11/3/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

protocol UploadCertificatePageDelegate {
    func didUploadCertificates(_ certificates:[Certificate])
}

class UploadCertificatePage: PillowzViewController, PhotoPickerDelegate {
    let imageView = UIImageView()
    let pickImageButton = PillowzButton()
    var photoPicker: PhotoPicker!
    let guideLabel: UILabel = {
        let label = UILabel()
        label.text = "Загрузите сюда ваше свидетельство о\nгосударственной регистрации в формате\nPDF,MS Word, JPEG"
        label.numberOfLines = 3
        label.textAlignment = .center
        label.textColor = UIColor.black.withAlphaComponent(0.54)
        label.font = UIFont.init(name: "OpenSans-Light", size: 14)!
        return label
    }()
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .red
        return tableView
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(Constants.paletteVioletColor, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.layer.borderColor = Constants.paletteVioletColor.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.backgroundColor = Constants.paletteVioletColor
        button.layer.borderColor = Constants.paletteVioletColor.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    var delegate:UploadCertificatePageDelegate?
    
    var certificates:[Certificate] = []
    
    override func loadView() {
        super.loadView()
        setupViews()
//        view.addSubview(pickImageButton)
//        pickImageButton.setTitle("Upload", for: .normal)
//        pickImageButton.addTarget(self, action: #selector(uploadPhoto), for: .touchUpInside)
//        pickImageButton.snp.makeConstraints { (make) in
//            make.center.equalToSuperview()
//        }
//
//        view.addSubview(imageView)
//        imageView.snp.makeConstraints { (make) in
//            make.bottom.equalTo(pickImageButton.snp.top).offset(-20)
//            make.centerX.equalToSuperview()
//            make.height.width.equalTo(200)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Upload Page"
        view.backgroundColor = .white 
        
        photoPicker = PhotoPicker(viewController: self, allowsMultiplePhotos: false)
        setupNavigationBar()
        view.backgroundColor = Constants.paletteLightGrayColor
        photoPicker.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CertificateTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(CertificateTableViewCell.self))
        //certificates.append("Svidetelstvo.pdf")
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func uploadPhoto() {
        photoPicker.pickPhoto()
    }
    
    @objc func uploadCertficate() {
        //TO DO: Upload certificate request
        print("Hey, it works")
    }
    
    func didPickPhoto(image: UIImage) {
        imageView.image = image
    }
    
    func didPickMultiplePhotos(images: [UIImage]) {
        AuthorizationAPIManager.getCertificateId(certificates: images) { responseObject, error  in
            if (error == nil) {
                self.delegate?.didUploadCertificates(responseObject as! [Certificate])
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension UploadCertificatePage: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return certificates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CertificateTableViewCell.self)) as! CertificateTableViewCell
        cell.name = String(certificates[indexPath.row].certificate_id!)
        cell.selectionStyle = .none
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchView.onTintColor = Constants.paletteVioletColor
        switchView.tag = indexPath.row
        cell.accessoryView = switchView
        return cell
    }
}

extension UploadCertificatePage {
    func setupNavigationBar() {
        let tlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        tlabel.text = "Свидет. о гос. регистрации"
        tlabel.font = UIFont.init(name: "OpenSans-Regular", size: 16)!
        tlabel.adjustsFontSizeToFitWidth = true
        self.navigationItem.titleView = tlabel
        
        let addButton = UIBarButtonItem(image: UIImage.init(named: "plus")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(uploadPhoto))
        navigationItem.rightBarButtonItem = addButton
    }
    func setupViews() {
        view.addSubview(guideLabel)
        guideLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(104)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(54)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(guideLabel.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-59)
            make.left.equalToSuperview().offset(55)
            make.width.equalToSuperview().multipliedBy(0.25)
            make.height.equalToSuperview().multipliedBy(0.0625)
        }
        view.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-59)
            make.right.equalToSuperview().offset(-55)
            make.width.equalToSuperview().multipliedBy(0.25)
            make.height.equalToSuperview().multipliedBy(0.0625)
        }
    }
    func setupDataViewSubviews() {
        
    }
}
