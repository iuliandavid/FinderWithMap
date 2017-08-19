//
//  AppDelegate.swift
//  FinderWithMap
//
//  Created by iulian david on 8/17/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        //login test
        //user is not logged in
        guard let _ = Auth.auth().currentUser?.uid else {
            perform(#selector(handleLogin), with: nil, afterDelay: 0)
            return false
        }
        return true
    }

    @objc private func handleLogin() {
        Login.login()
    }
    
}

