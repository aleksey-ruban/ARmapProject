//
//  Server.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 21.06.2021.
//

import UIKit

class Server {
    
    static let shared = Server()
    
    private init() {}
    
    var delegate: ServerProtocol?
    
    public var accountIsRecieving: Bool = false
    
    public func addHeaders(request: NSMutableURLRequest) {
        request.setValue("ios_application_armap user_client", forHTTPHeaderField: "useragent")
        request.setValue(globalVariables.appAccessKeys[0], forHTTPHeaderField: "accesskey1")
        request.setValue(globalVariables.appAccessKeys[1], forHTTPHeaderField: "accesskey2")
        request.setValue(globalVariables.appBasicAuthorization, forHTTPHeaderField: "Authorization")
    }
    
    func getAllTags(completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        if globalVariables.offlineMode {
            if let data = UserDefaults.standard.value(forKey:"offlineTagsList") as? Data {
                let tagsList = try? PropertyListDecoder().decode(Array<Tag>.self, from: data)
                globalVariables.allTags = tagsList ?? []
                
                Helpers().sortAvailableTags(category: nil) { done in
                    self.delegate?.allTagsWasRecieved()
                }
            }
        }
        
        let request = NSMutableURLRequest()
        request.url = URL(string: globalVariables.serverUrl + "getAllTags/")
        request.httpMethod = "GET"
        addHeaders(request: request)
        
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldUsePipelining = true
        configuration.timeoutIntervalForResource = 30
        configuration.timeoutIntervalForRequest = 30
        
        let session = URLSession(configuration: configuration)
        
        let dataTask = session.dataTask(with: request as URLRequest,completionHandler: { data, response, error in
            if error == nil && data != nil {
                
                do {
                    let decoder = JSONDecoder()
                    let answer = try decoder.decode(Array<Tag>.self, from:data!)
                    globalVariables.allTags = answer
                    
                    if globalVariables.offlineMode {
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(answer), forKey:"offlineTagsList")
                    }
                    
                    Helpers().sortAvailableTags(category: nil) { done in
                        self.delegate?.allTagsWasRecieved()
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 200, success: true))
                        }
                    }
                } catch {
                    print("Error in parsing in \"getAllTags\":", error)
                    
                    if globalVariables.offlineMode {
                        if let data = UserDefaults.standard.value(forKey:"offlineTagsList") as? Data {
                            let tagsList = try? PropertyListDecoder().decode(Array<Tag>.self, from: data)
                            globalVariables.allTags = tagsList ?? []
                            
                            Helpers().sortAvailableTags(category: nil) { done in
                                
                                self.delegate?.allTagsWasRecieved()
                                
                                DispatchQueue.main.async {
                                    completionBlock(ServerAnswer(status: 401, success: true))
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 400, success:false))
                        }
                    }
                }
            } else {
                print("Error in POST method in \"getAllTags\":", error as Any)
                if globalVariables.offlineMode {
                    if let data = UserDefaults.standard.value(forKey:"offlineTagsList") as? Data {
                        let tagsList = try? PropertyListDecoder().decode(Array<Tag>.self, from: data)
                        globalVariables.allTags = tagsList ?? []
 
                        Helpers().sortAvailableTags(category: nil) { done in
                            
                            self.delegate?.allTagsWasRecieved()
                            
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 401, success: true))
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completionBlock(ServerAnswer(status: 400, success:false))
                    }
                }
            }
        })
        dataTask.resume()
    }
    
    func getUser(userId: Int, completionBlock: @escaping (Any?) -> Void) -> Void {
        
        let request = NSMutableURLRequest()
        request.url = URL(string: globalVariables.serverUrl + "getUser/\(userId)/")
        request.httpMethod = "GET"
        addHeaders(request: request)
        
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldUsePipelining = true
        configuration.timeoutIntervalForResource = 5
        configuration.timeoutIntervalForRequest = 5
        
        let session = URLSession(configuration: configuration)
        
        let dataTask = session.dataTask(with: request as URLRequest,completionHandler: { data, response, error in
            print("\"getUser\":")
            if error == nil && data != nil {
                
                do {
                    let decoder = JSONDecoder()
                    let answer = try decoder.decode(User.self, from:data!)
                    DispatchQueue.main.async {
                        completionBlock(answer)
                    }
                    
                } catch {
                    print("Error in parsing answer in \"getUser\":", error)
                    DispatchQueue.main.async {
                        completionBlock(ServerAnswer(status: 433, success: false))
                    }
                }
            } else {
                print("Error in POST method in \"getUser\":", error as Any)
                DispatchQueue.main.async {
                    completionBlock(ServerAnswer(status: 401, success: false))
                }
            }
        })
        dataTask.resume()
    }
    
    func tagWasDisplayed(tagsId: Int) {
        
        let request = NSMutableURLRequest()
        request.url = URL(string: globalVariables.serverUrl + "tagWasDisplayed/\(tagsId)/")
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
                    if answer.success {
                        return
                    }
                } catch {
                    print("Error in parsing answer in \"tagWasDisplayed\":", error)
                }
            } else {
                print("Error in POST method in \"tagWasDisplayed\":", error as Any)
            }
        })
        dataTask.resume()
    }

    func writeReview(form: WriteReviewForm, completionBlock: @escaping (ServerAnswerWithReviewsId) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "writeReview/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 5
            configuration.timeoutIntervalForRequest = 5
            
            let session = URLSession(configuration: configuration)
                
            let encoder = JSONEncoder()
            do {
                let dataPost = try encoder.encode(form)
                let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                    if error == nil && data != nil {
                        do {
                            let decoder = JSONDecoder()
                            let answer = try decoder.decode(ServerAnswerWithReviewsId.self, from: data!)
                            if answer.success {
                                personalInfo.userAccount!.commentsCounter += 1
                                
                                if personalInfo.userAccount!.commentsCounter >= 10 {
                                    self.getAchievement(achievement: "Commentator") { achievementAnswer in
                                        if achievementAnswer.success && achievementAnswer.status == 200 {
                                            personalInfo.userAccount!.achievements.append("Commentator")
                                        }
                                    }
                                }
                            }
                            
                            DispatchQueue.main.async {
                                completionBlock(answer)
                            }
                        } catch {
                            print("Error in parsing answer in \"writeReview\":", error)
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswerWithReviewsId(status: 433, success: false, reviewsId: 0))
                            }
                        }
                    } else {
                        print("Error in POST method in \"writeReview\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswerWithReviewsId(status: 401, success: false, reviewsId: 0))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"writeReview\":", error as Any)
                DispatchQueue.main.async {
                    completionBlock(ServerAnswerWithReviewsId(status: 401, success: false, reviewsId: 0))
                }
            }
        }
        
        if personalInfo.isOfflineLogin {
            DispatchQueue.main.async {
                completionBlock(ServerAnswerWithReviewsId(status: 401, success: false, reviewsId: 0))
            }
        } else {
            request()
        }
        
    }
    
    func rewriteReview(form: RewriteReview, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "rewriteReview/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 5
            configuration.timeoutIntervalForRequest = 5
            
            let session = URLSession(configuration: configuration)
                
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
                            print("Error in parsing answer in \"rewriteReview\":", error)
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 433, success: false))
                            }
                        }
                    } else {
                        print("Error in POST method in \"rewriteReview\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 401, success: false))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"rewriteReview\":", error as Any)
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
    
    func deleteReview(email: String, password: String, reviewsId: Int, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "deleteReview/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 5
            configuration.timeoutIntervalForRequest = 5
            
            let session = URLSession(configuration: configuration)
                
            let deleteForm = DeleteForm(email: email, password: password, tagsId: reviewsId)
            
            let encoder = JSONEncoder()
            do {
                let dataPost = try encoder.encode(deleteForm)
                let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                    if error == nil && data != nil {
                        do {
                            let decoder = JSONDecoder()
                            let answer = try decoder.decode(ServerAnswer.self, from: data!)
                            
                            if answer.success {
                                personalInfo.userAccount!.commentsCounter -= 1
                            }
                                
                            DispatchQueue.main.async {
                                completionBlock(answer)
                            }
                        } catch {
                            print("Error in parsing answer in \"deleteReview\":", error)
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 433, success: false))
                            }
                        }
                    } else {
                        print("Error in POST method in \"deleteReview\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 401, success: false))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"deleteReview\":", error as Any)
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
    
    func searchPeople(text: String, completionBlock: @escaping (Any) -> Void) -> Void {
        
        let request = NSMutableURLRequest()
        request.url = URL(string: globalVariables.serverUrl + "searchUsers/\(text)/")
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
                    let answer = try decoder.decode(Array<Friend>.self, from:data!)
                    DispatchQueue.main.async {
                        completionBlock(answer)
                    }
                } catch {
                    print("Error in parsing answer in \"searchPeople\":", error)
                    DispatchQueue.main.async {
                        completionBlock(ServerAnswer(status: 433, success: false))
                    }
                }
            } else {
                print("Error in POST method in \"searchPeople\":", error as Any)
                DispatchQueue.main.async {
                    completionBlock(ServerAnswer(status: 401, success: false))
                }
            }
        })
        dataTask.resume()
    }
    
    func checkVersion(completionBlock: @escaping (Bool, Bool) -> Void) -> Void {
        
        let request = NSMutableURLRequest()
        request.url = URL(string: globalVariables.serverUrl + "app-versions/")
        request.httpMethod = "GET"
        addHeaders(request: request)
        
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldUsePipelining = true
        configuration.timeoutIntervalForResource = 3
        configuration.timeoutIntervalForRequest = 3
        
        let session = URLSession(configuration: configuration)
        
        let dataTask = session.dataTask(with: request as URLRequest,completionHandler: { data, response, error in
            if error == nil && data != nil {
                do {
                    let decoder = JSONDecoder()
                    let answer = try decoder.decode(Dictionary<String, Array<Int>>.self, from:data!)
                    
                    var d = Array<Int>()
                    for i in answer.values {
                        d.append(i[0])
                    }
                    if globalVariables.AppBuild >= d.max()! {
                        DispatchQueue.main.async {
                            completionBlock(false, false)
                        }
                        return
                    }
                    
                    var k = 0
                    var k_notKritic = 0
                    var mversion = ""
                    var mbuild = 0
                    var kritic = false
                    for i in answer {
                        if i.value[0] > mbuild {
                            mbuild = i.value[0]
                            mversion = i.key
                        }
                        if i.value[1] == 1 && i.value[0] > answer[globalVariables.AppVersion]?[0] ?? 0 {
                            k += 1
                            kritic = true
                        } else if i.value[1] == 0 && i.value[0] > answer[globalVariables.AppVersion]?[0] ?? 0 {
                            if !kritic {
                                k_notKritic += 1
                            }
                        }
                    }
                    
                    globalVariables.availableVersion = mversion
                    
                    if k == 0 && k_notKritic == 0 {
                        DispatchQueue.main.async {
                            completionBlock(false, false)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completionBlock(true, kritic)
                        }
                    }
                    
                    
                } catch {
                    print("Error in parsing answer in \"CheckVersions\":", error)
                    DispatchQueue.main.async {
                        completionBlock(false, false)
                    }
                }
            } else {
                print("Error in POST method in \"CheckVersions\":", error as Any)
                DispatchQueue.main.async {
                    completionBlock(false, false)
                }
            }
        })
        dataTask.resume()
        
        
    }

    func clearUnreadNotifications(userId: Int, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "clearUnreadNotifications/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 5
            configuration.timeoutIntervalForRequest = 5
            
            let session = URLSession(configuration: configuration)
            
            let encoder = JSONEncoder()
            do {
                let dataPost = try encoder.encode(ClearNotificationsForm(userId: userId, hostToken: personalInfo.previousToken))
                let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                    if error == nil && data != nil {
                        do {
                            let decoder = JSONDecoder()
                            let answer = try decoder.decode(ServerAnswer.self, from: data!)
                            
                            if answer.success {
                                print(answer, "clear Notifications")
                                DispatchQueue.main.async {
                                    UIApplication.shared.applicationIconBadgeNumber = 0
                                }
                            }
                            
                            DispatchQueue.main.async {
                                completionBlock(answer)
                            }
                        } catch {
                            print("Error in parsing answer in \"clearUnreadNotifications\":", error)
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 433, success: false))
                            }
                        }
                    } else {
                        print("Error in POST method in \"clearUnreadNotifications\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 401, success: false))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"clearUnreadNotifications\":", error as Any)
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
    
}


