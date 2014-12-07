//
//  AppDelegate.swift
//  SpotLab
//
//  Created by 高橋 弘 on 2014/11/16.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//


import UIKit

//#define FS_CLIENT_ID       "EQV3AQWPZOOAINWCFBUCZDGNLE5WEDX3P0HC5QGF2OG0CCIS"
//#define FS_CLIENT_SECRET   "JISUTSGRFSRNHPBI4UIAPO0BZKPHCKC23GJUEV1ZLCSOSN3Q"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
        window?.backgroundColor = UIColor.whiteColor();
        
        self.setAFNetworkActivityLogger();
        self.setAppirater();
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func setAFNetworkActivityLogger() {
        
        var myStr:String = "hogeha";
        NSLog("myStr:%@", myStr);
        
        AFNetworkActivityLogger.sharedLogger().startLogging();
        AFNetworkActivityLogger.sharedLogger().level = AFHTTPRequestLoggerLevel.AFLoggerLevelDebug;
        //NSLog("NSLog:setAFNetworkActivityLogger");
        //println("println:setAFNetworkActivityLogger");
        //[[AFNetworkActivityLogger sharedLogger] startLogging];
        //[[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
    }
    
    func setAppirater() {
        // App Store id
        Appirater.setAppId("000000000");
        // インストール後、再びメッセージを表示するまでの日数。(デフォルト:30日)
        Appirater.setDaysUntilPrompt(30);
        // 「後で見る」を選択したときにメッセージを再び表示するまでの日数。(デフォルト:1日)
        Appirater.setTimeBeforeReminding(1);
        // 再びメッセージを表示するまでの起動回数。(デフォルト:20回)
        Appirater.setUsesUntilPrompt(20);
        
        // ユーザーがアプリ内で何か特別な操作をしたときに意図的にメッセージを表示するか否か。(デフォルト:-1)
        // 値 : -1=無効, 1=有効
        // 表示する場合は、任意の箇所に [Appirater userDidSignificantEvent:YES] を呼ぶ。
        Appirater.setSignificantEventsUntilPrompt(-1);
        
        //　自分のLocalizedFilesを使いたい時に指定
        //Appirater.setAlwaysUseMainBundle(YES);
        
        // デバッグモードの有無。YESにすると起動の度に表示される。(デフォルト:NO)
        #if DEBUG
        //Appirater.setDebug(true);
        #endif
        
        Appirater.appLaunched(true);
        //[Appirater appLaunched:YES];
    }
}

