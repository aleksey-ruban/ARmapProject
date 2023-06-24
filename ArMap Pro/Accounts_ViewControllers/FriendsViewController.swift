//
//  FriendsViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 24.05.2021.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var requestsLabel: UILabel!
    @IBOutlet weak var requestsTable: UITableView!
    @IBOutlet weak var requestsTableContainer: UIView!
    @IBOutlet weak var requestsTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var addFriendButton: UIButton!
    
    @IBOutlet weak var myFriendsLabel: UILabel!
    @IBOutlet weak var myFriendsTableView: UITableView!
    @IBOutlet weak var MyFriendsTableContainer: UIView!
    @IBOutlet weak var myFriendsTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var possibleFriendsLabel: UILabel!
    @IBOutlet weak var possibleFriendsTableView: UITableView!
    @IBOutlet weak var possibleFriendsTableContainer: UIView!
    @IBOutlet weak var possibleFriendsTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var scrollViewBottom: NSLayoutConstraint!
        
    public var friends: [Friend] = []
    public var possibleFriends: [Friend] = []
    public var requestsForFriendship: [Friend] = []
    
    private var filteredMyFriends: [Friend] = [Friend]()
    private var filteredPossibleFriends: [Friend] = [Friend]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {
            return false
        }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    var tap: UITapGestureRecognizer?
    
    var isMyFriendsList: Bool = false
    
    let selectedFeedback = UISelectionFeedbackGenerator()
    
    var notificationView: UIView?
    
    private var willBeDeinited: Bool = true
    
    // MARK: - View Controller's Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if requestsForFriendship.count == 0 {
            requestsLabel?.removeFromSuperview()
            requestsTableContainer?.removeFromSuperview()
        }
        
        requestsTable?.reloadData()
        myFriendsTableView.reloadData()
        if self.friends.count == 0 {
            self.myFriendsTableViewHeight.constant = 69
        } else {
            self.myFriendsTableViewHeight.constant = CGFloat(self.friends.count * 70 - 1)
        }
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
            myFriendsTableView.delegate = nil
            myFriendsTableView.dataSource = nil
            possibleFriendsTableView?.delegate = nil
            possibleFriendsTableView?.dataSource = nil
            requestsTable?.delegate = nil
            requestsTable?.dataSource = nil
            searchController.searchResultsUpdater = nil
            tap?.delegate = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.layoutSubviews()
        
        if possibleFriends.count != 0 {
            if scrollView.frame.height - globalVariables.bottomScreenLength >= possibleFriendsTableContainer.frame.maxY + 10 {
                scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
            } else {
                scrollView.contentSize = CGSize(width: scrollView.frame.width, height: possibleFriendsTableContainer.frame.maxY + 20)
            }
        } else {
            if scrollView.frame.height - globalVariables.bottomScreenLength >= MyFriendsTableContainer.frame.maxY + 10 {
                scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
                
            } else {
                scrollView.contentSize = CGSize(width: scrollView.frame.width, height: MyFriendsTableContainer.frame.maxY + 20)
            }
        }
    }

    // MARK: - Setup functions
    
    func setupScene() {
        
        selectedFeedback.prepare()
        
        scrollViewBottom.constant = -globalVariables.bottomScreenLength
        
        if !isMyFriendsList {
            addFriendButton.removeFromSuperview()
            possibleFriendsLabel.removeFromSuperview()
            possibleFriendsTableView.removeFromSuperview()
            if globalVariables.currentLanguage == "en" {
                myFriendsLabel.text = "Friends"
            } else {
                myFriendsLabel.text = "Друзья"
            }
            
            requestsLabel.removeFromSuperview()
            requestsTableContainer.removeFromSuperview()
        } else if requestsForFriendship.count == 0 {
            requestsLabel.removeFromSuperview()
            requestsTableContainer.removeFromSuperview()
        }
        
        if possibleFriends.count == 0 {
            possibleFriendsLabel?.removeFromSuperview()
            possibleFriendsTableView?.removeFromSuperview()
        }
        
        myFriendsTableView.delegate = self
        myFriendsTableView.dataSource = self
        possibleFriendsTableView?.delegate = self
        possibleFriendsTableView?.dataSource = self
        requestsTable?.delegate = self
        requestsTable?.dataSource = self
        
        myFriendsTableView.rowHeight = 70
        possibleFriendsTableView?.rowHeight = 70
        requestsTable?.rowHeight = 70
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        if globalVariables.currentLanguage == "en" {
            searchController.searchBar.placeholder = "Search"
        } else {
            searchController.searchBar.placeholder = "Поиск"
        }
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        addFriendButton?.layer.cornerRadius = 12
        Helpers().addShadow(view: addFriendButton)
        myFriendsTableView.layer.cornerRadius = 16
        MyFriendsTableContainer.layer.cornerRadius = 16
        Helpers().addShadow(view: MyFriendsTableContainer)
        possibleFriendsTableView?.layer.cornerRadius = 16
        possibleFriendsTableContainer.layer.cornerRadius = 16
        Helpers().addShadow(view: possibleFriendsTableContainer)
        requestsTable?.layer.cornerRadius = 16
        requestsTableContainer?.layer.cornerRadius = 16
        Helpers().addShadow(view: requestsTableContainer)
        
        var myFriendsHeight = CGFloat(friends.count * 70 - 1)
        if myFriendsHeight == -1 {
            myFriendsHeight = 69
        }
        myFriendsTableViewHeight.constant = myFriendsHeight
        possibleFriendsTableViewHeight.constant = CGFloat(possibleFriends.count * 70 - 1)
        requestsTableHeight.constant = CGFloat(requestsForFriendship.count * 70 - 1)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(endOfSearching))
        tap!.delegate = self
        
        self.view.addGestureRecognizer(tap!)
    }
    
    // MARK: - Tabel View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            if isFiltering {
                if filteredMyFriends.count == 0 {
                    return 1
                }
                return filteredMyFriends.count
            }
            if friends.count == 0 {
                return 1
            }
            return friends.count
        case 1:
            if isFiltering {
                if filteredPossibleFriends.count == 0 {
                    return 1
                }
                return filteredPossibleFriends.count
            }
            return possibleFriends.count
        case 2:
            return requestsForFriendship.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch tableView.tag {
        case 0:
            if isFiltering && filteredMyFriends.count == 0 && friends.count != 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath)
                let addButton = cell.viewWithTag(9) as! UIButton
                if globalVariables.currentLanguage == "en" {
                    addButton.setTitle("No search results", for: .normal)
                } else {
                    addButton.setTitle("Ничего не найдено", for: .normal)
                }
                
                addButton.setTitleColor(UIColor(named: "textGrey"), for: .normal)
                addButton.isEnabled = false
            } else {
                if friends.count == 0 {
                    cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath)
                    if !isMyFriendsList {
                        let addButton = cell.viewWithTag(9) as! UIButton
                        if globalVariables.currentLanguage == "en" {
                            addButton.setTitle("User haven't friends", for: .normal)
                        } else {
                            addButton.setTitle("Пользователь не добавил друзей", for: .normal)
                        }
                        addButton.setTitleColor(UIColor(named: "textGrey"), for: .normal)
                        addButton.isEnabled = false
                    }
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "myFriendCell", for: indexPath)
                    if isFiltering {
                        let avatarView = cell.viewWithTag(6) as! UIImageView
                        if filteredMyFriends[indexPath.row].avatar != nil {
                            avatarView.image = Helpers().imageFromString(string: filteredMyFriends[indexPath.row].avatar!)
                        }
                        
                        let name = cell.viewWithTag(7) as! UILabel
                        name.text = filteredMyFriends[indexPath.row].name
                        if filteredMyFriends[indexPath.row].nickname == nil || filteredMyFriends[indexPath.row].nickname == "" {
                            (cell.viewWithTag(8) as! UILabel).isHidden = true
                            name.removeFromSuperview()
                            cell.contentView.addSubview(name)
                            name.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10).isActive = true
                            name.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor).isActive = true
                        } else {
                            (cell.viewWithTag(8) as! UILabel).text = filteredMyFriends[indexPath.row].nickname
                            (cell.viewWithTag(8) as! UILabel).isHidden = false
                            name.removeFromSuperview()
                            cell.contentView.addSubview(name)
                            name.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10).isActive = true
                            name.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor, constant: -10).isActive = true
                        }
                    } else {
                        let avatarView = cell.viewWithTag(6) as! UIImageView
                        if friends[indexPath.row].avatar != nil {
                            avatarView.image = Helpers().imageFromString(string: friends[indexPath.row].avatar!)
                        }
                        
                        let name = cell.viewWithTag(7) as! UILabel
                        name.text = friends[indexPath.row].name
                        if friends[indexPath.row].nickname == nil || friends[indexPath.row].nickname == "" {
                            (cell.viewWithTag(8) as! UILabel).isHidden = true
                            name.removeFromSuperview()
                            cell.contentView.addSubview(name)
                            name.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10).isActive = true
                            name.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor).isActive = true
                        } else {
                            (cell.viewWithTag(8) as! UILabel).text = friends[indexPath.row].nickname
                            (cell.viewWithTag(8) as! UILabel).isHidden = false
                            name.removeFromSuperview()
                            cell.contentView.addSubview(name)
                            name.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10).isActive = true
                            name.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor, constant: -10).isActive = true
                        }
                    }
                    (cell.viewWithTag(6) as! UIImageView).layer.masksToBounds = true
                    (cell.viewWithTag(6) as! UIImageView).layer.cornerRadius = 26
                }
            }
        case 1:
            if isFiltering && filteredPossibleFriends.count == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "noSearchPossibleFriend", for: indexPath)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "possibleFriendCell", for: indexPath)
                
                let addButton = cell.viewWithTag(13) as! UIButton
                addButton.addAction(addPossibleFriend(indexPath: indexPath), for: .touchUpInside)
                
                if isFiltering {
                    let avatarView = cell.viewWithTag(10) as! UIImageView
                    if filteredPossibleFriends[indexPath.row].avatar != nil {
                        avatarView.image = Helpers().imageFromString(string: filteredPossibleFriends[indexPath.row].avatar!)
                    } else {
                        avatarView.image = UIImage(systemName: "person.circle.fill")
                    }
                    
                    let name = cell.viewWithTag(11) as! UILabel
                    name.text = filteredPossibleFriends[indexPath.row].name
                    if filteredPossibleFriends[indexPath.row].nickname == nil || filteredPossibleFriends[indexPath.row].nickname == "" {
                        (cell.viewWithTag(12) as! UILabel).isHidden = true
                        name.removeFromSuperview()
                        cell.contentView.addSubview(name)
                        name.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10).isActive = true
                        name.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor).isActive = true
                    } else {
                        (cell.viewWithTag(12) as! UILabel).text = filteredPossibleFriends[indexPath.row].nickname
                        (cell.viewWithTag(12) as! UILabel).isHidden = false
                        name.removeFromSuperview()
                        cell.contentView.addSubview(name)
                        name.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10).isActive = true
                        name.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor, constant: -10).isActive = true
                    }
                      
                    if personalInfo.userAccount?.friends.contains(where: { friend in
                        return friend.userId == filteredPossibleFriends[indexPath.row].userId
                    }) ?? false || personalInfo.userAccount?.requestToFriends.contains(where: { friendId in
                        return friendId == filteredPossibleFriends[indexPath.row].userId
                    }) ?? false {
                        addButton.setImage(UIImage(systemName: "person.fill.checkmark.rtl"), for: .normal)
                        addButton.tintColor = UIColor(named: "textGrey")
                        addButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
                        addButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
                    } else {
                        addButton.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
                        addButton.tintColor = .systemBlue
                        addButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
                        addButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    }
                } else {
                    let avatarView = cell.viewWithTag(10) as! UIImageView
                    if possibleFriends[indexPath.row].avatar != nil {
                        avatarView.image = Helpers().imageFromString(string: possibleFriends[indexPath.row].avatar!)
                    } else {
                        avatarView.image = UIImage(systemName: "person.circle.fill")
                    }
                    
                    let name = cell.viewWithTag(11) as! UILabel
                    name.text = possibleFriends[indexPath.row].name
                    if possibleFriends[indexPath.row].nickname == nil || possibleFriends[indexPath.row].nickname == "" {
                        (cell.viewWithTag(12) as! UILabel).isHidden = true
                        name.removeFromSuperview()
                        cell.contentView.addSubview(name)
                        name.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10).isActive = true
                        name.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor).isActive = true
                    } else {
                        (cell.viewWithTag(12) as! UILabel).text = possibleFriends[indexPath.row].nickname
                        (cell.viewWithTag(12) as! UILabel).isHidden = false
                        name.removeFromSuperview()
                        cell.contentView.addSubview(name)
                        name.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10).isActive = true
                        name.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor, constant: -10).isActive = true
                    }
         
                    if personalInfo.userAccount?.friends.contains(where: { friend in
                        return friend.userId == possibleFriends[indexPath.row].userId
                    }) ?? false || personalInfo.userAccount?.requestToFriends.contains(where: { friendId in
                        return friendId == possibleFriends[indexPath.row].userId
                    }) ?? false {
                        addButton.setImage(UIImage(systemName: "person.fill.checkmark.rtl"), for: .normal)
                        addButton.tintColor = UIColor(named: "textGrey")
                        addButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
                        addButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
                    } else {
                        addButton.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
                        addButton.tintColor = .systemBlue
                        addButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
                        addButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    }
                }
                (cell.viewWithTag(10) as! UIImageView).layer.masksToBounds = true
                (cell.viewWithTag(10) as! UIImageView).layer.cornerRadius = 26
                
            }
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "waitingFriend", for: indexPath)

            let avatarView = cell.viewWithTag(6) as! UIImageView
            if requestsForFriendship[indexPath.row].avatar != nil {
                avatarView.image = Helpers().imageFromString(string:requestsForFriendship[indexPath.row].avatar!)
            }
            let name = cell.viewWithTag(7) as! UILabel
            name.text = requestsForFriendship[indexPath.row].name
            if requestsForFriendship[indexPath.row].nickname == nil || requestsForFriendship[indexPath.row].nickname == "" {
                (cell.viewWithTag(8) as! UILabel).isHidden = true
                name.removeFromSuperview()
                cell.contentView.addSubview(name)
                name.leadingAnchor.constraint(equalTo:avatarView.trailingAnchor, constant: 10).isActive = true
                name.centerYAnchor.constraint(equalTo:avatarView.centerYAnchor).isActive = true
            } else {
                (cell.viewWithTag(8) as! UILabel).text = requestsForFriendship[indexPath.row].nickname
                (cell.viewWithTag(8) as! UILabel).isHidden = false
                name.removeFromSuperview()
                cell.contentView.addSubview(name)
                name.leadingAnchor.constraint(equalTo:avatarView.trailingAnchor, constant: 10).isActive = true
                name.centerYAnchor.constraint(equalTo:avatarView.centerYAnchor, constant: -10).isActive = true
            }
            (cell.viewWithTag(6) as! UIImageView).layer.masksToBounds = true
            (cell.viewWithTag(6) as! UIImageView).layer.cornerRadius = 26
            
            let addButton = cell.viewWithTag(9) as! UIButton
            let noButton = cell.viewWithTag(10) as! UIButton
            
            addButton.layer.masksToBounds = true
            addButton.layer.cornerRadius = 12
            
            noButton.layer.masksToBounds = true
            noButton.layer.cornerRadius = 12
            
            addButton.addAction(acceptFriend(indexPath: indexPath), for: .touchUpInside)
            noButton.addAction(refuseFriend(indexPath: indexPath), for: .touchUpInside)
            
        default:
            break
        }
        return cell
    }
    
    func acceptFriend(indexPath: IndexPath) -> UIAction {
        let action = UIAction { [self] _ in
            self.selectedFeedback.selectionChanged()
            
            let friend = self.requestsForFriendship[indexPath.row]
            
            requestsTable?.isUserInteractionEnabled = false
            myFriendsTableView?.isUserInteractionEnabled = false
            possibleFriendsTableView?.isUserInteractionEnabled = false
            placeNotificationsView(event: .loading)
            
            Server.shared.addFriend(form: AddFriendForm(myId: personalInfo.userAccount!.userId, userId: friend.userId)) { [self]
                answer in
                requestsTable?.isUserInteractionEnabled = true
                myFriendsTableView?.isUserInteractionEnabled = true
                possibleFriendsTableView?.isUserInteractionEnabled = true
                removeNotificationView { [self] _ in
                    if answer.success {
                        
                        personalInfo.userAccount?.friends.append(friend)
                        personalInfo.userAccount?.waitingFriends.removeAll(where: { friend1 in
                            return friend1.userId == friend.userId
                        })
                        self.friends.append(friend)
                        self.myFriendsTableView.reloadData()
                        if self.requestsForFriendship.count != 1 {
                            self.requestsTable!.deleteRows(at: [indexPath], with: .left)
                        }
                        self.requestsForFriendship.remove(at: indexPath.row)
                        
                        if self.requestsForFriendship.count == 0 {
                            UIView.animate(withDuration: 0.3) {
                                self.requestsLabel!.alpha = 0.0
                                self.requestsTable!.alpha = 0.0
                            } completion: { _ in
                                self.requestsLabel?.removeFromSuperview()
                                self.requestsTableContainer?.removeFromSuperview()
                                self.requestsLabel = nil
                                self.requestsTable = nil
                                self.requestsTableContainer = nil
                                self.myFriendsTableViewHeight.constant = CGFloat(self.friends.count * 70 - 1)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    UIView.animate(withDuration: 0.2) {
                                        self.view.layoutIfNeeded()
                                    }
                                }
                            }
                        } else {
                            self.requestsTableHeight.constant = CGFloat(self.requestsForFriendship.count * 70 - 1)
                            self.myFriendsTableViewHeight.constant = CGFloat(self.friends.count * 70 - 1)
                            UIView.animate(withDuration: 0.2) {
                                self.view.layoutIfNeeded()
                            }
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
        }
        return action
    }
    
    func refuseFriend(indexPath: IndexPath) -> UIAction {
        let action = UIAction { [self] _ in
            let friend = self.requestsForFriendship[indexPath.row]
            
            requestsTable?.isUserInteractionEnabled = false
            myFriendsTableView?.isUserInteractionEnabled = false
            possibleFriendsTableView?.isUserInteractionEnabled = false
            placeNotificationsView(event: .loading)
            
            Server.shared.refuseFriend(form: AddFriendForm(myId: personalInfo.userAccount!.userId, userId: friend.userId)) { [self] answer in
                requestsTable?.isUserInteractionEnabled = true
                myFriendsTableView?.isUserInteractionEnabled = true
                possibleFriendsTableView?.isUserInteractionEnabled = true
                removeNotificationView { [self] _ in
                    if answer.success {
                        
                        personalInfo.userAccount?.waitingFriends.removeAll(where: { friend1 in
                            return friend1.userId == friend.userId
                        })
                        personalInfo.userAccount!.followers.append(friend.userId)
                    
                        self.requestsForFriendship.remove(at: indexPath.row)
                        self.requestsTable!.deleteRows(at: [indexPath], with: .left)
                        if self.requestsForFriendship.count == 0 {
                            UIView.animate(withDuration: 0.3) {
                                self.requestsLabel!.alpha = 0.0
                                self.requestsTableContainer!.alpha = 0.0
                            } completion: { _ in
                                self.requestsLabel?.removeFromSuperview()
                                self.requestsTableContainer?.removeFromSuperview()
                                self.requestsLabel = nil
                                self.requestsTable = nil
                                self.requestsTableContainer = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    UIView.animate(withDuration: 0.2) {
                                        self.view.layoutIfNeeded()
                                    }
                                }
                            }
                        } else {
                            self.requestsTableHeight.constant = CGFloat(self.requestsForFriendship.count * 70 - 1)
                            UIView.animate(withDuration: 0.2) {
                                self.view.layoutIfNeeded()
                            }
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
        }
        return action
    }
    
    func addPossibleFriend(indexPath: IndexPath) -> UIAction {
        
        let action = UIAction(title: "") { [self] _ in
            let button = self.possibleFriendsTableView.cellForRow(at: indexPath)?.viewWithTag(5) as! UIButton
            button.isEnabled = false
            if personalInfo.userAccount?.waitingFriends.contains(possibleFriends[indexPath.row]) ?? false || personalInfo.userAccount?.followers.contains(possibleFriends[indexPath.row].userId) ?? false {
                requestsTable?.isUserInteractionEnabled = false
                myFriendsTableView?.isUserInteractionEnabled = false
                possibleFriendsTableView?.isUserInteractionEnabled = false
                placeNotificationsView(event: .loading)
                
                Server.shared.addFriend(form: AddFriendForm(myId: personalInfo.userAccount!.userId, userId: self.possibleFriends[indexPath.row].userId)) { [self] answer in
                    requestsTable?.isUserInteractionEnabled = true
                    myFriendsTableView?.isUserInteractionEnabled = true
                    possibleFriendsTableView?.isUserInteractionEnabled = true
                    removeNotificationView { [self] _ in
                        if answer.success {
                            
                            let currentVC = self.navigationController?.topViewController
                            
                            guard let viewConstrollers = currentVC?.navigationController?.viewControllers else { return }
                            
                            let friend = Friend(name: possibleFriends[indexPath.row].name, userId: possibleFriends[indexPath.row].userId, avatar: possibleFriends[indexPath.row].avatar, nickname: possibleFriends[indexPath.row].nickname)
                            for i in viewConstrollers {
                                if i is FriendsViewController {
                                    let friendsListVC = i as! FriendsViewController
                                    if friendsListVC.isMyFriendsList {
                                        friendsListVC.friends.append(friend)
                                        friendsListVC.requestsForFriendship.removeAll { friend in
                                            return friend.userId == possibleFriends[indexPath.row].userId
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
                requestsTable?.isUserInteractionEnabled = false
                myFriendsTableView?.isUserInteractionEnabled = false
                possibleFriendsTableView?.isUserInteractionEnabled = false
                placeNotificationsView(event: .loading)
                
                Server.shared.sendRequestToFriend(form: AddFriendForm(myId: personalInfo.userAccount!.userId, userId: self.possibleFriends[indexPath.row].userId)) { [self] answer in
                    requestsTable?.isUserInteractionEnabled = true
                    myFriendsTableView?.isUserInteractionEnabled = true
                    possibleFriendsTableView?.isUserInteractionEnabled = true
                    removeNotificationView { [self] _ in
                        if answer.success {
                            personalInfo.userAccount?.requestToFriends.append(possibleFriends[indexPath.row].userId)
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
        
        let selectedRow = tableView.cellForRow(at: indexPath)
        
        selectedRow?.isSelected = false
        
        if selectedRow!.tag == 3 && friends.count == 0 {
            return
        } else if selectedRow!.tag == 3 || selectedRow!.tag == 5 {
            return
        } else if selectedRow!.tag == 2 {
            print("")
        } else if selectedRow!.tag == 4 {
            print("")
        }
        
        var id: Int!
        switch tableView.tag {
        case 0:
            id = friends[indexPath.row].userId
        case 1:
            id = possibleFriends[indexPath.row].userId
        case 2:
            id = requestsForFriendship[indexPath.row].userId
        default:
            break
        }
        
        if personalInfo.userAccount?.userId == id {
            return
        }
        
        requestsTable?.isUserInteractionEnabled = false
        myFriendsTableView?.isUserInteractionEnabled = false
        possibleFriendsTableView?.isUserInteractionEnabled = false
        placeNotificationsView(event: .loading)
        
        Server.shared.getUser(userId: id) { [self] userOpt in
            requestsTable?.isUserInteractionEnabled = true
            myFriendsTableView?.isUserInteractionEnabled = true
            possibleFriendsTableView?.isUserInteractionEnabled = true
            removeNotificationView { [self] _ in
                guard let user = userOpt else {
                    placeNotificationsView(event: .error)
                    return
                }
                
                if user is User {
                    
                    self.willBeDeinited = false
                    
                    let storyboard = UIStoryboard(name: "Accounts", bundle: nil)
                    let VC = storyboard.instantiateViewController(identifier: "AccountIfoViewController") as! AccountInfoViewController
                    VC.isAnotherUserAccount = true
                    VC.anotherUserAccount = user as? User
                    VC.modalPresentationStyle = .fullScreen
                    VC.modalTransitionStyle = .crossDissolve
                    
                    self.navigationController?.pushViewController(VC, animated: true)
                } else {
                    if (user as! ServerAnswer).status == 433 {
                        placeNotificationsView(event: .serverOff)
                    } else {
                        placeNotificationsView(event: .error)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Search Controller Functions
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredMyFriends = friends.filter({ friend in
            return friend.name.lowercased().starts(with: searchText.lowercased())
        })
        filteredMyFriends += friends.filter({ friend in
            return friend.nickname?.lowercased().starts(with: searchText.lowercased()) ?? false && !filteredMyFriends.contains(friend)
        })
        filteredMyFriends += friends.filter({ friend in
            return friend.name.lowercased().contains(searchText.lowercased()) && !filteredMyFriends.contains(friend)
        })
        filteredMyFriends += friends.filter({ friend in
            return friend.nickname?.lowercased().contains(searchText.lowercased()) ?? false && !filteredMyFriends.contains(friend)
        })
        
        
        filteredPossibleFriends = possibleFriends.filter({ friend in
            return friend.name.lowercased().starts(with: searchText.lowercased())
        })
        filteredPossibleFriends += possibleFriends.filter({ friend in
            return friend.nickname?.lowercased().starts(with: searchText.lowercased()) ?? false && !filteredPossibleFriends.contains(friend)
        })
        filteredPossibleFriends += possibleFriends.filter({ friend in
            return friend.name.lowercased().contains(searchText.lowercased()) && !filteredPossibleFriends.contains(friend)
        })
        filteredPossibleFriends += possibleFriends.filter({ friend in
            return friend.nickname?.lowercased().contains(searchText.lowercased()) ?? false && !filteredPossibleFriends.contains(friend)
        })
        
        UIView.transition(with: self.scrollView, duration: 0.2, options: [.transitionCrossDissolve], animations: { [self] in
            myFriendsTableView.reloadData()
            possibleFriendsTableView?.reloadData()
            if isFiltering {
                var myFriendsHeightVal = CGFloat(filteredMyFriends.count * 70 - 1)
                if myFriendsHeightVal == -1 { myFriendsHeightVal = 69}
                var possibleFriendsHeightVal = CGFloat(filteredPossibleFriends.count * 70 - 1)
                if possibleFriendsHeightVal == -1 { possibleFriendsHeightVal = 69}
                myFriendsTableViewHeight?.constant = myFriendsHeightVal
                possibleFriendsTableViewHeight?.constant = myFriendsHeightVal
            } else if searchBarIsEmpty {
                if CGFloat(friends.count * 70 - 1) == -1 {
                    myFriendsTableViewHeight?.constant = CGFloat(69)
                } else {
                    myFriendsTableViewHeight?.constant = CGFloat(friends.count * 70 - 1)
                }
                possibleFriendsTableViewHeight?.constant = CGFloat(possibleFriends.count * 70 - 1)
            }
        }, completion: { status in
            
        })
        self.viewDidLayoutSubviews()
    }
    
    // MARK: - Add new friends Function
    
    @IBAction func openAddFriendsScreen() {
        
        self.willBeDeinited = false
        
        let storyboard = UIStoryboard(name: "Accounts", bundle: nil)
        let VC = storyboard.instantiateViewController(identifier: "AddFriendsViewController") as! AddFriendsViewConrtoller
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
    // MARK: - Gesture recognizer
    
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

