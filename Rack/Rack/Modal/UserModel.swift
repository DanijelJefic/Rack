//  UserModel.swift
//  Rack
//  Created by hyperlink on 06/06/17.
//  Copyright © 2017 Hyperlink. All rights reserved.

import UIKit

class UserModel: NSObject, NSCoding{
    
    var bioTxt         : String! = ""
    var deleted        : String! = ""
    var deviceToken    : String! = ""
    var deviceType     : String! = ""
    var displayName    : String! = ""
    var email          : String! = ""
    var fbId           : String! = ""
    var fogotpwdToken  : String! = ""
    var followersCount : String! = ""
    var followingCount : String! = ""
    var forgotpwdDate  : String! = ""
    var userId         : String! = ""
    var insertdate     : String! = ""
    var isFollowing    : String! = ""
    var lastLogin      : String! = ""
    var login          : String! = ""
    var loginType      : String! = ""
    var owner          : String! = ""
    var password       : String! = ""
    var profile        : String! = ""
    var isPublic       : String! = ""
    var rackCount      : String! = ""
    var showRack       : String! = ""
    var signupStatus   : String! = ""
    var status         : String! = ""
    var token          : String! = ""
    var userName       : String! = ""
    var verify         : String! = ""
    var viewCount      : String! = ""
    var wardrobesImage : String! = ""
    var requestStatus  : String! = ""
    var coverImage     : UIImage! = nil
    var settings       : UserSettings! = nil

    static var currentUser : UserModel = UserModel()
    override init() {
        
        
    }

    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        bioTxt = json["bio_txt"].stringValue
        deleted = json["deleted"].stringValue
        deviceToken = json["device_token"].stringValue
        deviceType = json["device_type"].stringValue
        displayName = json["display_name"].stringValue
        email = json["email"].stringValue
        fbId = json["fb_id"].stringValue
        fogotpwdToken = json["fogotpwd_token"].stringValue
        followersCount = json["followers_count"].stringValue
        followingCount = json["following_count"].stringValue
        forgotpwdDate = json["forgotpwd_date"].stringValue
        userId = json["user_id"].stringValue
        insertdate = json["insertdate"].stringValue
        isFollowing = json["is_following"].stringValue
        lastLogin = json["last_login"].stringValue
        login = json["login"].stringValue
        loginType = json["login_type"].stringValue
        owner = json["owner"].stringValue
        password = json["password"].stringValue
        profile = json["profile"].stringValue
        isPublic = json["is_public"].stringValue
        rackCount = json["rack_count"].stringValue
        showRack = json["show_rack"].stringValue
        signupStatus = json["signup_status"].stringValue
        status = json["status"].stringValue
        token = json["token"].stringValue
        userName = json["user_name"].stringValue
        verify = json["verify"].stringValue
        viewCount = json["view_count"].stringValue
        wardrobesImage = json["wardrobes_image"].stringValue
        requestStatus = json["request_status"].stringValue
        if (json.dictionary?.keys.contains("user_settings"))! {
          settings = UserSettings(fromJson: json["user_settings"])
        }
        
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if bioTxt != nil{
            dictionary["bio_txt"] = bioTxt
        }
        if deleted != nil{
            dictionary["deleted"] = deleted
        }
        if deviceToken != nil{
            dictionary["device_token"] = deviceToken
        }
        if deviceType != nil{
            dictionary["device_type"] = deviceType
        }
        if displayName != nil{
            dictionary["display_name"] = displayName
        }
        if email != nil{
            dictionary["email"] = email
        }
        if fbId != nil{
            dictionary["fb_id"] = fbId
        }
        if fogotpwdToken != nil{
            dictionary["fogotpwd_token"] = fogotpwdToken
        }
        if followersCount != nil{
            dictionary["followers_count"] = followersCount
        }
        if followingCount != nil{
            dictionary["following_count"] = followingCount
        }
        if forgotpwdDate != nil{
            dictionary["forgotpwd_date"]  = forgotpwdDate
        }
        if userId != nil{
            dictionary["user_id"] = userId
        }
        if insertdate != nil{
            dictionary["insertdate"] = insertdate
        }
        if isFollowing != nil{
            dictionary["is_following"] = isFollowing
        }
        if lastLogin != nil{
            dictionary["last_login"] = lastLogin
        }
        if login != nil{
            dictionary["login"] = login
        }
        if loginType != nil{
            dictionary["login_type"] = loginType
        }
        if owner != nil{
            dictionary["owner"] = owner
        }
        if password != nil{
            dictionary["password"] = password
        }
        if profile != nil{
            dictionary["profile"] = profile
        }
        
