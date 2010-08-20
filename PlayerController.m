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

- (void)createStreamer:(Track *)track {
	[self destroyStreamer];
	
	NSLog(@"Creating streamer...");
	if([track hasCache]) {
		streamer = [[AudioStreamer alloc] initWithFileAtPath:[track cachedFilePath]];
	} else {
		streamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:track.url]];
	}
	
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
	if(self.playlistPosition >= 0 && self.playlistPosition < [self.playlist count]) {
		return [self.playlist objectAtIndex:self.playlistPosition];
	} else {
		return nil;
	}
}

- (NSMutableArray *)playlist {
	if(playlist == nil) {
		playlist = [[NSMutableArray alloc] init];
		for(NSString *trackId in [[NSUserDefaults standardUserDefaults] arrayForKey:@"Playlist"]) {
			NSManagedObjectID *objectID = [self.appDelegate.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:trackId]];
			if(objectID) {
				Track *track = (Track *)[self.appDelegate.managedObjectContext objectWithID:objectID];
				[playlist addObject:track];
			}
		}
	}
	return playlist;
}

- (void)persistPlaylist {
	NSMutableArray *trackIds = [NSMutableArray arrayWithCapacity:[self.playlist count]];
	for(Track *track in self.playlist) {
		[trackIds addObject:[[[track objectID] URIRepresentation] absoluteString]];
	}
	[[NSUserDefaults standardUserDefaults] setObject:trackIds forKey:@"Playlist"];
}

- (NSInteger)playlistPosition {
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"PlaylistPosition"];
}

- (void)setPlaylistPosition:(NSInteger)value {
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"PlaylistPosition"];
}

- (PlaybackControlsState)playbackControlsState {
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"PlaybackControlsState"];
}

- (void)setPlaybackControlsState:(PlaybackControlsState)value {
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"PlaybackControlsState"];
}

- (PlayerRepeatState)playerRepeatState {
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"PlayerRepeatState"];
}

- (void)setPlayerRepeatState:(PlayerRepeatState)value {
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"PlayerRepeatState"];
}

- (PlayerShuffleState)playerShuffleState {
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"PlayerShuffleState"];
}

- (void)setPlayerShuffleState:(PlayerShuffleState)value {
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"PlayerShuffleState"];
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
	if(track && [track.length intValue] > 30) {
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
		if(isSeeking == NO) {
			[progressSlider setValue:streamer.progress / [track.length doubleValue] animated:YES];
		}
		currentTimeLabel.text = [self secondsToTime:[NSNumber numberWithDouble:streamer.progress]];
		totalTimeLabel.text = [self secondsToTime:track.length];
	} else {
		progressSlider.value = 0;
		currentTimeLabel.text = @"0:00";
		totalTimeLabel.text = @"0:00";
	}
}

- (BOOL)isPaused {
	return streamer ? [streamer isPaused] : YES;
}

- (BOOL)isStopped {
	return streamer ? NO : YES;
}

- (BOOL)isPlayingFirstTrack {
	return self.playlistPosition == 0;
}

- (BOOL)isPlayingLastTrack {
	return self.playlistPosition == ([self.playlist count] - 1);
}

- (BOOL)hasQueuedTracks {
	return [self.playlist count] == 0 ? NO : YES;
}

- (void)showPlaybackControls {
	if([self hasQueuedTracks]) {
		[UIView beginAnimations:@"MoveAndStrech" context:nil];
		[UIView setAnimationDuration:0.2f];
		[UIView setAnimationBeginsFromCurrentState:YES];
		statusBar.alpha = 0.75f;
		toolBar.alpha = 0.75f;
		volumeBar.alpha = 0.75f;
		statusBar.frame = CGRectMake(0, 367, 320, 44);
		toolBar.frame = CGRectMake(0, 323, 320, 44);
		volumeBar.frame = CGRectMake(0, 74, 320, 46);
		statusBar.hidden = NO;
		toolBar.hidden = NO;
		volumeBar.hidden = NO;
		[UIView commitAnimations];
		self.playbackControlsState = PL_CTRLS_STATE_VISIBLE;
	}
}

