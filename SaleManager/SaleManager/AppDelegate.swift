//
//  AppDelegate.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //MARK: - 程序启动完成后处理的事件
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        /*
         设置窗口根控制器，并显示
         目前设置的是每次重新启动都要输入密码，所以启动时候的根控制器都是登录控制器。
         */
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = SAMLoginController()
        window?.makeKeyAndVisible()
        
        //监听界面跳转通知
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.loginSuccess(_:)), name: NSNotification.Name(rawValue: LoginSuccessNotification), object: nil)
        
        return true
    }
    
    //MARK: - 登录成功后的跳转操作
    func loginSuccess(_ notification: Notification) {
        let anim = CATransition()
        anim.type = "fade"
        anim.duration = 0.7
        window?.layer.add(anim, forKey: nil)
        window?.rootViewController = SAMMainTabBarController()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

