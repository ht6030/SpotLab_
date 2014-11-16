//
//  SpotsModel.h
//  SpotLab
//
//  Created by 高橋 弘 on 2014/09/12.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define NOTIF_SpotsModel_GetSpots   @"NOTIF_SpotsModel_GetSpots"

@interface SpotsModel : NSObject

- (void)getSpotsListWithQuery:(NSString *)query location:(CLLocationCoordinate2D)coordinate;

@end
