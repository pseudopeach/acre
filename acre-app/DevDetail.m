//
//  DevDetail.m
//  Acre
//
//  Created by Justin Armstrong on 11/22/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "DevDetail.h"


@implementation DevDetail
@synthesize development, headerView;

#pragma mark -
#pragma mark Initialization
/*
- (void)viewDidLoad
{
	
	// headerView
	CGRect newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.myHeaderView.frame.size.height);
	self.headerView.backgroundColor = [UIColor clearColor];
	self.headerView.frame = newFrame;
	self.tableView.tableHeaderView = self.myHeaderView;	// note this will override UITableView's 'sectionHeaderHeight' property
	
	// set up the table's footer view based on our UIView 'myFooterView' outlet
	newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.myFooterView.frame.size.height);
	self.footerView.backgroundColor = [UIColor clearColor];
	self.footerView.frame = newFrame;
	self.tableView.tableFooterView = self.myFooterView;	// note this will override UITableView's 'sectionFooterHeight' property
}*/

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
/*
- (void)viewDidUnload{
	self.myHeaderView = nil;
}
*/
/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return development.cost.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	Item* item = (Item*) [development.cost objectAtIndex:indexPath.row];
	[item lookupItemInfo];
    cell.textLabel.text = [NSString stringWithFormat:@"%d %@", item.qty, item.typeName];
	cell.imageView.image = [Datastore imageForItemWithId:item.typeId];
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
/*
- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section{
	headerView = [[DetailHeaderView alloc] initWithNibName:@"DetailHeaderView" bundle:nil];
	headerView.header1.text = @"SOmwthigns";//development.name;
	headerView.header2.text = development.description;
	return headerView.view;
}*/
/*
- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section{
	UIView* footerView = [[[UIView alloc] init] autorelease];
	UIButton* buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect]; //initWithFrame:CGRectMake(20,20,200,40)] autorelease];
	buyButton.frame = CGRectMake(10,15,300,45);
	[buyButton setTitle:@"Build Here" forState:UIControlStateNormal];
	[footerView addSubview:buyButton];
	[buyButton setBackgroundImage:[UIImage imageNamed:@"button_bg.png"] forState:UIControlStateNormal];
	[buyButton setBackgroundImage:[UIImage imageNamed:@"button_bg_h.png"] forState:UIControlStateHighlighted];
	return footerView;
}*/


- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
	if(section == 0)
		return 180;
	else
		return [super tableView:tableView heightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section{
	return 75;
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
}


- (void)dealloc {
	[development release];
	[headerView release];
    [super dealloc];
}


@end

