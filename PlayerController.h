//
//  PlayerController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-03-31.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate, AudioStreamer, Release, Track, MPVolumeView;

typedef enum {
	PL_CTRLS_STATE_UNDEFINED = 0,
	PL_CTRLS_STATE_HIDDEN,
	PL_CTRLS_STATE_VISIBLE
} PlaybackControlsState;

typedef enum {
	PL_REPEAT_OFF = 0,
	PL_REPEAT_ALL,
	PL_REPEAT_TRACK
} PlayerRepeatState;

typedef enum {
	PL_SHUFFLE_OFF = 0,
	PL_SHUFFLE_ON
} PlayerShuffleState;

@interface PlayerController : UIViewController {
	AppDelegate *appDelegate;
	IBOutlet UINavigationBar *navigationBar;
	IBOutlet UIWebView *webView;
	IBOutlet UIImageView *artwork;
	IBOutlet UIView *statusBar;
	IBOutlet UISlider *progressSlider;
	IBOutlet UILabel *currentTimeLabel;
	IBOutlet UILabel *totalTimeLabel;
	IBOutlet UIToolbar *toolBar;
	IBOutlet UIBarButtonItem *previousTrackButton;
	IBOutlet UIBarButtonItem *nextTrackButton;
	IBOutlet UIBarButtonItem *repeatButton;
	IBOutlet UIBarButtonItem *shuffleButton;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIView *volumeBar;
	IBOutlet MPVolumeView *volumeSlider;
	AudioStreamer *streamer;
	NSTimer *progressUpdateTimer;
	NSMutableArray *playlist;
	BOOL isSeeking;
}

@property (nonatomic, retain) AppDelegate *appDelegate;

@property (nonatomic, readonly) Track *currentTrack;
@property (nonatomic, readonly) NSMutableArray *playlist;
@property (nonatomic, assign) NSInteger playlistPosition;
@property (nonatomic, assign) PlaybackControlsState playbackControlsState;
@property (nonatomic, assign) PlayerRepeatState playerRepeatState;
@property (nonatomic, assign) PlayerShuffleState playerShuffleState;

- (IBAction)togglePlaybackControls:(id)sender;
- (IBAction)togglePlayback:(id)sender;
- (IBAction)nextTrack:(id)sender;
- (IBAction)previousTrack:(id)sender;
- (IBAction)toggleRepeat:(id)sender;
- (IBAction)toggleShuffle:(id)sender;
- (IBAction)seekInTrack:(id)sender;
- (IBAction)beginSeeking:(id)sender;
- (IBAction)endSeeking:(id)sender;
- (void)enqueueTrack:(Track *)track andPlay:(BOOL)play;
- (void)stopPlayback;
- (void)clearQueueAndResetPlayer:(BOOL)resetPlayer;

@end
