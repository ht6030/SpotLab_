//
//  SpotsDetailViewController.m
//  Memoris
//
//  Created by 高橋 弘 on 2014/05/17.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import "SpotsMapViewController.h"
#import "HTAnnotation.h"
#import "SpotDetailViewController.h"

@interface SpotsMapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (copy, nonatomic) NSDictionary *selectedVenueDict;
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
    
    for (int i=0; i<_venueArray.count; i++) {
        
        NSDictionary *venueDict = [_venueArray objectAtIndex:i];
        NSDictionary *locDict   = [venueDict objectForKey:@"location"];
        lat = [[locDict objectForKey:@"lat"] doubleValue];
        lon = [[locDict objectForKey:@"lng"] doubleValue];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);

        HTAnnotation *annotation = [[HTAnnotation alloc] initWithCoordinate:coord attributes:venueDict];
        [_mapView addAnnotation:annotation];
    }

    [self setCenter:lat setCentre:lon latSpan:0.25 lonSpan:0.22];
}



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
    
    _selectedVenueDict = ((HTAnnotation *)view.annotation).attributes;
    
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

#pragma mark - UIAlertViewDelegate

/**
 * same to FirstViewController
 */
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        return;
    
    for (HTAnnotation *annotation in _mapView.annotations) {
        NSString *annotationVenueId = [annotation.attributes objectForKey:@"id"];
        NSString *nowSelectedVenueId = [_selectedVenueDict objectForKey:@"id"];
        if (![annotationVenueId isEqualToString:nowSelectedVenueId])
            continue;
        
        [_mapView removeAnnotation:annotation];
        [_venueArray removeObject:_selectedVenueDict];
        
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
                                        _venueArray, @"venues",
                                        nil];
            // そのDictionaryをstoredArrayの該当行のものとreplaceする
            [storedArray replaceObjectAtIndex:i withObject:dictionary];
            
            // そうして残ったstoredArrayをストレージに確保する
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:storedArray];
            [data writeToFile:filePath atomically:YES];
            return;
        }
        return;
    }
}


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
