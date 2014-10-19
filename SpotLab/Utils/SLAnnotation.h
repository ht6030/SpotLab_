//
//  MKAnnotation.h
//  Memoris
//
//  Created by 高橋 弘 on 2014/04/04.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SLAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSDictionary *attributes;

- (id)initWithCoordinate:(CLLocationCoordinate2D)co;
- (id)initWithCoordinate:(CLLocationCoordinate2D)co attributes:(NSDictionary *)attributes;

@end
