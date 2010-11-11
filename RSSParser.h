//
//  RSSParser.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-11-11.
//  Copyright 2010 Sutajio. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RSSParser : NSObject <NSXMLParserDelegate> {
	NSMutableArray *items;
	NSMutableDictionary *currentItem;
	NSMutableString *currentElementValue;
}

@property (nonatomic, retain) NSArray *items;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
