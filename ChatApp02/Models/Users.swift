//
//  Users.swift
//  ChatApp02
//
//  Created by 岩元喜輝 on 2020/07/08.
//  Copyright © 2020 Yoshiki Iwamoto. All rights reserved.
//

import Foundation
import Firebase

class Users {
    let username:String
    let email:String
    let profileImageUrl:String
    let createdAt:Timestamp
    let uid:String
    let hobby:String
    
    
    
    init(dic:[String:Any]) {
        self.username = dic["username"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.email = dic["email"] as? String ?? ""
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.hobby = dic["hobby"] as? String ?? ""
    }
}

