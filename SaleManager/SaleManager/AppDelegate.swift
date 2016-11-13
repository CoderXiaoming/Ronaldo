//
//  AppDelegate.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

let LoginSuccessNotification = "LoginSuccessNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    //MARK: - 程序启动完成后处理的事件
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        //设置窗口跟控制器，并显示
        window = UIWindow.init(frame: UIScreen.mainScreen().bounds)
//        window?.rootViewController = SAMMainTabBarController()
        window?.rootViewController = SAMLoginController()
        window?.makeKeyAndVisible()
        
        //监听界面跳转通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.loginSuccess(_:)), name: LoginSuccessNotification, object: nil)
        
        return true
    }
    
    func loginSuccess(notification: NSNotification) {
        
        let anim = CATransition()
        anim.type = "fade"
        anim.duration = 0.7;
        window?.layer.addAnimation(anim, forKey: nil)
        
        window?.rootViewController = SAMMainTabBarController()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

