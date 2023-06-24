//
//  CorrectAccountViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 29.05.2021.
//

import UIKit
import AVFoundation

class CorrectAccountViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var avatarHeight: NSLayoutConstraint!
    @IBOutlet weak var avatarWidth: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var changeAvatarButton: UIButton!
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    @IBOutlet weak var deleteDateButton: UIButton!
    @IBOutlet weak var privatBirthdayButton: UIButton!
    @IBOutlet weak var permissionBirthdayLabel: UILabel!
    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var privatCountryCityButton: UIButton!
    @IBOutlet weak var permissionCountryCityLabel: UILabel!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var privatPublicTagsButton: UIButton!
    @IBOutlet weak var permissionPublicTagsLabel: UILabel!
    @IBOutlet weak var privatTagsButton: UIButton!
    @IBOutlet weak var permissionPrivatTagsLabel: UILabel!
    @IBOutlet weak var privatAchievementsButtom: UIButton!
    @IBOutlet weak var permissionAchievements: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var nameNotice: UILabel!
    @IBOutlet weak var nicknameNotice: UILabel!
    @IBOutlet weak var passwordNotice: UILabel!
    @IBOutlet weak var repeatNotice: UILabel!
    
    @IBOutlet weak var nicknameConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordConstraint: NSLayoutConstraint!
    @IBOutlet weak var repeatConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    let selectFeedback = UISelectionFeedbackGenerator()
    
    var everyoneBirthday: UIAction?
    var onlyFriendsBirthday: UIAction?
    var onlyMeBirthday: UIAction?
    
    var everyoneCountry: UIAction?
    var onlyFriendsCountry: UIAction?
    var onlyMeCountry: UIAction?
    
    var everyonePublicTags: UIAction?
    var onlyFriendsPublicTags: UIAction?
    
    var onlyFriendsPrivatTags: UIAction?
    var onlyMePrivatTags: UIAction?
    
    var everyoneAchievements: UIAction?
    var onlyFriendsAchievements: UIAction?
    
    var keyboardHeigth: CGFloat = 0.0
    
    var userAccount = personalInfo.userAccount!
    var avatarImage: UIImage?
    var isAvatarChanged = false
    
    var notificationView: UIView?
    var pickerController: UIImagePickerController?
    
    var birthdayString: String = ""
    
    private var willBeDeinited: Bool = true
    
    var showingPassword1: Bool = false
    var showingPassword2: Bool = false
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        willBeDeinited = true
        
        nameTF.isEnabled = false
        nameTF.text = personalInfo.emailAddress
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if willBeDeinited {
            notificationView?.removeFromSuperview()
            notificationView = nil
            userNameField.delegate = nil
            nicknameField.delegate = nil
            countryField.delegate = nil
            cityField.delegate = nil
            passwordField.delegate = nil
            repeatPasswordField.delegate = nil
            pickerController?.delegate = nil
            pickerController = nil
        }
    }
    
    // MARK: - Setup Scene
    
    func setupScene() {
        
        self.view.layoutSubviews()
        self.scrollView.layoutSubviews()
        self.avatarView.layoutSubviews()
        
        avatarWidth.constant = avatarView.frame.size.width * 0.52
        avatarHeight.constant = avatarWidth.constant
        
        selectFeedback.prepare()
        
        let tapToClose = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tapToClose)
        
        scrollViewBottom.isActive = false
        scrollViewBottom = scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: globalVariables.bottomScreenLength)
        scrollViewBottom.isActive = true
        
        avatarView.layer.cornerRadius = 16
        Helpers().addShadow(view: avatarView)
        mainView.layer.cornerRadius = 16
        Helpers().addShadow(view: mainView)
        privacyView.layer.cornerRadius = 16
        Helpers().addShadow(view: privacyView)
        
        userAvatar.layer.masksToBounds = true
        userAvatar.layer.cornerRadius = 20
        changeAvatarButton.layer.cornerRadius = 21
        Helpers().addShadow(view: changeAvatarButton)
        
        userNameField.layer.masksToBounds = true
        userNameField.layer.cornerRadius = 12
        privatBirthdayButton.layer.masksToBounds = true
        privatBirthdayButton.layer.cornerRadius = 12
        nicknameField.layer.masksToBounds = true
        nicknameField.layer.cornerRadius = 12
        countryField.layer.masksToBounds = true
        countryField.layer.cornerRadius = 12
        cityField.layer.masksToBounds = true
        cityField.layer.cornerRadius = 12
        privatCountryCityButton.layer.masksToBounds = true
        privatCountryCityButton.layer.cornerRadius = 12
        passwordField.layer.masksToBounds = true
        passwordField.layer.cornerRadius = 12
        repeatPasswordField.layer.masksToBounds = true
        repeatPasswordField.layer.cornerRadius = 12
        privatPublicTagsButton.layer.masksToBounds = true
        privatPublicTagsButton.layer.cornerRadius = 12
        privatTagsButton.layer.masksToBounds = true
        privatTagsButton.layer.cornerRadius = 12
        privatAchievementsButtom.layer.masksToBounds = true
        privatAchievementsButtom.layer.cornerRadius = 12
        deleteDateButton.layer.masksToBounds = true
        deleteDateButton.layer.cornerRadius = 12
        
        birthdayPicker.locale = .current
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let currentDate = dateFormatter.string(from: date)
        let maxYear = (currentDate.prefix(4) as NSString).integerValue - 13
        
        birthdayPicker.maximumDate = dateFormatter.date(from: "\(maxYear)" + currentDate.suffix(4))
        
        birthdayPicker.addTarget(self, action: #selector(birthdayChosen(_:)), for: .valueChanged)
        
        userNameField.delegate = self
        nicknameField.delegate = self
        countryField.delegate = self
        cityField.delegate = self
        passwordField.delegate = self
        repeatPasswordField.delegate = self
        
        userNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        userNameField.leftViewMode = .always
        
        nicknameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        nicknameField.leftViewMode = .always
        
        countryField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        countryField.leftViewMode = .always
        
        cityField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        cityField.leftViewMode = .always
        
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        passwordField.leftViewMode = .always
        
        repeatPasswordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        repeatPasswordField.leftViewMode = .always
        
        let eyeContainer = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
        let eyeView = UIImageView(image: UIImage.init(systemName: "eye.fill"))
        eyeView.contentMode = .left
        eyeView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        eyeView.tintColor = UIColor.systemGray3
        eyeView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showPassword1(_:)))
        eyeView.addGestureRecognizer(tap)
        eyeContainer.addSubview(eyeView)
        
        let eyeContainer1 = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
        let eyeView1 = UIImageView(image: UIImage.init(systemName: "eye.fill"))
        eyeView1.contentMode = .left
        eyeView1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        eyeView1.tintColor = UIColor.systemGray3
        eyeView1.isUserInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.showPassword2(_:)))
        eyeView1.addGestureRecognizer(tap1)
        eyeContainer1.addSubview(eyeView1)
        
        passwordField.rightView = eyeContainer
        passwordField.rightViewMode = .always
        repeatPasswordField.rightView = eyeContainer1
        repeatPasswordField.rightViewMode = .always
        
        saveButton.layer.cornerRadius = 16
        Helpers().addShadow(view: saveButton)
        
        if userAccount.avatar != nil && userAccount.avatar != "" {
            userAvatar.image = Helpers().imageFromString(string: userAccount.avatar)
        }
        userNameField.text = userAccount.name
        if userAccount.nickname != nil && userAccount.nickname != "" {
            nicknameField.text = userAccount.nickname!
        }
        if userAccount.country != nil && userAccount.country != "" {
            countryField.text = userAccount.country!
        }
        if userAccount.city != nil && userAccount.city != "" {
            cityField.text = userAccount.city!
        }
        if userAccount.birthYear != -1 && userAccount.birthDay != -1 && userAccount.birthMounth != -1 {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            
            var birthMount: String {
                if userAccount.birthMounth! < 10 {
                    return "0\(String(describing: userAccount.birthMounth!))"
                }
                return "\(String(describing: userAccount.birthMounth!))"
            }
            var birthDay: String {
                if userAccount.birthDay! < 10 {
                    return "0\(String(describing: userAccount.birthDay!))"
                }
                return "\(String(describing: userAccount.birthDay!))"
            }
            
            let birthDate = dateFormatter.date(from: "\(String(describing: userAccount.birthYear!))\(String(describing: birthMount))\(String(describing: birthDay))")
            
            birthdayPicker.date = birthDate!
            
            birthdayString = "\(String(describing: userAccount.birthYear!))\(String(describing: birthMount))\(String(describing: birthDay))"
        } else {
            birthdayPicker.alpha = 0.4
            deleteDateButton.isHidden = true
        }
        
        setupButtonsMenu()
        
        nameNotice.isHidden = true
        nicknameNotice.isHidden = true
        passwordNotice.isHidden = true
        repeatNotice.isHidden = true
        
        nicknameConstraint.priority = UILayoutPriority(rawValue: 400)
        passwordConstraint.priority = UILayoutPriority(rawValue: 400)
        repeatConstraint.priority = UILayoutPriority(rawValue: 400)
        
        userNameField.addTarget(self, action: #selector(nameChanged), for: .allEditingEvents)
        nicknameField.addTarget(self, action: #selector(nicknameChanged), for: .allEditingEvents)
        passwordField.addTarget(self, action: #selector(passwordChanged), for: .allEditingEvents)
        repeatPasswordField.addTarget(self, action: #selector(repeatChanged), for: .allEditingEvents)
    }
    
    // MARK: - Setup Buttoms
    
    func setupButtonsMenu() {
        
        var makePhotoTitle: String!
        var choosePhotoTitle: String!
        var deletePhotoTitle: String!
        
        var everyOneTitle: String!
        var allFriendsTitle: String!
        var onlyMeTitle: String!
        
        if globalVariables.currentLanguage == "en" {
            makePhotoTitle = "Make photo"
            choosePhotoTitle = "Choose photo"
            deletePhotoTitle = "Delete"
            
            everyOneTitle = "Everyone"
            allFriendsTitle = "All friends"
            onlyMeTitle = "Only me"
        } else {
            makePhotoTitle = "Сделать фото"
            choosePhotoTitle = "Выбрать фото"
            deletePhotoTitle = "Удалить"
            
            everyOneTitle = "Все"
            allFriendsTitle = "Только друзья"
            onlyMeTitle = "Только я"
        }
        
        let makePhoto = UIAction(title: makePhotoTitle, image: UIImage(systemName: "camera.fill")) { [self] _ in
            
            if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { [self] (granted: Bool) in
                    if granted {
                        pickerController = UIImagePickerController()
                        pickerController!.sourceType = .camera
                        pickerController!.allowsEditing = true
                        pickerController!.delegate = self
                        willBeDeinited = false
                        self.present(pickerController!, animated: true)
                    } else {
                        print("denide")
                    }
                })
            } else if AVCaptureDevice.authorizationStatus(for: .video) == .denied || AVCaptureDevice.authorizationStatus(for: .video) == .restricted {
                let alert = Helpers().constructAlert(error: .cameraAuthorization)
                self.present(alert, animated: true)
            } else if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                pickerController = UIImagePickerController()
                pickerController!.sourceType = .camera
                pickerController!.allowsEditing = true
                pickerController!.delegate = self
                willBeDeinited = false
                self.present(pickerController!, animated: true)
            }
        }
        
        let choosePhoto = UIAction(title: choosePhotoTitle, image: UIImage(systemName: "photo.on.rectangle")) { [self] _ in
            pickerController = UIImagePickerController()
            pickerController!.sourceType = .photoLibrary
            pickerController!.delegate = self
            pickerController!.allowsEditing = true
            self.present(pickerController!, animated: true)
        }
        let deleteAction = UIAction(title: deletePhotoTitle, image: UIImage(systemName: "trash.fill"), attributes: .destructive) { _ in
            self.isAvatarChanged = true
            UIView.transition(with: self.userAvatar, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.userAvatar.image = UIImage(systemName: "person.circle.fill")
            }, completion: nil)
            self.changeAvatarButton.menu = UIMenu(title: "", children: [makePhoto, choosePhoto])
        }
        changeAvatarButton.showsMenuAsPrimaryAction = true
        if userAccount.avatar != nil && userAccount.avatar != "" {
            changeAvatarButton.menu = UIMenu(title: "", children: [makePhoto, choosePhoto, deleteAction])
        } else {
            changeAvatarButton.menu = UIMenu(title: "", children: [makePhoto, choosePhoto])
        }

        everyoneBirthday = UIAction(title: everyOneTitle, image: UIImage(systemName: "person.3"), state: .off, handler: { _ in
            self.permissionBirthdayLabel.text = everyOneTitle
            self.everyoneBirthday?.state = .on
            self.onlyFriendsBirthday?.state = .off
            self.onlyMeBirthday?.state = .off
            
            self.userAccount.permissionBirthdayEveryone = true
            self.userAccount.permissionBirthdayFriends = true
            
            self.privatBirthdayButton.menu = UIMenu(title: "", children: [self.onlyMeBirthday!, self.onlyFriendsBirthday!, self.everyoneBirthday!])
        })
        onlyFriendsBirthday = UIAction(title: allFriendsTitle, image: UIImage(systemName: "person.2"), state: .off, handler: { _ in
            self.permissionBirthdayLabel.text = allFriendsTitle
            self.everyoneBirthday?.state = .off
            self.onlyFriendsBirthday?.state = .on
            self.onlyMeBirthday?.state = .off
            
            self.userAccount.permissionBirthdayEveryone = false
            self.userAccount.permissionBirthdayFriends = true
            
            self.privatBirthdayButton.menu = UIMenu(title: "", children: [self.onlyMeBirthday!, self.onlyFriendsBirthday!, self.everyoneBirthday!])
            
        })
        onlyMeBirthday = UIAction(title: onlyMeTitle, image: UIImage(systemName: "person"), state: .off, handler: { _ in
            self.permissionBirthdayLabel.text = onlyMeTitle
            self.everyoneBirthday?.state = .off
            self.onlyFriendsBirthday?.state = .off
            self.onlyMeBirthday?.state = .on
            
            self.userAccount.permissionBirthdayEveryone = false
            self.userAccount.permissionBirthdayFriends = false
            
            self.privatBirthdayButton.menu = UIMenu(title: "", children: [self.onlyMeBirthday!, self.onlyFriendsBirthday!, self.everyoneBirthday!])
        })
        if userAccount.permissionBirthdayEveryone {
            everyoneBirthday?.state = .on
            permissionBirthdayLabel.text = everyOneTitle
        } else if userAccount.permissionBirthdayFriends {
            onlyFriendsBirthday?.state = .on
            permissionBirthdayLabel.text = allFriendsTitle
        } else {
            onlyMeBirthday?.state = .on
            permissionBirthdayLabel.text = onlyMeTitle
        }
        privatBirthdayButton.showsMenuAsPrimaryAction = true
        privatBirthdayButton.menu = UIMenu(title: "", children: [onlyMeBirthday!, onlyFriendsBirthday!, everyoneBirthday!])
        
        
        
        everyoneCountry = UIAction(title: everyOneTitle, image: UIImage(systemName: "person.3"), state: .off, handler: { _ in
            self.permissionCountryCityLabel.text = everyOneTitle
            self.everyoneCountry?.state = .on
            self.onlyFriendsCountry?.state = .off
            self.onlyMeCountry?.state = .off
            
            self.userAccount.permissionCountryCityEveryone = true
            self.userAccount.permissionCountryCityFriends = true
            
            self.privatCountryCityButton.menu = UIMenu(title: "", children: [self.onlyMeCountry!, self.onlyFriendsCountry!, self.everyoneCountry!])
        })
        onlyFriendsCountry = UIAction(title: allFriendsTitle, image: UIImage(systemName: "person.2"), state: .off, handler: { _ in
            self.permissionCountryCityLabel.text = allFriendsTitle
            self.everyoneCountry?.state = .off
            self.onlyFriendsCountry?.state = .on
            self.onlyMeCountry?.state = .off
            
            self.userAccount.permissionCountryCityEveryone = false
            self.userAccount.permissionCountryCityFriends = true
            
            self.privatCountryCityButton.menu = UIMenu(title: "", children: [self.onlyMeCountry!, self.onlyFriendsCountry!, self.everyoneCountry!])
            
        })
        onlyMeCountry = UIAction(title: onlyMeTitle, image: UIImage(systemName: "person"), state: .off, handler: { _ in
            self.permissionCountryCityLabel.text = onlyMeTitle
            self.everyoneCountry?.state = .off
            self.onlyFriendsCountry?.state = .off
            self.onlyMeCountry?.state = .on
            
            self.userAccount.permissionCountryCityEveryone = false
            self.userAccount.permissionCountryCityFriends = false
            
            self.privatCountryCityButton.menu = UIMenu(title: "", children: [self.onlyMeCountry!, self.onlyFriendsCountry!, self.everyoneCountry!])
        })
        if userAccount.permissionCountryCityEveryone {
            everyoneCountry?.state = .on
            permissionCountryCityLabel.text = everyOneTitle
        } else if userAccount.permissionCountryCityFriends {
            onlyFriendsCountry?.state = .on
            permissionCountryCityLabel.text = allFriendsTitle
        } else {
            onlyMeCountry?.state = .on
            permissionCountryCityLabel.text = onlyMeTitle
        }
        privatCountryCityButton.showsMenuAsPrimaryAction = true
        privatCountryCityButton.menu = UIMenu(title: "", children: [onlyMeCountry!, onlyFriendsCountry!, everyoneCountry!])
        
        
        
        everyonePublicTags = UIAction(title: everyOneTitle, image: UIImage(systemName: "person.3"), state: .off, handler: { _ in
            self.permissionPublicTagsLabel.text = everyOneTitle
            self.everyonePublicTags?.state = .on
            self.onlyFriendsPublicTags?.state = .off
            
            self.userAccount.permissionPublicTagsEveryone = true
            
            self.privatPublicTagsButton.menu = UIMenu(title: "", children: [self.onlyFriendsPublicTags!, self.everyonePublicTags!])
        })
        onlyFriendsPublicTags = UIAction(title: allFriendsTitle, image: UIImage(systemName: "person.2"), state: .off, handler: { _ in
            self.permissionPublicTagsLabel.text = allFriendsTitle
            self.everyonePublicTags?.state = .off
            self.onlyFriendsPublicTags?.state = .on
            
            self.userAccount.permissionPublicTagsEveryone = false
            
            self.privatPublicTagsButton.menu = UIMenu(title: "", children: [self.onlyFriendsPublicTags!, self.everyonePublicTags!])
        })
        if userAccount.permissionPublicTagsEveryone {
            everyonePublicTags?.state = .on
            permissionPublicTagsLabel.text = everyOneTitle
        } else {
            onlyFriendsPublicTags?.state = .on
            permissionPublicTagsLabel.text = allFriendsTitle
        }
        privatPublicTagsButton.showsMenuAsPrimaryAction = true
        privatPublicTagsButton.menu = UIMenu(title: "", children: [onlyFriendsPublicTags!, everyonePublicTags!])
        
        
        
        onlyFriendsPrivatTags = UIAction(title: allFriendsTitle, image: UIImage(systemName: "person.2"), state: .off, handler: { _ in
            self.permissionPrivatTagsLabel.text = allFriendsTitle
            self.onlyFriendsPrivatTags?.state = .on
            self.onlyMePrivatTags?.state = .off
            
            self.userAccount.permissionPrivateTagsFriends = true
            
            self.privatTagsButton.menu = UIMenu(title: "", children: [self.onlyMePrivatTags!, self.onlyFriendsPrivatTags!])
        })
        onlyMePrivatTags = UIAction(title: onlyMeTitle, image: UIImage(systemName: "person"), state: .off, handler: { _ in
            self.permissionPrivatTagsLabel.text = onlyMeTitle
            self.onlyFriendsPrivatTags?.state = .off
            self.onlyMePrivatTags?.state = .on
            
            self.userAccount.permissionPrivateTagsFriends = false
            
            self.privatTagsButton.menu = UIMenu(title: "", children: [self.onlyMePrivatTags!, self.onlyFriendsPrivatTags!])
        })
        if userAccount.permissionPrivateTagsFriends {
            onlyFriendsPrivatTags?.state = .on
            permissionPrivatTagsLabel.text = allFriendsTitle
        } else {
            onlyMePrivatTags?.state = .on
            permissionPrivatTagsLabel.text = onlyMeTitle
        }
        privatTagsButton.showsMenuAsPrimaryAction = true
        privatTagsButton.menu = UIMenu(title: "", children: [onlyMePrivatTags!, onlyFriendsPrivatTags!])
        
        
        
        everyoneAchievements = UIAction(title: everyOneTitle, image: UIImage(systemName: "person.3"), state: .off, handler: { _ in
            self.permissionAchievements.text = everyOneTitle
            self.everyoneAchievements?.state = .on
            self.onlyFriendsAchievements?.state = .off
            
            self.userAccount.permissionAchievementsEveryOne = true
            
            self.privatAchievementsButtom.menu = UIMenu(title: "", children: [self.onlyFriendsAchievements!, self.everyoneAchievements!])
        })
        onlyFriendsAchievements = UIAction(title: allFriendsTitle, image: UIImage(systemName: "person.2"), state: .off, handler: { _ in
            self.permissionAchievements.text = allFriendsTitle
            self.everyoneAchievements?.state = .off
            self.onlyFriendsAchievements?.state = .on
            
            self.userAccount.permissionAchievementsEveryOne = false
            
            self.privatAchievementsButtom.menu = UIMenu(title: "", children: [self.onlyFriendsAchievements!, self.everyoneAchievements!])
        })
        if userAccount.permissionAchievementsEveryOne {
            everyoneAchievements?.state = .on
            permissionAchievements.text = everyOneTitle
        } else {
            onlyFriendsAchievements?.state = .on
            permissionAchievements.text = allFriendsTitle
        }
        privatAchievementsButtom.showsMenuAsPrimaryAction = true
        privatAchievementsButtom.menu = UIMenu(title: "", children: [onlyFriendsAchievements!, everyoneAchievements!])
    }
    
    // MARK: - Other Functions
    
    @objc func showPassword1(_ sender: UITapGestureRecognizer? = nil) {
        showingPassword1 = !showingPassword1
        
        if showingPassword1 {
            passwordField.isSecureTextEntry = false
        } else {
            passwordField.isSecureTextEntry = true
        }
    }
    
    @objc func showPassword2(_ sender: UITapGestureRecognizer? = nil) {
        showingPassword2 = !showingPassword2
        
        if showingPassword2 {
            repeatPasswordField.isSecureTextEntry = false
        } else {
            repeatPasswordField.isSecureTextEntry = true
        }
    }
    
    @objc func birthdayChosen(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        if birthdayString == "" {
            deleteDateButton.isHidden = false
            deleteDateButton.alpha = 0.0
            UIView.animate(withDuration: 0.4) { [self] in
                birthdayPicker.alpha = 1.0
                deleteDateButton.alpha = 1.0
            }
        }
        
        birthdayString = dateFormatter.string(from: sender.date)
        
    }
    
    @IBAction func birthdayDelete(_ sender: Any) {
        
        if birthdayString != "" {
            birthdayString = ""
            UIView.animate(withDuration: 0.4) { [self] in
                birthdayPicker.alpha = 0.4
                deleteDateButton.alpha = 0.0
            } completion: { _ in
                self.deleteDateButton.isHidden = true
            }

        }
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectange = keyboardFrame.cgRectValue
            keyboardHeigth = max(keyboardHeigth, keyboardRectange.height)
        }
    }

    @IBAction func saveChanges(_ sender: Any) {
        if ((passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == repeatPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) && Helpers().isSutablePassword(password: passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")) || (passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" && repeatPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "")) && userNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 >= 3 {
            
            if userAvatar.image != UIImage(systemName: "person.circle.fill") && isAvatarChanged {
                userAccount.avatar = Helpers().stringFromImage(image: avatarImage!)
            } else if userAvatar.image == UIImage(systemName: "person.circle.fill") {
                userAccount.avatar = ""
            }
            
            userAccount.name = userNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            userAccount.nickname = nicknameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            userAccount.country = countryField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            userAccount.city = cityField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

            if birthdayString != "" {
                
                userAccount.birthYear = (birthdayString.prefix(4) as NSString).integerValue
                userAccount.birthMounth = (birthdayString.prefix(6).suffix(2) as NSString).integerValue
                userAccount.birthDay = (birthdayString.suffix(2) as NSString).integerValue
            } else {
                userAccount.birthYear = -1
                userAccount.birthDay = -1
                userAccount.birthMounth = -1
            }
                        
            var password: String?
            if passwordField.text != "" || passwordField.text != nil {
                password = passwordField.text
            } else {
                password = ""
            }
            
            let form = CorrectAccountForm(email: personalInfo.emailAddress?.trimmingCharacters(in: .whitespacesAndNewlines), avatar: userAccount.avatar, userName: userAccount.name.trimmingCharacters(in: .whitespacesAndNewlines), birthYear: userAccount.birthYear!, birthDay: userAccount.birthDay!, birthMounth: userAccount.birthMounth!, nickname: userAccount.nickname?.trimmingCharacters(in: .whitespacesAndNewlines), country: userAccount.country?.trimmingCharacters(in: .whitespacesAndNewlines), city: userAccount.city?.trimmingCharacters(in: .whitespacesAndNewlines), newPassword: password, permissionBirthdayFriends: userAccount.permissionBirthdayFriends, permissionBirthdayEveryone: userAccount.permissionBirthdayEveryone, permissionCountryCityFriends: userAccount.permissionCountryCityFriends, permissionCountryCityEveryone: userAccount.permissionCountryCityEveryone, permissionPrivateTagsFriends: userAccount.permissionPrivateTagsFriends, permissionPublicTagsEveryone: userAccount.permissionPublicTagsEveryone, permissionAchievementsEveryOne: userAccount.permissionAchievementsEveryOne)
            
            self.saveButton.isEnabled = false
            self.placeNotificationsView(event: .loading)
            Server.shared.correctAccount(correctForm: form) { [self] answer in
                self.saveButton.isEnabled = true
                self.removeNotificationView { [self] _ in
                    if answer.success {
                        for var pin in globalVariables.allTags {
                            if pin.isPublicAccess {
                                if self.userAccount.permissionPublicTagsEveryone {
                                    pin.accessLevel = 1
                                } else {
                                    pin.accessLevel = 0
                                }
                            } else {
                                if self.userAccount.permissionPrivateTagsFriends {
                                    pin.accessLevel = 1
                                } else {
                                    pin.accessLevel = 0
                                }
                            }
                        }
                        
                        personalInfo.userAccount = self.userAccount
                        if form.newPassword != "" && form.newPassword != nil {
                            personalInfo.password = form.newPassword
                            Server.shared.changeDeviceTokens(data: nil, refreshAll: true) { answer in
                                print(answer, "- refresh tokens")
                            }
                        }
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        if answer.status == 430 {
                            nicknameConstraint.priority = UILayoutPriority(rawValue: 1000)
                            
                            nicknameNotice.alpha = 0.0
                            nicknameNotice.isHidden = false
                            
                            UIView.animate(withDuration: 0.4) { [self] in
                                nicknameNotice.alpha = 1.0
                                self.view.layoutIfNeeded()
                            }
                            scrollView.setContentOffset(CGPoint(x: 0, y: mainView.frame.minY - 14), animated: true)
                        } else if answer.status == 433 {
                            placeNotificationsView(event: .serverOff)
                        } else {
                            placeNotificationsView(event: .error)
                        }
                    }
                }
            }
        } else {
            if !Helpers().isSutablePassword(password: passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") && (passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" || repeatPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
                
                passwordConstraint.priority = UILayoutPriority(rawValue: 1000)
                
                passwordNotice.alpha = 0.0
                passwordNotice.isHidden = false
                
                UIView.animate(withDuration: 0.4) { [self] in
                    passwordNotice.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
            } else if passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != repeatPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) && (passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" || repeatPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
                
                repeatConstraint.priority = UILayoutPriority(rawValue: 1000)
                
                repeatNotice.alpha = 0.0
                repeatNotice.isHidden = false
                
                UIView.animate(withDuration: 0.4) { [self] in
                    repeatNotice.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
            }
            if userNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 < 3 {
                
                nameNotice.alpha = 0.0
                nameNotice.isHidden = false
                
                UIView.animate(withDuration: 0.4) { [self] in
                    nameNotice.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
                scrollView.setContentOffset(CGPoint(x: 0, y: mainView.frame.minY - 14), animated: true)
            }
        }
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        var title1: String!
        var title2: String!
        
        if globalVariables.currentLanguage == "en" {
            title1 = "Are you sure?"
            title2 = "It cannot be restored"
        } else {
            title1 = "Вы уверены?"
            title2 = "Это невозможно будет восстановить"
        }
        
        let actionSheet = UIAlertController(title: title1, message: title2, preferredStyle: .actionSheet)
        
        if globalVariables.currentLanguage == "en" {
            title1 = "Cancel"
            title2 = "Delete account"
        } else {
            title1 = "Отменить"
            title2 = "Удалить аккаунт"
        }
        
        actionSheet.addAction(UIAlertAction(title: title1, style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: title2, style: .destructive, handler: { _ in
            self.deleteButton.isEnabled = false
            self.placeNotificationsView(event: .loading)
            Server.shared.deleteAccount { answer in
                self.deleteButton.isEnabled = true
                self.removeNotificationView { [self] _ in
                    if answer.success {
                        
                        personalInfo.previousToken = ""
                        
                        personalInfo.userAccount = nil
                        personalInfo.emailAddress = nil
                        personalInfo.password = nil
                        personalInfo.isAuthorised = false
                        
                        UserDefaults.standard.set(nil, forKey:"offlineUserAccount")
                        
                        Helpers().sortAvailableTags(category: nil) { _ in
                            print("")
                        }
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        if answer.status == 433 {
                            placeNotificationsView(event: .serverOff)
                        } else {
                            placeNotificationsView(event: .error)
                        }
                    }
                }
            }
        }))
        
        present(actionSheet, animated: true)
    }
    
    // MARK: - Delegate Functions
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        var seconds = 0.0
        if keyboardHeigth == 0.0 {
            seconds = 0.5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [self] in
            let visiblePart = scrollView.frame.height - keyboardHeigth - 6
            
            switch textField.tag {
            case 0:
                var yUsername = mainView.frame.minY + userNameField.frame.maxY - visiblePart
                if yUsername < 0 { yUsername = 0}
                scrollView.setContentOffset(CGPoint(x: 0, y: yUsername), animated: true)
            case 3:
                var yBirthday = mainView.frame.minY + nicknameField.frame.maxY - visiblePart
                if yBirthday < 0 { yBirthday = 0}
                scrollView.setContentOffset(CGPoint(x: 0, y: yBirthday), animated: true)
            case 4:
                scrollView.setContentOffset(CGPoint(x: 0, y: mainView.frame.minY + countryField.frame.maxY - visiblePart), animated: true)
            case 5:
                scrollView.setContentOffset(CGPoint(x: 0, y: mainView.frame.minY + cityField.frame.maxY - visiblePart), animated: true)
            case 6:
                scrollView.setContentOffset(CGPoint(x: 0, y: privacyView.frame.minY + passwordField.frame.maxY - visiblePart), animated: true)
            case 7:
                scrollView.setContentOffset(CGPoint(x: 0, y: privacyView.frame.minY + repeatPasswordField.frame.maxY - visiblePart), animated: true)
            default:
                break
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            textField.resignFirstResponder()
        } else if textField.tag == 3 {
            countryField.becomeFirstResponder()
        } else if textField.tag == 4 {
            cityField.becomeFirstResponder()
        } else if textField.tag == 5 {
            cityField.resignFirstResponder()
        } else if textField.tag == 6 {
            repeatPasswordField.becomeFirstResponder()
        } else if textField.tag == 7 {
            repeatPasswordField.resignFirstResponder()
        }
        return true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        pickerController?.delegate = nil
        pickerController = nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var makePhotoTitle: String!
        var choosePhotoTitle: String!
        var deletePhotoTitle: String!
        
        if globalVariables.currentLanguage == "en" {
            makePhotoTitle = "Make photo"
            choosePhotoTitle = "Choose photo"
            deletePhotoTitle = "Delete"
        } else {
            makePhotoTitle = "Сделать фото"
            choosePhotoTitle = "Выбрать фото"
            deletePhotoTitle = "Удалить"
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        do {
            if info[UIImagePickerController.InfoKey.imageURL] != nil {
                try FileManager.default.removeItem(at: info[UIImagePickerController.InfoKey.imageURL] as! URL)
            }
        } catch {
            print(error)
        }
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        userAvatar.image = image
        avatarImage = image
        isAvatarChanged = true

        let makePhoto = UIAction(title: makePhotoTitle, image: UIImage(systemName: "camera.fill")) { _ in
            
            if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        self.willBeDeinited = false
                        let picker = UIImagePickerController()
                        picker.sourceType = .camera
                        picker.allowsEditing = true
                        picker.delegate = self
                        self.present(picker, animated: true)
                    } else {
                        print("denide")
                    }
                })
            } else if AVCaptureDevice.authorizationStatus(for: .video) == .denied || AVCaptureDevice.authorizationStatus(for: .video) == .restricted {
                let alert = Helpers().constructAlert(error: .cameraAuthorization)
                self.present(alert, animated: true)
            } else if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                self.willBeDeinited = false
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker, animated: true)
            }
        }
        let choosePhoto = UIAction(title: choosePhotoTitle, image: UIImage(systemName: "photo.on.rectangle")) { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true)
        }
        
        let deleteAction = UIAction(title: deletePhotoTitle, image: UIImage(systemName: "trash.fill"), attributes: .destructive) { _ in
            self.isAvatarChanged = true
            UIView.transition(with: self.userAvatar, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.userAvatar.image = UIImage(systemName: "person.circle.fill")
            }, completion: nil)
            self.changeAvatarButton.menu = UIMenu(title: "", children: [makePhoto, choosePhoto])
        }
        
        changeAvatarButton.menu = UIMenu(title: "", children: [makePhoto, choosePhoto, deleteAction])
        
        pickerController?.delegate = nil
        pickerController = nil
    }
    
    // MARK: - Notices Hiding
    
    @objc func nameChanged() {
        nameNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            nameNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        nameNotice.isHidden = true
    }
    
    @objc func nicknameChanged() {
        nicknameConstraint.priority = UILayoutPriority(rawValue: 400)
        
        nicknameNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            nicknameNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        nicknameNotice.isHidden = true
    }
    
    @objc func passwordChanged() {
        passwordConstraint.priority = UILayoutPriority(rawValue: 400)
        
        passwordNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            passwordNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        passwordNotice.isHidden = true
    }
    
    @objc func repeatChanged() {
        repeatConstraint.priority = UILayoutPriority(rawValue: 400)
        
        repeatNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            repeatNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        repeatNotice.isHidden = true
    }
    
    func placeNotificationsView(event: globalVariables.userNotification) {
        
        notificationView?.removeFromSuperview()
        notificationView = nil
        
        notificationView = Helpers().constructNotificationView(widthOfScreen: self.view.frame.width, event: event)
        
        self.view.addSubview(notificationView!)
        notificationView?.alpha = 0.0
        
        notificationView?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        notificationView?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        UIView.transition(with: self.view, duration: 0.2, options: .beginFromCurrentState, animations: {
            self.notificationView?.alpha = 1.0
        }, completion: nil)
        
        if event != .loading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.removeNotificationView(completion: nil)
            }
        }
    }
    
    func removeNotificationView(completion: ((Bool) -> Void)? = nil) {
    
        UIView.transition(with: self.view, duration: 0.2, options: .beginFromCurrentState) {
            self.notificationView?.alpha = 0.0
        } completion: { [self] _ in
            notificationView?.removeFromSuperview()
            notificationView = nil
            completion?(true)
        }
    }
}
