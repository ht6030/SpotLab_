//
//  URLConverter.m
//  Memoris
//
//  Created by 高橋 弘 on 2014/05/01.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import "URLCodec.h"

@implementation URLCodec

// エンコード
+ (NSString*)encode:(NSString*)str
{
    NSString* resultStr = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                               (CFStringRef)str,
                                                                                               NULL,
                                                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                               kCFStringEncodingUTF8));
    return resultStr;
}

// デコード
+ (NSString*)decode:(NSString*)str
{
    NSString *resultStr = (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                 (CFStringRef) str,
                                                                                                                 CFSTR(""),
                                                                                                                 kCFStringEncodingUTF8));
    return resultStr;
}

@end
