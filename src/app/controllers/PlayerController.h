//
//  PlayerController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-03-31.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate, AudioStreamer, Release, Track, MPVolumeView, Reachability;

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

#define AUTO_HIDE_PLAYBACK_CONTROLS_TIMEOUT_IN_SECONDS 10

@interface PlayerController : UIViewController {
	AppDelegate *appDelegate;
	IBOutlet UINavigationBar *navigationBar;
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
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
	UIBackgroundTaskIdentifier backgroundTask;
#endif
	Reachability *reachability;
	BOOL isTemporarilyOffline;
	double startPlayingAt;
	double previousPlayedTime;
	double totalPlayedTime;
	BOOL shouldScrobble;
	BOOL hasScrobbled;
	NSTimer *autoHidePlaybackControlsTimer;
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
- (void)enqueueTracks:(NSArray *)tracks;
- (void)enqueueTracks:(NSArray *)tracks andPlayTrackWithIndex:(NSInteger)index;
- (void)stopPlayback;
- (void)clearQueueAndResetPlayer:(BOOL)resetPlayer;

@end
