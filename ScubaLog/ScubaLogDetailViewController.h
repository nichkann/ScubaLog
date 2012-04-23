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

@class ScubaLog;


@interface ScubaLogDetailViewController : UITableViewController <DiveSitePickerViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) ScubaLog *scubaLogToEdit;

@property (strong, nonatomic) IBOutlet UILabel *diveSiteNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;


- (IBAction)cancel;
- (IBAction)done:(id)sender;

@end
