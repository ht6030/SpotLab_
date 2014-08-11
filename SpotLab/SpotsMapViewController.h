//
//  SpotsDetailViewController.h
//  Memoris
//
//  Created by 高橋 弘 on 2014/05/17.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SpotsMapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) NSMutableArray *venueArray;

@end
