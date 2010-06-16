//
//  PlayerController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-03-31.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioStreamer;

@interface PlayerController : UIViewController {
	IBOutlet UINavigationBar *navigationBar;
	IBOutlet UIImageView *artwork;
	IBOutlet UIProgressView *progress;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *previousTrackButton;
	IBOutlet UIBarButtonItem *togglePlaybackButton;
	IBOutlet UIBarButtonItem *nextTrackButton;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	AudioStreamer *streamer;
	NSTimer *progressUpdateTimer;
}

- (IBAction)togglePlayback:(id)sender;
- (IBAction)nextTrack:(id)sender;
- (IBAction)previousTrack:(id)sender;
- (void)updateProgress:(NSTimer *)aNotification;

@end
