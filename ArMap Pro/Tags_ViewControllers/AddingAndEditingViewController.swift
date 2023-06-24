//
//  Adding and Editing View Controller.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 21.05.2021.
//

import UIKit
import MapKit
import AVFoundation

class AddingAndEditingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var tagNameView: UIView!
    @IBOutlet weak var tagNameField: UITextField!
    
    @IBOutlet weak var coordinatesView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var addressNameView: UIView!
    @IBOutlet weak var addressNameField: UITextField!
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryShowView: HighlightView!
    
    @IBOutlet weak var photosView: UIView!
    @IBOutlet weak var photosScrollView: UIScrollView!
    @IBOutlet weak var photosScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var photosPageControll: UIPageControl!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    @IBOutlet weak var workingHoursView: UIView!
    @IBOutlet weak var workingHoursViewHeight: NSLayoutConstraint!
    @IBOutlet weak var workingHoursLabel: UILabel!
    
    @IBOutlet weak var contactNumberView: UIView!
    @IBOutlet weak var contactNumberField: UITextField!
    
    @IBOutlet weak var websiteView: UIView!
    @IBOutlet weak var websiteField: UITextField!
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionFakeField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var localizationView: UIView!
    @IBOutlet weak var localizationSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var publicAccessView: UIView!
    @IBOutlet weak var publicAccessLabel: UILabel!
    @IBOutlet weak var publicAccessSwitch: UISwitch!
    
    @IBOutlet weak var showAsAuthorView: UIView!
    @IBOutlet weak var showAsAuthorSwitch: UISwitch!
    
    @IBOutlet weak var addTagButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var effectView: UIVisualEffectView!
    
    @IBOutlet weak var nameNotice: UILabel!
    @IBOutlet weak var nameConstraint: NSLayoutConstraint!
    
    public var editingTag: Tag?
    var isEditingTag: Bool = false
    
    var tagPhotos: [UIImage] = []
    var contentWidth: CGFloat = 0.0
    var addPhotoButtonWidth: CGFloat?
    var addPhotoButtonHeight: CGFloat?
    var weekdaysTimeArray: [String]?
    var weekendsTimeArray: [String]?
    
    var weekdaysSinceTime: UIDatePicker?
    var weekdaysUntilTime: UIDatePicker?
    var weekendsSinceTime: UIDatePicker?
    var weekendsUntilTime: UIDatePicker?
    var showTimeSwitch: UISwitch?
    
    var keyboardHeigth: CGFloat = 0.0
    
    var locationManager: CLLocationManager?
    var previousLocation: CLLocation?
    
    lazy var categoryChooseView = UIView()
    var categoryScrollWidth: CGFloat = 0.0
    
    let selectFeedback = UISelectionFeedbackGenerator()
    
    var placingCoordinates: CLLocationCoordinate2D?
    
    var pickerController: UIImagePickerController?
    
    var enName: String?
    var ruName: String?
    
    var enAddressName: String?
    var ruAddressName: String?
    
    var enWebsite: String?
    var ruWebsite: String?
    
    var enDescription: String?
    var ruDescription: String?
    
    var notificationView: UIView?
    
    private var willBeDeinited: Bool = true
    
    // MARK: - View Controller's Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if editingTag != nil {
            isEditingTag = true
            for i in editingTag!.photos {
                tagPhotos.append(Helpers().imageFromString(string: i)!)
            }
            buildPhotosScrollView()
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        setupScene()
        locationManager = CLLocationManager()
        setupLocationsServices()
        selectFeedback.prepare()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if globalVariables.shouldSaveTagInAddingViewController {
            if personalInfo.isAuthorised {
                addOrSave((Any).self)
            }
            globalVariables.shouldSaveTagInAddingViewController = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        willBeDeinited = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
     
        photosScrollViewHeight.constant = photosScrollView.frame.width * (9 / 16)
        addPhotoButtonWidth = addPhotoButton.frame.width
        addPhotoButtonHeight = addPhotoButton.frame.height
        
        mapViewHeight.constant = mapView.frame.size.width * 0.525
        
        categoryScrollWidth = self.view.frame.size.width - 80
        
        if categoryChooseView.backgroundColor != UIColor(named: "infoColor") {
            setupCategoryView()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if willBeDeinited {
            notificationView?.removeFromSuperview()
            notificationView = nil
            pickerController?.delegate = nil
            pickerController = nil
            photosScrollView.delegate = nil
            tagNameField.delegate = nil
            addressNameField.delegate = nil
            contactNumberField.delegate = nil
            websiteField.delegate = nil
            descriptionTextView.delegate = nil
            locationManager?.delegate = nil
            locationManager = nil
            mapView.delegate = nil
            mapView.removeFromSuperview()
            mapView = nil
        }
    }
    
    // MARK: - Setup functions
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectange = keyboardFrame.cgRectValue
            keyboardHeigth = max(keyboardHeigth, keyboardRectange.height)
        }
    }
    
    func setupScene() {
        
        scrollViewBottom.isActive = false
        scrollViewBottom = scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: globalVariables.bottomScreenLength)
        scrollViewBottom.isActive = true
        
        photosScrollView.delegate = self
        photosPageControll.addTarget(self, action: #selector(pageControlDidChange), for: .valueChanged)
        
        
        effectView.removeConstraints(effectView.constraints)
        effectView.removeFromSuperview()
        self.view.addSubview(effectView)
        effectView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        effectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        effectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        effectView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: globalVariables.bottomScreenLength).isActive = true
        effectView.isHidden = true
        
        var makePhotoTitle: String!
        var choosePhotoTitle: String!
        
        if globalVariables.currentLanguage == "en" {
            makePhotoTitle = "Make photo"
            choosePhotoTitle = "Choose photo"
        } else {
            makePhotoTitle = "Сделать фото"
            choosePhotoTitle = "Выбрать фото"
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
        addPhotoButton.showsMenuAsPrimaryAction = true
        addPhotoButton.menu = UIMenu(title: "", children: [makePhoto, choosePhoto])
        
        tagNameView.layer.cornerRadius = 16
        Helpers().addShadow(view: tagNameView)
        tagNameField.layer.masksToBounds = true
        tagNameField.layer.cornerRadius = 12
        coordinatesView.layer.cornerRadius = 16
        Helpers().addShadow(view: coordinatesView)
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 16
        mapView.delegate = self
        addressNameView.layer.cornerRadius = 16
        Helpers().addShadow(view: addressNameView)
        addressNameField.layer.masksToBounds = true
        addressNameField.layer.cornerRadius = 12
        categoryView.layer.cornerRadius = 16
        Helpers().addShadow(view: categoryView)
        photosView.layer.cornerRadius = 16
        Helpers().addShadow(view: photosView)
        photosScrollView.layer.masksToBounds = true
        photosScrollView.layer.cornerRadius = 16
        addPhotoButton.layer.masksToBounds = true
        addPhotoButton.layer.cornerRadius = 16
        workingHoursView.layer.cornerRadius = 16
        Helpers().addShadow(view: workingHoursView)
        contactNumberView.layer.cornerRadius = 16
        Helpers().addShadow(view: contactNumberView)
        contactNumberField.layer.masksToBounds = true
        contactNumberField.layer.cornerRadius = 12
        websiteView.layer.cornerRadius = 16
        Helpers().addShadow(view: websiteView)
        websiteField.layer.masksToBounds = true
        websiteField.layer.cornerRadius = 12
        descriptionView.layer.cornerRadius = 16
        Helpers().addShadow(view: descriptionView)
        descriptionTextView.layer.masksToBounds = true
        descriptionTextView.layer.cornerRadius = 12
        descriptionFakeField.layer.masksToBounds = true
        descriptionFakeField.layer.cornerRadius = 12
        localizationView.layer.cornerRadius = 16
        Helpers().addShadow(view: localizationView)
        publicAccessView.layer.cornerRadius = 16
        Helpers().addShadow(view: publicAccessView)
        addTagButton.layer.cornerRadius = 16
        Helpers().addShadow(view: addTagButton)
        categoryShowView.layer.masksToBounds = true
        categoryShowView.layer.cornerRadius = 12
        showAsAuthorView.layer.cornerRadius = 16
        Helpers().addShadow(view: showAsAuthorView)
        
        
        tagNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        tagNameField.leftViewMode = .always
        tagNameField.delegate = self
        
        addressNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        addressNameField.leftViewMode = .always
        addressNameField.delegate = self

        contactNumberField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        contactNumberField.leftViewMode = .always
        contactNumberField.delegate = self
        
        websiteField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        websiteField.leftViewMode = .always
        websiteField.delegate = self
        
        descriptionFakeField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        descriptionFakeField.leftViewMode = .always
        
        descriptionTextView.textContainer.lineFragmentPadding = 10
        descriptionTextView.delegate = self

        switch globalVariables.currentLanguage {
        case "ru":
            localizationSegmentedControl.selectedSegmentIndex = 0
        case "en":
            localizationSegmentedControl.selectedSegmentIndex = 1
        default:
            localizationSegmentedControl.selectedSegmentIndex = 1
        }
        
        mapTypeSegmentedControl.addTarget(self, action: #selector(segmentSelectedMap), for: .valueChanged)
        localizationSegmentedControl.addTarget(self, action: #selector(segmentSelectedLocalization), for: .valueChanged)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        
        if isEditingTag {
            let barButtom = UIBarButtonItem(image: UIImage(systemName: "trash"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(deleteTag))
            barButtom.tintColor = .systemRed
            self.navigationItem.rightBarButtonItems = [barButtom]
            
            ruName = editingTag?.ruName
            ruAddressName = editingTag?.ruAddressName
            ruWebsite = editingTag?.ruWebsite
            if editingTag?.ruDescription != nil && editingTag?.ruDescription != "" {
                ruDescription = editingTag?.ruDescription
            }
            
            enName = editingTag?.enName
            enAddressName = editingTag?.enAddressName
            enWebsite = editingTag?.enWebsite
            if editingTag?.enDescription != nil && editingTag?.enDescription != "" {
                enDescription = editingTag?.enDescription
            }
            
            let category = globalVariables.categoryList.first { category in
                return category.enText == editingTag?.category ?? "None"
            }
            
            if globalVariables.currentLanguage == "en" {
                tagNameField.text = editingTag?.enName
                addressNameField.text = editingTag?.enAddressName
                websiteField.text = editingTag?.enWebsite
                if enDescription != nil && enDescription != "" {
                    descriptionTextView.text = enDescription
                    descriptionTextView.backgroundColor = UIColor(named: "background")
                }
                categoryLabel.text = category?.enText
                self.title = "Correct tag"
                addTagButton.setTitle("Save changes", for: .normal)
            } else {
                tagNameField.text = editingTag?.ruName
                addressNameField.text = editingTag?.ruAddressName
                websiteField.text = editingTag?.ruWebsite
                if ruDescription != nil && ruDescription != "" {
                    descriptionTextView.text = ruDescription
                    descriptionTextView.backgroundColor = UIColor(named: "background")
                }
                categoryLabel.text = category?.ruText 
                self.title = "Редактировать метку"
                addTagButton.setTitle("Сохранить изменения", for: .normal)
            }
            categoryImage.image = category!.image
            if editingTag?.contactNumber != nil {
                contactNumberField.text = editingTag?.contactNumber
            }
            
            mapView.setCenter(CLLocationCoordinate2D(latitude: editingTag!.latitude, longitude: editingTag!.longitude), animated: false)
            mapView.camera.centerCoordinateDistance = 2500
            
            publicAccessView.removeFromSuperview()
            publicAccessLabel.removeFromSuperview()
            
            weekdaysTimeArray = editingTag!.workingHoursWeekdays?.components(separatedBy: " - ")
            weekendsTimeArray = editingTag!.workingHoursWeekends?.components(separatedBy: " - ")
            
            showAsAuthorSwitch.isOn = editingTag!.showAuthor
        } else {
            if globalVariables.currentLanguage == "ru" {
                categoryLabel.text = "Ничего"
            }
        }
        
        setupWorkingHoursVeiw()
        
        nameNotice.isHidden = true
        nameConstraint.priority = UILayoutPriority(rawValue: 400)
        tagNameField.addTarget(self, action: #selector(nameChanged), for: .allEditingEvents)
    }
    
    // MARK: - Build Photos Scroll View
    
    func buildPhotosScrollView() {
        
        self.view.layoutSubviews()
        self.scrollView.layoutSubviews()
        self.photosView.layoutSubviews()
        self.photosScrollView.layoutSubviews()
        photosScrollViewHeight.constant = photosScrollView.frame.width * (9 / 16)
        self.photosView.layoutSubviews()
        self.photosScrollView.layoutSubviews()
        self.photosView.layoutSubviews()
        addPhotoButtonWidth = addPhotoButton.frame.width
        addPhotoButtonHeight = addPhotoButton.frame.height
        photosPageControll.numberOfPages = tagPhotos.count + 1

        let photoScrollFrame = photosScrollView.frame
        contentWidth = 0.0

        for constraint in addPhotoButton.constraints {
            constraint.isActive = false
        }
        UIView.transition(with: self.photosView, duration: 0.4, options: .transitionCrossDissolve, animations: { [self] in
            for view in photosScrollView.subviews {
                view.removeFromSuperview()
            }
        }, completion: nil)
            
            if tagPhotos.count != 0 {
                addPhotosToScrollView(photoScrollFrame: photoScrollFrame)
            }
            
            addPhotoButton.translatesAutoresizingMaskIntoConstraints = true
            photosScrollView.addSubview(addPhotoButton)
            
            let xCoordinateButton = (photoScrollFrame.width / 2 + photoScrollFrame.width * CGFloat(tagPhotos.count)) - addPhotoButtonWidth! / 2
            addPhotoButton.frame = CGRect(x: xCoordinateButton, y: photoScrollFrame.height / 2 - addPhotoButtonHeight! / 2, width: addPhotoButtonWidth!, height: addPhotoButtonHeight!)
            
            contentWidth += photoScrollFrame.width
            
            photosScrollView.contentSize = CGSize(width: contentWidth, height: photoScrollFrame.height)
        
    }
    
    func addPhotosToScrollView(photoScrollFrame: CGRect) {
        for i in 0...tagPhotos.count - 1 {
            
            contentWidth += photoScrollFrame.width
            
            let imageView = UIImageView(image: tagPhotos[i])
            imageView.contentMode = .scaleAspectFill
            imageView.alpha = 0.0
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 16
            
            
            photosScrollView.addSubview(imageView)
            
            let xCoordinate = photoScrollFrame.width * CGFloat(i)
            imageView.frame = CGRect(x: xCoordinate, y: 0, width: photoScrollFrame.width, height: photoScrollFrame.height)
            
            let deleteButton = UIButton()
            deleteButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            deleteButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .small), forImageIn: .normal)
            deleteButton.backgroundColor = .systemGray4
            deleteButton.tintColor = .darkGray
            deleteButton.tag = i
            deleteButton.addTarget(self, action: #selector(deletePhoto), for: .touchUpInside)
            deleteButton.alpha = 0.0
            photosScrollView.addSubview(deleteButton)
            deleteButton.frame = CGRect(x: photoScrollFrame.width * CGFloat(i) + photoScrollFrame.width - 8 - 28, y: 8, width: 28, height: 28)
            deleteButton.layer.masksToBounds = true
            deleteButton.layer.cornerRadius = 14
            
            UIView.transition(with: self.photosScrollView, duration: 0.4, options: .transitionCrossDissolve, animations: {
                imageView.alpha = 1.0
                deleteButton.alpha = 1.0
            }, completion: nil)
        }
    }
    
    // MARK: - Build Working Hours View
    
    func setupWorkingHoursVeiw() {

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC+3")
        dateFormatter.dateFormat = "HH:mm"
        
        workingHoursViewHeight.isActive = false
        
        let weekdaysLabel = UILabel()
        weekdaysLabel.translatesAutoresizingMaskIntoConstraints = false
        if globalVariables.currentLanguage == "en" {
            weekdaysLabel.text = "Weekdays"
        } else {
            weekdaysLabel.text = "Будние"
        }
        workingHoursView.addSubview(weekdaysLabel)
        weekdaysLabel.topAnchor.constraint(equalTo: workingHoursLabel.bottomAnchor, constant: 8).isActive = true
        weekdaysLabel.leadingAnchor.constraint(equalTo: workingHoursView.leadingAnchor, constant: 36).isActive = true
        
        let weekdaysStack = UIStackView()
        weekdaysStack.translatesAutoresizingMaskIntoConstraints = false
        weekdaysStack.axis = .horizontal
        weekdaysStack.distribution = .fillProportionally
        
        let weekdaysTimeViewSince = UIView()
        weekdaysTimeViewSince.translatesAutoresizingMaskIntoConstraints = false
        weekdaysTimeViewSince.backgroundColor = .clear
        
        let sinceWeekdaysLabel = UILabel()
        sinceWeekdaysLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if globalVariables.currentLanguage == "en" {
            sinceWeekdaysLabel.text = "Since"
        } else {
            sinceWeekdaysLabel.text = "C"
        }
        sinceWeekdaysLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        sinceWeekdaysLabel.textColor = UIColor(named: "textGrey")
        sinceWeekdaysLabel.textAlignment = .right
        
        weekdaysSinceTime = UIDatePicker()
        weekdaysSinceTime!.translatesAutoresizingMaskIntoConstraints = false
        weekdaysSinceTime!.locale = .current
        weekdaysSinceTime!.datePickerMode = .time
        weekdaysSinceTime!.preferredDatePickerStyle = .compact
        weekdaysSinceTime!.minuteInterval = 5
        if isEditingTag && editingTag?.workingHoursWeekdays != nil && editingTag?.workingHoursWeekdays != "" {
            weekdaysSinceTime!.date = dateFormatter.date(from: weekdaysTimeArray![0]) ?? Date()
        } else {
                weekdaysSinceTime!.date = dateFormatter.date(from: "07:00") ?? Date()
        }
        
        weekdaysTimeViewSince.addSubview(sinceWeekdaysLabel)
        weekdaysTimeViewSince.addSubview(weekdaysSinceTime!)
        
        sinceWeekdaysLabel.leadingAnchor.constraint(equalTo: weekdaysTimeViewSince.leadingAnchor).isActive = true
        sinceWeekdaysLabel.centerYAnchor.constraint(equalTo: weekdaysTimeViewSince.centerYAnchor).isActive = true
        
        weekdaysSinceTime!.centerYAnchor.constraint(equalTo: weekdaysTimeViewSince.centerYAnchor).isActive = true
        weekdaysSinceTime!.leadingAnchor.constraint(equalTo: sinceWeekdaysLabel.trailingAnchor, constant: 10).isActive = true
        weekdaysSinceTime!.trailingAnchor.constraint(equalTo: weekdaysTimeViewSince.trailingAnchor).isActive = true
        weekdaysSinceTime!.widthAnchor.constraint(equalToConstant: 88).isActive = true
        weekdaysSinceTime!.heightAnchor.constraint(equalToConstant: 34).isActive = true
        weekdaysTimeViewSince.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
       
        let weekdaysTimeViewUntil = UIView()
        weekdaysTimeViewUntil.translatesAutoresizingMaskIntoConstraints = false
        weekdaysTimeViewUntil.backgroundColor = .clear
        
        let untilWeekdaysLabel = UILabel()
        untilWeekdaysLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if globalVariables.currentLanguage == "en" {
            untilWeekdaysLabel.text = "Until"
        } else {
            untilWeekdaysLabel.text = "До"
        }
        untilWeekdaysLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        untilWeekdaysLabel.textColor = UIColor(named: "textGrey")
        untilWeekdaysLabel.textAlignment = .right
        
        weekdaysUntilTime = UIDatePicker()
        weekdaysUntilTime!.translatesAutoresizingMaskIntoConstraints = false
        weekdaysUntilTime!.locale = .current
        weekdaysUntilTime!.datePickerMode = .time
        weekdaysUntilTime!.preferredDatePickerStyle = .compact
        weekdaysUntilTime!.minuteInterval = 5
        if isEditingTag && editingTag?.workingHoursWeekdays != nil && editingTag?.workingHoursWeekdays != "" {
            weekdaysUntilTime!.date = dateFormatter.date(from: weekdaysTimeArray![1]) ?? Date()
        } else {
            weekdaysUntilTime!.date = dateFormatter.date(from: "21:00") ?? Date()
        }
        
        weekdaysTimeViewUntil.addSubview(untilWeekdaysLabel)
        weekdaysTimeViewUntil.addSubview(weekdaysUntilTime!)
        
        untilWeekdaysLabel.leadingAnchor.constraint(equalTo: weekdaysTimeViewUntil.leadingAnchor).isActive = true
        untilWeekdaysLabel.centerYAnchor.constraint(equalTo: weekdaysTimeViewUntil.centerYAnchor).isActive = true
        
        weekdaysUntilTime!.centerYAnchor.constraint(equalTo: weekdaysTimeViewUntil.centerYAnchor).isActive = true
        weekdaysUntilTime!.leadingAnchor.constraint(equalTo: untilWeekdaysLabel.trailingAnchor, constant: 10).isActive = true
        weekdaysUntilTime!.trailingAnchor.constraint(equalTo: weekdaysTimeViewUntil.trailingAnchor).isActive = true
        weekdaysUntilTime!.widthAnchor.constraint(equalToConstant: 88).isActive = true
        weekdaysUntilTime!.heightAnchor.constraint(equalToConstant: 34).isActive = true
        weekdaysTimeViewUntil.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        weekdaysStack.addArrangedSubview(weekdaysTimeViewSince)
        weekdaysStack.addArrangedSubview(weekdaysTimeViewUntil)
        workingHoursView.addSubview(weekdaysStack)
        
        weekdaysStack.leadingAnchor.constraint(equalTo: workingHoursView.leadingAnchor, constant: 12).isActive = true
        weekdaysStack.topAnchor.constraint(equalTo: weekdaysLabel.bottomAnchor, constant: 10).isActive  = true
        weekdaysStack.trailingAnchor.constraint(equalTo: workingHoursView.trailingAnchor, constant: -12).isActive = true
        
        
        
        let weekendsLabel = UILabel()
        weekendsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if globalVariables.currentLanguage == "en" {
            weekendsLabel.text = "Weekends"
        } else {
            weekendsLabel.text = "Выходные"
        }
        workingHoursView.addSubview(weekendsLabel)
        weekendsLabel.topAnchor.constraint(equalTo: weekdaysStack.bottomAnchor, constant: 18).isActive = true
        weekendsLabel.leadingAnchor.constraint(equalTo: workingHoursView.leadingAnchor, constant: 36).isActive = true
        
        let weekendsStack = UIStackView()
        weekendsStack.translatesAutoresizingMaskIntoConstraints = false
        weekendsStack.axis = .horizontal
        weekendsStack.distribution = .fillProportionally
        
        let weekendsTimeViewSince = UIView()
        weekendsTimeViewSince.translatesAutoresizingMaskIntoConstraints = false
        weekendsTimeViewSince.backgroundColor = .clear
        
        let sinceWeekendsLabel = UILabel()
        sinceWeekendsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if globalVariables.currentLanguage == "en" {
            sinceWeekendsLabel.text = "Since"
        } else {
            sinceWeekendsLabel.text = "C"
        }
        sinceWeekendsLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        sinceWeekendsLabel.textColor = UIColor(named: "textGrey")
        sinceWeekendsLabel.textAlignment = .right
        
        weekendsSinceTime = UIDatePicker()
        weekendsSinceTime!.translatesAutoresizingMaskIntoConstraints = false
        weekendsSinceTime!.locale = .current
        weekendsSinceTime!.datePickerMode = .time
        weekendsSinceTime!.preferredDatePickerStyle = .compact
        weekendsSinceTime!.minuteInterval = 5
        if isEditingTag {
            if editingTag?.workingHoursWeekends != nil && editingTag?.workingHoursWeekends != "" {
                weekendsSinceTime!.date = dateFormatter.date(from: weekendsTimeArray![0]) ?? Date()
            } else {
                weekendsSinceTime!.date = dateFormatter.date(from: "00:00") ?? Date()
            }
        } else {
            weekendsSinceTime!.date = dateFormatter.date(from: "10:00") ?? Date()
        }
        
        weekendsTimeViewSince.addSubview(sinceWeekendsLabel)
        weekendsTimeViewSince.addSubview(weekendsSinceTime!)
        
        sinceWeekendsLabel.leadingAnchor.constraint(equalTo: weekendsTimeViewSince.leadingAnchor).isActive = true
        sinceWeekendsLabel.centerYAnchor.constraint(equalTo: weekendsTimeViewSince.centerYAnchor).isActive = true
        
        weekendsSinceTime!.centerYAnchor.constraint(equalTo: weekendsTimeViewSince.centerYAnchor).isActive = true
        weekendsSinceTime!.leadingAnchor.constraint(equalTo: sinceWeekendsLabel.trailingAnchor, constant: 10).isActive = true
        weekendsSinceTime!.trailingAnchor.constraint(equalTo: weekendsTimeViewSince.trailingAnchor).isActive = true
        weekendsSinceTime!.widthAnchor.constraint(equalToConstant: 88).isActive = true
        weekendsSinceTime!.heightAnchor.constraint(equalToConstant: 34).isActive = true
        weekendsTimeViewSince.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
       
        let weekendsTimeViewUntil = UIView()
        weekendsTimeViewUntil.translatesAutoresizingMaskIntoConstraints = false
        weekendsTimeViewUntil.backgroundColor = .clear
        
        let untilWeekendsLabel = UILabel()
        untilWeekendsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if globalVariables.currentLanguage == "en" {
            untilWeekendsLabel.text = "Until"
        } else {
            untilWeekendsLabel.text = "До"
        }
        untilWeekendsLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        untilWeekendsLabel.textColor = UIColor(named: "textGrey")
        untilWeekendsLabel.textAlignment = .right
        
        weekendsUntilTime = UIDatePicker()
        weekendsUntilTime!.translatesAutoresizingMaskIntoConstraints = false
        weekendsUntilTime!.locale = .current
        weekendsUntilTime!.datePickerMode = .time
        weekendsUntilTime!.preferredDatePickerStyle = .compact
        weekendsUntilTime!.minuteInterval = 5
        if isEditingTag {
            if editingTag?.workingHoursWeekends != nil && editingTag?.workingHoursWeekends != "" {
                weekendsUntilTime!.date = dateFormatter.date(from: weekendsTimeArray![1]) ?? Date()
            } else {
                weekendsUntilTime!.date = dateFormatter.date(from: "00:00") ?? Date()
            }
        } else {
            weekendsUntilTime!.date = dateFormatter.date(from: "18:00") ?? Date()
        }
        
        weekendsTimeViewUntil.addSubview(untilWeekendsLabel)
        weekendsTimeViewUntil.addSubview(weekendsUntilTime!)
        
        untilWeekendsLabel.leadingAnchor.constraint(equalTo: weekendsTimeViewUntil.leadingAnchor).isActive = true
        untilWeekendsLabel.centerYAnchor.constraint(equalTo: weekendsTimeViewUntil.centerYAnchor).isActive = true
        
        weekendsUntilTime!.centerYAnchor.constraint(equalTo: weekendsTimeViewUntil.centerYAnchor).isActive = true
        weekendsUntilTime!.leadingAnchor.constraint(equalTo: untilWeekendsLabel.trailingAnchor, constant: 10).isActive = true
        weekendsUntilTime!.trailingAnchor.constraint(equalTo: weekendsTimeViewUntil.trailingAnchor).isActive = true
        weekendsUntilTime!.widthAnchor.constraint(equalToConstant: 88).isActive = true
        weekendsUntilTime!.heightAnchor.constraint(equalToConstant: 34).isActive = true
        weekendsTimeViewUntil.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        weekendsStack.addArrangedSubview(weekendsTimeViewSince)
        weekendsStack.addArrangedSubview(weekendsTimeViewUntil)
        workingHoursView.addSubview(weekendsStack)
        
        weekendsStack.leadingAnchor.constraint(equalTo: workingHoursView.leadingAnchor, constant: 12).isActive = true
        weekendsStack.topAnchor.constraint(equalTo: weekendsLabel.bottomAnchor, constant: 10).isActive  = true
        weekendsStack.trailingAnchor.constraint(equalTo: workingHoursView.trailingAnchor, constant: -12).isActive = true
        
        let showTimeLabel = UILabel()
        showTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if globalVariables.currentLanguage == "en" {
            showTimeLabel.text = "Show time"
        } else {
            showTimeLabel.text = "Показывать время"
        }
        
        workingHoursView.addSubview(showTimeLabel)
        
        showTimeLabel.leadingAnchor.constraint(equalTo: workingHoursView.leadingAnchor, constant: 20).isActive = true
        showTimeLabel.topAnchor.constraint(equalTo: weekendsStack.bottomAnchor, constant: 24).isActive = true
        showTimeLabel.bottomAnchor.constraint(equalTo: workingHoursView.bottomAnchor, constant: -23).isActive = true
        
        showTimeSwitch = UISwitch()
        showTimeSwitch?.translatesAutoresizingMaskIntoConstraints = false
        
        if isEditingTag && editingTag?.workingHoursWeekdays != nil && editingTag?.workingHoursWeekdays != "" {
            showTimeSwitch?.isOn = true
        } else {            
            showTimeSwitch?.isOn = false
        }
        
        
        workingHoursView.addSubview(showTimeSwitch!)
        
        showTimeSwitch?.centerYAnchor.constraint(equalTo: showTimeLabel.centerYAnchor).isActive = true
        showTimeSwitch?.trailingAnchor.constraint(equalTo: workingHoursView.trailingAnchor, constant: -20).isActive = true
        
        
    }
    
    // MARK: - Setup Category selection View
    
    func setupCategoryView() {
        
        self.view.layoutSubviews()
        
        categoryChooseView.translatesAutoresizingMaskIntoConstraints = false
        categoryChooseView.backgroundColor = UIColor(named: "infoColor")
        categoryChooseView.layer.masksToBounds = true
        categoryChooseView.layer.cornerRadius = 16
        categoryChooseView.isHidden = true
        
        self.view.addSubview(categoryChooseView)
        categoryChooseView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -80).isActive = true
        categoryChooseView.heightAnchor.constraint(equalToConstant: self.scrollView.frame.height * 0.75 - globalVariables.bottomScreenLength).isActive = true
        categoryChooseView.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
        categoryChooseView.centerYAnchor.constraint(equalTo: self.scrollView.centerYAnchor, constant: -globalVariables.bottomScreenLength / 2).isActive = true

        let categoryViewLabel = UILabel()
        categoryViewLabel.translatesAutoresizingMaskIntoConstraints = false
        if globalVariables.currentLanguage == "en" {
            categoryViewLabel.text = "Select category"
        } else {
            categoryViewLabel.text = "Выберете категорию"
        }
        
        categoryChooseView.addSubview(categoryViewLabel)
        
        categoryViewLabel.centerXAnchor.constraint(equalTo: categoryChooseView.centerXAnchor).isActive = true
        categoryViewLabel.topAnchor.constraint(equalTo: categoryChooseView.topAnchor, constant: 10).isActive = true
        
        let categoryScrollView = UIScrollView()
        categoryScrollView.translatesAutoresizingMaskIntoConstraints = false
        categoryScrollView.backgroundColor = UIColor(named: "infoColor")
        categoryScrollView.isPagingEnabled = false
        categoryScrollView.alwaysBounceVertical = true
        categoryScrollView.alwaysBounceHorizontal = false
        categoryScrollView.showsVerticalScrollIndicator = false
        
        categoryChooseView.addSubview(categoryScrollView)
        
        categoryScrollView.topAnchor.constraint(equalTo: categoryViewLabel.bottomAnchor, constant: 8).isActive = true
        categoryScrollView.trailingAnchor.constraint(equalTo: categoryChooseView.trailingAnchor, constant: 0).isActive = true
        categoryScrollView.bottomAnchor.constraint(equalTo: categoryChooseView.bottomAnchor, constant: 0).isActive = true
        categoryScrollView.leadingAnchor.constraint(equalTo: categoryChooseView.leadingAnchor, constant: 0).isActive = true
        
        self.view.layoutSubviews()
        categoryChooseView.layoutSubviews()
        
        for i in 0...globalVariables.categoryList.count - 1 {
            
            let viewCateg = HighlightView()
            viewCateg.backgroundColor = .clear
            viewCateg.isUserInteractionEnabled = true
            viewCateg.tag = i
            viewCateg.layer.masksToBounds = true
            viewCateg.layer.cornerRadius = 12
            
            let imageCatView = UIImageView()
            imageCatView.image = globalVariables.categoryList[i].image
            imageCatView.backgroundColor = .clear
            imageCatView.contentMode = .scaleAspectFill
            imageCatView.tintColor = .label
            
            viewCateg.addSubview(imageCatView)
            
            viewCateg.frame = CGRect(x: (categoryScrollWidth / 2) * CGFloat(i % 2), y: (categoryScrollWidth / 2) * CGFloat(i / 2), width: categoryScrollWidth / 2, height: categoryScrollWidth / 2)

            let widthImage = categoryScrollWidth / 2 * 0.35
            
            imageCatView.frame = CGRect(x: categoryScrollWidth / 4 - (widthImage / 2), y: categoryScrollWidth / 4 - (widthImage / 2) - categoryScrollWidth / 2 * 0.08, width: widthImage, height: widthImage)
            categoryScrollView.addSubview(viewCateg)
            
            let tapToView = UITapGestureRecognizer(target: self, action: #selector(selectCategory))
            viewCateg.addGestureRecognizer(tapToView)
            tapToView.view?.tag = i
            
            let catLabel = UILabel()
            if globalVariables.currentLanguage == "en" {
                catLabel.text = globalVariables.categoryList[i].enText
            } else {
                catLabel.text = globalVariables.categoryList[i].ruText
            }
            catLabel.textAlignment = .center
            
            viewCateg.addSubview(catLabel)
            
            viewCateg.layoutSubviews()
            
            catLabel.frame = CGRect(x: 0, y: categoryScrollWidth / 2 - 36 - categoryScrollWidth / 2 * 0.08, width: categoryScrollWidth / 2, height: 34)
            
        }

        
        categoryScrollView.contentSize = CGSize(width: categoryScrollWidth, height: categoryScrollWidth / 2 * CGFloat(globalVariables.categoryList.count / 2) + CGFloat(globalVariables.categoryList.count % 2 * Int(categoryScrollWidth) / 2))
       
    }
    
    // MARK: - Categories Functions
    
    @IBAction func chooseCategory(_ sender: Any) {
        selectFeedback.selectionChanged()
        UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: { [self] in
            categoryChooseView.isHidden = false
            effectView.isHidden = false
        }, completion: nil)
    }

    @objc func selectCategory(_ sender: UITapGestureRecognizer) {
        selectFeedback.selectionChanged()
        UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: { [self] in
            categoryChooseView.isHidden = true
            effectView.isHidden = true
        }, completion: nil)
        categoryImage.image = globalVariables.categoryList[sender.view!.tag].image
        
        if globalVariables.currentLanguage == "en" {
            categoryLabel.text = globalVariables.categoryList[sender.view!.tag].enText
        } else {
            categoryLabel.text = globalVariables.categoryList[sender.view!.tag].ruText
        }
    }
    
    @IBAction func closCategoryView(_ sender: Any) {
        UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: { [self] in
            categoryChooseView.isHidden = true
            effectView.isHidden = true
        }, completion: nil)
    }
    
    // MARK: - Segmented Controlles Functions
    
    @objc func segmentSelectedMap(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            return
        }
    }
    
    @objc func segmentSelectedLocalization(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            enName = tagNameField.text
            enAddressName = addressNameField.text
            enWebsite = websiteField.text
            enDescription = descriptionTextView.text
            
            tagNameField.text = ruName
            addressNameField.text = ruAddressName
            websiteField.text = ruWebsite
            if ruDescription != nil && ruDescription != "" {
                descriptionTextView.text = ruDescription
                descriptionTextView.backgroundColor = UIColor(named: "background")
            } else {
                descriptionTextView.text = ""
                descriptionTextView.backgroundColor = .clear
            }
        } else if sender.selectedSegmentIndex == 1 {
            ruName = tagNameField.text
            ruAddressName = addressNameField.text
            ruWebsite = websiteField.text
            ruDescription = descriptionTextView.text
            
            tagNameField.text = enName
            addressNameField.text = enAddressName
            websiteField.text = enWebsite
            if enDescription != nil && enDescription != "" {
                descriptionTextView.text = enDescription
                descriptionTextView.backgroundColor = UIColor(named: "background")
            } else {
                descriptionTextView.text = ""
                descriptionTextView.backgroundColor = .clear
            }
        }
    }
    
    // MARK: - Add or Save changes of tag
    
    @IBAction func addOrSave(_ sender: Any) {
        
        if personalInfo.isAuthorised {
            
            if localizationSegmentedControl.selectedSegmentIndex == 0 {
                ruName = tagNameField.text
                ruAddressName = addressNameField.text
                ruWebsite = websiteField.text
                ruDescription = descriptionTextView.text
            } else {
                enName = tagNameField.text
                enAddressName = addressNameField.text
                enWebsite = websiteField.text
                enDescription = descriptionTextView.text
            }
            
            if ruName == nil { ruName = "" }
            if enName == nil { enName = "" }
            
            if ((enName?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 >= 4 || (enName?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 && ruName?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 >= 4)) && (ruName?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 >= 4 || (ruName?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 && enName?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 >= 4))) && !personalInfo.userAccount!.isBanned {
                
                let center = getCenterLocation(for: mapView)
                let category = globalVariables.categoryList.first(where: { category in
                    return (globalVariables.currentLanguage == "en" && categoryLabel.text == category.enText) || (globalVariables.currentLanguage == "ru" && categoryLabel.text == category.ruText)
                })
                var photos: [String] = []
                for i in tagPhotos {
                    photos.append(Helpers().stringFromImage(image: i))
                }
                var weekdays = ""
                var weekends = ""
                if showTimeSwitch!.isOn {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    
                    weekdays = dateFormatter.string(from: weekdaysSinceTime!.date)
                    weekdays += " - "
                    weekdays += dateFormatter.string(from: weekdaysUntilTime!.date)
                    
                    if dateFormatter.string(from: weekendsSinceTime!.date) != dateFormatter.string(from: weekendsUntilTime!.date) {
                        
                        weekends = dateFormatter.string(from: weekendsSinceTime!.date)
                        weekends += " - "
                        weekends += dateFormatter.string(from: weekendsUntilTime!.date)
                    }
                }
                
                if !isEditingTag {
                    
                    var accessLevel: Int!
                    if publicAccessSwitch.isOn {
                        if personalInfo.userAccount!.permissionPublicTagsEveryone {
                            accessLevel = 1
                        } else {
                            accessLevel = 0
                        }
                    } else {
                        if personalInfo.userAccount!.permissionPrivateTagsFriends {
                            accessLevel = 1
                        } else {
                            accessLevel = 0
                        }
                    }
                    
                    var tag = Tag(latitude: center.coordinate.latitude, longitude: center.coordinate.longitude, altitude: 120, tagsId: 0, category: category?.enText, photos: photos, enName: enName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", enAddressName: enAddressName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", enWebsite: enWebsite?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", enDescription: enDescription?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", ruName: ruName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", ruAddressName: ruAddressName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", ruWebsite: ruWebsite?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", ruDescription: ruDescription?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", workingHoursWeekdays: weekdays, workingHoursWeekends: weekends, contactNumber: contactNumberField.text ?? "", isPublicAccess: publicAccessSwitch.isOn, accessLevel: accessLevel, authorId: personalInfo.userAccount!.userId, authorAvatar: personalInfo.userAccount!.avatar ?? "", authorName: personalInfo.userAccount!.name, authorNickname: personalInfo.userAccount!.nickname ?? "", reviews: [], views: 0, showAuthor: showAsAuthorSwitch.isOn)
                    
                    self.addTagButton.isEnabled = false
                    self.placeNotificationsView(event: .loading)
                    
                    Server.shared.addNewTag(tag: tag) { [self] answer in
                        self.addTagButton.isEnabled = true
                        self.removeNotificationView { [self] _ in
                            if answer.success {
                                
                                tag.tagsId = answer.tagsId
                                
                                let currentVC = self.navigationController?.topViewController
                                
                                guard var viewConstrollers = currentVC?.navigationController?.viewControllers else { return }
                                
                                _ = viewConstrollers.popLast()
                                let penultimate = viewConstrollers.last
                                
                                if publicAccessSwitch.isOn {
                                    personalInfo.userAccount?.publicTags.append(tag)
                                    if penultimate is TagsListViewController {
                                        (penultimate as! TagsListViewController).publicTags.append(tag)
                                    }
                                } else {
                                    personalInfo.userAccount?.privateTags.append(tag)
                                    if penultimate is TagsListViewController {
                                        (penultimate as! TagsListViewController).personalTags.append(tag)
                                    }
                                }
                                globalVariables.allTags.append(tag)
                                globalVariables.listOfAvailableTags.append(tag)
                                
                                if globalVariables.offlineMode {
                                    UserDefaults.standard.set(try? PropertyListEncoder().encode(globalVariables.allTags), forKey:"offlineTagsList")
                                }
                                
                                self.navigationController?.popViewController(animated: true)
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
                    
                    let tag = Tag(latitude: center.coordinate.latitude, longitude: center.coordinate.longitude, altitude: 120, tagsId: editingTag!.tagsId, category: category?.enText, photos: photos, enName: enName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", enAddressName: enAddressName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", enWebsite: enWebsite?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", enDescription: enDescription?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", ruName: ruName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", ruAddressName: ruAddressName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", ruWebsite: ruWebsite?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", ruDescription: ruDescription?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", workingHoursWeekdays: weekdays, workingHoursWeekends: weekends, contactNumber: contactNumberField.text ?? "", isPublicAccess: editingTag!.isPublicAccess, accessLevel: editingTag!.accessLevel, authorId: personalInfo.userAccount!.userId, authorAvatar: personalInfo.userAccount?.avatar, authorName: personalInfo.userAccount!.name, authorNickname: personalInfo.userAccount?.nickname, reviews: editingTag!.reviews, views: editingTag!.views, showAuthor: showAsAuthorSwitch.isOn)
                    
                    self.addTagButton.isEnabled = false
                    self.placeNotificationsView(event: .loading)
                    
                    Server.shared.correctTag(tag: tag) { [self] answer in
                        self.addTagButton.isEnabled = true
                        self.removeNotificationView { [self] _ in
                            if answer.success {
                                if tag.isPublicAccess {
                                    let index = personalInfo.userAccount!.publicTags.firstIndex(of: editingTag!)
                                    personalInfo.userAccount?.publicTags[index!] = tag
                                } else {
                                    let index = personalInfo.userAccount?.privateTags.firstIndex(of: editingTag!)
                                    personalInfo.userAccount?.privateTags[index!] = tag
                                }
                                let index0 = globalVariables.allTags.firstIndex(of: editingTag!)
                                globalVariables.allTags[index0!] = tag
                                let index = globalVariables.listOfAvailableTags.firstIndex(of: editingTag!)
                                globalVariables.listOfAvailableTags[index!] = tag
                                
                                let currentVC = self.navigationController?.topViewController
                                
                                guard var viewConstrollers = currentVC?.navigationController?.viewControllers else {
                                    return
                                }
                                
                                for i in viewConstrollers {
                                    if i is TagsListViewController {
                                        let tagsVC = i as! TagsListViewController
                                        if tag.isPublicAccess {
                                            let index = tagsVC.publicTags.firstIndex(of: editingTag!)
                                            tagsVC.publicTags[index!] = tag
                                            if tagsVC.isFiltering {
                                                let index = tagsVC.filteredPublicTags.firstIndex(of: editingTag!)
                                                tagsVC.filteredPublicTags[index!] = tag
                                            }
                                        } else {
                                            let index = tagsVC.personalTags.firstIndex(of: editingTag!)
                                            tagsVC.personalTags[index!] = tag
                                            if tagsVC.isFiltering {
                                                let index = tagsVC.filteredPersonalTags.firstIndex(of: editingTag!)
                                                tagsVC.filteredPersonalTags[index!] = tag
                                            }
                                        }
                                    }
                                }
                                
                                _ = viewConstrollers.popLast()
                                
                                let infoViewController = viewConstrollers.popLast()
                                if infoViewController is InfoViewController {
                                    (infoViewController as! InfoViewController).tag = tag
                                }
                                self.navigationController?.popViewController(animated: true)
                                
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
                }
            } else {
                if !((enName?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 >= 4 || (enName?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 && ruName?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 >= 4)) && (ruName?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 >= 4 || (ruName?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 && enName?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 >= 4))) {
                    nameConstraint.priority = UILayoutPriority(rawValue: 1000)
                    
                    nameNotice.alpha = 0.0
                    nameNotice.isHidden = false
                    
                    UIView.animate(withDuration: 0.4) { [self] in
                        nameNotice.alpha = 1.0
                        self.view.layoutIfNeeded()
                    }
                    scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                } else if personalInfo.userAccount?.isBanned ?? true {
                    placeNotificationsView(event: .banned)
                }
            }
        } else {
            globalVariables.shouldSaveTagInAddingViewController = true
            
            let storyboard = UIStoryboard(name: "Accounts", bundle: nil)
            
            willBeDeinited = false
            
            let VC = storyboard.instantiateViewController(identifier:"CreateAccountViewController")
            VC.modalPresentationStyle = .fullScreen
            VC.modalTransitionStyle = .crossDissolve
            
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    @objc func nameChanged() {
        nameConstraint.priority = UILayoutPriority(rawValue: 400)
        
        nameNotice.alpha = 1.0
        
        UIView.animate(withDuration: 0.4) { [self] in
            nameNotice.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        nameNotice.isHidden = true
    }
    
    // MARK: - Delete tag function
    
    @objc func deleteTag() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var title1: String!
        var title2: String!
        if globalVariables.currentLanguage == "en" {
            title1 = "Cancel"
            title2 = "Delete tag"
        } else {
            title1 = "Отменить"
            title2 = "Удалить метку"
        }
        actionSheet.addAction(UIAlertAction(title: title1, style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: title2, style: .destructive, handler: { _ in
            self.view.isUserInteractionEnabled = false
            self.placeNotificationsView(event: .loading)
            
            Server.shared.deleteTag(email: personalInfo.emailAddress ?? "", password: personalInfo.password ?? "", tagsId: self.editingTag!.tagsId) { [self] answer in
                self.view.isUserInteractionEnabled = true
                self.removeNotificationView { [self] _ in
                    if answer.success {
                        if editingTag!.isPublicAccess {
                            personalInfo.userAccount!.publicTags.removeAll { tag in
                                return tag.tagsId == editingTag!.tagsId
                            }
                        } else {
                            personalInfo.userAccount!.privateTags.removeAll { tag in
                                return tag.tagsId == editingTag!.tagsId
                            }
                        }
                        globalVariables.allTags.removeAll { tag in
                            return tag.tagsId == editingTag!.tagsId
                        }
                        
                        if globalVariables.offlineMode {
                            UserDefaults.standard.set(try? PropertyListEncoder().encode(globalVariables.allTags), forKey:"offlineTagsList")
                        }
                        
                        globalVariables.listOfAvailableTags.removeAll { tag in
                            return tag.tagsId == editingTag!.tagsId
                        }
                        
                        
                        let currentVC = self.navigationController?.topViewController
                        
                        guard var viewConstrollers = currentVC?.navigationController?.viewControllers else {
                            return
                        }
                        
                        for i in viewConstrollers {
                            if i is TagsListViewController {
                                let tagsVC = i as! TagsListViewController
                                if editingTag!.isPublicAccess {
                                    tagsVC.publicTags.removeAll { tag in
                                        return tag.tagsId == editingTag?.tagsId
                                    }
                                    tagsVC.filteredPublicTags.removeAll { tag in
                                        return tag.tagsId == editingTag?.tagsId
                                    }
                                } else {
                                    tagsVC.personalTags.removeAll { tag in
                                        return tag.tagsId == editingTag?.tagsId
                                    }
                                    tagsVC.filteredPersonalTags.removeAll { tag in
                                        return tag.tagsId == editingTag?.tagsId
                                    }
                                }
                            }
                        }
                        
                        _ = viewConstrollers.popLast()
                        if viewConstrollers.last is TagsListViewController {
                            currentVC?.navigationController?.setViewControllers(viewConstrollers, animated: true)
                            return
                        }
                        _ = viewConstrollers.popLast()
                        currentVC?.navigationController?.setViewControllers(viewConstrollers, animated: true)
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
    
    // MARK: - Location Services
    
    func setupLocationsServices(followUser: Bool = false) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            previousLocation = getCenterLocation(for: mapView)
            if locationManager?.authorizationStatus == .authorizedWhenInUse {
                setupMapView()
                mapView.showsUserLocation = true
                if followUser {
                    mapView.camera.centerCoordinateDistance = 500
                    mapView.setUserTrackingMode(.followWithHeading, animated: false)
                }
            } else if locationManager?.authorizationStatus == .notDetermined {
                locationManager?.requestWhenInUseAuthorization()
            } else {
                if !globalVariables.developeMode {
                    let alert = Helpers().constructAlert(error: .locationAuthorization)
                    self.present(alert, animated: true)
                }
            }
        } else {
            if !globalVariables.developeMode {
                let alert = Helpers().constructAlert(error: .locationAuthorization)
                self.present(alert, animated: true)
            }
        }
    }
    
    func setupMapView() {
        mapView.showsScale = false
        mapView.showsTraffic = false
        mapView.showsBuildings = true
        mapView.isZoomEnabled = true
        mapView.isPitchEnabled = true
        mapView.isRotateEnabled = true
        mapView.isScrollEnabled = true
        switch globalVariables.mapType {
        case "standart":
            mapView.mapType = .standard
            mapTypeSegmentedControl.selectedSegmentIndex = 0
        case "satellite":
            mapView.mapType = .satellite
            mapTypeSegmentedControl.selectedSegmentIndex = 1
        case "hybride":
            mapView.mapType = .hybrid
            mapTypeSegmentedControl.selectedSegmentIndex = 2
        default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            setupMapView()
            mapView.showsUserLocation = true
            if placingCoordinates != nil {
                mapView.setCenter(placingCoordinates!, animated: false)
                mapView.camera.centerCoordinateDistance = 2500
            } else if !isEditingTag {
                mapView.setUserTrackingMode(.follow, animated: false)
            }
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .denied, .restricted:
            if !globalVariables.developeMode {
                let alert = Helpers().constructAlert(error: .locationAuthorization)
                self.present(alert, animated: true)
            }
        @unknown default:
            fatalError()
        }
        
        let accuracyAuthorization = manager.accuracyAuthorization
        
        switch accuracyAuthorization {
        case .fullAccuracy:
            break
        case .reducedAccuracy:
            if !globalVariables.developeMode {
                let alert = Helpers().constructAlert(error: .locationAccuracyAuthorization)
                self.present(alert, animated: true)
            }
        default:
            break
        }
    }
    
    // MARK: - Image Picker View Functions
    
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
        
        tagPhotos.append(image)
        photosPageControll.numberOfPages = tagPhotos.count + 1
        buildPhotosScrollView()
        
        pickerController?.delegate = nil
        pickerController = nil        
    }
    
    // MARK: - Scroll View Functions
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        photosPageControll.currentPage = Int(photosScrollView.contentOffset.x / photosScrollView.frame.width)
    }
    
    @objc func pageControlDidChange(_ sender: UIPageControl) {
        let current = sender.currentPage
        photosScrollView.setContentOffset(CGPoint(x: CGFloat(current) * photosScrollView.frame.size.width, y: 0), animated: true)
    }
    
    @objc func deletePhoto(_ sender: UIButton) {
        tagPhotos.remove(at: sender.tag)
        photosPageControll.numberOfPages = tagPhotos.count + 1
        if photosPageControll.numberOfPages == 1 {
            photosPageControll.numberOfPages = 0
        }
        buildPhotosScrollView()
    }
    
    // MARK: - Text Field Functions
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        var seconds = 0.0
        if keyboardHeigth == 0.0 {
            seconds = 0.5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [self] in
            let visiblePart = scrollView.frame.height - keyboardHeigth - 23
            
            switch textField.tag {
            case 0:
                var yTagName = tagNameView.frame.maxY - (tagNameView.frame.size.height - tagNameField.frame.maxY) - visiblePart
                if yTagName < 0 { yTagName = 0}
                scrollView.setContentOffset(CGPoint(x: 0, y: yTagName), animated: true)
            case 1:
                var yAddressName = addressNameView.frame.maxY - (addressNameView.frame.size.height - addressNameField.frame.maxY) - visiblePart
                if yAddressName < 0 { yAddressName = 0}
                scrollView.setContentOffset(CGPoint(x: 0, y: yAddressName), animated: true)
            case 2:
                scrollView.setContentOffset(CGPoint(x: 0, y: contactNumberView.frame.maxY - (contactNumberView.frame.size.height - contactNumberField.frame.maxY) - visiblePart), animated: true)
            case 3:
                scrollView.setContentOffset(CGPoint(x: 0, y: websiteView.frame.maxY - (websiteView.frame.size.height - websiteField.frame.maxY) - visiblePart), animated: true)
            default:
                break
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            textField.resignFirstResponder()
        case 1:
            textField.resignFirstResponder()
        case 2:
            websiteField.becomeFirstResponder()
        case 3:
            descriptionTextView.becomeFirstResponder()
        default:
            break
        }
        return true
    }
    
    // MARK: - Text View Functions
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        let visiblePart = scrollView.frame.height - keyboardHeigth - 23
        scrollView.setContentOffset(CGPoint(x: 0, y: descriptionView.frame.maxY - (descriptionView.frame.size.height - descriptionTextView.frame.maxY) - visiblePart), animated: true)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == 0 {
            if textView.text == "" || textView.text == nil {
                textView.backgroundColor = .clear
            } else {
                textView.backgroundColor = UIColor(named: "background")
            }
        }
        
        UIView.animate(withDuration: 0.25) { [self] in
            self.view.layoutIfNeeded()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            let visiblePart = scrollView.frame.height - keyboardHeigth - 43
            var yToScroll = descriptionView.frame.minY + descriptionTextView.frame.maxY - visiblePart
            if yToScroll < 0 { yToScroll = 0}
            scrollView.setContentOffset(CGPoint(x: 0, y: yToScroll), animated: true)
        }
        
        UIView.animate(withDuration: 0.2) { [self] in
            self.view.layoutIfNeeded()
        }
        viewDidLayoutSubviews()
        
        return true
    }
    
    // MARK: - Auto Address Name Functions
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let lat = mapView.centerCoordinate.latitude
        let lon = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: lat, longitude: lon)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let _ = error { return }
            
            guard let placemark = placemarks?.first else { return }
            
            var street = placemark.thoroughfare ?? ""
            let building = placemark.subThoroughfare ?? ""
            if street != "" && building != "" {
                street += ", "
            }

            DispatchQueue.main.async {
                self.addressNameField.text = "\(street)\(building)"
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
