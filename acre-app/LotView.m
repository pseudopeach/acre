//
//  LotView.m
//  Acre
//
//  Created by Justin Armstrong on 11/14/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "LotView.h"

@implementation LotView
@synthesize headerView, nameLab, devTypeNameLab,
offersBuy, offersSell, offersTrade, devImage;

#pragma mark -
#pragma mark View lifecycle

- (void) viewDidLoad{
	[super viewDidLoad];
	self.tableView.backgroundColor = [UIColor clearColor];
	//UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
		//style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
		style:UIBarButtonItemStyleDone target:self action:@selector(close)];
	//self.navigationItem.leftBarButtonItem = cancelButton;
	self.navigationItem.rightBarButtonItem = doneButton;

	// headerView
	CGRect newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.headerView.frame.size.height);
	self.headerView.backgroundColor = [UIColor clearColor];
	self.headerView.frame = newFrame;
	self.tableView.tableHeaderView = self.headerView;	// note this will override UITableView's 'sectionHeaderHeight' property
	
	self.nameLab.text = lotData.name;
	self.devImage.image = [Datastore imageForDevWithId:lotData.devTypeId];
	self.devTypeNameLab.text = lotData.devTypeName;
	
	userService = [PListModel new];
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(getUserDetailDidRespond:) 
			name:@"serverDidRespond" object:userService];
}
- (void) viewDidUnload{
	self.headerView = nil;
}

- (void) setLotData:(Lot *)input{
	[lotData autorelease];
	lotData = [input retain];
	[self refreshOfferArrays];
}

- (void) refreshOfferArrays{
	NSPredicate* findBuys = [NSPredicate predicateWithFormat:@"isBuy == TRUE && unfulfilled > 0"];
	NSPredicate* findSells = [NSPredicate predicateWithFormat:@"isSell == TRUE  && unfulfilled > 0"];
	NSPredicate* findTrades = [NSPredicate predicateWithFormat:@"isBuy == FALSE && isSell == FALSE  && unfulfilled > 0"];
	self.offersBuy = [lotData.offers filteredArrayUsingPredicate:findBuys];
	self.offersSell = [lotData.offers filteredArrayUsingPredicate:findSells];
	self.offersTrade = [lotData.offers filteredArrayUsingPredicate:findTrades];
	
	nOfferSections = 
		((int) offersBuy.count > 0) + ((int) offersSell.count > 0) + ((int) offersTrade.count > 0);
}

- (Lot*) lotData{
	return lotData;
}
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (2 + nOfferSections);
}

