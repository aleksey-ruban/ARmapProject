//
//  EmailCodeViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 29.05.2021.
//

import UIKit

class EmailCodeViewController: UIViewController {
    
    @IBOutlet weak var infoLable: UILabel!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var verificationField: UITextField!
    @IBOutlet weak var verificationNotice: UILabel!
    @IBOutlet weak var verificationConstraint: NSLayoutConstraint!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var noToUse: NSLayoutConstraint!
    
    var userInfo: ProvisoryUserInfo?
    
    var notificationView: UIView?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillUserInfo()
        
        verificationField.layer.cornerRadius = 12
        Helpers().addShadow(view: verificationField)
        
        verificationField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        verificationField.leftViewMode = .always
        
        confirmButton.layer.cornerRadius = 12
        Helpers().addShadow(view: confirmButton)
        
        scrollViewBottom.isActive = false
        scrollViewBottom = scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: globalVariables.bottomScreenLength)
        scrollViewBottom.isActive = true
        noToUse.isActive = false
        scrollView.contentSize = CGSize(width: globalVariables.screenWidth, height: scrollView.frame.height)
        
        verificationField.becomeFirstResponder()
        
        if userInfo!.email != "" {
            infoLable.text = infoLable.text! + ": " + userInfo!.email + "."
        } else {
            infoLable.text = infoLable.text! + "."
        }
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        verificationField.addTarget(self, action: #selector(checkForCodeLen), for: .allEditingEvents)
        verificationNotice.isHidden = true
        verificationConstraint.priority = UILayoutPriority(rawValue: 400)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: globalVariables.screenWidth, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
    }
    
    func fillUserInfo() {
        let currentVC = self.navigationController?.topViewController
        
        guard var viewConstrollers = currentVC?.navigationController?.viewControllers else {
            return
        }
        
        _ = viewConstrollers.popLast()
        
        let createAccountViewController = viewConstrollers.popLast()
        
        if createAccountViewController is CreateAccountViewController {
            userInfo = (createAccountViewController as! CreateAccountViewController).userInfo!
        }
    }
    
    @IBAction func resendCode(_ sender: Any) {
        
        fillUserInfo()
        
        resendButton.isEnabled = false
        
        placeNotificationsView(event: .loading)
        Server.shared.resendCode(email: userInfo!.email, password: userInfo!.password, language: globalVariables.currentLanguage) { [self] answer in
            removeNotificationView { [self] _ in
                self.resendButton.isEnabled = true
                if !answer.success {
                    if answer.status == 433 {
                        placeNotificationsView(event: .serverOff)
                    } else {
                        placeNotificationsView(event: .error)
                    }
                }
            }
        }
    }
    
    
    @IBAction func confirm(_ sender: Any) {
        
        fillUserInfo()
        
        if verificationField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 6 {
            verificate()
        } else {
            verificationConstraint.priority = UILayoutPriority(rawValue: 1000)
            
            verificationNotice.alpha = 0.0
            verificationNotice.isHidden = false
            
            UIView.animate(withDuration: 0.4) { [self] in
                verificationNotice.alpha = 1.0
                self.view.layoutIfNeeded()
            }
            
            viewDidLayoutSubviews()
        }
    }
    
    @objc func checkForCodeLen() {
        verificationConstraint.priority = UILayoutPriority(rawValue: 400)
        
        verificationNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            verificationNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        verificationNotice.isHidden = true
        
        viewDidLayoutSubviews()
        
        if verificationField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 6 {
            fillUserInfo()
            verificate()
        }
    }
    
    func verificate() {
        confirmButton.isEnabled = false
        placeNotificationsView(event: .loading)
        Server.shared.confirmEmail(email: userInfo!.email, code: Int((verificationField.text!.trimmingCharacters(in: .whitespacesAndNewlines) as NSString).intValue)) { [self] answer in
            confirmButton.isEnabled = true
            removeNotificationView { [self] _ in
                if answer.success {
                    
                    personalInfo.isAuthorised = true
                    personalInfo.emailAddress = self.userInfo!.email
                    personalInfo.password = self.userInfo!.password
                    
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
                        let addTagViewViewController = viewConstrollers.popLast()
                        
                        self.navigationController?.popToViewController(addTagViewViewController!, animated: true)
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
                    if answer.status == 409 {
                        verificationConstraint.priority = UILayoutPriority(rawValue: 1000)
                        
                        verificationNotice.alpha = 0.0
                        verificationNotice.isHidden = false
                        
                        UIView.animate(withDuration: 0.4) { [self] in
                            verificationNotice.alpha = 1.0
                            self.view.layoutIfNeeded()
                        }
                        
                        viewDidLayoutSubviews()
                    } else if answer.status == 403 {
                        placeNotificationsView(event: .codeTimeOut)
                    } else if answer.status == 433 {
                        placeNotificationsView(event: .serverOff)
                    } else {
                        placeNotificationsView(event: .error)
                    }
                }
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
