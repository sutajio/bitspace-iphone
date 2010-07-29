//
//  ReleasesLoader.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "ReleasesLoader.h"
#import "Connection.h"
#import "Response.h"
#import "Release.h"
#import "Artist.h"
#import "Track.h"
#import "AppDelegate.h"
#import "ObjectiveResourceDateFormatter.h"
#import "NSString+SBJSON.h"


@implementation ReleasesLoader

@synthesize delegate;
@synthesize insertionContext, persistentStoreCoordinator, releaseEntityDescription;
@synthesize didFail, lastUpdateDate;

- (void)dealloc {
	[insertionContext release];
	[persistentStoreCoordinator release];
	[artistEntityDescription release];
	[releaseEntityDescription release];
	[trackEntityDescription release];
	[super dealloc];
}

- (NSPredicate *)predicateForURL:(NSString *)url {
	return [NSPredicate predicateWithFormat:@"url == %@", url];
}

- (NSArray *)filteredReleasesArrayUsingPredicate:(NSPredicate *)predicate {
	if(cachedReleases == nil) {
		NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
		[fetchRequest setEntity:self.releaseEntityDescription];
		cachedReleases = [self.insertionContext executeFetchRequest:fetchRequest error:nil];
	}
	return [cachedReleases filteredArrayUsingPredicate:predicate];
}

- (Release *)findOrCreateReleaseWithURL:(NSString *)url {
	NSPredicate *predicate = [self predicateForURL:url];
	NSArray *filteredArray = [self filteredReleasesArrayUsingPredicate:predicate];
	
	if([filteredArray count] == 0) {
		return [NSEntityDescription insertNewObjectForEntityForName:@"Release" inManagedObjectContext:self.insertionContext];
	} else {
		return [filteredArray objectAtIndex:0];
	}

}

- (Artist *)findOrCreateArtistWithName:(NSString *)artistName andSortName:(NSString *)sortName {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", artistName];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Artist" inManagedObjectContext:self.insertionContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	NSArray *filteredArray = [self.insertionContext executeFetchRequest:fetchRequest error:nil];
	
	if([filteredArray count] == 0) {
		Artist *artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:self.insertionContext];
		artist.name = artistName;
		artist.sortName = (NSNull *)sortName == [NSNull null] ? artistName : sortName;
		artist.sectionName = [artist.sortName substringToIndex:1];
		return artist;
	} else {
		return [filteredArray objectAtIndex:0];
	}
}

- (NSArray *)filteredTracksArrayUsingPredicate:(NSPredicate *)predicate {
	if(cachedTracks == nil) {
		NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
		[fetchRequest setEntity:self.trackEntityDescription];
		cachedTracks = [self.insertionContext executeFetchRequest:fetchRequest error:nil];
	}
	return [cachedTracks filteredArrayUsingPredicate:predicate];
}

- (Track *)findOrCreateTrackWithURL:(NSString *)url {
	NSPredicate *predicate = [self predicateForURL:url];
	NSArray *filteredArray = [self filteredTracksArrayUsingPredicate:predicate];
	
	if([filteredArray count] == 0) {
		return [NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:self.insertionContext];
	} else {
		return [filteredArray objectAtIndex:0];
	}
}

