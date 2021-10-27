//
//  AppDelegate.swift
//  Coverage-call-blocker
//
//  Created by iroid on 01/10/21.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import LGSideMenuController

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navVC: UINavigationController?
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        setupViewController()
        
//        CheckFonts()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func setupViewController(){
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print("countryCode : ", countryCode)
            if countryCode == "IN"
            {
                CountryCode = "+91"
            }
            else{
                CountryCode = "+1"
            }
        }
        
        let loginData = Utility.getUserData()
        
        if loginData == nil{
            let vc =  STORYBOARD.login.instantiateViewController(withIdentifier: "LoginScreen") as! LoginScreen
            navVC = UINavigationController.init(rootViewController: vc)
            navVC?.isNavigationBarHidden = true
            self.navVC?.interactivePopGestureRecognizer?.isEnabled = false
            self.window?.rootViewController = nil
            self.window?.rootViewController = navVC
            self.window?.makeKeyAndVisible()
        }
        else{
            let HomeVc =  STORYBOARD.home.instantiateViewController(withIdentifier: "HomeScreen") as! HomeScreen
            let MenuVc =  STORYBOARD.menu.instantiateViewController(withIdentifier: "MenuScreen") as! MenuScreen

            let rootViewController = HomeVc
            let leftViewController = MenuVc
            let rightViewController = UITableViewController()

            let sideMenuController = LGSideMenuController(rootViewController: rootViewController,leftViewController: leftViewController,rightViewController: rightViewController)

            sideMenuController.leftViewWidth = leftMenuWidth
            sideMenuController.leftViewPresentationStyle = .slideAbove
            sideMenuController.isLeftViewSwipeGestureEnabled = false
            sideMenuController.isRightViewSwipeGestureEnabled = false
            sideMenuController.leftViewBackgroundAlpha = 0.0
            sideMenuController.leftViewWidth = leftMenuWidth
            navVC = UINavigationController.init(rootViewController: sideMenuController)
            navVC?.isNavigationBarHidden = true
            self.navVC?.interactivePopGestureRecognizer?.isEnabled = false
            self.window?.rootViewController = nil
            self.window?.rootViewController = navVC
            self.window?.makeKeyAndVisible()
        }
        
    }
    
    func CheckFonts(){
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
    }

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Coverage_call_blocker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

