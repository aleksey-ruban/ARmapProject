//
//  Structures.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 21.05.2021.
//

import UIKit

struct category {
    
    var image: UIImage = UIImage()
    var enText: String
    var ruText: String
}

struct User: Codable {
    
    var name: String
    var userId: Int
    
    var avatar: String? = nil
    var birthYear: Int? = nil
    var birthDay: Int? = nil
    var birthMounth: Int? = nil
    var permissionBirthdayFriends: Bool = true
    var permissionBirthdayEveryone: Bool = false
    
    var nickname: String? = nil
    var country: String? = nil
    var city: String? = nil
    var permissionCountryCityFriends: Bool = true
    var permissionCountryCityEveryone: Bool = true
    
    var friends: [Friend]
    var privateTags: [Tag]
    var permissionPrivateTagsFriends: Bool = true
    var publicTags: [Tag]
    var permissionPublicTagsEveryone: Bool = true
    
    var achievements: [String]
    var permissionAchievementsEveryOne: Bool = false
    
    var isBanned: Bool = false
    var isSuperUser: Bool = false

    var mutualFriends: Int = 0
    
    var followers: [Int]
    var waitingFriends: [Friend]
    var requestToFriends: [Int]
    
    var commentsCounter: Int
}

struct Friend: Equatable, Codable {
    
    static func == (lhs: Friend, rhs: Friend) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    var name: String
    var userId: Int
    var avatar: String? = nil
    var nickname: String? = nil
}

struct Achievement: Codable {
    
    var imageName: String
    var achievedImageName: String
    var enText: String
    var ruText: String
    var enDescription: String
    var ruDescription: String
}

struct Tag: Equatable, Codable {
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.tagsId == rhs.tagsId
    }
    
    var latitude: Double
    var longitude: Double
    var altitude: Double
    
    var tagsId: Int
    
    var category: String? = nil
    var photos: [String]
    
    var enName: String? = nil
    var enAddressName: String? = nil
    var enWebsite: String? = nil
    var enDescription: String? = nil
    
    var ruName: String? = nil
    var ruAddressName: String? = nil
    var ruWebsite: String? = nil
    var ruDescription: String? = nil
    
    var workingHoursWeekdays: String? = nil
    var workingHoursWeekends: String? = nil
    var contactNumber: String? = nil
    
    var isPublicAccess: Bool
    var accessLevel: Int
    
    var authorId: Int
    var authorAvatar: String? = nil
    var authorName: String
    var authorNickname: String? = nil 
    
    var reviews: [Review]?
    var views: Int = 0
    
    var showAuthor: Bool 
    
}

struct Review: Codable {
    
    var reviewId: Int
    var authorId: Int
    var authorAvatar: String? = nil
    var authorName: String
    var authorNickname: String? = nil
    var mark: Int
    var date: String
    var text: String
}

struct SignUpForm: Codable {
    
    var name: String
    var email: String
    var password: String
    var language: String
    var avatar: String?
}

struct ServerAnswer: Codable {
    
    var status: Int
    var success: Bool
}

struct ResendCodeForm: Codable {
    
    var email: String
    var password: String
    var language: String
}

struct ProvisoryUserInfo {
    
    var email: String
    var password: String
    var name: String
    var avatar: String?
}

struct ConfirmEmailForm: Codable {
    
    var email: String
    var code: Int
}

struct SignInForm: Codable {
    
    var email: String
    var password: String
}

struct ServerAnswerWithUser: Codable {
    
    var name: String
    var userId: Int
    
    var avatar: String? = nil
    var birthYear: Int? = nil
    var birthDay: Int? = nil
    var birthMounth: Int? = nil
    var permissionBirthdayFriends: Bool = true
    var permissionBirthdayEveryone: Bool = false
    
    var nickname: String? = nil
    var country: String? = nil
    var city: String? = nil
    var permissionCountryCityFriends: Bool = true
    var permissionCountryCityEveryone: Bool = true
    
    var friends: [Friend]
    var privateTags: [Tag]
    var permissionPrivateTagsFriends: Bool = true
    var publicTags: [Tag]
    var permissionPublicTagsEveryone: Bool = true
    var mostPopularTagId: Int? = nil
    var achievements: [String]
    var permissionAchievementsEveryOne: Bool = false
    
    var isBanned: Bool = false
    var isSuperUser: Bool = false

    var mutualFriends: Int = 0
    
    var followers: [Int]
    var waitingFriends: [Friend]
    var requestToFriends: [Int]
    
    var commentsCounter: Int
    
    var status: Int
    var success: Bool
}

struct CorrectAccountForm: Codable {
    
    var email: String?
    var avatar: String?
    var userName: String
    var birthYear: Int
    var birthDay: Int
    var birthMounth: Int
    var nickname: String?
    var country: String?
    var city: String?
    var newPassword: String?
    
    var permissionBirthdayFriends: Bool
    var permissionBirthdayEveryone: Bool
    var permissionCountryCityFriends: Bool
    var permissionCountryCityEveryone: Bool
    var permissionPrivateTagsFriends: Bool
    var permissionPublicTagsEveryone: Bool
    var permissionAchievementsEveryOne: Bool
    
}

struct AddTagAnswer: Codable {
    
    var status: Int
    var success: Bool
    var tagsId: Int
}

struct DeleteForm: Codable {
    
    var email: String
    var password: String
    var tagsId: Int
}

struct AddFriendForm: Codable {
    
    var myId: Int
    var userId: Int
}

struct WriteReviewForm: Codable {
    
    var tagsId: Int
    var authorId: Int
    var mark: Int
    var date: String
    var text: String
}

struct RewriteReview: Codable {
    
    var reviewId: Int
    var mark: Int
    var date: String
    var text: String
}

struct ServerAnswerWithReviewsId: Codable {
    
    var status: Int
    var success: Bool
    var reviewsId: Int
}

struct GetAchievementForm: Codable {
    
    var userId: Int
    var password: String
    var achievement: String
}

struct ChangingDeviceTokens: Codable {
    
    var userId: Int
    var previousToken: String
    var newToken: String
    var refreshAll: Bool
}

struct ClearNotificationsForm: Codable {
    
    var userId: Int
    var hostToken: String
}
