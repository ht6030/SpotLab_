//
//  MKAnnotation.m
//  Memoris
//
//  Created by 高橋 弘 on 2014/04/04.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import "HTAnnotation.h"

@implementation HTAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)co
{
    self.coordinate = co;
    return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)co attributes:(NSDictionary *)attributes
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.coordinate = co;
    self.attributes = attributes;
    self.title      = [self.attributes valueForKey:@"name"];
    
    return self;
}

@end
