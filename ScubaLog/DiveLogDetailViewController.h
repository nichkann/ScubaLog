//
//  ScubaLogDetailViewController.h
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/3/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScubaLog.h"
#import "DiveSitePickerViewController.h"
#import "RateView.h"


@class ScubaLog;


@interface DiveLogDetailViewController : UITableViewController <DiveSitePickerViewControllerDelegate, RateViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) ScubaLog *scubaLogToEdit;
@property (nonatomic, strong) CLPlacemark *placemark;

@property (strong, nonatomic) IBOutlet UILabel *diveSiteNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet RateView *rateView;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;


- (IBAction)cancel;
- (IBAction)done:(id)sender;

@end
