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


@implementation PlayerController

@synthesize appDelegate;

- (void)destroyStreamer
{
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

- (void)createStreamer
{
	if (streamer)
	{
		return;
	}
	
	[self destroyStreamer];
	
	NSString *escapedValue =
	[(NSString *)CFURLCreateStringByAddingPercentEscapes(
														 nil,
														 (CFStringRef)@"http://cdn.bitspace.at/tracks/926a59b9e64da70773cad93973e9d8b980751963.mp3",
														 NULL,
														 NULL,
														 kCFStringEncodingUTF8)
	 autorelease];
	
	NSURL *url = [NSURL URLWithString:escapedValue];
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
}

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

	NSURL *url = [NSURL URLWithString:@"http://cdn.bitspace.at/releases/artworks/large/000/003/523-1269973952.png"];
	NSData *data = [NSData dataWithContentsOfURL:url];
	UIImage *img = [[UIImage alloc] initWithData:data];
	artwork.image = img;
	
	[self createStreamer];
	//[streamer start];
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
	[self destroyStreamer];
	if (progressUpdateTimer)
	{
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
	}
    [super dealloc];
}

- (void)updateProgress:(NSTimer *)updatedTimer
{
	progress.progress = streamer.progress / 100.0;
}

- (void)playbackStateChanged:(id)notification {
	NSLog(@"playbackStateChanged");
	switch (streamer.state) {
		case AS_PLAYING:
			NSLog(@"AS_PLAYING");
			[activityIndicator stopAnimating];
			[togglePlaybackButton initWithBarButtonSystemItem: UIBarButtonSystemItemPause target:self action:@selector(togglePlayback:)];
			break;
		case AS_PAUSED:
			NSLog(@"AS_PAUSED");
			[togglePlaybackButton initWithBarButtonSystemItem: UIBarButtonSystemItemPlay target:self action:@selector(togglePlayback:)];
			break;
		case AS_STOPPING:
			NSLog(@"AS_STOPPING");
			break;
		case AS_STOPPED:
			NSLog(@"AS_STOPPED");
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

- (void)togglePlayback:(id)sender {
	NSLog(@"togglePlayback");
	if([streamer isPaused]) {
		[streamer start];
	} else {
		[streamer pause];
	}
}

- (void)nextTrack:(id)sender {
	NSLog(@"nextTrack");
}

- (void)previousTrack:(id)sender {
	NSLog(@"previousTrack");
}


@end

