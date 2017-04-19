//
//  AppDelegate.swift
//  Butler
//
//  Created by blackbriar on 8/18/16.
//  Copyright © 2016 com.teressa. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerNotification()
        return true
    }
    
    func registerNotification() {
        
        // create notification actions
        // view in map action
        let openAction = UIMutableUserNotificationAction()
        openAction.identifier = "openAction"
        openAction.title = "View on Map"
        openAction.activationMode = UIUserNotificationActivationMode.foreground
        openAction.isAuthenticationRequired = true
        openAction.isDestructive = false
        
        // mute action
        let resetAction = UIMutableUserNotificationAction()
        resetAction.identifier = "muteAction"
        resetAction.title = "Mute location"
        resetAction.activationMode = UIUserNotificationActivationMode.background
        resetAction.isDestructive = true
    
        // create category
        let mapCategory = UIMutableUserNotificationCategory()
        mapCategory.identifier = "Map_Category"
        // set actions for context
        mapCategory.setActions([openAction, resetAction],
                                   for: UIUserNotificationActionContext.default)
        mapCategory.setActions([openAction, resetAction],
                                   for: UIUserNotificationActionContext.minimal)
        // register notifcations settings
        let types: UIUserNotificationType = [.alert, .sound]
        let settings = UIUserNotificationSettings(types: types, categories: NSSet(object: mapCategory) as? Set<UIUserNotificationCategory>)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.teressa.Butler" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Butler", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        if identifier == "openAction" {
            (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
        }
        else if identifier == "muteAction" {
            do {
                let request =  NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
                let titlePredicate = NSPredicate(format: "title == %@" , notification.alertBody!)
                
                request.predicate = titlePredicate
                let results = try managedObjectContext.fetch(request) as! [Item]
                print("RESULT \(results)")
                print(results.count) // returns 1
                results[0].active = 0
                /*
                 DELETE THE OBJECT
                managedObjectContext.deleteObject(results[0])
                do {
                    try managedObjectContext.save()
                    print("SUCCESFULLY DELETED ITEM")
                }
                catch let error as NSError {
                fatalError("Failed to delete run: \(error)")
                }
                 */
            }
            catch let error as NSError {
                fatalError("Failed to fetch: \(error)")
            }
        }
    }

}

