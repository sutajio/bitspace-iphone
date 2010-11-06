//
//  FavoritesController.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-08.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "NewsController.h"
#import "TrackTableViewCell.h"
#import "AppDelegate.h"
#import "PlayerController.h"
#import "Release.h"
#import "Track.h"
#import "Aluminium.h"


@implementation NewsController

@synthesize appDelegate;
@synthesize navigationBar;
@synthesize savedNewsList, newsList, newsItem;

#pragma mark -
#pragma mark Pull to refresh

- (void)parseNewsFeed {
	// Newsfeed
	NSURL *url = [[NSURL alloc] initWithString:@"http://srvc.se/feed"];
	//NSURL *url = [[NSURL alloc] initWithString:@"http://perhagman.se/testfeed.xml"];
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	[xmlParser setDelegate:self];
	
	// Start parsing the feed
	BOOL success = [xmlParser parse];
	
	// Compare new arraylist with last entry in the saved news arraylist
	//savedNewsList = [[NSMutableArray alloc] initWithCapacity:0];
	savedNewsList = [[NSMutableArray alloc] initWithContentsOfFile:[self saveFilePath]];
	
	//NSMutableArray *testArray = [[NSMutableArray alloc] init];
	NSMutableArray *testArray = [[NSMutableArray alloc] initWithContentsOfFile:[self saveFilePath]];
	
	//BOOL foundNewItems = NO;
		
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat: @"EEE, dd MMMM yyyy HH:mm:ss Z"];
		
	// Get lastest saved date
	NSDate *lastSavedDate = nil;
	if ([savedNewsList count] > 0) {
		lastSavedDate = [NSDate date];
		for (NSMutableDictionary* savedDict in savedNewsList) {
			lastSavedDate = [dateFormat dateFromString: [savedDict objectForKey:@"pubDate"]];
			break;
		}
	}
	
	// Compare date from new array with saved
	int i = 0;
	for (NSMutableDictionary *newDict in newsList) {
		//NSLog(@"%@", [newDict objectForKey:@"title"]);
		if (lastSavedDate == nil) {
			//NSLog(@"Add add add %@", [newDict objectForKey:@"title"]);
			[testArray addObject:newDict];
			NSLog(@"Antal: %d", [testArray count]);
		} else {
			NSDate *date = [dateFormat dateFromString: [newDict objectForKey:@"pubDate"]];
			NSTimeInterval difference = [date timeIntervalSinceDate: lastSavedDate];
			if (difference > 0.0f) {
				// Add new news item at index
				[savedNewsList insertObject:newDict atIndex:i];
				//foundNewItems = YES;
			} else {
				// End loop if same date or older
				break;
			}
		}
		i++;
	}
	
	NSLog(@"Antal i arrayen: %d", [savedNewsList count]);
	
	for (NSMutableDictionary *testDict in savedNewsList) {
		NSLog(@"%@", [testDict objectForKey:@"title"]);
	}
	
	/*if (foundNewItems) {
		// Save updated news list to file
		[savedNewsList writeToFile:[self saveFilePath] atomically:YES];
		NSLog(@"Updated file saved");
	}*/
	
	//[newsList writeToFile:[self saveFilePath] atomically:YES];
	[savedNewsList writeToFile:[self saveFilePath] atomically:YES];
	
	if(!success)
		NSLog(@"Error Error Error!!!");
	}

- (void)reloadTableViewDataSource {
	[self parseNewsFeed];
}


- (void)synchronizationDidFinish {
	[self dataSourceDidFinishLoadingNewData];
	self.refreshHeaderView.lastUpdatedDate = self.appDelegate.lastSynchronizationDate;
}


#pragma mark -
#pragma mark Reset view

- (void)resetView {	
	// Reset the last updated date
	self.refreshHeaderView.lastUpdatedDate = nil;
}

- (void)resetAppState {
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationBar.tintColor = [UIColor aluminiumColor];
	self.refreshHeaderView.lastUpdatedDate = self.appDelegate.lastSynchronizationDate;
	
	[self parseNewsFeed];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	self.refreshHeaderView.lastUpdatedDate = self.appDelegate.lastSynchronizationDate;
}


#pragma mark -
#pragma mark Plist save path

- (NSString *)saveFilePath {
	NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [[pathArray objectAtIndex:0] stringByAppendingPathComponent:@"news.plist"];
}


#pragma mark -
#pragma mark Xml parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"channel"]) {
		// Initialize the news array
		newsList = [[NSMutableArray alloc] init];
	}
	else if([elementName isEqualToString:@"item"]) {
		// Initialize the news hash
		newsItem = [[NSMutableDictionary alloc] init];
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
		[newsList addObject:newsItem];
	}
	else if ([elementName isEqualToString:@"title"] || [elementName isEqualToString:@"link"] || [elementName isEqualToString:@"pubDate"]) {
		NSString *elementValue = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[newsItem setObject:elementValue forKey:elementName];
	}
	
	[currentElementValue release];
	currentElementValue = nil;
}


#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return savedNewsList.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Reuse or create cell	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NewsCell"];
	}
	
	// Fill cell data
	NSDictionary *rowDataDict = [savedNewsList objectAtIndex:indexPath.row];
	cell.textLabel.text = [rowDataDict objectForKey:@"title"];
	cell.detailTextLabel.text = [rowDataDict objectForKey:@"pubDate"];
	return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//TODO: Get link and push new view
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
    [super dealloc];
}


@end

