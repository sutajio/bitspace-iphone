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
#import "GradientView.h"
#import "Theme.h"


@implementation ReleaseTableViewCell

@synthesize release;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		
		bgView = [[GradientView alloc] initWithFrame:self.frame];
		bgView.backgroundColor = [Theme backgroundColor];
		bgView.gradientEnabled = NO;
		self.backgroundView = bgView;
		[bgView release];
		
		artworkImageView = [[[UIImageView alloc] init] autorelease];
		artworkImageView.frame = CGRectMake(0.0f, 0.0f, 125.0f, 125.0f);
		artworkImageView.hidden = YES;
		[self.contentView addSubview:artworkImageView];
		
		downloadProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		downloadProgressView.frame = CGRectMake(135.0f, 95.0f, 175.0f, 9.0f);
		downloadProgressView.progress = 0.0f;
		downloadProgressView.hidden = YES;
		[self.contentView addSubview:downloadProgressView];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:@"finishedLoadingSmallArtwork" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStateWhenTrackChanged:) name:@"TrackOfflineModeDownloadWillBegin" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStateWhenTrackChanged:) name:@"TrackOfflineModeDownloadDidBegin" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStateWhenTrackChanged:) name:@"TrackOfflineModeDownloadDidFinish" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStateWhenTrackChanged:) name:@"TrackOfflineModeDidClear" object:nil];
	}
	
	return self;
}

- (void)updateState:(NSNotification *)notification {
	if(notification && [notification object] != release)
		return;
	self.release = release;
}

- (void)updateStateWhenTrackChanged:(NSNotification *)notification {
	if(notification && [release hasTrack:[notification object]] == NO)
		return;
	self.release = release;
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

- (void)setRelease:(Release *)value {
	release = value;

	self.textLabel.text = self.release.title;
	self.detailTextLabel.text = self.release.artist;
	
	self.imageView.image = [UIImage imageNamed:@"cover-art-small.jpg"];
	if(release.smallArtworkImage) {
		artworkImageView.hidden = NO;
		artworkImageView.image = self.release.smallArtworkImage;
		[self.contentView bringSubviewToFront:artworkImageView];
		if(isWaitingForArtwork == YES) {
			artworkImageView.alpha = 0.0f;
			[UIView beginAnimations:@"ShowArtwork" context:nil];
			[UIView setAnimationDuration:0.2f];
			[UIView setAnimationBeginsFromCurrentState:NO];
			artworkImageView.alpha = 1.0f;
			[UIView commitAnimations];
			isWaitingForArtwork = NO;
		}
	} else {
		if(release.smallArtworkLoader) {
			isWaitingForArtwork = YES;
		}
		artworkImageView.hidden = YES;
	}
	
	if([release hasOfflineTracks] == YES) {
		self.textLabel.textColor = [Theme offlineTextColor];
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.textColor = [Theme offlineTextColor];
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
		bgView.backgroundColor = [Theme offlineBackgroundColor];
		bgView.gradientEnabled = YES;
	} else {
		self.textLabel.textColor = [Theme darkTextColor];
		self.detailTextLabel.textColor = [Theme darkTextColor];
		bgView.backgroundColor = [Theme backgroundColor];
		bgView.gradientEnabled = NO;
	}
	
	float downloadProgress = (float)[release numberOfOfflineTracks] / (float)[release numberOfTracks];
	if(downloadProgress < 1.0f && downloadProgress > 0.0f || [release hasLoadingTracks] == YES || [release hasTracksQueuedForDownload] == YES) {
		downloadProgressView.hidden = NO;
		downloadProgressView.progress = downloadProgress;
	} else {
		downloadProgressView.hidden = YES;
		downloadProgressView.progress = 0.0f;
	}
	
	[self setNeedsLayout];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[downloadProgressView release];
	[super dealloc];
}

@end
