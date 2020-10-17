//
//  TrajilisAPI.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 31/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation
import Moya
import Result
import Alamofire

let kRefreshToken = "com.trajilis.refreshtoken"
let kAccessToken = "com.trajilis.accesstoken"

let APIREQUESTTOKENKEY = "com.trajilis.trajilis"

var S3BucketName: String {
//    return "postagraph"
    if kAppDelegate.isDevEnv {
        return "trajilis"
    } else {
        return "postagraph"
    }
}


var SERVERURL:String  {
    get {
        return Bundle.main.baseUrl ?? ""
//        if kAppDelegate.isDevEnv {
//            return dev_SERVERURL
//        } else {
//            return prod_SERVERURL
//        }
    }
}
var CHAT_URL:String  {
    get {
        return Bundle.main.chatUrl ?? ""
//        if kAppDelegate.isDevEnv {
//            return dev_CHAT_URL
//        } else {
//            return prod_CHAT_URL
//        }
    }
}   
var BOOKINGURL:String  {
    get {
        return Bundle.main.bookingUrl ?? ""
//        if kAppDelegate.isDevEnv {
//            return dev_BOOKINGURL
//        } else {
//            return prod_BOOKINGURL
//        }
    }
}


// PRODUCTION
let prod_SERVERURL = "https://api2.postagraph.com/api/"
let prod_CHAT_URL = "https://api.postagraph.com"
let prod_BOOKINGURL = "https://booking.postagraph.com"


// DEV ENVIRONMENT
let dev_SERVERURL = "https://api2.staging.postagraph.com/api/" // Stage instance
let dev_CHAT_URL = "https://api.staging.postagraph.com"
let dev_BOOKINGURL = "https://booking.staging.postagraph.com"


private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}
private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

let APIProvider = MoyaProvider<TrajilisAPI>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

enum TrajilisAPI: Hashable {
    
    var hashValue: Int {
        return self.path.hashValue
    }
    static func == (lhs: TrajilisAPI, rhs: TrajilisAPI) -> Bool {
        return lhs.path == rhs.path
    }
    
