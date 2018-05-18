//
//  ItemModel.swift
//  Rack
//
//  Created by hyperlink on 23/06/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

enum ObserverType {
    case newPostAdded
    case deleteData
    case updateData
}

class ItemModel: NSObject {

    var caption : String!
    var commentCount : String!
    var displayName : String!
    var height : String! = "0"
    var image : String!
    var thumbnail : String!
    var insertdate : String!
    var isBlock : String!
    var parentItem : ItemModel!
    var itemData   : [ItemModel]!
    //Require to change. For multiple image
    var itemId : String!
    var itemType : String!
    var likeCount : String!
    var loginUserLike : Bool!
    var loginUserComment : Bool!
    var ownerUid : String!
    var profile : String!
    var rackCell : String!
    var repost : String!
    var pinImage: String!
    var repostCount : String!
    var tagDetail : TagDetail!
    var uniqueId : String!
    var userId : String!
    var userLikeCount : String!
    var userName : String!
    var width : String! = "0"
    var commentData : [CommentModel]!
    var loginUserWant : Bool!
    var loginUserRepost : Bool!
    var parentId : String!
    var subParentId : String!
    var shareType : String!
    var createdDuration : String!
    var pass_insertdate : String!
    var dataFromWS : Bool = true
    
    // Rack Folder Data Variables
    var isFolderUpdated: Bool!
    var rackData: ItemModel!
    var rackId : String!
    var rackName : String!
    var rackTimestamp : String!
    var rackImage : String!
    var rackViews : String!
    var rackCategory : String!
    var rackUpdated : String!
    var rackItemId: String!
    var rackitemsData: [ItemModel]!
    
    override init() {
        
    }
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        caption = json["caption"].stringValue
        commentCount = json["comment_count"].stringValue
        displayName = json["display_name"].stringValue
        height = json["height"].stringValue
        image = json["image"].stringValue
        thumbnail = json["image_thumbnail"].stringValue

        insertdate = json["insertdate"].stringValue
        isBlock = json["is_block"].stringValue
        itemData = [ItemModel]()
        let itemDataArray = json["item_data"].arrayValue
        for itemDataJson in itemDataArray{
            itemData.append(ItemModel(fromJson: itemDataJson))
        }
        itemId = json["item_id"].stringValue
        itemType = json["item_type"].stringValue
        likeCount = json["like_count"].stringValue
        loginUserLike = json["login_user_like"].boolValue
        loginUserComment = json["login_user_comment"].boolValue
        loginUserWant = json["login_user_want"].boolValue
        loginUserRepost = json["login_user_repost"].boolValue
        ownerUid = json["owner_uid"].stringValue
        profile = json["profile"].stringValue
        
        rackCell = json["rackCell"].stringValue
        repost = json["repost"].stringValue
        repostCount = json["repost_count"].stringValue
        let tagDetailJson = json["tag_detail"]
        if !tagDetailJson.isEmpty{
            tagDetail = TagDetail(fromJson: tagDetailJson)
        }
        uniqueId = json["unique_id"].stringValue
        userId = json["user_id"].stringValue
        userLikeCount = json["user_like_count"].stringValue
        userName = json["user_name"].stringValue
        width = json["width"].stringValue
        commentData = [CommentModel]()
        let commentDataArray = json["comment_list"].arrayValue
        for commentDataJson in commentDataArray{
            commentData.append(CommentModel(fromJson: commentDataJson))
        }
    
        parentId = json["parent_id"].stringValue
        subParentId = json["sub_parent_id"].stringValue
        shareType = json["share_type"].stringValue
        createdDuration = json["created_duration"].stringValue
        pass_insertdate = json["pass_insertdate"].stringValue
        
        // Setup for handle data for Rack List for profile
        
