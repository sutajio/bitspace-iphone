//
//  RSSParser.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-11-11.
//  Copyright 2010 Sutajio. All rights reserved.
//

#import "RSSParser.h"


@implementation RSSParser

@synthesize items;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"channel"]) {
		// Initialize the news array
		items = [[NSMutableArray alloc] init];
	}
	else if([elementName isEqualToString:@"item"]) {
		// Initialize the news hash
		currentItem = [[NSMutableDictionary alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if(!currentElementValue)
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	else
		[currentElementValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if([elementName isEqualToString:@"channel"])
		return;
	
	if([elementName isEqualToString:@"item"]) {
		[items addObject:currentItem];
	}
	else if ([elementName isEqualToString:@"title"] || [elementName isEqualToString:@"link"]) {
		NSString *elementValue = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[currentItem setObject:elementValue forKey:elementName];
	}
	else if ([elementName isEqualToString:@"pubDate"]) {
		NSString *elementValue = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[dateFormatter setLocale:enUS];
		[enUS release];
		[dateFormatter setDateFormat: @"EEE, dd MMM yyyy HH:mm:ss Z"];
		NSDate *pubDate = [dateFormatter dateFromString:elementValue];
		[dateFormatter release];
		[currentItem setObject:pubDate forKey:elementName];
	}
	
	[currentElementValue release];
	currentElementValue = nil;
}

@end
