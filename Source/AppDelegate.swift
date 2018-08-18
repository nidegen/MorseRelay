//
//  AppDelegate.swift
//  MorseRelay
//
//  Created by Nicolas Degen on 11.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    let encoderVC = EncoderViewController()
    encoderVC.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
    let decoderVC = CameraPreviewController()
    decoderVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
    let tabBarController = UITabBarController()
    let controllers = [encoderVC, decoderVC]
    tabBarController.viewControllers = controllers.map {
      UINavigationController(rootViewController: $0)
    }
    
    window!.rootViewController = tabBarController
    window!.makeKeyAndVisible()
    return true
  }
}

