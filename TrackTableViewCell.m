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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
	
		bgView = [[UIView alloc] initWithFrame:self.frame];
		bgView.backgroundColor = [UIColor whiteColor];
		self.backgroundView = bgView;
		[bgView release];
		
		trackNrLabel = [[[UILabel alloc] init] autorelease];
		trackNrLabel.font = [UIFont systemFontOfSize:16.0f];
		trackNrLabel.frame = CGRectMake(0.0f, 10.0f, 40.0f, 22.0f);
		trackNrLabel.textColor = [UIColor blackColor];
		trackNrLabel.highlightedTextColor = [UIColor whiteColor];
		trackNrLabel.backgroundColor = [UIColor clearColor];
		trackNrLabel.textAlignment = UITextAlignmentCenter;
		trackNrLabel.opaque = NO;
		[self.contentView addSubview:trackNrLabel];
		
		textLabel = [[[UILabel alloc] init] autorelease];
		textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
		textLabel.frame = CGRectMake(40.0f, 10.0f, 220.0f, 22.0f);
		textLabel.textColor = [UIColor darkTextColor];
		textLabel.highlightedTextColor = [UIColor whiteColor];
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.opaque = NO;
		[self.contentView addSubview:textLabel];
		
		detailTextLabel = [[[UILabel alloc] init] autorelease];
		detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
		detailTextLabel.frame = CGRectMake(40.0f, 28.0f, 220.0f, 22.0f);
		detailTextLabel.textColor = [UIColor lightGrayColor];
		detailTextLabel.highlightedTextColor = [UIColor whiteColor];
		detailTextLabel.backgroundColor = [UIColor clearColor];
		detailTextLabel.opaque = NO;
		[self.contentView addSubview:detailTextLabel];
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		
		loveButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		loveButton.frame = CGRectMake(0.0f, 0.0f, 44.0f, 44.0f);
		[loveButton addTarget:self action:@selector(loveTrack:) forControlEvents:UIControlEventTouchUpInside];
		self.accessoryView = loveButton;
		
		downloadActivityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] retain];
		[downloadActivityIndicator stopAnimating];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadWillBegin:) name:@"TrackOfflineModeDownloadWillBegin" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDownloadActivity:) name:@"TrackOfflineModeDownloadDidBegin" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideDownloadActivity:) name:@"TrackOfflineModeDownloadDidFinish" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offlineModeDidClear:) name:@"TrackOfflineModeDidClear" object:nil];
	}
	
	return self;
}

- (void)updateLoveButtonState {
	if(track.lovedAt) {
		[loveButton setImage:[UIImage imageNamed:@"love-on.png"] forState:UIControlStateNormal];
	} else {
		[loveButton setImage:[UIImage imageNamed:@"love-off.png"] forState:UIControlStateNormal];
	}
}

- (void)showDownloadActivity:(NSNotification *)notification {
	if(notification && [notification object] != track)
		return;
	
	[downloadActivityIndicator startAnimating];
	self.accessoryView = downloadActivityIndicator;
}

- (void)hideDownloadActivity:(NSNotification *)notification {
	if(notification && [notification object] != track)
		return;
	
	[downloadActivityIndicator stopAnimating];
	self.accessoryView = loveButton;
}

- (void)updateOfflineModeState {
	if([track hasCache] == YES) {
		textLabel.textColor = [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
	} else {
		textLabel.textColor = [UIColor darkTextColor];
		if([track isLoading] == YES) {
			[self showDownloadActivity:nil];
		} else {
			[self hideDownloadActivity:nil];
		}
	}
}

- (void)downloadWillBegin:(NSNotification *)notification {
	if([notification object] == track) {
		[self updateOfflineModeState];
	}
}

- (void)offlineModeDidClear:(NSNotification *)notification {
	if([notification object] == track) {
		[self updateOfflineModeState];
	}
}

- (void)setTrack:(Track *)value {
	track = value;
	
	if([track.trackNr intValue] % 2) {
		bgView.backgroundColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:1.0f alpha:1.0f];
	} else {
		bgView.backgroundColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.97f alpha:1.0f];
	}
		
	trackNrLabel.text = [track.trackNr stringValue];
	textLabel.text = track.title;
	detailTextLabel.text = track.artist;
	
	[self updateLoveButtonState];
	[self updateOfflineModeState];
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
	[track.managedObjectContext save:nil];
	[appDelegate.syncQueue enqueueRequest:request];
	[self updateLoveButtonState];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	
	trackNrLabel.highlighted = highlighted;
	textLabel.highlighted = highlighted;
	detailTextLabel.highlighted = highlighted;
	loveButton.highlighted = NO;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[loveButton release];
	[downloadActivityIndicator release];
	[super dealloc];
}

@end
