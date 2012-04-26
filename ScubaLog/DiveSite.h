//
//  DiveSite.h
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/22/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DiveSite : NSManagedObject <MKAnnotation>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) CLPlacemark *placemark;
@property (nonatomic, retain) NSMutableSet *dive_logs;

- (void)updateRating;

@end
