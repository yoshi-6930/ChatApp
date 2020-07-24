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
import PKHUD



class ProfileViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    private var user:Users?{
        didSet{
            guard let user = user else { return }
            usernameTextField.text = user.username
            hobbyTextField.text = user.hobby
            let urlString = user.profileImageUrl
            let image:UIImage = UIImage(url: urlString)
            profileImageButton.setImage(image, for: .normal)
            profileImageButton.clipsToBounds = true
            
        }
    }
    
    var pickerView: UIPickerView = UIPickerView()
    var changeColor = ChangeColor()
    var gradientLayer = CAGradientLayer()
    
    private let hobbies = [
        "スポーツ","音楽","料理","旅行",
        "映画","漫画","アニメ","ゲーム",
        "読書","グルメ","美容","ファッション",
        "動物","車","YouTube","恋愛",
        "ビジネス","お金","健康","アイドル"
    ]
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var hobbyTextField: UITextField!
    @IBOutlet weak var changeProfileButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        fetchLoginUserInfo()
        usernameTextField.becomeFirstResponder()
    }
    private func setUpViews(){
        navigationController?.navigationBar.isHidden = true
        profileImageButton.layer.cornerRadius = 90
        profileImageButton.layer.borderColor = UIColor.lightGray.cgColor
        profileImageButton.layer.borderWidth = 1
        
        navigationController?.navigationBar.isHidden = true
        
        gradientLayer = changeColor.changeColor(topR:0.27,topG:0.53,topB:0.56,topAlpha:1.0,
                                                bottomR:0.84,bottomG:0.54,bottomB:0.56,bottomAlpha:0.74)
        
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        usernameTextField.layer.cornerRadius = 13
        
        usernameTextField.delegate = self
        changeProfileButton.layer.cornerRadius = 12
        changeProfileButton.isEnabled = false
        changeProfileButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(doneBtnClicked(_:)))
        toolbar.setItems([doneItem], animated: true)
        
        self.hobbyTextField.inputView = pickerView
        self.hobbyTextField.inputAccessoryView = toolbar
        
    }
    
    @objc private func doneBtnClicked(_ button: UIBarButtonItem?) {
        hobbyTextField?.resignFirstResponder()
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
        HUD.show(.progress)
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        storageRef.putData(uploadImage, metadata: nil) { (metaData, err) in
            if let err = err{
                print("storageへの情報の保存に失敗しました\(err)")
                HUD.hide()
                return
            }
            print("storageへの情報の保存に成功しました")
            storageRef.downloadURL { (url, err) in
                if let err = err{
                    print("storageからのダウンロードに失敗しました\(err)")
                    HUD.hide()
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
            HUD.hide()
            return
        }
        guard let user = self.user else { return }
        guard let hobby = hobbyTextField.text else { return }
        if user.uid == Auth.auth().currentUser?.uid {
            
            let docData = [
                "username":username,
                "hobby":hobby,
                "profileImageUrl": profileImageUrl
                ] as [String : Any]
            Firestore.firestore().collection("users").document(user.uid).updateData(docData) { (err) in
                if let err = err {
                    print("プロフィール情報の更新に失敗しました\(err)")
                    HUD.hide()
                    return
                }
                print("プロフィール情報の更新に成功しました")
                HUD.hide()
                
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hobbies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return hobbies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.hobbyTextField.text = hobbies[row]
    }
    
    func cancel() {
        self.hobbyTextField.text = ""
        self.hobbyTextField.endEditing(true)
    }
    
    func done() {
        self.hobbyTextField.endEditing(true)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}

extension ProfileViewController:UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? false
        let hobbyIsEmpty = hobbyTextField.text?.isEmpty ?? false
        if usernameIsEmpty && hobbyIsEmpty{
            changeProfileButton.isEnabled = false
            changeProfileButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        }else{
            changeProfileButton.isEnabled = true
            changeProfileButton.backgroundColor = .rgb(red: 35, green: 136, blue: 219)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changeProfileTap(self)
        textField.resignFirstResponder()
        return true
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
