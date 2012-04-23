//
//  DataModel.h
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/2/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

@property (nonatomic, strong) NSMutableArray *scubaLogList;

- (void)saveScubaLogLists;

@end
