//
//  ChatRoomTableViewCell.swift
//  ChatApp02
//
//  Created by 岩元喜輝 on 2020/07/08.
//  Copyright © 2020 Yoshiki Iwamoto. All rights reserved.
//



import UIKit
import Nuke
import Firebase

class ChatRoomTableViewCell: UITableViewCell {
    var message:Messages?

    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var partnerMessageTextviewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var myMessageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var partnerImageView: UIImageView!
    @IBOutlet weak var partnerMessageTextView: UITextView!
    @IBOutlet weak var partnerDateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        partnerImageView.layer.cornerRadius = 30
        partnerMessageTextView.layer.cornerRadius = 15
        messageTextView.layer.cornerRadius = 15
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

         checkWhichMessage()
      
    }
    private func checkWhichMessage(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if uid == message?.uid{
            messageTextView.isHidden = false
            myDateLabel.isHidden = false
            partnerImageView.isHidden = true
            partnerMessageTextView.isHidden = true
            partnerDateLabel.isHidden = true
            guard let message = message else { return }
            let width = estimateFrameTextView(text: message.message).width + 20
            myMessageWidthConstraint.constant = width
            messageTextView.text = message.message
            myDateLabel.text = dateFormatterForDate(date: message.createdAt.dateValue())
        }else{
            messageTextView.isHidden = true
            myDateLabel.isHidden = true
            partnerImageView.isHidden = false
            partnerMessageTextView.isHidden = false
            partnerDateLabel.isHidden = false
            guard let urlString = message?.partnerUser?.profileImageUrl,let url = URL(string: urlString) else { return }
            
            Nuke.loadImage(with: url, into: partnerImageView)
            
            guard let message = message else { return }
            let width = estimateFrameTextView(text: message.message).width + 20
            partnerMessageTextviewWidthConstraint.constant = width
            partnerMessageTextView.text = message.message
            partnerDateLabel.text = dateFormatterForDate(date: message.createdAt.dateValue())
            
        }
    }
    private func estimateFrameTextView(text:String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil)
    }

    private func dateFormatterForDate(date:Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
        
    }
}

