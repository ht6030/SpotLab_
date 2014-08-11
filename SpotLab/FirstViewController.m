//
//  FirstViewController.m
//  Memoris
//
//  Created by 高橋 弘 on 2014/03/23.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import "FirstViewController.h"
#import "HTAnnotation.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "URLCodec.h"
#import "HTNotification.h"
#import "HTIndicatorBlockView.h"
#import "SpotDetailViewController.h"

@interface FirstViewController ()
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *newBtn;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
//@property (strong, nonatomic) CLGeocoder *geocoder;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *guidanceView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet HTIndicatorBlockView *blockView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (strong, nonatomic) NSMutableArray *venueArray;
@property (strong, nonatomic) NSMutableArray *selectedVenueArray;
@property (nonatomic) NSInteger nowSelectedIndex;

- (IBAction)newButtonPushed:(id)sender;
- (IBAction)saveButtonPushed:(id)sender;

@end


@implementation FirstViewController

#pragma mark - View lifcycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _searchBar.delegate = self;
    _searchBar.backgroundColor = [UIColor colorWithRed:(247/255.0) green:(247/255.0) blue:(247/255.0) alpha:1];

    _tableView.hidden     = YES;
    _tableView.delegate   = self;
    _tableView.dataSource = self;

    _venueArray = [[NSMutableArray alloc] init];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
}


#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // もっとも最近の位置情報を得る
    CLLocation *recentLocation = locations.lastObject;
    _coordinate = recentLocation.coordinate;
    NSLog(@"latitude  = %f",_coordinate.latitude);
    NSLog(@"longitude = %f",_coordinate.longitude);
    
    [self setCenter:_coordinate.latitude setCentre:_coordinate.longitude latSpan:0.25 lonSpan:0.22];
    
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    _coordinate.latitude  = 35.682085;
    _coordinate.longitude = 139.766221;
    [self setCenter:_coordinate.latitude setCentre:_coordinate.longitude latSpan:0.25 lonSpan:0.22];
    
    [_locationManager stopUpdatingLocation];
}
    

#pragma mark - IBAction method

- (IBAction)saveButtonPushed:(id)sender
{
    NSLog(@"%s",__func__);
    
    if (_selectedVenueArray.count == 0) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"まだスポットがありません"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:nil
                               message:@"このリストのタイトルを\n入力してください"
                              delegate:self
                     cancelButtonTitle:@"キャンセル"
                     otherButtonTitles:@"OK", nil];
    alert.tag = 1;
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
}


- (IBAction)newButtonPushed:(id)sender
{
    NSLog(@"%s",__func__);
    
    if (_selectedVenueArray.count == 0)
        return;
    
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:nil
                               message:@"作成中のリストを破棄しても\nよろしいですか？"
                              delegate:self
                     cancelButtonTitle:@"キャンセル"
                     otherButtonTitles:@"OK", nil];
    alert.tag = 3;
    [alert show];
}


#pragma mark - Private method

- (void)setCenter:(double)latdbl setCentre:(double)londbl latSpan:(double)latS lonSpan:(double)lonS
{
	MKCoordinateRegion region  = _mapView.region;
	region.center.latitude     = latdbl;
	region.center.longitude    = londbl;
	region.span.latitudeDelta  = latS;
	region.span.longitudeDelta = lonS;
	[_mapView setRegion:region animated:YES];
    
	//_mapView.showsUserLocation = YES;
}

/**
 * AnnotationをMap上に作成するメソッド
 */
- (void)movePinLocationTo:(CLLocationCoordinate2D)coord parameters:(NSDictionary *)parameters
{
    HTAnnotation *annotation = [[HTAnnotation alloc] initWithCoordinate:coord attributes:parameters];
    [_mapView addAnnotation:annotation];
    [_mapView selectAnnotation:annotation animated:YES];
    
    MKCoordinateRegion region  = _mapView.region;
	region.center.latitude     = coord.latitude;
	region.center.longitude    = coord.longitude;
	region.span.latitudeDelta  = 0.25;
	region.span.longitudeDelta = 0.22;
    [_mapView setRegion:region animated:YES];
}


