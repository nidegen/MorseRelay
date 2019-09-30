//
//  AppDelegate.swift
//  MorseRelay
//
//  Created by Nicolas Degen on 11.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

import UIKit
import SwiftUI

import NDKit

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
    let swiftVC = UIHostingController(rootView: EncoderView())
    swiftVC.tabBarItem = UITabBarItem(title: "Swift", image: UIImage(named: "EncoderItem"), tag: 2)
    let tabBarController = UITabBarController()
    let controllers = [encoderVC, decoderVC, swiftVC]
    tabBarController.viewControllers = controllers.map {
      UINavigationController(rootViewController: $0)
    }
    tabBarController.tabBar.barStyle = .black
    
    window!.rootViewController = tabBarController // UIHostingController(rootView: MainView())
    window!.makeKeyAndVisible()
    
    let welcomeScreen = NDWelcomeViewController()
    welcomeScreen.details.append((UIImage(named: "EmittIcon")!, "Text to Morse","Write a text to emitt using the torch"))
    welcomeScreen.details.append((UIImage(named: "ReceiveIcon")!, "Morse to Text","Capture a emitted morse signal with the camera and display it as text"))
    
    welcomeScreen.presentIfNotSeen()
    return true
  }
}

