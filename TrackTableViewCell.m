//
//  TrackTableViewCell.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-18.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "TrackTableViewCell.h"
#import "Track.h"
#import "Release.h"
#import "AppDelegate.h"
#import "PlayerController.h"
#import "GradientView.h"
#import "Theme.h"


@implementation TrackTableViewCell

@synthesize track, index, showAlbumArtist;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
	
		bgView = [[GradientView alloc] initWithFrame:self.frame];
		bgView.backgroundColor = [Theme backgroundColor];
		bgView.gradientEnabled = NO;
		self.backgroundView = bgView;
		[bgView release];
		
		playingImage = [[[UIImageView alloc] init] autorelease];
		playingImage.frame = CGRectMake(12.0f, 13.0f, 16.0f, 16.0f);
		playingImage.image = [UIImage imageNamed:@"playing.png"];
		playingImage.hidden = YES;
		[self.contentView addSubview:playingImage];
		
		trackNrLabel = [[[UILabel alloc] init] autorelease];
		trackNrLabel.font = [UIFont systemFontOfSize:16.0f];
		trackNrLabel.frame = CGRectMake(0.0f, 10.0f, 40.0f, 22.0f);
		trackNrLabel.textColor = [Theme darkTextColor];
		trackNrLabel.highlightedTextColor = [UIColor whiteColor];
		trackNrLabel.backgroundColor = [UIColor clearColor];
		trackNrLabel.textAlignment = UITextAlignmentCenter;
		trackNrLabel.opaque = NO;
		[self.contentView addSubview:trackNrLabel];
		
		textLabel = [[[UILabel alloc] init] autorelease];
		textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
		textLabel.frame = CGRectMake(40.0f, 10.0f, 220.0f, 22.0f);
		textLabel.textColor = [Theme darkTextColor];
		textLabel.highlightedTextColor = [UIColor whiteColor];
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.opaque = NO;
		[self.contentView addSubview:textLabel];
		
		detailTextLabel = [[[UILabel alloc] init] autorelease];
		detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
		detailTextLabel.frame = CGRectMake(40.0f, 28.0f, 220.0f, 22.0f);
		detailTextLabel.textColor = [Theme darkTextColor];
		detailTextLabel.highlightedTextColor = [UIColor whiteColor];
		detailTextLabel.backgroundColor = [UIColor clearColor];
		detailTextLabel.opaque = NO;
		[self.contentView addSubview:detailTextLabel];
		
		downloadActivityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] retain];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(updateState:) 
													 name:@"TrackOfflineModeDownloadWillBegin" 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(updateState:) 
													 name:@"TrackOfflineModeDownloadDidBegin" 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(updateState:) 
													 name:@"TrackOfflineModeDownloadDidFinish" 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(updateState:) 
													 name:@"TrackOfflineModeDidClear" 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(updateState:) 
													 name:@"TrackLoveStateDidChange" 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(updateState:) 
													 name:@"TrackDidStartPlaying" 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(updateState:) 
													 name:@"TrackDidStopPlaying" 
												   object:nil];
	}
	
	return self;
}

- (void)updateState:(NSNotification *)notification {
	if(notification && [notification object] != track)
		return;
	self.track = track;
}

- (void)setTrack:(Track *)value {
	track = value;
	
	if(self.index % 2) {
		bgView.backgroundColor = [Theme evenBackgroundColor];
	} else {
		bgView.backgroundColor = [Theme oddBackgroundColor];
	}
	
	if([[(AppDelegate *)[[UIApplication sharedApplication] delegate] playerController] currentTrack] == track) {
		trackNrLabel.hidden = YES;
		playingImage.hidden = NO;
		textLabel.frame = CGRectMake(40.0f, 10.0f, 220.0f, 22.0f);
		detailTextLabel.frame = CGRectMake(40.0f, 28.0f, 220.0f, 22.0f);
	} else {
		playingImage.hidden = YES;
		if(self.index == -1) {
			trackNrLabel.hidden = YES;
			textLabel.frame = CGRectMake(10.0f, 10.0f, 250.0f, 22.0f);
			detailTextLabel.frame = CGRectMake(10.0f, 28.0f, 250.0f, 22.0f);
		} else {
			trackNrLabel.text = [NSString stringWithFormat:@"%d", self.index];
			trackNrLabel.hidden = NO;
			textLabel.frame = CGRectMake(40.0f, 10.0f, 220.0f, 22.0f);
			detailTextLabel.frame = CGRectMake(40.0f, 28.0f, 220.0f, 22.0f);
		}
	}
	
	textLabel.text = track.title;
	
	if(self.showAlbumArtist && track.artist == nil) {
		detailTextLabel.text = track.parent.artist;
	} else {
		detailTextLabel.text = track.artist;
	}
	
	if([track hasCache] == YES && [track isLoading] == NO) {
		textLabel.textColor = [Theme offlineTextColor];
		detailTextLabel.textColor = [Theme offlineTextColor];
		trackNrLabel.textColor = [Theme offlineTextColor];
		bgView.backgroundColor = [Theme offlineBackgroundColor];
		bgView.gradientEnabled = YES;
	} else {
		textLabel.textColor = [Theme darkTextColor];
		detailTextLabel.textColor = [Theme darkTextColor];
		trackNrLabel.textColor = [Theme darkTextColor];
		bgView.gradientEnabled = NO;
	}
	
	if([track isLoading] == YES) {
		[downloadActivityIndicator startAnimating];
		self.accessoryView = downloadActivityIndicator;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		[downloadActivityIndicator stopAnimating];
		self.accessoryType = UITableViewCellAccessoryNone;
	}
	
	if([track hasCache] == NO && track.loader != nil && [track isLoading] == NO) {
		trackNrLabel.alpha = 0.3f;
		textLabel.alpha = 0.3f;
		detailTextLabel.alpha = 0.3f;
		bgView.backgroundColor = [Theme loadingBackgroundColor];
	} else {
		trackNrLabel.alpha = 1.0f;
		textLabel.alpha = 1.0f;
		detailTextLabel.alpha = 1.0f;
	}
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	
	trackNrLabel.highlighted = highlighted;
	textLabel.highlighted = highlighted;
	detailTextLabel.highlighted = highlighted;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[downloadActivityIndicator release];
	[super dealloc];
}

@end
