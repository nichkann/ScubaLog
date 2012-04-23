//
//  HUDLocation.h
//  MyLocation
//
//  Created by Kann Vearasilp on 4/23/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HUDLocation : UIView

+ (HUDLocation *)hudInView:(UIView *)view animated:(BOOL)animated;

@property (nonatomic, strong) NSString *text;


@end
