//
//  ResetPasswordViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 29.05.2021.
//

import UIKit

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var resetView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var emailNotice: UILabel!
    @IBOutlet weak var emailConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var noToUse: NSLayoutConstraint!
    
    var notificationView: UIView?
    
    private var willBeDeinited: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
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
        
        resetView.layer.cornerRadius = 16
        Helpers().addShadow(view: resetView)
        emailField.layer.masksToBounds = true
        emailField.layer.cornerRadius = 12
        sendButton.layer.masksToBounds = true
        sendButton.layer.cornerRadius = 12
        
        emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        emailField.leftViewMode = .always
        emailField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        emailField.rightViewMode = .always
        
        emailField.delegate = self
        emailField.becomeFirstResponder()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        emailNotice.isHidden = true
        emailConstraint.priority = UILayoutPriority(rawValue: 400)
        
        emailField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        emailField.addTarget(self, action: #selector(emailChanged), for: .editingDidBegin)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendPassword((Any).self)
        return true
    }
    
    @IBAction func sendPassword(_ sender: Any) {
        if Helpers().isSutableEmail(email: emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") {
            self.resignFirstResponder()
            self.sendButton.isEnabled = false
            placeNotificationsView(event: .loading)
            
            Server.shared.resetPassword(email: emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) { [self] answer in
                self.sendButton.isEnabled = true
                removeNotificationView { [self] _ in
                    if answer.success {
                        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
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
                        } else if answer.status == 433 {
                            placeNotificationsView(event: .serverOff)
                        } else {
                            placeNotificationsView(event: .error)
                        }
                    }
                }
            }
        } else {
            emailConstraint.priority = UILayoutPriority(rawValue: 1000)
            
            emailNotice.alpha = 0.0
            emailNotice.isHidden = false
            
            UIView.animate(withDuration: 0.4) { [self] in
                emailNotice.alpha = 1.0
                self.view.layoutIfNeeded()
            }
            viewDidLayoutSubviews()
        }
    }
    
    @objc func emailChanged() {
        emailConstraint.priority = UILayoutPriority(rawValue: 400)
        
        emailNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            emailNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        emailNotice.isHidden = true
        
        viewDidLayoutSubviews()
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