    case deleteSelectedMessageForAll(param: JSONDictionary)
    case deleteSelectedMessage(param: JSONDictionary)
    case searchFollower(param: JSONDictionary)
    case emailAvailability(email: String)
    case countries
    case phoneAvailability(param: JSONDictionary)
    case requestPhoneOTP(param: JSONDictionary)
    case verifyPhone(param: JSONDictionary)
    case verifyUsername(username: String)
    case signup(param: JSONDictionary)
    case states(country: String)
    case cities(state: String, searchText: String)
    case completeProfile(param: JSONDictionary)
    case updateProfileImage(param: JSONDictionary)
    case getUser(userId: String, otherUserId: String)
    case login(param: JSONDictionary)
    case deactivate(userId: String)
    case delete(userId: String)
    case resetPassword(param: JSONDictionary)
    case feeds(userId: String, count: Int, limit: Int)
    case feedsExplore(userId: String, count: Int, limit: Int)
    case likeFeed(param: JSONDictionary)
    case hideFeed(feedId: String, userId: String)
    case deleteFeed(feedId: String, userId: String)
    case reportFeed(feedId: String, userId: String)
    case report(feedId: String, userId: String, type: String)
    case notificationCount(userId: String)
    case notifications(userId: String, count: Int, limit: Int)
    case clearBadge
    case messageCount
    case deleteNotification(id: String)
    case deleteAllNotification
    case markAllNotificationRead
    case userFeed(otherUserId: String, count: Int, limit: Int)
    case blockUser(blockUserId: String)
    case follow(follower: String, following: String, status: String)
    case likeProfile(param: JSONDictionary)
    case placeFeed(placeId: String, count: Int, limit: Int)
    case hashTagFeed(hashTag: String, count: Int, limit: Int)
    case getFollowers(otherUserId: String, count: Int, limit: Int)
    case getFeedViewers(feedId: String, userId: String)
    case getFollowing(otherUserId: String, count: Int, limit: Int)
    case getLikedFeed(userId: String, count: Int, limit: Int)
    case inviteFriendsByEmail(param: JSONDictionary)
    case inviteFriendsByPhoneNo(param: JSONDictionary)
    case updateUserDetail(param: JSONDictionary)
    case updateDeviceToken(param: JSONDictionary)
    case getCurrencyList(userId: String)
    case getBlockedUsers(userId: String)
    case unblockUser(userId: String, unblockUserId: String)
    case deleteUserAccount(userId: String)
    case getChatUsers
    case getChatMessages(groupId: String, count: Int, limit: Int)
    case getSuggestion(count: Int, limit: Int)
    case searchUsers(searchParam: String, count: Int, limit: Int)
    case searchNearbyPlaces(param: JSONDictionary)
    case getTripList(userId: String, invitationStatus: String, count: Int, limit: Int)
    case saveTrip(param: JSONDictionary)
    case searchUserForTrip(param: JSONDictionary)
    case airportSearch(searchText: String)
    case airportByLatLong(lat: String,lng:String)
    case flightSearch(param: JSONDictionary)
    case createFeed(param: JSONDictionary)
    case editFeed(param: JSONDictionary)
    case searchHashTag(searchParam: String, count: Int, limit: Int)
    case searchUserForTag(searchParam: String, count: Int, limit: Int)
    case getCurrentTrips(param: JSONDictionary)
    case createGroup(param: JSONDictionary)
    case searchExplorer(searchParam: String, count: Int, limit: Int)
    case bookability(param: JSONDictionary)
    case bestPricing(param: JSONDictionary)
    case bookFlight(param: JSONDictionary)
    case bookHotel(param: JSONDictionary)
    case flightUpsell(param: JSONDictionary)
    
    case repostFeed(userId: String, feedId: String)
    case likes(feed: String, count: Int, limit: Int)
    case pins(feed: String, count: Int, limit: Int)
    case getComments(feed: String, count: Int, limit: Int)
    case deleteComment(commentId: String,isReply:Bool)
    case likeComment(param: JSONDictionary)
    case getReply(commentId: String, count: Int, limit: Int)
    case saveComment(param: JSONDictionary)
    case saveReply(param: JSONDictionary)
    case getFeed(feedId: String)
    case markNotificationAsRead(notificationId: String)
    case trending(text: String, lng: String, lat: String, count: Int, limit: Int)
    case trendingLocation(text: String, lng: String, lat: String, count: Int, limit: Int)
    case markAsRead(messageId: String,userId:String)
    case deleteMessageByMessageId(messageId: String,userId:String)
    case leaveGroup(groupId: String,userId:String)
    case deleteAllMessage(groupId: String,userId:String)
    case getUserForMsgForward(userId: String,count:String,limit:String)
    case serchUserForMsgForward(param: JSONDictionary)
    case forwardMessage(param: JSONDictionary)
    case manageGroup(param: JSONDictionary)
    case updateGroupName(userId:String,groupId:String,groupName:String)
    case updateGroupImage(param: JSONDictionary)
    case tripsterDetail(id: String)
    case getTripMemories(userid:String,tripId: String, count: Int, limit: Int)
    case getTripPinsMemories(userid:String,tripId: String, count: Int, limit: Int)
    case deleteUserFromTrip(param: JSONDictionary)
    case addFeedViewCount(param: JSONDictionary)
    case pinFeedToTrip(param: JSONDictionary)
    case addUserToTrip(param: JSONDictionary)
    case uploadProfileImage(param: JSONDictionary)
    case uploadProfileVideo(param: JSONDictionary)
    case acceptOrRejectTripInvite(param: JSONDictionary)
    case pendingTripInvite
    case signout
    case refreshToken(refresh:String)
    case deleteGroup(groupId: String,userId:String)
    case deleteTrip(tripId: String,userId:String)
    case trendingTrip(userId: String, count: Int, limit: Int)
    case fareRules(param: JSONDictionary)
    
