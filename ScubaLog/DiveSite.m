//
//  DiveSite.m
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/22/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import "DiveSite.h"
#import "ScubaLog.h"


@implementation DiveSite

@dynamic name;
@dynamic rating;
@dynamic latitude;
@dynamic longitude;
@dynamic placemark;
@dynamic dive_logs;

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (NSString *)title
{
    if ([self.name length] > 0) {
        return self.name;
    }else {
        return @"No Description";
    }
}

- (NSString *)subtitle
{
    float rating = [self.rating floatValue];
    NSMutableString *rating_label = [NSMutableString stringWithCapacity:5];
    while (rating >= 1) {
        [rating_label appendString:@"★"];
        rating = rating - 1;
    }
    if (rating >= 0.75) {
        [rating_label appendString:@"¾"];
    }else if (rating < 0.75 && rating >= 0.5) {
        [rating_label appendString:@"½"];
    }else if (rating < 0.5 && rating >= 0.25) {
        [rating_label appendString:@"¼"];
    }else {
        return rating_label;
    }
    return rating_label;
//    return [NSString stringWithFormat:@"Rating: %.2f/5.0★½¾¼", [self.rating floatValue]];
}

 -(void)updateRating
{
    float rating = 0;

    if (self.dive_logs != nil) {
        
        for (ScubaLog *diveLog in self.dive_logs) {
            rating = rating + [diveLog.rating floatValue];
        }
        rating = rating / [self.dive_logs count];
    }
    
    self.rating = [NSNumber numberWithFloat:rating];
}

@end




