//
//  ReleasesController.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-03-31.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "ReleasesController.h"
#import "ReleasesLoader.h"
#import "Release.h"
#import "ReleaseController.h"
#import "AppDelegate.h"
#import "ObjectiveResourceDateFormatter.h"
#import "ReleaseTableViewCell.h"


@implementation ReleasesController

@synthesize appDelegate;
@synthesize fetchedResultsController;
@synthesize searchBar, searchController;


#pragma mark -
#pragma mark Release support

- (void)refresh {
	if (loader == nil) {
		NSTimeInterval reloadInterval = (NSTimeInterval)[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"ReloadInterval"] doubleValue];
		NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastReleasesUpdate"];
		lastUpdate = lastUpdate ? lastUpdate : [NSDate distantPast];
		
		if([lastUpdate timeIntervalSinceNow] <= -reloadInterval) {
			loader = [[ReleasesLoader alloc] init];
			loader.delegate = self;
			loader.appDelegate = self.appDelegate;
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			[self.operationQueue addOperation:loader];
		}
	}
}

- (NSOperationQueue *)operationQueue {
    if (operationQueue == nil) {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return operationQueue;
}


#pragma mark -
#pragma mark Reset data store and view

- (void)resetDataStoreAndView {
	
	// Reset the view
	[self.navigationController popToRootViewControllerAnimated:NO];
	[self.searchController setActive:NO];
	[self.searchBar setText:@""];
	
	// Reset the data store
	for(Release *release in self.fetchedResultsController.fetchedObjects) {
		[self.appDelegate.managedObjectContext deleteObject:release];
	}
	
	NSError *error = nil;
	if(![self.appDelegate.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
	
	// Reset the last updated date
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LastReleasesUpdate"];
}


#pragma mark -
#pragma mark UIViewController overrides

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
	self.title = @"Releases";
	navigationBar.tintColor = [UIColor blackColor];
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,44)];
	searchBar.delegate = self;
	searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"All", @"Title", @"Artist", @"Label", nil];
	[self.tableView addSubview:searchBar];
	
	searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchController.delegate = self;
	searchController.searchResultsDataSource = self;
	searchController.searchResultsDelegate = self;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self refresh];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (void)configureCell:(ReleaseTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	// Set up the cell...
	cell.release = [fetchedResultsController objectAtIndexPath:indexPath];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    ReleaseTableViewCell *cell = (ReleaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ReleaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [fetchedResultsController sectionIndexTitles];
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}


- (void)showRelease:(NSNotification *)notification {
	Release *release = (Release *)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishedLoadingRelease" object:release];
	
	ReleaseController *releaseController = [[ReleaseController alloc] initWithNibName:@"Release" bundle:nil];
	releaseController.theRelease = release;
	releaseController.appDelegate = self.appDelegate;
	[self.navigationController pushViewController:releaseController animated:YES];
	[releaseController release];
	
	UITableView *tableView;
	if(searchController.active == YES) {
		tableView = searchController.searchResultsTableView;
	} else {
		tableView = self.tableView;
	}
	
	NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
	ReleaseTableViewCell *cell = (ReleaseTableViewCell *)[tableView cellForRowAtIndexPath: indexPath];
	[cell hideActivity];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ReleaseTableViewCell *cell = (ReleaseTableViewCell *)[tableView cellForRowAtIndexPath: indexPath];
	[cell showActivity];
	
	Release *release = (Release *)[fetchedResultsController objectAtIndexPath:indexPath];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRelease:) name:@"finishedLoadingRelease" object:release];
	[release loadTracksWithAppDelegate:self.appDelegate];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Release" inManagedObjectContext:self.appDelegate.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:@"Releases"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
        [aFetchedResultsController release];
        [fetchRequest release];
        [sortDescriptor release];
        [sortDescriptors release];
    }
	
	return fetchedResultsController;
}    