    // hotels apis
    case citySearch(searchText: String)
    case cityByLatLong(lat: String,lng:String)
    case hotelSearch(param:JSONDictionary)
    case hotelNearby(param:JSONDictionary)
    case hotelDetails(param:JSONDictionary)
    case hotelPricing(param:JSONDictionary)
    case getHotelBookings
    case getFlightBookings
    case getCityFares(param:JSONDictionary)
    case getCityFaresFromNearestLocation(param: JSONDictionary)
    
    //flights
    case getOutbound(param: JSONDictionary)
    case getInbound(param: JSONDictionary)
}
//http://api.stage.trajilis.com/v1/airport?name="test"&lat=3.004&long=0.784
extension TrajilisAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .bestPricing:
            return URL(string: "\(BOOKINGURL)/v1/air/pricing")!
        case .airportSearch(let text):
            //return URL(string: "http://api.stage.trajilis.com/v1/airport?name=\(text.lowercased().encoded())")!
            return URL(string: "\(BOOKINGURL)/v1/airport/search?string=\(text.lowercased().encoded())")!
        case .airportByLatLong(let lat,let lng):
            //return URL(string: "http://api.stage.trajilis.com/v1/coordinate?lat=\(lat)&long=\(lng)")!
            return URL(string: "\(BOOKINGURL)/v1/airport/search?latitude=\(lat)&longitude=\(lng)")!
        case .flightSearch:
            return URL(string: "\(BOOKINGURL)/v1/air/search")!
        case .flightUpsell:
             return URL(string: "\(BOOKINGURL)/v1/air/price/upsell")!
        case .fareRules:
            return URL(string: "\(BOOKINGURL)/v1/air/rules")!
        case .bookability:
            return URL(string: "\(BOOKINGURL)/v1/air/bookable/status")!
        case .bookFlight:
            return URL(string: "\(BOOKINGURL)/v1/air/book")!
        case .getCityFares:
            return URL(string: "\(BOOKINGURL)/v1/air/search/location")!
        case .getCityFaresFromNearestLocation:
            return URL(string: "\(BOOKINGURL)/v1/air/search/to/specified/cities")!
        case .getFlightBookings:
            return URL(string: "\(BOOKINGURL)/v1/air/bookings")!
            // hotels apis
        case .citySearch(let text):
            return URL(string: "\(BOOKINGURL)/v1/hotel/cities/search?string=\(text.lowercased().encoded())")!
        case .cityByLatLong(let lat,let lng):
            return URL(string: "\(BOOKINGURL)/v1/hotel/cities/search?latitude=\(lat)&longitude=\(lng)")!
        case .hotelSearch:
            return URL(string: "\(BOOKINGURL)/v1/hotel/search")!
        case .hotelNearby:
            return URL(string: "\(BOOKINGURL)/v1/hotel/search/location")!
        case .hotelDetails:
            return URL(string: "\(BOOKINGURL)/v1/hotel/details")!
        case .hotelPricing:
            return URL(string: "\(BOOKINGURL)/v1/hotel/enhanced/pricing")!
        case .bookHotel:
            return URL(string: "\(BOOKINGURL)/v1/hotel/book")!
        case .getHotelBookings:
            return URL(string: "\(BOOKINGURL)/v1/hotel/bookings")!
        case .getOutbound, .getInbound:
            return  URL(string: "\(BOOKINGURL)/v1/")!
        default:
            return URL(string: SERVERURL)!
        }
    }


    var userId: String { return UserDefaults.standard.string(forKey: USERID) ?? "" }
    var path: String {
        switch self {
        case .uploadProfileVideo:
            return "User/UpdateProfileVideo"
        case .uploadProfileImage:
            return "User/UpdateProfileImage"
        case .addUserToTrip:
            return "Trip/UpdateTrip"
        case .getTripMemories(let userid ,let tripId, let count, let limit):
            return "Trip/GetTripMemory/\(userid)/\(tripId)/\(count)/\(limit)"
        case .getTripPinsMemories(let userid ,let tripId, let count, let limit):
            return "Trip/GetTripPinMemory/\(userid)/\(tripId)/\(count)/\(limit)"
        case .tripsterDetail(let id):
            return "Trip/GetTripDetail/\(userId)/\(id)"
        case .trendingLocation(let text, let lng, let lat, let count, let limit):
            return "search/GetTrends/\(userId)/\(text.encoded())/\(lat)/\(lng)/\(count)/\(limit)"
        case .trending(let text, let lng, let lat, let count, let limit):
            return "Search/SearchTranding/\(userId)/\(text.encoded())/\(lat)/\(lng)/\(count)/\(limit)"
        case .markNotificationAsRead(let notificationId):
            return "Notification/MarkAsRead/\(userId)/\(notificationId)"
        case .getFeed(let feedId):
            return "Feed/GetFeedDetail/\(userId)/\(feedId)"
        case .saveReply:
            return "Comment/SaveCommentReply"
        case .saveComment:
            return "Comment/SaveComment"
        case .getReply(let commentId, let count, let limit):
            return "Comment/GetCommentsReply/\(userId)/\(commentId)/\(count)/\(limit)"
        case .likeComment:
            return "Like/LikeComment"
        case .getComments(let feed, let count, let limit):
            return "Comment/GetComments/\(userId)/\(feed.encoded())/\(count)/\(limit)"
        case .deleteComment(let commentId,let isReply):
            if (isReply) {
                return "Comment/DeleteCommentReply/\(userId)/\(commentId)"
            } else {
                return "Comment/DeleteComment/\(userId)/\(commentId)"
            }
        case .likes(let feed, let count, let limit):
            return "Like/GetLikerList/\(userId)/\(feed.encoded())/\(count)/\(limit)"
        case .pins(let feed, let count, let limit):
            return "Feed/GetPinUserList/\(userId)/\(feed.encoded())/\(count)/\(limit)"
        case .bookFlight,.getCityFares, .getCityFaresFromNearestLocation:
            return ""
        case .bestPricing:
            return ""
        case .bookability:
            return ""
        case .searchExplorer(let searchParam, let count, let limit):
            return "User/SearchUserForExplorer/\(userId)/\(searchParam.encoded())/\(count)/\(limit)"
        case .createGroup:
            return "Chat/CreateGroup"
        case .getCurrentTrips:
            return "Trip/GetCurrentTrips"
        case .searchUserForTag(let searchParam, let count, let limit):
            return "User/SearchUserForTag/\(userId)/\(searchParam.encoded())/\(count)/\(limit)"
        case .searchHashTag(let searchParam, let count, let limit):
            return "Search/SearchHashTag/\(userId)/\(searchParam.encoded())/\(count)/\(limit)"
        case .createFeed:
            return "Feed/SaveFeed"
        case .editFeed:
            return "Feed/EditFeed"
        case .flightSearch:
            return ""
        case .flightUpsell, .fareRules:
            return ""
        case .airportSearch,.citySearch,.cityByLatLong,.hotelSearch,.hotelDetails,.hotelNearby,.hotelPricing,.bookHotel,.getHotelBookings,.getFlightBookings:
            return ""
        case .airportByLatLong:
            return ""
        case .getChatMessages(let groupId, let count, let limit):
            if groupId.isEmpty {
                return "Chat/GetChatMessages/\(userId)/\(count)/\(limit)"
            } else {
                return "Chat/GetChatMessages/\(userId)/\(groupId)/\(count)/\(limit)"
            }
        case .searchFollower:
            return "Connects/GetSearchFollowings"
        case .getChatUsers:
            return "Chat/GetChatUsers/\(userId)"
        case .getLikedFeed(let userId, let count, let limit):
            return "Feed/GetLikedFeed/\(userId)/\(count)/\(limit)"
        case .getFollowing(let otherUserId, let count, let limit):
            return "Connects/GetFollowings/\(userId)/\(otherUserId)/\(count)/\(limit)"
        case .getFollowers(let otherUserId, let count, let limit):
            return "Connects/GetFollowers/\(userId)/\(otherUserId)/\(count)/\(limit)"
        
        case .getFeedViewers(let feedId, let userId):
            return "User/GetUserForFeedViews/\(feedId)/\(userId)"
        case .hashTagFeed(let hashTag, let count, let limit):
            return "Feed/GetFeedsByHashtag/\(userId)/\(hashTag)/\(count)/\(limit)"
        case .placeFeed(let placeId, let count, let limit):
            return "Feed/GetPlaceFeed/\(userId)/\(placeId)/\(count)/\(limit)"
        case .likeProfile:
            return "Like/LikeUserProfile"
        case .follow(let follower, let following, let status):
            return "Connects/FollowUser/\(follower)/\(following)/\(status)"
        case .blockUser(let blockUserId):
            return "User/BlockUser/\(userId)/\(blockUserId)"
        case .userFeed(let otherUserId, let count, let limit):
            if otherUserId.isEmpty {
                return "Feed/GetFeedsForUser/\(userId)/\(userId)/\(count)/\(limit)"
            }
            return "Feed/GetFeedsForUser/\(userId)/\(otherUserId)/\(count)/\(limit)"
        case .markAllNotificationRead:
            return "Notification/MarkAllAsRead/\(userId)"
        case .deleteAllNotification:
            return "Notification/DeleteAllNotification/\(userId)"
        case .deleteNotification(let id):
            return "Notification/DeleteNotification/\(userId)/\(id)"
        case .messageCount:
            return "Chat/GetBadgeCount/\(userId)"
        case .clearBadge:
            return "Notification/ClearBadgeCount/\(userId)"
        case .notifications(let userId, let count, let limit):
            return "Notification/GetNotifications/\(userId)/\(count)/\(limit)"
        case .notificationCount(let userId):
            return "Notification/GetNotificationCount/\(userId)"
        case .reportFeed(let feedId, let userId):
            return "Feed/ReportSpam/\(userId)/\(feedId)/feed"
        case .report(let feedId, let userId, let type):
            return "Feed/ReportSpam/\(userId)/\(feedId)/\(type)"
        case .deleteFeed(let feedId, let userId):
            return "Feed/DeleteFeed/\(userId)/\(feedId)"
        case .hideFeed(let feedId, let userId):
            return "Feed/HideFeed/\(userId)/\(feedId)"
        case .likeFeed:
            return "Like/LikeFeed"
        case .feeds(let userId, let count, let limit):
            if userId.isEmpty {
                return "Feed/GetFeedsForHome/null/\(count)/\(limit)"
            } else {
                return "Feed/GetFeedsForHome/\(userId)/\(count)/\(limit)"
            }
        case .feedsExplore(let userId, let count, let limit):
            if userId.isEmpty {
                return "Feed/GetFeedsForExplore/null/\(count)/\(limit)"
            } else {
                return "Feed/GetFeedsForExplore/\(userId)/\(count)/\(limit)"
            }
        case .resetPassword:
            return "Login/ChangePasswordUsingPhone"
        case .login:
            return "Login/SignIn"
        case .deactivate(let userId):
            return "Login/UserDeactivate/\(userId)"
        case .delete(let userId):
            return "Login/DeleteUserAccount/\(userId)"
        case .getUser(let userId, let otherUserId):
            return "User/GetUserDetail/\(userId)/\(otherUserId)"
        case .updateProfileImage:
            return "User/UpdateProfileImage"
        case .completeProfile:
            return "User/SignUpUpdateUserDeatil"
        case .states(let country):
            return "Geography/GetStatesByCountryId/\(country)"
        case .cities(let state, let searchText):
            return "Geography/SearchCityByStateId/\(state)/\(searchText))"
        case .signup:
            return "Login/UserSignUp"
        case .emailAvailability(let email):
            return "Login/CheckEmailOrPhoneNoAvailability/\(email)"
        case .countries:
            return "Geography/GetCountry"
        case .phoneAvailability:
            return "Login/CheckPhoneAvailabilityWithTeleCountryCode"
        case .requestPhoneOTP:
            return "Login/SendOTPOnPhone"
        case .verifyPhone:
            return "Login/VerifySmsOTP"
        case .verifyUsername(let username):
            return "Login/CheckUserNameAvailability/\(username)"
        case .inviteFriendsByEmail:
            return "User/InviteFriendsByEmail"
        case .inviteFriendsByPhoneNo:
            return "User/InviteFriendsByPhoneNo"
        case .updateUserDetail:
            return "User/UpdateUserDeatil"
        case .updateDeviceToken:
            return "User/UpdateDeviceToken"
        case .getCurrencyList(let userId):
            return "Geography/GetCurrency/\(userId)"
        case .getBlockedUsers(let userId):
            return "User/GetBlockedUser/\(userId)"
        case .unblockUser(let userId, let unblockUser):
            return "User/UnBlockUser/\(userId)/\(unblockUser)"
        case .deleteUserAccount(let userId):
            return "Login/DeleteUserAccount/\(userId)"
        case .getSuggestion(let count, let limit):
            return "Connects/GetExplorerSuggestion/\(userId)/\(count)/\(limit)"
        case .searchUsers(let searchParam, let count, let limit):
            return "User/SearchUsers/\(userId)/\(searchParam.encoded())/\(limit)/\(count)"
        case .searchNearbyPlaces:
            return "/nearbysearch/json"
        case .getTripList(let userId, let inviteStatus, let count, let limit):
            if inviteStatus.isEmpty {
                return "Trip/GetTrip/\(userId)/\(count)/\(limit)"
            } else {
                return "Trip/GetTrip/\(userId)/\(inviteStatus)/\(count)/\(limit)"
            }
        case .trendingTrip(let userId, let count, let limit):
            return "Trip/GetTrendingTrip/\(userId)/\(count)/\(limit)"
        case .saveTrip:
            return "Trip/SaveTrip"
        case .searchUserForTrip:
            return "Trip/SearchUserForTrip"
        case .deleteMessageByMessageId(let messageId,let userId):
            return "Chat/DeleteMessageByMessageId/\(userId)/\(messageId)"
        case .markAsRead(let messageId,let userId):
            return "Chat/MarkAsRead/\(userId)/\(messageId)"
        case .deleteSelectedMessage:
            return "Chat/DeleteSelectedMessage"
        case .deleteSelectedMessageForAll:
            return "Chat/DeleteSelectedMessageForAll"
        case .leaveGroup(let groupId,let userId):
            return "Chat/LeaveGroup/\(userId)/\(groupId)"
        case .deleteAllMessage(let groupId,let userId):
            return "Chat/DeleteAllMessage/\(userId)/\(groupId)"
        case .deleteGroup(let groupId,let userId):
            return "Chat/DeleteGroup/\(userId)/\(groupId)"
            
        case .getUserForMsgForward(let userId,let count,let limit):
            return "Chat/GetUserForMsgForward/\(userId)/\(count)/\(limit)"
        case .serchUserForMsgForward:
            return "Chat/SerchUserForMsgForward"
        case .forwardMessage:
            return "Chat/ForwardMessage"
        case .manageGroup:
            return "Chat/ManageGroup"
        case .updateGroupName(let userId,let groupId,let groupName):
            return "Chat/UpdateGroupName/\(userId)/\(groupId)/\(groupName.encoded())"
        case .updateGroupImage:
            return "Chat/UpdateGroupImage"
        case .deleteUserFromTrip:
            return "Trip/RemoveMemberFromTrip"
        case .acceptOrRejectTripInvite:
            return "Trip/UpdateInvitationStatus"
        case .pendingTripInvite:
            return "Trip/PendingInvitationCount/\(userId)"
        case .deleteTrip(let tripId,let userId):
            return "Trip/DeleteTrip/\(userId)/\(tripId)"
        case .signout:
            return "Login/SignOut/\(userId)"
        case .refreshToken(let refresh):
            return "Login/token/\(refresh)/refresh"
        case .addFeedViewCount:
            return "Feed/Viewed"
        case .pinFeedToTrip:
            return "Trip/SaveTripPin"
        case .repostFeed(let userId, let feedId):
            return "Feed/RepostFeed/\(userId)/\(feedId)"
        case .getOutbound:
            return "air/get/outbound/flights"
        case .getInbound(let param):
            return "air/get/inbound/flights"
        }
    }
    var method: Moya.Method {
        switch self {
        case .emailAvailability, .countries, .verifyUsername,
             .states, .cities, .getUser, .feeds, .hideFeed,.feedsExplore,
             .deleteFeed, .reportFeed, .report, .notificationCount, .notifications,
             .clearBadge, .messageCount, .deleteNotification,
             .deleteAllNotification, .markAllNotificationRead, .userFeed,
             .blockUser, .follow, .placeFeed, .hashTagFeed,
             .getFollowers, .getFollowing, .getLikedFeed, .getCurrencyList, .getBlockedUsers,.getFeedViewers,
             .unblockUser, .deleteUserAccount,.getChatUsers,
             .getChatMessages, .getSuggestion,
             .searchUsers, .searchNearbyPlaces, .getTripList, .airportSearch,.airportByLatLong,
             .searchHashTag, .searchUserForTag, .searchExplorer, .likes, .pins,
             .markAsRead,.leaveGroup,.deleteAllMessage,.updateGroupName,.deleteMessageByMessageId,.refreshToken,
             .getUserForMsgForward,.deleteGroup,.deleteTrip,
             .getComments, .getReply, .getFeed, .markNotificationAsRead, .trending,.deleteComment,
             .trendingLocation, .tripsterDetail, .getTripMemories,.citySearch,.cityByLatLong,.getTripPinsMemories,
             .pendingTripInvite, .signout,.getHotelBookings,.getFlightBookings,
             .trendingTrip, .repostFeed, .deactivate, .delete:

            return .get
        case .requestPhoneOTP, .phoneAvailability, .verifyPhone, .signup,
             .completeProfile, .updateProfileImage, .login,
             .resetPassword, .likeFeed, .likeProfile, .searchFollower, .saveTrip, .searchUserForTrip,
             .inviteFriendsByPhoneNo, .inviteFriendsByEmail, .flightSearch, .flightUpsell, .createFeed,.editFeed,
             .deleteSelectedMessage,.serchUserForMsgForward,.forwardMessage,.manageGroup,.updateGroupImage,
             .likeComment,.deleteSelectedMessageForAll,
             .getCurrentTrips, .createGroup, .bookability, .bestPricing, .bookFlight,.getCityFares, .getCityFaresFromNearestLocation,
             .saveComment, .saveReply, .deleteUserFromTrip, .addUserToTrip,.addFeedViewCount,.pinFeedToTrip,
            .updateUserDetail,.updateDeviceToken, .uploadProfileImage, .uploadProfileVideo,
            .acceptOrRejectTripInvite,.hotelSearch,.hotelNearby,.hotelDetails,.hotelPricing,.bookHotel, .fareRules, .getOutbound, .getInbound:
            return .post
        }
    }
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    var task: Task {
        switch self {
        case .emailAvailability, .countries, .verifyUsername,
             .states, .cities, .getUser, .feeds, .hideFeed,.feedsExplore,
             .deleteFeed, .reportFeed, .report, .notificationCount, .notifications,
             .clearBadge, .messageCount, .deleteNotification,
             .deleteAllNotification, .markAllNotificationRead, .userFeed,
             .blockUser, .follow, .placeFeed, .hashTagFeed,
             .getFollowers, .getFollowing, .getLikedFeed, .getCurrencyList, .getBlockedUsers,.getFeedViewers,
             .unblockUser, .deleteUserAccount,
             .getChatUsers,
             .getChatMessages, .getSuggestion,
             .searchUsers, .searchNearbyPlaces, .getTripList, .airportSearch,.airportByLatLong,
             .searchHashTag, .searchUserForTag, .searchExplorer, .likes, .pins, .markAsRead,.leaveGroup,.deleteAllMessage,.updateGroupName, .getUserForMsgForward,.deleteMessageByMessageId,.refreshToken,.deleteGroup,.deleteTrip,
             .getComments, .getReply, .getFeed, .markNotificationAsRead,.deleteComment,
             .trending, .trendingLocation, .tripsterDetail, .getTripMemories,.citySearch,.cityByLatLong,.getTripPinsMemories,
             .pendingTripInvite, .signout,.getHotelBookings,.getFlightBookings,
             .trendingTrip, .repostFeed, .delete, .deactivate:
            return .requestPlain
            
        case .requestPhoneOTP(let param), .phoneAvailability(let param),
             .verifyPhone(let param), .signup(let param), .completeProfile(let param),
             .updateProfileImage(let param), .login(let param), .resetPassword(let param),
             .likeFeed(let param), .likeProfile(let param), .inviteFriendsByEmail(let param),
             .inviteFriendsByPhoneNo(let param), .updateUserDetail(let param),.updateDeviceToken(let param),
             .searchFollower(let param),.deleteSelectedMessage(let param),.deleteSelectedMessageForAll(let param),
             .saveTrip(param: let param), .searchUserForTrip(let param),
             .flightSearch(let param), .flightUpsell(let param), .createFeed(let param),.editFeed(let param),
             .getCurrentTrips(let param), .createGroup(let param), .bookability(let param),
             .serchUserForMsgForward(let param),
             .forwardMessage(let param),.manageGroup(let param),.updateGroupImage(let param),
             .bestPricing(let param), .bookFlight(let param), .likeComment(let param),.getCityFares(let param), .getCityFaresFromNearestLocation(param: let param),
             .saveComment(let param), .saveReply(let param),
            .deleteUserFromTrip(let param), .addUserToTrip(let param),.addFeedViewCount(let param),.pinFeedToTrip(let param),
            .uploadProfileImage(let param), .uploadProfileVideo(let param),
            .acceptOrRejectTripInvite(let param),.hotelSearch(let param),.hotelNearby(let param),.hotelDetails(let param),.hotelPricing(let param),.bookHotel(let param), .fareRules(let param), .getOutbound(let param), .getInbound(let param):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        }
    }
    var headers: [String: String]? {
        guard let accessToken = UserDefaults.standard.string(forKey: kAccessToken),let refreshToken = UserDefaults.standard.string(forKey: kRefreshToken)  else { return ["x-api-key" : "s1HFf5ES8ZrUQBFs2UeiMtg6oDWGpf5nfPTFwVefrXyahbvQOh"] }
        return [
            "x-api-key" : "s1HFf5ES8ZrUQBFs2UeiMtg6oDWGpf5nfPTFwVefrXyahbvQOh",
            "Authorization": "bearer \(accessToken)",
            "x-access-code": "\(refreshToken)"
        ]
    }
}
