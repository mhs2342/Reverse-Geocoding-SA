//
//  AppDelegate.swift
//  Reverse-Geocoding-SA
//
//  Created by Matthew Sanford on 6/19/18.
//  Copyright © 2018 msanford. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let rootVC = UINavigationController(rootViewController: ViewController())
        rootVC.navigationBar.isTranslucent = false
        rootVC.navigationBar.backgroundColor = .white

        window?.rootViewController = rootVC
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.init(red: 231/255,
                                                                green: 60/255,
                                                                blue: 60/255,
                                                                alpha: 1)
        ]

        UIApplication.shared.statusBarStyle = .default
        return true
    }

}

