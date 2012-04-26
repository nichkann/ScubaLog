//
//  DiveMapViewController.m
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/24/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import "DiveMapViewController.h"

@interface DiveMapViewController ()

@end

@implementation DiveMapViewController{
    CLLocationCoordinate2D _coordinate;
    NSFetchedResultsController *fetchedResultsController;
    NSArray *_otherDiveSites;
}

@synthesize managedObjectContext;
@synthesize currentDiveSite;
@synthesize mapView;


- (void)getOtherDiveSites
{   
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DiveSite" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];

    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (foundObjects == nil) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    
    if (_otherDiveSites != nil) {
        [self.mapView removeAnnotations:_otherDiveSites];
    }
    _otherDiveSites = foundObjects;
    [self.mapView addAnnotations:_otherDiveSites];
    
}

#pragma mark - Views

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
       
    }
    return self;
}

- (void)showCurrentDiveSite
{
    _coordinate = CLLocationCoordinate2DMake([self.currentDiveSite.latitude doubleValue], [self.currentDiveSite.longitude doubleValue]);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_coordinate, 8000, 8000);
    [self.mapView setRegion:region animated:YES];
//    [self.mapView setCenterCoordinate:_coordinate animated:YES];
    [self.mapView selectAnnotation:self.currentDiveSite animated:YES];
    [self getOtherDiveSites];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self showCurrentDiveSite];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - MKMapView



@end












