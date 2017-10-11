//
//  ViewController.swift
//  FirebaseChat
//
//  Created by Sahil Dhawan on 11/10/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBAction func loginButtonPresed(_ sender: Any) {
        if userNameTextField.text != "" {
            Auth.auth().signInAnonymously(completion: { (user, error) in
                if error == nil {
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                    self.userNameTextField.text = ""
                } else {
                    print("\(String(describing: error?.localizedDescription))")
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! UINavigationController
        let channelController = destination.viewControllers.first as! ChannelTableViewController
        channelController.sendersName = userNameTextField.text
    }
    
}

