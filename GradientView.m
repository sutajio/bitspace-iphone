//
//  GradientView.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-08-31.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "GradientView.h"


@implementation GradientView

@synthesize gradientEnabled;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		gradientEnabled = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	if(gradientEnabled) {
		CGContextRef currentContext = UIGraphicsGetCurrentContext();
		
		CGGradientRef glossGradient;
		CGColorSpaceRef rgbColorspace;
		size_t num_locations = 2;
		CGFloat locations[2] = { 0.0, 1.0 };
		CGFloat components[8] = { 1.0, 1.0, 1.0, 0.3,  // Start color
			1.0, 1.0, 1.0, 0.6 }; // End color
		
		rgbColorspace = CGColorSpaceCreateDeviceRGB();
		glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
		
		CGRect currentBounds = self.bounds;
		CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
		CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
		CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);
		
		CGGradientRelease(glossGradient);
		CGColorSpaceRelease(rgbColorspace);
	} else {
		[super drawRect:rect];
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
