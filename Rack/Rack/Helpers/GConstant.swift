//
//  GConstant.swift
//  Rack
//
//  Created by hyperlink on 27/04/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

let kAppName  : String = "RACK"

//MARK: - Screen (Width - Height)
let kScreenWidth                                =  UIScreen.main.bounds.size.width
let kScreenHeight                               =  UIScreen.main.bounds.size.height
let kHeightAspectRasio:CGFloat                  =  1.1

//MARK:- Color
let kColorDarkGray                  :Int    = 0x151515
let kColorGray74                    :Int    = 0xBDBDBD
let kColorFBBlue                    :Int    = 0x549AFE
let kColorFB                        :Int    = 0x405791
//Old color code of red
//let kColorRed                       :Int    = 0xFF4848
let kColorRed                       :Int    = 0xD60101
let kColorGreen                     :Int    = 0x25DE8D
let kColorGray38                    :Int    = 0x262626
let kColorGray123                   :Int    = 0x7B7B7B
let kColorWhite                     :Int    = 0xffffff

struct AppColor {
  static let primaryTheme = UIColor.white
  static let secondaryTheme = UIColor.lightGray

    static let createReckText = UIColor(red: 130.0/255.0, green: 130.0/255.0, blue: 130.0/255.0, alpha: 1.0)
  static let text = UIColor(red: 80.0/255.0, green: 80.0/255.0, blue: 80.0/255.0, alpha: 1.0)
  static let darkText = UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)

  static let placeHolder = UIColor(red: 161.0/255.0, green: 159.0/255.0, blue: 159.0/255.0, alpha: 1.0)
  static let btnTitle = UIColor(red: 80.0/255.0, green: 80.0/255.0, blue: 80.0/255.0, alpha: 1.0)
  
  static let borderColor = UIColor.lightGray


}

//MARK:- UserDefaults
let kAppLaunch                      : String = "KAppLaunch"
let kDeviceToken                    : String = "kDeviceToken"
let kLoginUserData                  : String = "kLoginUserData"
let kUserSession                    : String = "kUserSession"
let kUserSearchData                 : String = "kUserSearchData"
let kHashSearchData                 : String = "kHashSearchData"
let kBrandSearchData                : String = "kBrandSearchData"
let kItemSearchData                 : String = "kItemSearchData"

//MARK:- Key Constant
let kError                          :String = "kError"
let kImage                          :String = "kImage"

let kMinimumPressDuration           :CFTimeInterval  = 0.70

//MARK:- Enum
enum SelectRectType {
    case cameraRoll
    case racks
}

enum PickerMode {
    case defaultPickerMode
    case profilePickerMode
    case imagePostPickerMode
}

enum FollowType : String {
    case follow
    case following
    case requested
    case unblock
    case unfollow
}

enum StatusType : String {
    case like
    case unlike
    case want
    case rack
    case unwant
}

enum PageFrom {
    case defaultScreen
    case fromSettingPage
    case otherPage
}

enum ImagePostType {
    case camera
    case gallery
}

enum ReportType : String {
    case profile
    case item
    case comment
}

enum TagType : String {
    case none = ""
//    case tagHash = "hash_tag"
    case tagBrand = "brand_tag"
    case tagItem = "item_tag"
    case tagPeople = "user_tag"
    case addLink = "link_tag"
}

enum selectedButtonTag : Int {
    case tagBrand = 1
    case tagPeople = 2
    case addLink = 3
}


//discover,people,hashtag,brand,item
enum profileViewType {
    case me
    case other
}

enum uploadCellType {
    case postImageCell
    case optionSelectionCell
    case tagTypeCell
    case switchTypeCell
    case createRackCell
}

enum userAuthenticationStatus : String {
    case profile       = "profile"
    case wardrobes     = "wardrobes"
    case friend        = "friend"
    case login         = "login"

}
typealias userAuthStatu = userAuthenticationStatus

enum userProfileType : String {
    case kPublic       = "public"
    case kPrivate      = "private"
    
}
typealias profileType = userProfileType


enum requestStatus : String {
    case accepted
    case rejected
    case blocked
    case unfollow
}

enum searchFlagType : String {
    case hashtag
    case brand
    case item
    case discover
    case people
    case none
    case link
}
typealias searchFlag = searchFlagType

enum PostShareType : String {
    case main
    case repost
}

enum PageRefreshType : String {
    case top = "top"
    case bottom = "down"
}

enum MultiImageCellManageType : String {
    case added
    case remove
    case replace
}

enum tutorialFlagType : String {
    case Newsfeed
    case Search
    case Add
    case Profile
    case OtherProfile
    case Setting
}

typealias tutorialFlag = tutorialFlagType


//MARK:- Custom Notification 
let kNotificationProfileUpdate      : String = "kNotificationProfileUpdate"
let kNotificationRepostCountUpdate  : String = "kNotificationRepostCountUpdate"
let kNotificationUserDataUpdate     : String = "kNotificationUserDataUpdate"
let kNotificationFollowListUpdate   : String = "kNotificationFollowListUpdate"
let kNotificationItemDetailUpdate   : String = "kNotificationItemDetailUpdate"
let kNotificationItemDetailDelete   : String = "kNotificationItemDetailDelete"
let kNotificationNewPostAdded       : String = "kNotificationNewPostAdded"
let kNotificationUserPrivacyPublic  : String = "kNotificationUserPrivacyPublic"
let kNotificationUserRequest        : String = "kNotificationUserRequest"
let kNotificationUserDetailsUpdate  : String = "kNotificationUserDetailsUpdate"
let kNotificationRackWantUpdate     : String = "kNotificationRackWantUpdate"
let kNotificationScreenShot         : String = "kNotificationScreenShot"
let kNotificationSetHomePage        : String = "kNotificationSetHomePage"
let kNotificationUnfollow           : String = "kNotificationUnfollow"
let kNotificationWant               : String = "kNotificationWant"
let kNotificationRackWantEdit       : String = "kNotificationRackWantEdit"

//MARK:- Other
let mainStoryBoard                  : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
let secondStoryBoard                : UIStoryboard = UIStoryboard(name: "Second", bundle: nil)

protocol PSTableDelegateDataSource  : UITableViewDelegate , UITableViewDataSource {}
protocol PSCollectinViewDelegateDataSource : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {}

//MARK:- Message

let kSettingChangeTitle             :String = "Change your Settings"
let kPhotoPermissionMessage         :String = "We need to have access to your photos to select a Photo.\nPlease go to the App Settings and allow Photos."
let kCameraPermissionMessage        :String = "We need to have access to your camera to take a New Photo.\nPlease go to the App Settings and allow Camera."

var navigationCOntroller            : UINavigationController?
