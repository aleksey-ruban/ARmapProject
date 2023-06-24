//
//  WriteReviewViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 10.06.2021.
//

import UIKit

class WriteReviewViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var impressionView: UIView!
    @IBOutlet weak var impressionTextView: UITextView!
    @IBOutlet weak var impressionsFakeField: UITextField!
    @IBOutlet weak var impressionViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var markNotice: UILabel!
    @IBOutlet weak var impressionsNotice: UILabel!
    @IBOutlet weak var impressionsConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addReviewButtom: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    public var tagsId: Int!
    
    public var currentMark: Int = 0
    public var reviewId: Int?
    public var pastText: String?
        
    private var starStackView: UIStackView?
    
    private let selectFeedback = UISelectionFeedbackGenerator()
    
    private var keyboardHeigth: CGFloat = 0.0
    
    var notificationView: UIView?
    
    private var willBeDeinited: Bool = true
    
    // MARK: - View Controller's Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        willBeDeinited = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.layoutSubviews()
        
        if scrollView.frame.height - globalVariables.bottomScreenLength - keyboardHeigth >= addReviewButtom.frame.maxY + 12 {
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
        } else {
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: impressionView.frame.maxY + keyboardHeigth - globalVariables.bottomScreenLength)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if willBeDeinited {
            notificationView?.removeFromSuperview()
            notificationView = nil
            impressionTextView.delegate = nil
            starStackView?.removeFromSuperview()
            starStackView = nil
            reviewId = nil
            pastText = nil 
        }
    }
    
    // MARK: - Setup Scene
    
    func setupScene() {
        
        scrollViewBottom.constant = -globalVariables.bottomScreenLength
        
        buildStarsStackView()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        impressionView.layer.cornerRadius = 16
        Helpers().addShadow(view: impressionView)
        addReviewButtom.layer.cornerRadius = 16
        Helpers().addShadow(view: addReviewButtom)
        impressionTextView.layer.masksToBounds = true
        impressionTextView.layer.cornerRadius = 12
        impressionTextView.delegate = self
        
        impressionsFakeField.layer.masksToBounds = true
        impressionsFakeField.layer.cornerRadius = 12
        impressionsFakeField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        impressionsFakeField.leftViewMode = .always
        
        if pastText != nil && reviewId != nil {
            impressionTextView.text = pastText
            impressionTextView.backgroundColor = UIColor(named: "background")
            
            let barButtom = UIBarButtonItem(image: UIImage(systemName: "trash"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(deleteReview))
            barButtom.tintColor = .systemRed
            self.navigationItem.rightBarButtonItems = [barButtom]
            
            if globalVariables.currentLanguage == "en" {
                self.title = "Edit review"
                addReviewButtom.setTitle("Save changes", for: .normal)
            } else {
                self.title = "Редактировать отзыв"
                addReviewButtom.setTitle("Сохранить изменения", for: .normal)
            }
        }
        
        impressionTextView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        selectFeedback.prepare()
        
        markNotice.isHidden = true
        impressionsNotice.isHidden = true
        impressionsConstraint.priority = UILayoutPriority(rawValue: 400)
        
        
    }
 
    // MARK: - Build Star Stack View
    
    func buildStarsStackView() {
        
        starStackView = UIStackView()
        starStackView?.translatesAutoresizingMaskIntoConstraints = false
        starStackView!.axis = .horizontal
        starStackView!.distribution = .fillEqually
        starStackView!.spacing = 7
        
        for i in 0...4 {
            let starImageView = UIImageView()
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            if i <= currentMark - 1 {
                starImageView.image = UIImage(systemName: "star.fill")
                starImageView.tintColor = .systemYellow
            } else {
                starImageView.image = UIImage(systemName: "star")
                starImageView.tintColor = UIColor(named: "textGrey")
            }
            
            starImageView.tag = i
            starImageView.isUserInteractionEnabled = true
            
            starImageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: 34).isActive = true
            
            starStackView!.addArrangedSubview(starImageView)
            
            let selectStar = UITapGestureRecognizer(target: self, action: #selector(setNewMark))
            selectStar.view?.tag = i
            starImageView.addGestureRecognizer(selectStar)
        }
        
        scrollView.addSubview(starStackView!)
        
        starStackView?.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
        starStackView?.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 40).isActive = true
        
    }
    
    // MARK: - New Mark
    
    @objc func setNewMark(_ sender: UITapGestureRecognizer) {
        
        selectFeedback.selectionChanged()
        
        markNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            markNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        markNotice.isHidden = true
        
        currentMark = sender.view!.tag + 1
        UIView.transition(with: self.starStackView!, duration: 0.2, options: .transitionCrossDissolve, animations: { [self] in
            for star in 0...starStackView!.arrangedSubviews.count - 1 {
                if currentMark > star {
                    let imageView: UIImageView = starStackView!.arrangedSubviews[star] as! UIImageView
                    imageView.image = UIImage(systemName: "star.fill")
                    starStackView!.subviews[star].tintColor = .systemYellow
                } else {
                    let imageView: UIImageView = starStackView!.arrangedSubviews[star] as! UIImageView
                    imageView.image = UIImage(systemName: "star")
                    starStackView!.subviews[star].tintColor = UIColor(named: "textGrey")
                }
            }
        }, completion: nil)
        
    }

    // MARK: - Add review function
    
    @IBAction func addReview(_ sender: Any) {
        
        var text: String? = ""
        
        text = impressionTextView.text

        if text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" && text?.trimmingCharacters(in: .whitespacesAndNewlines) != nil && currentMark != 0 {
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC+3")
            dateFormatter.dateFormat = "dd.MM yyyy"
        
            let date = Date()
            
            if pastText != nil && reviewId != nil && !(personalInfo.userAccount?.isBanned ?? true) {
                let rewriteForm = RewriteReview(reviewId: reviewId!, mark: currentMark, date: dateFormatter.string(from: date), text: text!.trimmingCharacters(in: .whitespacesAndNewlines))
                self.addReviewButtom.isEnabled = false
                self.placeNotificationsView(event: .loading)
                
                Server.shared.rewriteReview(form: rewriteForm) { [self] answer in
                    self.addReviewButtom.isEnabled = true
                    self.removeNotificationView { [self] _ in
                        if answer.success {
                            let review = Review(reviewId: reviewId!, authorId: personalInfo.userAccount!.userId, authorAvatar: personalInfo.userAccount!.avatar, authorName: personalInfo.userAccount!.name, authorNickname: personalInfo.userAccount!.nickname, mark: currentMark, date: dateFormatter.string(from: date), text: text!.trimmingCharacters(in: .whitespacesAndNewlines))
                            
                            var index = globalVariables.allTags.firstIndex { tag in
                                return tag.tagsId == tagsId
                            }
                            var index1 = globalVariables.allTags[index!].reviews?.firstIndex(where: { review in
                                return review.reviewId == reviewId!
                            })
                            globalVariables.allTags[index!].reviews?[index1!] = review
                            
                            index = globalVariables.listOfAvailableTags.firstIndex(where: { tag in
                                return tag.tagsId == tagsId
                            })
                            index1 = globalVariables.listOfAvailableTags[index!].reviews?.firstIndex(where: { review in
                                return review.reviewId == reviewId!
                            })
                            globalVariables.listOfAvailableTags[index!].reviews?[index1!] = review
                            
                            let currentVC = self.navigationController?.topViewController
                            
                            guard let viewConstrollers = currentVC?.navigationController?.viewControllers else {
                                return
                            }
                            
                            for i in viewConstrollers {
                                if i is InfoViewController {
                                    let infoVC = i as! InfoViewController
                                    if infoVC.tag.tagsId == tagsId {
                                        index1 = infoVC.tag.reviews?.firstIndex(where: { review in
                                            return review.reviewId == reviewId!
                                        })
                                        infoVC.tag.reviews?[index1!] = review
                                    }
                                } else if i is AccountInfoViewController {
                                    let accountInfoVC = i as! AccountInfoViewController
                                    
                                    if accountInfoVC.isAnotherUserAccount {
                                        index = accountInfoVC.anotherUserPrivateTags.firstIndex(where: { tag in
                                            return tag.tagsId == tagsId
                                        })
                                        if let indexN = index {
                                            index1 = accountInfoVC.anotherUserPrivateTags[indexN].reviews?.firstIndex(where: { review in
                                                return review.reviewId == reviewId!
                                            })
                                            accountInfoVC.anotherUserPrivateTags[indexN].reviews?[index1!] = review
                                        }

                                        index = accountInfoVC.anotherUserPublicTags.firstIndex(where: { tag in
                                            return tag.tagsId == tagsId
                                        })
                                        if let indexN = index {
                                            index1 = accountInfoVC.anotherUserPublicTags[indexN].reviews?.firstIndex(where: { review in
                                                return review.reviewId == reviewId!
                                            })
                                            accountInfoVC.anotherUserPublicTags[indexN].reviews?[index1!] = review
                                        }
                                    }
                                } else if i is TagsListViewController {
                                    let tagsListVC = i as! TagsListViewController
                                    if !tagsListVC.isMyTags {
                                        
                                        index = tagsListVC.personalTags.firstIndex { tag in
                                            return tag.tagsId == tagsId
                                        }
                                        if index != nil {
                                            index1 = tagsListVC.personalTags[index!].reviews?.firstIndex(where: { review in
                                                return review.reviewId == reviewId!
                                            })
                                            tagsListVC.personalTags[index!].reviews?[index1!] = review
                                        }
                                        
                                        index = tagsListVC.publicTags.firstIndex(where: { tag in
                                            return tag.tagsId == tagsId
                                        })
                                        if index != nil {
                                            index1 = tagsListVC.publicTags[index!].reviews?.firstIndex(where: { review in
                                                return review.reviewId == reviewId!
                                            })
                                            tagsListVC.publicTags[index!].reviews?[index1!] = review
                                        }
                                        
                                        index = tagsListVC.filteredPersonalTags.firstIndex(where: { tag in
                                            return tag.tagsId == tagsId
                                        })
                                        if index != nil {
                                            index1 = tagsListVC.filteredPersonalTags[index!].reviews?.firstIndex(where: { review in
                                                return review.reviewId == reviewId!
                                            })
                                            tagsListVC.filteredPersonalTags[index!].reviews?[index1!] = review
                                        }
                                        
                                        index = tagsListVC.filteredPublicTags.firstIndex(where: { tag in
                                            return tag.tagsId == tagsId
                                        })
                                        if index != nil {
                                            index1 = tagsListVC.filteredPublicTags[index!].reviews?.firstIndex(where: { review in
                                                return review.reviewId == reviewId!
                                            })
                                            tagsListVC.filteredPublicTags[index!].reviews?[index1!] = review
                                        }
                                    }
                                }
                            }
                            self.navigationController?.popViewController(animated:true)
                            
                            if globalVariables.offlineMode {
                                UserDefaults.standard.set(try? PropertyListEncoder().encode(globalVariables.allTags), forKey:"offlineTagsList")
                            }
                        } else {
                            if answer.status == 433 {
                                placeNotificationsView(event: .serverOff)
                            } else {
                                placeNotificationsView(event: .error)
                            }
                        }
                    }                    
                }
            } else if !(personalInfo.userAccount?.isBanned ?? true) {
                let reviewForm = WriteReviewForm(tagsId: tagsId, authorId:personalInfo.userAccount!.userId, mark: currentMark, date: dateFormatter.string(from: date), text: text!.trimmingCharacters(in: .whitespacesAndNewlines))
                self.addReviewButtom.isEnabled = false
                self.placeNotificationsView(event: .loading)
                
                Server.shared.writeReview(form: reviewForm) { [self] answer in
                    self.addReviewButtom.isEnabled = true
                    self.removeNotificationView { [self] _ in
                        if answer.success {
                            let review = Review(reviewId: answer.reviewsId, authorId: personalInfo.userAccount!.userId, authorAvatar: personalInfo.userAccount!.avatar, authorName: personalInfo.userAccount!.name, authorNickname: personalInfo.userAccount!.nickname, mark: currentMark, date: dateFormatter.string(from: date), text: text!.trimmingCharacters(in: .whitespacesAndNewlines))
                            
                            var index = globalVariables.allTags.firstIndex { tag in
                                return tag.tagsId == tagsId
                            }
                            globalVariables.allTags[index!].reviews?.append(review)
                            
                            index = globalVariables.listOfAvailableTags.firstIndex(where: { tag in
                                return tag.tagsId == tagsId
                            })
                            globalVariables.listOfAvailableTags[index!].reviews?.append(review)
                            
                            let currentVC = self.navigationController?.topViewController
                            
                            guard let viewConstrollers = currentVC?.navigationController?.viewControllers else {
                                return
                            }
                            
                            for i in viewConstrollers {
                                if i is InfoViewController {
                                    let infoVC = i as! InfoViewController
                                    if infoVC.tag.tagsId == tagsId {
                                        infoVC.tag.reviews?.append(review)
                                    }
                                } else if i is AccountInfoViewController {
                                    let accountInfoVC = i as! AccountInfoViewController
                                    
                                    if accountInfoVC.isAnotherUserAccount {
                                        var index = accountInfoVC.anotherUserPrivateTags.firstIndex(where: { tag in
                                            return tag.tagsId == tagsId
                                        })
                                        if let indexN = index {
                                            accountInfoVC.anotherUserPrivateTags[indexN].reviews?.append(review)
                                        }
                                        
                                        index = accountInfoVC.anotherUserPublicTags.firstIndex(where: { tag in
                                            return tag.tagsId == tagsId
                                        })
                                        if let indexN = index {
                                            accountInfoVC.anotherUserPublicTags[indexN].reviews?.append(review)
                                        }
                                    }
                                } else if i is TagsListViewController {
                                    let tagsListVC = i as! TagsListViewController
                                    if !tagsListVC.isMyTags {
                                        
                                        var index = tagsListVC.personalTags.firstIndex { tag in
                                            return tag.tagsId == tagsId
                                        }
                                        if let indexN = index {
                                            tagsListVC.personalTags[indexN].reviews?.append(review)
                                        }
                                        
                                        index = tagsListVC.publicTags.firstIndex(where: { tag in
                                            return tag.tagsId == tagsId
                                        })
                                        if let indexN = index {
                                            tagsListVC.publicTags[indexN].reviews?.append(review)
                                        }
                                        
                                        index = tagsListVC.filteredPersonalTags.firstIndex(where: { tag in
                                            return tag.tagsId == tagsId
                                        })
                                        if let indexN = index {
                                            tagsListVC.filteredPersonalTags[indexN].reviews?.append(review)
                                        }
                                        
                                        index = tagsListVC.filteredPublicTags.firstIndex(where: { tag in
                                            return tag.tagsId == tagsId
                                        })
                                        if let indexN = index {
                                            tagsListVC.filteredPublicTags[indexN].reviews?.append(review)
                                        }
                                    }
                                }
                            }
                            self.navigationController?.popViewController(animated:true)
                            
                            if globalVariables.offlineMode {
                                UserDefaults.standard.set(try? PropertyListEncoder().encode(globalVariables.allTags), forKey:"offlineTagsList")
                            }
                        } else {
                            if answer.status == 433 {
                                placeNotificationsView(event: .serverOff)
                            } else {
                                placeNotificationsView(event: .error)
                            }
                        }
                    }
                }
            } else if personalInfo.userAccount?.isBanned ?? true {
                placeNotificationsView(event: .banned)
            }
        } else {
            if text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || text?.trimmingCharacters(in: .whitespacesAndNewlines) == nil {
                impressionsConstraint.priority = UILayoutPriority(rawValue: 1000)
                
                impressionsNotice.alpha = 0.0
                impressionsNotice.isHidden = false
                
                UIView.animate(withDuration: 0.4) { [self] in
                    impressionsNotice.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
                
                viewDidLayoutSubviews()
            }
            if currentMark == 0 {
                
                markNotice.alpha = 0.0
                markNotice.isHidden = false
                
                UIView.animate(withDuration: 0.4) { [self] in
                    markNotice.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Text View's Delegate functions
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        impressionsConstraint.priority = UILayoutPriority(rawValue: 400)
        
        impressionsNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            impressionsNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        impressionsNotice.isHidden = true
        
        viewDidLayoutSubviews()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       
        if text == "\n" {
            let visiblePart = scrollView.frame.height - keyboardHeigth - 43
            var yToScroll = impressionView.frame.maxY - (impressionView.frame.size.height - impressionTextView.frame.maxY) - visiblePart
            if yToScroll < 0 { yToScroll = 0}
            scrollView.setContentOffset(CGPoint(x: 0, y: yToScroll), animated: true)
        }
        
        UIView.animate(withDuration: 0.2) { [self] in
            self.view.layoutIfNeeded()
        }
        viewDidLayoutSubviews()
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        impressionsConstraint.priority = UILayoutPriority(rawValue: 400)
        
        impressionsNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.25) { [self] in
            impressionsNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        impressionsNotice.isHidden = true
        
        viewDidLayoutSubviews()
        
        if textView.text == "" || textView.text == nil {
            textView.backgroundColor = .clear
        } else {
            textView.backgroundColor = UIColor(named: "background")
        }
        
    }
    
    // MARK: - Another
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectange = keyboardFrame.cgRectValue
            keyboardHeigth = max(keyboardHeigth, keyboardRectange.height)
        }
    }
    
    // MARK: - Delete review
    
    @objc func deleteReview() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var title1: String!
        var title2: String!
        if globalVariables.currentLanguage == "en" {
            title1 = "Cancel"
            title2 = "Delete review"
        } else {
            title1 = "Отменить"
            title2 = "Удалить отзыв"
        }
        actionSheet.addAction(UIAlertAction(title: title1, style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: title2, style: .destructive, handler: { _ in
            
            self.placeNotificationsView(event: .loading)
            Server.shared.deleteReview(email: personalInfo.emailAddress ?? "", password: personalInfo.password ?? "", reviewsId: self.reviewId!) { [self] answer in
                removeNotificationView { [self] _ in
                    if answer.success {
                        var index = globalVariables.allTags.firstIndex { tag in
                            return tag.tagsId == tagsId
                        }
                        globalVariables.allTags[index!].reviews?.removeAll(where: { review in
                            return review.reviewId == reviewId!
                        })
                        
                        index = globalVariables.listOfAvailableTags.firstIndex(where: { tag in
                            return tag.tagsId == tagsId
                        })
                        globalVariables.listOfAvailableTags[index!].reviews?.removeAll(where: { review in
                            return review.reviewId == reviewId!
                        })
                        
                        let currentVC = self.navigationController?.topViewController
                        
                        guard let viewConstrollers = currentVC?.navigationController?.viewControllers else {
                            return
                        }
                        
                        for i in viewConstrollers {
                            if i is InfoViewController {
                                let infoVC = i as! InfoViewController
                                infoVC.tag.reviews?.removeAll(where: { review in
                                    return review.reviewId == reviewId!
                                })
                            } else if i is AccountInfoViewController {
                                let accountInfoVC = i as! AccountInfoViewController
                                if accountInfoVC.isAnotherUserAccount {
                                    index = accountInfoVC.anotherUserPrivateTags.firstIndex(where: { tag in
                                        return tag.tagsId == tagsId!
                                    })
                                    if index != nil {
                                        accountInfoVC.anotherUserPrivateTags[index!].reviews?.removeAll(where: { review in
                                            return review.reviewId == reviewId!
                                        })
                                    }
                                    
                                    index = accountInfoVC.anotherUserPublicTags.firstIndex(where: { tag in
                                        return tag.tagsId == tagsId!
                                    })
                                    if index != nil {
                                        accountInfoVC.anotherUserPublicTags[index!].reviews?.removeAll(where: { review in
                                            return review.reviewId == reviewId!
                                        })
                                    }
                                }
                            } else if i is TagsListViewController {
                                let accountInfoVC = i as! TagsListViewController
                                if !accountInfoVC.isMyTags {
                                    index = accountInfoVC.personalTags.firstIndex(where: { tag in
                                        return tag.tagsId == tagsId!
                                    })
                                    if index != nil {
                                        accountInfoVC.personalTags[index!].reviews?.removeAll(where: { review in
                                            return review.reviewId == reviewId!
                                        })
                                    }
                                     
                                    index = accountInfoVC.publicTags.firstIndex(where: { tag in
                                        return tag.tagsId == tagsId!
                                    })
                                    if index != nil {
                                        accountInfoVC.publicTags[index!].reviews?.removeAll(where: { review in
                                            return review.reviewId == reviewId!
                                        })
                                    }
                                    
                                    index = accountInfoVC.filteredPersonalTags.firstIndex(where: { tag in
                                        return tag.tagsId == tagsId!
                                    })
                                    if index != nil {
                                        accountInfoVC.filteredPersonalTags[index!].reviews?.removeAll(where: { review in
                                            return review.reviewId == reviewId!
                                        })
                                    }
                                    
                                    index = accountInfoVC.filteredPublicTags.firstIndex(where: { tag in
                                        return tag.tagsId == tagsId!
                                    })
                                    if index != nil {
                                        accountInfoVC.filteredPublicTags[index!].reviews?.removeAll(where: { review in
                                            return review.reviewId == reviewId!
                                        })
                                    }
                                }
                            }
                        }
                        self.navigationController?.popViewController(animated:true)
                        
                        if globalVariables.offlineMode {
                            UserDefaults.standard.set(try? PropertyListEncoder().encode(globalVariables.allTags), forKey:"offlineTagsList")
                        }
                        
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
