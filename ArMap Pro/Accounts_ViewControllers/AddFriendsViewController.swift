//
//  AddFriendsViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 13.06.2021.
//

import UIKit

class AddFriendsViewConrtoller: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var searchPeopleLabel: UILabel!
    @IBOutlet weak var byNameLabel: UILabel!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var byNicknameLabel: UILabel!
    @IBOutlet weak var searchByStack: UIStackView!
    
    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var nameContainer: UIView!
    @IBOutlet weak var nikContainer: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    var peopleOnSearch: [Friend] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    var noResults: Bool = false
    
    var startedWaitingToRequest: Date? {
        willSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if Float(Date().timeIntervalSince(self.startedWaitingToRequest ?? Date())) >= 0.8 {
                    self.startedWaitingToRequest = nil
                    self.doRequest()
                }
            }
        }
    }
    
    var notificationView: UIView?
    var searchCounter = 0
    
    var tap: UITapGestureRecognizer?
    
    private var searchBarIsEmpty: Bool {

        guard let text = searchController.searchBar.text else {
            return false
        }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
        
    }
    private var searchTextIsEmpty: Bool = true {
        
        didSet {
            if searchTextIsEmpty {
                UIView.transition(with: self.scrollView!, duration: 0.3, options: .transitionCrossDissolve, animations: { [self] in
                    searchPeopleLabel.isHidden = false
                    searchByStack.isHidden = false
                    orLabel.isHidden = false
                    tableViewContainer.isHidden = true
                }, completion: nil)
            } else {
                UIView.transition(with: self.scrollView!, duration: 0.3, options: .transitionCrossDissolve, animations: { [self] in
                    searchPeopleLabel.isHidden = true
                    searchByStack.isHidden = true
                    orLabel.isHidden = true
                    tableViewContainer.isHidden = false
                }, completion: nil)
            }
        }
    }
    
    private var willBeDeinited: Bool = true
    
    let selectedFeedback = UISelectionFeedbackGenerator()
    
    // MARK: - View Controller's Life Cycle
    
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
        
        scrollView.layoutSubviews()
        
        if searchTextIsEmpty {
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
        } else {
            if scrollView.frame.height - globalVariables.bottomScreenLength >= tableViewContainer.frame.maxY + 12 {
                scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
            } else {
                scrollView.contentSize = CGSize(width: scrollView.frame.width, height: tableViewContainer.frame.maxY + 20)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if willBeDeinited {
            notificationView?.removeFromSuperview()
            notificationView = nil
            tableView.delegate = nil
            tableView.dataSource = nil
            tap?.delegate = nil
            searchController.searchResultsUpdater = nil
        }
    }
    
    // MARK: - Setup Functions
    
    func setupScene() {
        
        scrollViewBottom.constant = -globalVariables.bottomScreenLength
        
        tableViewTop.constant = 20
        tableViewContainer.isHidden = true
        
        byNameLabel.layer.masksToBounds = true
        byNameLabel.layer.cornerRadius = 45
        nameContainer.layer.cornerRadius = 45
        Helpers().addShadow(view: nameContainer)
        byNicknameLabel.layer.masksToBounds = true
        byNicknameLabel.layer.cornerRadius = 45
        nikContainer.layer.cornerRadius = 45
        Helpers().addShadow(view: nikContainer)
        tableView.layer.cornerRadius = 16
        tableViewContainer.layer.cornerRadius = 16
        Helpers().addShadow(view: tableViewContainer)
        

        
        self.view.layoutSubviews()
        
        let horizontSpacing = self.view.frame.width * 0.8
        
        stackWidth.constant = horizontSpacing
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        if globalVariables.currentLanguage == "en" {
            searchController.searchBar.placeholder = "Search"
        } else {
            searchController.searchBar.placeholder = "Поиск"
        }
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        selectedFeedback.selectionChanged()
        
        tap = UITapGestureRecognizer(target: self, action: #selector(endOfSearching))
        tap!.delegate = self
        
        self.view.addGestureRecognizer(tap!)
    }
    
    // MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noResults { return 1 }
        if peopleOnSearch.count == 0 { return 1 }
        return peopleOnSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if noResults {
            cell = tableView.dequeueReusableCell(withIdentifier: "noSearchPossibleFriend", for: indexPath)
        } else if peopleOnSearch.count == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "searching", for: indexPath)
            (cell.viewWithTag(8) as! UIActivityIndicatorView).startAnimating()
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "possibleFriendCell", for: indexPath)
            let avatar = cell.viewWithTag(2) as! UIImageView
            let name = cell.viewWithTag(3) as! UILabel
            let nickname = cell.viewWithTag(4) as! UILabel
            let button = cell.viewWithTag(5) as! UIButton
            
            avatar.layer.masksToBounds = true
            avatar.layer.cornerRadius = 26
            
            if peopleOnSearch[indexPath.row].avatar != nil {
                avatar.image = Helpers().imageFromString(string: peopleOnSearch[indexPath.row].avatar!)
            } else {
                avatar.image = UIImage(systemName: "person.circle.fill")
            }
            name.text = peopleOnSearch[indexPath.row].name
            if peopleOnSearch[indexPath.row].nickname == nil || peopleOnSearch[indexPath.row].nickname == "" {
                nickname.isHidden = true
                name.removeFromSuperview()
                cell.contentView.addSubview(name)
                name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10).isActive = true
                name.centerYAnchor.constraint(equalTo: avatar.centerYAnchor).isActive = true
            } else {
                nickname.text = peopleOnSearch[indexPath.row].nickname
                nickname.isHidden = false
                name.removeFromSuperview()
                cell.contentView.addSubview(name)
                name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10).isActive = true
                name.centerYAnchor.constraint(equalTo: avatar.centerYAnchor, constant: -10).isActive = true
            }
            
            if personalInfo.userAccount?.friends.contains(where: { friend in
                return friend.userId == peopleOnSearch[indexPath.row].userId
            }) ?? false || personalInfo.userAccount?.requestToFriends.contains(where: { friendId in
                return friendId == peopleOnSearch[indexPath.row].userId
            }) ?? false {
                button.setImage(UIImage(systemName: "person.fill.checkmark.rtl"), for: .normal)
                button.tintColor = UIColor(named: "textGrey")
                button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
            } else {
                button.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
                button.tintColor = .systemBlue
                button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                button.addAction(addPossibleFriend(indexPath: indexPath), for: .touchUpInside)
            }
        }
        return cell
    }
    
    func addPossibleFriend(indexPath: IndexPath) -> UIAction {
        let action = UIAction(title: "") { [self] _ in
            let button = self.tableView.cellForRow(at: indexPath)?.viewWithTag(5) as! UIButton
            button.isEnabled = false
            if personalInfo.userAccount?.waitingFriends.contains(peopleOnSearch[indexPath.row]) ?? false || personalInfo.userAccount?.followers.contains(peopleOnSearch[indexPath.row].userId) ?? false {
                
                tableView.isUserInteractionEnabled = false
                placeNotificationsView(event: .loading)
                
                Server.shared.addFriend(form: AddFriendForm(myId: personalInfo.userAccount!.userId, userId: self.peopleOnSearch[indexPath.row].userId)) { [self] answer in
                    tableView.isUserInteractionEnabled = true
                    removeNotificationView { [self] _ in
                        if answer.success {
                            
                            let currentVC = self.navigationController?.topViewController
                            
                            guard let viewConstrollers = currentVC?.navigationController?.viewControllers else { return }
                            
                            let friend = Friend(name: peopleOnSearch[indexPath.row].name, userId: peopleOnSearch[indexPath.row].userId, avatar: peopleOnSearch[indexPath.row].avatar, nickname: peopleOnSearch[indexPath.row].nickname)
                            for i in viewConstrollers {
                                if i is FriendsViewController {
                                    let friendsListVC = i as! FriendsViewController
                                    if friendsListVC.isMyFriendsList {
                                        friendsListVC.friends.append(friend)
                                        friendsListVC.requestsForFriendship.removeAll { friend in
                                            return friend.userId == peopleOnSearch[indexPath.row].userId
                                        }
                                    }
                                }
                            }
                            personalInfo.userAccount?.friends.append(friend)
                            personalInfo.userAccount?.waitingFriends.removeAll(where: { friend1 in
                                return friend1.userId == friend.userId
                            })
                            personalInfo.userAccount?.followers.removeAll(where: { val in
                                return val == friend.userId
                            })
                            
                            self.selectedFeedback.selectionChanged()
                            
                            button.isEnabled = true

                            UIView.transition(with: button, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                button.setImage(UIImage(systemName: "person.fill.checkmark.rtl"), for: .normal)
                                button.tintColor = UIColor(named: "textGrey")
                                button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
                                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
                                button.removeTarget(nil, action: nil, for: .allEvents)
                            }, completion: nil)
                        } else {
                            button.isEnabled = true
                            if answer.status == 433 {
                                placeNotificationsView(event: .serverOff)
                            } else {
                                placeNotificationsView(event: .error)
                            }
                        }
                    }
                }
            } else {
                tableView.isUserInteractionEnabled = false
                placeNotificationsView(event: .loading)
                
                Server.shared.sendRequestToFriend(form: AddFriendForm(myId: personalInfo.userAccount!.userId, userId: self.peopleOnSearch[indexPath.row].userId)) { [self] answer in
                    tableView.isUserInteractionEnabled = true
                    removeNotificationView { [self] _ in
                        if answer.success {
                            personalInfo.userAccount?.requestToFriends.append(peopleOnSearch[indexPath.row].userId)
                            self.selectedFeedback.selectionChanged()
                            
                            button.isEnabled = true

                            UIView.transition(with: button, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                button.setImage(UIImage(systemName: "person.fill.checkmark.rtl"), for: .normal)
                                button.tintColor = UIColor(named: "textGrey")
                                button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
                                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
                                button.removeTarget(nil, action: nil, for: .allEvents)
                            }, completion: nil)
                        } else {
                            button.isEnabled = true
                            if answer.status == 433 {
                                placeNotificationsView(event: .serverOff)
                            } else {
                                placeNotificationsView(event: .error)
                            }
                        }
                    }
                }
            }
        }
        return action
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.isSelected = false
        
        if tableView.cellForRow(at: indexPath)?.tag == 1 {
            
            tableView.isUserInteractionEnabled = false
            placeNotificationsView(event: .loading)
            
            Server.shared.getUser(userId: peopleOnSearch[indexPath.row].userId) { userOpt in
                tableView.isUserInteractionEnabled = true
                self.removeNotificationView { [self] _ in
                    guard let user = userOpt else {
                        self.placeNotificationsView(event: .error)
                        return
                    }
                    if user is User {
                        willBeDeinited = false
                        
                        let storyboard = UIStoryboard(name: "Accounts", bundle: nil)
                        let VC = storyboard.instantiateViewController(identifier: "AccountIfoViewController") as! AccountInfoViewController
                        VC.isAnotherUserAccount = true
                        VC.anotherUserAccount = user as? User
                        VC.modalPresentationStyle = .fullScreen
                        VC.modalTransitionStyle = .crossDissolve
                        
                        self.navigationController?.pushViewController(VC, animated: true)
                    } else if user is ServerAnswer {
                        if (user as! ServerAnswer).status == 433 {
                            placeNotificationsView(event: .serverOff)
                        } else {
                            placeNotificationsView(event: .error)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Search Bar functions
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text!
        if searchText == "" && searchTextIsEmpty == false {
            searchTextIsEmpty = true
        } else if searchText != "" && searchTextIsEmpty == true {
            searchTextIsEmpty = false
        }
        
        noResults = false
        peopleOnSearch = []
        
        tableView.reloadData()
        
        if searchText != "" {
            
            UIView.transition(with: self.scrollView, duration: 0.2, options: .transitionCrossDissolve, animations: { [self] in
                
                tableView.reloadData()
                tableViewHeight?.constant = 69
            })
            startedWaitingToRequest = Date()
            
        } else {
            UIView.transition(with: self.scrollView, duration: 0.2, options: .transitionCrossDissolve, animations: { [self] in
                tableView.reloadData()
                
                var tableViewHeightVal = CGFloat(peopleOnSearch.count * 70 - 1)
                if tableViewHeightVal == -1 { tableViewHeightVal = 69}
                tableViewHeight?.constant = tableViewHeightVal
            })
        }
        
        self.viewDidLayoutSubviews()
    }
    
    func doRequest() {
        let searchText = searchController.searchBar.text!
        if searchText == "" {
            return
        }
        
        Server.shared.searchPeople(text: searchText.urlEncoded()) { [self] list in
            if list is Array<Friend> {
                if (list as! Array<Friend>).count != 0 {
                    peopleOnSearch = list as! Array<Friend>
                    peopleOnSearch.removeAll { friend in
                        return friend.userId == personalInfo.userAccount?.userId
                    }
                    if peopleOnSearch.count != 0 {
                        noResults = false
                    } else {
                        noResults = true
                    }
                    tableView.reloadData()
                } else {
                    noResults = true
                    peopleOnSearch = list as! Array<Friend>
                    tableView.reloadData()
                }
                UIView.transition(with: self.scrollView, duration: 0.2, options: .transitionCrossDissolve, animations: { [self] in
                    tableView.reloadData()
                    
                    var tableViewHeightVal = CGFloat(peopleOnSearch.count * 70 - 1)
                    if tableViewHeightVal == -1 { tableViewHeightVal = 69}
                    tableViewHeight?.constant = tableViewHeightVal
                })
                searchCounter = 0
            } else if list is ServerAnswer {
                if searchCounter == 0 {
                    if (list as! ServerAnswer).status == 433 {
                        placeNotificationsView(event: .serverOff)
                    } else {
                        placeNotificationsView(event: .error)
                    }
                }
                noResults = true
                peopleOnSearch = []
                tableView.reloadData()

                UIView.transition(with: self.scrollView, duration: 0.2, options: .transitionCrossDissolve, animations: { [self] in
                    tableView.reloadData()
                    
                    var tableViewHeightVal = CGFloat(peopleOnSearch.count * 70 - 1)
                    if tableViewHeightVal == -1 { tableViewHeightVal = 69}
                    tableViewHeight?.constant = tableViewHeightVal
                })
                searchCounter = 1
            }
        }
    }
    
    // MARK: - Another functions
    
    @IBAction func startSearch(_ sender: Any) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    
    // MARK: - Gesture Recognizer Functions
    
    @objc func endOfSearching() {
        if searchBarIsEmpty {
            self.searchController.isActive = false
        } else {
            self.searchController.searchBar.endEditing(true)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == scrollView { return true }
        return false
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
