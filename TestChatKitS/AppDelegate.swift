//
//  AppDelegate.swift
//  TestChatKitS
//
//  Created by 张子豪 on 2019/1/30.
//  Copyright © 2019 张子豪. All rights reserved.
//

import UIKit
import AVOSCloud
import ChatKit
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?

    let LCCKAPPID = "dYRQ8YfHRiILshUnfFJu2eQM-gzGzoHsz"
    let LCCKAPPKEY = "ye24iIK6ys8IvaISMC4Bs5WK"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.registerForRemoteNotification()
        self.customizeNavigationBar()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let loginViewController = LCCKLoginViewController()
        loginViewController.isAutoLogin = true
        loginViewController.setClientIDHandler { (clientID) in
            LCCKUtil.showProgressText("open client ...", duration: 10.0)
            LCChatKitExample.invokeThisMethodAfterLoginSuccess(withClientId: clientID, success: {
                LCCKUtil.hideProgress()
                
                let tabBarControllerConfig = LCCKTabBarControllerConfig()
                self.window?.rootViewController = tabBarControllerConfig.tabBarController;
                
            }, failed: { (error) in
                LCCKUtil.hideProgress()
                print(error)
            })
        }
        
        
        
        // 如果APP是在国外使用，开启北美节点
        // 必须在 APPID 初始化之前调用，否则走的是中国节点。
//        AVOSCloud.setServiceRegion(.US)
        LCChatKit.setAppId(LCCKAPPID, appKey: LCCKAPPKEY)
        // 启用未读消息
        AVIMClient.setUnreadNotificationEnabled(true)
        AVIMClient.setTimeoutIntervalInSeconds(20)
        //添加输入框底部插件，如需更换图标标题，可子类化，然后调用 `+registerSubclass`
        LCCKInputViewPluginTakePhoto.registerSubclass()
        LCCKInputViewPluginPickImage.registerSubclass()
        LCCKInputViewPluginLocation.registerSubclass()
        
        self.window?.rootViewController = loginViewController
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()
        return true
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AVOSCloud.handleRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func customizeNavigationBar()  {
        
//        if UINavigationBar.conforms(to: UIAppearanceContainer.self){
//            UINavigationBar.appearance().tintColor = .white
////            UINavigationBar.appearance().attri
//        }
        
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        LCChatKit.sharedInstance()?.syncBadge()
        
        
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
        
        LCChatKit.sharedInstance()?.syncBadge()
        
    }

    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if application.applicationState == .active{
            // 应用在前台时收到推送，只能来自于普通的推送，而非离线消息推送
            
        }else{
            /*!
             *  当使用 https://github.com/leancloud/leanchat-cloudcode 云代码更改推送内容的时候
             {
             aps = {
             alert = "lcckkit : sdfsdf";
             badge = 4;
             sound = default;
             };
             convid = 55bae86300b0efdcbe3e742e;
             }
             */
            
            LCChatKit.sharedInstance()?.didReceiveRemoteNotification(userInfo)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }
    
    
//    #pragma -
//    #pragma mark - Other Method
//
//    #pragma mark - 初始化UNUserNotificationCenter
    ///=============================================================================
    /// @name 初始化UNUserNotificationCenter
    ///=============================================================================
    
    /**
     * 初始化UNUserNotificationCenter
     */
    func registerForRemoteNotification()  {
        // 使用 UNUserNotificationCenter 来管理通知
        let uncenter = UNUserNotificationCenter.current()
        // 监听回调事件
        uncenter.delegate = self
        //iOS 10 使用以下方法注册，才能得到授权
        uncenter.requestAuthorization(options: [.alert,.badge,.sound]) { (granted, error) in
            DispatchQueue.main.sync {
                UIApplication.shared.registerForRemoteNotifications()
            }
            //TODO:授权状态改变
            print("授权状态改变")
            print(granted ? "授权成功" : "授权失败")
            print(error as Any)
        }
        // 获取当前的通知授权状态, UNNotificationSettings
        uncenter.getNotificationSettings { (settings) in
            print("settings是\n下面👇")
            print(settings)
            
            /*
             UNAuthorizationStatusNotDetermined : 没有做出选择
             UNAuthorizationStatusDenied : 用户未授权
             UNAuthorizationStatusAuthorized ：用户已授权
             */
            if settings.authorizationStatus == .notDetermined{
                print("未选择")
            }else if settings.authorizationStatus == .denied{
                print("未授权")
                
            }else if settings.authorizationStatus == .authorized{
                print("已授权")
                
            }

        }
    }
        
    
//    #pragma mark UNUserNotificationCenterDelegate
//
//    #pragma mark - 添加处理 APNs 通知回调方法
    ///=============================================================================
    /// @name 添加处理APNs通知回调方法
    ///=============================================================================
    
    
//    #pragma mark -
//    #pragma mark - UNUserNotificationCenterDelegate Method
//
//    #if XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8

    /**
     * Required for iOS 10+
     * 在前台收到推送内容, 执行的方法
     */
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) ?? false{
            //TODO:处理远程推送内容
            print("远程推送内容")
            print(userInfo)
        }
        completionHandler(.alert)
    }
    
    /**
     * Required for iOS 10+
     * 在后台和启动之前收到推送内容, 点击推送后执行的方法
     */
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) ?? false{
            //TODO:处理远程推送内容
            print("处理远程推送内容")
            print(userInfo)
        }
        completionHandler()
        
    }
    
//    #pragma mark -
//    #pragma mark - UIApplicationDelegate Method
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("userInfo")
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("无法注册远程提醒, 错误信息","\(error)")
    }
}