#pragma mark - MKMapView delegate

- (MKAnnotationView *)mapView:(MKMapView*)mapView viewForAnnotation:(id)annotation
{
    NSLog(@"%s",__func__);
    static NSString *PinIdentifier = @"Pin";
    MKPinAnnotationView *pav = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:PinIdentifier];
    if (pav == nil) {
        pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
        pav.canShowCallout = YES;
        pav.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    return pav;
}

- (void)mapView:(MKMapView*)mapView annotationView:(MKAnnotationView*)view calloutAccessoryControlTapped:(UIControl*)control
{
    NSLog(@"%s",__func__);
    
    for (int i=0; i<_selectedVenueArray.count; i++) {
        NSString *selectedVenueId = [[_selectedVenueArray objectAtIndex:i] objectForKey:@"id"];
        NSString *annotationVenueId = [((HTAnnotation *)view.annotation).attributes objectForKey:@"id"];
        if ([selectedVenueId isEqualToString:annotationVenueId]) {
            _nowSelectedIndex = i;
            break;
        }
    }
    
    UIActionSheet *actionSheet =
    [[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:@"キャンセル"
                  destructiveButtonTitle:@"このスポットをリストから削除"
                       otherButtonTitles:@"スポット詳細へ",nil];
    [actionSheet showInView:self.view.window];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:nil
                                   message:@"このスポットをリストから\n削除してもよろしいですか？"
                                  delegate:self
                         cancelButtonTitle:@"キャンセル"
                         otherButtonTitles:@"OK", nil];
        alert.tag = 4;
        [alert show];
    }
    
    // スポット詳細へ
    else if (buttonIndex == 1) {
        
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
        
        SpotDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SpotDetailScene"];
        vc.venueDict = [_selectedVenueArray objectAtIndex:_nowSelectedIndex];
        [self.navigationController pushViewController:vc animated:YES];
    }
}



