//
//  DataManager.m
//  SpotLab
//
//  Created by 高橋 弘 on 2014/09/12.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

static DataManager* sharedDataMgr = nil;

+ (DataManager *)sharedManager
{
    @synchronized(self) {
        if (sharedDataMgr == nil) {
            sharedDataMgr = [[self alloc] init];
//            [sharedDataMgr readUser];
//            [sharedDataMgr readSetting];
//            [sharedDataMgr readLocalSetting];
//            [sharedDataMgr readTopicsCategories];
        }
    }
    return sharedDataMgr;
}

@end
