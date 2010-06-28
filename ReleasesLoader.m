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
				[delegate loaderDidFinishParsingRelease:(NSDictionary *)release];
			}
			[delegate loaderDidFinishLoadingPage:self];
		}
		
		page++;
	} while(true);
	[delegate loaderDidFinish:self];
}

@end
