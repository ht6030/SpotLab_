//
//  URLConverter.h
//  Memoris
//
//  Created by 高橋 弘 on 2014/05/01.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLCodec : NSObject

+ (NSString*)encode:(NSString*)str;
+ (NSString*)decode:(NSString*)str;

@end
