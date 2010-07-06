//
//  Release.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "Release.h"
#import "Track.h"
#import "ReleaseLoader.h"
#import "ObjectiveResourceDateFormatter.h"


@implementation Release

@dynamic title;
@dynamic artist;
@dynamic year;
@dynamic url;
@dynamic createdAt;
@dynamic releaseDate;
@dynamic label;
@dynamic smallArtworkUrl;
@dynamic largeArtworkUrl;
@dynamic tracks;

@synthesize smallArtworkImage, largeArtworkImage;
@synthesize smallArtworkLoader, largeArtworkLoader;
@synthesize operationQueue, releaseLoader;

- (void)touch {
	touched = YES;
}

- (BOOL)wasTouched {
	return touched;
}

-(BOOL) hasTrackWithURL:(NSString *)url {
	for(Track *track in self.tracks) {
		if([track.url isEqualToString:url]) {
			return YES;
		}
	}
	return NO;
}

-(NSInteger) numberOfSets {
	NSInteger i = 1;
	for(Track *track in self.tracks) {
		if([track.setNr integerValue] > i) {
			i = [track.setNr integerValue];
		}
	}
	return i;
}

-(NSInteger) numberOfTracksInSet:(NSInteger)setNr {
	NSInteger i = 0;
	for(Track *track in self.tracks) {
		if([track.setNr integerValue] == setNr) {
			i++;
		}
	}
	return i;
}

+ (NSOperationQueue *)operationQueue {
	static NSOperationQueue *operationQueue;
    if (operationQueue == nil) {
        operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    }
    return operationQueue;
}

-(UIImage *)smallArtworkImage {
	if(smallArtworkImage == nil) {
		if(smallArtworkLoader == nil) {
			smallArtworkLoader = [[ArtworkLoader alloc] init];
			smallArtworkLoader.url = self.smallArtworkUrl;
			smallArtworkLoader.delegate = self;
			[[Release operationQueue] addOperation:smallArtworkLoader];
			[smallArtworkLoader release];
		}
	}
	return smallArtworkImage;
}

-(UIImage *)largeArtworkImage {
	if(largeArtworkImage == nil) {
		if(largeArtworkLoader == nil) {
			largeArtworkLoader = [[ArtworkLoader alloc] init];
			largeArtworkLoader.url = self.largeArtworkUrl;
			largeArtworkLoader.delegate = self;
			[[Release operationQueue] addOperation:largeArtworkLoader];
			[largeArtworkLoader release];
		}
	}
	return largeArtworkImage;
}

-(void)loaderDidFinishLoadingArtwork:(UIImage *)artworkImage fromURL:(NSString *)url {
	if([url isEqualToString:self.smallArtworkUrl]) {
		self.smallArtworkImage = artworkImage;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLoadingSmallArtwork" object:self];
	}
	if([url isEqualToString:self.largeArtworkUrl]) {
		self.largeArtworkImage = artworkImage;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLoadingLargeArtwork" object:self];
	}
}

-(void)updateRelease:(NSDictionary *)releaseJSON {
	NSArray *tracksArray = (NSArray *)[releaseJSON valueForKey:@"tracks"];
	NSInteger i = 1;
	for(NSDictionary *trackJSON in tracksArray) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", (NSString*)[trackJSON valueForKey:@"url"]];
		NSSet *filteredSet = [[self.managedObjectContext registeredObjects] filteredSetUsingPredicate:predicate];
		
		Track *track;
		
		if([filteredSet count] == 0) {
			track = [[NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:self.managedObjectContext] retain];
		} else {
			track = [[filteredSet anyObject] retain];
		}
			
		track.title = (NSString *)[trackJSON valueForKey:@"title"];
		track.url = (NSString *)[trackJSON valueForKey:@"url"];
		track.length = (NSNumber *)[trackJSON valueForKey:@"length"];
		track.nowPlayingUrl = (NSString *)[trackJSON valueForKey:@"now_playing_url"];
		track.scrobbleUrl = (NSString *)[trackJSON valueForKey:@"scrobble_url"];
		track.loveUrl = (NSString *)[trackJSON valueForKey:@"love_url"];
		if([trackJSON valueForKey:@"track_nr"] != [NSNull null]) {
			track.trackNr = (NSNumber *)[trackJSON valueForKey:@"track_nr"];
		} else {
			track.trackNr = [NSNumber numberWithInt:i];
		}
		if([trackJSON valueForKey:@"set_nr"] != [NSNull null]) {
			track.setNr = (NSNumber *)[trackJSON valueForKey:@"set_nr"];
		} else {
			track.setNr = [NSNumber numberWithInt:1];
		}
		if([trackJSON valueForKey:@"artist"] != [NSNull null]) {
			track.artist = (NSString *)[trackJSON valueForKey:@"artist"];
		}
		if([trackJSON valueForKey:@"loved_at"] != [NSNull null]) {
			track.lovedAt = [ObjectiveResourceDateFormatter parseDateTime:(NSString*)[trackJSON valueForKey:@"loved_at"]];
		}
		
		track.parent = self;
		track.touched = [NSNumber numberWithBool:YES];
		i++;
	}
	
	for(Track *track in self.tracks) {
		if(track.touched == [NSNumber numberWithBool:NO]) {
			[self.managedObjectContext deleteObject:track];
		}
	}
	
	NSError *error = nil;
	if(![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
}


- (void)loaderDidFinishParsingRelease:(NSDictionary *)releaseJSON {
	[self performSelectorOnMainThread:@selector(updateRelease:) withObject:releaseJSON waitUntilDone:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"finishedParsingRelease" object:self];
}

- (void)finishedLoading {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLoadingRelease" object:self];
}

- (void)loaderDidFinish:(ReleaseLoader *)loader {
	[self performSelectorOnMainThread:@selector(finishedLoading) withObject:nil waitUntilDone:NO];
}

- (void)showLoaderError:(NSError *)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oopsie daisy!" message:[error localizedDescription]
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alert show];
	[alert release];
}

- (void)loader:(ReleaseLoader *)loader didFailWithError:(NSError *)error {
	NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	if([self.tracks count] == 0) {
		[self performSelectorOnMainThread:@selector(showLoaderError:) withObject:error waitUntilDone:YES];
	}
	[self performSelectorOnMainThread:@selector(finishedLoading) withObject:nil waitUntilDone:NO];
}

- (NSOperationQueue *)operationQueue {
	if(operationQueue == nil) {
		operationQueue = [[NSOperationQueue alloc] init];
	}
	return operationQueue;
}

- (void)loadTracks:(BOOL)force {
	if(force == YES || [self.tracks count] == 0) {
		releaseLoader = [[ReleaseLoader alloc] init];
		releaseLoader.releaseURL = self.url;
		releaseLoader.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		releaseLoader.delegate = self;
		[self.operationQueue addOperation:releaseLoader];
		[releaseLoader release];
	} else {
		[self finishedLoading];
	}
}

-(void)dealloc {
	if(operationQueue) { [operationQueue release]; }
	if(smallArtworkImage) { [smallArtworkImage release]; }
	if(largeArtworkImage) { [largeArtworkImage release]; }
	[super dealloc];
}

@end
