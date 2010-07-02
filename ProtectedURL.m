//
//  ProtectedURL.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-02.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "ProtectedURL.h"
#import "NSData+Additions.h"


@implementation ProtectedURL

+ (NSURL *)URLWithStringAndCredentials:(NSString *)URLString withUser:(NSString *)user andPassword:(NSString *)password {
	NSURL *url = [NSURL URLWithString:URLString];
	
	NSString *escapedUser = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)user, NULL, (CFStringRef)@"@.:", kCFStringEncodingUTF8);
	NSString *escapedPassword = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)password, NULL, (CFStringRef)@"@.:", kCFStringEncodingUTF8);
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@://%@:%@@%@",[url scheme],escapedUser,escapedPassword,[url host],nil];
	if([url port]) {
		[urlString appendFormat:@":%@",[url port],nil];
	}
	[urlString appendString:[url path]];
	if([url query]){
		[urlString appendFormat:@"?%@",[url query],nil];
	}
	[escapedUser release];
	[escapedPassword release];
	return [NSURL URLWithString:urlString];
}

+ (NSString *)authorizationHeaderWithUser:(NSString *)user andPassword:(NSString *)password {
	NSString *authString = [[[NSString stringWithFormat:@"%@:%@", user, password] dataUsingEncoding:NSUTF8StringEncoding] base64Encoding];
	return [NSString stringWithFormat:@"Basic %@", authString];
}

@end
