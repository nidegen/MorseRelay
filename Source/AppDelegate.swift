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
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    let encoderVC = EncoderViewController()
    encoderVC.tabBarItem = UITabBarItem(title: "Encoder", image: UIImage(named: "EncoderItem"), tag: 0)
    let decoderVC = DecoderViewController()
    decoderVC.tabBarItem = UITabBarItem(title: "Decoder", image: UIImage(named: "DecoderItem") , tag: 1)
    let tabBarController = UITabBarController()
    let controllers = [encoderVC, decoderVC]
    tabBarController.viewControllers = controllers.map {
      UINavigationController(rootViewController: $0)
    }
    tabBarController.tabBar.barStyle = .black
    
    window!.rootViewController = tabBarController
    window!.makeKeyAndVisible()
    return true
  }
}

