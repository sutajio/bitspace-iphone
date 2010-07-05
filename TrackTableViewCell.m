//
//  TrackTableViewCell.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-18.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "TrackTableViewCell.h"
#import "Track.h"
#import "SyncQueue.h"
#import "ProtectedURL.h"
#import "AppDelegate.h"


@implementation TrackTableViewCell

@synthesize track;

- (void)updateLoveButtonState {
	if(track.lovedAt) {
		[loveButton setImage:[UIImage imageNamed:@"love-on.png"] forState:UIControlStateNormal];
	} else {
		[loveButton setImage:[UIImage imageNamed:@"love-off.png"] forState:UIControlStateNormal];
	}
}

- (void)setTrack:(Track *)value {
	track = value;
	self.textLabel.backgroundColor = [UIColor clearColor];
	self.textLabel.opaque = NO;
	self.detailTextLabel.backgroundColor = [UIColor whiteColor];
	self.textLabel.text = track.title;
	self.detailTextLabel.text = track.artist;
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	loveButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
	[loveButton addTarget:self action:@selector(loveTrack:) forControlEvents:UIControlEventTouchUpInside];
	[self updateLoveButtonState];
	self.accessoryView = loveButton;
	UIView *bg = [[UIView alloc] initWithFrame:self.frame];
	bg.backgroundColor = [UIColor whiteColor];
	self.backgroundView = bg;
	[bg release];
}

- (void)loveTrack:(id)sender {
	NSLog(@"Love");
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSURL *url = [ProtectedURL URLWithStringAndCredentials:track.loveUrl withUser:appDelegate.username andPassword:appDelegate.password];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestReloadIgnoringCacheData
													   timeoutInterval:5.0];
	[request setHTTPMethod:@"PUT"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request addValue:[ProtectedURL authorizationHeaderWithUser:appDelegate.username 
													andPassword:appDelegate.password]
										  forHTTPHeaderField:@"Authorization"];
	if(track.lovedAt) {
		[request setHTTPBody:[@"toggle=off" dataUsingEncoding:NSUTF8StringEncoding]];
		track.lovedAt = nil;
	} else {
		[request setHTTPBody:[@"toggle=on" dataUsingEncoding:NSUTF8StringEncoding]];
		track.lovedAt = [NSDate date];
	}
	[appDelegate.syncQueue enqueueRequest:request];
	[self updateLoveButtonState];
}

@end
