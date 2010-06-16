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


@implementation ReleasesLoader

@synthesize siteURL, username, password;
@synthesize delegate, managedObjectContext;

- (void)addRelease:(NSObject*)release {
	Release *newRelease = [NSEntityDescription insertNewObjectForEntityForName:@"Release" inManagedObjectContext:self.managedObjectContext];
	newRelease.title = (NSString*)[release valueForKey:@"title"];
	newRelease.artist = (NSString*)[release valueForKey:@"artist"];
	newRelease.url = (NSString*)[release valueForKey:@"url"];
	newRelease.createdAt = [NSDate dateWithNaturalLanguageString:(NSString*)[release valueForKey:@"created_at"]];
	
	if([release valueForKey:@"year"] != [NSNull null]) {
		newRelease.year = [NSString stringWithFormat:@"%d", (NSDecimalNumber*)[release valueForKey:@"year"]];
	}
	
	if([release valueForKey:@"small_artwork_url"] != [NSNull null]) {
		newRelease.smallArtworkUrl = (NSString*)[release valueForKey:@"small_artwork_url"];
	}
	
	if([release valueForKey:@"medium_artwork_url"] != [NSNull null]) {
		newRelease.mediumArtworkUrl = (NSString*)[release valueForKey:@"medium_artwork_url"];
	}
	
	if([release valueForKey:@"large_artwork_url"] != [NSNull null]) {
		newRelease.largeArtworkUrl = (NSString*)[release valueForKey:@"large_artwork_url"];
	}
}

- (void)main {
	NSLog(@"ReleasesLoader#main");
	
	int page = 1;
	
	do {
		// Request a page from the server...
		NSLog([NSString stringWithFormat:@"Requesting page #%d", page]);
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@releases?page=%d", self.siteURL, page]];
		NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url
																cachePolicy:NSURLRequestReloadIgnoringCacheData
															timeoutInterval:[Connection timeout]];
		[request setHTTPMethod:@"GET"];
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];	
		[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
		Response *res = [Connection sendRequest:request withUser:self.username andPassword:self.password];
		if([res isError]) {
			NSLog([res.error localizedDescription]);
			break;
		}
		
		// Parse the returned response
		NSString *responseString = [[NSString alloc] initWithData:res.body encoding:NSUTF8StringEncoding];
		NSArray *releases = [responseString JSONValue];
		if ([releases count] == 0) {
			break;
		} else {
			for(NSObject *release in releases) {
				[self addRelease:release];
			}
			[delegate loaderDidFinishLoadingPage:self];
		}
		
		page++;
	} while(true);
	[delegate loaderDidFinish:self];
}

@end
