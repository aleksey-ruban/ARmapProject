//
//  OpenMapDirections.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 12.02.2022.
//

import Foundation
import MapKit
import CoreLocation

class OpenMapDirections {
    
    // MARK: - Variables
    
    enum maps {
        case apple   // 1
        case google  // 2
        case yandex  // 3
    }
    
    static var currentApp: maps?
    static var name: String?
    static var coordinates: CLLocationCoordinate2D!
    
    static let googleMapsInstalled: Bool = {
        let appURLScheme = "comgooglemaps://"
      
        guard let appURL = URL(string: appURLScheme) else {
            return false
        }
        
        if UIApplication.shared.canOpenURL(appURL) {
            return true
        } else {
            return false
        }
    }()
    
    static let appleMapsInstalled: Bool = {
        let appURLScheme = "maps://"
      
        guard let appURL = URL(string: appURLScheme) else {
            return false
        }
        
        if UIApplication.shared.canOpenURL(appURL) {
            return true
        } else {
            return false
        }
    }()
    
    static let yandexMapsInstalled: Bool = {
        let appURLScheme = "yandexmaps://"
      
        guard let appURL = URL(string: appURLScheme) else {
            return false
        }
        
        if UIApplication.shared.canOpenURL(appURL) {
            return true
        } else {
            return false
        }
        
    }()
    
