//
//  AppDelegate.m
//  Memoris
//
//  Created by 高橋 弘 on 2014/03/23.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkActivityLogger.h"
#import "Appirater.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //[AppDelegate loadCookies];
    [self setFugafuga:@"hogehoge"];
    //NSLog(@"[self getFugafuga] = %@", [self getFugafuga]);
    
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
    
    
    // App Store id
    [Appirater setAppId:@"000000000"];
    
    // インストール後、再びメッセージを表示するまでの日数。(デフォルト:30日)
    [Appirater setDaysUntilPrompt: 30];
    
    // 「後で見る」を選択したときにメッセージを再び表示するまでの日数。(デフォルト:1日)
    [Appirater setTimeBeforeReminding: 1];
    
    // 再びメッセージを表示するまでの起動回数。(デフォルト:20回)
    [Appirater setUsesUntilPrompt: 20];
    
    // ユーザーがアプリ内で何か特別な操作をしたときに意図的にメッセージを表示するか否か。(デフォルト:-1)
    // 値 : -1=無効, 1=有効
    // 表示する場合は、任意の箇所に [Appirater userDidSignificantEvent:YES] を呼ぶ。
    [Appirater setSignificantEventsUntilPrompt: -1];
    
    //　自分のLocalizedFilesを使いたい時に指定
    //[Appirater setAlwaysUseMainBundle: YES];
    
    // デバッグモードの有無。YESにすると起動の度に表示される。(デフォルト:NO)
    #ifdef DEBUG
    [Appirater setDebug: YES];
    #endif
    
    [Appirater appLaunched:YES];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [AppDelegate saveCookies];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [AppDelegate loadCookies];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [AppDelegate saveCookies];
}


#pragma mark- Cookie Handler

// fugafugaという名前のCookieに値を設定する
- (void)setFugafuga:(NSString *)fugafuga
{
    // ストレージを取得する
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [storage setCookieAcceptPolicy: NSHTTPCookieAcceptPolicyAlways];
    
    // Cookieを作成する
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:@"fugafuga" forKey: NSHTTPCookieName];                                     /* 名前 */
    [properties setValue:fugafuga forKey: NSHTTPCookieValue];                                       /* 値 */
    [properties setValue:@"http://yourdomain.com" forKey: NSHTTPCookieDomain];                      /* ドメイン */
    
    // 有効期限をDateで設定します。ここでは、２時間にしています。
    [properties setObject:[[NSDate date] dateByAddingTimeInterval:7200] forKey:NSHTTPCookieExpires]; /* 有効期限 */
    [properties setValue:@"/" forKey:NSHTTPCookiePath];                                             /* パス設定 */
    
    // Cookieをストレージに設定する
    [self deleteAllCookies];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    [storage setCookie:cookie];
    //[storage setCookies:[[NSArray alloc] initWithObjects:cookie, nil] forURL:[NSURL URLWithString:@"http://yourdomain.com"] mainDocumentURL:nil];

    
    NSLog(@"storage.cookies.count = %lu",(unsigned long)storage.cookies.count);
    NSLog(@" Cookie %@ was set with value %@", cookie.name, cookie.value);
}

// Fugafugaという名前のCookieの値を取得する
- (NSString *)getFugafuga
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //NSArray *cookies = [storage cookiesForURL:[NSURL URLWithString:@"http://yourdomain.com"]];
    NSArray *cookies = [storage cookies];
    NSLog(@"cookies.count = %lu",(unsigned long)cookies.count);
    
    // Cookie処理ループ
    for (NSHTTPCookie *cookie in cookies) {
        // 目的のCookieが見つかったら値を返す
        if ([cookie.name isEqualToString: @"fugafuga"]) {
            NSString *fugafuga = cookie.value;
            return fugafuga;
        }
    }
    return nil;
}


// クッキーを削除する（セッション以外）
- (void)deleteAllCookies
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    // ↓URLには、ドメイン名を指定します。
    NSArray *cookies = [storage cookiesForURL:[NSURL URLWithString:@"http://yourdomain.com"]];
    
    // Cookie処理ループ
    for (NSHTTPCookie *cookie in cookies) {
        // WEBのセッション以外を消す
        if (![cookie.name isEqualToString: @"fugafuga_web_session"]) {
            [storage deleteCookie: cookie];
        }
    }
}


+ (void)saveCookies
{
    NSLog(@"%s", __func__);
    NSLog(@"cookies.count:%lu",(unsigned long)[[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] count]);
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:kCookieStore];
}


+ (void)loadCookies
{
    NSLog(@"%s", __func__);
    NSData *cookiesData = [[NSUserDefaults standardUserDefaults] objectForKey:kCookieStore];
    if (cookiesData) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];
        for (NSHTTPCookie *cookie in cookies) {
            NSLog(@"cookie:%@",cookie);
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
}

+ (void)wipeCookies
{
    NSLog(@"%s", __func__);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCookieStore];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (id obj in [cookieStorage cookies]) {
        [cookieStorage deleteCookie:obj];
    }
}

@end
