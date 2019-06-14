//
//  AppDelegate.swift
//  Multithreading
//
//  Created by Vladimir Ozerov on 13/06/2019.
//  Copyright © 2019 Sberbank. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		let frame = UIScreen.main.bounds
		let rootViewController = RootViewController()
		let navigationController = UINavigationController(rootViewController: rootViewController)
		
		let window = UIWindow(frame: frame)
		window.rootViewController = navigationController
		window.makeKeyAndVisible()
		self.window = window
		
		return true
	}
}