        rackId = json["rack_id"].stringValue
        rackImage = json["rack_image"].stringValue
        rackName = json["rack_name"].stringValue
        rackTimestamp = json["timestamp"].string
        rackViews = json["rack_views"].stringValue
        rackCategory = json["category"].stringValue
        rackUpdated = json["last_modified"].stringValue
        rackItemId = json["rack_image_item_id"].stringValue
        rackitemsData = [ItemModel]()
        let rackDataArray = json["items"].arrayValue
        for rackDataJson in rackDataArray{
            rackitemsData.append(ItemModel(fromJson: rackDataJson))
        }
        if  self.parentId != "0"  {
            if self.parentId != "" {
                self.parentItem = ItemModel(fromJson: json["parent_item"])
            }
        }
        rackData = ItemModel(fromJson: json["rack"])
        isFolderUpdated = false
        
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if caption != nil{
            dictionary["caption"] = caption
        }
        if commentCount != nil{
            dictionary["comment_count"] = commentCount
        }
        if displayName != nil{
            dictionary["display_name"] = displayName
        }
        if height != nil{
            dictionary["height"] = height
        }
        if image != nil{
            dictionary["image"] = image
        }
        if thumbnail != nil{
            dictionary["thumbnail"] = thumbnail
        }
        if insertdate != nil{
            dictionary["insertdate"] = insertdate
        }
        if isBlock != nil{
            dictionary["is_block"] = isBlock
        }
        if itemData != nil{
            dictionary["item_data"] = itemData
        }
        if itemId != nil{
            dictionary["item_id"] = itemId
        }
        if itemType != nil{
            dictionary["item_type"] = itemType
        }
        if likeCount != nil{
            dictionary["like_count"] = likeCount
        }
        if loginUserLike != nil{
            dictionary["login_user_like"] = loginUserLike
        }
        if loginUserComment != nil{
            dictionary["login_user_comment"] = loginUserComment
        }
        if loginUserWant != nil{
            dictionary["login_user_want"] = loginUserWant
        }
        if loginUserRepost != nil{
            dictionary["login_user_repost"] = loginUserRepost
        }
        if ownerUid != nil{
            dictionary["owner_uid"] = ownerUid
        }
        if profile != nil{
            dictionary["profile"] = profile
        }
        
        if rackCell != nil{
            dictionary["rackCell"] = rackCell
        }
        if repost != nil{
            dictionary["repost"] = repost
        }
        if repostCount != nil{
            dictionary["repost_count"] = repostCount
        }
        if tagDetail != nil{
            dictionary["tag_detail"] = tagDetail.toDictionary()
        }
        if uniqueId != nil{
            dictionary["unique_id"] = uniqueId
        }
        if userId != nil{
            dictionary["user_id"] = userId
        }
        if userLikeCount != nil{
            dictionary["user_like_count"] = userLikeCount
        }
        if userName != nil{
            dictionary["user_name"] = userName
        }
        if width != nil{
            dictionary["width"] = width
        }
        if commentData != nil{
            dictionary["comment_list"] = commentData
        }
        if parentId != nil{
            dictionary["parent_id"] = parentId
        }
        if subParentId != nil{
            dictionary["sub_parent_id"] = subParentId
        }
        if shareType != nil{
            dictionary["share_type"] = shareType
        }
        if createdDuration != nil{
            dictionary["created_duration"] = createdDuration
        }
        
        if createdDuration != nil{
            dictionary["created_duration"] = createdDuration
        }
        if pass_insertdate != nil{
            dictionary["pass_insertdate"] = pass_insertdate
        }
        
        // manage rack folder data
        if isFolderUpdated != nil {
            dictionary["isFolderUpdate"] = isFolderUpdated
        }
        if rackData != nil {
            dictionary["rack"] = rackData
        }
        if rackId != nil{
            dictionary["rack_id"] = rackId
        }
        if rackName != nil{
            dictionary["rack_name"] = rackName
        }
        if rackUpdated != nil{
            dictionary["last_modified"] = rackUpdated
        }
        if rackItemId != nil{
            dictionary["rack_image_item_id"] = rackItemId
        }
        if rackTimestamp != nil {
            dictionary["timestamp"] = rackTimestamp
        }
        if rackViews != nil{
            dictionary["rack_views"] = rackViews
        }
        if rackCategory != nil{
            dictionary["category"] = rackCategory
        }
        if rackImage != nil{
            dictionary["rack_image"] = rackImage
        }
        if rackitemsData != nil{
            dictionary["items"] = rackitemsData
        }
        
