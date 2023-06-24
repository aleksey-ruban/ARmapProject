//
//  AccountInfoViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 24.05.2021.
//

import UIKit

class AccountInfoViewController: UIViewController {
    
    @IBOutlet weak var personalInfoView: UIView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var avatarHeight: NSLayoutConstraint!
    @IBOutlet weak var avatarWidth: NSLayoutConstraint!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var friendsView: UIView!
    @IBOutlet weak var friendsCountLabel: UILabel!
    @IBOutlet weak var newFriendsView: UIView!
    @IBOutlet weak var newFriendsLabel: UILabel!
    @IBOutlet weak var friendsViewTop: NSLayoutConstraint!
    @IBOutlet weak var tagsView: UIView!
    @IBOutlet weak var tagsCountLabel: UILabel!
    @IBOutlet weak var ageView: UIView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var birthDay: UILabel!
    @IBOutlet weak var birthMonth: UILabel!
    @IBOutlet weak var nicknameView: UIView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var mostPopularTagView: UIView!
    @IBOutlet weak var popularTagName: UILabel!
    @IBOutlet weak var popularTagAddress: UILabel!
    @IBOutlet weak var popularTagViews: UILabel!
    @IBOutlet weak var popularTagHighlightView: HighlightView!
    @IBOutlet weak var addFirstTagButton: UIButton!
    @IBOutlet weak var correctButton: UIImageView!
    @IBOutlet weak var optionsButton: UIImageView!
    @IBOutlet weak var achievementsView: UIView!
    @IBOutlet weak var achievementsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var scrollViewTop: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var effectView: UIVisualEffectView!
    
    private var achievDetailView: UIView?
    
    public var isAnotherUserAccount: Bool = false
    public var anotherUserAccount: User?
    public var anotherUserPrivateTags: [Tag] = []
    public var anotherUserPublicTags: [Tag] = []
    
    var mostPopularTag: Tag?
    
    var showAge: Bool = false
    var showNickname: Bool = false
    var showCountry: Bool = false
    var showAchievements: Bool = false
    
    var variableNoMeaning: Bool = false
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var notificationView: UIView?
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isAnotherUserAccount {
            friendsCountLabel.text = String(describing: personalInfo.userAccount!.friends.count)
            tagsCountLabel.text = String(describing: personalInfo.userAccount!.privateTags.count + personalInfo.userAccount!.publicTags.count)
        } else {
            friendsCountLabel.text = String(describing: anotherUserAccount!.friends.count)
            tagsCountLabel.text = String(describing: anotherUserPrivateTags.count + anotherUserPublicTags.count)
        }
        
        if globalVariables.shouldStayOnAccountInfoViewController {
            globalVariables.shouldStayOnAccountInfoViewController = false
            if personalInfo.isAuthorised {
                if personalInfo.userAccount?.userId == anotherUserAccount!.userId {
                    isAnotherUserAccount = false
                    variableNoMeaning = true
                    setupLayoutConstraint()
                    addFriendButton.removeFromSuperview()
                } else {
                    addFriendButton.removeTarget(nil, action: nil, for: .allEvents)
                    addFriendButton.addAction(UIAction(handler: { _ in
                        self.addFriend()
                    }), for: .touchUpInside)
                }
            }
        }
        
        if !isAnotherUserAccount {
            if personalInfo.userAccount?.waitingFriends.count != 0 {
                newFriendsLabel?.text = "\(personalInfo.userAccount!.waitingFriends.count)"
                if globalVariables.currentLanguage == "en" {
                    newFriendsLabel?.text! += " new"
                } else {
                    if personalInfo.userAccount?.waitingFriends.count == 1 {
                        newFriendsLabel?.text! += " новый"
                    } else {
                        newFriendsLabel?.text! += " новых"
                    }
                }
            } else {
                newFriendsView.isHidden = true
            }
        }
        
