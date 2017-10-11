//
//  Channel.swift
//  FirebaseChat
//
//  Created by Sahil Dhawan on 11/10/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import Foundation

class Channel : NSObject {
    var id : String = ""
    var name : String = ""
    
    init(_ id : String , _ name : String){
        self.id = id
        self.name = name
    }
}
