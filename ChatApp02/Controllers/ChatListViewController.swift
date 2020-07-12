//
//  ChatListViewController.swift
//  ChatApp02
//
//  Created by 岩元喜輝 on 2020/07/08.
//  Copyright © 2020 Yoshiki Iwamoto. All rights reserved.
//



import UIKit
import Firebase
import Nuke
import PKHUD



class ChatListViewController: UIViewController {
    
    var chatRoomListner:ListenerRegistration?
    var chatrooms = [ChatRoom]()
    var changeColor = ChangeColor()
    var gradientLayer = CAGradientLayer()

    private var user:Users?
    
    
    @IBOutlet weak var chatListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        confirmLoginUser()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchLoginUser()
        fetchChatroomInfoFromFirestore()
        
    }
    
    func fetchChatroomInfoFromFirestore(){
        chatRoomListner?.remove()
        chatrooms.removeAll()
        chatListTableView.reloadData()
        HUD.show(.progress)
        
        
        chatRoomListner = Firestore.firestore().collection("chatRooms").addSnapshotListener { (snapshots, err) in
            
            if let err = err{
                print("チャットルーム情報の取得に失敗しました\(err)")
                HUD.hide()
                return
            }
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch
                documentChange .type{
                case .added:
                    self.handleAddedDocumentChange(documentChange: documentChange)
                    
                case .modified,.removed:
                    print("ntd")
                }
            })
        }
    }
    
    private func handleAddedDocumentChange(documentChange:DocumentChange){
        let dic = documentChange.document.data()
        let chatroom = ChatRoom(dic: dic)
        chatroom.documentId = documentChange.document.documentID
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let isContain = chatroom.members.contains(uid)
        if !isContain { return }
        chatroom.members.forEach { (memberUid) in
            if memberUid != uid {
                Firestore.firestore().collection("users").document(memberUid).getDocument { (userSnapshot, err) in
                    if let err = err{
                        print("ユーザー情報の取得に失敗しました\(err)")
                        HUD.hide()
                        return
                    }
                    guard let dic = userSnapshot?.data() else { return }
                    let user = Users(dic: dic)
                    chatroom.partnerUser = user
                    
                    guard let chatRoomId = chatroom.documentId else { return }
                    let latestMessageId = chatroom.latestMessageId
                    
                    if latestMessageId == ""{
                        self.chatrooms.append(chatroom)
                        self.chatListTableView.reloadData()
                        HUD.hide()
                        return
                    }
                    Firestore.firestore().collection("chatRooms").document(chatRoomId).collection("messages").document(latestMessageId).getDocument { (messageSnapshot, err) in
                        if let err = err{
                            print("最新情報の取得に失敗しました\(err)")
                            HUD.hide()
                            return
                        }
                        guard let dic = messageSnapshot?.data() else { return }
                        let message = Messages(dic: dic)
                        chatroom.latestMessage = message
                        
                        
                        self.chatrooms.append(chatroom)
                        self.chatListTableView.reloadData()
                        HUD.hide()
                    }
                    
                }
            }
        }
    }
    
    private func setUpViews(){
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        navigationController?.navigationBar.barTintColor = .rgb(red: 50, green: 60, blue: 80)
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.title = "トーク"
        let rightBarButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedNavRightBarButton))
        let logoutButton = UIBarButtonItem(title: "ログアウト", style: .plain, target: self, action: #selector(tappedLogoutButton))
        navigationItem.leftBarButtonItem = logoutButton
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem?.tintColor = .white
        gradientLayer = changeColor.changeColor(topR:0.27,topG:0.27,topB:0.56,topAlpha:0.6,
                                                bottomR:0.14,bottomG:0.64,bottomB:0.56,bottomAlpha:0.34)
        
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    @objc private func tappedLogoutButton(){
        do {
            try  Auth.auth().signOut()
            sendToSignupVC()
        } catch  {
            print(error)
        }
        
    }
    
    
    @objc private func tappedNavRightBarButton(){
        
        let storyboard = UIStoryboard(name: "UserList", bundle: nil)
        
        let userListVC = storyboard.instantiateViewController(withIdentifier: "UserListViewController")
        let nav = UINavigationController(rootViewController: userListVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    private func confirmLoginUser(){
        if Auth.auth().currentUser?.uid == nil{
            sendToSignupVC()
        }
        
    }
    private func sendToSignupVC(){
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        let nav = UINavigationController(rootViewController: signUpVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: false, completion: nil)
    }
    private func fetchLoginUser(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました \(err)")
                return
            }
            guard let dic = snapshot?.data() else { return }
            let user = Users(dic: dic)
            self.user = user
        }
    }
    
    
}
extension ChatListViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ChatListTableViewCell
        cell.chatroom = chatrooms[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "ChatRoom", bundle: nil)
        
        let chatRoomVC = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
        chatRoomVC.user = user
        chatRoomVC.chatroom = chatrooms[indexPath.row]
        navigationController?.pushViewController(chatRoomVC, animated: true)
        
    }
    
    
}

class ChatListTableViewCell:UITableViewCell{
    
    var chatroom:ChatRoom?{
        didSet{
            guard let chatroom = chatroom else { return }
            partnerNameLabel.text = chatroom.partnerUser?.username
            dateLabel.text = dateFormatterForDate(date: chatroom.latestMessage?.createdAt.dateValue() ?? Date())
            if let url = URL(string: chatroom.partnerUser?.profileImageUrl ?? ""){
                Nuke.loadImage(with: url, into: partnerImageView)
                latestMessageLabel.text = chatroom.latestMessage?.message
            }
            
        }
    }
    
    
    @IBOutlet weak var partnerImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerNameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        partnerImageView.layer.cornerRadius = 30
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func dateFormatterForDate(date:Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
        
    }
}
