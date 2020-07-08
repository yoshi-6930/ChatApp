//
//  LoginViewController.swift
//  ChatApp02
//
//  Created by 岩元喜輝 on 2020/07/08.
//  Copyright © 2020 Yoshiki Iwamoto. All rights reserved.
//



import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    
    
    var changeColor = ChangeColor()
    var gradientLayer = CAGradientLayer()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
        LoginButton.isEnabled = false
        LoginButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        imageView.layer.cornerRadius = 80
        LoginButton.layer.cornerRadius = 13
        
       
        gradientLayer = changeColor.changeColor(topR:0.27,topG:0.53,topB:0.56,topAlpha:1.0,
                                                bottomR:0.84,bottomG:0.54,bottomB:0.56,bottomAlpha:0.74)
        
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)

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
    

    

    @IBAction func tappedLoginButton(_ sender: Any) {
        guard let email = emailTextField.text,let password = passwordTextField.text else {
             alertUserLoginError()
            return
        }
        guard password.count >= 6 else {
             alertUserLoginError(message: "パスワードを正確に入力して下さい")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err{
                print("ログインに失敗しました\(err)")
            }
//           let storyboard = UIStoryboard(name: "ChatList", bundle: nil)
//           let chatListVC = storyboard.instantiateViewController(identifier: "ChatListViewController") as! ChatListViewController
//            chatListVC.fetchChatroomInfoFromFirestore()
//            
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    @IBAction func alreadyHaveAccountButton(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
//
//        let signupVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.popViewController(animated: true)
    }
}

extension LoginViewController:UITextFieldDelegate{
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        if emailIsEmpty || passwordIsEmpty{
            LoginButton.isEnabled = false
            LoginButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        }else{
            LoginButton.isEnabled = true
            LoginButton.backgroundColor = .rgb(red: 61, green: 161, blue: 157)
        }
        
    }
}