        if !isAnotherUserAccount {
            
            for i in achievementsView.subviews {
                if i.tag != 444 {
                    i.removeFromSuperview()
                }
            }
            
            buildAchievementsView()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isAnotherUserAccount {
            if logOutButton.frame.maxY + 8 > scrollView.frame.height - globalVariables.bottomScreenLength {
                scrollView.contentSize = CGSize(width: scrollView.frame.width, height: logOutButton.frame.maxY + 16)
            } else {
                scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
            }
        } else {
            if showAchievements && achievementsView != nil {
                if achievementsView.frame.maxY + 8 > scrollView.frame.height - globalVariables.bottomScreenLength {
                    scrollView.contentSize = CGSize(width: scrollView.frame.width, height: achievementsView.frame.maxY + 16)
                } else {
                    scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
                }
            } else if mostPopularTagView != nil {
                if mostPopularTagView.frame.maxY + 8 > scrollView.frame.height - globalVariables.bottomScreenLength {
                    scrollView.contentSize = CGSize(width: scrollView.frame.width, height: mostPopularTagView.frame.maxY + 16)
                } else {
                    scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
                }
            } else {
                if personalInfoView.frame.maxY + 8 > scrollView.frame.height - globalVariables.bottomScreenLength {
                    scrollView.contentSize = CGSize(width: scrollView.frame.width, height: personalInfoView.frame.maxY + 16)
                } else {
                    scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height - globalVariables.bottomScreenLength + 0.5)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if globalVariables.mustShowNewAchievement {
            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.scrollView.contentInset.bottom)
             scrollView.setContentOffset(bottomOffset, animated: true)
            globalVariables.mustShowNewAchievement = false
        }
        if globalVariables.mustShowFriendWithID != 0 {
            self.placeNotificationsView(event: .loading)
            Server.shared.getUser(userId: globalVariables.mustShowFriendWithID) { answer in
                self.removeNotificationView { _ in
                    if answer is User {
                        
                        let storyboard = UIStoryboard(name: "Accounts", bundle: nil)
                        let VC = storyboard.instantiateViewController(identifier: "AccountIfoViewController") as! AccountInfoViewController
                        VC.isAnotherUserAccount = true
                        VC.anotherUserAccount = answer as? User
                        VC.modalPresentationStyle = .fullScreen
                        VC.modalTransitionStyle = .crossDissolve
                        
                        self.navigationController?.pushViewController(VC, animated: true)
                    } else if answer is ServerAnswer {
                        self.placeNotificationsView(event: .error)
                    }
                    globalVariables.mustShowFriendWithID = 0
                }
            }
        }
        if globalVariables.mustShowFriendsList {
            self.openFriends(Any.self)
            globalVariables.mustShowFriendsList = false
        }
    }
    
    // MARK: - Scene setup functions
    
    func setupScene() {
        
        impactFeedback.prepare()
        
        self.view.layoutSubviews()
        self.scrollView.layoutSubviews()
        self.personalInfoView.layoutSubviews()
        
        avatarWidth.constant = personalInfoView.frame.size.width * 0.52
        avatarHeight.constant = avatarWidth.constant
        
        if anotherUserAccount?.userId != personalInfo.userAccount?.userId && anotherUserAccount != nil {
            isAnotherUserAccount = true
        } else {
            isAnotherUserAccount = false
        }
        
        if isAnotherUserAccount {
            anotherUserPrivateTags = Helpers().sortedTags(allTags: anotherUserAccount!.privateTags)
            anotherUserPublicTags = Helpers().sortedTags(allTags: anotherUserAccount!.publicTags)
            
            var maxViews = -1
            for i in anotherUserPrivateTags {
                if i.views > maxViews {
                    mostPopularTag = i
                    maxViews = i.views
                }
            }
            for i in anotherUserPublicTags {
                if i.views >= maxViews {
                    mostPopularTag = i
                    maxViews = i.views
                }
            }
            
            if personalInfo.isAuthorised {
                
                if personalInfo.userAccount!.friends.contains(where: { friend in
                    return friend.userId == anotherUserAccount!.userId
                }) {
                    addFriendButton.backgroundColor = UIColor(named: "background")
                    addFriendButton.setTitleColor(.label, for: .normal)
                    if globalVariables.currentLanguage == "en" {
                        addFriendButton.setTitle("My friend", for: .normal)
                    } else {
                        addFriendButton.setTitle("Мой друг", for: .normal)
                    }
                    
                    addFriendButton.addAction(UIAction(handler: { _ in
                        self.alertToDeleteFriend()
                    }), for: .touchUpInside)
                    
                } else if personalInfo.userAccount!.requestToFriends.contains(anotherUserAccount!.userId) {
                    
                    addFriendButton.backgroundColor = .systemGray4
                    addFriendButton.setTitleColor(.label, for: .normal)
                    if globalVariables.currentLanguage == "en" {
                        addFriendButton.setTitle("Request sent", for: .normal)
                    } else {
                        addFriendButton.setTitle("Заявка отправлена", for: .normal)
                    }
                    addFriendButton.addAction(UIAction(handler: { _ in
                        self.cancelRequest()
                    }), for: .touchUpInside)
                } else if personalInfo.userAccount!.followers.contains(anotherUserAccount!.userId) || personalInfo.userAccount!.waitingFriends.contains(where: { friend in
                    return friend.userId == anotherUserAccount!.userId
                }) {
                    addFriendButton.backgroundColor = .systemGray4
                    addFriendButton.setTitleColor(.label, for: .normal)
                    if globalVariables.currentLanguage == "en" {
                        addFriendButton.setTitle("Accept request", for: .normal)
                    } else {
                        addFriendButton.setTitle("Принять заявку", for: .normal)
                    }
                    addFriendButton.addAction(UIAction(handler: { _ in
                        self.acceptRequest()
                    }), for: .touchUpInside)
                } else {
                    addFriendButton.addAction(UIAction(handler: { _IOFBF in
                        self.addFriend()
                    }), for: .touchUpInside)
                }
            } else {
                addFriendButton.addAction(UIAction(handler: { _ in
                    self.signUpBeforeFriendship()
                }), for: .touchUpInside)
            }
        } else {
            var maxViews = -1
            for i in personalInfo.userAccount!.privateTags {
                if i.views > maxViews {
                    mostPopularTag = i
                    maxViews = i.views
                }
            }
            for i in personalInfo.userAccount!.publicTags {
                if i.views >= maxViews {
                    mostPopularTag = i
                    maxViews = i.views
                }
            }
        }
        
        if mostPopularTag != nil {
            if globalVariables.currentLanguage == "en" {
                if mostPopularTag?.enName == nil || mostPopularTag?.enName == "" {
                    popularTagName.text = mostPopularTag?.ruName
                } else {
                    popularTagName.text = mostPopularTag?.enName
                }
                var address: String? = ""
                if mostPopularTag?.enAddressName == nil || mostPopularTag?.enAddressName == "" {
                    address = mostPopularTag?.ruAddressName
                } else {
                    address = mostPopularTag?.enAddressName
                }
                if address != nil && address != "" {
                    popularTagAddress.text = address
                } else {
                    popularTagAddress.removeFromSuperview()
                    popularTagName.centerYAnchor.constraint(equalTo: popularTagViews.centerYAnchor).isActive = true
                }
                popularTagViews.text = String(describing: mostPopularTag!.views) + " views"
                
            } else {
                if mostPopularTag?.ruName == nil || mostPopularTag?.ruName == "" {
                    popularTagName.text = mostPopularTag?.enName
                } else {
                    popularTagName.text = mostPopularTag?.ruName
                }
                var address: String? = ""
                if mostPopularTag?.ruAddressName == nil || mostPopularTag?.ruAddressName == "" {
                    address = mostPopularTag?.enAddressName
                } else {
                    address = mostPopularTag?.ruAddressName
                }
                if address != nil && address != "" {
                    popularTagAddress.text = address
                } else {
                    popularTagAddress.removeFromSuperview()
                    popularTagName.centerYAnchor.constraint(equalTo: popularTagViews.centerYAnchor).isActive = true
                }
                popularTagViews.text = String(describing: mostPopularTag!.views) + " просмотров"
            }
        }
        
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        setupLayoutConstraint()
        
        scrollViewBottom.isActive = false
        scrollViewBottom = scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: globalVariables.bottomScreenLength)
        scrollViewBottom.isActive = true
        
        refreshControl.addTarget(self, action: #selector(self.refreshAccount(_:)), for: .valueChanged)
        scrollView.addSubview(refreshControl)
        scrollView.bringSubviewToFront(personalInfoView)
        
        personalInfoView.layer.cornerRadius = 16
        Helpers().addShadow(view: personalInfoView)
        userAvatar.layer.masksToBounds = true
        userAvatar.layer.cornerRadius = 20
        addFriendButton.layer.masksToBounds = true
        addFriendButton.layer.cornerRadius = 8
        friendsView.backgroundColor = UIColor(named: "infoColor")
        friendsView.layer.masksToBounds = true
        friendsView.layer.cornerRadius = 12
        tagsView.backgroundColor = UIColor(named: "infoColor")
        tagsView.layer.masksToBounds = true
        tagsView.layer.cornerRadius = 13
        newFriendsView.layer.masksToBounds = true
        newFriendsView.layer.cornerRadius = 13
        popularTagHighlightView.layer.masksToBounds = true
        popularTagHighlightView.layer.cornerRadius = 14
        ageView.backgroundColor = UIColor(named: "infoColor")
        nicknameView.backgroundColor = UIColor(named: "infoColor")
        countryView.backgroundColor = UIColor(named: "infoColor")
        
        mostPopularTagView.layer.cornerRadius = 16
        Helpers().addShadow(view: mostPopularTagView)
        popularTagHighlightView.backgroundColor = UIColor(named: "infoColor")
        
        achievementsView.layer.cornerRadius = 16
        Helpers().addShadow(view: achievementsView)
        
        if isAnotherUserAccount { // if it is another user account
            if globalVariables.currentLanguage == "en" {
                addFirstTagButton.setTitle("User have't tags yet", for: .normal)
            } else {
                addFirstTagButton.setTitle("Пользователь ещё не добавлял меток", for: .normal)
            }
            addFirstTagButton.setTitleColor(UIColor(named: "textGrey"), for: .normal)
            addFirstTagButton.isUserInteractionEnabled = false
            correctButton.isHidden = true
            optionsButton.isHidden = true
            logOutButton.isHidden = true
            
            userNameLabel.text = anotherUserAccount?.name
            if Helpers().sortedTags(allTags: anotherUserAccount!.publicTags).count + Helpers().sortedTags(allTags: anotherUserAccount!.privateTags).count == 0 {
                popularTagHighlightView.isHidden = true
            }
            friendsCountLabel.text = String(describing: anotherUserAccount!.friends.count)
            tagsCountLabel.text = String(describing: anotherUserAccount!.privateTags.count + anotherUserAccount!.publicTags.count)
            let avatar = anotherUserAccount?.avatar
            userAvatar.image = Helpers().imageFromString(string: avatar)
            
            if globalVariables.currentLanguage == "en" {
                self.title = "Account"
                tagsLabel.text = "Tags"
            } else {
                self.title = "Аккаунт"
                tagsLabel.text = "Метки"
            }
            
            newFriendsView.isHidden = true
        } else {
            
            userNameLabel.text = personalInfo.userAccount?.name
            if personalInfo.userAccount!.publicTags.count + personalInfo.userAccount!.privateTags.count == 0 {
                popularTagHighlightView.isHidden = true
            }
            friendsCountLabel.text = String(describing: personalInfo.userAccount!.friends.count)
            tagsCountLabel.text = String(describing: personalInfo.userAccount!.privateTags.count + personalInfo.userAccount!.publicTags.count)
            let avatar = personalInfo.userAccount?.avatar
            userAvatar.image = Helpers().imageFromString(string: avatar)
            
            if personalInfo.userAccount?.waitingFriends.count != 0 {
                newFriendsLabel.text = "\(personalInfo.userAccount!.waitingFriends.count)"
                if globalVariables.currentLanguage == "en" {
                    newFriendsLabel.text! += " new"
                } else {
                    if personalInfo.userAccount?.waitingFriends.count == 1 {
                        newFriendsLabel.text! += " новый"
                    } else {
                        newFriendsLabel.text! += " новых"
                    }
                }
            } else {
                newFriendsView.isHidden = true
            }
        }
        
        
        effectView.removeConstraints(effectView.constraints)
        effectView.removeFromSuperview()
        self.view.addSubview(effectView)
        effectView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        effectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        effectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        effectView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: globalVariables.bottomScreenLength).isActive = true
        effectView.isHidden = true
    }
    
