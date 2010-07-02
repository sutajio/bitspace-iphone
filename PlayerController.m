//
//  PlayerController.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-03-31.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "PlayerController.h"
#import "AudioStreamer.h"
#import "AppDelegate.h"
#import "Track.h"
#import "Release.h"
#import "SyncQueue.h"
#import "ProtectedURL.h"


@implementation PlayerController

@synthesize appDelegate;


#pragma mark Streamer methods

- (void)destroyStreamer
{
	NSLog(@"Destroying streamer...");
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
		 removeObserver:self
		 name:ASStatusChangedNotification
		 object:streamer];
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

- (void)createStreamer:(NSString *)sourceUrl {
	[self destroyStreamer];
	
	NSLog(@"Creating streamer...");
	NSURL *url = [NSURL URLWithString:sourceUrl];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
	progressUpdateTimer =
	[NSTimer
	 scheduledTimerWithTimeInterval:0.1
	 target:self
	 selector:@selector(updateProgress:)
	 userInfo:nil
	 repeats:YES];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(playbackStateChanged:)
	 name:ASStatusChangedNotification
	 object:streamer];
	
	[streamer start];
}


#pragma mark Playback helper methods

- (Track *)currentTrack {
	if(playlistPosition >= 0 && playlistPosition < [playlist count]) {
		return [playlist objectAtIndex:playlistPosition];
	} else {
		return nil;
	}
}

- (NSString *)secondsToTime:(NSNumber *)seconds {
	if([seconds intValue] < 3600) {
		NSInteger minutes = [seconds intValue] / 60;
		NSInteger secs = [seconds intValue] % 60;
		return [NSString stringWithFormat:@"%d:%02d", minutes, secs];
	} else if([seconds intValue] < 86400) {
		NSInteger hours = [seconds intValue] / 3600;
		NSInteger minutes = ([seconds intValue] % 3600) / 60;
		NSInteger secs = [seconds intValue] % 60;
		return [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, secs];
	} else {
		NSInteger days = [seconds intValue] / 60 / 60 / 24;
		if(days == 1) {
			return @"1 day";
		} else {
			return [NSString stringWithFormat:@"%d days", days];
		}
	}
}

- (void)scrobbleCurrentTrack:(BOOL)nowPlaying {
	Track *track = [self currentTrack];
	if(track) {
		NSURL *url;
		if(nowPlaying == YES) {
			url = [ProtectedURL URLWithStringAndCredentials:track.nowPlayingUrl 
												   withUser:self.appDelegate.username 
												andPassword:self.appDelegate.password];
			NSLog(@"Now playing");
		} else {
			url = [ProtectedURL URLWithStringAndCredentials:track.scrobbleUrl 
												   withUser:self.appDelegate.username 
												andPassword:self.appDelegate.password];
			NSLog(@"Scrobble");
		}
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
															   cachePolicy:NSURLRequestReloadIgnoringCacheData
														   timeoutInterval:5.0];
		[request setHTTPMethod:@"POST"];
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
		[request addValue:[ProtectedURL authorizationHeaderWithUser:self.appDelegate.username 
														andPassword:self.appDelegate.password]
											  forHTTPHeaderField:@"Authorization"];
		[self.appDelegate.syncQueue enqueueRequest:request];
	}
	
}

- (void)updateProgress:(NSTimer *)updatedTimer
{
	Track *track = [self currentTrack];
	if(track) {
		progress.progress = streamer.progress / [track.length doubleValue];
		currentTimeLabel.text = [self secondsToTime:[NSNumber numberWithDouble:streamer.progress]];
		totalTimeLabel.text = [self secondsToTime:track.length];
	} else {
		progress.progress = 0;
		currentTimeLabel.text = @"0:00";
		totalTimeLabel.text = @"0:00";
	}
}

- (BOOL)isPaused {
	return [streamer isPaused];
}

- (BOOL)isPlayingFirstTrack {
	return playlistPosition == 0;
}

- (BOOL)isPlayingLastTrack {
	return playlistPosition == ([playlist count] - 1);
}

- (BOOL)hasQueuedTracks {
	return [playlist count] == 0 ? NO : YES;
}

- (void)showPlaybackControls {
	if([self hasQueuedTracks]) {
		statusBar.hidden = NO;
		toolBar.hidden = NO;
		playbackControlsState = PL_CTRLS_STATE_VISIBLE;
		[[NSUserDefaults standardUserDefaults] setInteger:PL_CTRLS_STATE_VISIBLE forKey:@"PlaybackControlsState"];
	}
}

- (void)hidePlaybackControls {
	statusBar.hidden = YES;
	toolBar.hidden = YES;
	playbackControlsState = PL_CTRLS_STATE_HIDDEN;
	[[NSUserDefaults standardUserDefaults] setInteger:PL_CTRLS_STATE_HIDDEN forKey:@"PlaybackControlsState"];
}

