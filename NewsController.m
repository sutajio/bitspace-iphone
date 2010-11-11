//
//  NewsController.h
//  bitspace-iphone
//
//  Created by Fredrik Lundqvist on 11/9/10.
//  Copyright 2010 Sutajio. All rights reserved.
//

#import "NewsController.h"
#import "NewsItemController.h"
#import "RSSParser.h"


@implementation NewsController

@synthesize appDelegate;
@synthesize navigationBar;
@synthesize newsItems;

#pragma mark -
#pragma mark Pull to refresh

- (void)sortNewsItems {
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[newsItems sortUsingDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
}

- (void)parseNewsFeedFinishedParsingItem:(NSDictionary *)item {
	for (NSMutableDictionary *existingItem in newsItems) {
		NSString *link1 = (NSString *)[item objectForKey:@"link"];
		NSString *link2 = (NSString *)[existingItem objectForKey:@"link"];
		if ([link1 isEqualToString:link2] == YES)
			return;
	}
	[newsItems insertObject:item atIndex:0];
	[self sortNewsItems];
	[self.tableView reloadData];
}

- (void)parseNewsFeedFinished {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self dataSourceDidFinishLoadingNewData];
	[newsItems writeToFile:[self saveFilePath] atomically:YES];
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastNewsSynchronizationDate"];
	self.refreshHeaderView.lastUpdatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastNewsSynchronizationDate"];
	[self.tableView reloadData];
}

- (void)parseNewsFeedFailed:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self dataSourceDidFinishLoadingNewData];
	if([error code] != NSXMLParserPrematureDocumentEndError) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No news for you today" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
}

- (void)parseNewsFeed {
	
	// Create a new autorelease pool for this thread
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Load saved news items for plist-file
	NSMutableArray *savedNewsList = [[NSMutableArray alloc] initWithContentsOfFile:[self saveFilePath]];
	if (savedNewsList) {
		for (NSMutableDictionary *item in savedNewsList) {
			[self performSelectorOnMainThread:@selector(parseNewsFeedFinishedParsingItem:) withObject:item waitUntilDone:YES];
		}
	}
	
	// Setup RSS parser
	NSString *newsUrl = (NSString *)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"NewsURL"];
	NSURL *url = [[NSURL alloc] initWithString:newsUrl];
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	RSSParser *rssParser = [[RSSParser alloc] init];
	[xmlParser setDelegate:rssParser];
	
	// Start parsing the feed
	if ([xmlParser parse] == NO) {
		// Failed parsing the feed
		NSError *error = [xmlParser parserError];
		[self performSelectorOnMainThread:@selector(parseNewsFeedFailed:) withObject:error waitUntilDone:YES];
		return;
	}
	
	// Loop through all the items from the RSS feed
	for (NSMutableDictionary *item in rssParser.items) {
		[self performSelectorOnMainThread:@selector(parseNewsFeedFinishedParsingItem:) withObject:item waitUntilDone:YES];
	}
	
	// Finished
	[self performSelectorOnMainThread:@selector(parseNewsFeedFinished) withObject:nil waitUntilDone:YES];
	
	// Release objects
	[url release];
	[xmlParser release];
	[rssParser release];
	[savedNewsList release];
	
	// Release the autorelease pool
	[pool release];
}

- (void)reloadTableViewDataSource {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
	
	self.newsItems = [[NSMutableArray alloc] init];
	
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
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return newsItems.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Reuse or create cell	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NewsCell"];
	}
	
	// Fill cell data
	NSDictionary *rowDataDict = [newsItems objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [rowDataDict objectForKey:@"title"];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	NSString *formattedPubDate = [dateFormatter stringFromDate:[rowDataDict objectForKey:@"pubDate"]];
	[dateFormatter release];
	
	cell.detailTextLabel.text = formattedPubDate;
	
	return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Get link from array
	NSMutableDictionary *dict = [newsItems objectAtIndex:indexPath.row];
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
	[newsItems release];
    [super dealloc];
}


@end

