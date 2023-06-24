//
//  TagsListViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 24.05.2021.
//

import UIKit

class TagsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var personalLabel: UILabel!
    @IBOutlet weak var personalTableView: UITableView!
    @IBOutlet weak var personalTableContainer: UIView!
    @IBOutlet weak var personalTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var publicLabel: UILabel!
    @IBOutlet weak var publicTableView: UITableView!
    @IBOutlet weak var publicTableContainer: UIView!
    @IBOutlet weak var publicTableViewHeight: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    private var addFirstTagLabel: UILabel?
    private var addFirstTagButton: UIButton?
    
    public var isMyTags: Bool = false
    
    public var personalTags: [Tag] = []
    public var publicTags: [Tag] = []
    
    public var filteredPersonalTags = [Tag]()
    public var filteredPublicTags = [Tag]()
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {
            return false
        }
        return text.isEmpty
    }
    public var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var isFirstWillAppear: Bool = true
    
    var notificationView: UIView?
    
    private var willBeDeinited: Bool = true
    
    var tap: UITapGestureRecognizer?
    
    // MARK: - View Controller's life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isFirstWillAppear {
            if personalTags.count == 0 {
                personalLabel?.removeFromSuperview()
                personalTableView?.removeFromSuperview()
            }
            if publicTags.count == 0 {
                publicLabel?.removeFromSuperview()
                publicTableView?.removeFromSuperview()
            }
            if personalTags.count == 0 && publicTags.count == 0 {
                if !willBeDeinited {
                    buildAddFirstButtom()
                }
            }
        }
        
        personalTableView?.delegate = self
        publicTableView?.delegate = self
        personalTableView?.dataSource = self
        publicTableView?.dataSource = self
        
        if isFiltering {
            if filteredPublicTags.count == 0 {
                self.publicTableViewHeight?.constant = 51
            } else {
                self.publicTableViewHeight?.constant = CGFloat(filteredPublicTags.count * 52 - 1)
            }
            if filteredPersonalTags.count == 0 {
                self.personalTableViewHeight?.constant = 51
            } else {
                self.personalTableViewHeight?.constant = CGFloat(filteredPersonalTags.count * 52 - 1)
            }
        } else {
            self.publicTableViewHeight?.constant = CGFloat(publicTags.count * 52 - 1)
            self.personalTableViewHeight?.constant = CGFloat(personalTags.count * 52 - 1)
        }
        
        
        isFirstWillAppear = false
        
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        willBeDeinited = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        personalTableView?.delegate = nil
        publicTableView?.delegate = nil
        personalTableView?.dataSource = nil
        publicTableView?.dataSource = nil
        
        if willBeDeinited {
            notificationView?.removeFromSuperview()
            notificationView = nil
            personalTableView?.delegate = nil
            publicTableView?.delegate = nil
            personalTableView?.dataSource = nil
            publicTableView?.dataSource = nil
            searchController.searchResultsUpdater = nil
            tap?.delegate = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.layoutSubviews()
        
        if personalTags.count == 0 && publicTags.count == 0 {
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
        } else if publicTags.count != 0 {
            if scrollView.frame.height - globalVariables.bottomScreenLength >= publicTableContainer.frame.maxY + 10 {
                scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
            } else {
                scrollView.contentSize = CGSize(width: scrollView.frame.width, height: publicTableContainer.frame.maxY + 20)
            }
        } else {
            if scrollView.frame.height - globalVariables.bottomScreenLength >= personalTableContainer.frame.maxY + 12 {
                scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
            } else {
                scrollView.contentSize = CGSize(width: scrollView.frame.width, height: personalTableContainer.frame.maxY + 20)
            }
        }
    }
    
    // MARK: - Setup functions
    
    func setupScene() {
        
        if isMyTags {
            let plusItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(addTag))
            self.navigationItem.rightBarButtonItems = [plusItem]
            if globalVariables.currentLanguage == "en" {
                self.title = "My tags"
            } else {
                self.title = "Мои метки"
            }
        } else {
            if globalVariables.currentLanguage == "en" {
                self.title = "User tags"
            } else {
                self.title = "Метки"
            }
        }
        
        scrollViewBottom.constant = -globalVariables.bottomScreenLength
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        if globalVariables.currentLanguage == "en" {
            searchController.searchBar.placeholder = "Search tag"
        } else {
            searchController.searchBar.placeholder = "Поиск меток"
        }
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        personalTableView.layer.cornerRadius = 16
        personalTableContainer.layer.cornerRadius = 16
        Helpers().addShadow(view: personalTableContainer)
        publicTableView.layer.cornerRadius = 16
        publicTableContainer.layer.cornerRadius = 16
        Helpers().addShadow(view: publicTableContainer)
        
        personalTableView.dataSource = self
        personalTableView.rowHeight = 52
        publicTableView.dataSource = self
        publicTableView.rowHeight = 52
        
        personalTableViewHeight.constant = CGFloat(personalTags.count * 52) - 1
        publicTableViewHeight.constant = CGFloat(publicTags.count * 52) - 1
        
        if personalTags.count == 0 && publicTags.count == 0 {
            removePersonal()
            removePublic()
            buildAddFirstButtom()
        } else {
            if personalTags.count == 0 {
                removePersonal()
            }
            if publicTags.count == 0 {
                removePublic()
            }
        }
        
        tap = UITapGestureRecognizer(target: self, action: #selector(endOfSearching))
        tap!.delegate = self
        
        self.view.addGestureRecognizer(tap!)
    }
    
    @objc func endOfSearching() {
        if searchBarIsEmpty {
            self.searchController.isActive = false
        } else {
            self.searchController.searchBar.endEditing(true)
        }
    }
    
    func removePersonal() {
        personalLabel.removeFromSuperview()
        personalTableContainer.removeFromSuperview()
    }
    
    func removePublic() {
        publicLabel.removeFromSuperview()
        publicTableContainer.removeFromSuperview()
    }
    
    func buildAddFirstButtom() {

        self.view.layoutSubviews()
        
        addFirstTagButton = UIButton()
        addFirstTagButton?.translatesAutoresizingMaskIntoConstraints = false
        addFirstTagButton?.addTarget(self, action: #selector(addTag), for: .touchUpInside)
        addFirstTagButton?.layer.cornerRadius = 16
        addFirstTagButton?.alpha = 0.0
        
        addFirstTagButton?.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        
        scrollView.addSubview(addFirstTagButton!)
        
        addFirstTagButton?.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
        addFirstTagButton?.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 74).isActive = true
        addFirstTagButton?.widthAnchor.constraint(equalToConstant: scrollView.frame.width - 40).isActive = true
        addFirstTagButton?.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        if isMyTags {
            
            Helpers().addShadow(view: addFirstTagButton)
            
            addFirstTagLabel = UILabel()
            addFirstTagLabel?.alpha = 0.0
            addFirstTagLabel?.translatesAutoresizingMaskIntoConstraints = false

            
            addFirstTagLabel?.textColor = UIColor(named: "textGrey")
            scrollView.addSubview(addFirstTagLabel!)
            
            addFirstTagLabel?.centerXAnchor.constraint(equalTo: addFirstTagButton!.centerXAnchor).isActive = true
            addFirstTagLabel?.bottomAnchor.constraint(equalTo: addFirstTagButton!.topAnchor, constant: -16).isActive = true
            
            addFirstTagButton?.backgroundColor = .systemBlue
            addFirstTagButton?.setTitleColor(.white, for: .normal)
            if globalVariables.currentLanguage == "en" {
                addFirstTagLabel?.text = "You haven't tags yet"
                addFirstTagButton?.setTitle("Add your fisrt tag", for: .normal)
            } else {
                addFirstTagLabel?.text = "У вас ещё нет меток"
                addFirstTagButton?.setTitle("Добавьте свою первую метку", for: .normal)
            }
        } else {
            
            addFirstTagButton?.layer.shadowOpacity = 0.0
            
            addFirstTagButton?.backgroundColor = .clear
            addFirstTagButton?.setTitleColor(.darkGray, for: .normal)
            addFirstTagButton?.isEnabled = false
            if globalVariables.currentLanguage == "en" {
                addFirstTagButton?.setTitle("User haven't add tags yet", for: .normal)
            } else {
                addFirstTagButton?.setTitle("У пользователя ещё нет меток", for: .normal)
            }
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIView.animate(withDuration: 0.2) {
                self.addFirstTagButton?.alpha = 1.0
                self.addFirstTagLabel?.alpha = 1.0
            }
        }
    }
    
    // MARK: - Additional functions
    
    @objc func addTag() {
        let currentVC = self.navigationController?.topViewController
        
        guard var viewConstrollers = currentVC?.navigationController?.viewControllers else { return }
        
        _ = viewConstrollers.popLast()
        
        let tagsListViewController = UIStoryboard(name: "Tags", bundle: nil).instantiateViewController(identifier: "TagsListViewController") as! TagsListViewController
        tagsListViewController.personalTags = personalTags
        tagsListViewController.publicTags = publicTags
        tagsListViewController.isMyTags = isMyTags
        let additingViewController = UIStoryboard(name: "Tags", bundle: nil).instantiateViewController(identifier: "AddingAndEditingViewController")
        
        viewConstrollers.append(tagsListViewController)
        viewConstrollers.append(additingViewController)
        
        currentVC?.navigationController?.setViewControllers(viewConstrollers, animated: true)
    }
    
    // MARK: - TableView Delegates functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            if isFiltering {
                if filteredPersonalTags.count == 0 {
                    return 1
                }
                return filteredPersonalTags.count
            }
            return personalTags.count
        case 1:
            if isFiltering {
                if filteredPublicTags.count == 0 {
                    return 1
                }
                return filteredPublicTags.count
            }
            return publicTags.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch tableView.tag {
        case 0:
            if isFiltering && filteredPersonalTags.count == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "personalNoResults", for: indexPath)
            } else {
                var name: String?
                var address: String?
                if isFiltering {
                    if globalVariables.currentLanguage == "en" {
                        if filteredPersonalTags[indexPath.row].enName != nil && filteredPersonalTags[indexPath.row].enName != "" {
                            name = filteredPersonalTags[indexPath.row].enName
                        } else {
                            name = filteredPersonalTags[indexPath.row].ruName
                        }
                        if filteredPersonalTags[indexPath.row].enAddressName != nil && filteredPersonalTags[indexPath.row].enAddressName != "" {
                            address = filteredPersonalTags[indexPath.row].enAddressName
                        } else {
                            address = filteredPersonalTags[indexPath.row].ruAddressName
                        }
                    } else if globalVariables.currentLanguage == "ru" {
                        
                        if filteredPersonalTags[indexPath.row].ruName != nil && filteredPersonalTags[indexPath.row].ruName != "" {
                            name = filteredPersonalTags[indexPath.row].ruName
                        } else {
                            name = filteredPersonalTags[indexPath.row].enName
                        }

                        if filteredPersonalTags[indexPath.row].ruAddressName != nil && filteredPersonalTags[indexPath.row].ruAddressName != "" {
                            address = filteredPersonalTags[indexPath.row].ruAddressName
                        } else {
                            address = filteredPersonalTags[indexPath.row].enAddressName
                        }
                    }
                } else {
                    if globalVariables.currentLanguage == "en" {
                        
                        if personalTags[indexPath.row].enName != nil && personalTags[indexPath.row].enName != "" {
                            name = personalTags[indexPath.row].enName
                        } else {
                            name = personalTags[indexPath.row].ruName
                        }
                        if personalTags[indexPath.row].enAddressName != nil && personalTags[indexPath.row].enAddressName != "" {
                            address = personalTags[indexPath.row].enAddressName
                        } else {
                            address = personalTags[indexPath.row].ruAddressName
                        }
                    } else if globalVariables.currentLanguage == "ru" {
                        if personalTags[indexPath.row].ruName != nil && personalTags[indexPath.row].ruName != "" {
                            name = personalTags[indexPath.row].ruName
                        } else {
                            name = personalTags[indexPath.row].enName
                        }
                        if personalTags[indexPath.row].ruAddressName != nil && personalTags[indexPath.row].ruAddressName != "" {
                            address = personalTags[indexPath.row].ruAddressName
                        } else {
                            address = personalTags[indexPath.row].enAddressName
                        }
                    }
                }
                if address == nil || address == "" {
                    cell = tableView.dequeueReusableCell(withIdentifier: "personalCellNoAddress", for: indexPath)
                    
                    let nameLabel = cell.viewWithTag(1) as! UILabel
                    let viewsLabel = cell.viewWithTag(2) as! UILabel
                    
                    nameLabel.text = name
                    if globalVariables.currentLanguage == "en" {
                        viewsLabel.text = String(personalTags[indexPath.row].views) + " views"
                    } else {
                        viewsLabel.text = String(personalTags[indexPath.row].views) + " просмотров"
                    }
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "personalCell", for: indexPath)
                    
                    let nameLabel = cell.viewWithTag(1) as! UILabel
                    let viewsLabel = cell.viewWithTag(2) as! UILabel
                    let addressLabel = cell.viewWithTag(3) as! UILabel
                    
                    nameLabel.text = name
                    if globalVariables.currentLanguage == "en" {
                        viewsLabel.text = String(personalTags[indexPath.row].views) + " views"
                    } else {
                        viewsLabel.text = String(personalTags[indexPath.row].views) + " просмотров"
                    }
                    addressLabel.text = address
                }
            }
        case 1:
            if isFiltering && filteredPublicTags.count == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "publicNoResults", for: indexPath)
            } else {
                var name: String?
                var address: String?
                if isFiltering {
                    if globalVariables.currentLanguage == "en" {
                        if filteredPublicTags[indexPath.row].enName != nil && filteredPublicTags[indexPath.row].enName != "" {
                            name = filteredPublicTags[indexPath.row].enName
                        } else {
                            name = filteredPublicTags[indexPath.row].ruName
                        }
                        if filteredPublicTags[indexPath.row].enAddressName != nil && filteredPublicTags[indexPath.row].enAddressName != "" {
                            address = filteredPublicTags[indexPath.row].enAddressName
                        } else {
                            address = filteredPublicTags[indexPath.row].ruAddressName
                        }
                    } else if globalVariables.currentLanguage == "ru" {
                        if filteredPublicTags[indexPath.row].ruName != nil && filteredPublicTags[indexPath.row].ruName != "" {
                            name = filteredPublicTags[indexPath.row].ruName
                        } else {
                            name = filteredPublicTags[indexPath.row].enName
                        }
                        if filteredPublicTags[indexPath.row].ruAddressName != nil && filteredPublicTags[indexPath.row].ruAddressName != "" {
                            address = filteredPublicTags[indexPath.row].ruAddressName
                        } else {
                            address = filteredPublicTags[indexPath.row].enAddressName
                        }
                    }
                } else {
                    if globalVariables.currentLanguage == "en" {
                        if publicTags[indexPath.row].enName != nil && publicTags[indexPath.row].enName != "" {
                            name = publicTags[indexPath.row].enName
                        } else {
                            name = publicTags[indexPath.row].ruName
                        }
                        if publicTags[indexPath.row].enAddressName != nil && publicTags[indexPath.row].enAddressName != "" {
                            address = publicTags[indexPath.row].enAddressName
                        } else {
                            address = publicTags[indexPath.row].ruAddressName
                        }
                    } else if globalVariables.currentLanguage == "ru" {
                        if publicTags[indexPath.row].ruName != nil && publicTags[indexPath.row].ruName != "" {
                            name = publicTags[indexPath.row].ruName
                        } else {
                            name = publicTags[indexPath.row].enName
                        }
                        if publicTags[indexPath.row].ruAddressName != nil && publicTags[indexPath.row].ruAddressName != "" {
                            address = publicTags[indexPath.row].ruAddressName
                        } else {
                            address = publicTags[indexPath.row].enAddressName
                        }
                    }
                }
                if address == nil || address == "" {
                    cell = tableView.dequeueReusableCell(withIdentifier: "publicCellNoAddress", for: indexPath)
                    
                    let nameLabel = cell.viewWithTag(1) as! UILabel
                    let viewsLabel = cell.viewWithTag(2) as! UILabel
                    
                    nameLabel.text = name
                    if globalVariables.currentLanguage == "en" {
                        viewsLabel.text = String(publicTags[indexPath.row].views) + " views"
                    } else {
                        viewsLabel.text = String(publicTags[indexPath.row].views) + " просмотров"
                    }
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "publicCell", for: indexPath)
                    
                    let nameLabel = cell.viewWithTag(1) as! UILabel
                    let viewsLabel = cell.viewWithTag(2) as! UILabel
                    let addressLabel = cell.viewWithTag(3) as! UILabel
                    
                    nameLabel.text = name
                    if globalVariables.currentLanguage == "en" {
                        viewsLabel.text = String(publicTags[indexPath.row].views) + " views"
                    } else {
                        viewsLabel.text = String(publicTags[indexPath.row].views) + " просмотров"
                    }
                    addressLabel.text = address
                }
            }
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.isSelected = false
        
        if tableView.cellForRow(at: indexPath)?.tag == 0 {
            let storyboard = UIStoryboard(name: "Tags", bundle: nil)
            let VC = storyboard.instantiateViewController(identifier: "InfoViewController") as! InfoViewController
            if tableView.tag == 0 {
                if isFiltering {
                    VC.tag = filteredPersonalTags[indexPath.row]
                } else {
                    VC.tag = personalTags[indexPath.row]
                }
            } else if tableView.tag == 1 {
                if isFiltering {
                    VC.tag = filteredPublicTags[indexPath.row]
                } else {
                    VC.tag = publicTags[indexPath.row]
                }
            }
            
            VC.modalPresentationStyle = .fullScreen
            VC.modalTransitionStyle = .crossDissolve
            
            willBeDeinited = false
            
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if isMyTags {
            
            var configuration: UISwipeActionsConfiguration!
            
            if tableView.cellForRow(at: indexPath)?.tag == 0 {
                if tableView.tag == 0 {
                    let editAction = self.editTag(at: indexPath, isPersonal: true)
                    let deleteAction = self.deleteTag(at: indexPath, isPersonal: true)
                    configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
                    configuration.performsFirstActionWithFullSwipe = false
                } else if tableView.tag == 1 {
                    let editAction = self.editTag(at: indexPath, isPersonal: false)
                    let deleteAction = self.deleteTag(at: indexPath, isPersonal: false)
                    configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
                    configuration.performsFirstActionWithFullSwipe = false
                }
            } else {
                configuration = UISwipeActionsConfiguration(actions: [])
            }
            return configuration
        }
        
        return nil
    }
    
    func editTag(at indexPath: IndexPath, isPersonal: Bool) -> UIContextualAction {
        

        let action = UIContextualAction(style: .normal, title: nil) { [self] (action, view, complition) in
            
            let storyboard = UIStoryboard(name: "Tags", bundle: nil)
            let VC = storyboard.instantiateViewController(identifier: "AddingAndEditingViewController") as! AddingAndEditingViewController
            VC.modalPresentationStyle = .fullScreen
            VC.modalTransitionStyle = .crossDissolve
            if isPersonal {
                if isFiltering {
                    VC.editingTag = self.filteredPersonalTags[indexPath.row]
                } else {
                    VC.editingTag = self.personalTags[indexPath.row]
                }
            } else {
                if isFiltering {
                    VC.editingTag = self.filteredPublicTags[indexPath.row]
                } else {
                    VC.editingTag = self.publicTags[indexPath.row]
                }
            }
            VC.isEditingTag = true
            
            willBeDeinited = false
            
            self.navigationController?.pushViewController(VC, animated: true)
        }
        action.backgroundColor = .systemGray3
        action.image = UIImage(systemName: "square.and.pencil")
        
        return action
    }
    
    func deleteTag(at indexPath: IndexPath, isPersonal: Bool) -> UIContextualAction {
        
        let action = UIContextualAction(style: .destructive, title: nil) { [self] (action, view, complition) in
            
            if isPersonal {
                
                var id: Int!
                if isFiltering {
                    id = filteredPersonalTags[indexPath.row].tagsId
                } else {
                    id = personalTags[indexPath.row].tagsId
                }
                
                placeNotificationsView(event: .loading)
                Server.shared.deleteTag(email: personalInfo.emailAddress ?? "", password: personalInfo.password ?? "", tagsId: id) { [self] answer in
                    removeNotificationView { [self] _ in
                        if answer.success {
                            
                            globalVariables.allTags.removeAll { tag in
                                return tag.tagsId == id
                            }
                            
                            if globalVariables.offlineMode {
                                UserDefaults.standard.set(try? PropertyListEncoder().encode(globalVariables.allTags), forKey:"offlineTagsList")
                            }
                            
                            globalVariables.listOfAvailableTags.removeAll { tag in
                                return tag.tagsId == id
                            }
                            
                            let currentVC = self.navigationController?.topViewController
                            
                            guard let viewConstrollers = currentVC?.navigationController?.viewControllers else {
                                return
                            }
                            
                            for i in viewConstrollers {
                                if i is TagsListViewController {
                                    let tagsVC = i as! TagsListViewController
                                    
                                    tagsVC.personalTags.removeAll { tag in
                                        return tag.tagsId == id
                                    }
                                    tagsVC.filteredPersonalTags.removeAll { tag in
                                        return tag.tagsId == id
                                    }
                                }
                            }

                            personalInfo.userAccount?.privateTags.removeAll(where: { tag in
                                return tag.tagsId == id
                            })
                            
                            personalTableView!.deleteRows(at: [indexPath], with: .left)
                            if personalTags.count == 0 {
                                UIView.transition(with: self.scrollView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                    self.personalLabel!.alpha = 0.0
                                    self.personalTableView!.alpha = 0.0
                                }) { _ in
                                    self.personalLabel?.removeFromSuperview()
                                    self.personalTableContainer?.removeFromSuperview()
                                    self.personalLabel = nil
                                    self.personalTableView = nil
                                    self.personalTableContainer = nil
                                }
                                if publicTags.count == 0 {
                                    self.buildAddFirstButtom()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    UIView.transition(with: self.scrollView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                        self.view.layoutIfNeeded()
                                    })
                                }
                                self.personalLabel?.removeFromSuperview()
                                self.personalTableContainer?.removeFromSuperview()
                                self.personalLabel = nil
                                self.personalTableView = nil
                                self.personalTableContainer = nil
                            } else {
                                self.personalTableViewHeight.constant = CGFloat(personalTags.count * 52 - 1)
                                UIView.transition(with: self.scrollView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                    self.view.layoutIfNeeded()
                                })
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
            } else {
                var id: Int!
                if isFiltering {
                    id = filteredPublicTags[indexPath.row].tagsId
                } else {
                    id = publicTags[indexPath.row].tagsId
                }
                
                placeNotificationsView(event: .loading)
                Server.shared.deleteTag(email: personalInfo.emailAddress ?? "", password: personalInfo.password ?? "", tagsId: id) { [self] answer in
                    removeNotificationView { [self] _ in
                        if answer.success {
                            
                            globalVariables.allTags.removeAll { tag in
                                return tag.tagsId == id
                            }
                            
                            if globalVariables.offlineMode {
                                UserDefaults.standard.set(try? PropertyListEncoder().encode(globalVariables.allTags), forKey:"offlineTagsList")
                            }
                            
                            globalVariables.listOfAvailableTags.removeAll { tag in
                                return tag.tagsId == id
                            }
                            
                            
                            let currentVC = self.navigationController?.topViewController
                            
                            guard let viewConstrollers = currentVC?.navigationController?.viewControllers else {
                                return
                            }
                            
                            for i in viewConstrollers {
                                if i is TagsListViewController {
                                    let tagsVC = i as! TagsListViewController
                                    tagsVC.publicTags.removeAll { tag in
                                        return tag.tagsId == id
                                    }
                                    tagsVC.filteredPublicTags.removeAll { tag in
                                        return tag.tagsId == id
                                    }
                                }
                            }
                            
                            personalInfo.userAccount?.publicTags.removeAll(where: { tag in
                                return tag.tagsId == id
                            })

                            publicTableView!.deleteRows(at: [indexPath], with: .left)
                            if publicTags.count == 0 {
                                UIView.transition(with: self.scrollView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                    self.publicLabel!.alpha = 0.0
                                    self.publicTableView!.alpha = 0.0
                                }) { _ in
                                    self.publicLabel.removeFromSuperview()
                                    self.publicTableContainer.removeFromSuperview()
                                    self.publicLabel = nil
                                    self.publicTableView = nil
                                    self.publicTableContainer = nil
                                }
                                if personalTags.count == 0 {
                                    self.buildAddFirstButtom()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    UIView.transition(with: self.scrollView, duration: 0.2, options: .transitionCrossDissolve, animations: { [self] in
                                        self.view.layoutIfNeeded()
                                    })
                                }
                            } else {
                                self.publicTableViewHeight.constant = CGFloat(publicTags.count * 52 - 1)
                                UIView.transition(with: self.scrollView, duration: 0.2, options: .transitionCrossDissolve, animations: { [self] in
                                    self.view.layoutIfNeeded()
                                })
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
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                UIView.transition(with: self.scrollView, duration: 0.2, options: .transitionCrossDissolve, animations: { [self] in
                    self.viewDidLayoutSubviews()
                })
            }
            
        }
        action.backgroundColor = .systemRed
        action.image = UIImage(systemName: "trash.fill")
        
        return action
    }
    
    // MARK: - Search Bar functions
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredPersonalTags = personalTags.filter({ (tag: Tag) -> Bool in
            return tag.enName?.lowercased().starts(with: searchText.lowercased()) ?? false || tag.ruName?.lowercased().starts(with: searchText.lowercased()) ?? false
        })
        filteredPersonalTags += personalTags.filter({ (tag: Tag) -> Bool in
            return  (tag.enAddressName?.lowercased().starts(with: searchText.lowercased()) ?? false || tag.ruAddressName?.lowercased().starts(with: searchText.lowercased()) ?? false) && !filteredPersonalTags.contains(tag)
            
        })
        filteredPersonalTags += personalTags.filter({ (tag: Tag) -> Bool in
            return (tag.enName?.lowercased().contains(searchText.lowercased()) ?? false || tag.ruName?.lowercased().contains(searchText.lowercased()) ?? false) && !filteredPersonalTags.contains(tag)
        })
        filteredPersonalTags += personalTags.filter({ (tag: Tag) -> Bool in
            return  (tag.enAddressName?.lowercased().contains(searchText.lowercased()) ?? false || tag.ruAddressName?.lowercased().contains(searchText.lowercased()) ?? false) && !filteredPersonalTags.contains(tag)
            
        })
        
        
        filteredPublicTags = publicTags.filter({ (tag: Tag) -> Bool in
            return tag.enName?.lowercased().starts(with: searchText.lowercased()) ?? false || tag.ruName?.lowercased().starts(with: searchText.lowercased()) ?? false
        })
        filteredPublicTags += publicTags.filter({ (tag: Tag) -> Bool in
            return (tag.enAddressName?.lowercased().starts(with: searchText.lowercased()) ?? false || tag.ruAddressName?.lowercased().starts(with: searchText.lowercased()) ?? false) && !filteredPublicTags.contains(tag)
        })
        filteredPublicTags += publicTags.filter({ (tag: Tag) -> Bool in
            return (tag.enName?.lowercased().contains(searchText.lowercased()) ?? false || tag.ruName?.lowercased().contains(searchText.lowercased()) ?? false) && !filteredPublicTags.contains(tag)
        })
        filteredPublicTags += publicTags.filter({ (tag: Tag) -> Bool in
            return (tag.enAddressName?.lowercased().contains(searchText.lowercased()) ?? false || tag.ruAddressName?.lowercased().contains(searchText.lowercased()) ?? false) && !filteredPublicTags.contains(tag)
        })

        UIView.transition(with: self.scrollView, duration: 0.2, options: .transitionCrossDissolve, animations: { [self] in
            personalTableView?.reloadData()
            publicTableView?.reloadData()
            if isFiltering {
                var personalHeight = CGFloat(filteredPersonalTags.count * 52 - 1)
                if personalHeight == -1 { personalHeight = 51}
                var publicHeight = CGFloat(filteredPublicTags.count * 52 - 1)
                if publicHeight == -1 { publicHeight = 51}
                personalTableViewHeight?.constant = personalHeight
                publicTableViewHeight?.constant = publicHeight
            } else if searchBarIsEmpty {
                personalTableViewHeight?.constant = CGFloat(personalTags.count * 52 - 1)
                publicTableViewHeight?.constant = CGFloat(publicTags.count * 52 - 1)
            }
        })
        self.viewDidLayoutSubviews()
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == scrollView { return true }
        return false
    }
    
    // MARK: - Notifications
    
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
