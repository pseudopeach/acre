//
//  DevDetail2.m
//  Acre
//
//  Created by Justin Armstrong on 11/26/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "DevDetail2.h"


@implementation DevDetail2
@synthesize development, lotData, headerView, buildButton, devImage,
footerView, header1, header2, cantAffordLab;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad{
	// headerView
    self.tableView.backgroundColor = [UIColor clearColor];
	CGRect newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.headerView.frame.size.height);
	self.headerView.backgroundColor = [UIColor clearColor];
	self.headerView.frame = newFrame;
	self.tableView.tableHeaderView = self.headerView;	// note this will override UITableView's 'sectionHeaderHeight' property
	
	// footer
	newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.footerView.frame.size.height);
	self.footerView.backgroundColor = [UIColor clearColor];
	self.footerView.frame = newFrame;
	self.tableView.tableFooterView = self.footerView;	// note this will override UITableView's 'sectionFooterHeight' property
	
	self.header1.text = development.name;
	self.header2.text = development.description;
	self.navigationItem.title = @"Details";
	self.devImage.image = [Datastore imageForDevWithId:development.dbId];
	
	if(![development canBuildOnLot:lotData]){
		buildButton.enabled = NO;
		buildButton.alpha = .5;
		cantAffordLab.text = @"You can't afford this development right now.";
	}
    hasMultiAction = NO;
    for(int i=0;i<development.output.count;i++){
        Item* item = [development.output objectAtIndex:i];
        if(item.actionGroup != 1)
            hasMultiAction = YES;
    }
        
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//

- (void)viewDidUnload{
	self.headerView = nil;
	self.footerView = nil;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   // int sec = (development.input.count > 0)+(development.output.count > 0)+(development.abilities.count > 0) + 1;
    //NSLog(@"dev detail has %d sections",sec);
	return (development.input.count > 0)+(development.output.count > 0)+(development.abilities.count > 0) + 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int sectionC = [self correctedSection:section];
	switch(sectionC){
		case 0:
			return development.cost.count;
		case 1:
			return development.input.count;
		case 2:
			return development.output.count;
        case 3:
			return development.abilities.count;
	}
	return 0;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    int sectionC = [self correctedSection:section];
    
	switch(sectionC){
		case 0:
			return @"Costs";
		case 1:
			return @"Uses";
		case 2:
			return @"To Produce";
        case 3:
			return @"Abilities";
	}
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    int sectionC = [self correctedSection:indexPath.section];
    
	NSArray* sectionSource;
	if(sectionC == 0)
		sectionSource = development.cost;
	else if(sectionC == 1)
		sectionSource = development.input;
	else if(sectionC == 2)
		sectionSource = development.output;
    else
        sectionSource = development.abilities;
	
	if(sectionC != 3){
        Item* item = (Item*) [sectionSource objectAtIndex:indexPath.row];
        [item lookupItemInfo];
        int itemQtyC = sectionC == 1 ? -item.qty : item.qty;
        cell.textLabel.text = [NSString stringWithFormat:@"%d %@", itemQtyC, item.typeName];
        if(hasMultiAction && sectionC != 0)
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (group %d)",cell.textLabel.text,item.actionGroup];
        cell.imageView.image = [Datastore imageForItemWithId:item.typeId];
    }else{
        cell.textLabel.text = [sectionSource objectAtIndex:indexPath.row];
        cell.imageView.image = nil;
    }
        
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (IBAction) buildHere{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectDevelopment" object:self];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (int) correctedSection:(int)indexPathSec{
    int sectionC = indexPathSec;
	if(sectionC >= 1 && development.input.count == 0)
		sectionC++;
	if(sectionC >= 2 && development.output.count == 0)
		sectionC++;
    return sectionC;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [view autorelease];
    [view addSubview:label];
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40;
}


- (void)dealloc {
	[header1 release];
	[header2 release];
	[headerView release];
	[footerView release];
	[development release];
    [lotData release];
	[cantAffordLab release];
	[buildButton release];
	[devImage release];
    [super dealloc];
}


@end

