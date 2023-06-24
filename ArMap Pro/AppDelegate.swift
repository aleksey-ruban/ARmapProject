//
//  AppDelegate.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 21.05.2021.
//

import UIKit
import NotificationCenter

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    let server = Server.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if globalVariables.production {
            globalVariables.developeMode = false
        }
        
        UNUserNotificationCenter.current().delegate = self
        self.setupCategories()
        
        if globalVariables.renderDistance == 0 {
            globalVariables.renderDistance = 1000
        }
    
        if personalInfo.emailAddress != nil && personalInfo.emailAddress != "" && personalInfo.password != nil && personalInfo.password != "" {
            
            NetworkMonitor.shared.startMonitoring()
            
            server.autoSignIn() { answer in
                print("auto sign in:", answer)
            }
        }
        
        server.getAllTags { answer in
            print(answer, "Get tags list")
        }

        UserDefaults.standard.register(defaults: ["ofline": true])
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        server.changeDeviceTokens(data: deviceToken) { answer in
            return
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError :", error)
        return
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let userId = personalInfo.userAccount?.userId {
            server.clearUnreadNotifications(userId: userId) { _ in
                print("")
            }
        }
        completionHandler([.badge, .banner, .sound])
    }
    
    // MARK: - Notifications Categoreis
    
    func setupCategories() {
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_FRIEND",
            title: NSLocalizedString("ACCEPT_LOC", comment: ""),
            options: [.authenticationRequired])
        let refuseAction = UNNotificationAction(identifier: "REFUSE_FRIEND",
            title: NSLocalizedString("REJECT_LOC", comment: ""),
            options: [.destructive, .authenticationRequired])
        // Define the notification type
        let friendshipCategory =
            UNNotificationCategory(identifier: "FRIENDSHIP_REQUEST",
                                   actions: [acceptAction, refuseAction],
                                   intentIdentifiers: [],
                                   hiddenPreviewsBodyPlaceholder: "",
                                   options: .customDismissAction)
        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([friendshipCategory])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler:
             @escaping () -> Void) {
        
       // Perform the task associated with the action.
       switch response.actionIdentifier {
       case "ACCEPT_FRIEND":
           let userInfo = response.notification.request.content.userInfo
           let recieverID = userInfo["RECIEVER_ID"] as! Int
           let senderID = userInfo["SENDER_ID"] as! Int
           Server.shared.addFriend(form: AddFriendForm(myId: recieverID, userId: senderID)) { answer in
               print(answer)
           }
          break
       case "REFUSE_FRIEND":
           let userInfo = response.notification.request.content.userInfo
           let recieverID = userInfo["RECIEVER_ID"] as! Int
           let senderID = userInfo["SENDER_ID"] as! Int
           Server.shared.refuseFriend(form: AddFriendForm(myId: recieverID, userId: senderID)) { answer in
               print(answer)
           }
          break
       default:
           let userInfo = response.notification.request.content.userInfo
           let identifier = userInfo["OPEN_IDENTIFIER"] as! String
           print(identifier)
           
           if identifier == "NEW_ACHIEVEMENT" {
               globalVariables.mustShowNewAchievement = true
               DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                   globalVariables.mustShowNewAchievement = false
               }
           } else if identifier == "WE_ARE_FRIENDS" {
               let userID = userInfo["NEW_FRIEND_ID"] as! Int
               globalVariables.mustShowFriendWithID = userID
               DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                   globalVariables.mustShowFriendWithID = 0
               }
           } else if identifier == "FRIENDSHIP_REQUEST" {
               globalVariables.mustShowFriendsList = true
               DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                   globalVariables.mustShowNewAchievement = false
               }
           }
       }

       completionHandler()
    }
    
}

