//
//  SpotsModel.m
//  SpotLab
//
//  Created by 高橋 弘 on 2014/09/12.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import "SpotsModel.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "DataManager.h"
#import <MapKit/MapKit.h>

@implementation SpotsModel

- (void)getSpotsListWithQuery:(NSString *)query location:(CLLocationCoordinate2D)coordinate
{
    //DataManager *data = [DataManager sharedManager];
    
    if (coordinate.latitude == 0.0) {
        coordinate.latitude = 35.685175;
    }
    if (coordinate.longitude == 0.0) {
        coordinate.longitude = 139.752799;
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=%@&client_secret=%@&v=20130815&ll=%f,%f&query=%@", FS_CLIENT_ID, FS_CLIENT_SECRET, coordinate.latitude, coordinate.longitude, query];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        //NSArray *venuesArray = [[responseObject objectForKey:@"response"] objectForKey:@"venues"];
        //[data setFav_friend_list:venuesArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SpotsModel_GetSpots object:self userInfo:responseObject];
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

@end