- (void)showArtwork:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishedLoadingLargeArtwork" object:[notification object]];
	Track *track = [self currentTrack];
	Release *release = (Release *)[notification object];
	if(release == track.parent) {
		artwork.image = track.parent.largeArtworkImage;
		artwork.hidden = NO;
	}
	
	NSError *error = nil;
	if(![self.appDelegate.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
}

- (void)updatePlayerUIBasedOnPlaybackState {
	
	// Setup the track info
	Track *track = [self currentTrack];
	if(track) {
		if(track.artist) {
			navigationBar.topItem.prompt = track.artist;
		} else {
			navigationBar.topItem.prompt = track.parent.artist;
		}
		navigationBar.topItem.title = track.title;
		navigationBar.hidden = NO;
		
		// Show the artwork for the release
		if(track.parent.largeArtworkUrl != nil) {
			if(track.parent.largeArtwork) {
				artwork.image = track.parent.largeArtworkImage;
				artwork.hidden = NO;
			} else {
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showArtwork:) name:@"finishedLoadingLargeArtwork" object:track.parent];
				artwork.image = track.parent.largeArtworkImage;
				artwork.hidden = NO;
			}
		} else {
			artwork.image = [UIImage imageNamed:@"cover-art-large.jpg"];
			artwork.hidden = NO;
		}
	}
	
	// Set the play/pause button according to the current state
	if([toolBar.items count] > 0) {
		NSMutableArray *tbItems = [NSMutableArray arrayWithArray:toolBar.items];
		if([self isPaused]) {
			UIBarButtonItem *b = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemPlay target:self action:@selector(togglePlayback:)] autorelease];
			[tbItems replaceObjectAtIndex:4 withObject:b];
		} else {
			UIBarButtonItem *b = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemPause target:self action:@selector(togglePlayback:)] autorelease];
			[tbItems replaceObjectAtIndex:4 withObject:b];
		}
		[toolBar setItems:tbItems];
	}

	// Enable or disbale the previous/next buttons
	if([self isPlayingFirstTrack] && repeatState != PL_REPEAT_ALL && shuffleState != PL_SHUFFLE_ON) {
		previousTrackButton.enabled = NO;
	} else {
		previousTrackButton.enabled = YES;
	}
	
	if([self isPlayingLastTrack] && repeatState != PL_REPEAT_ALL && shuffleState != PL_SHUFFLE_ON) {
		nextTrackButton.enabled = NO;
	} else {
		nextTrackButton.enabled = YES;
	}
	
	// Show or hide playback controls based on configuration if state is undefined
	if(playbackControlsState == PL_CTRLS_STATE_UNDEFINED || playbackControlsState == PL_CTRLS_STATE_VISIBLE) {
		[self showPlaybackControls];
	} else {
		[self hidePlaybackControls];
	}
	
	// Set the correct repeat/shuffle state
	if(repeatState == PL_REPEAT_ALL) {
		repeatButton.image = [UIImage imageNamed:@"repeat-all.png"];
	} else if(repeatState == PL_REPEAT_TRACK) {
		repeatButton.image = [UIImage imageNamed:@"repeat-track.png"];
	} else {
		repeatButton.image = [UIImage imageNamed:@"repeat-off.png"];
	}
		
	if(shuffleState == PL_SHUFFLE_ON) {
		shuffleButton.image = [UIImage imageNamed:@"shuffle-on.png"];
	} else {
		shuffleButton.image = [UIImage imageNamed:@"shuffle-off.png"];
	}
}


#pragma mark View methods


/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	
	playlist = [[NSMutableArray alloc] init];
	playlistPosition = -1;
	playbackControlsState = [[NSUserDefaults standardUserDefaults] integerForKey:@"PlaybackControlsState"];
	repeatState = [[NSUserDefaults standardUserDefaults] integerForKey:@"PlayerRepeatState"];
	shuffleState = [[NSUserDefaults standardUserDefaults] integerForKey:@"PlayerShuffleState"];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[playlist release];
	[self destroyStreamer];
    [super dealloc];
}


#pragma mark Playback controls and callbacks

- (void)playbackStateChanged:(id)notification {
	NSLog(@"playbackStateChanged");
	switch (streamer.state) {
		case AS_PLAYING:
			NSLog(@"AS_PLAYING");
			[activityIndicator stopAnimating];
			[self updatePlayerUIBasedOnPlaybackState];
			break;
		case AS_PAUSED:
			NSLog(@"AS_PAUSED");
			[self updatePlayerUIBasedOnPlaybackState];
			break;
		case AS_STOPPING:
			NSLog(@"AS_STOPPING");
			break;
		case AS_STOPPED:
			NSLog(@"AS_STOPPED");
			[self scrobbleCurrentTrack:NO];
			if([self isPlayingLastTrack]) {
				if(repeatState == PL_REPEAT_ALL ||
				   repeatState == PL_REPEAT_TRACK ||
				   shuffleState == PL_SHUFFLE_ON) {
					[self nextTrack:nil];
				} else {
					[self clearQueueAndResetPlayer:NO];
				}
			} else {
				[self nextTrack:nil];
			}
			break;
		case AS_BUFFERING:
			NSLog(@"AS_BUFFERING");
			[activityIndicator startAnimating];
			break;
		case AS_INITIALIZED:
			NSLog(@"AS_INITIALIZED");
			break;
		case AS_STARTING_FILE_THREAD:
			NSLog(@"AS_STARTING_FILE_THREAD");
			break;
		case AS_WAITING_FOR_DATA:
			NSLog(@"AS_WAITING_FOR_DATA");
			[activityIndicator startAnimating];
			break;
		case AS_WAITING_FOR_QUEUE_TO_START:
			NSLog(@"AS_WAITING_FOR_QUEUE_TO_START");
			break;
		default:
			break;
	}
}

