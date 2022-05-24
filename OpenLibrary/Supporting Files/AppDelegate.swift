//
//  AppDelegate.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/10/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Limited caching for images and other network responses
        let temporaryDirectory = NSTemporaryDirectory()
        let urlCache = URLCache(memoryCapacity: 50_000_000, diskCapacity: 100_000_000, diskPath: temporaryDirectory)
        URLCache.shared = urlCache
        
        // set the root view controller’s container property to the persistent container
        if let rootVC = window?.rootViewController as? UITabBarController {
            if let searchRootNavigationController = rootVC.viewControllers?[0] as? UINavigationController,
            let booksSearchTableViewController = searchRootNavigationController.topViewController as? BooksSearchTableViewController {
            booksSearchTableViewController.container = persistentContainer
            }
            if let wishListRootNavigationController = rootVC.viewControllers?[1] as? UINavigationController,
            let wishListTableViewController = wishListRootNavigationController.topViewController as?
                WishlistTableViewController {
                wishListTableViewController.container = persistentContainer
            }
        } else {
            print("error setting container for rootViewController")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // Have container save data
        persistentContainer.saveContext()
    }
    
    // Initialize a Persistent Container for Core Data
    lazy var persistentContainer: PersistentContainer = {
        let container = PersistentContainer(name: "BookModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()


}