#pragma mark - UIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.tag == 1) {
        NSString *inputText = [[alertView textFieldAtIndex:0] text];
        if (inputText.length >= 1 ) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 保存する
    if (alertView.tag == 1) {
        
        if (buttonIndex == 0)
            return;
        
        NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"sample.binary"];
        NSData *myData = [NSData dataWithContentsOfFile:filePath];
        NSMutableArray *storedArray = [NSKeyedUnarchiver unarchiveObjectWithData:myData];
        if (!storedArray) {
            storedArray = [[NSMutableArray alloc] init];
        }
        
        // まとめごとのオブジェクトとなるNSDictionaryを作る。
        NSString *inputText = [[alertView textFieldAtIndex:0] text];
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    inputText, @"title",
                                    _selectedVenueArray, @"venues",
                                    nil];
        
        //[storedArray addObject:dictionary];
        [storedArray insertObject:dictionary atIndex:0];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:storedArray];
        [data writeToFile:filePath atomically:YES];
        
        
        // ここでSecondViewのテーブルをリロードするメソッドを投げる
        [[NSNotificationCenter defaultCenter] postNotificationName:HTReloadMyPageNotification object:self userInfo:nil];
        
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:nil
                                    message:@"スポットリストが保存されました"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        alert.tag = 2;
        [alert show];
    }
    
    // 保存確定後
    else if (alertView.tag == 2) {
        
        self.tabBarController.selectedIndex = 1;
    
        // マップのアノテーションをクリア
        [_mapView removeAnnotations:_mapView.annotations];
        _searchBar.text = nil;
        [_selectedVenueArray removeAllObjects];
        [self setCenter:_coordinate.latitude setCentre:_coordinate.longitude latSpan:0.25 lonSpan:0.22];
        
        _guidanceView.hidden = NO;
        //self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    // 新規
    else if (alertView.tag == 3) {
        
        if (buttonIndex == 0)
            return;
        
        [_mapView removeAnnotations:_mapView.annotations];
        _searchBar.text = nil;
        [_selectedVenueArray removeAllObjects];
        [self setCenter:_coordinate.latitude setCentre:_coordinate.longitude latSpan:0.25 lonSpan:0.22];
        
        _guidanceView.hidden = NO;
        //self.navigationItem.leftBarButtonItem.enabled  = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    // スポットを削除
    else if (alertView.tag == 4) {
        
        if (buttonIndex == 0)
            return;
        
        for (HTAnnotation *annotation in _mapView.annotations) {
            NSString *annotationVenueId = [annotation.attributes objectForKey:@"id"];
            NSString *nowSelectedVenueId = [[_selectedVenueArray objectAtIndex:_nowSelectedIndex] objectForKey:@"id"];
            if ([annotationVenueId isEqualToString:nowSelectedVenueId]) {
                [_mapView removeAnnotation:annotation];
                [_selectedVenueArray removeObjectAtIndex:_nowSelectedIndex];
                
                if (_selectedVenueArray.count == 0) {
                    //self.navigationItem.leftBarButtonItem.enabled  = NO;
                    self.navigationItem.rightBarButtonItem.enabled = NO;
                }
                
                return;
            }
        }
        
    }
    
}


#pragma mark - UISearchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //NSLog(@"%s",__func__);
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    CGRect frame = _guidanceView.frame;
    frame.origin.y -= 44;
    
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        _searchBar.frame = CGRectMake(0, 20, 320, 44);
        _guidanceView.frame = frame;
    }];
    _searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    //NSLog(@"%s",__func__);
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        _searchBar.frame = CGRectMake(0, 64, 320, 44);
    }];

    [_searchBar resignFirstResponder];
    _searchBar.showsCancelButton = NO;
    _tableView.hidden = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
    
    _blockView.hidden = NO;
    
    //NSString *urlStr = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=%@&client_secret=%@&v=20130815&ll=35.73707,139.760068&query=%@", FS_CLIENT_ID, FS_CLIENT_SECRET, [URLCodec encode:_searchBar.text]];
    NSString *urlStr = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=%@&client_secret=%@&v=20130815&ll=%f,%f&query=%@", FS_CLIENT_ID, FS_CLIENT_SECRET, _coordinate.latitude, _coordinate.longitude,[URLCodec encode:_searchBar.text]];
    
    
    __weak typeof(self) wself = self;
    
    /*
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
        // HTTPリクエストヘッダにアプリバージョンをセットする
    [manager.requestSerializer setValue:@"1.0.0" forHTTPHeaderField:@"app-version"];
    [manager GET:urlStr
      parameters:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             NSLog(@"responseObject: %@", responseObject);
             
             [wself.venueArray removeAllObjects];
             NSArray *venuesArray = [[responseObject objectForKey:@"response"] objectForKey:@"venues"];
             for (int i=0; i<venuesArray.count; i++) {
                 NSDictionary *venue = [venuesArray objectAtIndex:i];
                 [wself.venueArray addObject:venue];
             }
             
             wself.blockView.hidden = YES;
             wself.tableView.hidden = NO;
             [wself.tableView reloadData];
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"Error: %@", error);
         }
     ];
    */
    
    
    /*
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = @"path/to/your/api/?photo_id=1";
    [manager DELETE:url
         parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"responseObject: %@", responseObject);
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                // APIサーバーの返すエラーメッセージを取得する方法もある
                NSString *responseStr =
                [[NSString alloc] initWithData:operation.responseObject
                                      encoding:NSUTF8StringEncoding];
                NSLog(@"errorResponseStr: %@",responseStr);
            }
     ];
    */

    /*
    //NSString *url = @"path/to/your/api/?user_id=1";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"path/to/your/api/?user_id=1"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // 通信に成功したときの処理
             NSLog(@"responseObject: %@", responseObject);
             // このresponseObjectに取得したJSONが含まれています
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // 通信に失敗したときの処理
             NSLog(@"Error: %@", error);
         }
     ];
     */
    
    /*
//    NSString *url = @"path/to/your/api/?user_id=1";
//    NSDictionary* param = @{@"user_id" : @"1"};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:@"path/to/your/api/?user_id=1"
       parameters:@{@"user_id" : @"1"}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"responseObject: %@", responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];
    */
    
    /*
    UIImage *image = [UIImage imageNamed:@"hoge.png"];
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:@"path/to/your/api/"
       parameters:@{@"user_id" : @"1"}
       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
           [formData appendPartWithFileData:imgData
                                       name:@"uploadFile"
                                   fileName:@"test.jpeg"
                                   mimeType:@"image/jpeg"];
       } success:^(AFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"responseObject: %@", responseObject);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"Error: %@", error);
       }
     ];
    */
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        //id obj1 = [responseObject objectForKey:@"response"];
        //NSLog(@"obj1_class:%@",[[obj1 class] description]);
        //NSLog(@"obj2: %@", [obj1 objectForKey:@"venues"]);
        
        [wself.venueArray removeAllObjects];
        
        NSArray *venuesArray = [[responseObject objectForKey:@"response"] objectForKey:@"venues"];
        //NSLog(@"venuesArray.count = %lu",(unsigned long)venuesArray.count);
        for (int i=0; i<venuesArray.count; i++) {
            NSDictionary *venue = [venuesArray objectAtIndex:i];
            //NSString *venueName = [venue objectForKey:@"name"];
            //NSLog(@"venueName = %@",venueName);
            [wself.venueArray addObject:venue];
        }
        
        wself.blockView.hidden = YES;
        wself.tableView.hidden = NO;
        [wself.tableView reloadData];
        
        // 検索結果として、地図にピンを立てるとともに、テーブルビューで表示する。
        
        //NSLog(@"venuesArray_class:%@",[[venuesArray class] description]);
        
        //NSLog(@"obj3: %@", [[obj1 objectForKey:@"venues"] objectAtIndex:0]);
        //NSLog(@"obj1: %@", obj1);
        //NSLog(@"obj2: %@", [obj1 objectAtIndex:0]);
        
        //id obj2 = [responseObject objectForKey:@"venues"];
        //NSLog(@"obj2: %@", [obj1 objectAtIndex:0]);
        //NSLog(@"obj3: %@",[obj2 objectAtIndex:0]);

        //NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        //NSLog(@"jsonObject.count = %ld",jsonObject.count);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    return;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venueArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [[self.venueArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}


