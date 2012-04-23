//
//  ScubaLogAppDelegate.h
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/2/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScubaLogAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
