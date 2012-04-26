//
//  ScubaLog.m
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/2/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import "ScubaLog.h"

@implementation ScubaLog

@dynamic diveSiteName;
@dynamic date;
@dynamic time_in;
@dynamic time_out;
@dynamic rating;
@dynamic dive_site;
@dynamic longitude;
@dynamic latitude;
@dynamic placemark;

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (NSString *)title
{
    if ([self.diveSiteName length] > 0) {
        return self.diveSiteName;
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

@end
