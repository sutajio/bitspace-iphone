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
#import "AppDelegate.h"
#import "ObjectiveResourceDateFormatter.h"
#import "NSString+SBJSON.h"


@implementation ReleasesLoader

@synthesize delegate;
@synthesize insertionContext, persistentStoreCoordinator, releaseEntityDescription;

- (void)dealloc {
	[insertionContext release];
	[persistentStoreCoordinator release];
	[releaseEntityDescription release];
	[super dealloc];
}

- (NSPredicate *)predicateForURL:(NSString *)url {
	return [NSPredicate predicateWithFormat:@"url == %@", url];
}

- (NSArray *)filteredArrayUsingPredicate:(NSPredicate *)predicate {
	if(cachedObjects == nil) {
		NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Release" inManagedObjectContext:self.insertionContext];
		[fetchRequest setEntity:entity];
		cachedObjects = [self.insertionContext executeFetchRequest:fetchRequest error:nil];
	}
	return [cachedObjects filteredArrayUsingPredicate:predicate];
}

- (Release *)findOrCreateReleaseWithURL:(NSString *)url {
	NSPredicate *predicate = [self predicateForURL:url];
	NSArray *filteredArray = [self filteredArrayUsingPredicate:predicate];
	
	if([filteredArray count] == 0) {
		return [NSEntityDescription insertNewObjectForEntityForName:@"Release" inManagedObjectContext:self.insertionContext];
	} else {
		return [filteredArray objectAtIndex:0];
	}
}

- (void)addRelease:(NSDictionary*)releaseJSON {
	
	Release *release = [self findOrCreateReleaseWithURL:(NSString*)[releaseJSON valueForKey:@"url"]];
	
	release.title = (NSString*)[releaseJSON valueForKey:@"title"];
	release.artist = (NSString*)[releaseJSON valueForKey:@"artist"];
	release.url = (NSString*)[releaseJSON valueForKey:@"url"];
	release.createdAt = (NSString*)[releaseJSON valueForKey:@"created_at"];
	
	if([releaseJSON valueForKey:@"year"] != [NSNull null]) {
		release.year = [NSString stringWithFormat:@"%d", (NSDecimalNumber*)[releaseJSON valueForKey:@"year"]];
	}
	
	if([releaseJSON valueForKey:@"label"] != [NSNull null]) {
		release.label = (NSString *)[releaseJSON valueForKey:@"label"];
	}
	
	if([releaseJSON valueForKey:@"release_date"] != [NSNull null]) {
		release.releaseDate = (NSString *)[releaseJSON valueForKey:@"release_date"];
	}
	
	if([releaseJSON valueForKey:@"small_artwork_url"] != [NSNull null]) {
		release.smallArtworkUrl = (NSString*)[releaseJSON valueForKey:@"small_artwork_url"];
	}
	
	if([releaseJSON valueForKey:@"large_artwork_url"] != [NSNull null]) {
		release.largeArtworkUrl = (NSString*)[releaseJSON valueForKey:@"large_artwork_url"];
	}
	
	[release touch];
}

- (void)main {
	NSLog(@"ReleasesLoader#main");
	
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
	
	do {
		// Request a page from the server...
		NSLog(@"Requesting page #%d", page);
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@releases?page=%d", appDelegate.siteURL, page]];
		NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url
																cachePolicy:NSURLRequestReloadIgnoringCacheData
															timeoutInterval:[Connection timeout]];
		[request setHTTPMethod:@"GET"];
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
		Response *res = [Connection sendRequest:request withUser:appDelegate.username andPassword:appDelegate.password];
		if([res isError]) {
			NSLog(@"%@", [res.error localizedDescription]);
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
			[self.insertionContext save:nil];
			[delegate loaderDidFinishLoadingPage:self];
			if([self isCancelled] == YES)
				break;
		}
		
		page++;
	} while(true);
	
	if([self isCancelled] == NO) {
		// Run garbage collection on all releases and delete any release that wasn't
		// included in the last sync.
		for(Release *release in [self.insertionContext registeredObjects]) {
			if([release wasTouched] == NO) {
				[self.insertionContext deleteObject:release];
			}
		}

		// Save the context once again, in case any releases was deleted
		[self.insertionContext save:nil];
	}
	
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

- (NSEntityDescription *)releaseEntityDescription {
    if (releaseEntityDescription == nil) {
        releaseEntityDescription = [[NSEntityDescription entityForName:@"Release" inManagedObjectContext:self.insertionContext] retain];
    }
    return releaseEntityDescription;
}

@end