- (Track *)addTrack:(NSDictionary*)trackJSON {
	
	Track *track = [self findOrCreateTrackWithURL:(NSString*)[trackJSON valueForKey:@"url"]];
	
	track.title = (NSString *)[trackJSON valueForKey:@"title"];
	track.url = (NSString *)[trackJSON valueForKey:@"url"];
	track.length = (NSNumber *)[trackJSON valueForKey:@"length"];
	track.nowPlayingUrl = (NSString *)[trackJSON valueForKey:@"now_playing_url"];
	track.scrobbleUrl = (NSString *)[trackJSON valueForKey:@"scrobble_url"];
	track.loveUrl = (NSString *)[trackJSON valueForKey:@"love_url"];
	if([trackJSON valueForKey:@"track_nr"] != [NSNull null]) {
		track.trackNr = (NSNumber *)[trackJSON valueForKey:@"track_nr"];
	} else {
		track.trackNr = [NSNumber numberWithInt:0];
	}
	if([trackJSON valueForKey:@"set_nr"] != [NSNull null]) {
		track.setNr = (NSNumber *)[trackJSON valueForKey:@"set_nr"];
	} else {
		track.setNr = [NSNumber numberWithInt:1];
	}
	if([trackJSON valueForKey:@"artist"] != [NSNull null]) {
		track.artist = (NSString *)[trackJSON valueForKey:@"artist"];
	} else {
		track.artist = nil;
	}
	if([trackJSON valueForKey:@"loved_at"] != [NSNull null]) {
		track.lovedAt = [ObjectiveResourceDateFormatter parseDateTime:(NSString*)[trackJSON valueForKey:@"loved_at"]];
	} else {
		track.lovedAt = nil;
	}
	
	[track touch];
	
	return track;
}

- (Release *)addRelease:(NSDictionary*)releaseJSON {
	
	Release *release = [self findOrCreateReleaseWithURL:(NSString*)[releaseJSON valueForKey:@"url"]];

	release.parent = [self findOrCreateArtistWithName:(NSString*)[releaseJSON valueForKey:@"artist"] andSortName:(NSString*)[releaseJSON valueForKey:@"artist_sort_name"]];
	release.title = (NSString*)[releaseJSON valueForKey:@"title"];
	release.artist = (NSString*)[releaseJSON valueForKey:@"artist"];
	release.url = (NSString*)[releaseJSON valueForKey:@"url"];
	release.createdAt = (NSString*)[releaseJSON valueForKey:@"created_at"];
	release.updatedAt = (NSString*)[releaseJSON valueForKey:@"updated_at"];
	release.archived = (NSNumber*)[releaseJSON valueForKey:@"archived"];
	release.parent.archived = release.archived;
	
	if([releaseJSON valueForKey:@"year"] != [NSNull null]) {
		release.year = (NSDecimalNumber*)[releaseJSON valueForKey:@"year"];
	} else {
		release.year = nil;
	}
	
	if([releaseJSON valueForKey:@"label"] != [NSNull null]) {
		release.label = (NSString *)[releaseJSON valueForKey:@"label"];
	} else {
		release.label = nil;
	}
	
	if([releaseJSON valueForKey:@"release_date"] != [NSNull null]) {
		release.releaseDate = (NSString *)[releaseJSON valueForKey:@"release_date"];
	} else {
		release.releaseDate = nil;
	}
	
	if([releaseJSON valueForKey:@"small_artwork_url"] != [NSNull null]) {
		release.smallArtworkUrl = (NSString*)[releaseJSON valueForKey:@"small_artwork_url"];
	} else {
		release.smallArtworkUrl = nil;
	}
	
	if([releaseJSON valueForKey:@"large_artwork_url"] != [NSNull null]) {
		release.largeArtworkUrl = (NSString*)[releaseJSON valueForKey:@"large_artwork_url"];
	} else {
		release.largeArtworkUrl = nil;
	}
	
	NSArray *tracks = (NSArray *)[releaseJSON valueForKey:@"tracks"];
	if(tracks) {
		for(NSObject *t in tracks) {
			Track *track = [self addTrack:(NSDictionary *)t];
			track.parent = release;
		}
	}
	
	for(Track *track in release.tracks) {
		if([track wasTouched] == NO) {
			[self.insertionContext deleteObject:track];
		}
	}
	
	return release;
}

//- (NSString *)lastUpdateDate {
//	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
//	[fetchRequest setEntity:self.releaseEntityDescription];
//	[fetchRequest setFetchLimit:1];
//	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO selector:@selector(compare:)] autorelease];
//	NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
//	[fetchRequest setSortDescriptors:sortDescriptors];
//	NSArray *result = [self.insertionContext executeFetchRequest:fetchRequest error:nil];
//	if([result count] > 0) {
//		Release *release = [result objectAtIndex:0];
//		return [release.updatedAt copy];
//	} else {
//		return @"";
//	}
//}

