//
//  Messages.swift
//  ChatApp02
//
//  Created by 岩元喜輝 on 2020/07/08.
//  Copyright © 2020 Yoshiki Iwamoto. All rights reserved.
//

import Foundation
import Firebase

class Messages {
    let name:String
    let message:String
    let createdAt:Timestamp
    let uid:String
    
    var partnerUser:Users?
    
    init(dic:[String:Any]) {
        self.name = dic["name"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.uid = dic["uid"] as? String ?? ""
    }
    
}

