//
//  ViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 21.05.2021.
//

import UIKit
import MapKit
import ARKit
import CoreLocation

class MainViewController: UIViewController, LNTouchDelegate, CLLocationManagerDelegate, MKMapViewDelegate, ServerProtocol, DistanceUpdateProtocol {

    let server = Server.shared
    let distanceUpdater = DistanceUpdater.shared
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectFeedback = UISelectionFeedbackGenerator()
    
    @IBOutlet weak var arVewParentTop: NSLayoutConstraint!
    @IBOutlet weak var mapViewBottom: NSLayoutConstraint!
    @IBOutlet weak var mapViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var newsIndicator: UIView!
    
    @IBOutlet weak var settingsButton: HighlightView!
    @IBOutlet weak var settingsButtonImage: UIImageView!
    @IBOutlet weak var plusButton: HighlightView!
    @IBOutlet weak var plusButtonImage: UIImageView!
    @IBOutlet weak var categoriesButton: HighlightView!
    @IBOutlet weak var categoriesImage: UIImageView!
    
    @IBOutlet weak var arVewParent: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var effectView: UIVisualEffectView!
    
    var categoryChooseView: UIView?
    var categoryScrollView: UIScrollView?
    public var chosenCategory: String = "All"
    public var currentContentOffsetCategoryView: CGFloat?
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    var sceneLocationView: SceneLocationView?
    
    var window: UIWindow?
    
    var isWasSessionInterruption: Bool = false
    
    var accountIsRecieving: Bool = false
    var userWantsAccount: Bool = false
    
    var notificationView: UIView?
    
    var textLayers: Array<UILabel> = [] // Array<CATextLayer>
    
    // MARK: - View's Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        globalVariables.maiVCDidLoad = true
        
        server.delegate = self
        accountIsRecieving = server.accountIsRecieving
        
        distanceUpdater.delegate = self
        
        globalVariables.currentLanguage = Locale.current.languageCode ?? "en"
        
        window = UIApplication.shared.windows[0]
        figureOutLength()
        setupScene()
        
        newsIndicator.alpha = 0.75
        