/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	if(searchController.active == YES) {
		[searchController.searchResultsTableView beginUpdates];
	} else {
		[self.tableView beginUpdates];
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	UITableView *tableView;
	
	if(searchController.active == YES) {
		tableView = searchController.searchResultsTableView;
	} else {
		tableView = self.tableView;
	}
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(ReleaseTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	UITableView *tableView;
	
	if(searchController.active == YES) {
		tableView = searchController.searchResultsTableView;
	} else {
		tableView = self.tableView;
	}
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	if(searchController.active == YES) {
		[searchController.searchResultsTableView endUpdates];
	} else {
		[self.tableView endUpdates];
	}
}


#pragma mark -
#pragma mark <UISearchDisplayDelegate> Implementation

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[fetchedResultsController.fetchRequest setPredicate:nil];
	
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString*)searchString searchScope:(NSInteger)searchOption {
	
	NSPredicate *predicate = nil;
	if ([searchString length]) {
		if (searchOption == 0) {
			predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@ OR artist contains[cd] %@ OR label contains[cd] %@", searchString, searchString, searchString];
		} else {
			predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", [[controller.searchBar.scopeButtonTitles objectAtIndex:searchOption] lowercaseString], searchString];
		}
	}
	[fetchedResultsController.fetchRequest setPredicate:predicate];
	
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }           
	
	return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	NSInteger searchOption = controller.searchBar.selectedScopeButtonIndex;
	return [self searchDisplayController:controller shouldReloadTableForSearchString:searchString searchScope:searchOption];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	NSString* searchString = controller.searchBar.text;
	return [self searchDisplayController:controller shouldReloadTableForSearchString:searchString searchScope:searchOption];
}


#pragma mark -
#pragma mark <ReleasesLoaderDelegate> Implementation


- (void)handleLoadCompletion {
    // Store the current time as the time of the last import. This will be used to determine whether an
    // import is necessary when the application runs.
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastReleasesUpdate"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	// Release the loader
	[loader release];
	loader = nil;
	
	// Run garbage collection on all releases and delete any release that wasn't
	// included in the last sync.
	for(Release *release in self.fetchedResultsController.fetchedObjects) {
		if([release wasTouched] == NO) {
			[self.appDelegate.managedObjectContext deleteObject:release];
		}
	}
	
	// Save the context once again, in case any releases was deleted
	NSError *error = nil;
	if(![self.appDelegate.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
}


- (void)loaderDidFinish:(ReleasesLoader *)loader {
    [self performSelectorOnMainThread:@selector(handleLoadCompletion) withObject:nil waitUntilDone:NO];
}


- (void)handlePageCompletion {
	NSError *error = nil;
	if(![self.appDelegate.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
}


- (void)loaderDidFinishLoadingPage:(ReleasesLoader *)loader {
    [self performSelectorOnMainThread:@selector(handlePageCompletion) withObject:nil waitUntilDone:YES];
}


- (void)addRelease:(NSDictionary*)release {
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", (NSString*)[release valueForKey:@"url"]];
	NSSet *filteredSet = [[self.appDelegate.managedObjectContext registeredObjects] filteredSetUsingPredicate:predicate];
	
	Release *newRelease;
	
	if([filteredSet count] == 0) {
		newRelease = [[NSEntityDescription insertNewObjectForEntityForName:@"Release" inManagedObjectContext:self.appDelegate.managedObjectContext] retain];
	} else {
		newRelease = [[filteredSet anyObject] retain];
	}
	
	newRelease.title = (NSString*)[release valueForKey:@"title"];
	newRelease.artist = (NSString*)[release valueForKey:@"artist"];
	newRelease.url = (NSString*)[release valueForKey:@"url"];
	newRelease.createdAt = [ObjectiveResourceDateFormatter parseDateTime:(NSString*)[release valueForKey:@"created_at"]];
	
	if([release valueForKey:@"year"] != [NSNull null]) {
		newRelease.year = [NSString stringWithFormat:@"%d", (NSDecimalNumber*)[release valueForKey:@"year"]];
	}
	
	if([release valueForKey:@"label"] != [NSNull null]) {
		newRelease.label = (NSString *)[release valueForKey:@"label"];
	}
	
	if([release valueForKey:@"release_date"] != [NSNull null]) {
		newRelease.releaseDate = (NSString *)[release valueForKey:@"release_date"];
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
	
	[newRelease touch];
}


- (void)loaderDidFinishParsingRelease:(NSDictionary *)releaseJSON {
	[self performSelectorOnMainThread:@selector(addRelease:) withObject:releaseJSON waitUntilDone:YES];
}


- (void)loader:(ReleasesLoader *)loader didFailWithError:(NSError *)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oopsie daisy!" message:[error localizedDescription]
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alert show];
	[alert release];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[fetchedResultsController release];
	[operationQueue release];
    [super dealloc];
}


@end