- (void)playCurrentTrack {
	NSLog(@"Playing current track...");
	
	Track *track = [self currentTrack];
	if(track) {
		[self createStreamer:track.url];
		[self scrobbleCurrentTrack:YES];
	}
	
	[self updatePlayerUIBasedOnPlaybackState];
}

- (void)togglePlaybackControls:(id)sender {
	if(playbackControlsState == PL_CTRLS_STATE_VISIBLE) {
		[self hidePlaybackControls];
	} else {
		[self showPlaybackControls];
	}
}

- (void)togglePlayback:(id)sender {
	NSLog(@"togglePlayback");
	if([streamer isPaused]) {
		[streamer start];
	} else {
		[streamer pause];
	}
	[self updatePlayerUIBasedOnPlaybackState];
}

- (void)nextTrack:(id)sender {
	NSLog(@"nextTrack");
	if(shuffleState == PL_SHUFFLE_ON) {
		playlistPosition = rand() % [playlist count];
	} else if(repeatState == PL_REPEAT_TRACK) {
		if(sender == nil) {
			playlistPosition = playlistPosition;
		} else {
			playlistPosition++;
		}
	} else if(repeatState == PL_REPEAT_ALL && [self isPlayingLastTrack]) {
		playlistPosition = 0;
	} else {
		playlistPosition++;
	}
	[self playCurrentTrack];
}

- (void)previousTrack:(id)sender {
	NSLog(@"previousTrack");
	if(shuffleState == PL_SHUFFLE_ON) {
		playlistPosition = rand() % [playlist count];
	} else if(repeatState == PL_REPEAT_TRACK) {
		if(sender == nil) {
			playlistPosition = playlistPosition;
		} else {
			playlistPosition--;
		}
	} else if(repeatState == PL_REPEAT_ALL && playlistPosition == 0) {
		playlistPosition = [playlist count] - 1;
	} else {
		playlistPosition--;
	}
	[self playCurrentTrack];
}

- (void)toggleRepeat:(id)sender {
	if(repeatState == PL_REPEAT_ALL) {
		repeatState = PL_REPEAT_TRACK;
		[[NSUserDefaults standardUserDefaults] setInteger:PL_REPEAT_TRACK forKey:@"PlayerRepeatState"];
	} else if(repeatState == PL_REPEAT_TRACK) {
		repeatState = PL_REPEAT_OFF;
		[[NSUserDefaults standardUserDefaults] setInteger:PL_REPEAT_OFF forKey:@"PlayerRepeatState"];
	} else {
		repeatState = PL_REPEAT_ALL;
		[[NSUserDefaults standardUserDefaults] setInteger:PL_REPEAT_ALL forKey:@"PlayerRepeatState"];
	}
	[self updatePlayerUIBasedOnPlaybackState];
}

- (void)toggleShuffle:(id)sender {
	if(shuffleState == PL_SHUFFLE_ON) {
		shuffleState = PL_SHUFFLE_OFF;
		[[NSUserDefaults standardUserDefaults] setInteger:PL_SHUFFLE_OFF forKey:@"PlayerShuffleState"];
	} else {
		shuffleState = PL_SHUFFLE_ON;
		[[NSUserDefaults standardUserDefaults] setInteger:PL_SHUFFLE_ON forKey:@"PlayerShuffleState"];
	}
	[self updatePlayerUIBasedOnPlaybackState];
}

- (void)enqueueTrack:(Track *)track fromTheRelease:(Release *)release andPlay:(BOOL)play {
	NSLog(@"Enqueueing track...");
	
	[playlist addObject:track];
	if(play == YES) {
		playlistPosition = [playlist count] - 1;
		[self playCurrentTrack];
	} else {
		[self updatePlayerUIBasedOnPlaybackState];
	}
}

- (void)stopPlayback {
	NSLog(@"stopPlayback");
	if(![streamer isPaused]) {
		[streamer pause];
		[self updatePlayerUIBasedOnPlaybackState];
	}
}

- (void)clearQueueAndResetPlayer:(BOOL)resetPlayer {
	[playlist removeAllObjects];
	playlistPosition = -1;
	[self updatePlayerUIBasedOnPlaybackState];
	if(resetPlayer == YES) {
		navigationBar.hidden = YES;
		artwork.hidden = YES;
		statusBar.hidden = YES;
		toolBar.hidden = YES;
	}
}


@end

