//
//  SceneDelegate.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 21.05.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        Server.shared.checkVersion { update, kritic in
            print(update, "update")
            if update {
                globalVariables.kriticUpdate = kritic
                if let windowScene = scene as? UIWindowScene {
                    let window = UIWindow(windowScene: windowScene)
                    let storyboard = UIStoryboard(name: "UpdateApp", bundle: nil)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "update_app")
                    
                    
                    if #available(iOS 15.0, *) {
                        let snapshot = (windowScene.keyWindow?.snapshotView(afterScreenUpdates: true))!
                        rootViewController.view.addSubview(snapshot)
                        window.rootViewController = rootViewController
                        self.window = window
                        window.makeKeyAndVisible()
                        UIView.transition(with: snapshot, duration: 0.4, options: .transitionCrossDissolve, animations: {
                            snapshot.layer.opacity = 0
                        }, completion: { status in
                            snapshot.removeFromSuperview()
                        })
                    } else {
                        window.rootViewController = rootViewController
                        self.window = window
                        window.makeKeyAndVisible()
                    }
                    
                }
            } else {
                if let windowScene = scene as? UIWindowScene {
                    let window = UIWindow(windowScene: windowScene)
                    let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "startMain")
                    
                    if #available(iOS 15.0, *) {
                        let snapshot = (windowScene.keyWindow?.snapshotView(afterScreenUpdates: true))!
                        rootViewController.view.addSubview(snapshot)
                        window.rootViewController = rootViewController
                        self.window = window
                        window.makeKeyAndVisible()
                        UIView.transition(with: snapshot, duration: 0.4, options: .transitionCrossDissolve, animations: {
                            snapshot.layer.opacity = 0
                        }, completion: { status in
                            snapshot.removeFromSuperview()
                        })
                    } else {
                        window.rootViewController = rootViewController
                        self.window = window
                        window.makeKeyAndVisible()
                    }
                    
                }
            }
        }
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        if personalInfo.userAccount != nil {
            DispatchQueue.main.async {
                if UIApplication.shared.applicationIconBadgeNumber != 0 {
                    Server.shared.clearUnreadNotifications(userId: personalInfo.userAccount!.userId) { answer in
                        if answer.status == 200 {
                            // Do something
                        }
                    }
                }
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

