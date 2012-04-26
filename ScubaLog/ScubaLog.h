//
//  ScubaLog.h
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/2/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiveSite.h"

@interface ScubaLog : NSManagedObject <MKAnnotation>

@property (nonatomic, retain) NSString *diveSiteName;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *time_in;
@property (nonatomic, retain) NSDate *time_out;
@property (nonatomic, retain) NSNumber *rating;
@property (nonatomic, retain) DiveSite *dive_site;

@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) CLPlacemark *placemark;


@end