#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s",__func__);
    
    NSDictionary *location = [[self.venueArray objectAtIndex:indexPath.row] objectForKey:@"location"];
    double lat = [[location objectForKey:@"lat"] doubleValue];
    double lon = [[location objectForKey:@"lng"] doubleValue];
    //NSLog(@"loc : %f, %f",lat, lon);
    
    
    if (!self.selectedVenueArray) {
        self.selectedVenueArray = [[NSMutableArray alloc] init];
    }
    
    [_selectedVenueArray addObject:[_venueArray objectAtIndex:indexPath.row]];
    //NSInteger index = _selectedVenueArray.count-1;
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
    NSDictionary *params = [_venueArray objectAtIndex:indexPath.row];
    [self movePinLocationTo:coord parameters:params];
    
    [_searchBar resignFirstResponder];
    _searchBar.showsCancelButton = NO;
    _tableView.hidden    = YES;
    _guidanceView.hidden = YES;
    //self.navigationItem.leftBarButtonItem.enabled  = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        _searchBar.frame = CGRectMake(0, 64, 320, 44);
    }];
    [_searchBar resignFirstResponder];
    _searchBar.showsCancelButton = NO;
    _tableView.hidden = YES;
}


#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



//    if (self.navigationController.navigationBarHidden) {
//        [self.navigationController setNavigationBarHidden:NO animated:NO];
//    }
//
//    SpotDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SpotDetailScene"];
//    vc.venueDict = ((HTAnnotation *)view.annotation).attributes;
//    [self.navigationController pushViewController:vc animated:YES];


