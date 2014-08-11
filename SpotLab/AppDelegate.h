//
//  AppDelegate.h
//  Memoris
//
//  Created by 高橋 弘 on 2014/03/23.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FS_CLIENT_ID       @"EQV3AQWPZOOAINWCFBUCZDGNLE5WEDX3P0HC5QGF2OG0CCIS"
#define FS_CLIENT_SECRET   @"JISUTSGRFSRNHPBI4UIAPO0BZKPHCKC23GJUEV1ZLCSOSN3Q"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (void)saveCookies; // 全クッキーの保存
+ (void)loadCookies; // 全クッキーのロード
+ (void)wipeCookies; // 全クッキーの削除

@end
