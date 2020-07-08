//
//  ChatInputAccessorryView.swift
//  ChatApp02
//
//  Created by 岩元喜輝 on 2020/07/08.
//  Copyright © 2020 Yoshiki Iwamoto. All rights reserved.
//


import UIKit

protocol ChatInputAccessoryViewDelegate:class {
    func tappedSendButton(text: String)
}

class ChatInputAccessoryView: UIView {
    
  
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    weak var delegate:ChatInputAccessoryViewDelegate?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        nibInit()
        setUpViews()
        autoresizingMask = .flexibleHeight
        
    }
    private func nibInit(){
        let nib = UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        self.addSubview(view)
        
       
    }
    
    private func setUpViews(){
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        chatTextView.layer.borderWidth = 1
        
        sendButton.isEnabled = false
        chatTextView.text = ""
        chatTextView.delegate = self
    }
    
    override var intrinsicContentSize: CGSize{
        return .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func tappedSendButton(_ sender: Any) {
        guard let text = chatTextView.text else {
            return
        }
        delegate?.tappedSendButton(text: text)
        
    }
    func removeText(){
        chatTextView.text = ""
        sendButton.isEnabled = false
    }
}

extension ChatInputAccessoryView:UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            sendButton.isEnabled = false
        }else{
            sendButton.isEnabled = true
        }
    }
}

