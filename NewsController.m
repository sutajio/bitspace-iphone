//
//  NewsController.h
//  bitspace-iphone
//
//  Created by Fredrik Lundqvist on 11/9/10.
//  Copyright 2010 Sutajio. All rights reserved.
//

#import "NewsController.h"
#import "NewsItemController.h"
#import "TrackTableViewCell.h"
#import "AppDelegate.h"
#import "PlayerController.h"
#import "Release.h"
#import "Track.h"


@implementation NewsController

@synthesize appDelegate;
@synthesize navigationBar;
@synthesize savedNewsList, newsList, newsItem;

#pragma mark -
#pragma mark Pull to refresh

- (void)parseNewsFeedFinished:(NSNumber*)success {
	if([success boolValue] == YES) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastNewsSynchronizationDate"];
		self.refreshHeaderView.lastUpdatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastNewsSynchronizationDate"];
		[self.tableView reloadData];
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Parse error" message:@"Parsing news feed failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
}

- (void)parseNewsFeed {
	
	// Clear the lists
	if (savedNewsList) [savedNewsList removeAllObjects];
	if (newsList) [newsList removeAllObjects];
	
	// Newsfeed
	NSURL *url = [[NSURL alloc] initWithString:@"http://srvc.se/category/news/feed"];
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	[xmlParser setDelegate:self];
	
	// Start parsing the feed
	BOOL success = [xmlParser parse];
	
	// Compare new arraylist with last entry in the saved news arraylist
	savedNewsList = [[NSMutableArray alloc] initWithContentsOfFile:[self saveFilePath]];
	if (savedNewsList == NULL) {
		savedNewsList = newsList;
	} else {
		// Compare date from new array with saved
		for (NSMutableDictionary *newDict in newsList) {
			BOOL not_found = NO;
			for (NSMutableDictionary *savedDict in savedNewsList) {
				NSString *link1 = (NSString *)[savedDict objectForKey:@"link"];
				NSString *link2 = (NSString *)[newDict objectForKey:@"link"];
				if ([link1 isEqualToString:link2] == YES) {
					not_found = NO;
					break;
				} else {
					not_found = YES;
				}
			}
			if(not_found == YES) {
				[savedNewsList insertObject:newDict atIndex:0];
			}
		}
	}
	
	// Save new array to plist
	[savedNewsList writeToFile:[self saveFilePath] atomically:YES];
	
	[self dataSourceDidFinishLoadingNewData];
	[self performSelectorOnMainThread:@selector(parseNewsFeedFinished:) withObject:[NSNumber numberWithBool:success] waitUntilDone:NO];
}

- (void)reloadTableViewDataSource {
	[self performSelectorInBackground:@selector(parseNewsFeed) withObject:nil];
}


#pragma mark -
#pragma mark Reset view

- (void)resetView {	
	// Reset the view
	[self.navigationController popToRootViewControllerAnimated:NO];
	
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
	
	self.navigationBar.tintColor = [UIColor blackColor];
	self.refreshHeaderView.lastUpdatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastNewsSynchronizationDate"];
	
	[self reloadTableViewDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
	
	self.refreshHeaderView.lastUpdatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastNewsSynchronizationDate"];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
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
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat: @"EEE, dd MMMM yyyy HH:mm:ss Z"];
	NSDate *pubDate = [dateFormat dateFromString: [rowDataDict objectForKey:@"pubDate"]];
	[dateFormat setDateStyle:NSDateFormatterMediumStyle];
	NSString *formattedPubDate = [dateFormat stringFromDate:pubDate];
	cell.detailTextLabel.text = formattedPubDate;
	return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Get link from array
	NSMutableDictionary *dict = [savedNewsList objectAtIndex:indexPath.row];
	NSString *title = [dict objectForKey:@"title"];
	NSString *link = [dict objectForKey:@"link"];
	// Set link and push news item
	NewsItemController *newsItemController = [[NewsItemController alloc] initWithNibName:@"NewsItem" bundle:nil];
	newsItemController.title = title;
	newsItemController.link = link;
	newsItemController.appDelegate = self.appDelegate;
	[self.navigationController pushViewController:newsItemController animated:YES];
	[newsItemController release];
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

