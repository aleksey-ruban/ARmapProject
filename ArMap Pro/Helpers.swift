//
//  Helpers.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 13.06.2021.
//

import UIKit
import CoreLocation

class Helpers {
    
    func calculateDistance(viewLocation: CLLocation, userLocation: CLLocation) -> String {
        let dist = userLocation.distance(from: viewLocation)
        let dist_value = Int(round(dist / 10) * 10)
        var s = ""
        if 1000 <= dist_value && dist_value <= 9990 {
            let dist_value_km = round(Double(dist_value / 100)) / 10
            if globalVariables.currentLanguage == "ru" {
                s = String(dist_value_km) + " км"
            } else {
                s = String(dist_value_km) + " km"
            }
        } else {
            if globalVariables.currentLanguage == "ru" {
                s = String(dist_value) + " м"
            } else {
                s = String(dist_value) + " m"
            }
        }
        return s
    }
    
    func addShadow(view: UIView?) {
        view?.layer.shadowOffset = CGSize(width: 1, height: 1)
        view?.layer.shadowRadius = 10
        view?.layer.shadowOpacity = 0.09
        view?.layer.shadowColor = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 1.0).cgColor
    }
    
    func imageFromString(string: String?) -> UIImage? {
        if string != nil && string != "" {
            
            let imageData = Data.init(base64Encoded: string!, options: .init(rawValue: 0))
            let image = UIImage(data: imageData!)
            return image!
        }
        return UIImage(systemName: "person.circle.fill")
    }
    
    func stringFromImage(image: UIImage) -> String {
        let string = image.jpegData(compressionQuality: 0.35)?.base64EncodedString()
        return string ?? ""
    }
    
    func isSutableEmail(email: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isSutablePassword(password: String) -> Bool {
        
        let passwordRegEx = "^(?=.*\\d)(?=.*[a-zа-я0-9])(?=.*[A-ZА-Я0-9])[0-9a-zA-Zа-яА-Я!@-]{8,}$"

        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
    
    func sortAvailableTags(category: String?, completionBlock: @escaping (Bool) -> Void) -> Void {
        DispatchQueue.main.async { [self] in
            globalVariables.listOfAvailableTags = globalVariables.allTags.filter({ tag in
                return (((tag.isPublicAccess && ( (tag.accessLevel == 1) || (isUserMyFriend(id: tag.authorId)))) ||
                            (!tag.isPublicAccess && tag.accessLevel == 1 && isUserMyFriend(id: tag.authorId)) || tag.authorId == personalInfo.userAccount?.userId)) && ((category != nil && tag.category == category) || category == nil) 
            })
            
            completionBlock(true)
        }
    }
    
    func sortedTags(allTags: [Tag]) -> [Tag] {
        return allTags.filter { tag in
            return (((tag.isPublicAccess && ( (tag.accessLevel == 1) || (isUserMyFriend(id: tag.authorId)))) ||
                        (!tag.isPublicAccess && tag.accessLevel == 1 && isUserMyFriend(id: tag.authorId)) || tag.authorId == personalInfo.userAccount?.userId) && tag.showAuthor)
        }
    }
    
    func isUserMyFriend(id: Int) -> Bool {
        
        var answer: Bool!
        
        if personalInfo.isAuthorised {
            answer = personalInfo.userAccount!.friends.contains(where: { friend in
                return friend.userId == id
            })
        } else {
            answer = false
        }
        return answer
    }
    
    func constructNotificationView(widthOfScreen: CGFloat, event: globalVariables.userNotification) -> UIView {
        
        let width = widthOfScreen * 0.6
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor(named: "notification")
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20
        
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        switch event {
        case .error:
            
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(imageView)
            
            imageView.heightAnchor.constraint(equalToConstant: width * 0.6 * 0.5).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: width * 0.6 * 0.5).isActive = true
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 18).isActive = true
            
            imageView.image = UIImage(systemName: "exclamationmark.circle.fill")
            imageView.tintColor = UIColor(named: "notificationText")
            imageView.contentMode = .scaleAspectFit
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(label)
            
            label.textAlignment = .center
            label.textColor = UIColor(named: "notificationText")
            label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            label.numberOfLines = 0
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12).isActive = true
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
            
            if globalVariables.currentLanguage == "en" {
                label.text = "An error has occured, try again."
            } else {
                label.text = "Произошла ошибка, попробуйте ещё раз."
            }
            
        case .banned:
            
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(imageView)
            
            imageView.heightAnchor.constraint(equalToConstant: width * 0.6 * 0.5).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: width * 0.6 * 0.5).isActive = true
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 18).isActive = true
            
            imageView.image = UIImage(systemName: "xmark.octagon.fill")
            imageView.tintColor = UIColor(named: "notificationText")
            imageView.contentMode = .scaleAspectFit
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(label)
            
            label.textAlignment = .center
            label.textColor = UIColor(named: "notificationText")
            label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            label.numberOfLines = 0
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12).isActive = true
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
            
            if globalVariables.currentLanguage == "en" {
                label.text = "Your account is banned."
            } else {
                label.text = "Ваш аккаунт заблокирован."
            }

        case .serverOff:
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(imageView)
            
            imageView.heightAnchor.constraint(equalToConstant: width * 0.6 * 0.5).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: width * 0.6 * 0.5).isActive = true
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 18).isActive = true
            
            imageView.image = UIImage(systemName: "exclamationmark.icloud.fill")
            imageView.tintColor = UIColor(named: "notificationText")
            imageView.contentMode = .scaleAspectFit
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(label)
            
            label.textAlignment = .center
            label.textColor = UIColor(named: "notificationText")
            label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            label.numberOfLines = 0
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12).isActive = true
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
            
            if globalVariables.currentLanguage == "en" {
                label.text = "Server isn't available, please, try again later."
            } else {
                label.text = "Сервер недоступен, пожалуйста, попробуйте ещё раз позже."
            }
        case .codeTimeOut:
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(imageView)
            
            imageView.heightAnchor.constraint(equalToConstant: width * 0.6 * 0.5).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: width * 0.6 * 0.5).isActive = true
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 18).isActive = true
            
            imageView.image = UIImage(systemName: "hourglass.bottomhalf.fill")
            imageView.tintColor = UIColor(named: "notificationText")
            imageView.contentMode = .scaleAspectFit
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(label)
            
            label.textAlignment = .center
            label.textColor = UIColor(named: "notificationText")
            label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            label.numberOfLines = 0
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12).isActive = true
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
            
            if globalVariables.currentLanguage == "en" {
                label.text = "The code expired."
            } else {
                label.text = "Время действия кода истекло."
            }
        case .notAgreePolicy:
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(imageView)
            
            imageView.heightAnchor.constraint(equalToConstant: width * 0.6 * 0.5).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: width * 0.6 * 0.5).isActive = true
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 18).isActive = true
            
            imageView.image = UIImage(systemName: "doc.fill")
            imageView.tintColor = UIColor(named: "notificationText")
            imageView.contentMode = .scaleAspectFit
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(label)
            
            label.textAlignment = .center
            label.textColor = UIColor(named: "notificationText")
            label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            label.numberOfLines = 0
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12).isActive = true
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
            
            if globalVariables.currentLanguage == "en" {
                label.text = "Please, read the privacy policy."
            } else {
                label.text = "Пожалуйста, прочтите нашу политику конфиденциальности."
            }
        case .loading:
            
            let indicator = UIActivityIndicatorView()
            indicator.translatesAutoresizingMaskIntoConstraints = false
            
            indicator.style = .medium
            indicator.color = .label
            indicator.startAnimating()
            
            view.removeConstraints(view.constraints)
            view.widthAnchor.constraint(equalToConstant: 56).isActive = true
            view.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
            view.addSubview(indicator)

            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
        
        return view
    }
    
    func ageFromBirthday(year: Int, mounth: Int, day: Int) -> Int {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        var mounthString: String {
            if mounth < 10 {
                return "0\(mounth)"
            } else {
                return "\(mounth)"
            }
        }
        var dayString: String {
            if day < 10 {
                return "0\(day)"
            } else {
                return "\(day)"
            }
        }
        
        let birthdayString = "\(year)" + "\(mounthString)" + "\(dayString)"
        let dateString = dateFormatter.string(from: date)
        
        let currentBirthday = dateFormatter.date(from: "\(dateString.prefix(4))\(birthdayString.suffix(4))")
        
        let calendar = Calendar.current
        
        let difference = calendar.dateComponents([.day], from: currentBirthday!, to: date)
        
        if difference.day! >= 0 {
            return (dateString.prefix(4) as NSString).integerValue - (birthdayString.prefix(4) as NSString).integerValue
        } else {
            return (dateString.prefix(4) as NSString).integerValue - (birthdayString.prefix(4) as NSString).integerValue - 1
        }
    }
    
    func constructAlert(error: globalVariables.permissionNotification) -> UIAlertController {
        
        var alert: UIAlertController!
        
        var title1: String!
        var title2: String!
        
        switch error {
        case .locationAuthorization:
            
            if globalVariables.currentLanguage == "en" {
                title1 = "Access to geolocation"
                title2 = "Please, grant access to geolocation to use the application."
            } else {
                title1 = "Доступ к геолокации"
                title2 = "Пожалуйста, предоставьте доступ к геолокации, чтобы использовать приложение."
            }
            
            alert = UIAlertController(title: title1, message: title2, preferredStyle: .alert)
            
            if globalVariables.currentLanguage == "en" {
                title1 = "Settings"
            } else {
                title1 = "Настройки"
            }
            
            alert.addAction(UIAlertAction(title: title1, style: .default, handler: { action in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }))
            
        case .locationAccuracyAuthorization:
            
            if globalVariables.currentLanguage == "en" {
                title1 = "Low accuracy"
                title2 = "Please, grant higth accuracy of geolocation to use the application."
            } else {
                title1 = "Низкая точность"
                title2 = "Пожалуйста, предоставьте высокую точность геолокации, чтобы использовать приложение."
            }
            
            alert = UIAlertController(title: title1, message: title2, preferredStyle: .alert)
            
            if globalVariables.currentLanguage == "en" {
                title1 = "Settings"
            } else {
                title1 = "Настройки"
            }
            
            alert.addAction(UIAlertAction(title: title1, style: .default, handler: { action in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl)
                    }
            }))
            
        case .cameraAuthorization:
           
            if globalVariables.currentLanguage == "en" {
                title1 = "Access to camera"
                title2 = "Please, grant access to camera to use the application."
            } else {
                title1 = "Доступ к камере"
                title2 = "Пожалуйста, предоставьте доступ к камере, чтобы использовать приложение."
            }
            
            alert = UIAlertController(title: title1, message: title2, preferredStyle: .alert)
            
            if globalVariables.currentLanguage == "en" {
                title1 = "Cancel"
                title2 = "Settings"
            } else {
                title1 = "Отмена"
                title2 = "Настройки"
            }
            
            alert.addAction(UIAlertAction(title: title1, style: .cancel, handler: { action in
                return
            }))
            
            alert.addAction(UIAlertAction(title: title2, style: .default, handler: { action in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl)
                    }
            }))
            
        }

        return alert
    }
    
    
}


extension String {

    func urlEncoded() -> String {
        let charactersToEscape = "!*'();:@&=+$,/?%#[]\" "
        let allowedCharacters = NSCharacterSet(charactersIn: charactersToEscape).inverted

        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
    }
}

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}

final class CustomButton: UIButton {

    private var shadowLayer: CAShapeLayer!

    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
            shadowLayer.fillColor = UIColor.clear.cgColor

            shadowLayer.shadowColor = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 1.0).cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 1, height: 1)
            shadowLayer.shadowOpacity = 0.09
            shadowLayer.shadowRadius = 10
            
            layer.insertSublayer(shadowLayer, at: 0)
            //layer.insertSublayer(shadowLayer, below: nil) // also works
        }
    }

}