        if isPublic != nil{
            dictionary["is_public"] = isPublic
        }
        if rackCount != nil{
            dictionary["rack_count"] = rackCount
        }
        if showRack != nil{
            dictionary["show_rack"] = showRack
        }
        if signupStatus != nil{
            dictionary["signup_status"] = signupStatus
        }
        if status != nil{
            dictionary["status"] = status
        }
        if token != nil{
            dictionary["token"] = token
        }
        if userName != nil{
            dictionary["user_name"] = userName
        }
        if verify != nil{
            dictionary["verify"] = verify
        }
        if viewCount != nil{
            dictionary["view_count"] = viewCount
        }
        if wardrobesImage != nil{
            dictionary["wardrobes_image"] = wardrobesImage
        }
        if requestStatus != nil {
            dictionary["request_status"] = requestStatus
        }
        
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        bioTxt = aDecoder.decodeObject(forKey: "bio_txt") as? String
        deleted = aDecoder.decodeObject(forKey: "deleted") as? String
        deviceToken = aDecoder.decodeObject(forKey: "device_token") as? String
        deviceType = aDecoder.decodeObject(forKey: "device_type") as? String
        displayName = aDecoder.decodeObject(forKey: "display_name") as? String
        email = aDecoder.decodeObject(forKey: "email") as? String
        fbId = aDecoder.decodeObject(forKey: "fb_id") as? String
        fogotpwdToken = aDecoder.decodeObject(forKey: "fogotpwd_token") as? String
        followersCount = aDecoder.decodeObject(forKey: "followers_count") as? String
        followingCount = aDecoder.decodeObject(forKey: "following_count") as? String
        forgotpwdDate = aDecoder.decodeObject(forKey: "forgotpwd_date") as? String
        userId = aDecoder.decodeObject(forKey: "user_id") as? String
        insertdate = aDecoder.decodeObject(forKey: "insertdate") as? String
        isFollowing = aDecoder.decodeObject(forKey: "is_following") as? String
        lastLogin = aDecoder.decodeObject(forKey: "last_login") as? String
        login = aDecoder.decodeObject(forKey: "login") as? String
        loginType = aDecoder.decodeObject(forKey: "login_type") as? String
        owner = aDecoder.decodeObject(forKey: "owner") as? String
        password = aDecoder.decodeObject(forKey: "password") as? String
        profile = aDecoder.decodeObject(forKey: "profile") as? String
        
