//
//  InfoViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 21.05.2021.
//

import UIKit
import CoreLocation

class InfoViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var photosScrollView: UIScrollView!
    @IBOutlet weak var photoScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryTextLabel: UILabel!
    @IBOutlet weak var firstViewNoToUse: NSLayoutConstraint!
    
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var workingHoursLabel: UILabel!
    @IBOutlet weak var weekdaysLabel: UILabel!
    @IBOutlet weak var weekdaysTime: UILabel!
    @IBOutlet weak var weekendsLabel: UILabel!
    @IBOutlet weak var weekendsTime: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var contactNumberTextView: UITextView!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var websiteTextView: UITextView!
    
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var authorView: UIView!
    @IBOutlet weak var authorHighlightedView: HighlightView!
    @IBOutlet weak var authorAvatar: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var authorNameCenterY: NSLayoutConstraint!
    @IBOutlet weak var authorNickname: UILabel!
    
    @IBOutlet weak var reviewsView: UIView!
    @IBOutlet weak var reviewsScrollView: UIScrollView!
    @IBOutlet var addFirstReviewButton: UIButton!
    @IBOutlet weak var addReviewButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    private let selectedGenerangetor = UISelectionFeedbackGenerator()
    
    var starStackView: UIStackView?
    var marksLabel: UILabel?
    var ratingLabel: UILabel?
    
    public var tag: Tag!
    
    var showPhotos: Bool = false
    var showAddress: Bool = false
    var showCategory: Bool = false
    var showWorkingHours: Bool = false
    var showConstactNumber: Bool = false
    var showWebsite: Bool = false
    var showDescription: Bool = false
    var showAuthor: Bool = false
    var showAddReviewButton: Bool = false
    var isMyTag: Bool = false
    
    var photos: Array<UIImage> = []
    var reviews: Array<Review>!
    
    private var marksSumm: Int = 0
    private var middleMark: Double = 0.0
    
    private var notificationView: UIView?
    
    private var willBeDeinited: Bool = true
    
    private let routerButton: UIButton = {
        let button = UIButton()

        button.translatesAutoresizingMaskIntoConstraints = false
        if globalVariables.currentLanguage == "en" {
            button.setTitle("Build a route", for: .normal)
        } else {
            button.setTitle("Построить маршрут", for: .normal)
        }
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 12
        
        return button
    }()

    // MARK: - View Controller's Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in tag.photos {
            if i != "" {
                photos.append(Helpers().imageFromString(string: i)!)
        }}
        reviews = tag.reviews ?? []
        isMyTag = (tag.authorId == personalInfo.userAccount?.userId)

        if !isMyTag {
            Server.shared.tagWasDisplayed(tagsId: tag.tagsId)
        }
        
        setupScene()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedGenerangetor.prepare()
        
        reviews = tag.reviews

        if tag.reviews?.count != 0 {
            marksSumm = 0
            for i in tag.reviews! {
                marksSumm += i.mark
            }
            middleMark = Double(marksSumm) / Double(tag.reviews!.count)
            middleMark = round(middleMark * 10) / 10.0
        } else {
            middleMark = 0.0
        }
        
        for i in starStackView!.subviews {
           
            if i is UIImageView {
                let t = i as! UIImageView
                let whole = Int(middleMark)
                let decimal = middleMark.truncatingRemainder(dividingBy: 1)
                if t.tag <= whole - 1 {
                    t.image = UIImage(systemName: "star.fill")!
                } else if decimal >= 0.49 && i.tag == whole {
                    t.image = UIImage(systemName: "star.leadinghalf.fill")!
                } else {
                    t.image = UIImage(systemName: "star")!
                }
                t.tintColor = .systemYellow
            }
        }
        
        ratingLabel!.text = "\(middleMark)"
        
        if globalVariables.currentLanguage == "en" {
            marksLabel!.text = "\(tag.reviews?.count ?? 0) marks"
        } else {
            marksLabel!.text = "\(tag.reviews?.count ?? 0) оценок"
        }
        
        if reviews.count == 0 {
            showAddReviewButton = false
            addReviewButton.isHidden = true
            for i in reviewsScrollView.subviews {
                i.removeFromSuperview()
            }
            reviewsScrollView.addSubview(addFirstReviewButton)
            
            addFirstReviewButton.centerYAnchor.constraint(equalTo: reviewsScrollView.centerYAnchor).isActive = true
            addFirstReviewButton.centerXAnchor.constraint(equalTo: reviewsScrollView.centerXAnchor).isActive = true
            addFirstReviewButton.leadingAnchor.constraint(equalTo: reviewsScrollView.leadingAnchor, constant: 65).isActive = true
            addFirstReviewButton.trailingAnchor.constraint(equalTo: reviewsScrollView.trailingAnchor, constant: -65).isActive = true
            addFirstReviewButton.topAnchor.constraint(equalTo: reviewsScrollView.topAnchor, constant: 63).isActive = true
            addFirstReviewButton.bottomAnchor.constraint(equalTo: reviewsScrollView.bottomAnchor, constant: -63).isActive = true
            
            if isMyTag || !personalInfo.isAuthorised {
                addFirstReviewButton.backgroundColor = .systemGray4
                addFirstReviewButton.setTitleColor(.label, for: .normal)
                if globalVariables.currentLanguage == "en" {
                    addFirstReviewButton.setTitle("No reviews yet", for: .normal)
                } else {
                    addFirstReviewButton.setTitle("Пока что нет отзывов", for: .normal)
                }
                addFirstReviewButton.isEnabled = false
            }

        } else {
            setupReviewsScrollView()
            if !isMyTag && personalInfo.isAuthorised {
                showAddReviewButton = true
                viewDidLayoutSubviews()
            } else {
                showAddReviewButton = false
                addReviewButton.isHidden = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        willBeDeinited = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.layoutSubviews()
        self.scrollView.layoutSubviews()
        
        if showAddReviewButton {
            
            if scrollView.frame.size.height - globalVariables.bottomScreenLength > addReviewButton.frame.maxY + 12 {
                scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height - globalVariables.bottomScreenLength + 0.5)
            } else {
                scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: addReviewButton.frame.maxY + 24)
            }
        } else {
            if scrollView.frame.size.height - globalVariables.bottomScreenLength > reviewsView.frame.maxY + 12 {
                scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height - globalVariables.bottomScreenLength + 0.5)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if willBeDeinited { 
            notificationView?.removeFromSuperview()
            notificationView = nil
            photosScrollView?.delegate = nil
            tag = nil
            photos = []
            reviews = nil
            starStackView?.removeFromSuperview()
            starStackView = nil
            marksLabel?.removeFromSuperview()
            marksLabel = nil
            ratingLabel?.removeFromSuperview()
            ratingLabel = nil
            addFirstReviewButton?.removeFromSuperview()
            addFirstReviewButton = nil
        }
    }
    
    // MARK: - Setup functions
    
    func setupScene() {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if isMyTag {
            let barButtom = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(editThisTag))
            self.navigationItem.rightBarButtonItems = [barButtom]
        }
        
        scrollViewBottom.constant = -globalVariables.bottomScreenLength
        firstViewNoToUse.isActive = false
        
        self.view.layoutSubviews()
        self.scrollView.layoutSubviews()
        self.firstView.layoutSubviews()
        
        photoScrollViewHeight.constant = photosScrollView.frame.width * 9 / 16
        
        firstView.layer.cornerRadius = 16
        Helpers().addShadow(view: firstView)
        secondView.layer.cornerRadius = 16
        Helpers().addShadow(view: secondView)
        thirdView.layer.cornerRadius = 16
        Helpers().addShadow(view: thirdView)
        photosScrollView.layer.masksToBounds = true
        photosScrollView.layer.cornerRadius = 16
        authorView.layer.cornerRadius = 16
        Helpers().addShadow(view: authorView)
        authorAvatar.layer.masksToBounds = true
        authorAvatar.layer.cornerRadius = 26
        reviewsView.layer.cornerRadius = 16
        Helpers().addShadow(view: reviewsView)
        addFirstReviewButton.layer.masksToBounds = true
        addFirstReviewButton.layer.cornerRadius = 16
        addReviewButton.layer.cornerRadius = 16
        Helpers().addShadow(view: addReviewButton)
        authorHighlightedView.layer.masksToBounds = true
        authorHighlightedView.layer.cornerRadius = 12
        
        if photos.count == 0 { showPhotos = false }
        else {
            showPhotos = true
            setupPhotosScrollView()
        }
        
        if globalVariables.currentLanguage == "en" {
            if tag.enName != "" && tag.enName != nil {
                self.title = tag.enName
            } else {
                self.title = tag.ruName
            }
            if tag.enAddressName != nil && tag.enAddressName != "" {
                showAddress = true
                addressTextView.text = tag.enAddressName
            } else if tag.ruAddressName != nil && tag.ruAddressName != "" {
                showAddress = true
                addressTextView.text = tag.ruAddressName
            }
            if tag.enWebsite != nil && tag.enWebsite != "" {
                showWebsite = true
                websiteTextView.text = tag.enWebsite
            } else if tag.ruWebsite != nil && tag.ruWebsite != "" && globalVariables.showForeignTags {
                showWebsite = true
                websiteTextView.text = tag.ruWebsite
            }
            if tag.enDescription != nil && tag.enDescription != "" {
                showDescription = true
                descriptionTextView.text = tag.enDescription
            } else if tag.ruDescription != nil && tag.ruDescription != "" && globalVariables.showForeignTags {
                showDescription = true
                descriptionTextView.text = tag.ruDescription
            }
        } else {
            if tag.ruName != "" && tag.ruName != nil {
                self.title = tag.ruName
            } else {
                self.title = tag.enName
            }
            if tag.ruAddressName != nil && tag.ruAddressName != "" {
                showAddress = true
                addressTextView.text = tag.ruAddressName
            } else if tag.enAddressName != nil && tag.enAddressName != "" {
                showAddress = true
                addressTextView.text = tag.enAddressName
            }
            if tag.ruWebsite != nil && tag.ruWebsite != "" {
                showWebsite = true
                websiteTextView.text = tag.ruWebsite
            } else if tag.enWebsite != nil && tag.enWebsite != "" && globalVariables.showForeignTags {
                showWebsite = true
                websiteTextView.text = tag.enWebsite
            }
            if tag.ruDescription != nil && tag.ruDescription != "" {
                showDescription = true
                descriptionTextView.text = tag.ruDescription
            } else if tag.enDescription != nil && tag.enDescription != "" && globalVariables.showForeignTags {
                showDescription = true
                descriptionTextView.text = tag.enDescription
            }
        }
        if tag.category != nil && tag.category != "" && tag.category != "\"\"" && tag.category != "None" {
            showCategory = true
            let category = globalVariables.categoryList.first { category in
                return category.enText == tag.category
            }
            if globalVariables.currentLanguage == "en" {
                categoryTextLabel.text = category?.enText
            } else {
                categoryTextLabel.text = category?.ruText
            }
            categoryImage.image = category?.image
        }
        if (tag.workingHoursWeekdays != nil && tag.workingHoursWeekdays != "") || (tag.workingHoursWeekends != nil && tag.workingHoursWeekends != "") {
            showWorkingHours = true
            weekdaysTime.text = tag.workingHoursWeekdays
            if tag.workingHoursWeekends != "" && tag.workingHoursWeekends != nil {
                weekendsTime.text = tag.workingHoursWeekends
            } else {
                if globalVariables.currentLanguage == "en" {
                    weekendsTime.text = "Doesn't work"
                } else {
                    weekendsTime.text = "Не работает"
                }
            }
        }
        if tag.contactNumber != nil && tag.contactNumber != "" {
            showConstactNumber = true
            contactNumberTextView.text = tag.contactNumber
        }
        
        let currentVC = self.navigationController?.topViewController
        
        guard var viewConstrollers = currentVC?.navigationController?.viewControllers else { return }
        _ = viewConstrollers.popLast()
        if tag.authorId == personalInfo.userAccount?.userId ?? 0 || viewConstrollers.last is TagsListViewController || viewConstrollers.last is AccountInfoViewController || !tag.showAuthor {
            showAuthor = false
        } else {
            showAuthor = true
            authorName.text = tag.authorName
            authorAvatar.image = Helpers().imageFromString(string: tag.authorAvatar)
            if tag.authorNickname != nil && tag.authorNickname != "" {
                authorNickname.text = tag.authorNickname
            } else {
                authorNickname.removeFromSuperview()
                authorNameCenterY.constant = 0
            }
 
        }
        
        setupStartStackVeiw()
        
        if !showPhotos {
            photosScrollView.removeFromSuperview()
            pageControl.removeFromSuperview()
        }
        if !showAddress {
            addressLabel.removeFromSuperview()
            addressTextView.removeFromSuperview()
        }
        if !showCategory {
            categoryLabel.removeFromSuperview()
            categoryImage.removeFromSuperview()
            categoryTextLabel.removeFromSuperview()
        }
        if !showWorkingHours && !showConstactNumber && !showWebsite {
            secondView.removeFromSuperview()
        } else {
            if !showWorkingHours {
                workingHoursLabel.removeFromSuperview()
                weekdaysLabel.removeFromSuperview()
                weekdaysTime.removeFromSuperview()
                weekendsLabel.removeFromSuperview()
                weekendsTime.removeFromSuperview()
            }
            if !showConstactNumber {
                contactNumberLabel.removeFromSuperview()
                contactNumberTextView.removeFromSuperview()
            }
            if !showWebsite {
                websiteLabel.removeFromSuperview()
                websiteTextView.removeFromSuperview()
            }
        }
        if !showDescription {
            thirdView.removeFromSuperview()
        }
        if !showAuthor {
            authorView.removeFromSuperview()
        }
        
        if reviews.count == 0 {
            showAddReviewButton = false
        } else {
            if !isMyTag && personalInfo.isAuthorised {
                showAddReviewButton = true
                viewDidLayoutSubviews()
            } else {
                showAddReviewButton = false
                addReviewButton.isHidden = true
            }
        }
    }
    
    // MARK: - Setup Stars Stack View
    
    func setupStartStackVeiw() {
        
        firstView.addSubview(routerButton)
        routerButton.addTarget(self, action: #selector(routerToTag(_:)), for: .touchUpInside)
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(routeToTagWithChoice(_:)))
        gesture.isEnabled = true
        routerButton.addGestureRecognizer(gesture)
        let gesture1 = UITapGestureRecognizer(target: self, action: #selector(routerToTag(_:)))
        gesture1.isEnabled = true
        routerButton.addGestureRecognizer(gesture1)
        routerButton.leadingAnchor.constraint(equalTo: firstView.leadingAnchor, constant: 16).isActive = true
        routerButton.trailingAnchor.constraint(equalTo: firstView.trailingAnchor, constant: -16).isActive = true
        routerButton.bottomAnchor.constraint(equalTo: firstView.bottomAnchor, constant: -12).isActive = true
        routerButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        if tag.reviews?.count != 0 {
            for i in tag.reviews! {
                marksSumm += i.mark
            }
            middleMark = Double(marksSumm) / Double(tag.reviews!.count)
            middleMark = round(middleMark * 10) / 10.0
        }
        
        starStackView = UIStackView()
        starStackView!.translatesAutoresizingMaskIntoConstraints = false
        starStackView!.axis = .horizontal
        starStackView!.distribution = .fillEqually
        starStackView!.spacing = 4
        
        let whole = Int(middleMark)
        let decimal = middleMark.truncatingRemainder(dividingBy: 1)
        
        for i in 0...4 {
            let starImageView = UIImageView()
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            
            if i <= whole - 1 {
                starImageView.image = UIImage(systemName: "star.fill")
            } else if decimal >= 0.49 && i == whole {
                starImageView.image = UIImage(systemName: "star.leadinghalf.fill")
            } else {
                starImageView.image = UIImage(systemName: "star")
            }
            starImageView.tintColor = .systemYellow
            
            starImageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
            starImageView.tag = i
            
            starStackView!.addArrangedSubview(starImageView)
        }
        
        firstView.addSubview(starStackView!)
        
        starStackView!.leadingAnchor.constraint(equalTo: firstView.leadingAnchor, constant: 20).isActive = true
        if categoryImage != nil {
            starStackView!.topAnchor.constraint(equalTo: categoryImage.bottomAnchor, constant: 12).isActive = true
        }
        starStackView!.bottomAnchor.constraint(equalTo: routerButton.topAnchor, constant: -16).isActive = true
        
        if addressTextView != nil {
            let stackViewTopAddress = starStackView!.topAnchor.constraint(equalTo: addressTextView.bottomAnchor, constant: 12)
            stackViewTopAddress.priority = UILayoutPriority(500)
            stackViewTopAddress.isActive = true
        }
        
        if pageControl != nil {
            let stackViewTopPhotos = starStackView!.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 12)
            stackViewTopPhotos.priority = UILayoutPriority(250)
            stackViewTopPhotos.isActive = true
        }
        
        let stackViewTop = starStackView!.topAnchor.constraint(equalTo: firstView.topAnchor, constant: 16)
        stackViewTop.priority = UILayoutPriority(100)
        stackViewTop.isActive = true
        
        ratingLabel = UILabel()
        ratingLabel!.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel!.textColor = .label
        ratingLabel!.text = "\(middleMark)"
        ratingLabel!.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        
        firstView.addSubview(ratingLabel!)
        
        ratingLabel!.centerYAnchor.constraint(equalTo: starStackView!.centerYAnchor, constant: 1).isActive = true
        ratingLabel!.leadingAnchor.constraint(equalTo: starStackView!.trailingAnchor, constant: 8).isActive = true
        
        marksLabel = UILabel()
        marksLabel!.translatesAutoresizingMaskIntoConstraints = false
        marksLabel!.textColor = UIColor(named: "textGrey")
        if globalVariables.currentLanguage == "en" {
            marksLabel!.text = "\(tag.reviews?.count ?? 0) marks"
        } else {
            marksLabel!.text = "\(tag.reviews?.count ?? 0) оценок"
        }
        
        marksLabel!.font = UIFont.systemFont(ofSize: 17)
        
        firstView.addSubview(marksLabel!)
        
        marksLabel!.centerYAnchor.constraint(equalTo: starStackView!.centerYAnchor, constant: 1).isActive = true
        marksLabel!.leadingAnchor.constraint(equalTo: ratingLabel!.trailingAnchor, constant: 10).isActive = true
    }
    
    // MARK: - Setup Photos ScrollView
    
    func setupPhotosScrollView() {
        self.view.layoutSubviews()
        self.scrollView.layoutSubviews()
        self.firstView.layoutSubviews()
        photoImageView.removeFromSuperview()
        
        pageControl.numberOfPages = photos.count
        photosScrollView.delegate = self
        pageControl.addTarget(self, action: #selector(pageControlDidChange), for: .valueChanged) 
        
        for i in 0...photos.count - 1 {
            
            let imageView = UIImageView(image: photos[i])
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 16
            
            photosScrollView.addSubview(imageView)
            
            let xCoordinate = photosScrollView.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xCoordinate, y: 0, width: photosScrollView.frame.width, height: photosScrollView.frame.height)
        }
        
        photosScrollView.contentSize = CGSize(width: photosScrollView.frame.width * CGFloat(photos.count), height: photosScrollView.frame.height)
    }
    
    // MARK: - Setup Reviews ScrollView
    
    func setupReviewsScrollView() {
        
        self.view.layoutSubviews()
        self.scrollView.layoutSubviews()
        self.reviewsView.layoutSubviews()
        
        for i in reviewsScrollView.subviews {
            i.removeFromSuperview()
        }
        
        if reviews.count == 0 {
            addReviewButton.isHidden = true
        } else {
            if !isMyTag {
                addReviewButton.isHidden = false
            }
            for i in 0...reviews.count - 1 {
                let reviewView = UIView()
                reviewView.backgroundColor = UIColor(named: "background")
                reviewView.layer.masksToBounds = true
                reviewView.layer.cornerRadius = 16
                
                reviewsScrollView.addSubview(reviewView)
                
                reviewView.frame = CGRect(x: reviewsScrollView.frame.width * CGFloat(i) + 16, y: 0, width: reviewsScrollView.frame.width - 36, height: reviewsScrollView.frame.height - 16)
                
                self.reviewsScrollView.layoutSubviews()
                
                let reviewAuthorView = HighlightView()
                reviewAuthorView.backgroundColor = UIColor(named: "infoColor")
                reviewAuthorView.layer.masksToBounds = true
                reviewAuthorView.layer.cornerRadius = 16
                reviewAuthorView.tag = i
                
                reviewView.addSubview(reviewAuthorView)
                
                reviewAuthorView.frame = CGRect(x: 8, y: 8, width: reviewView.frame.width - 16, height: 64)
                
                let openReviewAuthor = UITapGestureRecognizer(target: self, action: #selector(openReviewAutor))
                reviewAuthorView.addGestureRecognizer(openReviewAuthor)
                openReviewAuthor.view?.tag = i
                
                let reviewAuthorAvatar = UIImageView()
                reviewAuthorAvatar.contentMode = .scaleAspectFit
                reviewAuthorAvatar.backgroundColor = .systemGray3
                reviewAuthorAvatar.tintColor = UIColor(named: "textGrey")
                if reviews[i].authorAvatar != nil {
                    reviewAuthorAvatar.image = Helpers().imageFromString(string: reviews[i].authorAvatar)
                } else {
                    reviewAuthorAvatar.image = UIImage(systemName: "person.circle.fill")
                }
                
                reviewAuthorView.addSubview(reviewAuthorAvatar)
                
                let avatarWidth: CGFloat = 46
                reviewAuthorAvatar.frame = CGRect(x: 8, y: reviewAuthorView.frame.height / 2 - avatarWidth / 2, width: avatarWidth, height: avatarWidth)
                reviewAuthorAvatar.layer.masksToBounds = true
                reviewAuthorAvatar.layer.cornerRadius = avatarWidth / 2
                
                let reviewAuthorName = UILabel()
                reviewAuthorName.textAlignment = .left
                reviewAuthorName.text = reviews[i].authorName
                
                reviewAuthorView.addSubview(reviewAuthorName)
                
                reviewAuthorName.frame = CGRect(x: reviewAuthorAvatar.frame.maxX + 8, y: 0, width: reviewAuthorView.frame.width - reviewAuthorAvatar.frame.maxX - 8, height: reviewAuthorView.frame.height - 16)
                
                if reviews[i].authorNickname == nil || reviews[i].authorNickname == "" {
                    reviewAuthorName.frame = CGRect(x: reviewAuthorAvatar.frame.maxX + 8, y: 0, width: reviewAuthorView.frame.width - reviewAuthorAvatar.frame.maxX - 8, height: reviewAuthorView.frame.height)
                } else {
                    let reviewAuthorNickname = UILabel()
                    
                    reviewAuthorNickname.textAlignment = .left
                    reviewAuthorNickname.font = UIFont.systemFont(ofSize: 15)
                    reviewAuthorNickname.textColor = UIColor(named: "textGrey")
                    reviewAuthorNickname.text = reviews[i].authorNickname
                    
                    reviewAuthorView.addSubview(reviewAuthorNickname)
                    
                    reviewAuthorNickname.frame = CGRect(x: reviewAuthorAvatar.frame.maxX + 8, y: 28, width: reviewAuthorView.frame.width - reviewAuthorAvatar.frame.maxX - 8, height: 24)
                }
                
                if reviews[i].authorId == personalInfo.userAccount?.userId {
                    let editImageView = UIImageView()
                    editImageView.translatesAutoresizingMaskIntoConstraints = false
                    editImageView.isUserInteractionEnabled = true
                    
                    editImageView.backgroundColor = .clear
                    editImageView.image = UIImage(systemName: "square.and.pencil")
                    editImageView.tintColor = .systemBlue
                    
                    reviewAuthorView.addSubview(editImageView)
                    
                    editImageView.heightAnchor.constraint(equalToConstant: 26).isActive = true
                    editImageView.widthAnchor.constraint(equalToConstant: 26).isActive = true
                    editImageView.centerYAnchor.constraint(equalTo: reviewAuthorView.centerYAnchor).isActive = true
                    editImageView.trailingAnchor.constraint(equalTo: reviewAuthorView.trailingAnchor, constant: -16).isActive = true
                    
                    
                    let tapGesture = UITapGestureRecognizer()
                    tapGesture.addTarget(self, action: #selector(rewriteReview))
                    editImageView.addGestureRecognizer(tapGesture)
                    tapGesture.view?.tag = i
                }

                let starStackView = UIStackView()
                starStackView.axis = .horizontal
                starStackView.distribution = .fillEqually
                starStackView.spacing = 4
                
                for j in 0...4 {
                    let starImageView = UIImageView()
                    starImageView.translatesAutoresizingMaskIntoConstraints = false
                    if reviews[i].mark > j {
                        starImageView.image = UIImage(systemName: "star.fill")
                        starImageView.tintColor = .systemYellow
                    } else {
                        starImageView.image = UIImage(systemName: "star")
                        starImageView.tintColor = UIColor(named: "textGrey")
                    }
                    
                    starImageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
                    starImageView.heightAnchor.constraint(equalToConstant: 18).isActive = true
                    
                    starStackView.addArrangedSubview(starImageView)
                }
                
                reviewView.addSubview(starStackView)
                
                starStackView.frame = CGRect(x: 16, y: reviewAuthorView.frame.maxY + 6, width: 106, height: 18)
                
                let dateLabel = UILabel()
                dateLabel.text = reviews[i].date
                dateLabel.textColor = UIColor(named: "textGrey")
                dateLabel.textAlignment = .left
                dateLabel.font = UIFont.systemFont(ofSize: 15)
                
                reviewView.addSubview(dateLabel)
                
                dateLabel.frame = CGRect(x: starStackView.frame.maxX + 10, y: reviewAuthorView.frame.maxY, width: reviewView.frame.width - starStackView.frame.maxX - 10, height: 30)
                
                let textView = UITextView()
                textView.isEditable = false
                textView.isScrollEnabled = true
                textView.font = UIFont.systemFont(ofSize: 17)
                textView.spellCheckingType = .no
                textView.backgroundColor = .clear
                textView.text = reviews[i].text
                
                reviewView.addSubview(textView)
                
                textView.frame = CGRect(x: 8, y: starStackView.frame.maxY + 4, width: reviewView.frame.width - 24, height: reviewView.frame.height - starStackView.frame.maxY - 7)
                
                textView.contentInset = UIEdgeInsets(top: -6, left: 5, bottom: 6, right: 5)
                textView.showsVerticalScrollIndicator = false
                
            }

            reviewsView.layoutSubviews()
            
            reviewsScrollView.contentSize = CGSize(width: reviewsScrollView.frame.width * CGFloat(reviews.count), height: reviewsScrollView.frame.height)
        }
    }
    
    // MARK: - Other functionality
    
    @IBAction func openAuthorAccount(_ sender: Any) {
        if tag.authorId == 0 { return }
        
        authorHighlightedView.isUserInteractionEnabled = false
        placeNotificationsView(event: .loading)
        Server.shared.getUser(userId: tag.authorId) { [self] user in
            authorHighlightedView.isUserInteractionEnabled = true
            removeNotificationView { [self] _ in
                
                guard let author = user else {
                
                    placeNotificationsView(event: .error)
                    return
                }
                
                if author is User {
                    let storyboard = UIStoryboard(name: "Accounts", bundle: nil)
                
                    let VC = storyboard.instantiateViewController(identifier: "AccountIfoViewController") as! AccountInfoViewController
                    if tag.authorId != personalInfo.userAccount?.userId ?? 0 {
                        VC.isAnotherUserAccount = true
                        VC.anotherUserAccount = author as? User
                    }
                    VC.modalPresentationStyle = .fullScreen
                    VC.modalTransitionStyle = .crossDissolve
                    
                    willBeDeinited = false
                    
                    self.navigationController?.pushViewController(VC, animated: true)
                } else {
                    if (author as! ServerAnswer).status == 433 {
                        placeNotificationsView(event: .serverOff)
                    } else {
                        placeNotificationsView(event: .error)
                    }
                }
            }
        }
    }
    
    @objc func openReviewAutor(_ sender: UITapGestureRecognizer) {
    
        if reviews[sender.view!.tag].authorId == personalInfo.userAccount?.userId || reviews[sender.view!.tag].authorId == 0 { return }
        
        sender.view?.isUserInteractionEnabled = false
        
        placeNotificationsView(event: .loading)
        Server.shared.getUser(userId: reviews[sender.view!.tag].authorId) { [self] user in
            sender.view?.isUserInteractionEnabled = true
            removeNotificationView { [self] _ in
                guard let author = user else {
                    placeNotificationsView(event: .error)
                    return
                }
                if author is User {
                    let storyboard = UIStoryboard(name: "Accounts", bundle: nil)
                
                    let VC = storyboard.instantiateViewController(identifier: "AccountIfoViewController") as! AccountInfoViewController
                    if (author as! User).userId == personalInfo.userAccount?.userId {
                        VC.isAnotherUserAccount = false
                    } else {
                        VC.isAnotherUserAccount = true
                    }
                        
                    willBeDeinited = false
                        
                    VC.anotherUserAccount = author as? User
                    VC.modalPresentationStyle = .fullScreen
                    VC.modalTransitionStyle = .crossDissolve
                    
                    self.navigationController?.pushViewController(VC, animated: true)
                    
                } else {
                    if (author as! ServerAnswer).status == 433 {
                        placeNotificationsView(event: .serverOff)
                    } else {
                        placeNotificationsView(event: .error)
                    }
                }
            }
        }
    }
    
    @objc func routerToTag(_ sender: UITapGestureRecognizer? = nil) {
        var name: String!
        if globalVariables.currentLanguage == "ru" {
            if tag.ruName != nil && tag.ruName != "" {
                name = tag.ruName
            } else {
                name = tag.enName
            }
        } else if globalVariables.currentLanguage == "en" {
            if tag.enName != nil && tag.enName != "" {
                name = tag.enName
            } else {
                name = tag.ruName
            }
        }
        var coordinates = CLLocationCoordinate2D()
        coordinates.latitude = tag.latitude
        coordinates.longitude = tag.longitude
        OpenMapDirections.analize(in: self, sourceView: routerButton, name: name, coordinates: coordinates)
    }
    
    @objc func routeToTagWithChoice(_ sender: UITapGestureRecognizer? = nil) {
        var name: String!
        if globalVariables.currentLanguage == "ru" {
            if tag.ruName != nil && tag.ruName != "" {
                name = tag.ruName
            } else {
                name = tag.enName
            }
        } else if globalVariables.currentLanguage == "en" {
            if tag.enName != nil && tag.enName != "" {
                name = tag.enName
            } else {
                name = tag.ruName
            }
        }
        var coordinates = CLLocationCoordinate2D()
        coordinates.latitude = tag.latitude
        coordinates.longitude = tag.longitude
        if sender?.state == .began {
            selectedGenerangetor.selectionChanged()
            OpenMapDirections.present(in: self, sourceView: routerButton, name: name, coordinates: coordinates)
        }
    }
    
    func pushViewController(storyboard: UIStoryboard, identifier: String) {
        
        willBeDeinited = false
        
        let VC = storyboard.instantiateViewController(identifier: identifier)
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @objc func editThisTag() {
        
        let currentVC = self.navigationController?.topViewController
        
        guard var viewConstrollers = currentVC?.navigationController?.viewControllers else {
            return
        }
        
        willBeDeinited = false
        
        _ = viewConstrollers.popLast()
        
        let infoViewController = UIStoryboard(name: "Tags", bundle: nil).instantiateViewController(identifier: "InfoViewController") as! InfoViewController
        infoViewController.tag = tag
        infoViewController.willBeDeinited = false
        let addingAndEditingViewConstroller = UIStoryboard(name: "Tags", bundle: nil).instantiateViewController(identifier: "AddingAndEditingViewController") as! AddingAndEditingViewController
        addingAndEditingViewConstroller.editingTag = tag
        
        viewConstrollers.append(infoViewController)
        viewConstrollers.append(addingAndEditingViewConstroller)
        
        currentVC?.navigationController?.setViewControllers(viewConstrollers, animated: true)
        
    }
    
    @IBAction func addReview(_ sender: Any) {
        if personalInfo.userAccount?.isBanned ?? true {
            placeNotificationsView(event: .banned)
            return
        }
        willBeDeinited = false
        
        let storyboard = UIStoryboard(name: "Tags", bundle: nil)
        
        let VC = storyboard.instantiateViewController(identifier: "writeReviewViewController") as! WriteReviewViewController
        VC.tagsId = tag.tagsId
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        pageControl.currentPage = Int(photosScrollView.contentOffset.x / photosScrollView.frame.width)
    }
    
    @objc func pageControlDidChange(_ sender: UIPageControl) {
        let current = sender.currentPage
        photosScrollView.setContentOffset(CGPoint(x: CGFloat(current) * photosScrollView.frame.size.width, y: 0), animated: true)
    }
    
    @objc func rewriteReview(_ sender: UITapGestureRecognizer) {
        
        willBeDeinited = false
        
        let i = sender.view?.tag
        
        let storyboard = UIStoryboard(name: "Tags", bundle: nil)
        
        let VC = storyboard.instantiateViewController(identifier: "writeReviewViewController") as! WriteReviewViewController
        VC.tagsId = tag.tagsId
        VC.currentMark = reviews[i!].mark
        VC.pastText = reviews[i!].text
        VC.reviewId = reviews[i!].reviewId
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: true)
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
