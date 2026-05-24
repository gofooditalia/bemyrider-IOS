//
//  StringConstants.swift
//  Lifester
//
//  Created by NCT 24 on 07/12/17.
//  Copyright © 2017 NCT 24. All rights reserved.
//

import Foundation

//LoginView

extension String {
//https://stackoverflow.com/questions/36661848/is-any-function-in-swift-similar-to-r-java-in-android
    
    enum StringId: String {
        //Login
        case Email = "Email"
        case Password = "Password"
        case LOGIN = "LOGIN"
        case ForgotPwd = "Forgot Password ?"
        
        //Notification setting
        case NotiTitle = "Notification Preference"
        case NotiDescr = "Want to get informed when new message arrived and you are around?"
        
        //Create Forum
        case createOpenForum = "Create Open Forum"
        case ForumName = "Forum Name"
        case createForum = "Create Forum"
        case close = "Close"
        
    }
    
    init(id: StringId) {
        self = id.rawValue
    }
    
}
//Ex: let label = String(id: .Welcome) // "Welcome to the game!"