        isPublic = aDecoder.decodeObject(forKey: "is_public") as? String
        rackCount = aDecoder.decodeObject(forKey: "rack_count") as? String
        showRack = aDecoder.decodeObject(forKey: "show_rack") as? String
        signupStatus = aDecoder.decodeObject(forKey: "signup_status") as? String
        status = aDecoder.decodeObject(forKey: "status") as? String
        token = aDecoder.decodeObject(forKey: "token") as? String
        userName = aDecoder.decodeObject(forKey: "user_name") as? String
        verify = aDecoder.decodeObject(forKey: "verify") as? String
        viewCount = aDecoder.decodeObject(forKey: "view_count") as? String
        wardrobesImage = aDecoder.decodeObject(forKey: "wardrobes_image") as? String
        requestStatus = aDecoder.decodeObject(forKey: "request_status") as? String
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if bioTxt != nil{
            aCoder.encode(bioTxt, forKey: "bio_txt")
        }
        if deleted != nil{
            aCoder.encode(deleted, forKey: "deleted")
        }
        if deviceToken != nil{
            aCoder.encode(deviceToken, forKey: "device_token")
        }
        if deviceType != nil{
            aCoder.encode(deviceType, forKey: "device_type")
        }
        if displayName != nil{
            aCoder.encode(displayName, forKey: "display_name")
        }
        if email != nil{
            aCoder.encode(email, forKey: "email")
        }
        if fbId != nil{
            aCoder.encode(fbId, forKey: "fb_id")
        }
        if fogotpwdToken != nil{
            aCoder.encode(fogotpwdToken, forKey: "fogotpwd_token")
        }
        if followersCount != nil{
            aCoder.encode(followersCount, forKey: "followers_count")
        }
        if followingCount != nil{
            aCoder.encode(followingCount, forKey: "following_count")
        }
        if forgotpwdDate != nil{
            aCoder.encode(forgotpwdDate, forKey: "forgotpwd_date")
        }
        if userId != nil{
            aCoder.encode(userId, forKey: "user_id")
        }
        if insertdate != nil{
            aCoder.encode(insertdate, forKey: "insertdate")
        }
        if isFollowing != nil{
            aCoder.encode(isFollowing, forKey: "is_following")
        }
        if lastLogin != nil{
            aCoder.encode(lastLogin, forKey: "last_login")
        }
        if login != nil{
            aCoder.encode(login, forKey: "login")
        }
        if loginType != nil{
            aCoder.encode(loginType, forKey: "login_type")
        }
        if owner != nil{
            aCoder.encode(owner, forKey: "owner")
        }
        if password != nil{
            aCoder.encode(password, forKey: "password")
        }
        if profile != nil{
            aCoder.encode(profile, forKey: "profile")
        }
        
        if isPublic != nil{
            aCoder.encode(isPublic, forKey: "is_public")
        }
        if rackCount != nil{
            aCoder.encode(rackCount, forKey: "rack_count")
        }
        if showRack != nil{
            aCoder.encode(showRack, forKey: "show_rack")
        }
        if signupStatus != nil{
            aCoder.encode(signupStatus, forKey: "signup_status")
        }
        if status != nil{
            aCoder.encode(status, forKey: "status")
        }
        if token != nil{
            aCoder.encode(token, forKey: "token")
        }
        if userName != nil{
            aCoder.encode(userName, forKey: "user_name")
        }
        if verify != nil{
            aCoder.encode(verify, forKey: "verify")
        }
        if viewCount != nil{
            aCoder.encode(viewCount, forKey: "view_count")
        }
        if wardrobesImage != nil{
            aCoder.encode(wardrobesImage, forKey: "wardrobes_image")
        }
        if requestStatus != nil{
            aCoder.encode(requestStatus, forKey: "request_status")
        }
        
    }

    //------------------------------------------------------
    
    //MARK: - Other Helper Method
    
    func saveUserDetailInDefaults()  {
        let userDefault = UserDefaults.standard
        let encodeData = NSKeyedArchiver.archivedData(withRootObject: self)
        userDefault.set(encodeData, forKey: kLoginUserData)
        if self.settings != nil {
            let settingData = NSKeyedArchiver.archivedData(withRootObject: self.settings)
            userDefault.set(settingData, forKey: self.userId)
        }
        userDefault.synchronize()
    }
    
    func getUserDetailFromDefaults() {
        let userDefault = UserDefaults.standard
        guard let decodeData = userDefault.value(forKey: kLoginUserData) else {
            return
        }
        UserModel.currentUser = NSKeyedUnarchiver.unarchiveObject(with: decodeData as! Data) as! UserModel
        
        guard let decodeSettingData = userDefault.value(forKey: UserModel.currentUser.userId) else {
            return
        }
        UserModel.currentUser.settings = NSKeyedUnarchiver.unarchiveObject(with: decodeSettingData as! Data) as! UserSettings
        
    }
    
    

    func saveUserSessionInToDefaults() {
        UserDefaults.standard.set(self.token, forKey: kUserSession)
        UserDefaults.standard.synchronize()
    }

    class func getUserSessionToken() -> String! {
        
        if (UserDefaults.standard.value(forKey: kUserSession) != nil) {
            
            let userSession : String? = UserDefaults.standard.value(forKey: kUserSession) as? String
            
            guard let
                letValue = userSession, !letValue.isEmpty else {
                    //print(":::::::::-User Token Not Found-:::::::::::")
                    return ""
            }
            return userSession!
        }
        return ""
    }
    
    func isPrivateProfile() -> Bool {
     
        if self.isPublic == profileType.kPrivate.rawValue {
            return true
        } else {
            return false
        }
    }
    
    func isShowRack(_ viewType : profileViewType = .me) -> Bool {
        if self.showRack == "yes" {
            return true
        } else {
            return false
        }
    }
    
    func isProfileAccessible(_ viewType : profileViewType) -> Bool {
     
        switch viewType {
        
        case .me:
            return true

        case .other:
            
            if (self.isPrivateProfile() && !(self.isFollowing.lowercased() == FollowType.following.rawValue)) || (self.isFollowing.lowercased() == FollowType.unblock.rawValue) {
                return false
            } else {
                return true
            }
            
        }
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
    
    func isUserVerify() -> Bool {
        if self.verify == "not verify" {
            return false
        } else {
            return true
        }
    }
    
}


