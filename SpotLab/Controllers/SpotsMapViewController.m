//
//  SpotsDetailViewController.m
//  Memoris
//
//  Created by 高橋 弘 on 2014/05/17.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import "SpotsMapViewController.h"
#import "AppDelegate.h"
#import "SLAnnotation.h"
#import "SpotDetailViewController.h"
#import "AFNetworking.h"
#import "URLCodec.h"
#import "SLIndicatorBlockView.h"
#import "SpotsModel.h"

@interface SpotsMapViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet SLIndicatorBlockView *blockView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSDictionary *selectedVenueDict;
@property (strong, nonatomic) NSMutableArray *venueArray;
@property (nonatomic) CLLocationCoordinate2D coordinate;

- (IBAction)editButtonPushed:(id)sender;
@end

@implementation SpotsMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifcycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    double lat = 0.0;
    double lon = 0.0;
    
    _mapView.delegate = self;

    _tableView.delegate   = self;
    _tableView.dataSource = self;

    _searchBar.hidden = YES;
    _searchBar.delegate = self;
    //_searchBar.frame = CGRectMake(0, -44, 320, 44);
    //_searchBar.frame = CGRectZero;
    
    _venueArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<_selectedVenueArray.count; i++) {
        NSDictionary *venueDict = [_selectedVenueArray objectAtIndex:i];
        NSDictionary *locDict   = [venueDict objectForKey:@"location"];
        lat = [[locDict objectForKey:@"lat"] doubleValue];
        lon = [[locDict objectForKey:@"lng"] doubleValue];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);

        SLAnnotation *annotation = [[SLAnnotation alloc] initWithCoordinate:coord attributes:venueDict];
        [_mapView addAnnotation:annotation];
    }

    [self setCenter:lat setCentre:lon latSpan:0.25 lonSpan:0.22];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSpotsDone:) name:NOTIF_SpotsModel_GetSpots object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_SpotsModel_GetSpots object:nil];
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
    
    #pragma mark - TODO ここはCLLocationManagerで現在地追跡する必要あり？
	_mapView.showsUserLocation = YES;
}

/**
 * AnnotationをMap上に作成するメソッド
 */
- (void)movePinLocationTo:(CLLocationCoordinate2D)coord parameters:(NSDictionary *)parameters
{
    SLAnnotation *annotation = [[SLAnnotation alloc] initWithCoordinate:coord attributes:parameters];
    [_mapView addAnnotation:annotation];
    [_mapView selectAnnotation:annotation animated:YES];
    
    MKCoordinateRegion region  = _mapView.region;
    region.center.latitude     = coord.latitude;
    region.center.longitude    = coord.longitude;
    region.span.latitudeDelta  = 0.25;
    region.span.longitudeDelta = 0.22;
    [_mapView setRegion:region animated:YES];
}

/**
 * 現在選択状態のSpotを保存
 */
- (void)saveEditedVenues
{
    // 保存されている配列から該当のオブジェクトを取り出す
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"sample.binary"];
    NSData *myData = [NSData dataWithContentsOfFile:filePath];
    NSMutableArray *storedArray = [NSKeyedUnarchiver unarchiveObjectWithData:myData];
    for (int i=0; i<storedArray.count; i++) {
        NSString *title = [[storedArray objectAtIndex:i] objectForKey:@"title"];
        if (![self.title isEqualToString:title])
            continue;
        
        // remove修正されたあとの配列とタイトルをセットにしたDictionaryを新たに生成
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    title, @"title",
                                    _selectedVenueArray, @"venues",
                                    nil];
        // そのDictionaryをstoredArrayの該当行のものとreplaceする
        [storedArray replaceObjectAtIndex:i withObject:dictionary];
        
        // そうして残ったstoredArrayをストレージに確保する
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:storedArray];
        [data writeToFile:filePath atomically:YES];
        return;
    }
}


#pragma mark - IBAction method

- (IBAction)editButtonPushed:(id)sender
{
    NSLog(@"%s",__func__);
    _searchBar.hidden = NO;
    //if (_searchBar.hidden) {
    if ([_editButton.title isEqualToString:@"編集"]) {
        _editButton.title = @"完了";
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
            _searchBar.frame = CGRectMake(0, 64, 320, 44);
        }];
        [self saveEditedVenues];
        
    } else {
        _editButton.title = @"編集";
        [_searchBar resignFirstResponder];
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
            _searchBar.frame = CGRectMake(0, -44, 320, 44);
            //_searchBar.hidden = YES;
        }];
    }
}


#pragma mark - Notification method

