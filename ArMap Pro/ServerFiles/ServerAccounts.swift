//
//  ServerAccounts.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 20.07.2021.
//

import UIKit

extension Server {
    
    func singUp(name: String, email: String, password: String, language: String, avatar: String?, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        let request = NSMutableURLRequest()
        request.url = URL(string: globalVariables.serverUrl + "signUp/")
        request.httpMethod = "POST"
        addHeaders(request: request)
        
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldUsePipelining = true
        configuration.timeoutIntervalForResource = 4
        configuration.timeoutIntervalForRequest = 4
        
        let session = URLSession(configuration: configuration)
        
        let dictData = SignUpForm(name: name, email: email, password: password, language: language, avatar: avatar)
        let encoder = JSONEncoder()
        do {
            let dataPost = try encoder.encode(dictData)
            let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                if error == nil && data != nil {
                    do {
                        let decoder = JSONDecoder()
                        let answer = try decoder.decode(ServerAnswer.self, from: data!)
                        DispatchQueue.main.async {
                            completionBlock(answer)
                        }
                    } catch {
                        print("Error in parsing answer in \"singUp\":", error)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 433, success: false))
                        }
                    }
                } else {
                    print("Error in POST method in \"singUp\":", error as Any)
                    DispatchQueue.main.async {
                        completionBlock(ServerAnswer(status: 433, success: false))
                    }
                }
            }
            postTask.resume()
        } catch {
            print("Error in \"singUp\":", error as Any)
            DispatchQueue.main.async {
                completionBlock(ServerAnswer(status: 401, success: false))
            }
        }
    }
    
    func resendCode(email: String, password: String, language: String, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        let request = NSMutableURLRequest()
        request.url = URL(string: globalVariables.serverUrl + "resendEmailCode/")
        request.httpMethod = "POST"
        addHeaders(request: request)
        
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldUsePipelining = true
        configuration.timeoutIntervalForResource = 5
        configuration.timeoutIntervalForRequest = 5
        
        let session = URLSession(configuration: configuration)
        
        let dictData = ResendCodeForm(email: email, password: password, language: language)
        let encoder = JSONEncoder()
        do {
            let dataPost = try encoder.encode(dictData)
            let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                if error == nil && data != nil {
                    do {
                        let decoder = JSONDecoder()
                        let answer = try decoder.decode(ServerAnswer.self, from: data!)
                        DispatchQueue.main.async {
                            completionBlock(answer)
                        }
                    } catch {
                        print("Error in parsing answer in \"resendCode\":", error)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 433, success: false))
                        }
                    }
                } else {
                    print("Error in POST method in \"resendCode\":", error as Any)
                    DispatchQueue.main.async {
                        completionBlock(ServerAnswer(status: 401, success: false))
                    }
                }
            }
            postTask.resume()
        } catch {
            print("Error in \"resendCode\":", error as Any)
            DispatchQueue.main.async {
                completionBlock(ServerAnswer(status: 401, success: false))
            }
        }
        
    }
    
    func confirmEmail(email: String, code: Int, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        let request = NSMutableURLRequest()
        request.url = URL(string: globalVariables.serverUrl + "confirmEmail/")
        request.httpMethod = "POST"
        addHeaders(request: request)
        
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldUsePipelining = true
        configuration.timeoutIntervalForResource = 5
        configuration.timeoutIntervalForRequest = 5
        
        let session = URLSession(configuration: configuration)
        
        let dictData = ConfirmEmailForm(email: email, code: code)
        let encoder = JSONEncoder()
        do {
            let dataPost = try encoder.encode(dictData)
            let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                if error == nil && data != nil {
                    do {
                        let decoder = JSONDecoder()
                        let answer = try decoder.decode(ServerAnswerWithUser.self, from: data!)
                        
                        var avatar: String? = nil
                        if answer.avatar != "" && answer.avatar != nil {
                            avatar = answer.avatar
                        }
                        let user = User(name: answer.name, userId: answer.userId, avatar: avatar, birthYear: answer.birthYear, birthDay: answer.birthDay, birthMounth: answer.birthMounth, permissionBirthdayFriends: answer.permissionBirthdayFriends, permissionBirthdayEveryone: answer.permissionBirthdayEveryone, nickname: answer.nickname, country: answer.country, city: answer.city, permissionCountryCityFriends: answer.permissionCountryCityFriends, permissionCountryCityEveryone: answer.permissionCountryCityEveryone, friends: answer.friends, privateTags: answer.privateTags, permissionPrivateTagsFriends: answer.permissionPrivateTagsFriends, publicTags: answer.publicTags, permissionPublicTagsEveryone: answer.permissionPublicTagsEveryone, achievements: answer.achievements, permissionAchievementsEveryOne: answer.permissionAchievementsEveryOne, isBanned: answer.isBanned, isSuperUser: answer.isSuperUser, mutualFriends: answer.mutualFriends, followers: answer.followers, waitingFriends: answer.waitingFriends, requestToFriends: answer.requestToFriends, commentsCounter: 0)
                        personalInfo.userAccount = user
                        
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(user), forKey:"offlineUserAccount")
                        
                        Helpers().sortAvailableTags(category: nil) { _ in
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: answer.status, success: answer.success))
                            }
                        }
                    } catch {
                        print("Error in parsing answer in \"confirmEmail\":", error)
                        do {
                            let decoder = JSONDecoder()
                            let answer = try decoder.decode(ServerAnswer.self, from: data!)
                            DispatchQueue.main.async {
                                completionBlock(answer)
                            }
                        } catch {
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 433, success: false))
                            }
                        }
                    }
                } else {
                    print("Error in POST method in \"confirmEmail\":", error as Any)
                    DispatchQueue.main.async {
                        completionBlock(ServerAnswer(status: 401, success: false))
                    }
                }
            }
            postTask.resume()
        } catch {
            print("Error in \"confirmEmail\":", error as Any)
            DispatchQueue.main.async {
                completionBlock(ServerAnswer(status: 401, success: false))
            }
        }
        
    }
    
    func signIn(email: String, password: String, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        let request = NSMutableURLRequest()
        request.url = URL(string: globalVariables.serverUrl + "signIn/")
        request.httpMethod = "POST"
        addHeaders(request: request)
        
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldUsePipelining = true
        configuration.timeoutIntervalForResource = 15
        configuration.timeoutIntervalForRequest = 15
        
        let session = URLSession(configuration: configuration)
        
        let dictData = SignInForm(email: email, password: password)
        let encoder = JSONEncoder()
        do {
            Server.shared.accountIsRecieving = true
            let dataPost = try encoder.encode(dictData)
            let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                if error == nil && data != nil {
                    do {
                        let decoder = JSONDecoder()
                        let answer = try decoder.decode(ServerAnswerWithUser.self, from: data!)
                        var avatar: String? = nil
                        if answer.avatar != "" && answer.avatar != nil {
                            avatar = answer.avatar
                        }
                        
                        let user = User(name: answer.name, userId: answer.userId, avatar: avatar, birthYear: answer.birthYear, birthDay: answer.birthDay, birthMounth: answer.birthMounth, permissionBirthdayFriends: answer.permissionBirthdayFriends, permissionBirthdayEveryone: answer.permissionBirthdayEveryone, nickname: answer.nickname, country: answer.country, city: answer.city, permissionCountryCityFriends: answer.permissionCountryCityFriends, permissionCountryCityEveryone: answer.permissionCountryCityEveryone, friends: answer.friends, privateTags: answer.privateTags, permissionPrivateTagsFriends: answer.permissionPrivateTagsFriends, publicTags: answer.publicTags, permissionPublicTagsEveryone: answer.permissionPublicTagsEveryone, achievements: answer.achievements, permissionAchievementsEveryOne: answer.permissionAchievementsEveryOne, isBanned: answer.isBanned, isSuperUser: answer.isSuperUser, mutualFriends: answer.mutualFriends, followers: answer.followers, waitingFriends: answer.waitingFriends, requestToFriends: answer.requestToFriends, commentsCounter: answer.commentsCounter)
                                                
                        personalInfo.userAccount = user
                        personalInfo.isAuthorised = true
                        personalInfo.isOfflineLogin = false
                        
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(user), forKey:"offlineUserAccount")
                        
                        if answer.success && answer.status == 200 {
                            
                            var counter = 0
                            
                            for i in personalInfo.userAccount!.publicTags {
                                var middleMark = 0.0
                                
                                for r in i.reviews ?? [] {
                                    middleMark += Double(r.mark)
                                }
                                
                                middleMark = middleMark / Double(i.reviews!.count)
                                
                                if middleMark > 4.0 { counter += 1 }
                                
                            }
                            
                            if counter >= 10 && !personalInfo.userAccount!.achievements.contains("Good reputation") {
                                self.getAchievement(achievement: "Good reputation") { achievementAnswer in
                                    if achievementAnswer.success && achievementAnswer.status == 200 {
                                        personalInfo.userAccount!.achievements.append("Good reputation")
                                    }
                                }
                            }
                            
                        }
                        
                        Helpers().sortAvailableTags(category: nil) { _ in
                            
                            if globalVariables.maiVCDidLoad {
                                self.delegate?.accountWasRecieved()
                            } else {
                                Server.shared.accountIsRecieving = false
                            }
                            
                            
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: answer.status, success: answer.success))
                            }
                        }

                    } catch {
                        do {
                            let decoder = JSONDecoder()
                            let answer = try decoder.decode(ServerAnswer.self, from: data!)
                            if answer.status == 402 {
                                if personalInfo.isAuthorised && personalInfo.isOfflineLogin {
                                    if globalVariables.maiVCDidLoad {
                                        self.delegate?.accountWasRecieved()
                                    } else {
                                        Server.shared.accountIsRecieving = false
                                    }
                                }
                                personalInfo.emailAddress = nil
                                personalInfo.password = nil
                                personalInfo.isAuthorised = false
                                personalInfo.isOfflineLogin = false
                            }
                            
                            if globalVariables.maiVCDidLoad {
                                self.delegate?.accountWasRecieved()
                            } else {
                                Server.shared.accountIsRecieving = false
                            }
                            
                            DispatchQueue.main.async {
                                completionBlock(answer)
                                return
                            }
                        } catch {
                            if let data = UserDefaults.standard.value(forKey:"offlineUserAccount")as? Data {
                                let userAccount = try? PropertyListDecoder().decode(User.self, from:data)
                                personalInfo.userAccount = userAccount
                                if userAccount != nil {
                                    personalInfo.isAuthorised = true
                                    personalInfo.isOfflineLogin = true
                                    Helpers().sortAvailableTags(category: nil) { done in
                                        
                                        if globalVariables.maiVCDidLoad {
                                            self.delegate?.accountWasRecieved()
                                        } else {
                                            Server.shared.accountIsRecieving = false
                                        }
                                        
                                        DispatchQueue.main.async {
                                            completionBlock(ServerAnswer(status: 401, success: true))
                                        }
                                    }
                                } else {
                                    if globalVariables.maiVCDidLoad {
                                        self.delegate?.accountWasRecieved()
                                    } else {
                                        Server.shared.accountIsRecieving = false
                                    }
                                    
                                    DispatchQueue.main.async {
                                        completionBlock(ServerAnswer(status: 433, success: false))
                                    }
                                }
                            } else {
                                if globalVariables.maiVCDidLoad {
                                    self.delegate?.accountWasRecieved()
                                } else {
                                    Server.shared.accountIsRecieving = false
                                }
                                DispatchQueue.main.async {
                                    completionBlock(ServerAnswer(status: 402, success: false))
                                }
                            }
                        }
                        print("Error in parsing answer in \"signIn\":", error)
                    }
                } else {
                    print("Error in POST method in \"signIn\":", error as Any)
                    if let data = UserDefaults.standard.value(forKey:"offlineUserAccount") as? Data {
                        let userAccount = try? PropertyListDecoder().decode(User.self, from: data)
                        personalInfo.userAccount = userAccount
                        if userAccount != nil {
                            personalInfo.isAuthorised = true
                            personalInfo.isOfflineLogin = true
                            Helpers().sortAvailableTags(category: nil) { done in
                                if globalVariables.maiVCDidLoad {
                                    self.delegate?.accountWasRecieved()
                                } else {
                                    Server.shared.accountIsRecieving = false
                                }
                                
                                DispatchQueue.main.async {
                                    completionBlock(ServerAnswer(status: 401, success: true))
                                }
                            }
                        } else {
                            if globalVariables.maiVCDidLoad {
                                self.delegate?.accountWasRecieved()
                            } else {
                                Server.shared.accountIsRecieving = false
                            }
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 401, success: false))
                            }
                        }
                    } else {
                        if globalVariables.maiVCDidLoad {
                            self.delegate?.accountWasRecieved()
                        } else {
                            Server.shared.accountIsRecieving = false
                        }
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 433, success: false))
                        }
                    }
                }
            }
            postTask.resume()
        } catch {
            print("Error in \"signIn\":", error as Any)
            if let data = UserDefaults.standard.value(forKey:"offlineUserAccount") as? Data {
                let userAccount = try? PropertyListDecoder().decode(User.self, from: data)
                personalInfo.userAccount = userAccount
                if userAccount != nil {
                    personalInfo.isAuthorised = true
                    personalInfo.isOfflineLogin = true
                    Helpers().sortAvailableTags(category: nil) { done in
                        if globalVariables.maiVCDidLoad {
                            self.delegate?.accountWasRecieved()
                        } else {
                            Server.shared.accountIsRecieving = false
                        }
                        
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 401, success: true))
                        }
                    }
                } else {
                    if globalVariables.maiVCDidLoad {
                        self.delegate?.accountWasRecieved()
                    } else {
                        Server.shared.accountIsRecieving = false
                    }
                    DispatchQueue.main.async {
                        completionBlock(ServerAnswer(status: 401, success: false))
                    }
                }
            }
        }
    }
    
    func correctAccount(correctForm: CorrectAccountForm, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "correctAccount/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 8
            configuration.timeoutIntervalForRequest = 8
            
            let session = URLSession(configuration: configuration)
            
            let encoder = JSONEncoder()
            do {
                let dataPost = try encoder.encode(correctForm)
                let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                    if error == nil && data != nil {
                        do {
                            let decoder = JSONDecoder()
                            let answer = try decoder.decode(ServerAnswer.self, from: data!)
                            DispatchQueue.main.async {
                                completionBlock(answer)
                            }
                        } catch {
                            print("Error in parsing answer in \"correctAccount\":", error)
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 433, success: false))
                            }
                        }
                    } else {
                        print("Error in POST method in \"correctAccount\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 401, success: false))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"correctAccount\":", error as Any)
                DispatchQueue.main.async {
                    completionBlock(ServerAnswer(status: 401, success: false))
                }
            }
        }
        
        if personalInfo.isOfflineLogin || correctForm.email == nil {
            DispatchQueue.main.async {
                completionBlock(ServerAnswer(status: 401, success: false))
            }
        } else {
            request()
        }
    }
    
    func deleteAccount(completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "deleteAccount/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 8
            configuration.timeoutIntervalForRequest = 8
            
            let session = URLSession(configuration: configuration)
            
            let deleteForm = SignInForm(email: personalInfo.emailAddress!, password: personalInfo.password!)
            
            let encoder = JSONEncoder()
            do {
                let dataPost = try encoder.encode(deleteForm)
                let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                    if error == nil && data != nil {
                        do {
                            let decoder = JSONDecoder()
                            let answer = try decoder.decode(ServerAnswer.self, from: data!)
                            Helpers().sortAvailableTags(category: nil) { done in
                                DispatchQueue.main.async {
                                    completionBlock(answer)
                                }
                            }
                        } catch {
                            print("Error in parsing answer in \"deleteAccount\":", error)
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 433, success: false))
                            }
                        }
                    } else {
                        print("Error in POST method in \"deleteAccount\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 401, success: false))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"deleteAccount\":", error as Any)
                DispatchQueue.main.async {
                    completionBlock(ServerAnswer(status: 401, success: false))
                }
            }
        }
        
        if personalInfo.isOfflineLogin || (personalInfo.emailAddress == nil || personalInfo.password == nil)  {
            DispatchQueue.main.async {
                completionBlock(ServerAnswer(status: 401, success: false))
            }
        } else {
            request()
        }
    }
    
    func resetPassword(email: String, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        let request = NSMutableURLRequest()
        request.url = URL(string: globalVariables.serverUrl + "resetPassword/\(email)/\(globalVariables.currentLanguage)/")
        request.httpMethod = "GET"
        addHeaders(request: request)
        
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldUsePipelining = true
        configuration.timeoutIntervalForResource = 5
        configuration.timeoutIntervalForRequest = 5
        
        let session = URLSession(configuration: configuration)
        
        let dataTask = session.dataTask(with: request as URLRequest,completionHandler: { data, response, error in
            if error == nil && data != nil {
                do {
                    let decoder = JSONDecoder()
                    let answer = try decoder.decode(ServerAnswer.self, from:data!)
                    DispatchQueue.main.async {
                        completionBlock(answer)
                    }
                } catch {
                    print("Error in parsing answer in \"resetPassword\":", error)
                    DispatchQueue.main.async {
                        completionBlock(ServerAnswer(status: 433, success:false))
                    }
                }
            } else {
                print("Error in POST method in \"resetPassword\":", error as Any)
                DispatchQueue.main.async {
                    completionBlock(ServerAnswer(status: 401, success:false))
                }
            }
        })
        dataTask.resume()
    }
    
    func getAchievement(achievement: String, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "getAchievement/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 5
            configuration.timeoutIntervalForRequest = 5
            
            let session = URLSession(configuration: configuration)
            
            let form = GetAchievementForm(userId: personalInfo.userAccount!.userId, password: personalInfo.password!, achievement: achievement)
            
            let encoder = JSONEncoder()
            do {
                let dataPost = try encoder.encode(form)
                let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                    if error == nil && data != nil {
                        do {
                            let decoder = JSONDecoder()
                            let answer = try decoder.decode(ServerAnswer.self, from: data!)
                            DispatchQueue.main.async {
                                completionBlock(answer)
                            }
                        } catch {
                            print("Error in parsing answer in \"getAchievement\":", error)
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 433, success: false))
                            }
                        }
                    } else {
                        print("Error in POST method in \"getAchievement\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 401, success: false))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"getAchievement\":", error as Any)
                DispatchQueue.main.async {
                    completionBlock(ServerAnswer(status: 401, success: false))
                }
            }
        }

        if personalInfo.isOfflineLogin {
            DispatchQueue.main.async {
                completionBlock(ServerAnswer(status: 401, success: false))
            }
        } else {
            request()
        }
    }
    
    func changeDeviceTokens(data: Data?, refreshAll: Bool = false, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        let request = NSMutableURLRequest()
        request.url = URL(string: globalVariables.serverUrl + "changeDeviceTokens/")
        request.httpMethod = "POST"
        addHeaders(request: request)
        
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldUsePipelining = true
        configuration.timeoutIntervalForResource = 20
        configuration.timeoutIntervalForRequest = 20
        
        let session = URLSession(configuration: configuration)
    
        
        var userId: Int?
        var newToken: String!
        if data != nil {
            newToken = data!.hexString
            guard let userId1 = personalInfo.userAccount?.userId else { return }
            userId = userId1
        } else {
            newToken = ""
            if let data = UserDefaults.standard.value(forKey:"offlineUserAccount") as? Data {
                let userAccount = try? PropertyListDecoder().decode(User.self, from: data)
                userId = userAccount?.userId
            }
        }
        let previousToken = personalInfo.previousToken
        
        if previousToken == newToken {
            DispatchQueue.main.async {
                completionBlock(ServerAnswer(status: 200, success: true))
            }
            return
        }
        
        if refreshAll {
            newToken = previousToken
        }
        
        let form = ChangingDeviceTokens(userId: userId!, previousToken: previousToken, newToken: newToken, refreshAll: refreshAll)
        
        let encoder = JSONEncoder()
        do {
            let dataPost = try encoder.encode(form)
            let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                if error == nil && data != nil {
                    do {
                        let decoder = JSONDecoder()
                        let answer = try decoder.decode(ServerAnswer.self, from: data!)
                        
                        if answer.success == true {
                            if previousToken == "" && newToken != "" {
                                personalInfo.previousToken = newToken
                            } else if previousToken != "" && newToken != "" {
                                personalInfo.previousToken = newToken
                            } else if previousToken != "" && newToken == "" {
                                personalInfo.previousToken = ""
                            }
                        }
                        
                        DispatchQueue.main.async {
                            completionBlock(answer)
                        }
                    } catch {
                        print("Error in parsing answer in \"ChangingDeviceTokens\":", error)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 433, success: false))
                        }
                    }
                } else {
                    print("Error in POST method in \"ChangingDeviceTokens\":", error as Any)
                    DispatchQueue.main.async {
                        completionBlock(ServerAnswer(status: 401, success: false))
                    }
                }
            }
            postTask.resume()
        } catch {
            print("Error in \"ChangingDeviceTokens\":", error as Any)
            DispatchQueue.main.async {
                completionBlock(ServerAnswer(status: 401, success: false))
            }
        }
    }
    
    func autoSignIn(completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        self.signIn(email: personalInfo.emailAddress!, password: personalInfo.password!) { answer in
            print("Sign In function done.")
            print(answer, "signin")
            
            let center = UNUserNotificationCenter.current()
            
            center.getNotificationSettings { settings in
                
                if answer.success {
                    DispatchQueue.main.async {
                        if UIApplication.shared.applicationIconBadgeNumber != 0 {
                            self.clearUnreadNotifications(userId: personalInfo.userAccount!.userId) { answer in
                                if answer.status == 200 {
                                    // Do something
                                }
                            }
                        }
                    }
                    
                    if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional || settings.authorizationStatus == .ephemeral {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    } else if settings.authorizationStatus == .notDetermined {
                        center.requestAuthorization(options: [.sound, .alert, .badge]) { success, error in
                            if error == nil {
                                DispatchQueue.main.async {
                                    UIApplication.shared.registerForRemoteNotifications()
                                }
                            }
                        }
                    }
                } else if answer.status == 402 {
                    
                    self.changeDeviceTokens(data: nil) { answer in
                        print("")
                    }
                }
            }
            
            DispatchQueue.main.async {
                completionBlock(answer)
            }
        }
    }
    
    
}
