//
//  DiveMapViewController.h
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/24/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiveSite.h"


@interface DiveMapViewController : UIViewController 

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) DiveSite *currentDiveSite;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@end
