//
//  CreateAccountViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 24.05.2021.
//

import UIKit
import SafariServices
import AVFoundation

class CreateAccountViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var nameNotice: UILabel!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var emailNotice: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordNotice: UILabel!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var repeatNotice: UILabel!
    @IBOutlet weak var singUpButton: UIButton!
    
    @IBOutlet weak var nameConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordConstraint: NSLayoutConstraint!
    @IBOutlet weak var repeatConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var alreadyHaveLable: UILabel!
    @IBOutlet weak var singInButton: UIButton!
    
    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var agreeementLabel: UILabel!
    @IBOutlet weak var agreementNotice: UILabel!
    @IBOutlet weak var agreementConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var noToUse: NSLayoutConstraint!
    
    var notificationView: UIView?
    
    var keyboardHeigth: CGFloat = 0.0
    
    public var userInfo: ProvisoryUserInfo?
    
    private var willBeDeinited: Bool = true
    
    var pickerController: UIImagePickerController?
    
    var isSettingContentOffset = false
    
    let grayColor = CGColor.init(srgbRed: 0.667, green: 0.667, blue: 0.667, alpha: 1.0)
    var agreeWithPolicy: Bool = false
    var showingPassword1: Bool = false
    var showingPassword2: Bool = false
    
    let selectFeedback = UISelectionFeedbackGenerator()
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        willBeDeinited = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.layoutSubviews()
        self.scrollView.layoutSubviews()

        let contentY = scrollView.contentOffset.y
        
        if scrollView.frame.height - globalVariables.bottomScreenLength <= singInButton.frame.maxY + 12 {
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: singInButton.frame.maxY + 82)
        } else {
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
        }
        
        if keyboardHeigth != 0.0 {
            if scrollView.frame.height <= repeatPasswordField.frame.maxY + createView.frame.minY + keyboardHeigth + 10 {
                scrollView.contentSize = CGSize(width: scrollView.frame.width, height: repeatPasswordField.frame.maxY + createView.frame.minY + keyboardHeigth + 10)
            }
        }
        
        if !isSettingContentOffset {
            scrollView.setContentOffset(CGPoint(x: 0, y: contentY), animated: false)
        }
        isSettingContentOffset = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if willBeDeinited {
            userAvatar?.image = nil
            userAvatar = nil
            notificationView?.removeFromSuperview()
            notificationView = nil
            userInfo = nil
            pickerController?.delegate = nil
            pickerController = nil
            username.delegate = nil
            emailAddress.delegate = nil
            passwordField.delegate = nil
            repeatPasswordField.delegate = nil
        }
    }
    
    // MARK: - Setup Functions
    
    func setupScene() {
        
        selectFeedback.prepare()
        
        createView.layer.cornerRadius = 16
        Helpers().addShadow(view: createView)
        
        userAvatar.layer.masksToBounds = true
        userAvatar.layer.cornerRadius = 73
        username.layer.masksToBounds = true
        username.layer.cornerRadius = 12
        emailAddress.layer.masksToBounds = true
        emailAddress.layer.cornerRadius = 12
        passwordField.layer.masksToBounds = true
        passwordField.layer.cornerRadius = 12
        repeatPasswordField.layer.masksToBounds = true
        repeatPasswordField.layer.cornerRadius = 12
        singUpButton.layer.masksToBounds = true
        singUpButton.layer.cornerRadius = 12
        changePhotoButton.layer.cornerRadius = 21
        Helpers().addShadow(view: changePhotoButton)
        
        checkmarkButton.layer.masksToBounds = true
        checkmarkButton.layer.cornerRadius = 5
        checkmarkButton.layer.borderWidth = 2.0
        checkmarkButton.layer.borderColor = grayColor
        checkmarkButton.backgroundColor = .clear
        
        var makePhotoTitle: String!
        var choosePhotoTitle: String!
        
        if globalVariables.currentLanguage == "en" {
            makePhotoTitle = "Make photo"
            choosePhotoTitle = "Choose photo"
        } else {
            makePhotoTitle = "Сделать фото"
            choosePhotoTitle = "Выбрать фото"
            let mainPart = NSMutableAttributedString(string: "Я ознакомлен и согласен с ")
            mainPart.append(NSAttributedString(string: "политикой конфиденциальности", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]))
            agreeementLabel.attributedText = mainPart
        }
        
        let makePhoto = UIAction(title: makePhotoTitle, image: UIImage(systemName: "camera.fill")) { [self] _ in
            
            if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { [self] (granted: Bool) in
                    if granted {
                        self.willBeDeinited = false
                        
                        pickerController = UIImagePickerController()
                        pickerController!.sourceType = .camera
                        pickerController!.allowsEditing = true
                        pickerController!.delegate = self
                        self.present(pickerController!, animated: true)
                    } else {
                        print("denide")
                    }
                })
            } else if AVCaptureDevice.authorizationStatus(for: .video) == .denied || AVCaptureDevice.authorizationStatus(for: .video) == .restricted {
                let alert = Helpers().constructAlert(error: .cameraAuthorization)
                self.present(alert, animated: true)
            } else if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                self.willBeDeinited = false
                
                pickerController = UIImagePickerController()
                pickerController!.sourceType = .camera
                pickerController!.allowsEditing = true
                pickerController!.delegate = self
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
        
        changePhotoButton.showsMenuAsPrimaryAction = true
        changePhotoButton.menu = UIMenu(title: "", children: [makePhoto, choosePhoto])
        
        singInButton.layer.cornerRadius = 14
        Helpers().addShadow(view: singInButton)
        
        scrollViewBottom.isActive = false
        scrollViewBottom = scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: globalVariables.bottomScreenLength)
        scrollViewBottom.isActive = true
        
        username.delegate = self
        emailAddress.delegate = self
        passwordField.delegate = self
        repeatPasswordField.delegate = self
        
        username.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        username.leftViewMode = .always
        emailAddress.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        emailAddress.leftViewMode = .always
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
        
        let tapToClose = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tapToClose)
        
        nameNotice.isHidden = true
        emailNotice.isHidden = true
        passwordNotice.isHidden = true
        repeatNotice.isHidden = true
        agreementNotice.isHidden = true
        
        nameConstraint.priority = UILayoutPriority(rawValue: 400)
        emailConstraint.priority = UILayoutPriority(rawValue: 400)
        passwordConstraint.priority = UILayoutPriority(rawValue: 400)
        repeatConstraint.priority = UILayoutPriority(rawValue: 400)
        agreementConstraint.priority = UILayoutPriority(rawValue: 400)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        username.addTarget(self, action: #selector(nameFieldChange), for: .allEditingEvents)
        emailAddress.addTarget(self, action: #selector(emailFieldChange), for: .allEditingEvents)
        passwordField.addTarget(self, action: #selector(passwordFieldChange), for: .allEditingEvents)
        repeatPasswordField.addTarget(self, action: #selector(repeatFieldChange), for: .allEditingEvents)
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
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectange = keyboardFrame.cgRectValue
            keyboardHeigth = max(keyboardHeigth, keyboardRectange.height)
            
            viewDidLayoutSubviews()
        }
    }
    
    @objc func tappedImage (_ sender: Any) {
        print("TAP TO IMAGE")
    }
    
    @IBAction func singUp(_ sender: Any) {
        
        
        if username.text != nil && username.text != "" && username.text?.count ?? 0 >= 3 && Helpers().isSutableEmail(email: emailAddress.text ?? "") && passwordField.text == repeatPasswordField.text && Helpers().isSutablePassword(password: passwordField.text ?? "") && agreeWithPolicy {
            
            let avatar: String?
            if userAvatar.image == UIImage(systemName: "person.circle.fill") {
                avatar = nil
            } else {
                avatar = Helpers().stringFromImage(image: userAvatar.image!)
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            
            userInfo = ProvisoryUserInfo(email: emailAddress.text!, password: passwordField.text!, name: username.text!, avatar: avatar)
            
            singUpButton.isEnabled = false
            placeNotificationsView(event: .loading)
            
            Server.shared.singUp(name: username.text!.trimmingCharacters(in: .whitespacesAndNewlines), email:emailAddress.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines),language: globalVariables.currentLanguage, avatar:avatar) { [self] (answer) in
                singUpButton.isEnabled = true
                removeNotificationView { [self] _ in
                    if answer.success {
                        self.confirmEmailView()
                    } else {
                        if answer.status == 413 {
                            emailConstraint.priority = UILayoutPriority(rawValue: 1000)
                            
                            emailNotice.alpha = 0.0
                            emailNotice.isHidden = false
                            
                            UIView.animate(withDuration: 0.4) { [self] in
                                emailNotice.alpha = 1.0
                                self.view.layoutIfNeeded()
                            }
                        } else if answer.status == 433 {
                            placeNotificationsView(event: .serverOff)
                        } else {
                            placeNotificationsView(event: .error)
                        }
                    }
                }
            }
        } else {
            
            if username.text == nil || username.text == "" || username.text?.count ?? 0 < 3 {
                nameConstraint.priority = UILayoutPriority(rawValue: 1000)
                
                nameNotice.alpha = 0.0
                nameNotice.isHidden = false
                
                UIView.animate(withDuration: 0.4) { [self] in
                    nameNotice.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
            }
            if !Helpers().isSutableEmail(email: emailAddress.text ?? "") {
                emailConstraint.priority = UILayoutPriority(rawValue: 1000)
                
                emailNotice.alpha = 0.0
                emailNotice.isHidden = false
                
                UIView.animate(withDuration: 0.4) { [self] in
                    emailNotice.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
            }
            if !Helpers().isSutablePassword(password: passwordField.text ?? "") {
                passwordConstraint.priority = UILayoutPriority(rawValue: 1000)
                
                passwordNotice.alpha = 0.0
                passwordNotice.isHidden = false
                
                UIView.animate(withDuration: 0.4) { [self] in
                    passwordNotice.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
            }
            if passwordField.text != repeatPasswordField.text && Helpers().isSutablePassword(password: passwordField.text ?? "") {
                repeatConstraint.priority = UILayoutPriority(rawValue: 1000)
                
                repeatNotice.alpha = 0.0
                repeatNotice.isHidden = false
                
                UIView.animate(withDuration: 0.4) { [self] in
                    repeatNotice.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
            }
            if !agreeWithPolicy {
                
                agreementConstraint.priority = UILayoutPriority(1000)
                
                agreementNotice.isHidden = false
                agreementNotice.alpha = 0.0
                
                UIView.animate(withDuration: 0.4) {
                    self.agreementNotice.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
            }
            
            viewDidLayoutSubviews()
        }
        
    }
    
    @objc func nameFieldChange() {
        nameConstraint.priority = UILayoutPriority(rawValue: 400)
        
        nameNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            nameNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        nameNotice.isHidden = true
        
        viewDidLayoutSubviews()
    }
    
    @objc func emailFieldChange() {
        emailConstraint.priority = UILayoutPriority(rawValue: 400)
        
        emailNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            emailNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        emailNotice.isHidden = true
        
        viewDidLayoutSubviews()
    }
    
    @objc func passwordFieldChange() {
        passwordConstraint.priority = UILayoutPriority(rawValue: 400)
        
        passwordNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            passwordNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        passwordNotice.isHidden = true
        
        repeatConstraint.priority = UILayoutPriority(rawValue: 400)
        
        repeatNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            repeatNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        repeatNotice.isHidden = true
        
        viewDidLayoutSubviews()
    }
    
    @objc func repeatFieldChange() {
        repeatConstraint.priority = UILayoutPriority(rawValue: 400)
        
        repeatNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            repeatNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        repeatNotice.isHidden = true
        
        viewDidLayoutSubviews()
    }
    
    func confirmEmailView() {
        let storyboard = UIStoryboard(name: "Accounts", bundle: nil)
        self.pushViewController(storyboard: storyboard, identifier: "enterEmailCodeViewController")
    }
    
    @IBAction func goToSingIn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Accounts", bundle: nil)
        pushViewController(storyboard: storyboard, identifier: "SingInViewController")
    }
    
    func pushViewController(storyboard: UIStoryboard, identifier: String) {
        
        willBeDeinited = false
        
        let VC = storyboard.instantiateViewController(identifier: identifier)
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func changeAgreement(_ sender: Any) {
        
        agreementConstraint.priority = UILayoutPriority(rawValue: 400)
        
        agreementNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            agreementNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        agreementNotice.isHidden = true
        
        viewDidLayoutSubviews()
        
        agreeWithPolicy = !agreeWithPolicy
        
        selectFeedback.selectionChanged()
        
        UIView.animate(withDuration: 0.3) { [self] in
            switch checkmarkButton.backgroundColor {
            case UIColor.clear:
                checkmarkButton.backgroundColor = .lightGray
            case UIColor.lightGray:
                checkmarkButton.backgroundColor = .clear
            default:
                break
            }
        }
    }
    
    @IBAction func openPrivacyPolicy(_ sender: Any) {
        
        var url: URL!
        
        switch globalVariables.currentLanguage {
        case "en":
            url = URL(string: globalVariables.websiteUrl + "en/policy/")
        case "ru":
            url = URL(string: globalVariables.websiteUrl + "ru/policy/")
        default:
            url = URL(string: globalVariables.websiteUrl + "en/policy/")
        }
        
        let vc = SFSafariViewController(url: url)
        
        willBeDeinited = false
        
        present(vc, animated: true)
    }
    
    // MARK: - Delegate Functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            emailAddress.becomeFirstResponder()
        } else if textField.tag == 1 {
            passwordField.becomeFirstResponder()
        } else if textField.tag == 2 {
            repeatPasswordField.becomeFirstResponder()
        } else if textField.tag == 3 {
            singUp((Any).self)
        }
        return true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
        pickerController?.delegate = nil
        pickerController = nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        do {
            if info[UIImagePickerController.InfoKey.imageURL] != nil {
                try FileManager.default.removeItem(at: info[UIImagePickerController.InfoKey.imageURL] as! URL)
            }
        } catch {
            print(error)
        }
        
        userAvatar.image = nil
        userAvatar.image = image

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
        
        let makePhoto = UIAction(title: makePhotoTitle, image: UIImage(systemName: "camera.fill")) { [self] _ in
            
            if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { [self] (granted: Bool) in
                    if granted {
                        self.willBeDeinited = false
                        pickerController = UIImagePickerController()
                        pickerController!.sourceType = .camera
                        pickerController!.allowsEditing = true
                        pickerController!.delegate = self
                        self.present(pickerController!, animated: true)
                    } else {
                        print("denide")
                    }
                })
            } else if AVCaptureDevice.authorizationStatus(for: .video) == .denied || AVCaptureDevice.authorizationStatus(for: .video) == .restricted {
                let alert = Helpers().constructAlert(error: .cameraAuthorization)
                self.present(alert, animated: true)
            } else if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                self.willBeDeinited = false
                pickerController = UIImagePickerController()
                pickerController!.sourceType = .camera
                pickerController!.allowsEditing = true
                pickerController!.delegate = self
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
            UIView.transition(with: self.userAvatar, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.userAvatar.image = nil
                self.userAvatar.image = UIImage(systemName: "person.circle.fill")
            }, completion: nil)
            self.changePhotoButton.menu = UIMenu(title: "", children: [makePhoto, choosePhoto])
        }
        
        changePhotoButton.menu = UIMenu(title: "", children: [makePhoto, choosePhoto, deleteAction])
        
        pickerController?.delegate = nil
        pickerController = nil
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        var seconds = 0.0
        if keyboardHeigth == 0.0 {
            seconds = 0.5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [self] in
            let visiblePart = scrollView.frame.height - keyboardHeigth - 23
            
            switch textField.tag {
            case 2:
                var y = passwordField.frame.maxY + createView.frame.minY - visiblePart
                if y < 0 { y = 0 }
                isSettingContentOffset = true
                scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
            case 3:
                var y = repeatPasswordField.frame.maxY + createView.frame.minY - visiblePart
                if y < 0 { y = 0 }
                isSettingContentOffset = true
                scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
            default:
                break
            }
            
        }
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