    static var defaultMapsApp: String? {
        get {
            return UserDefaults.standard.string(forKey: "defaultMaps")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "defaultMaps")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var usefullMaps: String {
        get {
            return UserDefaults.standard.string(forKey: "usefullMaps") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "usefullMaps")
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - Main Functions
    
    static func analize(in viewController: UIViewController, sourceView: UIView, name: String, coordinates: CLLocationCoordinate2D) {
        
        self.name = name
        self.coordinates = coordinates
        
        if (self.defaultMapsApp == "apple" && self.appleMapsInstalled) || (self.defaultMapsApp == "google" && self.googleMapsInstalled) || (self.defaultMapsApp == "yandex" && self.yandexMapsInstalled) {
            self.usefullMaps = ""
            self.openInMaps(defaultFlag: true)
        } else if defaultMapsApp == nil {
            self.present(in: viewController, sourceView: sourceView, name: name, coordinates: coordinates)
        } else if !self.appleMapsInstalled && !self.yandexMapsInstalled && !self.googleMapsInstalled {
            self.downloadAll(in: viewController, sourceView: sourceView)
        } else {
            switch defaultMapsApp {
            case "apple":
                self.downloadApple(in: viewController, sourceView: sourceView)
            case "google":
                self.downloadGoogle(in: viewController, sourceView: sourceView)
            case "yandex":
                self.downloadYandex(in: viewController, sourceView: sourceView)
            case .none:
                break
            case .some(_):
                break
            }
        }
    }
    
    static func present(in viewController: UIViewController, sourceView: UIView, name: String, coordinates: CLLocationCoordinate2D) {
        
        self.name = name
        self.coordinates = coordinates
        
        let actionSheet = UIAlertController(title: nil, message: NSLocalizedString("CHOOSE_MAPS_APP", comment: ""), preferredStyle: .actionSheet)
        
        if globalVariables.currentLanguage == "ru" {
            actionSheet.addAction(UIAlertAction(title: "Яндекс Карты", style: .default, handler: { _ in
                
                if defaultMapsApp != nil && defaultMapsApp != "yandex" {
                    if usefullMaps.contains("1") || usefullMaps.contains("2") {
                        usefullMaps = "3"
                    } else {
                        if usefullMaps != "333" {
                            usefullMaps += "3"
                        }
                    }
                }
                
                self.currentApp = .yandex
                if self.defaultMapsApp == nil {
                    suggestDefault(in: viewController, sourceView: sourceView)
                } else if usefullMaps == "333" {
                    suggestDefault(in: viewController, sourceView: sourceView)
                } else {
                    if self.yandexMapsInstalled {
                        self.openInMaps()
                    } else {
                        self.downloadYandex(in: viewController, sourceView: sourceView)
                    }
                }
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { _ in
            
            if defaultMapsApp != nil && defaultMapsApp != "google" {
                if usefullMaps.contains("1") || usefullMaps.contains("3") {
                    usefullMaps = "2"
                } else {
                    
                    if usefullMaps != "222" {
                        self.usefullMaps = usefullMaps + "2"
                    }
                }
            }
            
            self.currentApp = .google
            if self.defaultMapsApp == nil {
                suggestDefault(in: viewController, sourceView: sourceView)
            } else if usefullMaps == "222" {
                suggestDefault(in: viewController, sourceView: sourceView)
            } else {
                if self.googleMapsInstalled {
                    self.openInMaps()
                } else {
                    self.downloadGoogle(in: viewController, sourceView: sourceView)
                }
            }
           
        }))
    
        actionSheet.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { _ in
            
            if defaultMapsApp != nil && defaultMapsApp != "apple" {
                if usefullMaps.contains("2") || usefullMaps.contains("3") {
                    usefullMaps = "1"
                } else {
                    if usefullMaps != "111" {
                        usefullMaps += "1"
                    }
                }
            }
            
            self.currentApp = .apple
            if self.defaultMapsApp == nil {
                suggestDefault(in: viewController, sourceView: sourceView)
            }else if usefullMaps == "111" {
                suggestDefault(in: viewController, sourceView: sourceView)
            }  else {
                if self.appleMapsInstalled {
                    self.openInMaps()
                } else {
                    self.downloadApple(in: viewController, sourceView: sourceView)
                }
            }
            
        }))
    
        actionSheet.popoverPresentationController?.sourceRect = sourceView.bounds
        actionSheet.popoverPresentationController?.sourceView = sourceView
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil))
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    static func suggestDefault(in viewController: UIViewController, sourceView: UIView) {
        
        let actionSheet = UIAlertController(title: NSLocalizedString("USE_DEFAULT_MAPS", comment: ""), message: NSLocalizedString("WILL_BE_DEFAULT_MAPS", comment: ""), preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("USE_MAPS", comment: ""), style: .default, handler: { action in
            switch self.currentApp {
            case .yandex:
                self.defaultMapsApp = "yandex"
                usefullMaps = ""
            case .apple:
                self.defaultMapsApp = "apple"
                usefullMaps = ""
            case .google:
                self.defaultMapsApp = "google"
                usefullMaps = ""
            case .none:
                break
            }
            self.openInMaps()
        }))
        
        actionSheet.popoverPresentationController?.sourceRect = sourceView.bounds
        actionSheet.popoverPresentationController?.sourceView = sourceView
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("NO", comment: ""), style: .default, handler: { _ in
            usefullMaps = ""
            self.openInMaps()
        }))
        viewController.present(actionSheet, animated: true, completion: nil)
        
    }
    
    static func openInMaps(defaultFlag: Bool = false) {
        if defaultFlag {
            switch defaultMapsApp {
            case "apple":
                let coordinate = coordinates!
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
                mapItem.name = name
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            case "google":
                let url = URL(string: "comgooglemaps://?daddr=\(String(describing: coordinates.latitude)),\(String(describing: coordinates.longitude))&directionsmode=driving&views=traffic")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            case "yandex":
                let url = URL(string: "yandexmaps://maps.yandex.ru/?pt=\(String(describing: coordinates.longitude)),\(String(describing: coordinates.latitude))&z=14")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            case .none:
                break
            case .some(_):
                break
            }
            
            return
        }
        
        switch self.currentApp {
        case .apple:
            let coordinate = coordinates!
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
            mapItem.name = name
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        case .google:
            let url = URL(string: "comgooglemaps://?daddr=\(String(describing: coordinates.latitude)),\(String(describing: coordinates.longitude))&directionsmode=driving&views=traffic")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case .yandex:
            let url = URL(string: "yandexmaps://maps.yandex.ru/?pt=\(String(describing: coordinates.longitude)),\(String(describing: coordinates.latitude))&z=14")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case .none:
            break
        }
    }
    
    // MARK: - Downloads Functions
    
    static func downloadAll(in viewController: UIViewController, sourceView: UIView) {
        let actionSheet = UIAlertController(title: NSLocalizedString("NO_INSTALLED_MAPS", comment: ""), message: NSLocalizedString("CHOOSE_MAPS_APP_TO_INSTALL", comment: ""), preferredStyle: .alert)
        
        if globalVariables.currentLanguage == "ru" {
            actionSheet.addAction(UIAlertAction(title: "Яндекс карты", style: .default, handler: { action in
                if let url = URL(string: "itms-apps://apple.com/app/id313877526") {
                    UIApplication.shared.open(url)
                }
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { action in
            if let url = URL(string: "itms-apps://apple.com/app/id585027354") {
                UIApplication.shared.open(url)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { action in
            if let url = URL(string: "itms-apps://apple.com/app/id915056765") {
                UIApplication.shared.open(url)
            }
        }))
        
        actionSheet.popoverPresentationController?.sourceRect = sourceView.bounds
        actionSheet.popoverPresentationController?.sourceView = sourceView
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: { _ in
            return
        }))
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    static func downloadYandex(in viewController: UIViewController, sourceView: UIView) {
        let actionSheet = UIAlertController(title: NSLocalizedString("DEFAULT_MAPS_NOT_INSTALLED", comment: ""), message: NSLocalizedString("DO_YOU_WANT_INSTALL", comment: ""), preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("DOWNLAOD_APP", comment: ""), style: .default, handler: { action in
            if let url = URL(string: "itms-apps://apple.com/app/id313877526") {
                UIApplication.shared.open(url)
            }
        }))
        
        actionSheet.popoverPresentationController?.sourceRect = sourceView.bounds
        actionSheet.popoverPresentationController?.sourceView = sourceView
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: { _ in
            return
        }))
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    static func downloadGoogle(in viewController: UIViewController, sourceView: UIView) {
        let actionSheet = UIAlertController(title: NSLocalizedString("DEFAULT_MAPS_NOT_INSTALLED", comment: ""), message: NSLocalizedString("DO_YOU_WANT_INSTALL", comment: ""), preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("DOWNLAOD_APP", comment: ""), style: .default, handler: { action in
            if let url = URL(string: "itms-apps://apple.com/app/id585027354") {
                UIApplication.shared.open(url)
            }
        }))
        
        actionSheet.popoverPresentationController?.sourceRect = sourceView.bounds
        actionSheet.popoverPresentationController?.sourceView = sourceView
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: { _ in
            return
        }))
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    static func downloadApple(in viewController: UIViewController, sourceView: UIView) {
        let actionSheet = UIAlertController(title: NSLocalizedString("DEFAULT_MAPS_NOT_INSTALLED", comment: ""), message: NSLocalizedString("DO_YOU_WANT_INSTALL", comment: ""), preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("DOWNLAOD_APP", comment: ""), style: .default, handler: { action in
            if let url = URL(string: "itms-apps://apple.com/app/id915056765") {
                UIApplication.shared.open(url)
            }
        }))
        
        actionSheet.popoverPresentationController?.sourceRect = sourceView.bounds
        actionSheet.popoverPresentationController?.sourceView = sourceView
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: { _ in
            return
        }))
        viewController.present(actionSheet, animated: true, completion: nil)
    }
}
