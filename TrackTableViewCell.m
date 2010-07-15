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


@implementation TrackTableViewCell

@synthesize track, index, showAlbumArtist;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
	
		bgView = [[UIView alloc] initWithFrame:self.frame];
		bgView.backgroundColor = [UIColor whiteColor];
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
		bgView.backgroundColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:1.0f alpha:1.0f];
	} else {
		bgView.backgroundColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.97f alpha:1.0f];
	}
	
	if([[(AppDelegate *)[[UIApplication sharedApplication] delegate] playerController] currentTrack] == track) {
		trackNrLabel.hidden = YES;
		playingImage.hidden = NO;
	} else {
		trackNrLabel.text = [NSString stringWithFormat:@"%d", self.index];
		trackNrLabel.hidden = NO;
		playingImage.hidden = YES;
	}
	
	textLabel.text = track.title;
	
	if(self.showAlbumArtist && track.artist == nil) {
		detailTextLabel.text = track.parent.artist;
	} else {
		detailTextLabel.text = track.artist;
	}
	
	if(track.lovedAt) {
		[loveButton setImage:[UIImage imageNamed:@"love-on.png"] forState:UIControlStateNormal];
	} else {
		[loveButton setImage:[UIImage imageNamed:@"love-off.png"] forState:UIControlStateNormal];
	}
	
	if([track hasCache] == YES && [track isLoading] == NO) {
		textLabel.textColor = [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
	} else {
		textLabel.textColor = [UIColor darkTextColor];
	}
	
	if([track isLoading] == YES) {
		[downloadActivityIndicator startAnimating];
		self.accessoryView = downloadActivityIndicator;
	} else {
		[downloadActivityIndicator stopAnimating];
		self.accessoryView = loveButton;
	}
	
	if([track hasCache] == NO && track.loader != nil && [track isLoading] == NO) {
		trackNrLabel.alpha = 0.3f;
		textLabel.alpha = 0.3f;
		detailTextLabel.alpha = 0.3f;
		bgView.backgroundColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.9f alpha:1.0f];
	} else {
		trackNrLabel.alpha = 1.0f;
		textLabel.alpha = 1.0f;
		detailTextLabel.alpha = 1.0f;
	}
}

- (void)loveTrack:(id)sender {
	[self.track toggleLove];
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
