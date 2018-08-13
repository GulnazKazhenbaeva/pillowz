//
//  ChatViewController.swift
//  Pillowz
//
//  Created by Samat on 09.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MBProgressHUD
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    var room:String!
    
    var ref: DatabaseReference!
    
    var lastId:Int = 0
    
    var messages:[JSQMessage] = []
    
    var myId:Int = User.shared.user_id!
    
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    var chat:Chat!
    
    var firebaseHandle:UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.inputToolbar.contentView?.leftBarButtonItem = nil
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.lightGray)
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: Constants.paletteVioletColor)
        self.collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        self.senderId = String(myId)
        self.senderDisplayName = User.shared.name!
        self.topContentAdditionalInset = 64
        
        ref = Database.database().reference().child("chats").child(room)
        
        
        if (chat != nil) {
            self.title = chat.otherUser.name
        } else {
            
        }
        
        let rightButton = UIButton(frame: CGRect.zero)
        rightButton.fillImageView(image: #imageLiteral(resourceName: "send_button"), color: Constants.paletteVioletColor)
        self.inputToolbar.contentView.rightBarButtonItemWidth = CGFloat(30.0)
        self.inputToolbar.contentView.rightBarButtonItem = rightButton
        
        //getMessages()
    }
    
    override func loadView() {
        super.loadView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        firebaseHandle = ref.observe(DataEventType.value, with: { (snapshot) in
            let serverLastId = snapshot.value as? NSNumber
            // ...
            if (serverLastId != nil) {
                if (self.lastId<serverLastId!.intValue) {
                    print("GOT MESSAGES")
                    self.getMessages()
                }
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ref.removeObserver(withHandle: firebaseHandle)
    }
    
    func getMessages() {
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        
        ChatAPIManager.getMessages(room: room, lastId: lastId) { (newMessagesObject, error) in
            //MBProgressHUD.hide(for: self.view, animated: true)

            if (error == nil) {
                let newMessages = newMessagesObject as! [Message]
                
                for message in newMessages {
                    //updating last id
                    if message.chat_id! > self.lastId {
                        self.lastId = message.chat_id!
                    }
                    
                    var jsqmessage:JSQMessage
                    
                    //let date = message.time
                    
                    let date = Date(timeIntervalSince1970: TimeInterval(message.timestamp))
                    
                    if let userID = message.user?.user_id, let userName = message.user?.name {
                        jsqmessage = JSQMessage(senderId: String(userID), senderDisplayName: userName, date: date, text: message.text!)
                    } else {
                        jsqmessage = JSQMessage(senderId: "0", senderDisplayName: "Pillowz", date: date, text: message.text!)
                    }
                    self.messages.append(jsqmessage)
                    self.finishReceivingMessage(animated: true)
                }
            }
        }
    }
    
    // MARK: JSQMessagesViewController method overrides
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        /**
         *  Sending a message. Your implementation of this method should do *at least* the following:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishSendingMessage`
         */
        
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.inputToolbar.contentView.rightBarButtonItem.isEnabled = false
        
        ChatAPIManager.sendMessage(room: room, text: text) { (messageObject, error) in
            //MBProgressHUD.hide(for: self.view, animated: true)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true

            if (error == nil) {
                //let message = messageObject as! Message
                
//                let jsqmessage = JSQMessage(senderId: String(message.user!.user_id!), senderDisplayName: message.user!.name!, date: Date(), text: message.text!)
//                self.messages.append(jsqmessage)
//                self.finishReceivingMessage(animated: true)
                
                self.inputToolbar.contentView!.textView!.text = ""
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        return messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        //let message = messages[indexPath.item]
        
        return nil//getAvatar(message.senderId)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        /**
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         *  The other label text delegate methods should follow a similar pattern.
         *
         *  Show a timestamp for every 3rd message
         */
        if (indexPath.item % 10 == 0) {
            let message = self.messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        
        // Displaying names above messages
        //Mark: Removing Sender Display Name
        /**
         *  Example on showing or removing senderDisplayName based on user settings.
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         */
        if message.senderId == self.senderId {
            return nil
        }
        
        //if title was not loaded from chat then show it from message
        if self.title == "" || self.title == nil {
            self.title = message.senderDisplayName
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        /**
         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
         */
        
        /**
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         *  The other label height delegate methods should follow similarly
         *
         *  Show a timestamp for every 3rd message
         */
        if indexPath.item % 10 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        /**
         *  Example on showing or removing senderDisplayName based on user settings.
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         */
        /**
         *  iOS7-style sender name labels
         */
        let currentMessage = self.messages[indexPath.item]
        
        if currentMessage.senderId == self.senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
