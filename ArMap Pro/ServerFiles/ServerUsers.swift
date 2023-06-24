//
//  ServerUsers.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 20.07.2021.
//

import Foundation

extension Server {
    
    func addFriend(form: AddFriendForm, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "addFriend/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 8
            configuration.timeoutIntervalForRequest = 8
            
            let session = URLSession(configuration: configuration)
                
            let encoder = JSONEncoder()
            do {
                let dataPost = try encoder.encode(form)
                let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                    if error == nil && data != nil {
                        do {
                            let decoder = JSONDecoder()
                            let answer = try decoder.decode(ServerAnswer.self, from: data!)
                            
                            if answer.status == 200 {
                                if personalInfo.userAccount!.friends.count + 1 >= 25 && !personalInfo.userAccount!.achievements.contains("Friendly") {
                                    self.getAchievement(achievement: "Friendly") { achievementAnswer in
                                        if achievementAnswer.success && achievementAnswer.status == 200 {
                                            personalInfo.userAccount?.achievements.append("Friendly")
                                        }
                                    }
                                }
                            }
                            Helpers().sortAvailableTags(category: nil) { done in
                                DispatchQueue.main.async {
                                    completionBlock(answer)
                                }
                            }
                        } catch {
                            print("Error in parsing answer in \"addFriend\":", error)
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 433, success: false))
                            }
                        }
                    } else {
                        print("Error in POST method in \"addFriend\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 401, success: false))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"addFriend\":", error as Any)
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
    
    func refuseFriend(form: AddFriendForm, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "refuseFriend/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 8
            configuration.timeoutIntervalForRequest = 8
            
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
                            print("Error in parsing answer in \"refuseFriend\":", error)
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 433, success: false))
                            }
                        }
                    } else {
                        print("Error in POST method in \"refuseFriend\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 401, success: false))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"refuseFriend\":", error as Any)
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
    
    func sendRequestToFriend(form: AddFriendForm, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "sentRequestToFriend/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 8
            configuration.timeoutIntervalForRequest = 8
            
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
                            print("Error in parsing answer in \"sendRequestToFriend\":", error)
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 433, success: false))
                            }
                        }
                    } else {
                        print("Error in POST method in \"sendRequestToFriend\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 401, success: false))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"sendRequestToFriend\":", error as Any)
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
 
    func deleteFriend(form: AddFriendForm, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "deleteFriend/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 8
            configuration.timeoutIntervalForRequest = 8
            
            let session = URLSession(configuration: configuration)
                
            let encoder = JSONEncoder()
            do {
                let dataPost = try encoder.encode(form)
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
                            print("Error in parsing answer in \"deleteFriend\":", error)
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 433, success: false))
                            }
                        }
                    } else {
                        print("Error in POST method in \"deleteFriend\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 401, success: false))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"deleteFriend\":", error as Any)
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
    
    func cancelRequest(form: AddFriendForm, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "cancelRequest/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 8
            configuration.timeoutIntervalForRequest = 8
            
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
                            print("Error in parsing answer in \"cancelRequest\":", error)
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 433, success: false))
                            }
                        }
                    } else {
                        print("Error in POST method in \"cancelRequest\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 401, success: false))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"cancelRequest\":", error as Any)
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
