//
//  ScubaLogDetailViewController.m
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/3/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import "ScubaLogDetailViewController.h"
#import "DiveSitePickerViewController.h"
#import "HUDView.h"
#import "DiveSite.h"

@interface ScubaLogDetailViewController ()

@end

@implementation ScubaLogDetailViewController{
    NSString *_name;
    NSDate *_date;
    DiveSite *_diveSite;
}

@synthesize managedObjectContext;
@synthesize scubaLogToEdit;

@synthesize diveSiteNameLabel;
@synthesize dateLabel;


#pragma mark - inits & views

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        _name = @"empty name";
        _date = [NSDate date];
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.scubaLogToEdit != nil) {
        self.title = @"Edit Dive Log";
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        self.diveSiteNameLabel.text = _name;
        self.dateLabel.text = [self formatDate:_date];
    }else {
        self.diveSiteNameLabel.text = @"Pick Dive Site";
        self.dateLabel.text = [self formatDate:[NSDate date]];
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.dateLabel = nil;
    self.diveSiteNameLabel = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    
    NSLog(@"name is : %@", scubaLog.diveSiteName);
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    
    [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];
    
}


#pragma mark - setters

- (void)setScubaLogToEdit:(ScubaLog *)newScubaLogToEdit
{
    if (scubaLogToEdit != newScubaLogToEdit) {
        scubaLogToEdit = newScubaLogToEdit;
        _name = scubaLogToEdit.diveSiteName;
        _date = scubaLogToEdit.date;
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickDiveSite"]){
        DiveSitePickerViewController *controller = segue.destinationViewController;
        controller.managedObjectContext = self.managedObjectContext;
        controller.delegate = self;
    }
}

#pragma mark - DiveSitePickerViewController Delagate
- (void)diveSitePicker:(DiveSitePickerViewController *)controller didPickDiveSite:(DiveSite *)diveSite
{
    _diveSite = diveSite;
    self.diveSiteNameLabel.text = _diveSite.name;
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end





