    // MARK: - Setup Layout Constraints
    
    func setupLayoutConstraint() {
        
        settingShowingVariables()
        
        if !isAnotherUserAccount {
            addFriendButton.removeFromSuperview()
            if showAge {
                ageView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8).isActive = true
            } else if showNickname {
                nicknameView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8).isActive = true
            } else if showCountry {
                countryView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8).isActive = true
            } else {
                friendsView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8).isActive = true
            }
        }
        if !showAge {
            ageView?.removeFromSuperview()
            if showNickname {
                if isAnotherUserAccount {
                    nicknameView.topAnchor.constraint(equalTo: addFriendButton.bottomAnchor, constant: 4).isActive = true
                } else {
                    nicknameView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8).isActive = true
                }
            } else if showCountry {
                if isAnotherUserAccount {
                    countryView.topAnchor.constraint(equalTo: addFriendButton.bottomAnchor, constant: 4).isActive = true
                } else {
                    countryView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8).isActive = true
                }
            } else {
                if isAnotherUserAccount {
                    friendsView.topAnchor.constraint(equalTo: addFriendButton.bottomAnchor, constant: 4).isActive = true
                } else {
                    friendsView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8).isActive = true
                }
            }
        } else {
            if !isAnotherUserAccount {
                ageLabel.text = "\(Helpers().ageFromBirthday(year: personalInfo.userAccount!.birthYear!, mounth: personalInfo.userAccount!.birthMounth!, day: personalInfo.userAccount!.birthDay!))"
                birthDay.text = String(describing: personalInfo.userAccount!.birthDay!)
                birthMonth.text = globalVariables.mountnNumberToString[(personalInfo.userAccount!.birthMounth!)]
            } else {
                ageLabel.text = "\(Helpers().ageFromBirthday(year: anotherUserAccount!.birthYear!, mounth: anotherUserAccount!.birthMounth!, day: anotherUserAccount!.birthDay!))"
                birthDay.text = String(describing: anotherUserAccount!.birthDay!)
                birthMonth.text = globalVariables.mountnNumberToString[(anotherUserAccount!.birthMounth!)]
            }
        }
        
        if !showNickname {
            nicknameView?.removeFromSuperview()
            if showAge {
                if showCountry {
                    countryView.topAnchor.constraint(equalTo: ageView.bottomAnchor, constant: 0).isActive = true
                } else {
                    friendsView.topAnchor.constraint(equalTo: ageView.bottomAnchor, constant: 0).isActive = true
                }
            } else if isAnotherUserAccount {
                if showCountry {
                    countryView.topAnchor.constraint(equalTo: addFriendButton.bottomAnchor, constant: 4).isActive = true
                } else {
                    friendsView.topAnchor.constraint(equalTo: addFriendButton.bottomAnchor, constant: 4).isActive = true
                }
            } else {
                if showCountry {
                    countryView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8).isActive = true
                } else {
                    friendsView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8).isActive = true
                }
            }
        } else {
            if !isAnotherUserAccount {
                nicknameLabel.text = personalInfo.userAccount!.nickname!
            } else {
                nicknameLabel.text = anotherUserAccount!.nickname!
            }
        }
        
        if !showCountry {
            countryView?.removeFromSuperview()
            if showNickname {
                friendsView.topAnchor.constraint(equalTo: nicknameView.bottomAnchor, constant: 0).isActive = true
            } else if showAge {
                friendsView.topAnchor.constraint(equalTo: ageView.bottomAnchor, constant: 0).isActive = true
            } else if isAnotherUserAccount {
                friendsView.topAnchor.constraint(equalTo: addFriendButton.bottomAnchor, constant: 4).isActive = true
            } else {
                friendsView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8).isActive = true
            }
        } else {
            if !isAnotherUserAccount {
                countryLabel.text = "\(String(describing: personalInfo.userAccount!.country!)), \(String(describing: personalInfo.userAccount!.city!))"
            } else {
                countryLabel.text = "\(String(describing: anotherUserAccount!.country!)), \(String(describing: anotherUserAccount!.city!))"
            }
        }
        
        if showAchievements {
            if !variableNoMeaning{
                buildAchievementsView()
            }
        } else {
            achievementsView?.removeFromSuperview()
        }
        variableNoMeaning = false
        self.view.layoutSubviews()
        self.scrollView.layoutSubviews()
        viewDidLayoutSubviews()
    }
    
    // MARK: - Showing Variables
    
    func settingShowingVariables() {
        if !isAnotherUserAccount {
            if personalInfo.userAccount?.birthYear != nil && personalInfo.userAccount?.birthYear != -1 && personalInfo.userAccount?.birthDay != nil && personalInfo.userAccount?.birthDay != -1 && personalInfo.userAccount?.birthMounth != nil && personalInfo.userAccount?.birthMounth != -1 { showAge = true }
            if personalInfo.userAccount?.nickname != nil && personalInfo.userAccount?.nickname != "" { showNickname = true }
            if personalInfo.userAccount?.country != nil && personalInfo.userAccount?.country != "" && personalInfo.userAccount?.city != nil && personalInfo.userAccount?.city != "" { showCountry = true }
            showAchievements = true
        } else {
            if anotherUserAccount?.birthYear != nil && anotherUserAccount?.birthYear != -1 &&
                anotherUserAccount?.birthDay != nil && anotherUserAccount?.birthDay != -1 && anotherUserAccount?.birthMounth != nil && anotherUserAccount?.birthMounth != -1 && (anotherUserAccount!.permissionBirthdayEveryone || (anotherUserAccount!.permissionBirthdayFriends && Helpers().isUserMyFriend(id: anotherUserAccount!.userId))) { showAge = true }
            if anotherUserAccount?.nickname != nil && anotherUserAccount?.nickname != "" { showNickname = true }
            if anotherUserAccount?.country != nil && anotherUserAccount?.country != "" && anotherUserAccount?.city != nil && anotherUserAccount?.city != "" && (anotherUserAccount!.permissionCountryCityEveryone || (anotherUserAccount!.permissionCountryCityFriends && Helpers().isUserMyFriend(id: anotherUserAccount!.userId))) { showCountry = true }
            if anotherUserAccount!.permissionAchievementsEveryOne || Helpers().isUserMyFriend(id: anotherUserAccount!.userId) {
                showAchievements = true
            }
        }
    }
    
    // MARK: - Build Achievements View
    
    func buildAchievementsView() {
        
        self.view.layoutSubviews()
        self.scrollView.layoutSubviews()
        self.achievementsView.layoutSubviews()
        
        let viewWidth = self.achievementsView.frame.size.width / 3
        
        for achievement in 0..<globalVariables.achieveemntsList.count {
        
            let viewAchiev = HighlightView()
            viewAchiev.translatesAutoresizingMaskIntoConstraints = false
            viewAchiev.backgroundColor = .clear
            
            viewAchiev.layer.masksToBounds = true
            viewAchiev.layer.cornerRadius = 12
            
            achievementsView.addSubview(viewAchiev)
            
            viewAchiev.widthAnchor.constraint(equalToConstant: viewWidth).isActive = true
            viewAchiev.heightAnchor.constraint(equalToConstant: viewWidth).isActive = true
            viewAchiev.topAnchor.constraint(equalTo: achievementsView.topAnchor, constant: CGFloat(achievement / 3) * viewWidth + 39).isActive = true
            viewAchiev.leadingAnchor.constraint(equalTo: achievementsView.leadingAnchor, constant: CGFloat(achievement % 3) * viewWidth).isActive = true
                
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.backgroundColor = .clear
            
            viewAchiev.addSubview(imageView)
            
            imageView.widthAnchor.constraint(equalToConstant: viewWidth * 0.54).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: viewWidth * 0.54).isActive = true
            imageView.centerXAnchor.constraint(equalTo: viewAchiev.centerXAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: viewAchiev.topAnchor, constant: viewWidth * 0.15).isActive = true
            
            if !isAnotherUserAccount {
                if personalInfo.userAccount!.achievements.contains(globalVariables.achieveemntsList[achievement].enText) {
                    imageView.image = UIImage(named: globalVariables.achieveemntsList[achievement].achievedImageName)
                } else {
                    imageView.image = UIImage(named: globalVariables.achieveemntsList[achievement].imageName)
                }
            } else {
                if anotherUserAccount!.achievements.contains(globalVariables.achieveemntsList[achievement].enText) {
                    imageView.image = UIImage(named: globalVariables.achieveemntsList[achievement].achievedImageName)
                } else {
                    imageView.image = UIImage(named: globalVariables.achieveemntsList[achievement].imageName)
                }
            }
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            
            if globalVariables.currentLanguage == "en" {
                label.text = globalVariables.achieveemntsList[achievement].enText
            } else {
                label.text = globalVariables.achieveemntsList[achievement].ruText
            }
            
            if !isAnotherUserAccount {
                if personalInfo.userAccount!.achievements.contains(globalVariables.achieveemntsList[achievement].enText) {
                    label.textColor = .label
                } else {
                    label.textColor = UIColor(named: "textGrey")
                }
            } else {
                if anotherUserAccount!.achievements.contains(globalVariables.achieveemntsList[achievement].enText) {
                    label.textColor = .label
                } else {
                    label.textColor = UIColor(named: "textGrey")
                }
            }
            
            label.font = UIFont.systemFont(ofSize: 13)
            label.textAlignment = .center
            
            viewAchiev.addSubview(label)
            
            label.leadingAnchor.constraint(equalTo: viewAchiev.leadingAnchor, constant: 8).isActive = true
            label.trailingAnchor.constraint(equalTo: viewAchiev.trailingAnchor, constant: -8).isActive = true
            label.bottomAnchor.constraint(equalTo: viewAchiev.bottomAnchor, constant: -2).isActive = true
            label.heightAnchor.constraint(equalToConstant: 34).isActive = true
            label.numberOfLines = 0
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showAchievementDetails))
            viewAchiev.addGestureRecognizer(tapGesture)
            tapGesture.view?.tag = achievement
        }
        
        var rowsCount = globalVariables.achieveemntsList.count / 3
        if globalVariables.achieveemntsList.count % 3 != 0 { rowsCount += 1 }
        
        achievementsViewHeight.constant = CGFloat(rowsCount) * viewWidth + 39
        
    }
    
    // MARK: - Achievements Details
    
    @objc func showAchievementDetails(_ sender: UITapGestureRecognizer) {
        achievDetailView = UIView()
        
        achievDetailView?.translatesAutoresizingMaskIntoConstraints = false
        achievDetailView?.backgroundColor = UIColor(named: "infoColor")
        
        self.view.addSubview(achievDetailView!)
        
        self.view.bringSubviewToFront(achievDetailView!)
        achievDetailView?.layer.masksToBounds = true
        achievDetailView?.layer.cornerRadius = 20
        achievDetailView?.isHidden = true
        
        achievDetailView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40).isActive = true
        achievDetailView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40).isActive = true
        achievDetailView?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        //achievDetailView?.heightAnchor.constraint(equalToConstant: 500).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        if globalVariables.currentLanguage == "en" {
            nameLabel.text = globalVariables.achieveemntsList[sender.view!.tag].enText
        } else {
            nameLabel.text = globalVariables.achieveemntsList[sender.view!.tag].ruText
        }
        
        nameLabel.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        
        achievDetailView?.addSubview(nameLabel)
        
        nameLabel.centerXAnchor.constraint(equalTo: achievDetailView!.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: achievDetailView!.topAnchor, constant: 22).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: achievDetailView!.leadingAnchor, constant: 14).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: achievDetailView!.trailingAnchor, constant: -14).isActive = true
        
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        
        imageView.image = UIImage(named: globalVariables.achieveemntsList[sender.view!.tag].achievedImageName)
        
        achievDetailView!.addSubview(imageView)
        
        self.view.layoutSubviews()
        self.achievDetailView?.layoutSubviews()
        
        imageView.centerXAnchor.constraint(equalTo: achievDetailView!.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: achievDetailView!.frame.width * 0.35).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: achievDetailView!.frame.width * 0.35).isActive = true
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        if globalVariables.currentLanguage == "en" {
            descriptionLabel.text = globalVariables.achieveemntsList[sender.view!.tag].enDescription
        } else {
            descriptionLabel.text = globalVariables.achieveemntsList[sender.view!.tag].ruDescription
        }
        
        achievDetailView!.addSubview(descriptionLabel)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        
        descriptionLabel.centerXAnchor.constraint(equalTo: achievDetailView!.centerXAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: achievDetailView!.bottomAnchor, constant: -22).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: achievDetailView!.leadingAnchor, constant: 22).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: achievDetailView!.trailingAnchor, constant: -22).isActive = true
        
        descriptionLabel.textColor = UIColor(named: "textGrey")
        
        impactFeedback.impactOccurred()
        
        UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: { [self] in
            achievDetailView!.isHidden = false
            effectView.isHidden = false
        }, completion: nil)
        
    }
    
    @IBAction func closeAchievDetails(_ sender: Any) {
        UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: { [self] in
            achievDetailView!.isHidden = true
            effectView.isHidden = true
        }, completion: nil)
        achievDetailView?.removeFromSuperview()
        achievDetailView = nil
    }
    
    // MARK: - Another Functions
    
    @IBAction func openOptions() {
        let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
        pushViewController(storyboard: storyboard, identifier: "OptionsViewController")
    }
    
    @IBAction func correctAccount(_ sender: Any) {
        
        let currentVC = self.navigationController?.topViewController
        
        guard var viewConstrollers = currentVC?.navigationController?.viewControllers else {
            return
        }
        
        _ = viewConstrollers.popLast()
        
        let accountInfoViewController = UIStoryboard(name: "Accounts", bundle: nil).instantiateViewController(identifier: "AccountIfoViewController")
        let correctAccountViewController = UIStoryboard(name: "Accounts", bundle: nil).instantiateViewController(identifier: "CorrectAccountViewController")
        
        viewConstrollers.append(accountInfoViewController)
        viewConstrollers.append(correctAccountViewController)
        
        currentVC?.navigationController?.setViewControllers(viewConstrollers, animated: true)
    }
    
    @IBAction func openFriends(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Accounts", bundle: nil)
    
        let VC = storyboard.instantiateViewController(identifier: "FriendsViewController") as! FriendsViewController
        if !isAnotherUserAccount {
            VC.isMyFriendsList = true
            VC.friends = personalInfo.userAccount!.friends
            VC.requestsForFriendship = personalInfo.userAccount!.waitingFriends
        } else {
            VC.isMyFriendsList = false
            VC.friends = anotherUserAccount!.friends
        }
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func openTags(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Tags", bundle: nil)
        
        let VC = storyboard.instantiateViewController(identifier: "TagsListViewController") as! TagsListViewController
        
        if !isAnotherUserAccount {
            VC.personalTags = personalInfo.userAccount!.privateTags
            VC.publicTags = personalInfo.userAccount!.publicTags
            VC.isMyTags = true
        } else {
            VC.personalTags = anotherUserPrivateTags
            VC.publicTags = anotherUserPublicTags
            VC.isMyTags = false
        }
        
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func addFirstTag(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Tags", bundle: nil)
        pushViewController(storyboard: storyboard, identifier: "AddingAndEditingViewController")
    }
    
    @IBAction func openPopularTag(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Tags", bundle: nil)
        
        let VC = storyboard.instantiateViewController(identifier: "InfoViewController") as! InfoViewController
        VC.tag = mostPopularTag
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func pushViewController(storyboard: UIStoryboard, identifier: String) {
        
        let VC = storyboard.instantiateViewController(identifier: identifier)
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func logOut(_ sender: Any) {

        var title: String!
        
        if globalVariables.currentLanguage == "en" {
            title = "Are your sure?"
        } else {
            title = "Вы уверены?"
        }
        
        let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        if globalVariables.currentLanguage == "en" {
            title = "Cancel"
        } else {
            title = "Отменить"
        }
        
        actionSheet.addAction(UIAlertAction(title: title, style: .cancel, handler: nil))
        if globalVariables.currentLanguage == "en" {
            title = "Log out"
        } else {
            title = "Выйти"
        }
        actionSheet.addAction(UIAlertAction(title: title, style: .destructive, handler: { _ in
            
            Server.shared.changeDeviceTokens(data: nil) { answer in
                if answer.success {
                    personalInfo.userAccount = nil
                    personalInfo.password = nil
                    personalInfo.isAuthorised = false
                    UserDefaults.standard.set(nil, forKey:"offlineUserAccount")
                    Helpers().sortAvailableTags(category: nil) { _ in
                        print("")
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }))
        
        present(actionSheet, animated: true)
    }
    
    // MARK: - Friends functions
    
    func signUpBeforeFriendship() {
        let storyboard = UIStoryboard(name: "Accounts", bundle: nil)
        
        let VC = storyboard.instantiateViewController(identifier: "CreateAccountViewController")
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        globalVariables.shouldStayOnAccountInfoViewController = true
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func addFriend() {
        addFriendButton.isEnabled = false
        placeNotificationsView(event: .loading)
        Server.shared.sendRequestToFriend(form: AddFriendForm(myId: personalInfo.userAccount!.userId, userId: anotherUserAccount!.userId)) { [self] answer in
            addFriendButton.isEnabled = true
            removeNotificationView { [self] _ in
                if answer.success {
                    personalInfo.userAccount?.requestToFriends.append(self.anotherUserAccount!.userId)
                    addFriendButton.backgroundColor = .systemGray4
                    addFriendButton.setTitleColor(.label, for: .normal)
                    if globalVariables.currentLanguage == "en" {
                        addFriendButton.setTitle("Request sent", for: .normal)
                    } else {
                        addFriendButton.setTitle("Заявка отправлена", for: .normal)
                    }
                    
                    addFriendButton.removeTarget(nil, action: nil, for: .allEvents)
                    addFriendButton.addAction(UIAction(handler: { [self] _ in
                        cancelRequest()
                    }), for: .touchUpInside)
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
    
    func alertToDeleteFriend() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        var title: String!
        if globalVariables.currentLanguage == "en" {
            title = "Cancel"
        } else {
            title = "Отменить"
        }
        
        actionSheet.addAction(UIAlertAction(title: title, style: .cancel, handler: nil))
        if globalVariables.currentLanguage == "en" {
            title = "Delete from friends"
        } else {
            title = "Удалить из друзей"
        }
        actionSheet.addAction(UIAlertAction(title: title, style: .destructive, handler: { _ in
            self.addFriendButton.isEnabled = false
            self.placeNotificationsView(event: .loading)
            Server.shared.deleteFriend(form: AddFriendForm(myId: personalInfo.userAccount!.userId, userId: self.anotherUserAccount!.userId)) { [self] answer in
                addFriendButton.isEnabled = true
                removeNotificationView { [self] _ in
                    if answer.success {
                        personalInfo.userAccount!.friends.removeAll { friend in
                            return friend.userId == self.anotherUserAccount!.userId
                        }
                        personalInfo.userAccount!.followers.append(anotherUserAccount!.userId)
                        let currentVC = self.navigationController?.topViewController
                        
                        guard let viewConstrollers = currentVC?.navigationController?.viewControllers else { return }
                        
                        for i in viewConstrollers {
                            if i is FriendsViewController {
                                let friendsListVC = i as! FriendsViewController
                                if friendsListVC.isMyFriendsList {
                                    friendsListVC.friends.removeAll { friend in
                                        return friend.userId == self.anotherUserAccount?.userId
                                    }
                                }
                            }
                        }
                        
                        addFriendButton.backgroundColor = .systemGray4
                        addFriendButton.setTitleColor(.label, for: .normal)
                        if globalVariables.currentLanguage == "en" {
                            addFriendButton.setTitle("Accept request", for: .normal)
                        } else {
                            addFriendButton.setTitle("Принять заявку", for: .normal)
                        }
                        
                        addFriendButton.removeTarget(nil, action: nil, for: .allEvents)
                        addFriendButton.addAction(UIAction(handler: { [self] _ in
                            acceptRequest()
                        }), for: .touchUpInside)
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
    
    func acceptRequest() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        var title: String!
        if globalVariables.currentLanguage == "en" {
            title = "Cancel"
        } else {
            title = "Отменить"
        }
        
        actionSheet.addAction(UIAlertAction(title: title, style: .cancel, handler: nil))
        if globalVariables.currentLanguage == "en" {
            title = "Add friend"
        } else {
            title = "Добавить в друзья"
        }
        actionSheet.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
            self.addFriendButton.isEnabled = false
            self.placeNotificationsView(event: .loading)
            Server.shared.addFriend(form: AddFriendForm(myId: personalInfo.userAccount!.userId, userId: self.anotherUserAccount!.userId)) { [self] answer in
                addFriendButton.isEnabled = true
                removeNotificationView { [self] _ in
                    if answer.success {
                        
                        let currentVC = self.navigationController?.topViewController
                        
                        guard let viewConstrollers = currentVC?.navigationController?.viewControllers else { return }
                        
                        let friend = Friend(name: anotherUserAccount!.name, userId: anotherUserAccount!.userId, avatar: anotherUserAccount!.avatar, nickname: anotherUserAccount!.nickname)
                        for i in viewConstrollers {
                            if i is FriendsViewController {
                                let friendsListVC = i as! FriendsViewController
                                if friendsListVC.isMyFriendsList {
                                    friendsListVC.friends.append(friend)
                                    friendsListVC.requestsForFriendship.removeAll { friend in
                                        return friend.userId == anotherUserAccount!.userId
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
                        
                        addFriendButton.backgroundColor = UIColor(named: "background")
                        addFriendButton.setTitleColor(.label, for: .normal)
                        if globalVariables.currentLanguage == "en" {
                            addFriendButton.setTitle("My friend", for: .normal)
                        } else {
                            addFriendButton.setTitle("Мой друг", for: .normal)
                        }
                        
                        addFriendButton.removeTarget(nil, action: nil, for: .allEvents)
                        addFriendButton.addAction(UIAction(handler: { [self] _ in
                            alertToDeleteFriend()
                        }), for: .touchUpInside)
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
    
    func cancelRequest() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        var title: String!
        if globalVariables.currentLanguage == "en" {
            title = "Cancel"
        } else {
            title = "Отменить"
        }
        
        actionSheet.addAction(UIAlertAction(title: title, style: .cancel, handler: nil))
        if globalVariables.currentLanguage == "en" {
            title = "Cancel request"
        } else {
            title = "Отменить заявку"
        }
        actionSheet.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
            self.addFriendButton.isEnabled = false
            self.placeNotificationsView(event: .loading)
            Server.shared.cancelRequest(form: AddFriendForm(myId: personalInfo.userAccount!.userId, userId: self.anotherUserAccount!.userId)) { [self] answer in
                addFriendButton.isEnabled = true
                removeNotificationView { [self] _ in
                    if answer.success {
                        personalInfo.userAccount!.requestToFriends.removeAll { val in
                            return val == anotherUserAccount!.userId
                        }
                        addFriendButton.backgroundColor = .systemBlue
                        if globalVariables.currentLanguage == "en" {
                            addFriendButton.setTitle("Add to friends", for: .normal)
                        } else {
                            addFriendButton.setTitle("Добавить в друзья", for: .normal)
                        }
                        addFriendButton.setTitleColor(.white, for: .normal)
                        
                        addFriendButton.removeTarget(nil, action: nil, for: .allEvents)
                        addFriendButton.addAction(UIAction(handler: { [self] _ in
                            addFriend()
                        }), for: .touchUpInside)
                    } else {
                        if answer.status == 433 {
                            placeNotificationsView(event: .loading)
                        } else {
                            placeNotificationsView(event: .error)
                        }
                    }
                }
            }
        }))
        
        present(actionSheet, animated: true)
    }
    
    // MARK: - Notifications working
    
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
    
    // MARK: - Refresh Funtion
    
    @objc func refreshAccount(_ sender: Any) {
        
        scrollViewTop.constant = 40
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        var id = 0
        if isAnotherUserAccount {
            id = anotherUserAccount!.userId
        } else {
            id = personalInfo.userAccount!.userId
        }
        
        if isAnotherUserAccount && personalInfo.isAuthorised {
            Server.shared.signIn(email: personalInfo.emailAddress!, password: personalInfo.password!) { answer in
                Server.shared.getUser(userId: id) { [self] answer in
                    if answer is User {
                        
                        UIView.animate(withDuration: 0.2) { [self] in
                            let account = answer as! User
                            
                            if !self.isAnotherUserAccount {
                                personalInfo.userAccount = account
                            } else {
                                self.anotherUserAccount = account
                            }
                            
                            userNameLabel.text = account.name
                            userAvatar.image = Helpers().imageFromString(string: account.avatar)
                            
                            settingShowingVariables()
                            
                            if ageView != nil && showAge {
                                ageLabel.text = "\(Helpers().ageFromBirthday(year: account.birthYear!, mounth: account.birthMounth!, day: account.birthDay!))"
                                birthDay.text = String(describing: account.birthDay!)
                                birthMonth.text = globalVariables.mountnNumberToString[account.birthMounth!]
                            }
                            if nicknameView != nil && showNickname {
                                nicknameLabel.text = account.nickname
                            }
                            if countryView != nil && showCountry {
                                countryLabel.text = account.country! + ", " + account.city!
                            }
                            friendsCountLabel.text = "\(account.friends.count)"
                            
                            if isAnotherUserAccount {
                                
                                anotherUserPrivateTags = Helpers().sortedTags(allTags: account.privateTags)
                                anotherUserPublicTags = Helpers().sortedTags(allTags: account.publicTags)
                                
                                tagsCountLabel.text = String(describing: anotherUserPrivateTags.count + anotherUserPublicTags.count)
                                
                                addFriendButton.removeTarget(nil, action: nil, for: .allEvents)
                                if personalInfo.isAuthorised {
                                    if personalInfo.userAccount!.friends.contains(where: { friend in
                                        return friend.userId == anotherUserAccount!.userId
                                    }) {
                                        addFriendButton.backgroundColor = UIColor(named: "background")
                                        addFriendButton.setTitleColor(.label, for: .normal)
                                        if globalVariables.currentLanguage == "en" {
                                            addFriendButton.setTitle("My friend", for: .normal)
                                        } else {
                                            addFriendButton.setTitle("Мой друг", for: .normal)
                                        }
                                        
                                        addFriendButton.addAction(UIAction(handler: { _ in
                                            self.alertToDeleteFriend()
                                        }), for: .touchUpInside)
                                        
                                    } else if personalInfo.userAccount!.requestToFriends.contains(anotherUserAccount!.userId) {
                                        
                                        addFriendButton.backgroundColor = .systemGray4
                                        addFriendButton.setTitleColor(.label, for: .normal)
                                        if globalVariables.currentLanguage == "en" {
                                            addFriendButton.setTitle("Request sent", for: .normal)
                                        } else {
                                            addFriendButton.setTitle("Заявка отправлена", for: .normal)
                                        }
                                        addFriendButton.addAction(UIAction(handler: { _ in
                                            self.cancelRequest()
                                        }), for: .touchUpInside)
                                    } else if personalInfo.userAccount!.followers.contains(anotherUserAccount!.userId) || personalInfo.userAccount!.waitingFriends.contains(where: { friend in
                                        return friend.userId == anotherUserAccount!.userId
                                    }) {
                                        addFriendButton.backgroundColor = .systemGray4
                                        addFriendButton.setTitleColor(.label, for: .normal)
                                        if globalVariables.currentLanguage == "en" {
                                            addFriendButton.setTitle("Accept request", for: .normal)
                                        } else {
                                            addFriendButton.setTitle("Принять заявку", for: .normal)
                                        }
                                        addFriendButton.addAction(UIAction(handler: { _ in
                                            self.acceptRequest()
                                        }), for: .touchUpInside)
                                    } else {
                                        addFriendButton.addAction(UIAction(handler: { _IOFBF in
                                            self.addFriend()
                                        }), for: .touchUpInside)
                                    }
                                } else {
                                    addFriendButton.addAction(UIAction(handler: { _ in
                                        self.signUpBeforeFriendship()
                                    }), for: .touchUpInside)
                                }
                            }
                            
                            if !isAnotherUserAccount {
                                if account.waitingFriends.count > 0 {
                                    newFriendsView.isHidden = false
                                    
                                    if account.waitingFriends.count != 0 {
                                        newFriendsLabel.text = "\(account.waitingFriends.count)"
                                        if globalVariables.currentLanguage == "en" {
                                            newFriendsLabel.text! += " new"
                                        } else {
                                            if account.waitingFriends.count == 1 {
                                                newFriendsLabel.text! += " новый"
                                            } else {
                                                newFriendsLabel.text! += " новых"
                                            }
                                        }
                                    } else {
                                        newFriendsView.isHidden = true
                                    }
                                }
                            }
                            
                            if achievementsView != nil && showAchievements{
                                for i in achievementsView.subviews {
                                    if i.tag != 444 {
                                        i.removeFromSuperview()
                                    }
                                }
                                
                                buildAchievementsView()
                            }
                            
                            if isAnotherUserAccount {
                                var maxViews = -1
                                for i in anotherUserPrivateTags {
                                    if i.views > maxViews {
                                        mostPopularTag = i
                                        maxViews = i.views
                                    }
                                }
                                for i in anotherUserPublicTags {
                                    if i.views >= maxViews {
                                        mostPopularTag = i
                                        maxViews = i.views
                                    }
                                }
                            } else {
                                var maxViews = -1
                                for i in account.privateTags {
                                    if i.views > maxViews {
                                        mostPopularTag = i
                                        maxViews = i.views
                                    }
                                }
                                for i in account.publicTags {
                                    if i.views >= maxViews {
                                        mostPopularTag = i
                                        maxViews = i.views
                                    }
                                }
                            }
                            
                            if mostPopularTag != nil {
                                if globalVariables.currentLanguage == "en" {
                                    if mostPopularTag?.enName == nil || mostPopularTag?.enName == "" {
                                        popularTagName.text = mostPopularTag?.ruName
                                    } else {
                                        popularTagName.text = mostPopularTag?.enName
                                    }
                                    var address: String? = ""
                                    if mostPopularTag?.enAddressName == nil || mostPopularTag?.enAddressName == "" {
                                        address = mostPopularTag?.ruAddressName
                                    } else {
                                        address = mostPopularTag?.enAddressName
                                    }
                                    if address != nil && address != "" {
                                        popularTagAddress?.text = address
                                    } else {
                                        popularTagAddress?.removeFromSuperview()
                                        popularTagName?.removeFromSuperview()
                                        popularTagHighlightView?.addSubview(popularTagName)
                                        popularTagName?.leadingAnchor.constraint(equalTo: popularTagHighlightView.leadingAnchor, constant: 20).isActive = true
                                        popularTagName?.centerYAnchor.constraint(equalTo: popularTagViews.centerYAnchor).isActive = true
                                    }
                                    popularTagViews?.text = String(describing: mostPopularTag!.views) + " views"
                                    
                                } else {
                                    if mostPopularTag?.ruName == nil || mostPopularTag?.ruName == "" {
                                        popularTagName?.text = mostPopularTag?.enName
                                    } else {
                                        popularTagName?.text = mostPopularTag?.ruName
                                    }
                                    var address: String? = ""
                                    if mostPopularTag?.ruAddressName == nil || mostPopularTag?.ruAddressName == "" {
                                        address = mostPopularTag?.enAddressName
                                    } else {
                                        address = mostPopularTag?.ruAddressName
                                    }
                                    if address != nil && address != "" {
                                        popularTagAddress?.text = address
                                    } else {
                                        popularTagAddress?.removeFromSuperview()
                                        popularTagName?.removeFromSuperview()
                                        popularTagHighlightView?.addSubview(popularTagName)
                                        popularTagName?.leadingAnchor.constraint(equalTo: popularTagHighlightView.leadingAnchor, constant: 20).isActive = true
                                        popularTagName?.centerYAnchor.constraint(equalTo: popularTagViews.centerYAnchor).isActive = true
                                    }
                                    popularTagViews?.text = String(describing: mostPopularTag!.views) + " просмотров"
                                }
                            }
                        }
                    } else {
                        if answer is ServerAnswer {
                            if (answer as! ServerAnswer).status == 433 {
                                placeNotificationsView(event: .serverOff)
                            } else {
                                placeNotificationsView(event: .error)
                            }
                        }
                    }
                }
            }
        } else {
            Server.shared.getUser(userId: id) { [self] answer in
                if answer is User {
                    
                    UIView.animate(withDuration: 0.2) { [self] in
                        let account = answer as! User
                        
                        if !self.isAnotherUserAccount {
                            personalInfo.userAccount = account
                        } else {
                            self.anotherUserAccount = account
                        }
                        
                        userNameLabel.text = account.name
                        userAvatar.image = Helpers().imageFromString(string: account.avatar)
                        
                        settingShowingVariables()
                        
                        if ageView != nil && showAge {
                            ageLabel.text = "\(Helpers().ageFromBirthday(year: account.birthYear!, mounth: account.birthMounth!, day: account.birthDay!))"
                            birthDay.text = String(describing: account.birthDay!)
                            birthMonth.text = globalVariables.mountnNumberToString[account.birthMounth!]
                        }
                        if nicknameView != nil && showNickname {
                            nicknameLabel.text = account.nickname
                        }
                        if countryView != nil && showCountry {
                            countryLabel.text = account.country! + ", " + account.city!
                        }
                        friendsCountLabel.text = "\(account.friends.count)"
                        
                        if isAnotherUserAccount {
                            
                            anotherUserPrivateTags = Helpers().sortedTags(allTags: account.privateTags)
                            anotherUserPublicTags = Helpers().sortedTags(allTags: account.publicTags)
                            
                            tagsCountLabel.text = String(describing: anotherUserPrivateTags.count + anotherUserPublicTags.count)
                            
                            addFriendButton.removeTarget(nil, action: nil, for: .allEvents)
                            if personalInfo.isAuthorised {
                                if personalInfo.userAccount!.friends.contains(where: { friend in
                                    return friend.userId == anotherUserAccount!.userId
                                }) {
                                    addFriendButton.backgroundColor = UIColor(named: "background")
                                    addFriendButton.setTitleColor(.label, for: .normal)
                                    if globalVariables.currentLanguage == "en" {
                                        addFriendButton.setTitle("My friend", for: .normal)
                                    } else {
                                        addFriendButton.setTitle("Мой друг", for: .normal)
                                    }
                                    
                                    addFriendButton.addAction(UIAction(handler: { _ in
                                        self.alertToDeleteFriend()
                                    }), for: .touchUpInside)
                                    
                                } else if personalInfo.userAccount!.requestToFriends.contains(anotherUserAccount!.userId) {
                                    
                                    addFriendButton.backgroundColor = .systemGray4
                                    addFriendButton.setTitleColor(.label, for: .normal)
                                    if globalVariables.currentLanguage == "en" {
                                        addFriendButton.setTitle("Request sent", for: .normal)
                                    } else {
                                        addFriendButton.setTitle("Заявка отправлена", for: .normal)
                                    }
                                    addFriendButton.addAction(UIAction(handler: { _ in
                                        self.cancelRequest()
                                    }), for: .touchUpInside)
                                } else if personalInfo.userAccount!.followers.contains(anotherUserAccount!.userId) || personalInfo.userAccount!.waitingFriends.contains(where: { friend in
                                    return friend.userId == anotherUserAccount!.userId
                                }) {
                                    addFriendButton.backgroundColor = .systemGray4
                                    addFriendButton.setTitleColor(.label, for: .normal)
                                    if globalVariables.currentLanguage == "en" {
                                        addFriendButton.setTitle("Accept request", for: .normal)
                                    } else {
                                        addFriendButton.setTitle("Принять заявку", for: .normal)
                                    }
                                    addFriendButton.addAction(UIAction(handler: { _ in
                                        self.acceptRequest()
                                    }), for: .touchUpInside)
                                } else {
                                    addFriendButton.addAction(UIAction(handler: { _IOFBF in
                                        self.addFriend()
                                    }), for: .touchUpInside)
                                }
                            } else {
                                addFriendButton.addAction(UIAction(handler: { _ in
                                    self.signUpBeforeFriendship()
                                }), for: .touchUpInside)
                            }
                        }
                        
                        if !isAnotherUserAccount {
                            if account.waitingFriends.count > 0 {
                                newFriendsView.isHidden = false
                                
                                if account.waitingFriends.count != 0 {
                                    newFriendsLabel.text = "\(account.waitingFriends.count)"
                                    if globalVariables.currentLanguage == "en" {
                                        newFriendsLabel.text! += " new"
                                    } else {
                                        if account.waitingFriends.count == 1 {
                                            newFriendsLabel.text! += " новый"
                                        } else {
                                            newFriendsLabel.text! += " новых"
                                        }
                                    }
                                } else {
                                    newFriendsView.isHidden = true
                                }
                            }
                        }
                        
                        if achievementsView != nil && showAchievements {
                            for i in achievementsView.subviews {
                                if i.tag != 444 {
                                    i.removeFromSuperview()
                                }
                            }
                            
                            buildAchievementsView()
                        }
                        
                        if isAnotherUserAccount {
                            var maxViews = -1
                            for i in anotherUserPrivateTags {
                                if i.views > maxViews {
                                    mostPopularTag = i
                                    maxViews = i.views
                                }
                            }
                            for i in anotherUserPublicTags {
                                if i.views >= maxViews {
                                    mostPopularTag = i
                                    maxViews = i.views
                                }
                            }
                        } else {
                            var maxViews = -1
                            for i in account.privateTags {
                                if i.views > maxViews {
                                    mostPopularTag = i
                                    maxViews = i.views
                                }
                            }
                            for i in account.publicTags {
                                if i.views >= maxViews {
                                    mostPopularTag = i
                                    maxViews = i.views
                                }
                            }
                        }
                        
                        if mostPopularTag != nil {
                            if globalVariables.currentLanguage == "en" {
                                if mostPopularTag?.enName == nil || mostPopularTag?.enName == "" {
                                    popularTagName.text = mostPopularTag?.ruName
                                } else {
                                    popularTagName.text = mostPopularTag?.enName
                                }
                                var address: String? = ""
                                if mostPopularTag?.enAddressName == nil || mostPopularTag?.enAddressName == "" {
                                    address = mostPopularTag?.ruAddressName
                                } else {
                                    address = mostPopularTag?.enAddressName
                                }
                                if address != nil && address != "" {
                                    popularTagAddress?.text = address
                                } else {
                                    popularTagAddress?.removeFromSuperview()
                                    popularTagName?.removeFromSuperview()
                                    popularTagHighlightView?.addSubview(popularTagName)
                                    popularTagName?.leadingAnchor.constraint(equalTo: popularTagHighlightView.leadingAnchor, constant: 20).isActive = true
                                    popularTagName?.centerYAnchor.constraint(equalTo: popularTagViews.centerYAnchor).isActive = true
                                }
                                popularTagViews?.text = String(describing: mostPopularTag!.views) + " views"
                                
                            } else {
                                if mostPopularTag?.ruName == nil || mostPopularTag?.ruName == "" {
                                    popularTagName?.text = mostPopularTag?.enName
                                } else {
                                    popularTagName?.text = mostPopularTag?.ruName
                                }
                                var address: String? = ""
                                if mostPopularTag?.ruAddressName == nil || mostPopularTag?.ruAddressName == "" {
                                    address = mostPopularTag?.enAddressName
                                } else {
                                    address = mostPopularTag?.ruAddressName
                                }
                                if address != nil && address != "" {
                                    popularTagAddress?.text = address
                                } else {
                                    popularTagAddress?.removeFromSuperview()
                                    popularTagName?.removeFromSuperview()
                                    popularTagHighlightView?.addSubview(popularTagName)
                                    popularTagName?.leadingAnchor.constraint(equalTo: popularTagHighlightView.leadingAnchor, constant: 20).isActive = true
                                    popularTagName?.centerYAnchor.constraint(equalTo: popularTagViews.centerYAnchor).isActive = true
                                }
                                popularTagViews?.text = String(describing: mostPopularTag!.views) + " просмотров"
                            }
                        }
                    }
                } else {
                    if answer is ServerAnswer {
                        if (answer as! ServerAnswer).status == 433 {
                            placeNotificationsView(event: .serverOff)
                        } else {
                            placeNotificationsView(event: .error)
                        }
                    }
                }
            }
        }

        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.scrollViewTop.constant = 16
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.view.layoutSubviews()
            self.scrollView.layoutSubviews()
            self.viewDidLayoutSubviews()
        }
        
    }
    
}
