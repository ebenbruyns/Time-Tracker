//
//  SelectionListViewController.m
//  TimeTracker
//
//  Created by Eben Bruyns on 10/08/08.
//  
//  Copyright (c) 2008-2013, SDK Innovation Ltd.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met: 
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer. 
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution. 
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies, 
//  either expressed or implied, of the FreeBSD Project.

#import "SelectionListViewController.h"
#import "TimeTrackerAppDelegate.h"

@implementation SelectionListViewController

@synthesize customers,projects,tasks, tableView, lookupEditViewController, lookupNavigationController, editingItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		
	}
	return self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    //[super setEditing:editing animated:NO];

    // Updates the appearance of the Edit|Done button as necessary.
	NSInteger count = 0;
	if ([self.title isEqualToString:@"Customers"]) {
		count = [customers count];
	} else if ([self.title isEqualToString:@"Projects"]) {
		count = [projects count];
	} else if ([self.title isEqualToString:@"Tasks"]) {
		count = [tasks count];
	}
	if (!editing && count == 0) {
		return;
	}
	[super setEditing:editing animated:animated];
	
	if(count > 0)
	{
		NSArray *indexPaths = [NSArray arrayWithObject:
							   [NSIndexPath indexPathForRow:count inSection:0]];
	    if (editing ) {
			// Show the placeholder rows
			[tableView beginUpdates];
			
			[tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
			[tableView endUpdates];
			//[tableView reloadData];
		} else if (!editing) {
			[tableView beginUpdates];
			
			
			// Hide the placeholder rows.
			[tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
			[tableView endUpdates];
			//[tableView reloadData];
			
		}
	}
	
	[tableView setEditing:editing animated:YES];
	// 
}


- (void)viewWillAppear:(BOOL)animated {
    
	NSInteger count = 0;
	if ([self.title isEqualToString:@"Customers"]) {
		count = [customers count];
	} else if ([self.title isEqualToString:@"Projects"]) {
		count = [projects count];
	} else if ([self.title isEqualToString:@"Tasks"]) {
		count = [tasks count];
	}
	if(count == 0)
	{
		self.editing = YES;
	}
	[self.tableView reloadData];
}

- (void)viewDidLoad {
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	//[tableView reloadData];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[customers release];
	[super dealloc];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // The number of sections is based on the number of items in the data property list.
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	NSInteger count = 0;
	if(section == 0)
	{
		if ([self.title isEqualToString:@"Customers"]) {
			count = [customers count];
		} else if ([self.title isEqualToString:@"Projects"]) {
			count = [projects count];
		} else if ([self.title isEqualToString:@"Tasks"]) {
			count = [tasks count];
		}	
		/*if(count == 0 && !self.editing)
			self.editing = YES;
		 */
		if(self.editing) 
		 count++;
	}
    return count;
}
/*
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 return [[data objectAtIndex:section] objectForKey:@"name"];
 }
 */

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextCell"] autorelease];
       // cell.hidesAccessoryWhenEditing = NO;
    }
    // The DetailCell has two modes of display - either a type/name pair or a prompt for creating a new item of a type
    // The type derives from the section, the name from the item.
	NSMutableArray *content;
	if ([self.title isEqualToString:@"Customers"]) {
		content = customers;
	} else if ([self.title isEqualToString:@"Projects"]) {
		content = projects;
	} else //if ([self.title isEqualToString:@"Tasks"]) 
    {
		content = tasks;
	}
	int count = [content count];
	if(indexPath.row < count)
	{
		
		if ([self.title isEqualToString:@"Customers"]) {
			Customer *cust = (Customer *)[self.customers objectAtIndex:indexPath.row];
			[cust hydrate];
			[cell.textLabel setText:cust.displayValue];
		} else if ([self.title isEqualToString:@"Projects"]) {
			Project *proj = (Project *)[self.projects objectAtIndex:indexPath.row];
			[proj hydrate];
			[cell.textLabel setText:proj.displayValue];
		} else if ([self.title isEqualToString:@"Tasks"]) {
			Task *tmpTask = (Task *)[self.tasks objectAtIndex:indexPath.row];
			[tmpTask hydrate];
			[cell.textLabel setText:tmpTask.displayValue];
		}
		
		
		//[obj release];
		//obj = nil;
	}
	else
	{
		if ([self.title isEqualToString:@"Customers"]) {
			[cell.textLabel setText:@"Add New Customer"];
		} else if ([self.title isEqualToString:@"Projects"]) {
			[cell.textLabel setText:@"Add New Project"];
		} else if ([self.title isEqualToString:@"Tasks"]) {
			[cell.textLabel setText:@"Add New Task"];
		}
	}
	
	
	if(self.editing)
	{
		
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
	}
	else 
		if ([self.title isEqualToString:@"Customers"]) {
			if([customers count] > 0) {
				if([[[customers objectAtIndex:indexPath.row] valueForKey:@"displayValue"] isEqualToString:[editingItem valueForKey:@"customer"]]) {
					cell.accessoryType=  UITableViewCellAccessoryCheckmark;
				}
			}
		} else if ([self.title isEqualToString:@"Projects"]) {
			if([projects count] > 0) {
				if([[[projects objectAtIndex:indexPath.row] valueForKey:@"displayValue"] isEqualToString:[editingItem valueForKey:@"project"]]) {
					cell.accessoryType=  UITableViewCellAccessoryCheckmark;
				}
			}
		} else if ([self.title isEqualToString:@"Tasks"]) {
			if([tasks count] > 0) {
				if([[[tasks objectAtIndex:indexPath.row] valueForKey:@"displayValue"] isEqualToString:[editingItem valueForKey:@"task"]]) {
					cell.accessoryType=  UITableViewCellAccessoryCheckmark;
				}
			}
		}
		else
			cell.accessoryType=  UITableViewCellAccessoryNone;
	
	
	return cell;
}

