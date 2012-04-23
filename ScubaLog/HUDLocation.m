//
//  HUDLocation.m
//  MyLocation
//
//  Created by Kann Vearasilp on 4/23/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import "HUDLocation.h"

@implementation HUDLocation

@synthesize text;

- (void)showAnimated:(BOOL)animated
{
    if (animated) {
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        self.alpha = 1.0f;
        self.transform = CGAffineTransformIdentity;
        
        [UIView commitAnimations];
    }
}

+ (HUDLocation *)hudInView:(UIView *)view animated:(BOOL)animated
{
    HUDLocation *hudView = [[HUDLocation alloc] initWithFrame:view.bounds];
    hudView.opaque = NO;
    
    [view addSubview:hudView];
    view.userInteractionEnabled = NO;
    
    //    hudView.backgroundColor = [UIColor colorWithRed:1.0f green:0 blue:0 alpha:0.5f];
    [hudView showAnimated:animated];
    return hudView;
}

- (void)drawRect:(CGRect)rect
{
    const CGFloat boxWidth = 96.0f;
    const CGFloat boxHeight = 96.0f;
    
    CGRect boxRect = CGRectMake(
                                roundf(self.bounds.size.width - boxWidth)/2.0f, 
                                roundf(self.bounds.size.height - boxHeight)/2.0f, 
                                boxWidth, boxHeight);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:10.0f];
    [[UIColor colorWithWhite:0.0f alpha:0.75f] setFill];
    [roundedRect fill];
    
    UIImage *image = [UIImage imageNamed:@"radar"];
    
    CGPoint imagePoint = CGPointMake(
                                     self.center.x - roundf(image.size.width / 2.0f),
                                     self.center.y - roundf(image.size.width) / 2.0f - boxHeight / 8.0f);
    [image drawAtPoint:imagePoint];
    
    [[UIColor whiteColor] set];
    UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
    CGSize textSize = [self.text sizeWithFont:font];
    
    CGPoint textPoint = CGPointMake(
                                    self.center.x - roundf(textSize.width / 2.0f),
                                    self.center.y - roundf(textSize.height / 2.0f) + boxHeight / 4.0f);
    [self.text drawAtPoint:textPoint withFont:font];
    
}

@end
