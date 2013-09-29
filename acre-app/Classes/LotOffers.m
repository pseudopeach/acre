//
//  LotOffers.m
//  Acre
//
//  Created by Justin Armstrong on 11/13/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "LotOffers.h"


@implementation LotOffers
@synthesize lotData, table;



#pragma mark -
#pragma mark ToolBar stuff

- (IBAction) didSelectToolbarButton:(id)sender{
	UIBarButtonItem* button = (UIBarButtonItem*) sender;
	switch (button.tag) {
		case 0:
			[self close];
			break;
		case 1:
			[self saveAndClose];
			break;
		case 86:
			[self toggleEditing];
			break;
		case 87:
			[self addOfferItem];
			break;
		default:
			break;
	}
}

- (void) addOfferItem{
	if(lotData.offers.count >= lotData.offerLimit){
		NSString* msg = [NSString stringWithFormat:
			@"This lot can only carry %d offers. You must remove some before adding more.",
			lotData.offerLimit];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
			message:msg delegate:self 
			cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
		[alert show]; 
		[alert release];
		return; 
	}

	OfferCreate* newOfferView = [[OfferCreate alloc] initWithNibName:@"OfferCreate" bundle:nil];
	newOfferView.delegate = self;
	newOfferView.lotData = lotData;
	
	NSPredicate* thisDevPrd = [NSPredicate predicateWithFormat:@"dbId == %d",lotData.devTypeId];
	Dev* thisDev = [[[Datastore getInst].allDevelopments filteredArrayUsingPredicate:thisDevPrd]
		objectAtIndex:0];
	newOfferView.lotDev = thisDev;
	
	newOfferView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:newOfferView animated:YES];
	[newOfferView release];
}

- (void) toggleEditing{
	[table setEditing:!table.editing animated:YES];
	
	//disable add button and done button
	//UIBarButtonItem* debugBBI = (UIBarButtonItem*) [self.view viewWithTag:1];
	/*[(UIBarButtonItem*) [self.view viewWithTag:87] setEnabled:NO];
	[(UIBarButtonItem*) [self.view viewWithTag:3] setTitle:@"sss"];
	[(UIBarButtonItem*) [self.view viewWithTag:3] setEnabled:!table.editing];*/
} 

- (void) tableView:(UITableView*)tableView 
		commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
		forRowAtIndexPath:(NSIndexPath*)indexPath{
	//NSUInteger row = indexPath.row;
	[lotData.offers removeObjectAtIndex:indexPath.row];
	[table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
		withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark -
#pragma mark OfferCreateDelegate

- (void) didCreateNewOffer:(Offer*)offer{
	[lotData.offers insertObject:offer atIndex:0];
	[self.table reloadData];
	[self dismissModalViewControllerAnimated:YES];
}

- (void) didDismissView{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return lotData.offers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"OfferCell";
    Offer* offer = [lotData.offers objectAtIndex:indexPath.row];
	Item* haveItem = offer.haveItem;
	Item* wantItem = offer.wantItem;
	[haveItem lookupItemInfo];
	[wantItem lookupItemInfo];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
			reuseIdentifier:CellIdentifier] autorelease];
    }
    
	if(!offer.isBuy && !offer.isSell){
		//barter
		cell.textLabel.text = [NSString stringWithFormat:@"Want %d %@ for %d %@", 
			offer.wantItem.qty, offer.wantItem.typeName, offer.haveItem.qty, offer.haveItem.typeName];
	}else if(offer.isSell){//want money
		cell.textLabel.text = [NSString stringWithFormat:@"Sell %d %@ for $%d",
			offer.haveItem.qty, offer.haveItem.typeName, offer.wantItem.qty];
	}else {
		cell.textLabel.text = [NSString stringWithFormat:@"Buy %d %@ for $%d",
			offer.wantItem.qty, offer.wantItem.typeName, offer.haveItem.qty];
	}
	cell.imageView.image = [Datastore imageForItemWithId:offer.haveItem.typeId];
	if(offer.unfulfilled > 1)
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d unfulfilled",offer.unfulfilled];
	else if(offer.unfulfilled == 0){
		cell.detailTextLabel.text = @"fulfilled";
		cell.textLabel.textColor = [UIColor grayColor];
	}else
		cell.detailTextLabel.text = @"";

    return cell;
}

- (void) save{
	[super save];
	[model callFunction:@"setLotInfo" withParams:lotData.serverParams];
}

- (void) saveDidSucceed{
	[delegate remapLot:lotData];
	[super saveDidSucceed];
}
#pragma mark -
#pragma mark lifecycle

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[lotData release];
	[table release];
    [super dealloc];
}


@end