- (void)hidePlaybackControls {
	[UIView beginAnimations:@"MoveAndStrech" context:nil];
	[UIView setAnimationDuration:0.2f];
	[UIView setAnimationBeginsFromCurrentState:YES];
	statusBar.alpha = 0.0f;
	toolBar.alpha = 0.0f;
	volumeBar.alpha = 0.0f;
	statusBar.frame = CGRectMake(0, 455, 320, 44);
	toolBar.frame = CGRectMake(0, 411, 320, 44);
	volumeBar.frame = CGRectMake(0, 28, 320, 46);
	[UIView commitAnimations];
	self.playbackControlsState = PL_CTRLS_STATE_HIDDEN;
}

- (void)showArtwork:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishedLoadingLargeArtwork" object:[notification object]];
	Track *track = [self currentTrack];
	Release *release = (Release *)[notification object];
	if(release == track.parent) {
		artwork.image = track.parent.largeArtworkImage;
		artwork.hidden = NO;
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
		if(track.parent.largeArtworkImage) {
			artwork.image = track.parent.largeArtworkImage;
			artwork.hidden = NO;
		} else {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showArtwork:) name:@"finishedLoadingLargeArtwork" object:track.parent];
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
	if([self isPlayingFirstTrack] && self.playerRepeatState != PL_REPEAT_ALL && self.playerShuffleState != PL_SHUFFLE_ON) {
		previousTrackButton.enabled = NO;
	} else {
		previousTrackButton.enabled = YES;
	}
	
	if([self isPlayingLastTrack] && self.playerRepeatState != PL_REPEAT_ALL && self.playerShuffleState != PL_SHUFFLE_ON) {
		nextTrackButton.enabled = NO;
	} else {
		nextTrackButton.enabled = YES;
	}
	
	// Show or hide playback controls based on configuration if state is undefined
	if(self.playbackControlsState == PL_CTRLS_STATE_UNDEFINED || self.playbackControlsState == PL_CTRLS_STATE_VISIBLE) {
		[self showPlaybackControls];
	} else {
		[self hidePlaybackControls];
	}
	
	// Set the correct repeat/shuffle state
	if(self.playerRepeatState == PL_REPEAT_ALL) {
		repeatButton.image = [UIImage imageNamed:@"repeat-all.png"];
	} else if(self.playerRepeatState == PL_REPEAT_TRACK) {
		repeatButton.image = [UIImage imageNamed:@"repeat-track.png"];
	} else {
		repeatButton.image = [UIImage imageNamed:@"repeat-off.png"];
	}
		
	if(self.playerShuffleState == PL_SHUFFLE_ON) {
		shuffleButton.image = [UIImage imageNamed:@"shuffle-on.png"];
	} else {
		shuffleButton.image = [UIImage imageNamed:@"shuffle-off.png"];
	}
	
	// Enable or disable the progress slider depending on the current playback state
	if([self isPaused]) {
		progressSlider.enabled = NO;
	} else {
		progressSlider.enabled = YES;
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
	
	backgroundTask = UIBackgroundTaskInvalid;
	
	NSString *startPage = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"StartPage"];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:startPage]];
	[webView loadRequest:request];
	[webView setBackgroundColor:[UIColor clearColor]];
	[webView setOpaque:NO];
	
	[progressSlider setThumbImage:[UIImage imageNamed:@"progress-slider-thumb.png"] forState:UIControlStateNormal];
	[progressSlider setThumbImage:[UIImage imageNamed:@"progress-slider-thumb-highlighted.png"] forState:UIControlStateHighlighted];
	[progressSlider setMinimumTrackImage:[[UIImage imageNamed:@"progress-slider-minimum.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateNormal];
	[progressSlider setMaximumTrackImage:[[UIImage imageNamed:@"progress-slider-maximum.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateNormal];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self updatePlayerUIBasedOnPlaybackState];
}

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
	switch (streamer.state) {
		case AS_PLAYING:
			NSLog(@"AS_PLAYING");
			[activityIndicator stopAnimating];
			[self updatePlayerUIBasedOnPlaybackState];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
			if([[UIApplication sharedApplication] respondsToSelector:@selector(endBackgroundTask:)]) {
				if(backgroundTask != UIBackgroundTaskInvalid) {
					[[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
					backgroundTask = UIBackgroundTaskInvalid;
				}
			}
#endif
			break;
		case AS_PAUSED:
			NSLog(@"AS_PAUSED");
			[self updatePlayerUIBasedOnPlaybackState];
			break;
		case AS_STOPPING:
			NSLog(@"AS_STOPPING");
			NSLog(@"Error code: %d", streamer.errorCode);
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
			if([[UIApplication sharedApplication] respondsToSelector:@selector(beginBackgroundTaskWithExpirationHandler:)]) {
				if(backgroundTask == UIBackgroundTaskInvalid) {
					backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
				}
			}
#endif
			break;
		case AS_STOPPED:
			NSLog(@"AS_STOPPED");
			[self scrobbleCurrentTrack:NO];
			if([self isPlayingLastTrack]) {
				if(self.playerRepeatState == PL_REPEAT_ALL ||
				   self.playerRepeatState == PL_REPEAT_TRACK ||
				   self.playerShuffleState == PL_SHUFFLE_ON) {
					[self nextTrack:nil];
				} else {
					[self clearQueueAndResetPlayer:YES];
				}
			} else {
				[self nextTrack:nil];
			}
			break;
		case AS_BUFFERING:
			NSLog(@"AS_BUFFERING");
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
			if([[UIApplication sharedApplication] respondsToSelector:@selector(beginBackgroundTaskWithExpirationHandler:)]) {
				if(backgroundTask == UIBackgroundTaskInvalid) {
					backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
				}
			}
#endif
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
		case AS_FLUSHING_EOF:
			NSLog(@"AS_FLUSHING_EOF");
			break;
		default:
			break;
	}
}

- (void)playCurrentTrack {
	NSLog(@"Playing current track...");
	
	Track *track = [self currentTrack];
	if(track) {
		[self createStreamer:track];
		[self scrobbleCurrentTrack:YES];
	}
	
	[self updatePlayerUIBasedOnPlaybackState];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackDidStartPlaying" object:track];
}

- (void)togglePlaybackControls:(id)sender {
	if(self.playbackControlsState == PL_CTRLS_STATE_VISIBLE) {
		[self hidePlaybackControls];
	} else {
		[self showPlaybackControls];
	}
}

- (void)togglePlayback:(id)sender {
	NSLog(@"togglePlayback");
	if([self isStopped] == NO) {
		if([self isPaused]) {
			[streamer start];
		} else {
			[streamer pause];
		}
	} else {
		[self playCurrentTrack];
	}
	[self updatePlayerUIBasedOnPlaybackState];
}

- (void)nextTrack:(id)sender {
	NSLog(@"nextTrack");
	Track *oldTrack = [self currentTrack];
	if(self.playerShuffleState == PL_SHUFFLE_ON) {
		self.playlistPosition = rand() % [self.playlist count];
	} else if(self.playerRepeatState == PL_REPEAT_TRACK) {
		if(sender == nil) {
			self.playlistPosition = self.playlistPosition;
		} else {
			self.playlistPosition++;
		}
	} else if(self.playerRepeatState == PL_REPEAT_ALL && [self isPlayingLastTrack]) {
		self.playlistPosition = 0;
	} else {
		if([self isPlayingLastTrack] == NO) {
			self.playlistPosition++;
		}
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackDidStopPlaying" object:oldTrack];
	[self playCurrentTrack];
}

- (void)previousTrack:(id)sender {
	NSLog(@"previousTrack");
	Track *oldTrack = [self currentTrack];
	if(self.playerShuffleState == PL_SHUFFLE_ON) {
		self.playlistPosition = rand() % [self.playlist count];
	} else if(self.playerRepeatState == PL_REPEAT_TRACK) {
		if(sender == nil) {
			self.playlistPosition = self.playlistPosition;
		} else {
			self.playlistPosition--;
		}
	} else if(self.playerRepeatState == PL_REPEAT_ALL && self.playlistPosition == 0) {
		self.playlistPosition = [self.playlist count] - 1;
	} else {
		if([self isPlayingFirstTrack] == NO) {
			self.playlistPosition--;
		}
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackDidStopPlaying" object:oldTrack];
	[self playCurrentTrack];
}

- (void)toggleRepeat:(id)sender {
	if(self.playerRepeatState == PL_REPEAT_ALL) {
		self.playerRepeatState = PL_REPEAT_TRACK;
		[[NSUserDefaults standardUserDefaults] setInteger:PL_REPEAT_TRACK forKey:@"PlayerRepeatState"];
	} else if(self.playerRepeatState == PL_REPEAT_TRACK) {
		self.playerRepeatState = PL_REPEAT_OFF;
		[[NSUserDefaults standardUserDefaults] setInteger:PL_REPEAT_OFF forKey:@"PlayerRepeatState"];
	} else {
		self.playerRepeatState = PL_REPEAT_ALL;
		[[NSUserDefaults standardUserDefaults] setInteger:PL_REPEAT_ALL forKey:@"PlayerRepeatState"];
	}
	[self updatePlayerUIBasedOnPlaybackState];
}

- (void)toggleShuffle:(id)sender {
	if(self.playerShuffleState == PL_SHUFFLE_ON) {
		self.playerShuffleState = PL_SHUFFLE_OFF;
		[[NSUserDefaults standardUserDefaults] setInteger:PL_SHUFFLE_OFF forKey:@"PlayerShuffleState"];
	} else {
		self.playerShuffleState = PL_SHUFFLE_ON;
		[[NSUserDefaults standardUserDefaults] setInteger:PL_SHUFFLE_ON forKey:@"PlayerShuffleState"];
	}
	[self updatePlayerUIBasedOnPlaybackState];
}

- (void)seekInTrack:(id)sender {
	if([self currentTrack]) {
		[streamer seekToTime:progressSlider.value * [[self currentTrack].length doubleValue]];
	}
}

- (void)beginSeeking:(id)sender {
	isSeeking = YES;
	NSLog(@"beginSeeking");
}

- (void)endSeeking:(id)sender {
	[NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(stopSeeking) userInfo:nil repeats:NO];
	NSLog(@"endSeeking");
}

- (void)stopSeeking {
	isSeeking = NO;
	NSLog(@"stopSeeking");
}

- (void)enqueueTracks:(NSArray *)tracks {
	[self clearQueueAndResetPlayer:NO];
	[self.playlist addObjectsFromArray:tracks];
	[self persistPlaylist];
}

- (void)enqueueTracks:(NSArray *)tracks andPlayTrackWithIndex:(NSInteger)index {
	[self enqueueTracks:tracks];
	if(index != -1) {
		self.playlistPosition = index;
		[self playCurrentTrack];
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
	Track *oldTrack = [self currentTrack];
	
	[self.playlist removeAllObjects];
	[self persistPlaylist];
	
	self.playlistPosition = -1;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackDidStopPlaying" object:oldTrack];
	[self updatePlayerUIBasedOnPlaybackState];
	if(resetPlayer == YES) {
		navigationBar.hidden = YES;
		artwork.hidden = YES;
		statusBar.hidden = YES;
		toolBar.hidden = YES;
		volumeBar.hidden = YES;
	}
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
}

@end

