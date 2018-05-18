//  GAPIConstant.swift
//  Rack
//  Created by hyperlink on 05/06/17.
//  Copyright © 2017 Hyperlink. All rights reserved.

import Foundation

//MARK: - Base URL
let kBase               : String = "http://52.63.171.238/"
//let kBase             : String = "http://13.55.228.20/"
let kBaseURL            : String = kBase + "api/v4/"
let kTerms              : String = kBase + "home/term_condition"
let kPrivacy            : String = kBase + "home/privacy_policy"
let kAbout              : String = kBase + "home/aboutus"
//MARK: - Header
let kHeaderAPIKey       : String = "API-KEY"
let kHeaderAPIKeyValue  : String = "RACK"
let kHeaderToken        : String = "TOKEN"

//MARK: - Method
let kMethodLogin                    : String = "user/login"
let kMethodSignup                   : String = "user/signup"
let kMethodCreateProfile            : String = "user/create_profile"
let kMethodCheckUsername            : String = "user/check_username"
let kMethodWardrobesList            : String = "user/wardrobes_list"
let kMethodCreateWardrobes          : String = "user/create_wardrobes"
let kMethodSearch                   : String = "user/search"
let kMethodSearchDetail             : String = "user/search_detail"
let kMethodCreateFriend             : String = "user/create_friend"
let kMethodForgotPassword           : String = "user/forgotpassword"
let kMethodChangePassword           : String = "user/changepassword"
let kMethodLogout                   : String = "user/logout"
let kMethodUserDeviceInfo           : String = "user/editdevice_info"
let kMethodUserNotificationCount    : String = "user/notificationcount"
let kMethodUserCount                : String = "user/user_count"
let kMethodUserViewTutorial         : String = "user/view_user_tutorial"
let kMethodUserAddTutorial          : String = "user/add_user_tutorial"
let kMethodDeactivate               : String = "user/deactivate_account"

//user detail
let kMethodUserDetail               : String = "user/user_detail"
let kMethodUserEdit                 : String = "user/edit"
let kMethodProfilePublic            : String = "user/profile_public"
let kMethodShowRack                 : String = "user/show_rack"
let kMethodUserData                 : String = "user/user_data"
let kMethodUserActivity             : String = "user/activity"

//user listing
let kMethodUserList                 : String = "user/user_list"
let kMethodBlockUser                : String = "user/block_user"


//user request
let kMethodUpdateRequest            : String    = "request/update_request"
let kMethodSendRequest              : String    = "request/send_request"
let kMethodRequestNotificationRead  : String    = "request/unread_notification"
let kMethodItemLike                 : String    = "request/item_like"
let kMethodUserLikeList             : String    = "request/userlike_list"
let kMethodUserRepostersList        : String    = "request/user_reposters_list"
let kMethodItemCommentList          : String    = "request/comment_list"
let kMethodSendComment              : String    = "request/add_comment"
let kMethodNotificationList         : String    = "request/notification_new_list"
let kMethodRequestNotificationList  : String    = "request/requests_list"
let kMethodRepostNotificationList   : String    = "request/reposts_list"

let kMethodDeleteComment            : String    = "request/delete_comment"
let kMethodRequestReport            : String    = "request/report"
let kMethodSaveSettings             : String    = "request/save_settings"


//item request
let kMethodUploadItem               : String   = "item/uploaditem"
let kMethodItemList                 : String   = "item/myfeedlist"
let kMethodWantList                 : String   = "item/itemwant"
let kMethodRackWantList             : String   = "item/rackwantlist"
let kMethodIWantList                : String   = "item/userwant_list"
let kMethodItemDetail               : String   = "item/itemdetail"
let kMethodItemDelete               : String   = "item/deleteitem"
let kMethodItemEdit                 : String   = "item/edititem"
let kMethodItemSharing              : String   = "item/sharing"
let kMethodRackList                 : String   = "item/racklist"
let kMethodRackDetail               : String   = "item/rackdetail"
let kMethodRackDelete               : String   = "item/delete_rack"
let kMethodRackEdit                 : String   = "item/edit_rack"

//MARK:- responseStatusCode
let success                         :String = "1"
let noDataFound                     :String = "2"
let accountInactive                 :String = "3"
let verificationOTP                 :String = "4"
let verificationEmail               :String = "5"
let forceUpdateApp                  :String = "6"
let updateAppAlert                  :String = "7"
//MARK:- custom responseStatusCode
let myfeedlistempty                 :String = "12"

//MARK:- API Key Constant
let kData                           :String = "data"
let kNotificationDetail             :String = "notification_detail"
let kMessage                        :String = "message"
let kCode                           :String = "code"

// FB :- 1075523932489526

/* Twitter Client's account
 
 Consumer Key (API Key)    vCCIgyvTCwrG9JmeXd1DBeygi
 Consumer Secret (API Secret)    oOuWw3NYGN2yGVyN02FBiTEAZWynbZ7w5hOAua6qMp19Wh8xH7
 */

/* Pinterest client's account
 
//App ID 4928663422681232830
//App secret b8a87f23931b3ca9d2bc7945472602def70ff37e9a2b10a76b7ceb0bd630839b
*/

/*Tumblr client's account
 
 OAuth consumer key:
 skxVxmQfGP8W1WmeMobr0jzaFaXkTlqEslP5adzZukVIuFMKn9
 OAuth consumer secret:
 5lMB2oCP93x3iPUHQO9llvGJCwvzqaYEZgioVdLrdnkYiKINro
 */
