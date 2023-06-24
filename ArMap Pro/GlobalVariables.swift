//
//  GlobalVariables.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 21.05.2021.
//

import Foundation
import UIKit

struct globalVariables {
    
    static let AppVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    static let AppBuild: Int = Int(Bundle.main.infoDictionary!["CFBundleVersion"] as! String) ?? 0
    
    static var kriticUpdate: Bool = false
    
    static let production: Bool = true
    static var developeMode: Bool {
        get {
            return Bool(UserDefaults.standard.bool(forKey: "developeMode"))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "developeMode")
            UserDefaults.standard.synchronize()
        }
    }
    static var websiteUrl: String = {
        return Security.websiteUrl
    }()
    static var serverUrl: String = {
        return Security.serverUrl
    }()
    static var appAccessKeys: Array<String> = {
        return Security.appAccessKeys
    }()
    static var appBasicAuthorization: String = {
        return Security.appBasicAuthorization
    }()
    
    static var availableVersion: String = ""
    static var maiVCDidLoad: Bool = false
    static var mustShowNewAchievement: Bool = false
    static var mustShowFriendWithID: Int = 0
    static var mustShowFriendsList: Bool = false
    
    static var topScreenLength: CGFloat = 0.0
    static var bottomScreenLength: CGFloat = 0.0
    static var screenHeight: CGFloat = 0.0
    static var screenWidth: CGFloat = 0.0
    /// Safe area with navigation top bar
    static var topSafeAreaLength: CGFloat {
        get {
            return CGFloat(UserDefaults.standard.float(forKey: "topSafeAreaInsets"))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "topSafeAreaInsets")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var isViewDidLoadInMapViewController: Bool = false
    
    static var renderDistance: Int {
        get {
            return UserDefaults.standard.integer(forKey: "distance")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "distance")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var offlineMode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "ofline")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ofline")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var appearanceMode: String {
        get {
            return UserDefaults.standard.string(forKey: "appearance") ?? "system"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "appearance")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var mapType: String {
        get {
            return UserDefaults.standard.string(forKey: "mapType") ?? "standart"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "mapType")
            UserDefaults.standard.synchronize()
        }
    }

    static var showForeignTags: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "showForeignTags")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "showForeignTags")
            UserDefaults.standard.synchronize()
        }
    }
    
    static let categoryList = [
        category(image: UIImage(named: "restaurant")!, enText: "Restaurants", ruText: "Рестораны"),
        category(image: UIImage(systemName: "bed.double.fill")!, enText: "Hotels", ruText: "Отели"),
        category(image: UIImage(named: "london-eye")!, enText: "Entertainments", ruText: "Развлечения"),
        category(image: UIImage(named: "eiffel-tower")!, enText: "Sights", ruText: "Памятники"),
        category(image: UIImage(named: "map")!, enText: "Excursions", ruText: "Экскурсии"),
        category(image: UIImage(named: "coffee-cup")!, enText: "Cafe", ruText: "Кафе"),
        category(image: UIImage(named: "cocktail")!, enText: "Bars", ruText: "Бары"),
        category(image: UIImage(named: "monument")!, enText: "Museums", ruText: "Музеи"),
        category(image: UIImage(named: "mall")!, enText: "Malls", ruText: "Торговые центры"),
        category(image: UIImage(systemName: "cart")!, enText: "Shops", ruText: "Магазины"),
        category(image: UIImage(named: "video-camera")!, enText: "Cinema", ruText: "Кино"),
        category(image: UIImage(named: "beach")!, enText: "Beaches", ruText: "Пляжи"),
        category(image: UIImage(named: "dumbbell")!, enText: "Sport", ruText: "Спорт"),
        category(image: UIImage(systemName: "car.fill")!, enText: "Car rental", ruText: "Аренда авто"),
        category(image: UIImage(named: "mirror-ball")!, enText: "Clubs", ruText: "Клубы"),
        category(image: UIImage(named: "landscape")!, enText: "Parks", ruText: "Парки"),
        category(image: UIImage(systemName: "square.dashed")!, enText: "None", ruText: "Ничего")
    ]
    
    static var achieveemntsList = [
        Achievement(imageName: "high-five-chb", achievedImageName: "high-five", enText: "Friendly", ruText: "Дружелюбный", enDescription: "Add 25 friends", ruDescription: "Добавьте 25 друзей"),
        Achievement(imageName: "idea-chb", achievedImageName: "idea", enText: "Adept", ruText: "Знаток", enDescription: "Create 15 tags", ruDescription: "Создайте 15 меток"),
        Achievement(imageName: "hat-chb", achievedImageName: "hat", enText: "Incognito", ruText: "Инкогнито", enDescription: "Hide your authorship in 10 tags", ruDescription: "Скройте своё авторство в 10 метках"),
        Achievement(imageName: "chat-chb", achievedImageName: "chat", enText: "Commentator", ruText: "Комментатор", enDescription: "Comment tags 10 times", ruDescription: "Прокомментируйте метки 10 раз"),
        Achievement(imageName: "popularity-chb", achievedImageName: "popularity", enText: "Popular", ruText: "Популярный", enDescription: "One of your tags has received more than 1 thousand views", ruDescription: "Одна из ваших меток набрала более 1 тысячи просмотров"),
        Achievement(imageName: "reputation-chb", achievedImageName: "reputation", enText: "Good reputation", ruText: "Хорошая репутация", enDescription: "Ten of your public tags scored above 4", ruDescription: "Десять ваших публичных меток набрали рейтинг выше 4")
    ]
    
    enum userNotification {
        
        case error
        case banned
        case serverOff
        case loading
        case codeTimeOut
        case notAgreePolicy
    }
    
    enum permissionNotification {
        
        case locationAuthorization
        case locationAccuracyAuthorization
        case cameraAuthorization
    }
    
    static var currentLanguage: String = ""
    static let mountnNumberToString = [1:"Jan", 2:"Feb", 3:"Mar", 4:"Apr", 5:"May", 6:"Jun", 7:"Jul", 8:"Aug", 9:"Sep", 10:"Oct", 11:"Nov", 12:"Dec"]
    
    static var shouldSaveTagInAddingViewController: Bool = false
    static var shouldStayOnAccountInfoViewController: Bool = false
    
    static var allTags: [Tag] = []
    static var listOfAvailableTags: [Tag] = []
}

struct personalInfo {
    
    static var isAuthorised: Bool = false
    static var isOfflineLogin: Bool = false
    static var emailAddress: String? {
        get {
            if !globalVariables.developeMode {
                return UserDefaults.standard.string(forKey: "emailAddress")
            } else {
                return UserDefaults.standard.string(forKey: "emailAddressDev")
            }
        }
        set {
            if !globalVariables.developeMode {
                UserDefaults.standard.set(newValue, forKey: "emailAddress")
            } else {
                UserDefaults.standard.set(newValue, forKey: "emailAddressDev")
            }
            UserDefaults.standard.synchronize()
        }
    }
    static var password: String? {
        get {
            if !globalVariables.developeMode {
                return UserDefaults.standard.string(forKey: "password")
            } else {
                return UserDefaults.standard.string(forKey: "passwordDev")
            }
        }
        set {
            if !globalVariables.developeMode {
                UserDefaults.standard.set(newValue, forKey: "password")
            } else {
                UserDefaults.standard.set(newValue, forKey: "passwordDev")
            }
            UserDefaults.standard.synchronize()
        }
    }
    static var userAccount: User?
    
    static var previousToken: String {
        get {
            return UserDefaults.standard.string(forKey: "previousToken") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "previousToken")
            UserDefaults.standard.synchronize()
        }
    }
}

