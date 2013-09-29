//
//  HouseList.m
//  Acre
//
//  Created by Justin Armstrong on 12/18/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "HouseList.h"


@implementation HouseList
@synthesize houseList, isLeaf;

#pragma mark -
#pragma mark Initialization

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
		style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
	self.navigationItem.rightBarButtonItem = cancelButton;
	[cancelButton release];
}

- (void) setLotList:(NSArray*) input{
	[lotList autorelease];
	lotList = [input retain];
	
	NSPredicate* houseFilter = [NSPredicate predicateWithFormat:@"parentLotId == 0"];
	self.houseList = [lotList filteredArrayUsingPredicate:houseFilter];
}
- (NSArray*) lotList{
	return lotList;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return isLeaf ? lotList.count : houseList.count;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath{ return 55;}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	Lot* lot = isLeaf ? [lotList objectAtIndex:indexPath.row] : [houseList objectAtIndex:indexPath.row];
    
	if(isLeaf){
		LotListPayRent* payCell = (LotListPayRent*) [tableView dequeueReusableCellWithIdentifier:@"payCell"];
		
		if (payCell == nil) {
			NSArray* nibStuff = [[NSBundle mainBundle] loadNibNamed:@"LotListPayRent" owner:payCell options:nil];
			for(id obj in nibStuff)
				if([obj isKindOfClass:[UITableViewCell class]]){
					payCell = (LotListPayRent*) obj;
					break;
				}
		}
		//[[NSBundle mainBundle] loadNibNamed:@"LotListPayRent" owner:payCell options:nil];
		/*payCell.nameLab.text = lot.name;
		payCell.dueLab.text = @"due sometime";
		payCell.valueLab.text = [NSString stringWithFormat:@"$%d",lot.rentPrice];
		payCell.detailLab.text = lot.locationName ?
			[NSString stringWithFormat:@"%@ in %@",lot.devTypeName,lot.locationName] : 
			lot.devTypeName;*/
		payCell.lotData = lot;
		payCell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell = (UITableViewCell*) payCell;
	}else{
		//non-leaf lot
		cell = [tableView dequeueReusableCellWithIdentifier:@"branchCell"];
		if (cell == nil) 
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
			reuseIdentifier:@"branchCell"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = lot.name;
		cell.detailTextLabel.text = lot.locationName ?
			[NSString stringWithFormat:@"%@ in %@",lot.devTypeName,lot.locationName] : lot.devTypeName;
    }
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
if(!isLeaf){
	Lot* selectedItem = [houseList objectAtIndex:indexPath.row];
	NSPredicate* childFilter = [NSPredicate predicateWithFormat:
		@"dbId == %d || parentLotId == %d", selectedItem.dbId, selectedItem.dbId];
	HouseList* houseLotsView = [HouseList new];
	houseLotsView.lotList = [lotList filteredArrayUsingPredicate:childFilter];
	houseLotsView.isLeaf = YES;
	houseLotsView.title = [NSString stringWithFormat:@"Near %@",selectedItem.name];
	[self.navigationController pushViewController:houseLotsView animated:YES];
	[houseLotsView release];
}}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [lotList release];
	[houseList release];
    
    [super dealloc];
}


@end

