//
//  ReleaseTableViewCell.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-28.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "ReleaseTableViewCell.h"
#import "Release.h"


@implementation ReleaseTableViewCell

@synthesize release;

- (void)setRelease:(Release *)value {
	release = value;
	self.textLabel.text = self.release.title;
	self.detailTextLabel.text = self.release.artist;
	if(self.release.smallArtworkImage == nil) {
		self.imageView.image = [UIImage imageNamed:@"cover-art-small.jpg"];
	} else {
		self.imageView.image = self.release.smallArtworkImage;
	}
}

- (void)showActivity {
	UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[activityView startAnimating];
	self.accessoryView = activityView;
	[activityView release];
}

- (void)hideActivity {
	self.accessoryView = nil;
}

@end
