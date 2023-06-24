//
//  MapViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 21.05.2021.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, ServerProtocol {
    
    @IBOutlet weak var backButton: HighlightView!
    @IBOutlet weak var backButtonChevron: UIImageView!
    @IBOutlet weak var backButtonLabel: UILabel!
    @IBOutlet weak var plusButton: HighlightView!
    @IBOutlet weak var plusButtonImage: UIImageView!
    @IBOutlet weak var plusButtonTop: NSLayoutConstraint!
    @IBOutlet weak var followingButton: HighlightView!
    @IBOutlet weak var followingButtonImage: UIImageView!
    @IBOutlet weak var categoriesButton: HighlightView!
    @IBOutlet weak var categoriesImage: UIImageView!
    @IBOutlet weak var effectView: UIVisualEffectView!
    
    @IBOutlet weak var mapViewTop: NSLayoutConstraint!
    @IBOutlet weak var mapViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var categoryChooseView: UIView?
    var categoryScrollView: UIScrollView?
    
    private var willBeDeinited: Bool = true
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    let selectFeedback = UISelectionFeedbackGenerator()
    
    var locationManager: CLLocationManager?
    
    let server = Server.shared
    
    // MARK: - View's Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        globalVariables.isViewDidLoadInMapViewController = true
        locationManager = CLLocationManager()
        
        server.delegate = self
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        addAnnotations()
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

        var categories = globalVariables.categoryList
        _ = categories.popLast()
        categories.insert(category(image: UIImage(systemName: "square.dashed")!, enText: "All", ruText: "Все"), at: 0)
        
        let curCategory = categories.first(where: { category in
            return category.enText == self.getCurrentCategory()
        })
        
        categoriesImage.image = curCategory!.image
        
        
        setupLocationsServices(followUser: globalVariables.isViewDidLoadInMapViewController)
        globalVariables.isViewDidLoadInMapViewController = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        willBeDeinited = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.removeAnnotations(mapView.annotations)
        if willBeDeinited {
            locationManager?.delegate = nil
            locationManager = nil
            mapView.delegate = nil
            mapView.removeFromSuperview()
            mapView = nil
            server.delegate = nil
        }
    }
    
    // MARK: - Setup View Function
    
    func setupView() {
        backButton.layer.masksToBounds = true
        backButton.layer.cornerRadius = 15
        backButton.backgroundColor = UIColor(named: "mainScreenButtons")
        backButtonChevron.tintColor = UIColor(named: "tintForMainScreenButtons")
        backButtonLabel.textColor = UIColor(named: "tintForMainScreenButtons")
        backButton.alpha = 0.75
        backButton.normalOpacity = 0.75
        backButton.isMainScreenButtons = true
        
        plusButton.layer.masksToBounds = true
        plusButton.layer.cornerRadius = 18
        plusButton.backgroundColor = UIColor(named: "mainScreenButtons")
        plusButton.alpha = 0.75
        plusButtonImage.tintColor = UIColor(named: "tintForMainScreenButtons")
        plusButton.normalOpacity = 0.75
        plusButton.isMainScreenButtons = true
        
        followingButton.layer.masksToBounds = true
        followingButton.layer.cornerRadius = 18
        followingButton.backgroundColor = UIColor(named: "mainScreenButtons")
        followingButtonImage.tintColor = UIColor(named: "tintForMainScreenButtons")
        followingButton.alpha = 0
        followingButton.normalOpacity = 0.75
        followingButton.isMainScreenButtons = true
        
        categoriesButton.layer.masksToBounds = true
        categoriesButton.layer.cornerRadius = 18
        categoriesButton.backgroundColor = UIColor(named: "mainScreenButtons")
        categoriesButton.alpha = 0.75
        categoriesImage.tintColor = UIColor(named: "tintForMainScreenButtons")
        categoriesButton.normalOpacity = 0.75
        categoriesButton.isMainScreenButtons = true
        
        mapView.showsCompass = false
        let compass = MKCompassButton(mapView: mapView)
        compass.translatesAutoresizingMaskIntoConstraints = false
        compass.compassVisibility = .visible
        compass.alpha = 1.0
        compass.heightAnchor.constraint(equalToConstant: 40).isActive = true
        compass.widthAnchor.constraint(equalToConstant: 40).isActive = true
    
        mapView.addSubview(compass)
        compass.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        compass.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16).isActive = true
        
        mapViewTop.isActive = false
        mapViewBottom.isActive = false
        plusButtonTop.isActive = false
        
        mapViewTop = mapView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -globalVariables.topScreenLength)
        mapViewBottom = mapView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: globalVariables.bottomScreenLength)
        plusButtonTop = plusButton.topAnchor.constraint(equalTo: compass.bottomAnchor, constant: 8)
        
        mapViewTop.isActive = true
        mapViewBottom.isActive = true
        plusButtonTop.isActive = true
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addOnLongPresss(gestureRecognizer:)))
        mapView.addGestureRecognizer(gestureRecognizer)

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
    }

    @objc func addOnLongPresss(gestureRecognizer:   UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom:    mapView)
    
            impactFeedback.impactOccurred()
            let storyboard = UIStoryboard(name: "Tags", bundle: nil)
            let addingVC = storyboard.instantiateViewController(identifier:     "AddingAndEditingViewController") as! AddingAndEditingViewController
            addingVC.isEditingTag = false
            addingVC.placingCoordinates = coordinate
            addingVC.modalPresentationStyle = .fullScreen
            addingVC.modalTransitionStyle = .crossDissolve
            
            willBeDeinited = false
            
            self.navigationController?.pushViewController(addingVC,     animated: true)
            
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }
    
    func setupLocationsServices(followUser: Bool = false) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
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
            if locationManager?.accuracyAuthorization == .reducedAccuracy {
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
    }
    
    func setupMapView() {
        mapView.showsScale = false
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.isZoomEnabled = true
        mapView.isPitchEnabled = true
        mapView.isRotateEnabled = true
        mapView.isScrollEnabled = true
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
        var seconds = 0.0
        if globalVariables.listOfAvailableTags.count == 0 {
            seconds = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [self] in

            for pin in globalVariables.listOfAvailableTags {

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
                let location = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                mapAnnotation.coordinate = location
                mapAnnotation.title = name!
                mapAnnotation.accessibilityNavigationStyle = .separate
                self.mapView.addAnnotation(mapAnnotation)
            }
        }
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
            
            willBeDeinited = false
            
            self.navigationController?.pushViewController(infoVC, animated: true)
        }
    }
    
    // MARK: - Actions
    
    func pushViewController(storyboard: UIStoryboard, identifier: String) {
        
        willBeDeinited = false
        
        let VC = storyboard.instantiateViewController(identifier: identifier)
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openAddingViewController(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Tags", bundle: nil)
        pushViewController(storyboard: storyboard, identifier: "AddingAndEditingViewController")
    }
    
    @IBAction func followUser(_ sender: Any) {
        mapView.camera.centerCoordinateDistance = 500
        mapView.camera.pitch = 0
        mapView.setUserTrackingMode(.followWithHeading, animated: false)
        UIView.animate(withDuration: 0.5) {
            self.followingButton.alpha = 0.0
        }
    }
    
    // MARK: - Select Categories Functions
    
    @IBAction func selectCategory(_ sender: Any) {
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
            
            if categories[i].enText == self.getCurrentCategory() {
                imageCatView.tintColor = .systemBlue
                catLabel.textColor = .systemBlue
            }
            
            viewCateg.addSubview(catLabel)
            
            viewCateg.layoutSubviews()
            
            catLabel.frame = CGRect(x: 0, y: categoryScrollWidth / 2 - 36 - categoryScrollWidth / 2 * 0.08, width: categoryScrollWidth / 2, height: 34)
        }

        categoryScrollView!.contentSize = CGSize(width: categoryScrollWidth, height: categoryScrollWidth / 2 * CGFloat(categories.count / 2) + CGFloat(categories.count % 2 * Int(categoryScrollWidth) / 2))
        
        categoryScrollView?.setContentOffset(CGPoint(x: 0.0, y: self.getCurrentContentOffset() ?? 0.0), animated: false)
       
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
        
        self.setCurrentCategory(category: categories[sender.view!.tag].enText)
        
        let curCategory = categories.first(where: { category in
            return category.enText == self.getCurrentCategory()
        })
        
        categoriesImage.image = curCategory!.image
        if curCategory?.enText != "All" {
            Helpers().sortAvailableTags(category: curCategory!.enText) { done in
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.addAnnotations()
            }
        } else {
            Helpers().sortAvailableTags(category: nil) { done in
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.addAnnotations()
            }
        }
        
        self.setCurrentContentOffset(y: categoryScrollView?.contentOffset.y ?? 0.0)
        
        UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: { [self] in
            categoryChooseView!.isHidden = true
            effectView.isHidden = true
            categoryChooseView?.removeFromSuperview()
            categoryChooseView = nil
        }, completion: nil)
    }
    
    @IBAction func closeCategoryView(_ sender: Any) {
        UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: { [self] in
            categoryChooseView!.isHidden = true
            effectView.isHidden = true
            categoryChooseView?.removeFromSuperview()
            categoryChooseView = nil
        }, completion: nil)
    }
    
    func getCurrentCategory() -> String? {
        let currentVC = self.navigationController?.topViewController
        
        guard var viewConstrollers = currentVC?.navigationController?.viewControllers else {
            return nil
        }
        
        _ = viewConstrollers.popLast()
        let mainVC = viewConstrollers.popLast() as! MainViewController
        
        return mainVC.chosenCategory
    }
    
    func setCurrentCategory(category: String) {
        let currentVC = self.navigationController?.topViewController
        
        guard var viewConstrollers = currentVC?.navigationController?.viewControllers else {
            return
        }
        
        _ = viewConstrollers.popLast()
        let mainVC = viewConstrollers.popLast() as! MainViewController
        
        mainVC.chosenCategory = category
    }
    
    func getCurrentContentOffset() -> CGFloat? {
        let currentVC = self.navigationController?.topViewController
        
        guard var viewConstrollers = currentVC?.navigationController?.viewControllers else {
            return nil
        }
        
        _ = viewConstrollers.popLast()
        let mainVC = viewConstrollers.popLast() as! MainViewController
        
        return mainVC.currentContentOffsetCategoryView
    }
    
    func setCurrentContentOffset(y: CGFloat) {
        let currentVC = self.navigationController?.topViewController
        
        guard var viewConstrollers = currentVC?.navigationController?.viewControllers else {
            return
        }
        
        _ = viewConstrollers.popLast()
        let mainVC = viewConstrollers.popLast() as! MainViewController
        
        mainVC.currentContentOffsetCategoryView = y
    }
    
    // MARK: - Server Protocol
    
    func closeViewControllersWithUnlogin() {
        print("")
    }
    
    func allTagsWasRecieved() {
        self.mapView?.removeAnnotations(self.mapView.annotations)
        self.addAnnotations()
    }
    
    func accountWasRecieved() {
        print("")
    }
    
    // MARK: - Other
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            setupMapView()
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(.followWithHeading, animated: false)
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
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        if mode != .followWithHeading {
            UIView.animate(withDuration: 0.5) {
                self.followingButton.alpha = 0.75
            }
        }
    }
    
}