class UserSettings: NSObject, NSCoding{
    
    var likes          : String! = ""
    var comments       : String! = ""
    var reposts        : String! = ""
    var requests       : String! = ""
    var photos         : String! = ""
    var followers      : String! = ""
  
    init(fromJson setting: JSON!){
        if setting.isEmpty{
            return
        }
        likes     = setting["likes"].stringValue
        comments  = setting["comments"].stringValue
        reposts   = setting["reposts"].stringValue
        requests  = setting["requests"].stringValue
        photos    = setting["photos"].stringValue
        followers = setting["followers"].stringValue
    }
    
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if likes != nil{
            aCoder.encode(likes, forKey: "likes")
        }
        if comments != nil{
            aCoder.encode(comments, forKey: "comments")
        }
        if reposts != nil{
            aCoder.encode(reposts, forKey: "reposts")
        }
        if requests != nil{
            aCoder.encode(requests, forKey: "requests")
        }
        if photos != nil{
            aCoder.encode(photos, forKey: "photos")
        }
        if followers != nil{
            aCoder.encode(followers, forKey: "followers")
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        likes = aDecoder.decodeObject(forKey: "likes") as? String
        comments = aDecoder.decodeObject(forKey: "comments") as? String
        reposts = aDecoder.decodeObject(forKey: "reposts") as? String
        requests = aDecoder.decodeObject(forKey: "requests") as? String
        photos = aDecoder.decodeObject(forKey: "photos") as? String
        followers = aDecoder.decodeObject(forKey: "followers") as? String
    }
    
    func getsettings() -> [Int] {
        var settings : [Int] = [2,2,2,1,1,1]
        if likes != nil {
            if likes == "off"{
                settings[0] = 0
            } else if likes == "following"{
                settings[0] = 1
            }
        }
        if comments != nil {
            if comments == "off"{
                settings[1] = 0
            } else if comments == "following"{
                settings[1] = 1
            }
        }
        if reposts != nil {
            if reposts == "off"{
                settings[2] = 0
            } else if reposts == "following"{
                settings[2] = 1
            }
        }
        if requests != nil {
            if requests == "off"{
                settings[3] = 0
            }
        }
        if photos != nil {
            if photos == "following"{
                settings[4] = 0
            }
        }
        if followers != nil {
            if followers == "off"{
                settings[5] = 0
            }
        }
        return settings
    }
    
    
    
}


