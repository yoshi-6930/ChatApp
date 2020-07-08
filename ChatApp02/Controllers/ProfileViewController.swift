//
//  ProfileViewController.swift
//  ChatApp02
//
//  Created by 岩元喜輝 on 2020/07/08.
//  Copyright © 2020 Yoshiki Iwamoto. All rights reserved.
//


import UIKit
import Firebase
import Nuke



class ProfileViewController: UIViewController{
    
    
    private var user:Users?{
        didSet{
            guard let user = user else { return }
            usernameTextField.text = user.username
            emailLabel.text = user.email
            let urlString = user.profileImageUrl
//            guard let url = URL(string: urlString) else {return}
//            [btnProfilePic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@url]]] forState:UIControlStateNormal];
//            Nuke.loadImage(with: url, into: profileImageButton.imageView!)
            let image:UIImage = UIImage(url: urlString)
            profileImageButton.setImage(image, for: .normal)
            profileImageButton.clipsToBounds = true
            
        }
    }
    
    @IBOutlet weak var profileImageButton: UIButton!
    
   
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var changeProfileButton: UIButton!
    var changeColor = ChangeColor()
    
    var gradientLayer = CAGradientLayer()
//    var chatListVC = ChatListViewController()

    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
        profileImageButton.layer.cornerRadius = 90
        profileImageButton.layer.borderColor = UIColor.lightGray.cgColor
        profileImageButton.layer.borderWidth = 1
       
        navigationController?.navigationBar.isHidden = true
        
        gradientLayer = changeColor.changeColor(topR:0.27,topG:0.53,topB:0.56,topAlpha:1.0,
                                                bottomR:0.84,bottomG:0.54,bottomB:0.56,bottomAlpha:0.74)

        gradientLayer.frame = view.bounds 
        view.layer.insertSublayer(gradientLayer, at: 0)


//        chatListVC.delegate = self

        usernameTextField.layer.cornerRadius = 13

        usernameTextField.delegate = self
        changeProfileButton.layer.cornerRadius = 12
        changeProfileButton.isEnabled = false
        changeProfileButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
         
    }
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
       fetchLoginUserInfo()
    }
   

    
    @IBAction func profileImageTap(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        presentPhotoActionSheet()
    }
    
    private func fetchLoginUserInfo(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).addSnapshotListener
        { (snapshot, err) in
                   if let err = err{
                       print("ログインユーザーの取得に失敗しました \(err)")
                       return
                   }
                   guard let dic = snapshot?.data() else { return }
                   let user = Users(dic: dic)
                   self.user = user
               }
    }
    
    
    @IBAction func changeProfileTap(_ sender: Any) {
    
    guard let image = profileImageButton.imageView?.image else {
        alertUserLoginError(message: "プロフィール画像を選択してください")
            return
        }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else {
            return
        }
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        storageRef.putData(uploadImage, metadata: nil) { (metaData, err) in
            if let err = err{
                print("storageへの情報の保存に失敗しました\(err)")
                return
            }
            print("storageへの情報の保存に成功しました")
            storageRef.downloadURL { (url, err) in
                if let err = err{
                    print("storageからのダウンロードに失敗しました\(err)")
                    return
                }
                guard let urlString = url?.absoluteString else { return }
                self.changeUserInfo(profileImageUrl: urlString)
            }
        }
    }
    
    private func changeUserInfo(profileImageUrl:String){

            guard let username = self.usernameTextField.text else {
                alertUserLoginError()
                return
        }
        guard let user = self.user else { return }
        if user.uid == Auth.auth().currentUser?.uid {

            let docData = [
            "username":username,
            "profileImageUrl": profileImageUrl
            ] as [String : Any]
            Firestore.firestore().collection("users").document(user.uid).updateData(docData) { (err) in
                if let err = err {
                    print("プロフィール情報の更新に失敗しました\(err)")
                    return
                }
                print("プロフィール情報の更新に成功しました")
               
            }
        }
    }

    func alertUserLoginError(message:String = "正確に入力して下さい") {
           let alert = UIAlertController(title: "エラー",
                                         message: message,
                                         preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "キャンセル",
                                         style: .cancel,
                                         handler: nil))
           
           present(alert, animated: true, completion: nil)
       }

    
  
}

extension ProfileViewController:UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {

        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? false
        if usernameIsEmpty{
            changeProfileButton.isEnabled = false
            profileImageButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        }else{
            changeProfileButton.isEnabled = true
            changeProfileButton.backgroundColor = .rgb(red: 35, green: 136, blue: 219)
        }
    }
}

extension ProfileViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func presentPhotoActionSheet() {
           let actionSheet = UIAlertController(title: "プロフィール画像",
                                               message: "選択してください",
                                               preferredStyle: .actionSheet)
           actionSheet.addAction(UIAlertAction(title: "キャンセル",
                                               style: .cancel, handler: nil))
           actionSheet.addAction(UIAlertAction(title: "写真を撮る",
                                               style: .default, handler: { [weak self] _ in
                                                   self?.takePicture()
           }))
           actionSheet.addAction(UIAlertAction(title: "アルバムから選択",
                                               style: .default, handler: { [weak self] _ in
                                                   self?.chooseFromAlbum()
           }))
           
           present(actionSheet, animated: true, completion: nil)
       }
       
       func takePicture() {
           let vc = UIImagePickerController()
           vc.sourceType = .camera
           vc.delegate = self
           vc.allowsEditing = true
           present(vc, animated: true, completion: nil)
       }
       
       func chooseFromAlbum() {
           let vc = UIImagePickerController()
           vc.sourceType = .photoLibrary
           vc.delegate = self
           vc.allowsEditing = true
           present(vc, animated: true, completion: nil)
       }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage{
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }else if let originalImage = info[.originalImage] as? UIImage{
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.clipsToBounds = true
        
        
        dismiss(animated: true, completion: nil)
    }
}

//extension ProfileViewController:ProfileInfomationdelegate{
//    func setUpProfile(user: Users) {
//        self.user = user
//}
//
//}
          

