//
//  ScubaLogDetailViewController.m
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/3/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import "DiveLogDetailViewController.h"
#import "DiveSitePickerViewController.h"
#import "HUDView.h"
#import "DiveSite.h"
#import "MBProgressHUD.h"

@interface DiveLogDetailViewController ()

@end

@implementation DiveLogDetailViewController{

    CLLocationManager *_locationManager;
    CLLocation *_location;
    BOOL _updatingLocation;
    NSError *_lastLocationError;
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
    BOOL _performingReverseGeocoding;

    
    NSString *_name;
    NSDate *_date;
    double _latitude;
    double _longitude;    
    DiveSite *_diveSite;
    DiveSite *_oldDiveSite;
    float _rating;
}

@synthesize managedObjectContext;
@synthesize scubaLogToEdit;

@synthesize diveSiteNameLabel;
@synthesize dateLabel;
@synthesize rateView;
@synthesize mapView;
@synthesize placemark;


#pragma mark - inits & views

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _geocoder = [[CLGeocoder alloc] init];
        
        _name = @"empty name";
        _date = [NSDate date];
        _rating = 0;
    }
    return  self;
}

- (NSString *)formatDate:(NSDate *)theDate
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterLongStyle];
//        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    return [formatter stringFromDate:theDate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.rateView.notSelectedImage = [UIImage imageNamed:@"kermit_empty.png"];
    self.rateView.halfSelectedImage = [UIImage imageNamed:@"kermit_half.png"];
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"kermit_full.png"];
    self.rateView.editable = YES;
    self.rateView.maxRating = 5;
    self.rateView.delegate = self;    
    
    if (self.scubaLogToEdit != nil) {
        self.title = @"Edit Dive Log";
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        self.diveSiteNameLabel.text = _name;
        self.dateLabel.text = [self formatDate:_date];
        self.rateView.rating = _rating;
    }else {
        self.diveSiteNameLabel.text = @"Pick Dive Site";
        self.dateLabel.text = [self formatDate:[NSDate date]];
        self.rateView.rating = 0;
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.dateLabel = nil;
    self.diveSiteNameLabel = nil;
    self.rateView = nil;
    self.mapView = nil;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.scubaLogToEdit != nil) {
        [self showDiveSiteLocation];   
    }else {
        [self getCurrentLocation];
    }
 
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - IBActions

- (void)closeScreen
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel
{
    [self closeScreen];
}

- (IBAction)done:(id)sender
{
    if (_diveSite == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot find the dive site... :'("
                                                            message:@"Did you forget to pick a dive site?" delegate:nil cancelButtonTitle:@"Oops..!" otherButtonTitles:nil];
        [alertView show];
    }else {
        HUDView *hudView = [HUDView hudInView:self.navigationController.view animated:YES];
        
        ScubaLog *scubaLog = nil;
        
        if (self.scubaLogToEdit != nil) {
            hudView.text = @"Updated";
            scubaLog = self.scubaLogToEdit;
        }else {
            hudView.text = @"Added";
            scubaLog = [NSEntityDescription insertNewObjectForEntityForName:@"ScubaLog" inManagedObjectContext:self.managedObjectContext];
        }

        scubaLog.diveSiteName = self.diveSiteNameLabel.text;
        scubaLog.date = _date;
        scubaLog.rating = [NSNumber numberWithFloat:self.rateView.rating];
        scubaLog.latitude = [NSNumber numberWithDouble:_latitude];
        scubaLog.longitude = [NSNumber numberWithDouble:_longitude];
        scubaLog.placemark = self.placemark;
        
        scubaLog.dive_site = _diveSite;
        

        //Here in case that users switched dive site
        [_diveSite updateRating];
        [_oldDiveSite updateRating];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error: %@", error);
            FATAL_CORE_DATA_ERROR(error);
            return;
        }
        
        [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];
    }
    
}


#pragma mark - CLLocationManager

- (void)startLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [_locationManager startUpdatingLocation];
        _updatingLocation = YES;
        
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}

- (void)stopLocationManager
{
    if (_updatingLocation) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
        
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        _updatingLocation = NO;
    }
}

