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
import Firebase
import FirebaseMessaging
import CoreData
import CallerData
import CallKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var navVC: UINavigationController?
    
    var caller: Caller? {
        didSet {
            //            self.updateUI()
        }
    }
    
    lazy private var callerData = CallerData()
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        application.registerForRemoteNotifications()
        Messaging.messaging().isAutoInitEnabled = true
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        //        FirebaseApp.configure()
        
        setupViewController()
        
        setupInAppPurchase()
        
        //        CheckFonts()
        
        //        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //        print("DB Location: ",urls[urls.count-1] as URL)
        //
        //        getCoreDataDBPath()
        
        //        registerBackgroundTask(60)
        
        //        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        //        UserDefaults.standard.set("", forKey: "ABC")
        //        UserDefaults.standard.synchronize()
        
//        let abc = UserDefaults.standard.value(forKey: "ABC")
//        print("abc ====> ", abc ?? "")
        
        return true
    }
    
    //    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    //        print("\(Date()) perfom bg fetch")
    //        completionHandler(.newData)
    //    }
    
    //    func getCoreDataDBPath() {
    //        let path = FileManager
    //            .default
    //            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
    //            .last?
    //            .absoluteString
    //            .replacingOccurrences(of: "file://", with: "")
    //            .removingPercentEncoding
    //
    //        print("Core Data DB Path :: \(path ?? "Not found")")
    //    }
    
    //    func registerBackgroundTask(_ durationSec : Double = 60 ) {
    //        let duration : DispatchTime = DispatchTime.now() + durationSec
    //        DispatchQueue.global(qos: .background).asyncAfter(deadline: duration, qos: .background) {
    //                print("fasdf")
    //                // customize it!
    //            }
    //    }
    //
    //    func applicationDidEnterBackground(_ application: UIApplication) {
    //
    //        application.beginBackgroundTask {[weak self] in
    //            self?.registerBackgroundTask(5 * 60)
    //        }
    //    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
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
    
    //    // MARK: - Core Data stack
    //
    //    lazy var persistentContainer: NSPersistentContainer = {
    //        /*
    //         The persistent container for the application. This implementation
    //         creates and returns a container, having loaded the store for the
    //         application to it. This property is optional since there are legitimate
    //         error conditions that could cause the creation of the store to fail.
    //        */
    //        let container = NSPersistentContainer(name: "Coverage_call_blocker")
    //        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
    //            if let error = error as NSError? {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //
    //                /*
    //                 Typical reasons for an error here include:
    //                 * The parent directory does not exist, cannot be created, or disallows writing.
    //                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
    //                 * The device is out of space.
    //                 * The store could not be migrated to the current model version.
    //                 Check the error message to determine what the actual problem was.
    //                 */
    //                fatalError("Unresolved error \(error), \(error.userInfo)")
    //            }
    //        })
    //        return container
    //    }()
    //
    //    // MARK: - Core Data Saving support
    //
    //    func saveContext () {
    //        let context = persistentContainer.viewContext
    //        if context.hasChanges {
    //            do {
    //                try context.save()
    //            } catch {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //                let nserror = error as NSError
    //                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    //            }
    //        }
    //    }
    
}

extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate{
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("\(#function) Error: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UNUserNotificationCenter) {
        application.registerForRemoteNotifications()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("Firebase registration token: \(String(describing: fcmToken))")
        //        UserDefaults.standard.setValue(fcmToken, forKey: "fcmToken")
        //        UserDefaults.standard.synchronize()
        //        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        //        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
    }
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        print("Notification info : ", userInfo)
        
        completionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        print("Notification info : ", userInfo)
        //        let Aps = userInfo["aps"] as! [String: AnyObject]
        //        let type = "\(userInfo["type"] as? String ?? "")"
        //        let body = "\(userInfo["body"] as? String ?? "")"
        
        completionHandler()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Perform background operation
        //        self.saveOrInsertData(name: "Kartik", number: 919773442279)
        
        if let value = userInfo["number"] as? String {
            print(value) // output: "some-value"
            
            let numberArray = value.components(separatedBy: ",")
            
            if numberArray.count > 0{
                for i in 0...numberArray.count - 1 {
                    print("Start blocking at : ", Date())
                    print("name : ", "spam\(i)")
                    print("number : ", Int64(numberArray[i]) ?? 0)
                    self.saveOrInsertData(name: "spam\(i)", number: Int64(numberArray[i]) ?? 0)
                    sleep(UInt32(2))
                }
//                UserDefaults.standard.set(numberArray.count, forKey: "ABC")
//                UserDefaults.standard.synchronize()
            }
            
        }
        
        // Inform the system after the background operation is completed.
        completionHandler(.newData)
    }
    
    
}

extension AppDelegate{
    
    func saveOrInsertData(name : String, number: Int64){
        //        let context = self.callerData.context
        //        let privateManagedObjectContext: NSManagedObjectContext = {
        //            let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        //            moc.parent = context
        //            return moc
        //        }()
        
        //        let caller = NSEntityDescription.insertNewObject(forEntityName: "Caller", into: privateManagedObjectContext) as! Caller
        let caller = self.caller ?? Caller(context: self.callerData.context)
        caller.name = name
        caller.number = number
        caller.isFromContacts = false
        caller.isBlocked = true
        caller.isRemoved = false
        caller.updatedDate = Date()
        //        privateManagedObjectContext.perform {
        //            do {
        //                try privateManagedObjectContext.save()
        //            }catch {
        //                print("Something wrong in coredata.")
        //            }
        //        }
        
        self.callerData.saveContext()
        self.reload()
    }
    
    func reload(){
        
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: reloadExtetionString, completionHandler: { (error) in
            if (error == nil) {
                print("End blocking at : ", Date())
                print("======== Blocked successfully.=========")
            }else{
                print("End blocking at : ", Date())
                print("======== Error.=========")
                print("Error reloading extension: \(error?.localizedDescription ?? "")")
            }
        })
    }
}

