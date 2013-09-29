//
//  DevList.m
//  Acre
//
//  Created by Justin Armstrong on 11/21/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "DevList.h"


@implementation DevList
@synthesize lotData;

- (void)viewDidLoad{
	self.tableView.backgroundColor = [UIColor clearColor];
	self.navigationItem.title = @"Developments";
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[Datastore getInst] allDevelopments] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DevCell";
    Dev* development = [[[Datastore getInst] allDevelopments] objectAtIndex:indexPath.row];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		if(development.dbId == lotData.devTypeId){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
				reuseIdentifier: @"DontReuse"] autorelease];
			cell.imageView.image = [UIImage imageNamed:@"checkmark.png"];
		}else
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
				reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = development.name;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DevDetail2* thisDev = [[DevDetail2 alloc] initWithNibName:@"DevDetail2" bundle:nil];
    thisDev.development = [[[Datastore getInst] allDevelopments] objectAtIndex:indexPath.row];
    thisDev.lotData = lotData;
    [self.navigationController pushViewController:thisDev animated:YES];
    [thisDev release];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)dealloc {
	[lotData release];
    [super dealloc];
}


@end

