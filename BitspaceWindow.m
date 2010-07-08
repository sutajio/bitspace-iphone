//
//  BitspaceWindow.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-30.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "BitspaceWindow.h"
#import "AppDelegate.h"
#import "PlayerController.h"


@implementation BitspaceWindow


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	switch (event.subtype) {
		case UIEventSubtypeRemoteControlTogglePlayPause:
			[[appDelegate playerController] togglePlayback:nil];
			break;
		case UIEventSubtypeRemoteControlPlay:
			[[appDelegate playerController] togglePlayback:nil];
			break;
		case UIEventSubtypeRemoteControlPause:
			[[appDelegate playerController] togglePlayback:nil];
			break;
		case UIEventSubtypeRemoteControlStop:
			[[appDelegate playerController] stopPlayback];
			break;
		case UIEventSubtypeRemoteControlNextTrack:
			[[appDelegate playerController] nextTrack:nil];
			break;
		case UIEventSubtypeRemoteControlPreviousTrack:
			[[appDelegate playerController] previousTrack:nil];
			break;
	}
}
#endif

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceShaken" object:self];
    }
}


@end