        NotificationCenter.default.addObserver(forName: .sessionWasInterrupted, object: nil, queue: OperationQueue.main) { (notification) in
            self.sceneLocationView!.locationNodeTouchDelegate = nil
            self.sceneLocationView!.removeFromSuperview()
            self.isWasSessionInterruption = true
        }
        NotificationCenter.default.addObserver(forName: .sessionInterruptionEnded, object: nil, queue: OperationQueue.main) { [self] (notification) in
            isWasSessionInterruption = false
            sceneLocationView!.pause()
            sceneLocationView = nil
            
            sceneLocationView = SceneLocationView()
            sceneLocationView!.locationNodeTouchDelegate = self
            arVewParent.addSubview(sceneLocationView!)
            
            arVewParent.bringSubviewToFront(settingsButton)
            arVewParent.bringSubviewToFront(newsIndicator)
            arVewParent.bringSubviewToFront(plusButton)
            arVewParent.bringSubviewToFront(categoriesButton)
            
            sceneLocationView!.run()
            distanceUpdater.startTracking()
            
            sceneLocationView?.frame = self.arVewParent.bounds
            
            self.view.layoutSubviews()

            if (self.navigationController?.topViewController == self) {
                self.addArAnnotations()
                self.addAnnotations()
            }
            
            if globalVariables.mustShowNewAchievement || globalVariables.mustShowFriendWithID != 0 || globalVariables.mustShowFriendsList {
                DispatchQueue.main.async {
                    self.navigationController?.setViewControllers([self], animated: true)
                    self.openAccountViewController(Any.self)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        var categories = globalVariables.categoryList
        _ = categories.popLast()
        categories.insert(category(image: UIImage(systemName: "square.dashed")!, enText: "All", ruText: "Все"), at: 0)
        
        let curCategory = categories.first(where: { category in
            return category.enText == chosenCategory
        })
        
        categoriesImage?.image = curCategory!.image
        
        if personalInfo.userAccount?.waitingFriends.count ?? 0 != 0 {
            newsIndicator.isHidden = false
        } else {
            newsIndicator.isHidden = true
        }
        
        setupLocationsServices()
        if globalVariables.listOfAvailableTags.count != 0 {
            self.sceneLocationView?.removeAllNodes()
            self.textLayers = []
            self.mapView?.removeAnnotations(self.mapView.annotations)
            self.addAnnotations()
            self.addArAnnotations()
        }
        self.distanceUpdater.startTracking()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        newsIndicator.isHidden = true
        
        mapView.removeAnnotations(mapView.annotations)
        sceneLocationView?.removeAllNodes()
        self.textLayers = []
        self.distanceUpdater.stopTraking()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.sceneLocationView?.removeAllNodes()
        self.textLayers = []
        self.addArAnnotations()
        self.addAnnotations()
    }
    
    // MARK: - Setup Functions
    
    func setupScene() {
        
        self.view.layoutSubviews()
        self.arVewParent.layoutSubviews()
        
        sceneLocationView = SceneLocationView()
        sceneLocationView!.locationNodeTouchDelegate = self
        arVewParent.addSubview(sceneLocationView!)
        sceneLocationView!.run()
        self.distanceUpdater.startTracking()
        self.sceneLocationView?.frame = arVewParent.bounds
        
        
        arVewParent.addSubview(settingsButton)
        arVewParent.addSubview(newsIndicator)
        arVewParent.addSubview(plusButton)
        arVewParent.addSubview(categoriesButton)
        
        settingsButton.layer.masksToBounds = true
        settingsButton.layer.cornerRadius = 18
        newsIndicator.layer.masksToBounds = true
        newsIndicator.layer.cornerRadius = 6
        plusButton.layer.masksToBounds = true
        plusButton.layer.cornerRadius = 18
        categoriesButton.layer.masksToBounds = true
        categoriesButton.layer.cornerRadius = 18
        
        settingsButton.backgroundColor = UIColor(named: "mainScreenButtons")
        settingsButton.alpha = 0.75
        settingsButtonImage.tintColor = UIColor(named: "tintForMainScreenButtons")
        plusButton.backgroundColor = UIColor(named: "mainScreenButtons")
        plusButton.alpha = 0.75
        plusButtonImage.tintColor = UIColor(named: "tintForMainScreenButtons")
        categoriesButton.backgroundColor = UIColor(named: "mainScreenButtons")
        categoriesButton.alpha = 0.75
        categoriesImage.tintColor = UIColor(named: "tintForMainScreenButtons")
        settingsButton.normalOpacity = 0.75
        settingsButton.isMainScreenButtons = true
        plusButton.normalOpacity = 0.75
        plusButton.isMainScreenButtons = true
        categoriesButton.normalOpacity = 0.75
        categoriesButton.isMainScreenButtons = true
        
        self.arVewParentTop.isActive = false
        self.mapViewBottom.isActive = false
        
        self.arVewParentTop = arVewParent.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -globalVariables.topScreenLength)
        self.mapViewBottom = mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: globalVariables.bottomScreenLength)
        self.mapViewHeight.constant = (globalVariables.screenHeight / 3 + 20)
        
        self.mapViewBottom.isActive = true
        self.arVewParentTop.isActive = true
        
        self.view.layoutSubviews()
        self.arVewParent.layoutSubviews()
        let drawingRect: CGRect = mapView.bounds
        let bezier = UIBezierPath()
        
        bezier.move(to: CGPoint(x: drawingRect.minX, y: drawingRect.maxY))
        bezier.addLine(to: CGPoint(x: drawingRect.minX, y: drawingRect.minY + 40))
        bezier.addQuadCurve(to: CGPoint(x: drawingRect.maxX, y: drawingRect.minY + 40), controlPoint: CGPoint(x: drawingRect.midX, y: drawingRect.minY))
        bezier.addLine(to: CGPoint(x: drawingRect.maxX, y: drawingRect.maxY))
        bezier.addLine(to: CGPoint(x: drawingRect.minX, y: drawingRect.maxY))
        bezier.close()
        
        let mask = CAShapeLayer()
        mask.path = bezier.cgPath
        
        mapView.layer.mask = mask
        mapView.showsCompass = false
        
        switch globalVariables.appearanceMode {
        case "light":
            window?.overrideUserInterfaceStyle = .light
        case "dark":
            window?.overrideUserInterfaceStyle = .dark
        case "system":
            window?.overrideUserInterfaceStyle = .unspecified
        default:
            break
        }
        
        impactFeedback.prepare()
        selectFeedback.prepare()
        
        effectView.removeConstraints(effectView.constraints)
        effectView.removeFromSuperview()
        self.view.addSubview(effectView)
        effectView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -globalVariables.topScreenLength).isActive = true
        effectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        effectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        effectView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: globalVariables.bottomScreenLength).isActive = true
        effectView.isHidden = true
        
        self.view.bringSubviewToFront(effectView)
        
        if globalVariables.mustShowNewAchievement || globalVariables.mustShowFriendWithID != 0 || globalVariables.mustShowFriendsList {
            DispatchQueue.main.async {
                self.navigationController?.setViewControllers([self], animated: true)
                self.openAccountViewController(Any.self)
            }
        }
    }
    
    func figureOutLength() {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
            globalVariables.topScreenLength = window?.safeAreaInsets.top ?? 0.0
            globalVariables.bottomScreenLength = window?.safeAreaInsets.bottom ?? 0.0
        }
        globalVariables.screenHeight = UIScreen.main.bounds.height
        globalVariables.screenWidth = UIScreen.main.bounds.width
    }
    
    func setupLocationsServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            if locationManager.authorizationStatus == .authorizedWhenInUse {
                setupMapView(animated: false)
                mapView?.showsUserLocation = true
                mapView?.setUserTrackingMode(.followWithHeading, animated: false)
            } else if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            } else {
                if !globalVariables.developeMode {
                    let alert = Helpers().constructAlert(error: .locationAuthorization)
                    self.present(alert, animated: true)
                }
            }
            if locationManager.accuracyAuthorization == .reducedAccuracy {
                if !globalVariables.developeMode {
                    let alert = Helpers().constructAlert(error: .locationAccuracyAuthorization)
                    self.present(alert, animated: true)
                }
            }
        } else {
            if !globalVariables.developeMode {
                let alert = Helpers().constructAlert(error: .locationAuthorization)
                self.present(alert, animated: true)
            }
        }
        
        if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    print("granted")
                } else {
                    print("denide")
                }
            })
        } else if AVCaptureDevice.authorizationStatus(for: .video) == .denied || AVCaptureDevice.authorizationStatus(for: .video) == .restricted {
            if !globalVariables.developeMode {
                let alert = Helpers().constructAlert(error: .cameraAuthorization)
                self.present(alert, animated: true)
            }
        }
    }
    
    func setupMapView(animated: Bool) {
        mapView.showsScale = false
        mapView.showsTraffic = false
        mapView.showsBuildings = true
        mapView.isZoomEnabled = true
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        mapView.isScrollEnabled = false
        mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 200, maxCenterCoordinateDistance: 7500), animated: animated)
        mapView.delegate = self
        switch globalVariables.mapType {
        case "standart":
            mapView.mapType = .standard
        case "satellite":
            mapView.mapType = .satellite
        case "hybride":
            mapView.mapType = .hybrid
        default:
            break
        }
    }
    
    func addAnnotations() {
        for pin in globalVariables.listOfAvailableTags.filter({ tag in
            return locationManager.location?.distance(from: CLLocation(latitude: tag.latitude,longitude: tag.longitude)) ?? 5000 <= 4200
        }) {
            var name: String?
            if globalVariables.currentLanguage == "ru" {
                name = pin.ruName
            } else {
                name = pin.enName
            }
            if (name == nil || name == "") && pin.authorId != personalInfo.userAccount?.userId ?? 0 && !globalVariables.showForeignTags {
                continue
            } else if (name == nil || name == "") {
                if globalVariables.currentLanguage == "en" {
                    name = pin.ruName
                } else {
                    name = pin.enName
                }
            }
            
            let mapAnnotation = MKPointAnnotation()
            let location = CLLocationCoordinate2D(latitude: pin.latitude, longitude:pin.longitude)
            mapAnnotation.coordinate = location
            mapAnnotation.title = name!
            mapAnnotation.accessibilityNavigationStyle = .separate
            self.mapView.addAnnotation(mapAnnotation)
        }

    }
    
    func addArAnnotations() {
        for pin in globalVariables.listOfAvailableTags.filter({ tag in
            return locationManager.location?.distance(from: CLLocation(latitude: tag.latitude,  longitude: tag.longitude)) ?? 5000 <= 4200
        }) {
            let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude), altitude: pin.altitude,   horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date())
        
            var name: String?

            if globalVariables.currentLanguage == "ru" {
                name = pin.ruName
            } else {
                name = pin.enName
            }
            if (name == nil || name == "") && pin.authorId != personalInfo.userAccount?.userId ?? 0 && !globalVariables.showForeignTags {
                continue
            } else if (name == nil || name == "") {
                if globalVariables.currentLanguage == "en" {
                    name = pin.ruName
                } else {
                    name = pin.enName
                }
            }
            
            /*
            var widthOfView: Int?
            if name!.count <= 5 {
                widthOfView = name!.count * 18
            } else if name!.count > 5 && name!.count <= 20 {
                widthOfView = name!.count * 13
            } else {
                widthOfView = name!.count * 10
            }
            
            
            let view = UIView()
            let lable = UILabel(frame: CGRect(x: 0, y: 0, width: widthOfView!, height: 40))
            lable.text = name!
            lable.textAlignment = .center
            lable.backgroundColor = UIColor(named: "annotations")
            lable.textColor = UIColor.darkText
            lable.tag = pin.tagsId
            lable.layer.masksToBounds = true
            lable.layer.cornerRadius = 18
            
            view.frame = CGRect(x: 0, y: 0, width: lable.frame.width, height:  lable.frame.height)
            view.layer.cornerRadius = 18
            view.addSubview(lable)
            */
            
            let title = UILabel()
            title.text = name!
            title.textAlignment = .center
            title.textColor = UIColor.darkText
            title.font = UIFont.systemFont(ofSize: 19)
            var title_width = title.intrinsicContentSize.width
            if title_width > 160 {
                title_width = 160
            }
            title.frame = CGRect(x: 12, y: 0, width: title_width, height: 46)
            
            let distance = UILabel()
            if let loc = sceneLocationView!.sceneLocationManager.currentLocation {
                distance.text = Helpers().calculateDistance(viewLocation: CLLocation(latitude: pin.latitude, longitude: pin.longitude), userLocation: loc)
            }
            distance.tag = pin.tagsId
            distance.textAlignment = .center
            distance.textColor = UIColor.gray
            distance.font = UIFont.systemFont(ofSize: 17)
            var distanceLabelWidth = distance.intrinsicContentSize.width
            //print(distanceLabelWidth)
            if distanceLabelWidth <= 30 {
                distanceLabelWidth = 50
                DistanceUpdater.shared.updateNow()
            }
            distance.frame = CGRect(x: title_width + 12, y: 2, width: distanceLabelWidth + 16, height: 24)
            
            var middleMark = 0.0
            var marksSumm = 0
            
            if pin.reviews?.count != 0 {
                for i in pin.reviews! {
                    marksSumm += i.mark
                }
                middleMark = Double(marksSumm) / Double(pin.reviews!.count)
                middleMark = round(middleMark * 10) / 10.0
            }
            
            let starsImage = UIImageView(frame: CGRect(x: title_width + 20 + 5, y: 27, width: 12, height: 12))
            if middleMark >= 4.0 {
                starsImage.image = UIImage(systemName: "star.fill")
                starsImage.tintColor = UIColor.systemYellow
            } else if 2.5 <= middleMark && middleMark < 4.0 {
                starsImage.image = UIImage(systemName: "star")
                starsImage.tintColor = UIColor.systemYellow
            } else {
                starsImage.image = UIImage(systemName: "star")
                starsImage.tintColor = UIColor.gray
            }
            
            starsImage.backgroundColor = .clear
            starsImage.preferredSymbolConfiguration = UIImage.SymbolConfiguration(scale: .small)
            starsImage.contentMode = .center
            
            let ratingLabel = UILabel(frame: CGRect(x: starsImage.frame.maxX - 5, y: 20, width: 40, height: 26))
            ratingLabel.text = String(middleMark)
            ratingLabel.textAlignment = .center
            ratingLabel.textColor = UIColor.black
            ratingLabel.font = UIFont.systemFont(ofSize: 15)
            
            
            let tag = UIView(frame: CGRect(x: 0, y: 0, width: title_width + distanceLabelWidth + 38 + 2, height: 46))
            tag.backgroundColor = UIColor(named: "annotations")
            tag.layer.masksToBounds = true
            tag.layer.cornerRadius = 16
            tag.addSubview(title)
            tag.addSubview(ratingLabel)
            tag.addSubview(distance)
            tag.addSubview(starsImage)
            
            
            /*
            let width = view.bounds.width
            let height = view.bounds.height
            let cornerRadius = view.layer.cornerRadius
            
            let b = UIBezierPath()
            
            b.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: 90 * .pi / 180, endAngle: 180 * .pi / 180, clockwise: true)
            b.move(to: CGPoint(x: cornerRadius, y: 0))
            b.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
            b.addArc(withCenter: CGPoint(x: width - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: 90 * .pi / 180, clockwise: true)
            b.move(to: CGPoint(x: width, y: cornerRadius))
            b.addLine(to: CGPoint(x: width, y: height - cornerRadius))
            b.addArc(withCenter: CGPoint(x: width - cornerRadius, y: height - cornerRadius), radius: cornerRadius, startAngle: 270 * .pi / 180, endAngle: 360 * .pi / 180, clockwise: true)
            b.move(to: CGPoint(x: width - cornerRadius, y: height))
            b.addLine(to: CGPoint(x: cornerRadius, y: height))
            b.addArc(withCenter: CGPoint(x: cornerRadius, y: height - cornerRadius), radius: cornerRadius, startAngle: 180 * .pi / 180, endAngle: 270 * .pi / 180, clockwise: true)
            b.move(to: CGPoint(x: 0, y: height - cornerRadius))
            b.addLine(to: CGPoint(x: 0, y: cornerRadius))
            b.close()
            
            let mask = CAShapeLayer()
            mask.path = b.cgPath
            
            view.layer.mask = mask
            */
            
            //let annotationNode = LocationAnnotationNode(location: location, view:view, id: pin.tagsId)
            
            
            
            /*
            let tag_layer = CALayer()
            tag_layer.contentsScale = UIScreen.main.scale
            tag_layer.allowsEdgeAntialiasing = true
            
            let background_layer = CALayer()
            background_layer.contentsScale = UIScreen.main.scale
            background_layer.allowsEdgeAntialiasing = true
            
            let title_layer = CATextLayer()
            title_layer.contentsScale = UIScreen.main.scale
            title_layer.allowsEdgeAntialiasing = true
            title_layer.allowsFontSubpixelQuantization = true
            
            let distance_layer = CATextLayer()
            distance_layer.contentsScale = UIScreen.main.scale
            distance_layer.allowsEdgeAntialiasing = true
            distance_layer.allowsFontSubpixelQuantization = true
            
            let star_image_layer = CALayer()
            star_image_layer.contentsScale = UIScreen.main.scale
            star_image_layer.allowsEdgeAntialiasing = true
            
            let stars_value_layer = CATextLayer()
            stars_value_layer.contentsScale = UIScreen.main.scale
            stars_value_layer.allowsEdgeAntialiasing = true
            stars_value_layer.allowsFontSubpixelQuantization = true
            
            
            tag_layer.frame = CGRect(x: 0, y: 0, width: 150, height: 60)
            background_layer.frame = CGRect(x: 5, y: 5, width: tag_layer.frame.width - 10, height: tag_layer.frame.height - 10)
            
            background_layer.backgroundColor = UIColor(named: "annotations")?.cgColor
            background_layer.masksToBounds = false
            background_layer.cornerRadius = 20
            tag_layer.addSublayer(background_layer)
            
            
            title_layer.frame = CGRect(x: 4, y: 4, width: 100, height: 50)
            title_layer.contentsScale = UIScreen.main.scale
            title_layer.allowsFontSubpixelQuantization = true
            title_layer.allowsEdgeAntialiasing = true
            
            title_layer.fontSize = 20
            title_layer.alignmentMode = .center
            title_layer.foregroundColor = UIColor.black.cgColor
            title_layer.string = name!
            title_layer.isWrapped = false // true
            title_layer.truncationMode = .none
            background_layer.addSublayer(title_layer)
            
            
            distance_layer.frame = CGRect(x: background_layer.bounds.width - 4 - 50, y: 4, width: 50, height: 50)
            distance_layer.contentsScale = UIScreen.main.scale
            distance_layer.allowsFontSubpixelQuantization = true
            distance_layer.allowsEdgeAntialiasing = true
            distance_layer.fontSize = 20
            distance_layer.alignmentMode = .right
            distance_layer.foregroundColor = UIColor.gray.cgColor
            if let loc = sceneLocationView!.sceneLocationManager.currentLocation {
                distance_layer.string = Helpers().calculateDistance(viewLocation: CLLocation(latitude: pin.latitude, longitude: pin.longitude), userLocation: loc)
            }
            distance_layer.name = String(pin.tagsId)
            distance_layer.isWrapped = false // true
            distance_layer.truncationMode = .none
            background_layer.addSublayer(distance_layer)
            */
            
            // star_image_layer
            
            
            // stars_value_layer
            
            //tag_layer.frame = CGRect(x: 0, y: 0, width: 200, height: 150) // width: title_layer.preferredFrameSize().width + distance_layer.preferredFrameSize().width + 40 + 40
            //let annotationNode = LocationAnnotationNode(location: location, layer: layer_old, id: pin.tagsId)
            //let annotationNode = LocationAnnotationNode(location: location, layer: tag_layer, id: pin.tagsId)
            let annotationNode = LocationAnnotationNode(location: location, view_dynamic: tag, id: pin.tagsId)
            annotationNode.ignoreAltitude = true
            
            sceneLocationView?.addLocationNodeWithConfirmedLocation(locationNode:  annotationNode)
            
            textLayers.append(distance)
            
        }
    }
    
    // MARK: - Actions
    
    @IBAction func openMapViewController(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            impactFeedback.impactOccurred()            
            let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
            pushViewController(storyboard: storyboard, identifier: "MapViewController")
        }
    }
    
    @IBAction func openAccountViewController(_ sender: Any) {
        if self.accountIsRecieving {
            self.userWantsAccount = true
            placeNotificationsView(event: .loading)
        } else {
            if personalInfo.isAuthorised { // if user is authorised
                let storyboard = UIStoryboard(name: "Accounts", bundle: nil)
                pushViewController(storyboard: storyboard, identifier: "AccountIfoViewController")
            } else {
                let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
                pushViewController(storyboard: storyboard, identifier: "OptionsViewController")
            }
        }
    }
    
    @IBAction func openAddingScreen(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Tags", bundle: nil)
        pushViewController(storyboard: storyboard, identifier: "AddingAndEditingViewController")
    }
    
    func pushViewController(storyboard: UIStoryboard, identifier: String) {
        
        let VC = storyboard.instantiateViewController(identifier: identifier)
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func showCategoriesView(_ sender: Any) {
        
        impactFeedback.impactOccurred()
        
        self.view.layoutSubviews()
        
        categoryChooseView = UIView()
        
        categoryChooseView!.translatesAutoresizingMaskIntoConstraints = false
        categoryChooseView!.backgroundColor = UIColor(named: "infoColor")
        categoryChooseView!.layer.masksToBounds = true
        categoryChooseView!.layer.cornerRadius = 22
        categoryChooseView!.isHidden = true
        
        self.view.addSubview(categoryChooseView!)
        
        self.view.bringSubviewToFront(categoryChooseView!)
        
        categoryChooseView!.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -80).isActive = true
        categoryChooseView!.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.75 - globalVariables.bottomScreenLength).isActive = true
        categoryChooseView!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        categoryChooseView!.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true

        let categoryViewLabel = UILabel()
        categoryViewLabel.translatesAutoresizingMaskIntoConstraints = false
        if globalVariables.currentLanguage == "en" {
            categoryViewLabel.text = "Filter by category"
        } else {
            categoryViewLabel.text = "Фильтровать по категориям"
        }
        
        categoryChooseView!.addSubview(categoryViewLabel)
        
        categoryViewLabel.centerXAnchor.constraint(equalTo: categoryChooseView!.centerXAnchor).isActive = true
        categoryViewLabel.topAnchor.constraint(equalTo: categoryChooseView!.topAnchor, constant: 10).isActive = true
        
        categoryScrollView = UIScrollView()
        categoryScrollView!.translatesAutoresizingMaskIntoConstraints = false
        categoryScrollView!.backgroundColor = UIColor(named: "infoColor")
        categoryScrollView!.isPagingEnabled = false
        categoryScrollView!.alwaysBounceVertical = true
        categoryScrollView!.alwaysBounceHorizontal = false
        categoryScrollView!.showsVerticalScrollIndicator = false
        
        categoryChooseView!.addSubview(categoryScrollView!)
        
        categoryScrollView!.topAnchor.constraint(equalTo: categoryViewLabel.bottomAnchor, constant: 8).isActive = true
        categoryScrollView!.trailingAnchor.constraint(equalTo: categoryChooseView!.trailingAnchor, constant: 0).isActive = true
        categoryScrollView!.bottomAnchor.constraint(equalTo: categoryChooseView!.bottomAnchor, constant: 0).isActive = true
        categoryScrollView!.leadingAnchor.constraint(equalTo: categoryChooseView!.leadingAnchor, constant: 0).isActive = true
        
        self.view.layoutSubviews()
        categoryChooseView!.layoutSubviews()
        
        let categoryScrollWidth = self.view.frame.size.width - 80
        
        var categories = globalVariables.categoryList
        _ = categories.popLast()
        categories.insert(category(image: UIImage(systemName: "square.dashed")!, enText: "All", ruText: "Все"), at: 0)
        
        for i in 0...categories.count - 1 {
            
            let viewCateg = HighlightView()
            viewCateg.backgroundColor = .clear
            viewCateg.isUserInteractionEnabled = true
            viewCateg.tag = i
            viewCateg.layer.masksToBounds = true
            viewCateg.layer.cornerRadius = 12
            
            let imageCatView = UIImageView()
            imageCatView.image = categories[i].image
            imageCatView.backgroundColor = .clear
            imageCatView.contentMode = .scaleAspectFill
            imageCatView.tintColor = .label
            
            viewCateg.addSubview(imageCatView)
            
            viewCateg.frame = CGRect(x: (categoryScrollWidth / 2) * CGFloat(i % 2), y: (categoryScrollWidth / 2) * CGFloat(i / 2), width: categoryScrollWidth / 2, height: categoryScrollWidth / 2)

            let widthImage = categoryScrollWidth / 2 * 0.35
            
            imageCatView.frame = CGRect(x: categoryScrollWidth / 4 - (widthImage / 2), y: categoryScrollWidth / 4 - (widthImage / 2) - categoryScrollWidth / 2 * 0.08, width: widthImage, height: widthImage)
            categoryScrollView!.addSubview(viewCateg)
            
            let tapToView = UITapGestureRecognizer(target: self, action: #selector(selectedCategory))
            viewCateg.addGestureRecognizer(tapToView)
            tapToView.view?.tag = i
            
            let catLabel = UILabel()
            if globalVariables.currentLanguage == "en" {
                catLabel.text = categories[i].enText
            } else {
                catLabel.text = categories[i].ruText
            }
            catLabel.textAlignment = .center
            
            if categories[i].enText == chosenCategory {
                imageCatView.tintColor = .systemBlue
                catLabel.textColor = .systemBlue
            }
            
            viewCateg.addSubview(catLabel)
            
            viewCateg.layoutSubviews()
            
            catLabel.frame = CGRect(x: 0, y: categoryScrollWidth / 2 - 36 - categoryScrollWidth / 2 * 0.08, width: categoryScrollWidth / 2, height: 34)
        }

        categoryScrollView!.contentSize = CGSize(width: categoryScrollWidth, height: categoryScrollWidth / 2 * CGFloat(categories.count / 2) + CGFloat(categories.count % 2 * Int(categoryScrollWidth) / 2))
       
        categoryScrollView?.setContentOffset(CGPoint(x: 0.0, y: currentContentOffsetCategoryView ?? 0.0), animated: false)
        
        UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: { [self] in
            categoryChooseView!.isHidden = false
            effectView.isHidden = false
        }, completion: nil)
    }
    
    @objc func selectedCategory(_ sender: UITapGestureRecognizer) {
        selectFeedback.selectionChanged()

        var categories = globalVariables.categoryList
        _ = categories.popLast()
        categories.insert(category(image: UIImage(systemName: "square.dashed")!, enText: "All", ruText: "Все"), at: 0)
        
        chosenCategory = categories[sender.view!.tag].enText
        
        let curCategory = categories.first(where: { category in
            return category.enText == chosenCategory
        })
        
        categoriesImage.image = curCategory!.image
        if curCategory?.enText != "All" {
            Helpers().sortAvailableTags(category: curCategory!.enText) { done in
                self.sceneLocationView?.removeAllNodes()
                self.textLayers = []
                self.mapView?.removeAnnotations(self.mapView.annotations)
                self.addAnnotations()
                self.addArAnnotations()
            }
        } else {
            Helpers().sortAvailableTags(category: nil) { done in
                self.sceneLocationView?.removeAllNodes()
                self.textLayers = []
                self.mapView?.removeAnnotations(self.mapView.annotations)
                self.addAnnotations()
                self.addArAnnotations()
            }
        }
        
        currentContentOffsetCategoryView = categoryScrollView?.contentOffset.y
        
        closeCategoryView(Any.self)
    }
    
    @IBAction func closeCategoryView(_ sender: Any) {
        UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: { [self] in
            categoryChooseView!.isHidden = true
            effectView.isHidden = true
            categoryChooseView?.removeFromSuperview()
            categoryChooseView = nil
        }, completion: nil)
    }
    
    // MARK: - Server Protocol
    
    func closeViewControllersWithUnlogin() {
        DispatchQueue.main.async {
            self.navigationController?.setViewControllers([self], animated: true)
        }
    }
    
    func allTagsWasRecieved() {
        self.sceneLocationView?.removeAllNodes()
        self.textLayers = []
        self.mapView?.removeAnnotations(self.mapView.annotations)
        self.addAnnotations()
        self.addArAnnotations()
    }
    
    func accountWasRecieved() {
        self.accountIsRecieving = false
        server.accountIsRecieving = false
        if userWantsAccount {
            self.removeNotificationView { [self] _ in
                if personalInfo.isAuthorised {
                    let storyboard = UIStoryboard(name: "Accounts", bundle: nil)
                    pushViewController(storyboard: storyboard, identifier: "AccountIfoViewController")
                } else {
                    let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
                    pushViewController(storyboard: storyboard, identifier: "OptionsViewController")
                }
            }
            userWantsAccount = false
        }
        if personalInfo.userAccount?.waitingFriends.count != 0 {
            self.newsIndicator.alpha = 0
            self.newsIndicator.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.newsIndicator.alpha = 0.75
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.newsIndicator.isHidden = true
            }
        }
        Helpers().sortAvailableTags(category: nil) { done in
            self.allTagsWasRecieved()
        }
    }
    
    // MARK: - DistanceUpdater Protocol
    
    func sendPosition() {
        self.distanceUpdater.newLocation(location: (sceneLocationView?.sceneLocationManager.currentLocation))
    }
    
    func changeInfo() {
        updateDistance()
    }
    
    func updateDistance() {
        guard let location = sceneLocationView?.sceneLocationManager.currentLocation else {
            return
        }
        for i in textLayers {
            let tag = globalVariables.listOfAvailableTags.filter({ tag in
                //return tag.tagsId == Int(i.name!)
                return tag.tagsId == Int(i.tag)
            }).first
            //i.string = Helpers().calculateDistance(viewLocation: CLLocation(latitude: tag?.latitude ?? location.coordinate.latitude, longitude: tag?.longitude ?? location.coordinate.longitude), userLocation: location)
            i.text = Helpers().calculateDistance(viewLocation: CLLocation(latitude: tag?.latitude ?? location.coordinate.latitude, longitude: tag?.longitude ?? location.coordinate.longitude), userLocation: location)
        }
    }
    
    // MARK: - Other
    
    func annotationNodeTouched(node: AnnotationNode) {
        impactFeedback.impactOccurred()
        let storyboard = UIStoryboard(name: "Tags", bundle: nil)
        let infoVC = storyboard.instantiateViewController(identifier: "InfoViewController") as! InfoViewController
        infoVC.tag = globalVariables.listOfAvailableTags.first(where: { tag in
            return tag.tagsId == node.id
        })
        infoVC.modalPresentationStyle = .fullScreen
        infoVC.modalTransitionStyle = .crossDissolve
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let annot = globalVariables.listOfAvailableTags.first(where: { tag in
            return tag.latitude == view.annotation?.coordinate.latitude && tag.longitude == view.annotation?.coordinate.longitude
        })
        if annot != nil {
            impactFeedback.impactOccurred()
            let storyboard = UIStoryboard(name: "Tags", bundle: nil)
            let infoVC = storyboard.instantiateViewController(identifier: "InfoViewController") as! InfoViewController
            infoVC.tag = annot
            infoVC.modalPresentationStyle = .fullScreen
            infoVC.modalTransitionStyle = .crossDissolve
            self.navigationController?.pushViewController(infoVC, animated: true)
        }
    }
    
    func locationNodeTouched(node: LocationNode) {
        return
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            setupMapView(animated: true)
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(.followWithHeading, animated: false)
            
            self.sceneLocationView!.locationNodeTouchDelegate = nil
            self.sceneLocationView!.removeFromSuperview()
            self.sceneLocationView = nil
            
            self.sceneLocationView = SceneLocationView()
            self.sceneLocationView!.locationNodeTouchDelegate = self
            self.arVewParent.addSubview(self.sceneLocationView!)
            self.sceneLocationView!.run()
            self.sceneLocationView?.frame = self.arVewParent.bounds
            self.distanceUpdater.startTracking()
            self.arVewParent.addSubview(self.settingsButton)
            self.arVewParent.addSubview(self.newsIndicator)
            self.arVewParent.addSubview(self.plusButton)
            self.arVewParent.addSubview(self.categoriesButton)
            
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.addAnnotations()
            self.addArAnnotations()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
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
                switch manager.authorizationStatus {
                case .authorizedWhenInUse:
                    let alert = Helpers().constructAlert(error: .locationAccuracyAuthorization)
                    self.present(alert, animated: true)
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        mapView.userTrackingMode = .followWithHeading
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

// MARK: - Notification extension

extension Notification.Name {
    static let sessionWasInterrupted = Notification.Name(rawValue: "sessionWasInterrupted")
    static let sessionInterruptionEnded = Notification.Name(rawValue: "sessionInterruptionEnded")
}
