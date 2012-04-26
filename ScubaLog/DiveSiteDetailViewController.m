//
//  DiveSiteDetailViewController.m
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/22/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import "DiveSiteDetailViewController.h"
#import "DiveMapViewController.h"
#import "HUDView.h"
#import "MBProgressHUD.h"
#import "DiveSite.h"


@interface DiveSiteDetailViewController ()

@end

@implementation DiveSiteDetailViewController{
    CLLocationManager *locationManager;
    CLLocation *location;
    BOOL updatingLocation;
    NSError *lastLocationError;
    CLGeocoder *geocoder;
    CLPlacemark *_placemark;
    BOOL performingReverseGeocoding;
    
    NSString *_name;
    double _latitude;
    double _longitude;
    float _rating;
}


@synthesize diveSiteToEdit;
@synthesize currentScubaLog;
@synthesize placemark;
@synthesize managedObjectContext;

@synthesize diveSiteMap;
@synthesize diveSiteNameTextField;
@synthesize latitudeLabel;
@synthesize longitudeLabel;
@synthesize ratingLabel;
@synthesize rateViewLabel;


#pragma mark - Views

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        locationManager = [[CLLocationManager alloc] init];
        geocoder = [[CLGeocoder alloc] init];        
        
        _name = @"Dive Site Name";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rateViewLabel.notSelectedImage = [UIImage imageNamed:@"kermit_empty.png"];
    self.rateViewLabel.halfSelectedImage = [UIImage imageNamed:@"kermit_half.png"];
    self.rateViewLabel.fullSelectedImage = [UIImage imageNamed:@"kermit_full.png"];
    self.rateViewLabel.editable = NO;
    self.rateViewLabel.maxRating = 5;
    self.rateViewLabel.delegate = self;    
    
    
    if (self.diveSiteToEdit != nil) {
        self.title = @"Edit Dive Site";
        self.rateViewLabel.rating = _rating;

    }
    self.diveSiteNameTextField.text = _name;
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", _latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", _longitude];
    if ([self.diveSiteToEdit.dive_logs count] > 1) {
        self.ratingLabel.text = [NSString stringWithFormat:@"%.1f/5.0 from %d dives", _rating,[self.diveSiteToEdit.dive_logs count]];
    }else {
        self.ratingLabel.text = [NSString stringWithFormat:@"%.1f/5.0 from %d dive", _rating,[self.diveSiteToEdit.dive_logs count]];
    }

    
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.diveSiteMap = nil;
    self.diveSiteNameTextField = nil;
    self.latitudeLabel = nil;
    self.longitudeLabel = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self showDiveSiteLocation];    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - IBActions

-(void)closeScreen
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)done
{
    HUDView *hudView = [HUDView hudInView:self.tableView animated:YES];    
    
    DiveSite *diveSite = nil;
    
    if (self.diveSiteToEdit != nil) {
        hudView.text = @"Updated";
        diveSite = self.diveSiteToEdit;
    }else {
        hudView.text = @"Added";
        diveSite = [NSEntityDescription insertNewObjectForEntityForName:@"DiveSite" inManagedObjectContext:self.managedObjectContext];
    }
    
    diveSite.name = _name;
    diveSite.latitude = [NSNumber numberWithDouble:_latitude];
    diveSite.longitude = [NSNumber numberWithDouble:_longitude];
    diveSite.placemark = self.placemark;
    
    [diveSite updateRating];
    

    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    
    
    [hudView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.6];
    [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.8];
    
}


#pragma mark - setter
- (void)setDiveSiteToEdit:(DiveSite *)newDiveSiteToEdit
{
    if (diveSiteToEdit != newDiveSiteToEdit) {
        diveSiteToEdit = newDiveSiteToEdit;
        _name = diveSiteToEdit.name;
        _longitude = [diveSiteToEdit.longitude doubleValue];
        _latitude = [diveSiteToEdit.latitude doubleValue];
        _rating = [diveSiteToEdit.rating floatValue];
    }
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDiveMap"]) {
        DiveMapViewController *controller = segue.destinationViewController;
        controller.managedObjectContext = self.managedObjectContext;
        controller.currentDiveSite = self.diveSiteToEdit;
    }
}

#pragma mark - CLLocationManager

- (void)startLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [locationManager startUpdatingLocation];
        updatingLocation = YES;
        
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}

