//
//  ChatRoomViewController.swift
//  ChatApp02
//
//  Created by 岩元喜輝 on 2020/07/08.
//  Copyright © 2020 Yoshiki Iwamoto. All rights reserved.
//


import UIKit
import Firebase

class ChatRoomViewController: UIViewController {
    
    var messages = [Messages]()
    var user:Users?
    var chatroom:ChatRoom?
    var changeColor = ChangeColor()
    var gradientLayer = CAGradientLayer()
    
    private var safeAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }
    
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    private lazy var chatInputAccessoryView:ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatInputAccessoryView.delegate = self
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: "cellId")
        chatRoomTableView.backgroundColor = .clear
        chatRoomTableView.tableFooterView = UIView()
        chatRoomTableView.contentInset = .init(top: 15, left: 0, bottom: 0, right: 0)
        chatRoomTableView.scrollIndicatorInsets = .init(top: 10, left: 0, bottom: 0, right: 0)
        chatRoomTableView.keyboardDismissMode = .onDrag
        chatRoomTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        gradientLayer = changeColor.changeColor(topR:0.27,topG:0.27,topB:0.56,topAlpha:0.6,
                                                bottomR:0.14,bottomG:0.64,bottomB:0.56,bottomAlpha:0.34)
        
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        fetchMessages()
        setUpNotification()
        
    }
    private func setUpNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShow(notification:NSNotification){
        guard let userInfo = notification.userInfo else { return }
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            if keyboardFrame.height <= 100 { return }
            let top = keyboardFrame.height - safeAreaBottom
            var moveY = -(top - chatRoomTableView.contentOffset.y)
            if chatRoomTableView.contentOffset.y == -15 { moveY += 15}
            let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            chatRoomTableView.contentInset = contentInset
            chatRoomTableView.scrollIndicatorInsets = contentInset
            chatRoomTableView.contentOffset = CGPoint(x: 0, y: moveY)
        }
    }
    @objc func keyboardWillHide(){
        chatRoomTableView.contentInset = .init(top: 15, left: 0, bottom: 0, right: 0)
        chatRoomTableView.scrollIndicatorInsets = .init(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    
    override var inputAccessoryView: UIView?{
        get{
            return chatInputAccessoryView
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    private func fetchMessages(){
        guard let documentId = chatroom?.documentId else { return }
        Firestore.firestore().collection("chatRooms").document(documentId).collection("messages").addSnapshotListener { (snapshots, err) in
            if let err = err{
                print("メッセージ情報の取得に失敗しました\(err)")
            }
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type{
                case .added:
                    let dic = documentChange.document.data()
                    let message = Messages(dic: dic)
                    message.partnerUser = self.chatroom?.partnerUser
                    self.messages.append(message)
                    
                    self.messages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                    }
                    self.chatRoomTableView.reloadData()
                case .modified,.removed:
                    print("ntd")
                    
                }
            })
        }
    }
}

extension ChatRoomViewController:ChatInputAccessoryViewDelegate{
    func tappedSendButton(text: String) {
        
        
        guard let documentId = chatroom?.documentId else { return }
        guard let name = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        chatInputAccessoryView.removeText()
        let messageId = randomString(length: 20)
        let docData = [
            "name": name,
            "message":text,
            "createdAt":Timestamp(),
            "uid": uid
            ] as [String : Any]
        Firestore.firestore().collection("chatRooms").document(documentId).collection("messages").document(messageId).setData(docData) { (err) in
            if let err = err{
                print("メッセージ情報の保存に失敗しました\(err)")
                return
            }
            
            let latestMessageData = [
                "latestMessageId":messageId
            ]
            Firestore.firestore().collection("chatRooms").document(documentId).updateData(latestMessageData) { (err) in
                if let err = err{
                    print("最新情報の更新に失敗しました\(err)")
                    return
                }
                print("最新メッセージ情報の更新に成功しました")
            }
            print("メッセージ情報の保存に成功しました")
        }
    }
    
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    
    
}

extension ChatRoomViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ChatRoomTableViewCell
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        cell.message = messages[indexPath.row]
        return cell
    }
    
    
}
