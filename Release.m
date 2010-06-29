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
@dynamic mediumArtworkUrl;
@dynamic largeArtworkUrl;
@dynamic smallArtwork;
@dynamic mediumArtwork;
@dynamic largeArtwork;
@dynamic tracks;

@synthesize smallArtworkLoader, mediumArtworkLoader, largeArtworkLoader, releaseLoader;

-(NSString *)monthCreatedAt {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMM ''yy"];
	NSString *formatedDate = [dateFormatter stringFromDate:self.createdAt];
	[dateFormatter release];
	return formatedDate;
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

- (NSOperationQueue *)operationQueue {
    if (operationQueue == nil) {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return operationQueue;
}

-(UIImage *)smallArtworkImage {
	if(smallArtworkImage == nil) {
		if(self.smallArtwork == nil) {
			if(smallArtworkLoader == nil) {
				smallArtworkLoader = [[ArtworkLoader alloc] init];
				smallArtworkLoader.url = self.smallArtworkUrl;
				smallArtworkLoader.delegate = self;
				[self.operationQueue addOperation:smallArtworkLoader];
				[smallArtworkLoader release];
			}
		} else {
			smallArtworkImage = [[UIImage imageWithData:self.smallArtwork] retain];
		}
	}
	return smallArtworkImage;
}

-(UIImage *)mediumArtworkImage {
	if(mediumArtworkImage == nil) {
		if(self.mediumArtwork == nil) {
			if(mediumArtworkLoader == nil) {
				mediumArtworkLoader = [[ArtworkLoader alloc] init];
				mediumArtworkLoader.url = self.mediumArtworkUrl;
				mediumArtworkLoader.delegate = self;
				[self.operationQueue addOperation:mediumArtworkLoader];
				[mediumArtworkLoader release];
			}
		} else {
			mediumArtworkImage = [[UIImage imageWithData:self.mediumArtwork] retain];
		}
	}
	return mediumArtworkImage;
}

-(UIImage *)largeArtworkImage {
	if(largeArtworkImage == nil) {
		if(self.largeArtwork == nil) {
			if(largeArtworkLoader == nil) {
				largeArtworkLoader = [[ArtworkLoader alloc] init];
				largeArtworkLoader.url = self.largeArtworkUrl;
				largeArtworkLoader.delegate = self;
				[self.operationQueue addOperation:largeArtworkLoader];
				[largeArtworkLoader release];
			}
		} else {
			largeArtworkImage = [[UIImage imageWithData:self.largeArtwork] retain];
		}
	}
	return largeArtworkImage;
}

-(void)loaderDidFinishLoadingArtwork:(NSData *)artworkData fromURL:(NSString *)url {
	if([url isEqualToString:self.smallArtworkUrl]) {
		self.smallArtwork = artworkData;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLoadingSmallArtwork" object:self];
	}
	if([url isEqualToString:self.mediumArtworkUrl]) {
		self.mediumArtwork = artworkData;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLoadingMediumArtwork" object:self];
	}
	if([url isEqualToString:self.largeArtworkUrl]) {
		self.largeArtwork = artworkData;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLoadingLargeArtwork" object:self];
	}
}

- (void)loadTracksWithAppDelegate:(AppDelegate *)appDelegate {
	releaseLoader = [[ReleaseLoader alloc] init];
	releaseLoader.releaseURL = self.url;
	releaseLoader.appDelegate = appDelegate;
	releaseLoader.delegate = self;
	[self.operationQueue addOperation:releaseLoader];
	[releaseLoader release];
}

-(void)updateRelease:(NSDictionary *)releaseJSON {
	NSArray *tracksArray = (NSArray *)[releaseJSON valueForKey:@"tracks"];
	NSInteger i = 1;
	for(NSDictionary *trackJSON in tracksArray) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", (NSString*)[trackJSON valueForKey:@"url"]];
		NSSet *filteredSet = [[self.managedObjectContext registeredObjects] filteredSetUsingPredicate:predicate];
		
		if([filteredSet count] == 0) {
			Track *track = [NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:self.managedObjectContext];
			track.title = (NSString *)[trackJSON valueForKey:@"title"];
			track.url = (NSString *)[trackJSON valueForKey:@"url"];
			track.length = (NSNumber *)[trackJSON valueForKey:@"length"];
			track.nowPlayingUrl = (NSString *)[trackJSON valueForKey:@"now_playing_url"];
			track.scrobbleUrl = (NSString *)[trackJSON valueForKey:@"scrobble_url"];
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
		}
		i++;
	}
	
	if([releaseJSON valueForKey:@"release_date"] != [NSNull null]) {
		self.releaseDate = (NSString *)[releaseJSON valueForKey:@"release_date"];
	}
	
	if([releaseJSON valueForKey:@"label"] != [NSNull null]) {
		self.label = (NSString *)[releaseJSON valueForKey:@"label"];
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

- (void)loader:(ReleaseLoader *)loader didFailWithError:(NSError *)error {
	NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	[self performSelectorOnMainThread:@selector(finishedLoading) withObject:nil waitUntilDone:NO];
}

//-(void)dealloc {
//	if(operationQueue) { [operationQueue release]; }
//	if(smallArtworkImage) { [smallArtworkImage release]; }
//	if(mediumArtworkImage) { [mediumArtworkImage release]; }
//	if(largeArtworkImage) { [largeArtworkImage release]; }
//	[super dealloc];
//}

@end
