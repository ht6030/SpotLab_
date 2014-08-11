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

- (void)mapView:(MKMapView*)mapView annotationView:(MKAnnotationView*)view calloutAccessoryControlTapped:(UIControl*)control
{
    NSLog(@"%s",__func__);
    
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    
    SpotDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SpotDetailScene"];
    vc.venueDict = ((HTAnnotation *)view.annotation).attributes;
    [self.navigationController pushViewController:vc animated:YES];
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
