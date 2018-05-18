//
//  FollowModel.swift
//  Rack
//
//  Created by hyperlink on 14/06/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class FollowModel: NSObject {

    var displayName : String!
    var followersCount : String!
    var followingCount : String!
    var loginFollowersCount : String!
    var loginFollowingCount : String!
    var isBlock : String!
    var isFollowing : String!
    var isPublic : String!
    var profile : String!
    
    var rackCount : String!
    var requestId : String!
    var status : String!
    var userId : String!
    var userName : String!
    var viewCount : String!
    var wardrobesImage : String!
    
    override init() {
        
    }
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        displayName = json["display_name"].stringValue
        followersCount = json["followers_count"].stringValue
        followingCount = json["following_count"].stringValue
        loginFollowersCount = json["login_followers_count"].stringValue
        loginFollowingCount = json["login_following_count"].stringValue
        isBlock = json["is_block"].stringValue
        isFollowing = json["is_following"].stringValue
        isPublic = json["is_public"].stringValue
        profile = json["profile"].stringValue
        
        rackCount = json["rack_count"].stringValue
        requestId = json["request_id"].stringValue
        status = json["status"].stringValue
        userId = json["user_id"].stringValue
        userName = json["user_name"].stringValue
        viewCount = json["view_count"].stringValue
        wardrobesImage = json["wardrobes_image"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if displayName != nil{
            dictionary["display_name"] = displayName
        }
        if followersCount != nil{
            dictionary["followers_count"] = followersCount
        }
        if followingCount != nil{
            dictionary["following_count"] = followingCount
        }
        if loginFollowersCount != nil{
            dictionary["login_followers_count"] = loginFollowersCount
        }
        if loginFollowingCount != nil{
            dictionary["login_following_count"] = loginFollowingCount
        }
        if isBlock != nil{
            dictionary["is_block"] = isBlock
        }
        if isFollowing != nil{
            dictionary["is_following"] = isFollowing
        }
        if isPublic != nil{
            dictionary["is_public"] = isPublic
        }
        if profile != nil{
            dictionary["profile"] = profile
        }
        
        if rackCount != nil{
            dictionary["rack_count"] = rackCount
        }
        if requestId != nil{
            dictionary["request_id"] = requestId
        }
        if status != nil{
            dictionary["status"] = status
        }
        if userId != nil{
            dictionary["user_id"] = userId
        }
        if userName != nil{
            dictionary["user_name"] = userName
        }
        if viewCount != nil{
            dictionary["view_count"] = viewCount
        }
        if wardrobesImage != nil{
            dictionary["wardrobes_image"] = wardrobesImage
        }
        return dictionary
    }
    
    internal class func modelsFromDictionaryArray(array:[JSON]) -> [FollowModel] {
        var models:[FollowModel] = []
        for item in array
        {
            models.append(FollowModel(fromJson: item))
        }
        return models
    }

    func getUserName() -> String {
        var uName : String = ""
        
        if self.userId == UserModel.currentUser.userId {
            uName = UserModel.currentUser.userName
        } else {
            uName = userName
        }
        
        return uName.replacingOccurrences(of: "@", with: "")
    }
    
    
    
    func getUserProfile() -> String {
        var img : String = ""
        if userId == UserModel.currentUser.userId {
            img = UserModel.currentUser.profile
        } else {
            img = profile
        }
        return img
    }
    
    func isPrivateProfile() -> Bool {
        
        if self.isPublic == profileType.kPrivate.rawValue {
            return true
        } else {
            return false
        }
    }
}
