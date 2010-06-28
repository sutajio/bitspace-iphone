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

@synthesize delegate, appDelegate, releaseURL;

-(void)main {
	NSLog(@"ReleaseLoader#main");
	
	NSURL *url = [NSURL URLWithString:self.releaseURL];
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
		return;
	}
	
	// Parse the returned response
	NSString *responseString = [[NSString alloc] initWithData:res.body encoding:NSUTF8StringEncoding];
	NSDictionary *releaseJSON = [responseString JSONValue];
	[delegate loaderDidFinish:releaseJSON];
}

@end
