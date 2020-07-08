//
//  ChatRoom.swift
//  ChatApp02
//
//  Created by 岩元喜輝 on 2020/07/08.
//  Copyright © 2020 Yoshiki Iwamoto. All rights reserved.
//

import Foundation
import Firebase

class ChatRoom {
    let members:[String]
    let createdAt:Timestamp
    let latestMessageId:String
    
    var partnerUser:Users?
    var documentId:String?
    var latestMessage:Messages?
    
    init(dic:[String:Any]) {
        self.members = dic["members"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
    }
}

