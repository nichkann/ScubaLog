//
//  DiveSiteDetailViewController.m
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/22/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import "DiveSiteDetailViewController.h"
#import "HUDView.h"
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
}


@synthesize diveSiteToEdit;
@synthesize placemark;
@synthesize managedObjectContext;

@synthesize diveSiteMap;
@synthesize diveSiteNameTextField;
@synthesize latitudeLabel;
@synthesize longitudeLabel;

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
    
    if (self.diveSiteToEdit != nil) {
        self.title = @"Edit Dive Site";
        
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    }
    self.diveSiteNameTextField.text = _name;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.diveSiteMap = nil;
    self.diveSiteNameTextField = nil;
    self.latitudeLabel = nil;
    self.longitudeLabel = nil;
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
        _name = newDiveSiteToEdit.name;
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
        
        lastLocationError = [NSError errorWithDomain:@"MylocationErrorDomain" code:1 userInfo:nil];
        
//        [self updateLabels];
//        [self configureGetButton];
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


- (void)getLocation
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
    }else if (cell.tag == 101) {
        [self getLocation];
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

@end















