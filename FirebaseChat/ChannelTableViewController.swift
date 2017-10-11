//
//  ChannelTableViewController.swift
//  FirebaseChat
//
//  Created by Sahil Dhawan on 11/10/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class ChannelTableViewController: UITableViewController {
    
    private var channels : [Channel] = []
     var selectedChannel : Channel?
    var sendersName : String?
    private lazy var channelRef : DatabaseReference = Database.database().reference().child("channels")
    private var channelRefHandle : DatabaseHandle?
    
    
    @IBOutlet weak var channelNameTextField: UITextField!
    @IBOutlet weak var createButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Channel List"
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        observeChannels()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell")
        cell?.textLabel?.text = channels[indexPath.item].name
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChannel = channels[indexPath.item]
        self.performSegue(withIdentifier: "chatSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ChatViewController
        destination.channel = selectedChannel
        destination.firebaseRef = channelRef.child((selectedChannel?.id)!)
        destination.senderDisplayName = sendersName
        
    }
    
    @IBAction func addNewChannel(sender : UIButton){
        if let name = channelNameTextField.text {
            
            let newChannerRef = channelRef.childByAutoId()
            let channelName =
                [
                    "name" : name
            ]
            newChannerRef.setValue(channelName)
            tableView.reloadData()
        }
    }
    
    func observeChannels() {
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) in
            let channelData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if let channelName = channelData["name"] as! String! , channelName.characters.count > 0 {
                self.channels.append(Channel(id , channelName))
                self.tableView.reloadData()
            }else {
                print("Could not get channel list")
            }
        })
    }
}
