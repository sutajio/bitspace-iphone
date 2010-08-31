//
//  ArtistController.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-15.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "ArtistController.h"
#import "AppDelegate.h"
#import "Artist.h"
#import "Release.h"
#import "Track.h"
#import "ReleaseTableViewCell.h"
#import "ReleaseController.h"
#import "BiographyController.h"
#import "PlayerController.h"


@implementation ArtistController

@synthesize appDelegate, theArtist, fetchedResultsController;


#pragma mark -
#pragma mark Biography

- (void)showBiography {
	BiographyController *biographyController = [[BiographyController alloc] initWithNibName:@"Biography" bundle:nil];
	biographyController.theArtist = self.theArtist;
	[self.navigationController pushViewController:biographyController animated:YES];
	[biographyController release];
}


#pragma mark -
#pragma mark All tracks

- (NSMutableArray *)allTracks {
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"trackNr" ascending:YES selector:@selector(compare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:0];
	for(Release *release in [fetchedResultsController fetchedObjects]) {
		NSArray *sortedTracks = [release.tracks sortedArrayUsingDescriptors:sortDescriptors];
		for(Track *track in sortedTracks) {
			[tracks addObject:track];
		}
	}
	[sortDescriptors release];
	[sortDescriptor release];
	return tracks;
}


- (NSMutableArray *)shuffleArray:(NSArray *)array {
	NSMutableArray *shuffledArray = [NSMutableArray arrayWithCapacity:[array count]];
	[shuffledArray addObjectsFromArray:array];
	if ([shuffledArray count] > 1) {
		for (NSUInteger shuffleIndex = [shuffledArray count] - 1; shuffleIndex > 0; shuffleIndex--)
			[shuffledArray exchangeObjectAtIndex:shuffleIndex withObjectAtIndex:arc4random() % (shuffleIndex + 1)];
	}
	return shuffledArray;
}


- (void)playAllTracks:(id)sender {
	NSArray *tracks = [self allTracks];
	if([tracks count] > 0) {
		[self.appDelegate.playerController enqueueTracks:tracks];
		[self.appDelegate.playerController nextTrack:nil];
		[self.appDelegate showPlayer];
	}
}


- (void)shuffleAllTracks:(id)sender {
	NSArray *tracks = [self shuffleArray:[self allTracks]];
	if([tracks count] > 0) {
		[self.appDelegate.playerController enqueueTracks:tracks];
		[self.appDelegate.playerController nextTrack:nil];
		[self.appDelegate showPlayer];
	}
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	if(tableHeaderView == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"ArtistHeaderView" owner:self options:nil];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	self.tableView.tableHeaderView = tableHeaderView;
	
	self.navigationItem.title = theArtist.name;
	if(theArtist.biographyUrl || theArtist.largeArtworkUrl) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Biography" style:UIBarButtonItemStylePlain target:self action:@selector(showBiography)];
	}
	
	[[self fetchedResultsController] performFetch:nil];
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
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


#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 125;
}


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
	}
    
	// Set up the cell...
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
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
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Release *release = (Release *)[fetchedResultsController objectAtIndexPath:indexPath];
	
	ReleaseController *releaseController = [[ReleaseController alloc] initWithNibName:@"Release" bundle:nil];
	releaseController.theRelease = release;
	releaseController.appDelegate = self.appDelegate;
	[self.navigationController pushViewController:releaseController animated:YES];
	[releaseController release];
}


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
        
        // Edit the sort keys as appropriate.
		NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:NO selector:@selector(compare:)];
		NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"releaseDate" ascending:NO selector:@selector(compare:)];
		NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO selector:@selector(compare:)];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, sortDescriptor3, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
		
		// Edit the filter predicate as appropriate.
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"artist == %@ AND archived == NO", theArtist.name];
		[fetchRequest setPredicate:predicate];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
        [aFetchedResultsController release];
        [fetchRequest release];
        [sortDescriptor1 release];
		[sortDescriptor2 release];
		[sortDescriptor3 release];
        [sortDescriptors release];
    }
	
	return fetchedResultsController;
}    


/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *tableView = self.tableView;
	
	ReleaseTableViewCell *cell;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			cell = (ReleaseTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
			[self configureCell:cell atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	self.navigationItem.rightBarButtonItem = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

