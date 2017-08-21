//
//  Login.swift
//  FinderWithMap
//
//  Created by iulian david on 8/19/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import Foundation
import Firebase

let o = Obfuscator(withSalt: [AppDelegate.self, NSObject.self, NSString.self])
class Login {
    
    //Should this fail the app will not run
    static func login() {
        Auth.auth().signIn(withEmail: o.reveal(key: Constants.FIREBASE_EMAIL), password: o.reveal(key: Constants.FIREBASE_KEY), completion: {(user, error) in
            if error != nil {
                fatalError()
            }
        })
    }
}
