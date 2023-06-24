//
//  SingInViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 28.05.2021.
//

import UIKit

class SingInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var singInView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var singInButton: UIButton!
    @IBOutlet weak var forgotLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var emailNotice: UILabel!
    @IBOutlet weak var passwordNotice: UILabel!
    
    @IBOutlet weak var emailConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var noToUse: NSLayoutConstraint!
    
    var notificationView: UIView?
    
    private var willBeDeinited: Bool = true

    var firstFieldPasted: Int?
    var secondFieldPasted: Int?
    
    var showingPassword: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        willBeDeinited = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if willBeDeinited {
            notificationView?.removeFromSuperview()
            notificationView = nil
            emailField.delegate = nil
            passwordField.delegate = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: globalVariables.screenWidth, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
    }
    
    func setupScene() {
        scrollViewBottom.isActive = false
        scrollViewBottom = scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: globalVariables.bottomScreenLength)
        scrollViewBottom.isActive = true
        noToUse.isActive = false
        
        singInView.layer.cornerRadius = 16
        Helpers().addShadow(view: singInView)
        
        emailField.layer.masksToBounds = true
        emailField.layer.cornerRadius = 12
        passwordField.layer.masksToBounds = true
        passwordField.layer.cornerRadius = 12
        singInButton.layer.masksToBounds = true
        singInButton.layer.cornerRadius = 12
        
        emailField.delegate = self
        passwordField.delegate = self
        
        emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        emailField.leftViewMode = .always
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        passwordField.leftViewMode = .always
        
        let eyeContainer = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
        let eyeView = UIImageView(image: UIImage.init(systemName: "eye.fill"))
        eyeView.contentMode = .left
        eyeView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        eyeView.tintColor = UIColor.systemGray3
        eyeView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showPassword(_:)))
        eyeView.addGestureRecognizer(tap)
        eyeContainer.addSubview(eyeView)
        
        passwordField.rightView = eyeContainer
        passwordField.rightViewMode = .always
        
        
        let tapToClose = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tapToClose)
        
        emailNotice.isHidden = true
        passwordNotice.isHidden = true
        
        emailConstraint.priority = UILayoutPriority(rawValue: 400)
        passwordConstraint.priority = UILayoutPriority(rawValue: 400)
        
        emailField.addTarget(self, action: #selector(emailChanged), for: .allEditingEvents)
        passwordField.addTarget(self, action: #selector(passwordChanged), for: .allEditingEvents)
        
    }
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            passwordField.becomeFirstResponder()
        } else if textField.tag == 1 {
            singIn((Any).self)
        }
        return true
    }
    
    @objc func showPassword(_ sender: UITapGestureRecognizer? = nil) {
        showingPassword = !showingPassword
        
        if showingPassword {
            passwordField.isSecureTextEntry = false
        } else {
            passwordField.isSecureTextEntry = true
        }
    }
    
    @IBAction func singIn(_ sender: Any) {
        if Helpers().isSutableEmail(email: emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") && Helpers().isSutablePassword(password: passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") {
            self.singInButton.isEnabled = false
            placeNotificationsView(event: .loading)
            Server.shared.signIn(email: emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) { [self] (answer) in
                self.singInButton.isEnabled = true
                removeNotificationView { [self] _ in
                    if answer.success {
                        
                        personalInfo.emailAddress = emailField.text
                        personalInfo.password = passwordField.text
                        
                        let center = UNUserNotificationCenter.current()
                        
                        center.getNotificationSettings { settings in
                            if settings.authorizationStatus == .authorized || settings.authorizationStatus == .ephemeral || settings.authorizationStatus == .provisional {
                                DispatchQueue.main.async {
                                    UIApplication.shared.registerForRemoteNotifications()
                                }
                            } else if settings.authorizationStatus == .notDetermined {
                                center.requestAuthorization(options: [.sound, .alert, .badge]) { success, error in
                                    if error == nil {
                                        DispatchQueue.main.async {
                                            UIApplication.shared.registerForRemoteNotifications()
                                        }
                                    }
                                }
                            }
                        }
                        
                        let currentVC = self.navigationController?.topViewController
                        
                        guard var viewConstrollers = currentVC?.navigationController?.viewControllers else {
                            return
                        }
                        
                        if globalVariables.shouldSaveTagInAddingViewController {
                            _ = viewConstrollers.popLast()
                            _ = viewConstrollers.popLast()
                            let addOrSaveTagViewController = viewConstrollers.popLast()
                            
                            self.navigationController?.popToViewController(addOrSaveTagViewController!, animated: true)
                        } else if globalVariables.shouldStayOnAccountInfoViewController {
                            _ = viewConstrollers.popLast()
                            _ = viewConstrollers.popLast()
                            currentVC?.navigationController?.setViewControllers(viewConstrollers, animated: true)
                        } else {
                            _ = viewConstrollers.popLast()
                            _ = viewConstrollers.popLast()
                            _ = viewConstrollers.popLast()
                            
                            let accountViewController = UIStoryboard(name: "Accounts", bundle: nil).instantiateViewController(identifier: "AccountIfoViewController") as! AccountInfoViewController
                            accountViewController.isAnotherUserAccount = false
                            viewConstrollers.append(accountViewController)
                            
                            currentVC?.navigationController?.setViewControllers(viewConstrollers, animated: true)
                        }
                    } else {
                        if answer.status == 404 {
                            emailConstraint.priority = UILayoutPriority(rawValue: 1000)
                            
                            emailNotice.alpha = 0.0
                            emailNotice.isHidden = false
                            
                            UIView.animate(withDuration: 0.4) { [self] in
                                emailNotice.alpha = 1.0
                                self.view.layoutIfNeeded()
                            }
                            
                            viewDidLayoutSubviews()
                        } else if answer.status == 402 {
                            passwordConstraint.priority = UILayoutPriority(rawValue: 1000)
                            
                            passwordNotice.alpha = 0.0
                            passwordNotice.isHidden = false
                            
                            UIView.animate(withDuration: 0.4) { [self] in
                                passwordNotice.alpha = 1.0
                                self.view.layoutIfNeeded()
                            }
                            
                            viewDidLayoutSubviews()
                        } else if answer.status == 433 {
                            placeNotificationsView(event: .serverOff)
                        } else {
                            placeNotificationsView(event: .error)
                        }
                    }
                }
            }
        } else {
            if !Helpers().isSutableEmail(email: emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") {
                emailConstraint.priority = UILayoutPriority(rawValue: 1000)
                
                emailNotice.alpha = 0.0
                emailNotice.isHidden = false
                
                UIView.animate(withDuration: 0.4) { [self] in
                    emailNotice.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
                
                viewDidLayoutSubviews()
            } else if !Helpers().isSutablePassword(password: passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") {
                passwordConstraint.priority = UILayoutPriority(rawValue: 1000)
                
                passwordNotice.alpha = 0.0
                passwordNotice.isHidden = false
                
                UIView.animate(withDuration: 0.4) { [self] in
                    passwordNotice.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
                
                viewDidLayoutSubviews()
            }
        }
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        self.willBeDeinited = false
        
        let VC = UIStoryboard(name: "Accounts", bundle: nil).instantiateViewController(identifier: "ResetViewController")
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @objc func emailChanged () {
        emailConstraint.priority = UILayoutPriority(rawValue: 400)
        
        emailNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            emailNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        emailNotice.isHidden = true
        
        viewDidLayoutSubviews()
    }
    
    @objc func passwordChanged() {
        passwordConstraint.priority = UILayoutPriority(rawValue: 400)
        
        passwordNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            passwordNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        passwordNotice.isHidden = true
        
        viewDidLayoutSubviews()
    }
    
    func placeNotificationsView(event: globalVariables.userNotification) {
        
        notificationView?.removeFromSuperview()
        notificationView = nil
        
        notificationView = Helpers().constructNotificationView(widthOfScreen: self.view.frame.width, event: event)
        notificationView?.alpha = 0.0
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 1 {
            if textField.tag == 0 {
                firstFieldPasted = Int(Date().timeIntervalSince1970)
                if firstFieldPasted == secondFieldPasted ?? 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.singIn((Any).self)
                    }
                }
            } else if textField.tag == 1 {
                secondFieldPasted = Int(Date().timeIntervalSince1970)
                if secondFieldPasted == firstFieldPasted ?? 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.singIn((Any).self)
                    }
                }
            }
        }
        return true
    }
}
