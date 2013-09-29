//
//  LotEdit.m
//  Acre
//
//  Created by Justin Armstrong on 11/13/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "LotEdit.h"


@implementation LotEdit
@synthesize lotData, nameField, rentPayCell;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor clearColor];
	UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
		style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
		style:UIBarButtonItemStyleDone target:self action:@selector(saveAndClose)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	self.navigationItem.rightBarButtonItem = doneButton;
	[cancelButton release];
	[doneButton release];
	
	//lookup and save the city if it hasn't been done
	if(!lotData.locationName || [lotData.locationName isEqualToString:@""])
		[lotData lookupCity];
	
	payService = [PListModel new];
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(payNowDidRespond:) 
			name:@"serverDidRespond" object:payService];
}



- (void) rewriteData{
	lotData.name = nameField.text;
}

- (void) save{
	[super save];
	[model callFunction:@"setLotInfo" withParams:lotData.serverParams];
}
- (void) saveDidSucceed{
	[delegate remapLot:lotData];
	[super saveDidSucceed];
}
- (void) saveDidFail:(ServerResponse *)response{
	if(response.errorId == 6){
		NSLog(@"result object: %@",response.resultObject);
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
			message:@"Some of the changes to this acre could not be saved. Try loading it again." delegate:self 
			cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show]; 
		[alert release];
		[self close];
	}else{
		NSString* errorMsg = [NSString stringWithFormat:@"Server error. ID:%d",response.errorId];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
			message:errorMsg delegate:self 
			cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show]; 
		[alert release];
		[self close];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section){
		case 0:
			return 1;
		case 2:
			return lotData.lotHistory.count > 0 ? lotData.lotHistory.count : 1;
		case 1:
			return 1;
		case 3:
			return 2;
	}
	return 0;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section){
		case 0:
			return @"Lot Name";
        case 1:
			return @"Development";
		case 2:
			return @"Recent Activity";
		case 3:
			return @"Lease";
	}
	return @"";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* cell;
    if(indexPath.section == 2){//history section
		if(lotData.lotHistory.count == 0){//no history items to display
			cell =  [[[UITableViewCell alloc] 
					  initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
			cell.detailTextLabel.text = @"no activity";
		}else{
			cell = [tableView dequeueReusableCellWithIdentifier:@"LogItem"];
			if (cell == nil) 
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
					reuseIdentifier:@"LogItem"] autorelease];
			LogItem* item = [lotData.lotHistory objectAtIndex:indexPath.row];
			cell.textLabel.text = item.description;
			cell.imageView.image = [Datastore imageForItemWithId:item.itemTypeId];
		}
		//cell.imageView.image = [[Datastore inst] imageForItemTypeId:item.itemTypeId];
	}else if(indexPath.section == 3){//rent section
		if(indexPath.row == 0){
			cell =  [[[UITableViewCell alloc] 
					  initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
			cell.detailTextLabel.text = @"Lot Value";
			UILabel* valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(90,12,200,25)];
			valueLabel.font = [UIFont systemFontOfSize:16];
			valueLabel.text = [NSString stringWithFormat:@"$%d",lotData.rentBid];
			[cell.contentView addSubview:valueLabel];
			[valueLabel release];
		}
		else{
		    static NSString* reuseId = @"PayRentCell";
			self.rentPayCell = (LotEditPayRent*)[tableView dequeueReusableCellWithIdentifier:reuseId];
			if (rentPayCell == nil) {
				self.rentPayCell = (LotEditPayRent*) 
					[[[NSBundle mainBundle] 
					 loadNibNamed:@"LotEditPayRent2" owner:self options:nil]
					 objectAtIndex:0];
			}
			[rentPayCell.payButton addTarget:self action:@selector(payNow) forControlEvents:UIControlEventTouchUpInside];
			rentPayCell.lotData = lotData;
			cell = rentPayCell;
		}
	}else if(indexPath.section == 1){//dev section
		cell =  [[[UITableViewCell alloc] 
				  initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
		cell.textLabel.text = lotData.devTypeName;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}else{//lot name section
		cell =  [[[UITableViewCell alloc] 
				  initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
		cell.detailTextLabel.text = @"Name";
		
		self.nameField = [[[UITextField alloc] initWithFrame:CGRectMake(90,12,200,25)] autorelease];
		nameField.clearsOnBeginEditing = NO;
		nameField.returnKeyType = UIReturnKeyDone;
		[cell.contentView addSubview:nameField];
		nameField.text = lotData.name;
		[nameField addTarget:self action:@selector(nameFieldDone:) 
			forControlEvents:UIControlEventEditingDidEndOnExit|UIControlEventTouchUpOutside];
	}
	cell.selectionStyle = (indexPath.section == 2) ? 
		UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath{
	if(indexPath.section == 3 && indexPath.row != 0)
		return 75;
	else 
		return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1){
		DevList* devList = [[DevList alloc] initWithStyle:UITableViewStyleGrouped];
		devList.lotData = lotData;
		[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(didSelectDevelopment:) 
			name:@"didSelectDevelopment" object:nil];
		[[self navigationController] pushViewController:devList animated:YES];
		[devList release];
	}
}

- (void) nameFieldDone:(UITextField*)textField{
	[textField resignFirstResponder];
}

- (void) didSelectDevelopment:(NSNotification*)notification{
	Dev* newDev = [(DevDetail2*)[notification object] development];
	lotData.devTypeId = newDev.dbId;
	lotData.devTypeName = newDev.name;
	[self.tableView reloadData];
	[self.navigationController popToViewController:self animated:YES];
}

-(void) payNow{
	NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSString stringWithFormat:@"%d", lotData.ci],@"ci",
		[NSString stringWithFormat:@"%d", lotData.cj],@"cj",nil];
	[ActivityView presentFrom:self withMessage:@"processing..." cancelable:NO];
	[payService callFunction:@"payUpkeep" withParams:params];
	[params release];
}

- (void) payNowDidRespond:(NSNotification*)notification{
	[ActivityView removeSelf];
	ServerResponse* response = [[notification object] lastResponse];
	if(response.success){
		NSDate* newRentDueDate = [response.resultObject valueForKey:@"newDueDate"];
		if(newRentDueDate)
			lotData.rentDue = newRentDueDate;
		[self.tableView reloadData];
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


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewDidUnload];
}


- (void)dealloc {
	[lotData release];
	[nameField release];
	[rentPayCell release];
	[payService release];
    //[dateFormatter release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


@end
