//
//  ScubaLog.h
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/2/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiveSite.h"

@interface ScubaLog : NSManagedObject

@property (nonatomic, retain) NSString *diveSiteName;
@property (nonatomic, retain) NSDate *date;



@end
