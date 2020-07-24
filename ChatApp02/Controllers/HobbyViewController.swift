//
//  HobbyViewController.swift
//  ChatApp02
//
//  Created by 岩元喜輝 on 2020/07/22.
//  Copyright © 2020 Yoshiki Iwamoto. All rights reserved.
//

import UIKit
import Firebase
import PKHUD

class HobbyViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var uid:String?
    var changeColor = ChangeColor()
    var gradientLayer = CAGradientLayer()
   
    private var myhobby:String?
    private let hobbies = [
        ["スポーツ","音楽","料理","旅行"],
        ["映画","漫画","アニメ","ゲーム"],
        ["読書","グルメ","美容","ファッション"],
        ["動物","車","YouTube","恋愛"],
        ["ビジネス","お金","健康","アイドル"],
    ]
    
    @IBOutlet weak var hobbyCollectionView: UICollectionView!
    
    @IBOutlet weak var decideButton: UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hobbyCollectionView.allowsMultipleSelection = false
        hobbyCollectionView.delegate = self
        hobbyCollectionView.dataSource = self
        hobbyCollectionView.register(HobbyCollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        decideButton.layer.cornerRadius = 13
        gradientLayer = changeColor.changeColor(topR:0.27,topG:0.53,topB:0.56,topAlpha:1.0,
                                                bottomR:0.84,bottomG:0.54,bottomB:0.56,bottomAlpha:0.74)
        decideButton.isEnabled = false
        decideButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        
        
    }

   
    @IBAction func tappedDecide(_ sender: Any) {
     
        guard let hobby = myhobby else {
            return
        }
        guard let uid = self.uid else { return }
        let docData = [
            "hobby": hobby
        ]
        Firestore.firestore().collection("users").document(uid).updateData(docData) { (err) in
            if let err = err {
                HUD.hide()
                print("趣味情報の保存に失敗しました\(err)")
                return
                
            }
             print("趣味情報の保存に成功しました")
            HUD.hide()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
           return .init(width: collectionView.frame.width, height: 10)
       }
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           let width = (collectionView.frame.width - 10 * 3) / 4
           return .init(width: width, height: 70)
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 5
       }
       func numberOfSections(in collectionView: UICollectionView) -> Int {
           return hobbies.count
       }
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return hobbies[section].count
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = hobbyCollectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! HobbyCollectionViewCell
           cell.backgroundColor = .lightGray
           cell.layer.cornerRadius = 35
        cell.isSelected = false
           cell.hobbyLabel.text = hobbies[indexPath.section][indexPath.row]
           return cell
       }
       
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           
    

        
           let selectedHobby = hobbies[indexPath.section][indexPath.row]
        self.myhobby = selectedHobby
           let cell = hobbyCollectionView.cellForItem(at: indexPath)

        if cell?.isSelected == true{
            cell?.backgroundColor = .systemPink
            decideButton.isEnabled = true
            decideButton.backgroundColor = .rgb(red: 46, green: 168, blue: 149)
        }else{
            cell?.backgroundColor = .lightGray
             decideButton.isEnabled = false
             decideButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        }

          
       }
       func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
           
           let cell = hobbyCollectionView.cellForItem(at: indexPath)
          if cell?.isSelected == true{
                     cell?.backgroundColor = .systemPink
                    decideButton.isEnabled = true
                     decideButton.backgroundColor = .rgb(red: 46, green: 168, blue: 149)
                 }else{
                     cell?.backgroundColor = .lightGray
             decideButton.isEnabled = false
                        decideButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
                 }

       }

       
}

class HobbyCollectionViewCell:UICollectionViewCell {
    
    let hobbyLabel:UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 15)
        label.backgroundColor = .clear
        label.clipsToBounds = true
        return label
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       addSubview(hobbyLabel)
        hobbyLabel.frame.size = self.frame.size
       
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