-(NSArray*) offerArrayForSection:(int)section{
	int sectionC = section;
	if(sectionC >= 1 && offersBuy.count == 0)
		sectionC++;
	if(sectionC >= 2 && offersSell.count == 0)
		sectionC++;
		
	switch (sectionC) {
		case 1:
			return offersBuy;
		case 2:
			return offersSell;
		case 3:
			return offersTrade;
	}
	return offersTrade; //should never happen
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0)
		return 1;
	if(section > nOfferSections)
		   return 2;
		   
	return [self offerArrayForSection:section].count;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(section == 0)
		return @"Owner";
	if(section > nOfferSections)
		return @"Bid On This Lot";
	NSArray* offerArray = [self offerArrayForSection:section];
	if(offerArray == offersBuy)
		return @"Buying";
	if(offerArray == offersSell)
		return @"Selling";
	return @"Trades";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* cell;
	
	if(indexPath.section !=0  && indexPath.section <= nOfferSections){ //lot offers
		static NSString *CellIdentifier = @"OfferCell";
		Offer* offer = [[self offerArrayForSection:indexPath.section] objectAtIndex:indexPath.row];
		Item* haveItem = offer.haveItem;
		Item* wantItem = offer.wantItem;
		[haveItem lookupItemInfo];
		[wantItem lookupItemInfo];
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
				reuseIdentifier:CellIdentifier] autorelease];
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		//cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		
		if(!offer.isBuy && !offer.isSell){ 
			//barter
			cell.textLabel.text = [NSString stringWithFormat:@"%d %@", 
				offer.haveItem.qty, offer.haveItem.typeName];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"want %d %@", 
				offer.wantItem.qty, offer.wantItem.typeName];
		}else if(offer.isSell){//want money
			cell.textLabel.text = [NSString stringWithFormat:@"%d %@ for $%d",
				offer.haveItem.qty, offer.haveItem.typeName, offer.wantItem.qty];
		}else {
			cell.textLabel.text = [NSString stringWithFormat:@"%d %@ for $%d",
				offer.wantItem.qty, offer.wantItem.typeName, offer.haveItem.qty];
		}
		cell.imageView.image = [Datastore imageForItemWithId:offer.haveItem.typeId];
	}else if(indexPath.section > nOfferSections){  //rent section
		cell =  [[[UITableViewCell alloc] 
				  initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
		UILabel* valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(190,12,50,25)];
		valueLabel.font = [UIFont systemFontOfSize:16];
		if(indexPath.row == 0){ //high bid
			cell.detailTextLabel.text = @"Value";
			valueLabel.text = [NSString stringWithFormat:@"$%d",lotData.rentBid];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}else{ //your bid
			cell.detailTextLabel.text = @"Your Bid";
			NSLog(@"lot data rent price %d, rent bid %d",lotData.rentPrice, lotData.rentBid);
			valueLabel.text = (lotData.rentPrice != 0) ?
				[NSString stringWithFormat:@"$%d",lotData.rentPrice] : @" n/a ";
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		[cell.contentView addSubview:valueLabel];
		[valueLabel release];
	}else{ //owner section (section == 0)
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
				reuseIdentifier:@"DontReuse2"] autorelease];
		cell.textLabel.text = lotData.ownerName;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return cell;
}

#pragma mark -
#pragma mark tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0){
		NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:lotData.ownerName,@"screenName",nil];
		[ActivityView presentFrom:self withMessage:@"fetching..." cancelable:NO];
		[userService callFunction:@"getUser" withParams:params];
		[params release];
	}else if(indexPath.section > nOfferSections){
		LotBidManager* bidView = [[LotBidManager alloc] initWithNibName:@"LotBidManager" bundle:nil];
		bidView.lotData = lotData;
        bidView.delegate = self;
		bidView.title = @"Lot Bidding";
		[[self navigationController] pushViewController:bidView animated:YES];
		[bidView release];
	}else{ 
		OfferAccept* offerView = [[OfferAccept alloc] initWithNibName:@"OfferAccept" bundle:nil];
		offerView.delegate = self;
		offerView.offerData = [[self offerArrayForSection:indexPath.section] objectAtIndex:indexPath.row];
		offerView.title = @"Offer";
		[[self navigationController] pushViewController:offerView animated:YES];
		[offerView release];
	}
}

- (void) getUserDetailDidRespond:(NSNotification*)notification{
	[ActivityView removeSelf];
	ServerResponse* response = [[notification object] lastResponse];
	if(!response.success) return;
	
	User* user = [User new];
	[user setValuesForKeysWithDictionary:response.resultObject];
	
	UserDetail* detailView = [[UserDetail alloc] initWithNibName:@"UserDetail" bundle:nil];
	detailView.userData = user;
	[[self navigationController] pushViewController:detailView animated:YES];
	
	[user release];
	[detailView release];
}

- (void) didExecuteOffer{
	[self.navigationController popViewControllerAnimated:YES];
	[self refreshOfferArrays];
	[self.tableView reloadData];
}

- (void) didUpdateBid {
    [self.tableView reloadData];
}


- (void)dealloc {
	[headerView release]; 
	[nameLab release]; 
	[devTypeNameLab release]; 
	
	[lotData release];
	[offersBuy release];
	[offersSell release];
	[offersTrade release];
	[devImage release];
	
	[userService release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}


@end

