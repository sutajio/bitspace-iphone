//
//  Theme.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-11-15.
//  Copyright 2010 Sutajio. All rights reserved.
//

#import "Theme.h"


@implementation Theme

+ (UIColor *)navigationBarColor {
	return [UIColor blackColor];
}

+ (UIColor *)darkTextColor {
	return [UIColor darkTextColor];
}

+ (UIColor *)backgroundColor {
	return [UIColor whiteColor];
}

+ (UIColor *)offlineTextColor {
	return [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
}

+ (UIColor *)offlineBackgroundColor {
	return [UIColor colorWithHue:0.36f saturation:0.03f brightness:1.0f alpha:1.0f];
}

+ (UIColor *)evenBackgroundColor {
	return [UIColor colorWithHue:0.0f saturation:0.0f brightness:1.0f alpha:1.0f];
}

+ (UIColor *)oddBackgroundColor {
	return [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.97f alpha:1.0f];
}

+ (UIColor *)loadingBackgroundColor {
	return [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.9f alpha:1.0f];
}

@end
