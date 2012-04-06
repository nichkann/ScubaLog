//
//  ScubaLog.h
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/2/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiveSite.h"

@interface ScubaLog : NSObject

@property (nonatomic, strong) DiveSite *diveSite;
@property (nonatomic, strong) NSString *name;


@end
