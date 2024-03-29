//
//  DiveSiteDetailViewController.h
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/22/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScubaLog.h"
#import "RateView.h"

@class DiveSite;

@interface DiveSiteDetailViewController : UITableViewController <UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate, RateViewDelegate>


@property (nonatomic, strong) DiveSite *diveSiteToEdit;
@property (nonatomic, strong) ScubaLog *currentScubaLog;
@property (nonatomic, strong) CLPlacemark *placemark;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet MKMapView *diveSiteMap;
@property (nonatomic, strong) IBOutlet UITextField *diveSiteNameTextField;
@property (nonatomic, strong) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *ratingLabel;
@property (nonatomic, strong) IBOutlet RateView *rateViewLabel;

- (IBAction)done;
- (IBAction)getCurrentLocation;
- (IBAction)getLocationFromCurrentDiveLog;

@end
