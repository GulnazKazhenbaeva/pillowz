////
////  EditProfileViewController.swift
////  Pillowz
////
////  Created by Samat on 30.11.2017.
////  Copyright © 2017 Samat. All rights reserved.
////
//
//import UIKit
//import MBProgressHUD
//
//class UserProfileViewController: ValidationViewController, PhotoPickerDelegate, DatePickerTableViewCellDelegate, SocialNetworksPickerViewDelegate, ListPickerViewControllerDelegate, ComplainTableViewCellDelegate, ReviewTableViewCellDelegate, RealtorSpacesTableViewCellDelegate {
//    var fields:[Field] = []
//    var headers:[String] = []
//    let crudVM = CreateEditObjectTableViewGenerator()
//    var photoPicker: PhotoPicker!
//
//    let languagesField = Field()
////    let countryField = Field()
//    let birthdayField = Field()
//    let genderField = Field()
//
//    let birthdayTextField = UITextField()
//    
//    var chosenLanguageId:Int?
//    
//    let dateFormatter = DateFormatter()
//    
//    var profileFields:[Field] = []
//    
//    //for other user profile
//    var user_id:Int!
//    var user:User! {
//        didSet {
//            generateFields()
//        }
//    }
//    
//    let topBackButton = UIButton()
//    let topGradient = UIImageView()
//    
//    var horizontalSpacesList:HorizontalSpacesList!
//    var spaceLoaderClosure:SpaceLoaderClosure!
//    var superViewControllerForHorizontalSpacesList:UIViewController!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//        dateFormatter.dateFormat = "dd MMM yyyy"
//        
//        photoPicker = PhotoPicker(viewController: self, allowsMultiplePhotos: false)
//
//        crudVM.viewController = self
//        crudVM.options = ["userDescription":"longText"]
//        
//        if (user_id == nil) {
//            user = User.shared
//        } else {
//            loadUser()
//        }
//        
//        self.view.addSubview(topBackButton)
//        topBackButton.snp.makeConstraints { (make) in
//            make.left.equalToSuperview()
//            make.top.equalToSuperview().offset(20)
//            make.width.height.equalTo(44)
//        }
//        topBackButton.setImage(#imageLiteral(resourceName: "backWhite"), for: .normal)
//        topBackButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
//        topBackButton.isHidden = (user_id == nil)
//        if (user_id != nil) {
//            crudVM.tableView.snp.updateConstraints({ (make) in
//                make.top.equalToSuperview().offset(20)
//                make.bottom.equalToSuperview().offset(-49)
//            })
//            
//            crudVM.disableTextFields = true
//            
//            self.view.addSubview(topGradient)
//            topGradient.snp.makeConstraints({ (make) in
//                make.top.left.right.equalToSuperview()
//                make.height.equalTo(64)
//            })
//            topGradient.image = #imageLiteral(resourceName: "appbar_gradient")
//            
//            self.view.bringSubview(toFront: topBackButton)
//        }
//        
//        if (user_id == nil) {
//            self.view.bringSubview(toFront: saveButton)
//        }
//        
//        superViewControllerForHorizontalSpacesList = self
//        spaceLoaderClosure = { () in
//            self.loadRealtorSpaces()
//        }
//    }
//    
//    @objc func backTapped() {
//        self.navigationController?.popViewController(animated: true)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        if (user_id != nil) {
//            self.navigationController?.navigationBar.isHidden = true
//        }
//    }
//    
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        if (user_id != nil) {
//            self.navigationController?.navigationBar.isHidden = false
//        }
//    }
//    
//    func loadUser() {
//        MBProgressHUD.showAdded(to: self.view, animated: true)
//
//        AuthorizationAPIManager.getUserInfo(user_id: user_id) { (userObject, error) in
//            MBProgressHUD.hide(for: self.view, animated: true)
//
//            if (error == nil) {
//                self.user = userObject as! User
//            } else {
//                
//            }
//        }
//    }
//    
//    func generateFields() {
//        languagesField.type = "ChoiceField"
//        languagesField.param_name = "Языки"
//        languagesField.multiLanguageName = ["ru": "Языки", "en":"Языки"]
//        
//        var languagesText = ""
//
//        if (CategoriesHandler.sharedInstance.languages.count == 0) {
//            
//        } else {
//            for languageString in user.languages! {
//                for language in CategoriesHandler.sharedInstance.languages {
//                    if (language.name == "") {
//                        
//                    }
//                }
//                
//                languagesText = languagesText + languageString + ", "
//            }
//            languagesText = String(languagesText.dropLast(2))
//            languagesField.setCustomText(text: languagesText)
//        }
//        
//        
//        if (user_id != nil && languagesText == "") {
//            languagesField.setCustomText(text: "Не указано")
//        }
//
//        languagesField.didSelectClosure = { () in
//            var languages:[Language] = []
//
//            if (CategoriesHandler.sharedInstance.languages.count == 0) {
//                HelpersAPIManager.getLanguages(completion: { (languagesObject, error) in
//                    if (error == nil) {
//                        languages = languagesObject as! [Language]
//                        
//                        let listPickerVC = ListPickerViewController()
//                        listPickerVC.values = languages
//                        listPickerVC.delegate = self
//                        listPickerVC.allowsMultipleSelection = true
//                        
//                        self.navigationController?.pushViewController(listPickerVC, animated: true)
//                    }
//                })
//            } else {
//                languages = CategoriesHandler.sharedInstance.languages
//                
//                let listPickerVC = ListPickerViewController()
//                listPickerVC.values = languages
//                listPickerVC.delegate = self
//                listPickerVC.allowsMultipleSelection = true
//                
//                self.navigationController?.pushViewController(listPickerVC, animated: true)
//            }
//        }
//        
////        countryField.type = "ChoiceField"
////        countryField.param_name = "country"
////        countryField.multiLanguageName = ["ru": "Страна", "en":"Страна"]
////        if (user.country!.iso != nil) {
////            countryField.value = user.country!.iso!
////            countryField.setCustomText(text: user.country!.name!)
////        }
////        countryField.didSelectClosure = { () in
////            var CHECK_HERE_IF_THERE_ARE_SOME_COUNTRIES:String
////
////            let vc = ListPickerViewController()
////            vc.values = CategoriesHandler.sharedInstance.countries
////            vc.delegate = self
////            self.navigationController?.pushViewController(vc, animated: true)
////        }
//        
//
//        
//        
//        let shouldShowUserProfile = (User.currentRole == .client || user.realtor == nil || user.realtor?.rtype == .agent || user.realtor?.rtype == .owner)
//        
//        if (shouldShowUserProfile) {
//            let (fieldsOfProfile, profileHeaders) = CategoriesHandler.getFieldsOfObject(object: user, shouldControlObject: false, shouldFillEmptyValues: (user_id != nil))
//            fields = fieldsOfProfile
//            headers = profileHeaders
//            
//            for field in fields {
//                if (field.param_name == "userDescription") {
//                    field.param_name = "description"
//                }
//            }
//            
//            if (user_id == nil) {
//                let uploadPhotoField = Field()
//                uploadPhotoField.isCustomCellField = true
//                uploadPhotoField.customCellObject = self
//                uploadPhotoField.customCellClassString = "UploadPhotoTableViewCell"
//                fields.insert(uploadPhotoField, at: 0)
//                headers.insert("", at: 0)
//            } else {
//                let profileInfoField = Field()
//                profileInfoField.isCustomCellField = true
//                profileInfoField.customCellObject = user
//                profileInfoField.customCellClassString = "ProfileInfoTableViewCell"
//                fields.insert(profileInfoField, at: 0)
//                headers.insert("", at: 0)
//            }
//            
//            genderField.type = "ChoiceField"
//            genderField.param_name = "gender"
//            genderField.multiLanguageName = ["ru": "Пол", "en":"Пол"]
//            if (user.gender != nil) {
//                genderField.setCustomText(text: User.getDisplayNameForGender(gender: user.gender!)["ru"]!)
//            }
//            
//            if (user_id != nil && user.gender == nil) {
//                genderField.setCustomText(text: "Не указано")
//            }
//            
//            genderField.didSelectClosure = { () in
//                var genderFields:[Field] = []
//                
//                for gender in Gender.allValues {
//                    let listGenderField = Field()
//                    listGenderField.value = String(gender.rawValue)
//                    listGenderField.multiLanguageName = User.getDisplayNameForGender(gender: gender)
//                    
//                    genderFields.append(listGenderField)
//                }
//                
//                let listPickerVC = ListPickerViewController()
//                listPickerVC.values = genderFields
//                listPickerVC.delegate = self
//                
//                self.navigationController?.pushViewController(listPickerVC, animated: true)
//            }
//            fields.insert(genderField, at: 3)
//            headers.insert("Пол", at: 3)
//            
//            birthdayField.isCustomCellField = true
//            birthdayField.customCellObject = self
//            birthdayField.customCellClassString = "DatePickerTableViewCell"
//            birthdayField.param_name = "birthday"
//            if (user.birthday != nil) {
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "dd.MM.yyyy"
//
//                birthdayField.value = dateFormatter.string(from: Date(timeIntervalSince1970: Double(user.birthday!)))
//                
//                let dateString = birthdayField.value
//                
//                birthdayField.setCustomText(text: dateString)
//            }
//            
//            if (user_id != nil && user.birthday == nil) {
//                birthdayField.setCustomText(text: "Не указано")
//            }
//            
//            birthdayField.multiLanguageName = ["ru":"Дата рождения", "en":"Дата рождения"]
//            fields.insert(birthdayField, at: 4)
//            headers.insert("Дата рождения", at: 4)
//            
//            fields.insert(languagesField, at: 6)
//            headers.insert("Языки", at: 6)
//            
//            //fields.insert(countryField, at: 7)
//            //headers.insert("Страна", at: 7)
//
//            if (user.isRealtor()) {
//                let rtypeField = Field()
//                rtypeField.param_name = "rtype"
//                rtypeField.value = String(user.realtor!.rtype!.rawValue)
//                profileFields.append(rtypeField)
//                
//                if (user.realtor!.rtype! == .owner || user.realtor!.rtype! == .agent && user_id == nil) {
//                    let personIDField = Field()
//                    personIDField.param_name = "person_id"
//                    personIDField.multiLanguageName = ["ru": "ИИН", "en":"ИИН"]
//                    personIDField.value = user.realtor!.person_id!
//                    personIDField.didPickFieldValueClosure = { (newValue) in
//                        let person_id = newValue as! String
//                        personIDField.value = person_id
//                    }
//                    personIDField.type = "CharField"
//                    fields.append(personIDField)
//                    headers.append("ИИН")
//                    
//                    profileFields.append(personIDField)
//                }
//                
//                if (user.realtor!.rtype! == .agent && user_id == nil) {
//                    let uploadPhotosField = Field()
//                    uploadPhotosField.isCustomCellField = true
//                    uploadPhotosField.customCellObject = ["VC":self, "Space":nil, "certificates":user.realtor!.certificates] as AnyObject
//                    uploadPhotosField.customCellClassString = "PhotosTableViewCell"
//                    fields.append(uploadPhotosField)
//                    headers.append("")
//                }
//            }
//        } else {
//            let (fieldsOfRealtor, realtorHeaders) = CategoriesHandler.getFieldsOfObject(object: user.realtor!, shouldControlObject: false)
//            fields = fieldsOfRealtor
//            headers = realtorHeaders
//            
//            let uploadPhotoField = Field()
//            uploadPhotoField.isCustomCellField = true
//            uploadPhotoField.customCellObject = self
//            uploadPhotoField.customCellClassString = "UploadPhotoTableViewCell"
//            fields.insert(uploadPhotoField, at: 0)
//            headers.insert("", at: 0)
//            
//            fields.insert(languagesField, at: 3)
//            headers.insert("Языки", at: 3)
//            
//            let rtypeField = Field()
//            rtypeField.param_name = "rtype"
//            rtypeField.value = String(user.realtor!.rtype!.rawValue)
//            profileFields.append(rtypeField)
//            profileFields.append(contentsOf: fields)
//            
//            if (user_id == nil) {
//                let uploadPhotosField = Field()
//                uploadPhotosField.isCustomCellField = true
//                uploadPhotosField.customCellObject = ["VC":self, "Space":nil, "certificates":user.realtor!.certificates] as AnyObject
//                uploadPhotosField.customCellClassString = "PhotosTableViewCell"
//                fields.append(uploadPhotosField)
//                headers.append("")
//            }
//        }
//        
//        if (user_id == nil) {
//            let socialNetworksField = Field()
//            socialNetworksField.isCustomCellField = true
//            socialNetworksField.customCellObject = self
//            socialNetworksField.customCellClassString = "AttachedSocialNetworksTableViewCell"
//            fields.append(socialNetworksField)
//            headers.append("Мои страницы")
//        }
//        
//        if (user_id != nil) {
//            let complainField = Field()
//            complainField.isCustomCellField = true
//            complainField.customCellObject = self
//            complainField.customCellClassString = "ComplainTableViewCell"
//            fields.append(complainField)
//            headers.append("")
//            
//            
//            let reviewField = Field()
//            reviewField.isCustomCellField = true
//            
//            if (user.reviews?.count == 0) {
//                reviewField.customCellObject = "Отзывы отсутствуют" as AnyObject
//                reviewField.customCellClassString = "HeaderIncludedTableViewCell"
//            } else {
//                reviewField.customCellObject = self
//                reviewField.customCellClassString = "ReviewTableViewCell"
//            }
//            fields.append(reviewField)
//            headers.append("")
//            
//            if (user.isRealtor()) {
//                let reviewField = Field()
//                reviewField.isCustomCellField = true
//                reviewField.customCellObject = self
//                reviewField.customCellClassString = "RealtorSpacesTableViewCell"
//                fields.append(reviewField)
//                headers.append("")
//            }
//        }
//        
//        crudVM.headers = headers
//        crudVM.object = fields as AnyObject
//    }
//    
//    func didPickDate(date: Date) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd.MM.yyyy"
//
//        birthdayField.value = dateFormatter.string(from: date)
//        birthdayField.setCustomText(text: dateFormatter.string(from: date))
//    }
//    
//    func socialNetworkTapped(socialNetwork: SocialNetworkLinks) {
//        if (socialNetwork == .vkontakte) {
//            
//        } else if (socialNetwork == .instagram) {
//            
//        } else if (socialNetwork == .google) {
//            
//        } else if (socialNetwork == .facebook) {
//            
//        }
//    }
//    
//    override func saveWithAPI() {
//        MBProgressHUD.showAdded(to: self.view, animated: true)
//
//        AuthorizationAPIManager.updateClientProfile(profileFields: fields) { (userObject, error) in
//            if (error == nil) {
//                if (self.user.isRealtor()) {
//                    AuthorizationAPIManager.updateRealtorProfile(profileFields: self.profileFields, completion: { (userObject, error) in
//                        MBProgressHUD.hide(for: self.view, animated: true)
//                        
//                        if (error == nil) {
//                            
//                        }
//                        
//                    })
//                } else {
//                    MBProgressHUD.hide(for: self.view, animated: true)
//                }
//            }
//        }
//    }
//    
//    func didPickValue(_ value: AnyObject) {
//        if (value is Country) {
////            user.country = value as? Country
////            self.countryField.value = user.country!.iso!
////            self.countryField.setCustomText(text: user.country!.name!)
//        } else {
//            let chosenGenderField = value as! Field
//            self.genderField.value = chosenGenderField.value
//            self.genderField.setCustomText(text: (value as! Field).name!)
//        }
//    }
//    
//    func didPickMultipleValues(_ values: [AnyObject]) {
//        AuthorizationAPIManager.updateLanguages(languages: values as! [Language]) { (profileObject, error) in
//            if (error == nil) {
//                var totalString = ""
//                
//                for value in values {
//                    let language = value as! Language
//                    
//                    totalString = totalString + language.name + ", "
//                }
//                
//                totalString = String(totalString.dropLast(2))
//                
//                self.languagesField.setCustomText(text: totalString)
//            }
//        }
//    }
//    
//    override func isValid() -> Bool {
//        return true
//    }
//    
//    func didPickPhoto(image: UIImage) {
//        MBProgressHUD.showAdded(to: self.view, animated: true)
//        
//        AuthorizationAPIManager.uploadAvatar(image: image) { (userObject, error) in
//            MBProgressHUD.hide(for: self.view, animated: true)
//            
//            if (error == nil) {
//                let cell = self.crudVM.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! UploadPhotoTableViewCell
//                cell.fillWithObject(object: self)
//            }
//        }
//    }
//
//    func didPickMultiplePhotos(images: [UIImage]) {
//        
//    }
//    
//    func complainTapped() {
//        let vc = CreateFeedbackViewController()
//        
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    func showAllReviewsTapped() {
//        let vc = ReviewsViewController()
//        vc.reviews = user.reviews!
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    func loadRealtorSpaces() {
//        self.horizontalSpacesList.isLoading = true
//        
//        SpaceAPIManager.getRealtorSpaces(user_id: user.user_id!) { (spacesObject, error) in
//            self.horizontalSpacesList.isLoading = false
//
//            if (error == nil) {
//                DispatchQueue.main.async {
//                    self.horizontalSpacesList.displayingSpaces = spacesObject as! [Space]
//                    self.horizontalSpacesList.cell?.header = String(self.horizontalSpacesList.displayingSpaces.count) + " объектов"
//                }
//            } else {
//                self.horizontalSpacesList.loadFailed = true
//            }
//        }
//    }
//    
//    func openUserWithId(_ userId: Int) {
//        let profileVC = UserProfileViewController()
//        profileVC.user_id = userId
//        self.navigationController?.pushViewController(profileVC, animated: true)
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
