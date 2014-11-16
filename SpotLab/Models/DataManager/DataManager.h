//
//  DataManager.h
//  SpotLab
//
//  Created by 高橋 弘 on 2014/09/12.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

// シングルトンインスタンスを返す
+ (DataManager *)sharedManager;

@end
