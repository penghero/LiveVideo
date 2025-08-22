//
//  AppDelegate.swift
//  LiveVideo
//
//  Created by chenpeng on 2025/2/17.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        IQKeyboardManager.shared.isEnabled = true
//        IQKeyboardManager.shared.resignOnTouchOutside = true
                
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        // 使用TabBarController作为根控制器
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
        
        return true
    }
}