// The accessory view is on the right side of each cell. We'll use a "disclosure" indicator in editing mode,
// to indicate to the user that selecting the row will navigate to a new view where details can be edited.
/*
- (UITableViewCellAccessoryType)tableView:(UITableView *)aTableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	if(self.editing)
	{
		NSInteger count = 0;
		if ([self.title isEqualToString:@"Customers"]) {
			count = [customers count];
		} else if ([self.title isEqualToString:@"Projects"]) {
			count = [projects count];
		} else if ([self.title isEqualToString:@"Tasks"]) {
			count = [tasks count];
		}
		if(indexPath.row < count)
			return UITableViewCellEditingStyleDelete;
		else
			return UITableViewCellEditingStyleInsert;
	}
	else 
		if ([self.title isEqualToString:@"Customers"]) {
			if([customers count] > 0) {
				if([[[customers objectAtIndex:indexPath.row] valueForKey:@"displayValue"] isEqualToString:[editingItem valueForKey:@"customer"]]) {
					return UITableViewCellAccessoryCheckmark;
				}
			}
		} else if ([self.title isEqualToString:@"Projects"]) {
			if([projects count] > 0) {
				if([[[projects objectAtIndex:indexPath.row] valueForKey:@"displayValue"] isEqualToString:[editingItem valueForKey:@"project"]]) {
					return UITableViewCellAccessoryCheckmark;
				}
			}
		} else if ([self.title isEqualToString:@"Tasks"]) {
			if([tasks count] > 0) {
				if([[[tasks objectAtIndex:indexPath.row] valueForKey:@"displayValue"] isEqualToString:[editingItem valueForKey:@"task"]]) {
					return UITableViewCellAccessoryCheckmark;
				}
			}
		}
		else
			return UITableViewCellAccessoryNone;
    return UITableViewCellAccessoryNone;
}
*/
// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger count = 0;
	if ([self.title isEqualToString:@"Customers"]) {
		count = [customers count];
	} else if ([self.title isEqualToString:@"Projects"]) {
		count = [projects count];
	} else if ([self.title isEqualToString:@"Tasks"]) {
		count = [tasks count];
	}
	
	if (indexPath.row >= count) {
		return UITableViewCellEditingStyleInsert;
	} else {
		return UITableViewCellEditingStyleDelete;
	}
}
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
	TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Find the book at the deleted row, and remove from application delegate's array.
		if ([self.title isEqualToString:@"Customers"]) {
			Customer *customer = [customers objectAtIndex:indexPath.row];
			[appDelegate removeCustomer:customer];
		} else if ([self.title isEqualToString:@"Projects"]) {
			Project *project = [projects objectAtIndex:indexPath.row];
			[appDelegate removeProject:project];
		} else if ([self.title isEqualToString:@"Tasks"]) {
			Task *task = [tasks objectAtIndex:indexPath.row];
			[appDelegate removeTask:task];
		}
		
		
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
		 withRowAnimation:UITableViewRowAnimationFade];
		[tableView reloadData];
    }
	/*if(indexPath.row == [customers count] -1){
	 Customer *customer = [customers objectAtIndex:indexPath.row];
	 
	 [customer dehydrate];
	 }*/
}


