//
//  ChatViewController.swift
//  FirebaseChat
//
//  Created by Sahil Dhawan on 11/10/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController
import Firebase

class ChatViewController : JSQMessagesViewController {
    
    var firebaseRef : DatabaseReference?
    var channel : Channel? {
        didSet {
            title = channel?.name
        }
    }
    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView = self.setupIncomingBubble()
    
    private lazy var messageRef : DatabaseReference = (firebaseRef?.child("messages"))!
    private var messageRefHandle : DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = title!
        self.senderId = Auth.auth().currentUser?.uid
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        observeMessages()
    }
    
    
    
    // adding message
    private func addMessage(id : String , name : String , description : String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: description) {
            messages.append(message)
        }
    }
    
    // collection view data source
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // message cell bubble color
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    // cell text label color
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            cell.textView.textColor = UIColor.white
        } else {
            cell.textView.textColor = UIColor.black
        }
        return cell
    }
    
    //removing avatars
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "senderId" : senderId ,
            "name" : senderDisplayName , 
            "text" : text!
        ]
        itemRef.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    
    private func observeMessages(){
        messageRefHandle = messageRef.observe(.childAdded, with: { (snapshot) in
            let messageData = snapshot.value as! Dictionary<String, String>
            if let id = messageData["senderId"] as String! , let name = messageData["name"] as String! , let text = messageData["text"] as String!, text.characters.count > 0 {
                self.addMessage(id: id, name: name, description: text)
                self.finishSendingMessage()
            }else {
                print("Couldn't Receive messages")
            }
        })
    }
}