- (void)getSpotsDone:(NSNotification *)notification
{
    [_venueArray removeAllObjects];
    NSArray *venuesArray = [[notification.userInfo objectForKey:@"response"] objectForKey:@"venues"];
    NSLog(@"venuesArray.count = %lu",(unsigned long)venuesArray.count);
    for (int i=0; i<venuesArray.count; i++) {
        NSDictionary *venue = [venuesArray objectAtIndex:i];
        NSString *venueName = [venue objectForKey:@"name"];
        NSLog(@"venueName = %@",venueName);
        [_venueArray addObject:venue];
    }
    _blockView.hidden = YES;
    _tableView.hidden = NO;
    [_tableView reloadData];
}


#pragma mark - MKMapView delegate

- (MKAnnotationView *)mapView:(MKMapView*)mapView viewForAnnotation:(id)annotation
{
    if (annotation == _mapView.userLocation) {
        return nil; //default to blue dot
    }
    
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


/**
 * same to FirstViewController
 */
- (void)mapView:(MKMapView*)mapView annotationView:(MKAnnotationView*)view calloutAccessoryControlTapped:(UIControl*)control
{
    NSLog(@"%s",__func__);
    
    _selectedVenueDict = ((SLAnnotation *)view.annotation).attributes;
    
    UIActionSheet *actionSheet =
    [[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:@"キャンセル"
                  destructiveButtonTitle:@"このスポットをリストから削除"
                       otherButtonTitles:@"スポット詳細へ",nil];
    [actionSheet showInView:self.view.window];
}


#pragma mark - UIActionSheetDelegate

/**
 * same to FirstViewController
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[[UIAlertView alloc] initWithTitle:nil
                                   message:@"このスポットをリストから\n削除してもよろしいですか？"
                                  delegate:self
                         cancelButtonTitle:@"キャンセル"
                         otherButtonTitles:@"OK", nil] show];
    }
    // スポット詳細へ
    else if (buttonIndex == 1) {
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
        SpotDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SpotDetailScene"];
        vc.venueDict = _selectedVenueDict;
        [self.navigationController pushViewController:vc animated:YES];
    }
}




- (void)moveSeachBarAbove
{
    _searchBar.showsCancelButton = YES;
    CGRect selfFrame = self.view.frame;
    selfFrame.origin.y -= 44;
    
    if (selfFrame.origin.y == -88)
        return;
    
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        self.view.frame = selfFrame;
        NSLog(@"self.view.frame:%@",NSStringFromCGRect(self.view.frame));
    }];
}


- (void)moveSeachBarBelow
{
    [_searchBar resignFirstResponder];
    _searchBar.showsCancelButton = NO;
    _tableView.hidden = YES;
}


#pragma mark - UISearchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //NSLog(@"%s",__func__);
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self performSelector:@selector(moveSeachBarAbove) withObject:nil afterDelay:0.01];
    
//    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
//        _searchBar.frame = CGRectMake(0, 20, 320, 44);
//    }];
//    _searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    //NSLog(@"%s",__func__);
    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
//        _searchBar.frame = CGRectMake(0, 64, 320, 44);
//    }];
    [_searchBar resignFirstResponder];
    _searchBar.showsCancelButton = NO;
    _tableView.hidden = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
    _blockView.hidden = NO;
    
    SpotsModel *spotsModel = [[SpotsModel alloc] init];
    [spotsModel getSpotsListWithQuery:[URLCodec encode:_searchBar.text] location:_coordinate];
    //_blockView.hidden = NO;
}


#pragma mark - UIAlertViewDelegate

/**
 * same to FirstViewController
 */
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        return;
    
    for (SLAnnotation *annotation in _mapView.annotations) {
        NSString *annotationVenueId = [annotation.attributes objectForKey:@"id"];
        NSString *nowSelectedVenueId = [_selectedVenueDict objectForKey:@"id"];
        if (![annotationVenueId isEqualToString:nowSelectedVenueId])
            continue;
        
        [_mapView removeAnnotation:annotation];
        [_selectedVenueArray removeObject:_selectedVenueDict];
        [self saveEditedVenues];
        return;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _venueArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [[_venueArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *location = [[_venueArray objectAtIndex:indexPath.row] objectForKey:@"location"];
    double lat = [[location objectForKey:@"lat"] doubleValue];
    double lon = [[location objectForKey:@"lng"] doubleValue];
    //NSLog(@"loc : %f, %f",lat, lon);
    
    [_selectedVenueArray addObject:[_venueArray objectAtIndex:indexPath.row]];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
    NSDictionary *params = [_venueArray objectAtIndex:indexPath.row];
    [self movePinLocationTo:coord parameters:params];
    
    [_searchBar resignFirstResponder];
    _searchBar.showsCancelButton = NO;
    _tableView.hidden = YES;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
