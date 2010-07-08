//
//  ReleaseTableViewCell.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-28.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "ReleaseTableViewCell.h"
#import "Release.h"
#import "Track.h"


@implementation ReleaseTableViewCell

@synthesize release;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDidBegin:) name:@"TrackOfflineModeDownloadDidBegin" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDidFinish:) name:@"TrackOfflineModeDownloadDidFinish" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offlineModeDidClear:) name:@"TrackOfflineModeDidClear" object:nil];
	}
	
	return self;
}

- (void)showArtwork:(NSNotification *)notification {
	if([notification object] == release) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishedLoadingSmallArtwork" object:[notification object]];
		self.imageView.image = ((Release *)[notification object]).smallArtworkImage;
		[self setNeedsLayout];
	}
}

- (void)showActivity {
	UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[activityView startAnimating];
	self.accessoryView = activityView;
	[activityView release];
	[self setNeedsLayout];
}

- (void)hideActivity {
	self.accessoryView = nil;
	[self setNeedsLayout];
}

- (void)showDownloadProgress {
	if(downloadProgressView == nil) {
		downloadProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		downloadProgressView.frame = CGRectMake(135.0f, 95.0f, 175.0f, 9.0f);
		downloadProgressView.progress = 0.0f;
		[self.contentView addSubview:downloadProgressView];
	}
	downloadProgressView.hidden = NO;
	downloadProgressView.progress = (float)[release numberOfOfflineTracks] / (float)[release numberOfTracks];
	[self setNeedsLayout];
}

- (void)hideDownloadProgress {
	if(downloadProgressView) {
		downloadProgressView.hidden = YES;
		downloadProgressView.progress = 0.0f;
		[self setNeedsLayout];
	}
}

- (void)updateOfflineModeState {
	if([release hasOfflineTracks] == YES) {
		self.textLabel.textColor = [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
	} else {
		self.textLabel.textColor = [UIColor darkTextColor];
	}
	if([release hasLoadingTracks] == YES) {
		[self showDownloadProgress];
	} else {
		[self hideDownloadProgress];
	}
}

- (void)downloadDidBegin:(NSNotification *)notification {
	if([release hasTrack:[notification object]]) {
		[self updateOfflineModeState];
	}
}

- (void)downloadDidFinish:(NSNotification *)notification {
	if([release hasTrack:[notification object]]) {
		[self updateOfflineModeState];
	}
}

- (void)offlineModeDidClear:(NSNotification *)notification {
	if([release hasTrack:[notification object]]) {
		[self updateOfflineModeState];
	}
}

- (void)setRelease:(Release *)value {
	release = value;
	self.textLabel.text = self.release.title;
	self.detailTextLabel.text = self.release.artist;
	if(release.smallArtworkImage) {
		self.imageView.image = release.smallArtworkImage;
	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showArtwork:) name:@"finishedLoadingSmallArtwork" object:release];
		self.imageView.image = [UIImage imageNamed:@"cover-art-small.jpg"];
	}
	[self updateOfflineModeState];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"TrackOfflineModeDownloadDidBegin"];
	[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"TrackOfflineModeDownloadDidFinish"];
	[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"TrackOfflineModeDidClear"];
	[downloadProgressView release];
	[super dealloc];
}

@end
