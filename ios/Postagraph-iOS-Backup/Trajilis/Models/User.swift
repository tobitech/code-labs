//
//  User.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 03/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

final class User {
    let state: String
    let numOfBlockedUsers: String
    let city: String
    let country: String
    let countryId: String
    let currency: String
    let currencySymbol: String
    let currencyCountry: String
    let distance: String
    let dob: String
    let email: String?
    let firstname: String
    let lastname: String
    let feedCount: String
    var followerCount: String
    var followingCount: String
    var followingStatus: String
    let messageCount: String
    let notificationCount: String
    let notificationEnable: String
    let phone: String?
    var profileImage: String
    let profileImageThumb: String
    let profileImageType: String
    let profileLikeCount: String
    var profileLikeStatus: String
    var profileVideo: String
    var profileVideoThumb: String
    let registrationType: String
    let status: String
    let dialCode: String
    let id: String
    let username: String
    let workAt: String
    let tripsterCount: String
    
    init(json: JSONDictionary) {
        state = json["state"] as? String ?? ""
        numOfBlockedUsers = json["block_user_count"] as? String ?? ""
        city = json["city"] as? String ?? ""
        country = json["country"] as? String ?? ""
        countryId = json["country_id"] as? String ?? ""
        currencySymbol = json["currency_symbol"] as? String ?? ""
        currency = json["currency"] as? String ?? ""
        currencyCountry = json["currency_country"] as? String ?? ""
        distance = json["distance_unit"] as? String ?? ""
        dob = json["dob"] as? String ?? ""
        email = json["email"] as? String ?? ""
        firstname = json["f_name"] as? String ?? ""
        lastname = json["l_name"] as? String ?? ""
        feedCount = json["feed_count"] as? String ?? ""
        followerCount = json["follower_count"] as? String ?? ""
        followingCount = json["following_count"] as? String ?? ""
        followingStatus = json["following_status"] as? String ?? ""
        messageCount = json["message_count"] as? String ?? ""
        notificationCount = json["notification_count"] as? String ?? ""
        notificationEnable = json["notification_enable"] as? String ?? ""
        phone = json["phone"] as? String ?? ""
        profileImage = json["profile_image"] as? String ?? ""
        profileImageThumb = json["profile_image_thumb"] as? String ?? ""
        profileImageType = json["profile_image_type"] as? String ?? ""
        profileLikeCount = json["profile_like_count"] as? String ?? ""
        profileLikeStatus = json["profile_like_status"] as? String ?? ""
        profileVideo = json["profile_video"] as? String ?? ""
        profileVideoThumb = json["profile_video_thumb"] as? String ?? ""
        registrationType = json["registration_type"] as? String ?? ""
        status = json["status"] as? String ?? ""
        dialCode = json["tel_country_code"] as? String ?? ""
        id = json["user_id"] as? String ?? ""
        username = json["user_name"] as? String ?? ""
        workAt = json["work_at"] as? String ?? ""
        tripsterCount =  json["tripster_count"] as? String ?? ""
    }

    var condensedUser: CondensedUser {
        return CondensedUser.init(userImage: profileImage, userId: id, profileImageType: "", username: username, firstName: firstname, lastName: lastname)
    }
}
