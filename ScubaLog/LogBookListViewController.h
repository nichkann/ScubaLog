//
//  LogBookListViewController.h
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/2/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "ScubaLog.h"

@interface LogBookListViewController : UITableViewController

@property (nonatomic, strong) DataModel *dataModel;

@end
