//
//  FirstViewController.h
//  Memoris
//
//  Created by 高橋 弘 on 2014/03/23.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import <MapKit/MapKit.h>

//#define NOTIF_SpotsModel_GetSpots   @"NOTIF_SpotsModel_GetSpots"

@interface MakeSpotsViewController : UIViewController
<MKMapViewDelegate, UISearchBarDelegate, UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, CLLocationManagerDelegate>

@end
