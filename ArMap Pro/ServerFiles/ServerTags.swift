//
//  ServerTags.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 20.07.2021.
//

import Foundation
import MapKit

extension Server {
    
    func addNewTag(tag: Tag, completionBlock: @escaping (AddTagAnswer) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "addNewTag/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 5
            configuration.timeoutIntervalForRequest = 5
            
            let session = URLSession(configuration: configuration)
                
            let encoder = JSONEncoder()
            do {
                let dataPost = try encoder.encode(tag)
                let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                    if error == nil && data != nil {
                        do {
                            let decoder = JSONDecoder()
                            let answer = try decoder.decode(AddTagAnswer.self, from: data!)
                            
                            if answer.success && answer.status == 200 {
                                if personalInfo.userAccount!.privateTags.count + personalInfo.userAccount!.publicTags.count + 1 >= 15 && !personalInfo.userAccount!.achievements.contains("Adept") {
                                    self.getAchievement(achievement: "Adept") { achievementAnswer in
                                        if achievementAnswer.status == 200 {
                                            personalInfo.userAccount!.achievements.append("Adept")
                                        }
                                    }
                                }
                                
                                if !personalInfo.userAccount!.achievements.contains("Incognito") && !tag.showAuthor {
                                
                                    var counter = 0
                                    
                                    for i in personalInfo.userAccount!.privateTags {
                                        if !i.showAuthor {
                                            counter += 1
                                        }
                                    }
                                    for i in personalInfo.userAccount!.publicTags {
                                        if !i.showAuthor {
                                            counter += 1
                                        }
                                    }
                                    
                                    if counter >= 9 {
                                        self.getAchievement(achievement: "Incognito") { achievementAnswer in
                                            if achievementAnswer.status == 200 {
                                                personalInfo.userAccount!.achievements.append("Incognito")
                                            }
                                        }
                                    }
                                }
                            }
     
                            DispatchQueue.main.async {
                                completionBlock(answer)
                            }
                        } catch {
                            print("Error in parsing answer in \"addNewTag\":", error)
                            DispatchQueue.main.async {
                                completionBlock(AddTagAnswer(status: 433, success: false, tagsId: 0))
                            }
                        }
                    } else {
                        print("Error in POST method in \"addNewTag\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(AddTagAnswer(status: 401, success: false, tagsId: 0))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"addNewTag\":", error as Any)
                DispatchQueue.main.async {
                    completionBlock(AddTagAnswer(status: 401, success: false, tagsId: 0))
                }
            }
        }

        if personalInfo.isOfflineLogin {
            DispatchQueue.main.async {
                completionBlock(AddTagAnswer(status: 401, success: false, tagsId: 0))
            }
        } else {
            request()
        }
    }
    
    func correctTag(tag: Tag, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "correctTag/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 5
            configuration.timeoutIntervalForRequest = 5
            
            let session = URLSession(configuration: configuration)
                
            let encoder = JSONEncoder()
            do {
                let dataPost = try encoder.encode(tag)
                let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                    if error == nil && data != nil {
                        do {
                            let decoder = JSONDecoder()
                            let answer = try decoder.decode(ServerAnswer.self, from: data!)
                            
                            if answer.success && answer.status == 200 {
                                if !personalInfo.userAccount!.achievements.contains("Incognito") && !tag.showAuthor {
                                
                                    var counter = 0
                                    
                                    for i in personalInfo.userAccount!.privateTags {
                                        if !i.showAuthor {
                                            counter += 1
                                        }
                                    }
                                    for i in personalInfo.userAccount!.publicTags {
                                        if !i.showAuthor {
                                            counter += 1
                                        }
                                    }
                                    
                                    if counter >= 9 {
                                        self.getAchievement(achievement: "Incognito") { achievementAnswer in
                                            if achievementAnswer.status == 200 {
                                                personalInfo.userAccount!.achievements.append("Incognito")
                                            }
                                        }
                                    }
                                }
                            }
                            
                            DispatchQueue.main.async {
                                completionBlock(answer)
                            }
                        } catch {
                            print("Error in parsing answer in \"correctTag\":", error)
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 433, success: false))
                            }
                        }
                    } else {
                        print("Error in POST method in \"correctTag\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 401, success: false))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"correctTag\":", error as Any)
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
    
    func deleteTag(email: String, password: String, tagsId: Int, completionBlock: @escaping (ServerAnswer) -> Void) -> Void {
        
        func request() {
            let request = NSMutableURLRequest()
            request.url = URL(string: globalVariables.serverUrl + "deleteTag/")
            request.httpMethod = "POST"
            addHeaders(request: request)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpShouldUsePipelining = true
            configuration.timeoutIntervalForResource = 5
            configuration.timeoutIntervalForRequest = 5
            
            let session = URLSession(configuration: configuration)
                
            let deleteForm = DeleteForm(email: email, password: password, tagsId: tagsId)
            
            let encoder = JSONEncoder()
            do {
                let dataPost = try encoder.encode(deleteForm)
                let postTask = session.uploadTask(with: request as URLRequest, from: dataPost) { (data, response, error) in
                    if error == nil && data != nil {
                        do {
                            let decoder = JSONDecoder()
                            let answer = try decoder.decode(ServerAnswer.self, from: data!)
                            DispatchQueue.main.async {
                                completionBlock(answer)
                            }
                        } catch {
                            print("Error in parsing answer in \"deleteTag\":", error)
                            DispatchQueue.main.async {
                                completionBlock(ServerAnswer(status: 433, success: false))
                            }
                        }
                    } else {
                        print("Error in POST method in \"deleteTag\":", error as Any)
                        DispatchQueue.main.async {
                            completionBlock(ServerAnswer(status: 401, success: false))
                        }
                    }
                }
                postTask.resume()
            } catch {
                print("Error in \"deleteTag\":", error as Any)
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