- (void)didTimeOut:(id)obj
{
    NSLog(@"***Time out!");
    
    if (_location == nil) {
        [self stopLocationManager];
        
        _lastLocationError = [NSError errorWithDomain:@"MyLocationErrorDomain" code:1 userInfo:nil];
    }
}

- (void)updateLabels
{
    if (_location != nil) {
//        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
        _latitude = _location.coordinate.latitude;
//        self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
        _longitude = _location.coordinate.longitude;
        
    }
    if (_placemark != nil) {
        self.placemark = _placemark;
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError %@", error);
    
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    [self stopLocationManager];
    _lastLocationError = error;
    
    [self updateLabels];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation %@", newLocation);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    hud.labelText = @"Getting Location...";    
    
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    CLLocationDistance distance = MAXFLOAT;
    if (_location != nil) {
        distance = [newLocation distanceFromLocation:_location];
    }
    
    if (_location == nil || _location.horizontalAccuracy > newLocation.horizontalAccuracy) {
        _lastLocationError = nil;
        _location = newLocation;
        [self updateLabels];
        
        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            NSLog(@"*** we are done!");
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
            [self stopLocationManager];
            
            if (distance > 0) {
                _performingReverseGeocoding = NO;
            }
        }
        
        if (!_performingReverseGeocoding) {
            NSLog(@"*** Going to gecode");
            
            _performingReverseGeocoding = YES;
            [_geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
                NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
                
                _lastLocationError = error;
                if (error == nil && [placemarks count] > 0) {
                    _placemark = [placemarks lastObject];
                }else {
                    _placemark = nil;
                }
                
                _performingReverseGeocoding = NO;
                [self updateLabels];
            }];
        }
    }else if (distance < 10.0) {
        NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:_location.timestamp];
        if (timeInterval > 10) {
            NSLog(@"***Force done!");
            [self stopLocationManager];
            [self updateLabels];
        }
    }
}


# pragma mark - Map Stuffs

- (void)getCurrentLocation
{
    
    if (_updatingLocation) {
        [self stopLocationManager];
    }else {
        _location = nil;
        _placemark = nil;
        _lastLocationError = nil;
        [self startLocationManager];
    }
    
    [self updateLabels];
    NSLog(@"latitude %.8f",_location.coordinate.latitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
    [self.mapView setRegion:region animated:YES];
}


- (void)showDiveSiteLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([self.scubaLogToEdit coordinate], 1000, 1000);
    [self.mapView setRegion:region animated:YES];
    
    //    [self.diveSiteMap addAnnotation:self.diveSiteToEdit];
    [self.mapView selectAnnotation:self.scubaLogToEdit animated:NO];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *annotationIdentifier = @"DiveSite";
    MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    if (pinAnnotationView == nil) {
        pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    }else {
        pinAnnotationView.annotation = annotation;
    }
    
    pinAnnotationView.enabled = YES;
    pinAnnotationView.canShowCallout = NO;
    pinAnnotationView.animatesDrop = YES;

    return pinAnnotationView;    
    
}


#pragma mark - setters

- (void)setScubaLogToEdit:(ScubaLog *)newScubaLogToEdit
{
    if (scubaLogToEdit != newScubaLogToEdit) {
        scubaLogToEdit = newScubaLogToEdit;
        _name = scubaLogToEdit.diveSiteName;
        _date = scubaLogToEdit.date;
        _rating = [scubaLogToEdit.rating floatValue];
        _diveSite = scubaLogToEdit.dive_site;
        _latitude = [scubaLogToEdit.latitude doubleValue];
        _longitude = [scubaLogToEdit.longitude doubleValue];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickDiveSite"]){
        DiveSitePickerViewController *controller = segue.destinationViewController;
        controller.managedObjectContext = self.managedObjectContext;
        controller.currentScubaLog = self.scubaLogToEdit;
        controller.delegate = self;
    }
}

#pragma mark - DiveSitePickerViewController Delagate
- (void)diveSitePicker:(DiveSitePickerViewController *)controller didPickDiveSite:(DiveSite *)diveSite
{
    _oldDiveSite = _diveSite;
    _diveSite = diveSite;
    self.diveSiteNameLabel.text = _diveSite.name;
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - RateView
- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating 
{
//    self.rateScoreLabel.text = [NSString stringWithFormat:@"%.2f", rating];
}
@end





























