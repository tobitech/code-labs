//
//  AppDelegate.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 29/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications
import FBSDKCoreKit
import AWSCore
import Fabric
import Crashlytics
import DropDown
import CoreData
import Flurry_iOS_SDK
import StoreKit
import AVFoundation
import FirebaseCore
import FirebaseDynamicLinks

let kAppDelegate = UIApplication.shared.delegate as! AppDelegate
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var user: User?
    weak var mainTabbar: TabBarVC?
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    var isDevEnv: Bool = true
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont.systemFont(ofSize: 16)
        UIApplication.shared.statusBarStyle = .lightContent
        
        FirebaseApp.configure()
        setupTabBarAppearance()
        setupFlurry()
        setupKount()
        startMonitoringConnectivity()
        setupAWS()
        setupSound(isPrimary: false)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.disabledToolbarClasses = [VerifyPhoneVC.self] 
        DropDown.startListeningToKeyboard()
        
        //TODO REMOVED THIS and PUT PRODUCTION key before release
        
        Fabric.with([Crashlytics.self])
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        CurrencyManager.shared.callCurrenciesAPI()
        if Helpers.isLoggedIn() {
            self.askForPushNotification()
        }
//        window?.rootViewController = UIStoryboard(name: "VideoMain", bundle: nil).instantiateInitialViewController()
        
        //        let vc = VerifyPhoneVC.instantiate(fromAppStoryboard: .auth)
        //        vc.viewModel = SignupViewModel()
        //        window?.rootViewController = vc
        return true
    }
    
    private func setupTabBarAppearance() {
        UITabBar.appearance().barTintColor = UIColor.clear
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIColor(hexString: "#C4C4C4", alpha: 0.1).image()
    }
    
    func setupSound(isPrimary: Bool) {
        //        DispatchQueue.main.asyncAfter(deadline: .now()) {
        do {
            let sessionInstance = AVAudioSession.sharedInstance()
            if isPrimary {
                try sessionInstance.setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
                try sessionInstance.setActive(true)
            }else {
                try sessionInstance.setCategory(AVAudioSession.Category.playback, mode: .default,
                                                options: .mixWithOthers)
                try sessionInstance.setActive(false, options: .notifyOthersOnDeactivation)
            }
        }catch {
            print(error)
        }
        //        }
    }
    
    private func setupAWS() {
        let credential = AWSStaticCredentialsProvider(accessKey: "AKIAJI3HWMF57QRFYPUA", secretKey: "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")
        let region: AWSRegionType = isDevEnv ? .USWest2 : .USEast1
        let config = AWSServiceConfiguration(region: region, credentialsProvider: credential)
        AWSServiceManager.default()?.defaultServiceConfiguration = config
    }
    
    func askForPushNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            guard granted else {
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func setupFlurry() {
        Flurry.startSession("NCHC6CV3T8YYQWMZHB5D", with: FlurrySessionBuilder
            .init()
            .withCrashReporting(true)
            .withLogLevel(FlurryLogLevelNone))
    }
    
    func setupKount() {
        
        KDataCollector.shared().merchantID = Constants.kountMerchantId
        KDataCollector.shared().locationCollectorConfig = KLocationCollectorConfig.passive
        
        // For test Environment
        if isDevEnv {
            KDataCollector.shared().debug = true
            KDataCollector.shared().environment = KEnvironment.test
        } else {
            // For Production Environment
            KDataCollector.shared().environment = KEnvironment.production
        }
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 1. Convert device token to string
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        // 2. Print device token to use for PNs payloads
        print("Device Token: \(token)")
        UserDefaults.standard.set(token, forKey: "deviceId")
        //UIPasteboard.general.string = token //for testnig direct push
        DispatchQueue.global(qos: .background).async {
            self.updateDevicetoken(token: token)
        }
    }
    func updateDevicetoken(token:String) {
        if let user = self.user {
            var request = JSONDictionary()
            request["user_name"] = user.username
            request["user_id"] = user.id
            request["device_token"] = token
            request["device_tpye"] = "ios"
            request["notification_enable"] = true
            APIController.makeRequest(request: TrajilisAPI.updateDeviceToken(param: request)) {(response) in
            }
        }
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        print("Failed to register for remote notifications with error: \(error)")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance()?.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation]) ?? true        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketIOManager.shared.chatVC?.appMovedToBackground()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        SocketIOManager.shared.establishConnection()
        SocketIOManager.shared.chatVC?.applicationDidBecomeActive()        
        Helpers.getCurrentUser()
        
        SavedRecording.removeOldRecordings()
        
        if Helpers.isLoggedIn() && UserDefaults.standard.string(forKey: "deviceId") == nil {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        CurrencyManager.shared.updateSelectedCurrency()
        
        if let terminalNavVC = kAppDelegate.mainTabbar?.viewControllers?.first as? UINavigationController,let termiinalVC = terminalNavVC.viewControllers.first as? TerminalVC {
            termiinalVC.messageVC.viewModel.refresh()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SocketIOManager.shared.disconnect()
    }
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        try? DataStorage.shared.dataStorage.removeAll()
    }
    
    private func startMonitoringConnectivity() {
        do {
            Network.reachability = try Reachability(hostname: "www.google.com")
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print(error)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Trajilis")
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
    func getContext() -> NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    func rateUS() {
        SKStoreReviewController.requestReview()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("got it")
        print(userInfo)
        completionHandler(.newData)
    }
    
}

// handling dynamic links
extension AppDelegate {
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let dynamicLinks = DynamicLinks.dynamicLinks()
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamicLink, error) in
            if (dynamicLink != nil) && !(error != nil) {
                self.handleDynamicLink(dynamicLink)
            }
        }
        if !handled {
            // Handle incoming URL with other methods as necessary
            // ...
        }
        return handled
    }
    
    private func handleDynamicLink(_ dynamicLink: DynamicLink?) -> Bool {
        guard let dynamicLink = dynamicLink,
            let deepLink = dynamicLink.url,
            let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems,
            let linkQueryItem = queryItems.first(where: {return DynamicLinkMode(rawValue: $0.name) != nil})
            else { return false }
        
        let mode = DynamicLinkMode(rawValue: linkQueryItem.name)!
        let value = linkQueryItem.value
        
        
        switch mode {
        case .invite:
            if user == nil {
                UserDefaults.standard.set(value, forKey: "User_Invited_By")
            }
        case .profile: break
            
        }
        return true
    }
    
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        //        if let messageID = userInfo[gcmMessageIDKey] {
        //            print("Message ID1: \(messageID)")
        //        }
        
        // Print full message.
        print("Received displayed notif for ios 10")
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let userInfo = response.notification.request.content.userInfo as? [String: Any] else {return}
        // Print full message.
        print("Printing full messages")
        print(userInfo)
        let application = UIApplication.shared
        if (application.applicationState == UIApplication.State.inactive || application.applicationState == UIApplication.State.background  ) {
            if let aps = userInfo["aps"] as? NSDictionary {
                if let payload = aps["payload"] as? NSDictionary {
                    if let group_id = payload["group_id"] as? String {
                        self.gotoChatGroup(grpId: group_id)
                    }
                }
            }
        }
        
        completionHandler()
    }
    
    private func gotoChatGroup(grpId: String) {
        self.mainTabbar?.selectedIndex = kTabIndex.Terminal.rawValue
        // get terminal screen
        if let navVC = self.mainTabbar?.viewControllers?.first as? UINavigationController {
            navVC.popToRootViewController(animated: false)
            if let terminalVC = navVC.viewControllers.first as? TerminalVC {
                terminalVC.showMessageVCWithGroupId(grpId:grpId)
            }
        }
    }
    
}
