    //
//  CollectionsController.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2011-02-02.
//  Copyright 2011 Sutajio. All rights reserved.
//

#import "CollectionsController.h"
#import "CollectionGridViewCell.h"
#import "AppDelegate.h"


@implementation CollectionsController

@synthesize appDelegate, fetchedResultsController;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.appDelegate = [[UIApplication sharedApplication] delegate];
	
	self.gridView.delegate = self;
	self.gridView.dataSource = self;
	self.gridView.bounces = YES;
	
	self.gridView.backgroundColor = [UIColor clearColor];
	
	[[self fetchedResultsController] performFetch:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[fetchedResultsController release];
    [super dealloc];
}


#pragma mark -
#pragma mark DTGridViewDataSource methods

- (NSInteger)numberOfRowsInGridView:(DTGridView *)gridView {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:0];
	return [sectionInfo numberOfObjects] / 2;
}
- (NSInteger)numberOfColumnsInGridView:(DTGridView *)gridView forRowWithIndex:(NSInteger)index {
	return 4;
}

- (CGFloat)gridView:(DTGridView *)gridView heightForRow:(NSInteger)rowIndex {
	return 192.0;
}
- (CGFloat)gridView:(DTGridView *)gridView widthForCellAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex {
	return 192.0;
}

- (DTGridViewCell *)gridView:(DTGridView *)gv viewForRow:(NSInteger)rowIndex column:(NSInteger)columnIndex {
	
	CollectionGridViewCell *cell = (CollectionGridViewCell *)[gv dequeueReusableCellWithIdentifier:@"cell"];
	
	if (!cell) {
		cell = [[[CollectionGridViewCell alloc] initWithReuseIdentifier:@"cell"] autorelease];
	}
	
	NSUInteger indexArr[] = {0,((rowIndex*4)+columnIndex)};
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
	cell.release = [fetchedResultsController objectAtIndexPath:indexPath];

	return cell;
}


#pragma mark -
#pragma mark DTGridViewDelegate methods

- (void)gridView:(DTGridView *)gv selectionMadeAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex {
	NSLog(@"%@:%s %@", self, _cmd, [gv cellForRow:rowIndex column:columnIndex]);
	
}

- (void)gridView:(DTGridView *)gridView scrolledToEdge:(DTGridViewEdge)edge {
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
        
        // Edit the sort key as appropriate.
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
		
		// Edit the filter predicate as appropriate.
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"archived == NO"];
		[fetchRequest setPredicate:predicate];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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
	//[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
//	UITableView *tableView;
//	
//	if(controller == searchResultsController) {
//		tableView = searchController.searchResultsTableView;
//	} else {
//		tableView = self.tableView;
//	}
//	
//	ReleaseTableViewCell *cell;
//	
//	switch(type) {
//		case NSFetchedResultsChangeInsert:
//			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//			break;
//			
//		case NSFetchedResultsChangeDelete:
//			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//			break;
//			
//		case NSFetchedResultsChangeUpdate:
//			cell = (ReleaseTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//			cell.release = [controller objectAtIndexPath:indexPath];
//			break;
//			
//		case NSFetchedResultsChangeMove:
//			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
//	UITableView *tableView;
//	
//	if(controller == searchResultsController) {
//		tableView = searchController.searchResultsTableView;
//	} else {
//		tableView = self.tableView;
//	}
//	
//	switch(type) {
//		case NSFetchedResultsChangeInsert:
//			[tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//			break;
//			
//		case NSFetchedResultsChangeDelete:
//			[tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//			break;
//	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
//	if(controller == searchResultsController) {
//		[searchController.searchResultsTableView endUpdates];
//	} else {
//		[self.tableView endUpdates];
//	}
}


@end
