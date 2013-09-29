//
//  ItemList.m
//  Acre
//
//  Created by Justin Armstrong on 3/5/11.
//  Copyright 2011 Actinic inc. All rights reserved.
//

#import "ItemList.h"


@implementation ItemList
@synthesize table, itemArray, itemToLiquidate;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSPredicate* noMoney = [NSPredicate predicateWithFormat:@"typeId != 1"];
    itemArray = [[NSMutableArray alloc] initWithArray:
		[[Datastore getInst].carriedItems filteredArrayUsingPredicate:noMoney]];
	
	liquidateService = [PListModel new];
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(liquidateDidRespond:) 
			name:@"serverDidRespond" object:liquidateService];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? itemArray.count : 1;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section){
		case 0:
			return @"Items";
		case 1:
			return @"Money";
	}
	return @"";
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *needCellType;
	Item* item;
	
	if(indexPath.section == 0 ) {
		item = [itemArray objectAtIndex:indexPath.row] ;
		needCellType = @"itemCell";
	}else{
		item = [Datastore getInst].moneyItem;
		needCellType = @"moneyCell";
	}
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:needCellType];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:needCellType] autorelease];
		if(indexPath.section == 0){
			UIImage* btnUp = [UIImage imageNamed:@"button_cancel_bg.png"];
			UIImage* btnDn = [UIImage imageNamed:@"button_cancel_bg_h.png"];
			UIButton* liqButton = [UIButton buttonWithType:UIButtonTypeCustom];
			liqButton.titleLabel.font = [UIFont systemFontOfSize:10];
			[liqButton setFrame:CGRectMake(0,0,btnUp.size.width, btnUp.size.height)];
			[liqButton setBackgroundImage:btnUp forState:UIControlStateNormal];
			[liqButton setBackgroundImage:btnDn forState:UIControlStateHighlighted];
			[liqButton setTitle:@"Liquidate" forState:UIControlStateNormal];
			[liqButton addTarget:self action:@selector(liquidate:) forControlEvents:UIControlEventTouchUpInside];
			cell.accessoryView = liqButton;
		}
    }
    
	[item lookupItemInfo];
	cell.imageView.image = [Datastore imageForItemWithId:item.typeId];
    cell.textLabel.text = [NSString stringWithFormat:@"%d",item.qty];
	cell.detailTextLabel.text = item.typeName;
    return cell;
}

- (void) liquidate:(id)sender{
	UITableViewCell* thisCell = (UITableViewCell*) [(UIButton*) sender superview];
	NSUInteger index = [self.table indexPathForCell:thisCell].row;
	self.itemToLiquidate = [itemArray objectAtIndex:index];
	NSString* msg = [NSString stringWithFormat:@"Liquidate %@ for %d $",
		itemToLiquidate.typeName, itemToLiquidate.qty];
	//NSString* liqMsg = [NSString stringWithFormat:@"Liquidate %@",itemToLiquidate.typeName];
	UIActionSheet* sheet = [[UIActionSheet alloc]
		initWithTitle:msg delegate:self cancelButtonTitle:@"Cancel" 
		destructiveButtonTitle:@"Liquidate" otherButtonTitles:nil];
	sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[sheet showInView:self.tabBarController.view];
	[sheet release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex==0){
		//liquidate it
		[ActivityView presentFrom:self withMessage:@"processing..." cancelable:NO];
		NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
			[NSString stringWithFormat:@"%d",itemToLiquidate.dbId],@"id",nil];
		[liquidateService callFunction:@"liquidateItem" withParams:params];
		[params release];
	}
}

- (void) liquidateDidRespond:(NSNotification*)notification{
	[ActivityView removeSelf];
	ServerResponse* response = [[notification object] lastResponse];
	if(response.success){
		[itemArray removeObject:itemToLiquidate];
		[Datastore getInst].moneyItem.qty += itemToLiquidate.qty; //**** 1 to 1 item liquidation rule
		[self.table reloadData];
	}else{
		NSString* msg = [NSString stringWithFormat:@"Transaction didn't go through. Error id: %d : %@",
			response.errorId, response.errorMessage];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
			message:msg delegate:self 
			cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
		[alert show]; 
		[alert release];
	}
}

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[table release];
	[itemArray release];
	[itemToLiquidate release];
    [liquidateService release];
    [super dealloc];
}


@end