- (void)stopLocationManager
{
    if (updatingLocation) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
        
        [locationManager stopUpdatingLocation];
        locationManager.delegate = nil;
        updatingLocation = NO;
    }
}

- (void)didTimeOut:(id)obj
{
    NSLog(@"***Time out!");
    
    if (location == nil) {
        [self stopLocationManager];
        
        lastLocationError = [NSError errorWithDomain:@"MyLocationErrorDomain" code:1 userInfo:nil];
    }
}

- (void)updateLabels
{
    if (location != nil) {
        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
        _latitude = location.coordinate.latitude;
        self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
        _longitude = location.coordinate.longitude;
        
    }
    if (_placemark != nil) {
        self.placemark = _placemark;
    }
}


# pragma mark - Map Stuffs

- (IBAction)getCurrentLocation
{
 
    if (updatingLocation) {
        [self stopLocationManager];
    }else {
        location = nil;
        _placemark = nil;
        lastLocationError = nil;
        [self startLocationManager];
    }

    [self updateLabels];
    NSLog(@"latitude %.8f",location.coordinate.latitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.diveSiteMap.userLocation.coordinate, 1000, 1000);
    [self.diveSiteMap setRegion:region animated:YES];
}

- (IBAction)getLocationFromCurrentDiveLog
{
    if (self.currentScubaLog != nil) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([self.currentScubaLog coordinate], 1000, 1000);
        [self.diveSiteMap setRegion:region animated:YES];
        _latitude = [self.currentScubaLog.latitude doubleValue];
        _longitude = [self.currentScubaLog.longitude doubleValue];
        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", _latitude];
        self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", _longitude];
        self.placemark = self.currentScubaLog.placemark;

    }else {
        [self getCurrentLocation];
    }
}

- (void)showDiveSiteLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([self.diveSiteToEdit coordinate], 1000, 1000);
    [self.diveSiteMap setRegion:region animated:YES];

//    [self.diveSiteMap addAnnotation:self.diveSiteToEdit];
    [self.diveSiteMap selectAnnotation:self.diveSiteToEdit animated:NO];
}

#pragma mark - MKMapViewDelegate


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"ShowDiveMap" sender:nil];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *annotationIdentifier = @"DiveSite";
    MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    if (pinAnnotationView == nil) {
        pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    }else {
        pinAnnotationView.annotation = annotation;
    }
    
    pinAnnotationView.enabled = YES;
    pinAnnotationView.canShowCallout = YES;
    pinAnnotationView.animatesDrop = YES;
    UIButton *disclosuerButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pinAnnotationView.rightCalloutAccessoryView = disclosuerButton;

    return pinAnnotationView;


}



#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError %@", error);
    
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    [self stopLocationManager];
    lastLocationError = error;
    
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
    if (location != nil) {
        distance = [newLocation distanceFromLocation:location];
    }
    
    if (location == nil || location.horizontalAccuracy > newLocation.horizontalAccuracy) {
        lastLocationError = nil;
        location = newLocation;
        [self updateLabels];
        
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            NSLog(@"*** we are done!");
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
            [self stopLocationManager];
            
            if (distance > 0) {
                performingReverseGeocoding = NO;
            }
        }
        
        if (!performingReverseGeocoding) {
            NSLog(@"*** Going to gecode");
            
            performingReverseGeocoding = YES;
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
                
                lastLocationError = error;
                if (error == nil && [placemarks count] > 0) {
                    _placemark = [placemarks lastObject];
                }else {
                    _placemark = nil;
                }
                
                performingReverseGeocoding = NO;
                [self updateLabels];
            }];
        }
    }else if (distance < 10.0) {
        NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:location.timestamp];
        if (timeInterval > 10) {
            NSLog(@"***Force done!");
            [self stopLocationManager];
            [self updateLabels];
        }
    }
}

#pragma mark - UITableView Delegates

/*
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return nil;
    }
}
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == 100) {
        [self.diveSiteNameTextField becomeFirstResponder];
    }else if (cell.tag == 102) {
        NSLog(@"Just tapped use dive site location");
    }
}

#pragma mark - UITextFields Delagates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    _name = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _name = textField.text;
}


#pragma mark - RateView
- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating 
{
//    self.ratingLabel.text = [NSString stringWithFormat:@"%.1f/5.0 from %d dives", self.diveSiteToEdit.rating,[self.diveSiteToEdit.dive_logs count]];
}

@end















