//
//  UserListViewController.swift
//  ChatApp02
//
//  Created by 岩元喜輝 on 2020/07/08.
//  Copyright © 2020 Yoshiki Iwamoto. All rights reserved.
//

import UIKit
import Firebase
import Nuke

class UserListViewController: UIViewController {
    
    private var selectedUser:Users?
    private var users = [Users]()
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var userListTableView: UITableView!
    
    var changeColor = ChangeColor()
    var gradientLayer = CAGradientLayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradientLayer = changeColor.changeColor(topR:0.27,topG:0.27,topB:0.56,topAlpha:0.6,
                                                bottomR:0.14,bottomG:0.64,bottomB:0.56,bottomAlpha:0.34)
        
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        userListTableView.tableFooterView = UIView()
        userListTableView.delegate = self
        userListTableView.dataSource = self
        navigationController?.navigationBar.barTintColor = .rgb(red: 50, green: 60, blue: 80)
        chatButton.layer.cornerRadius = 12
        chatButton.isEnabled = false
        fetchUserInfoFromFirestore()
        
    }
    private func fetchUserInfoFromFirestore(){
        Firestore.firestore().collection("users").getDocuments { (snapshots, err) in
            if let err = err{
                print("ユーザー情報の取得に失敗しました\(err)")
                return
            }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = Users(dic: dic)
                
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                if uid == snapshot.documentID{
                    return
                }
                self.users.append(user)
                self.userListTableView.reloadData()
                
            })
        }
    }
    
    
    
    
    @IBAction func startChatButton(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let partnerUid = self.selectedUser?.uid else { return }
        let members = [uid,partnerUid]
        
        let docData = [
            "members":members,
            "latestMessageId":"",
            "createdAt":Timestamp()
            ] as [String : Any]
        Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (err) in
            if let err = err{
                print("チャットルーム情報の保存に失敗しました\(err)")
            }
            self.dismiss(animated: true, completion: nil)
            print("チャットルーム情報の保存に成功しました")
        }
    }
}

extension UserListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        self.selectedUser = user
        chatButton.isEnabled = true
    }
}

class UserListTableViewCell: UITableViewCell {
    var user:Users?{
        didSet{
            guard let user = user else { return }
            nameLabel.text = user.username
            if let url = URL(string:user.profileImageUrl){
                Nuke.loadImage(with: url, into: userImageView)
            }
            
            
            
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 30
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
