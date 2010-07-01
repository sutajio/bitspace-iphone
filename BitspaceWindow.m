//
//  BitspaceWindow.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-30.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "BitspaceWindow.h"


@implementation BitspaceWindow


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceShaken" object:self];
    }
}


@end
