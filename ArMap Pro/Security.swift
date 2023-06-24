//
//  Security.swift
//  ArMap Pro
//
//  Created by Aleksey Ruban on 28.12.2022.
//

import Foundation

struct Security {
    
    static var websiteUrl: String = {
        if !globalVariables.developeMode {
            return "https://armap-design.ru/"
        } else {
            return ""
        }
    }()
    static var serverUrl: String = {
        if !globalVariables.developeMode {
            return ""
        } else {
            return ""
        }
    }()
    
    static var appAccessKeys: Array<String> = {
        if !globalVariables.developeMode {
            return [
                "",
                ""
            ]
        } else {
            return [
                "",
                ""
            ]
        }
    }()
    
    static var appBasicAuthorization: String = {
        if !globalVariables.developeMode {
            let username = ""
            let password = ""
            let loginString = "\(username):\(password)"

            guard let loginData = loginString.data(using: String.Encoding.utf8) else {
                return ""
            }
            let base64LoginString = loginData.base64EncodedString()
            
            return "Basic \(base64LoginString)"
        } else {
            let username = ""
            let password = ""
            let loginString = "\(username):\(password)"

            guard let loginData = loginString.data(using: String.Encoding.utf8) else {
                return ""
            }
            let base64LoginString = loginData.base64EncodedString()
            
            return "Basic \(base64LoginString)"
        }
    }()
    
}
