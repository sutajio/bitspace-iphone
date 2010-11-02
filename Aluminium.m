//
//  Aluminium.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-08-03.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "Aluminium.h"


@implementation UIColor (Aluminium)

+ (UIColor *)aluminiumColor {
	return [UIColor blackColor];
}

+ (UIColor *)aluminiumPattern {
	return [UIColor colorWithPatternImage:[UIImage imageNamed:@"aluminium.png"]];
}

@end
