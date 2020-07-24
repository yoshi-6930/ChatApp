


import UIKit
import Firebase
import PKHUD



class SignUpViewController: UIViewController {
    
    var changeColor = ChangeColor()
    var gradientLayer = CAGradientLayer()
    var uid:String?
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
  
    @IBOutlet weak var signUpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        profileImageButton.layer.cornerRadius = 90
        profileImageButton.layer.borderColor = UIColor.lightGray.cgColor
        profileImageButton.layer.borderWidth = 1
        
        
        gradientLayer = changeColor.changeColor(topR:0.27,topG:0.53,topB:0.56,topAlpha:1.0,
                                                bottomR:0.84,bottomG:0.54,bottomB:0.56,bottomAlpha:0.74)
        
        gradientLayer.frame = view.bounds 
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        
        emailTextField.layer.cornerRadius = 10
        passwordTextField.layer.cornerRadius = 10
        usernameTextField.layer.cornerRadius = 10
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        signUpButton.layer.cornerRadius = 13
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        
    }
    
   
    
    @IBAction func profileImageTap(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        presentPhotoActionSheet()
    }
    
    
    @IBAction func signUPTap(_ sender: Any) {
        guard let image = profileImageButton.imageView?.image,image != UIImage(named: "camera") else {
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
                self.createUserToFirestore(profileImageUrl: urlString)
            }
        }
    }
    
    private func createUserToFirestore(profileImageUrl:String){
        guard let email = emailTextField.text,let password = passwordTextField.text else {
            alertUserLoginError()
            HUD.hide()
            return
        }
        guard password.count >= 6  else {
            alertUserLoginError(message: "パスワードを正確に入力して下さい")
            HUD.hide()
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err{
                print("会員登録に失敗しました\(err)")
                HUD.hide()
                return
            }
            print("会員登録に成功しました")
            
            guard let uid = res?.user.uid else { return }
            self.uid = uid
            guard let username = self.usernameTextField.text else { return }
            let docData = [
                "username":username,
                "uid":uid,
                "createdAt":Timestamp(),
                "email":email,
                "profileImageUrl": profileImageUrl,
                "hobby":""
                ] as [String : Any]
            Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
                if let err = err{
                    print("ユーザー情報の保存に失敗しました\(err)")
                    HUD.hide()
                    return
                }
                print("ユーザー情報の保存に成功しました")
                HUD.hide()
                let storyboard = UIStoryboard(name: "Hobby", bundle: nil)
                
                let hobbyVC = storyboard.instantiateViewController(withIdentifier: "HobbyViewController") as! HobbyViewController
                hobbyVC.uid = self.uid
                self.navigationController?.pushViewController(hobbyVC, animated: true)
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
    
    
    @IBAction func dontHaveAccountTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SignUpViewController:UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? false
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty{
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        }else{
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = .rgb(red: 35, green: 136, blue: 219)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField.isEditing == true{
            passwordTextField.becomeFirstResponder()
        }else if passwordTextField.isEditing == true {
            usernameTextField.becomeFirstResponder()
        }else{
            signUPTap(self)
            textField.resignFirstResponder()
        }
        return true
    }
    
}

extension SignUpViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