- (void)main {
	NSLog(@"ReleasesLoader#main");
	
	// Reset fail state
	didFail = NO;
	
	// Create a new autorelease pool for this thread
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Tell the delegate object to observe changes in the managed object context
	if (delegate && [delegate respondsToSelector:@selector(loaderDidSave:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:delegate 
												 selector:@selector(loaderDidSave:) 
													 name:NSManagedObjectContextDidSaveNotification 
												   object:self.insertionContext];
    }
	
	// Tell the delegate that we have started loading
	[delegate loaderDidStart:self];
	
	int page = 1;
	[ObjectiveResourceDateFormatter setSerializeFormat:DateTime];
	NSString *since = self.lastUpdateDate ? [ObjectiveResourceDateFormatter formatDate:self.lastUpdateDate] : @"";
	
	do {
		// Request a page from the server...
		NSLog(@"Requesting page #%d", page);
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@releases?page=%d&since=%@", appDelegate.siteURL, page, since]];
		NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url
																cachePolicy:NSURLRequestReloadIgnoringCacheData
															timeoutInterval:[Connection timeout]];
		[request setHTTPMethod:@"GET"];
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
		Response *res = [Connection sendRequest:request withUser:appDelegate.username andPassword:appDelegate.password];
		if([res isError]) {
			NSLog(@"%@", [res.error localizedDescription]);
			didFail = YES;
			[delegate loader:self didFailWithError:res.error];
			break;
		}
		
		// Parse the returned response
		NSString *responseString = [[NSString alloc] initWithData:res.body encoding:NSUTF8StringEncoding];
		NSArray *releases = [responseString JSONValue];
		if ([releases count] == 0) {
			break;
		} else {
			for(NSObject *release in releases) {
				[self addRelease:(NSDictionary *)release];
				[delegate loaderDidFinishParsingRelease:self];
			}
			NSError *error = nil;
			[self.insertionContext save:&error];
			if(error) {
				NSLog(@"%@", [error userInfo]);
			}
			[delegate loaderDidFinishLoadingPage:self];
			if([self isCancelled] == YES)
				break;
		}
		
		page++;
	} while(true);
	
	// Tell the delegate that we have finished loading
	[delegate loaderDidFinish:self];
	
	// Tell the delegate to not listen for changes in the managed object context any more
	if (delegate && [delegate respondsToSelector:@selector(loaderDidSave:)]) {
        [[NSNotificationCenter defaultCenter] removeObserver:delegate 
														name:NSManagedObjectContextDidSaveNotification 
													  object:self.insertionContext];
    }
	
	// Release the autorelease pool
	[pool release];
}

- (NSManagedObjectContext *)insertionContext {
    if (insertionContext == nil) {
        insertionContext = [[NSManagedObjectContext alloc] init];
        [insertionContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return insertionContext;
}

- (NSEntityDescription *)artistEntityDescription {
    if (artistEntityDescription == nil) {
        artistEntityDescription = [[NSEntityDescription entityForName:@"Artist" inManagedObjectContext:self.insertionContext] retain];
    }
    return artistEntityDescription;
}

- (NSEntityDescription *)releaseEntityDescription {
    if (releaseEntityDescription == nil) {
        releaseEntityDescription = [[NSEntityDescription entityForName:@"Release" inManagedObjectContext:self.insertionContext] retain];
    }
    return releaseEntityDescription;
}

- (NSEntityDescription *)trackEntityDescription {
    if (trackEntityDescription == nil) {
        trackEntityDescription = [[NSEntityDescription entityForName:@"Track" inManagedObjectContext:self.insertionContext] retain];
    }
    return trackEntityDescription;
}

@end
