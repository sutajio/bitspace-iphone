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


@implementation ReleasesLoader

@synthesize delegate, appDelegate;

- (void)addRelease:(NSDictionary*)release {
	Release *newRelease = [NSEntityDescription insertNewObjectForEntityForName:@"Release" inManagedObjectContext:self.appDelegate.managedObjectContext];
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
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@releases?page=%d", self.appDelegate.siteURL, page]];
		NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url
																cachePolicy:NSURLRequestReloadIgnoringCacheData
															timeoutInterval:[Connection timeout]];
		[request setHTTPMethod:@"GET"];
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];	
		[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
		Response *res = [Connection sendRequest:request withUser:self.appDelegate.username andPassword:self.appDelegate.password];
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
