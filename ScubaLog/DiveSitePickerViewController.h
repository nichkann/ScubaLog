//
//  DiveSitePickerViewController.h
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/22/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DiveSitePickerViewController;
@class DiveSite;

@protocol DiveSitePickerViewControllerDelegate <NSObject>

- (void)diveSitePicker:(DiveSitePickerViewController *)controller didPickDiveSite:(DiveSite *)diveSite;

@end

@interface DiveSitePickerViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id <DiveSitePickerViewControllerDelegate> delegate;

@end
