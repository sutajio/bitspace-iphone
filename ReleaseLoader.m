//
//  ReleaseLoader.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-17.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "ReleaseLoader.h"
#import "Connection.h"
#import "Response.h"
#import "Release.h"
#import "Track.h"
#import "AppDelegate.h"


@implementation ReleaseLoader

@synthesize appDelegate, release;

-(void)updateRelease:(NSDictionary *)releaseJSON {
	NSArray *tracks = (NSArray *)[releaseJSON valueForKey:@"tracks"];
	for(NSDictionary *trackJSON in tracks) {
		if([release hasTrackWithURL:(NSString *)[trackJSON valueForKey:@"url"]] == NO) {
			Track *track = [NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:release.managedObjectContext];
			track.title = (NSString *)[trackJSON valueForKey:@"title"];
			track.url = (NSString *)[trackJSON valueForKey:@"url"];
			track.length = (NSNumber *)[trackJSON valueForKey:@"length"];
			track.nowPlayingUrl = (NSString *)[trackJSON valueForKey:@"now_playing_url"];
			track.scrobbleUrl = (NSString *)[trackJSON valueForKey:@"scrobble_url"];
			if([trackJSON valueForKey:@"track_nr"] != [NSNull null]) {
				track.trackNr = (NSNumber *)[trackJSON valueForKey:@"track_nr"];
			}
			if([trackJSON valueForKey:@"set_nr"] != [NSNull null]) {
				track.setNr = (NSNumber *)[trackJSON valueForKey:@"set_nr"];
			}
			if([trackJSON valueForKey:@"artist"] != [NSNull null]) {
				track.artist = (NSString *)[trackJSON valueForKey:@"artist"];
			}
			release.tracks = [release.tracks setByAddingObject:track];
		}
	}
}

-(void)main {
	NSLog(@"ReleaseLoader#main");
	
	NSURL *url = [NSURL URLWithString:release.url];
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url
															cachePolicy:NSURLRequestReloadIgnoringCacheData
														timeoutInterval:[Connection timeout]];
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];	
	[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
	Response *res = [Connection sendRequest:request withUser:self.appDelegate.username andPassword:self.appDelegate.password];
	if([res isError]) {
		NSLog([res.error localizedDescription]);
		return;
	}
	
	// Parse the returned response
	NSString *responseString = [[NSString alloc] initWithData:res.body encoding:NSUTF8StringEncoding];
	NSDictionary *releaseJSON = [responseString JSONValue];
	[self updateRelease:releaseJSON];
}

@end
