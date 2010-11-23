//
//  Theme.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-11-15.
//  Copyright 2010 Sutajio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Theme : UIColor

+ (UIColor *)navigationBarColor;
+ (UIColor *)darkTextColor;
+ (UIColor *)backgroundColor;
+ (UIColor *)offlineTextColor;
+ (UIColor *)offlineBackgroundColor;
+ (UIColor *)evenBackgroundColor;
+ (UIColor *)oddBackgroundColor;
+ (UIColor *)loadingBackgroundColor;

@end