//    NSData *data_ = [NSData dataWithContentsOfFile:filePath];
//    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data_];
//    NSLog(@"array.count = %lu",(unsigned long)array.count);

// Specify the position of the center of the map and the display area
//    double latitudinalMeters  = [[parameters objectForKey:@"latitudinalMeters"] doubleValue];
//    double longitudinalMeters = [[parameters objectForKey:@"longitudinalMeters"] doubleValue];
//double latitudinalMeters  = [[parameters objectForKey:@"latitudinalMeters"] doubleValue];
//double longitudinalMeters = [[parameters objectForKey:@"longitudinalMeters"] doubleValue];

// MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 200.0f, 200.0f);
//MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, latitudinalMeters, longitudinalMeters);

//    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
//                            [parameters objectForKey:@"name"],    @"title",
//                            @"", @"subtitle",
//                            nil];
//    HTAnnotation *annotation = [[HTAnnotation alloc] initWithCoordinate:coord attributes:params];

//_saveButton.backgroundColor = [UIColor whiteColor];

//_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-6, 0, 316, 44)];
//_searchBar.keyboardType = UIKeyboardTypeDefault;
//_searchBar.searchBarStyle = UISearchBarStyleMinimal;
//_searchBar.tintColor = [UIColor colorWithRed:(247/255.0) green:(247/255.0) blue:(247/255.0) alpha:1];
//_searchBar.placeholder = @"場所名を検索";

//    // UISearchBarを入れるためのコンテナViewをつくる
//    UIView *searchBarContainer = [[UIView alloc] initWithFrame:_searchBar.frame];
//    [searchBarContainer addSubview:_searchBar];
//
//    // UINavigationBar上に、UISearchBarを追加
//    self.navigationItem.titleView = searchBarContainer;
//    self.navigationItem.titleView.frame = CGRectMake(0, 0, 320, 44);


/*
if ([[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
    [[[UIAlertView alloc] initWithTitle:@"エラー"
                                message:@"住所を入力してください。"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles: nil]show];
    return;
}

//__weak FirstViewController *wself = self;
self.geocoder = [[CLGeocoder alloc] init];
[self.geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray * placemarks, NSError * error) {
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"エラー"
                                    message:@"場所が取得できませんでした。"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]show];
        return;
    }
    if ([placemarks count] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"エラー"
                                    message:@"該当する場所がありません。"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]show];
        return;
    }
    
    NSLog(@"placemarks.count = %lu", (unsigned long)placemarks.count);
    for (int i=0; i<placemarks.count; i++) {
        NSLog(@"%d = %@",i,[placemarks objectAtIndex:i]);
    }
    
    CLPlacemark *placemark = [placemarks objectAtIndex:0];
    CLLocationCoordinate2D coord = placemark.location.coordinate;
    NSLog(@"coord.latitude  = %f",coord.latitude);
    NSLog(@"coord.longitude = %f",coord.longitude);
    //[weak_self movePinLocationTo:coord];
}];

[_searchBar resignFirstResponder];
_searchBar.showsCancelButton = NO;
*/

/*
if (!self.myAnnotation) {
    self.myAnnotation = [[HTAnnotation alloc] initWithCoordinate:coord];
    [self.mMapView addAnnotation:self.myAnnotation];
}

self.myAnnotation.title    = [parameters objectForKey:@"title"];
self.myAnnotation.subtitle = [parameters objectForKey:@"subtitle"];

// set a coordinate of the specific location
self.myAnnotation.coordinate = coord;
*/

//    HTAnnotation *annotation = [[HTAnnotation alloc]init];
//    annotation.coordinate    = coord;
//    annotation.title         = [parameters objectForKey:@"title"];
//    annotation.subtitle      = [parameters objectForKey:@"subtitle"];