        return dictionary
    }

    internal class func modelsFromDictionaryArray(array:[JSON]) -> [ItemModel] {
        var models:[ItemModel] = []
        for item in array
        {
            models.append(ItemModel(fromJson: item))
        }
        return models
    }
    
    internal class func dictArrayFromModelArray(array:[ItemModel]) -> [Dictionary<String,Any>]
    {
        var arrayData : [Dictionary<String,Any>] = []
        for item in array
        {
            arrayData.append(item.toDictionary())
        }
        return arrayData
    }
    
    //MARK: - Helper Method    
    func getInsertDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: self.insertdate) {
            return date
        }
        return nil
    }
    
    func getPassInsertDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: self.pass_insertdate) {
            return date
        }
        return nil
    }
    
    func calculatePostTime() -> String {
        
        guard let insertDate = self.getInsertDate() else {
            return ""
        }
        
        let localDate = insertDate.convertToLocal(sourceDate: insertDate)
        let seconds = Date().timeIntervalSince(localDate)
        return GFunction.shared.conversionSecondsToPostDuration(Int(seconds), formatType: .full)
        
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
    
}


class CommentModel : NSObject {
    var comment : String!
    var commentId : String!
    var displayName : String!
    var userName : String!
    var followersCount : String!
    var followingCount : String!
    var isFollowing : String!
    var isPublic : String!
    var loginFollowersCount : String!
    var loginFollowingCount : String!
    var profile : String!
    var profileThumb : String!
    var rackCount : String!
    var userId : String!
    var viewCount : String!
    var wardrobesImage : String!
    var insertdate : String!
    var createdDuration : String!
    
    override init() {
        
    }
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        comment = json["comment"].stringValue
        commentId = json["comment_id"].stringValue
        displayName = json["display_name"].stringValue
        userName = json["user_name"].stringValue
        followersCount = json["followers_count"].stringValue
        followingCount = json["following_count"].stringValue
        isFollowing = json["is_following"].stringValue
        isPublic = json["is_public"].stringValue
        loginFollowersCount = json["login_followers_count"].stringValue
        loginFollowingCount = json["login_following_count"].stringValue
        profile = json["profile"].stringValue
        
        rackCount = json["rack_count"].stringValue
        userId = json["user_id"].stringValue
        viewCount = json["view_count"].stringValue
        wardrobesImage = json["wardrobes_image"].stringValue
        insertdate = json["insertdate"].stringValue
        createdDuration = json["created_duration"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if comment != nil{
            dictionary["comment"] = comment
        }
        if commentId != nil{
            dictionary["comment_id"] = commentId
        }
        if displayName != nil{
            dictionary["display_name"] = displayName
        }
        if userName != nil{
            dictionary["user_name"] = userName
        }
        if followersCount != nil{
            dictionary["followers_count"] = followersCount
        }
        if followingCount != nil{
            dictionary["following_count"] = followingCount
        }
        if isFollowing != nil{
            dictionary["is_following"] = isFollowing
        }
        if isPublic != nil{
            dictionary["is_public"] = isPublic
        }
        if loginFollowersCount != nil{
            dictionary["login_followers_count"] = loginFollowersCount
        }
        if loginFollowingCount != nil{
            dictionary["login_following_count"] = loginFollowingCount
        }
        if profile != nil{
            dictionary["profile"] = profile
        }
        
        if rackCount != nil{
            dictionary["rack_count"] = rackCount
        }
        if userId != nil{
            dictionary["user_id"] = userId
        }
        if viewCount != nil{
            dictionary["view_count"] = viewCount
        }
        if wardrobesImage != nil{
            dictionary["wardrobes_image"] = wardrobesImage
        }
        if insertdate != nil{
            dictionary["insertdate"] = insertdate
        }
        
        return dictionary
    }
    
    internal class func modelsFromDictionaryArray(array:[JSON]) -> [CommentModel] {
        var models:[CommentModel] = []
        for item in array
        {
            models.append(CommentModel(fromJson: item))
        }
        return models
    }
    
    //MARK: - Helper Method
    func getInsertDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: self.insertdate) {
            return date
        }
        return nil
    }
    
    func calculatePostTime() -> String {
        
        guard let insertDate = self.getInsertDate() else {
            return ""
        }
        
        let localDate = insertDate.convertToLocal(sourceDate: insertDate)
        let seconds = Date().timeIntervalSince(localDate)
        return GFunction.shared.conversionSecondsToPostDuration(Int(seconds), formatType: .short)
        
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
}