- (LookupEditViewController *) lookupEditViewController {
	if (lookupEditViewController == nil) {
        LookupEditViewController *controller = [[LookupEditViewController alloc] initWithNibName:@"LookupEdit" bundle:nil];
        self.lookupEditViewController = controller;
        [controller release];
    }
	return lookupEditViewController;
	
}
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (indexPath.section == 0) {
		// Make a local reference to the editing view controller.
		if(self.editing)
		{
			LookupEditViewController *controller = self.lookupEditViewController;
			if ([self.title isEqualToString:@"Customers"]) {
				Customer *customer;
				if(indexPath.row == [customers count]) {
					customer = [[Customer alloc] init];	
				}
				else {
					customer =(Customer *)[customers objectAtIndex:indexPath.row];
				}
				
				controller.lookUpList = appDelegate.customers;
				controller.editedObject = customer;
				controller.textValue = customer.displayValue;
				controller.editedFieldKey = @"displayValue";
				controller.editTitle = @"Customer";

				controller.dateEditing = NO;
				controller.isNew = indexPath.row == [customers count];
				
				//[customer autorelease];
			} else if ([self.title isEqualToString:@"Projects"]) {
				Project *project;
				if(indexPath.row == [projects count]) {
					project = [[Project alloc] init];	
				}
				else {
					project =(Project *)[projects objectAtIndex:indexPath.row];
				}
				
				controller.lookUpList = appDelegate.projects;
				controller.editedObject = project;
				controller.textValue = project.displayValue;
				controller.editedFieldKey = @"displayValue";
				controller.editTitle = @"Project";
				controller.dateEditing = NO;
				controller.isNew = indexPath.row == [projects count];
				
				//[project autorelease];
			} else if ([self.title isEqualToString:@"Tasks"]) {
				Task *task;
				if(indexPath.row == [tasks count]) {
					task = [[Task alloc] init];	
				}
				else {
					task =(Task *)[tasks objectAtIndex:indexPath.row];
				}
				
				controller.lookUpList = appDelegate.tasks;
				controller.editedObject = task;
				controller.textValue = task.displayValue;
				controller.editedFieldKey = @"displayValue";
				controller.editTitle = @"Task";
				controller.dateEditing = NO;
				controller.isNew = indexPath.row == [tasks count];
				
				//[task autorelease];
			}
			
			
			[self.navigationController pushViewController:controller animated:YES];
			[controller setEditing:YES animated:NO];
		}
		else {
			if ([self.title isEqualToString:@"Customers"]) {
				editingItem.customer = [[customers objectAtIndex:indexPath.row] valueForKey:@"displayValue"];
			} else if ([self.title isEqualToString:@"Projects"]) {
				editingItem.project = [[projects objectAtIndex:indexPath.row] valueForKey:@"displayValue"];
			} else if ([self.title isEqualToString:@"Tasks"]) {
				editingItem.task = [[tasks objectAtIndex:indexPath.row] valueForKey:@"displayValue"];
			}
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger count = 0;
	if ([self.title isEqualToString:@"Customers"]) {
		count = [customers count];
	} else if ([self.title isEqualToString:@"Projects"]) {
		count = [projects count];
	} else if ([self.title isEqualToString:@"Tasks"]) {
		count = [tasks count];
	}
	
	
    return (indexPath.row < count);
}

// This allows the delegate to retarget the move destination to an index path of its choice. In this app, we don't want
// the user to be able to move items from one group to another, or to the last row of its group (the last row is
// reserved for the add-item placeholder).
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
	   toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	int count = 0;
	if ([self.title isEqualToString:@"Customers"]) {
		count = [customers count];
	} else if ([self.title isEqualToString:@"Projects"]) {
		count = [projects count];
	} else if ([self.title isEqualToString:@"Tasks"]) {
		count = [tasks count];
	}
	if(sourceIndexPath.row == count || proposedDestinationIndexPath.row == count)
		return sourceIndexPath;
	return proposedDestinationIndexPath;
}

// Process the row move. This means updating the data model to correct the item indices.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
	  toIndexPath:(NSIndexPath *)toIndexPath {
	NSMutableArray *content;
	if ([self.title isEqualToString:@"Customers"]) {
		content = customers;
	} else if ([self.title isEqualToString:@"Projects"]) {
		content = projects;
	} else { //if ([self.title isEqualToString:@"Tasks"]) {
		content = tasks;
	}
	
	
	if (content && toIndexPath.row < [content count]) {
		id item = [[content objectAtIndex:fromIndexPath.row] retain];
		[content removeObject:item];
		[content insertObject:item atIndex:toIndexPath.row];
		[item release];
		int i = 0;
		
		for(i = 0; i < [content count]; i++)
		{
			if ([self.title isEqualToString:@"Customers"]) {
				Customer *cust = (Customer *)[content objectAtIndex:i];
				cust.sortOrder = i;
			} else if ([self.title isEqualToString:@"Projects"]) {
				Project *proj = (Project *)[content objectAtIndex:i];
				proj.sortOrder = i;
			} else if ([self.title isEqualToString:@"Tasks"]) {
				Task *task = (Task *)[content objectAtIndex:i];
				task.sortOrder = i;
			}
			
			
		}
		//TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];

		if ([self.title isEqualToString:@"Customers"]) {
			//[appDelegate saveCustomers];
			[customers makeObjectsPerformSelector:@selector(dehydrate)];
			[customers makeObjectsPerformSelector:@selector(hydrate)];
		} else if ([self.title isEqualToString:@"Projects"]) {
			//[appDelegate saveProjects];
			[projects makeObjectsPerformSelector:@selector(dehydrate)];
			[projects makeObjectsPerformSelector:@selector(hydrate)];

		} else if ([self.title isEqualToString:@"Tasks"]) {
			//[appDelegate saveTasks];
			[tasks makeObjectsPerformSelector:@selector(dehydrate)];
			[tasks makeObjectsPerformSelector:@selector(hydrate)];

		}
	}
    
}

@end
