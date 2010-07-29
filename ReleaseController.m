//
//  ReleaseController.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "ReleaseController.h"
#import "Release.h"
#import "Track.h"
#import "AppDelegate.h"
#import "PlayerController.h"
#import "TrackTableViewCell.h"


@implementation ReleaseController

@synthesize appDelegate;
@synthesize theRelease, fetchedResultsController;
@synthesize tableHeaderView, artworkImage, titleLabel, artistLabel;
@synthesize tableFooterView, releasedAtLabel, releasedByLabel;


#pragma mark Offline

- (void)enableOfflineMode {
	for(Track *track in [fetchedResultsController fetchedObjects]) {
		[(Track *)track enableOfflineMode];
	}
}

- (void)clearDownloadedTracks {
	for(Track *track in [fetchedResultsController fetchedObjects]) {
		[(Track *)track clearCache];
	}
}

- (void)offline:(id)sender {
	if([theRelease hasOnlineTracks] && [theRelease hasOfflineTracks]) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear downloaded tracks" otherButtonTitles:@"Enable offline mode", nil];
		[actionSheet showInView:sender];
		[actionSheet release];
	} else if([theRelease hasOnlineTracks]) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Enabling offline mode will download all the tracks on this release so that you can listen to them without an internet connection. We strongly recommend that you use a Wi-Fi connection when enabling offline mode." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Enable offline mode", nil];
		[actionSheet showInView:sender];
		[actionSheet release];
	} else if([theRelease hasOfflineTracks]) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear downloaded tracks" otherButtonTitles:nil, nil];
		[actionSheet showInView:sender];
		[actionSheet release];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == [actionSheet destructiveButtonIndex]) {
		[self clearDownloadedTracks];
	} else if(buttonIndex == [actionSheet cancelButtonIndex]) {
		return;
	} else {
		[self enableOfflineMode];
	}
}


#pragma mark Shuffle

- (NSMutableArray *)shuffleArray:(NSArray *)array {
	NSMutableArray *shuffledArray = [NSMutableArray arrayWithCapacity:[array count]];
	[shuffledArray addObjectsFromArray:array];
	if ([shuffledArray count] > 1) {
		for (NSUInteger shuffleIndex = [shuffledArray count] - 1; shuffleIndex > 0; shuffleIndex--)
			[shuffledArray exchangeObjectAtIndex:shuffleIndex withObjectAtIndex:random() % (shuffleIndex + 1)];
	}
	return shuffledArray;
}

- (void)shuffle:(id)sender {
	NSMutableArray *tracks = [self shuffleArray:[fetchedResultsController fetchedObjects]];
	[self.appDelegate.playerController enqueueTracks:tracks];
	[self.appDelegate.playerController nextTrack:nil];
	[self.appDelegate showPlayer];
}


#pragma mark Release helper methods

- (void)refreshRelease {
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}


#pragma mark View methods

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
	//self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.title = theRelease.title;
	
	// Load the release header nib
    if (tableHeaderView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ReleaseHeader" owner:self options:nil];
    }

	// Fetch the tracks from CoreData
	[self refreshRelease];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	// Set the table header
	self.tableView.tableHeaderView = tableHeaderView;
	
	// Set the artwork
	if(theRelease.smallArtworkImage) {
		self.artworkImage.image = theRelease.smallArtworkImage;
	} else {
		self.artworkImage.image = [UIImage imageNamed:@"cover-art-small.jpg"];
	}
	
	// Set the artist and title
	self.titleLabel.text = theRelease.title;
	self.artistLabel.text = theRelease.artist;
	
	// Set label and release date
	if(theRelease.label) {
		self.releasedByLabel.text = theRelease.label;
	} else {
		self.releasedByLabel.text = @"Unknown label";
		self.releasedByLabel.font = [UIFont italicSystemFontOfSize:10];
	}
	
	if(theRelease.releaseDate) {
		self.releasedAtLabel.text = theRelease.releaseDate;
	} else if (theRelease.year) {
		self.releasedAtLabel.text = [theRelease.year stringValue];
	}
	
	// Set background color of table view to the same as the header view
	self.tableView.backgroundColor = tableHeaderView.backgroundColor;
	
	// Prefetch the large artwork for the release
	self.theRelease.largeArtworkImage;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	Track *track = [fetchedResultsController objectAtIndexPath:indexPath];
	if(track.artist == nil) {
		return 44;
	} else {
		return 60;
	}
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (void)configureCell:(TrackTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	// Set up the cell...
	cell.index = [indexPath row]+1;
	cell.showAlbumArtist = NO;
	cell.track = [fetchedResultsController objectAtIndexPath:indexPath];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

	TrackTableViewCell *cell = (TrackTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TrackTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
    
	// Set up the cell...
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    if([[fetchedResultsController sections] count] > 1) {
		NSArray *sectionIndex = [@"A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z" componentsSeparatedByString:@"|"];
		return [NSString stringWithFormat:@"Side %@", [sectionIndex objectAtIndex:section]];
	} else {
		return nil;
	}
}


//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return [fetchedResultsController sectionIndexTitles];
//}


//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    return [fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.appDelegate.playerController enqueueTracks:[fetchedResultsController fetchedObjects] andPlayTrackWithIndex:indexPath.row];
	[self.appDelegate showPlayer];
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
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:self.appDelegate.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort keys as appropriate.
		NSSortDescriptor *sortDescriptorSetNr = [[NSSortDescriptor alloc] initWithKey:@"setNr" ascending:YES selector:@selector(compare:)];
		NSSortDescriptor *sortDescriptorTrackNr = [[NSSortDescriptor alloc] initWithKey:@"trackNr" ascending:YES selector:@selector(compare:)];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorSetNr, sortDescriptorTrackNr, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
		
		// Edit the filter predicate as appropriate.
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent == %@", theRelease];
		[fetchRequest setPredicate:predicate];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.appDelegate.managedObjectContext sectionNameKeyPath:@"setNr" cacheName:nil];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
        [aFetchedResultsController release];
        [fetchRequest release];
        [sortDescriptorSetNr release];
		[sortDescriptorTrackNr release];
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
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(TrackTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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


#pragma mark Dealloc

- (void)dealloc {
	[fetchedResultsController release];
    [super dealloc];
}


@end

