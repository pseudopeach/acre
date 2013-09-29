//
//  LotItems.m
//  Acre
//
//  Created by Justin Armstrong on 11/13/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "LotItems.h"


@implementation LotItems
@synthesize lotData, carriedTotLab, lotTotLab, table, headerView, items;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	table.backgroundColor = [UIColor clearColor];
	
		
	currentSlider = -1;
	
	//CGRect newFrame = CGRectMake(0.0, 0.0, table.bounds.size.width, self.headerView.frame.size.height);
	//self.headerView.frame = newFrame;
	//table.tableHeaderView = self.headerView;
	
	items = [[NSMutableArray alloc] 
		initWithCapacity:lotData.itemsPresent.count + [Datastore getInst].carriedItems.count];
		
	//items: array of mutable dictionaries
	//set the @"lot" keys to all the itemsPresent
	int j=0;
	for(int i=0;i<lotData.itemsPresent.count;i++){
		Item* item = [lotData.itemsPresent objectAtIndex:i];
		if(item.typeId != 1){
			NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
			item, LotItemDictKeyLot,[NSNumber numberWithInt:j], LotItemDictKeyIndex, nil];
			[items insertObject:dic atIndex:items.count];
			[dic release];
			j++;
		}
	}
	//set the @"carried" keys to the Datastore carried items, add new items to the array if needed
	for(int i=0;i<[Datastore getInst].carriedItems.count;i++){
		Item* item = [[Datastore getInst].carriedItems objectAtIndex:i];
		if(item.typeId == 1) continue;
		j = 0;
		while(j<items.count && 
			[(Item*)[[items objectAtIndex:j] objectForKey:LotItemDictKeyLot] typeId] != item.typeId)
				j++;
		//if(j >= items.count){ 
		NSMutableDictionary* dic; 
		if(j >= items.count){//NSLog(@"didn't find match j=%d",j);
			dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
				item, LotItemDictKeyCarried,[NSNumber numberWithInt:j], LotItemDictKeyIndex, nil];
			[items insertObject:dic atIndex:j];
			[dic release];
		}else    //NSLog(@"found match j=%d",j);
			[(NSMutableDictionary*)[items objectAtIndex:j] setObject:item forKey:LotItemDictKeyCarried];
	}
	
	[self setSliderBounds];
	/*lotTotLab.text = [NSString stringWithFormat:@"%d / %d", tempSumLot, lotData.itemLimit];
	carriedTotLab.text = [NSString stringWithFormat:@"%d / %d", 
		tempSumCarried, [Datastore getInst].carryLimit];*/
	
}




#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(section == 0)
		return @"Lot Items";
	else
		return @"Carried Items";
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1 + items.count;
	//return (section == 0) ? 1 : items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //static NSString *CellIdentifier = @"SliderCell";
	if(indexPath.row == 0){
		UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Dont"];
		UILabel* directions = [[UILabel alloc] initWithFrame:
			CGRectMake(20.0, 10.0, 270, 35)];
		directions.text = @"Drag the sliders to the right to drop items in this acre. Slide them to the left to pick items up.";
		directions.textAlignment = UITextAlignmentCenter;
		directions.font = [UIFont systemFontOfSize:10];
		directions.numberOfLines = 2;
		directions.lineBreakMode = UILineBreakModeWordWrap;
		[cell.contentView addSubview:directions];
		[directions release];
		return [cell autorelease];
	}
    ItemSlider* cell = (ItemSlider*) [table dequeueReusableCellWithIdentifier:@"SliderCell"];
    if (cell == nil) {
		NSArray* nibStuff = [[NSBundle mainBundle] loadNibNamed:@"ItemSlider" owner:self options:nil];
		for(id obj in nibStuff)
			if([obj isKindOfClass:[UITableViewCell class]]){
				cell = (ItemSlider*) obj;
				break;
			}
	}
	cell.itemInfo = [items objectAtIndex:(indexPath.row-1)]; //-1 for the instructions row
	cell.lotData = lotData;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.delegate = self;
    
	//[cell autorelease];
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath{
	return (indexPath.row == 0) ? 55 : 100;
}

- (void) updateSums{
	tempSumLot = 0;
	tempSumCarried = 0;
	for(int i=0;i<items.count;i++){
		NSMutableDictionary* infoDict = [items objectAtIndex:i];
		Item* citm = [infoDict objectForKey:LotItemDictKeyCarried];
		Item* litm = [infoDict objectForKey:LotItemDictKeyLot];
		if(i != currentSlider){
			tempSumCarried += citm.qty;
			tempSumLot += litm.qty;
		}else{
			tempSumCarried += (citm.qty+litm.qty);
		}
	}
	
	//tempSumLot = (sum of all items in lots) - (slider lot)
	//tempCarried = (sum of all items in lots) - (slider lot)
	
	//NSLog(@"tempSumCarried:%d tempSumLot:%d ",tempSumCarried, tempSumLot);
	
	if(currentSlider == -1){
		lotTotLab.text = [NSString stringWithFormat:@"%d / %d", tempSumLot, lotData.itemLimit];
		carriedTotLab.text = [NSString stringWithFormat:@"%d / %d", 
			tempSumCarried, [Datastore getInst].carryLimit];
	}
}

- (void) sliderValueDidChange:(int)index toValue:(int)value{

	//if this is the first time for this slider add up the tempSums
	if(index != currentSlider){
		currentSlider = index;
		[self updateSums];
	}
	
	lotTotLab.text = [NSString stringWithFormat:@"%d / %d", tempSumLot + value, lotData.itemLimit];
	carriedTotLab.text = [NSString stringWithFormat:@"%d / %d", 
		tempSumCarried - value, [Datastore getInst].carryLimit];
}

- (void) sliderDidEndSliding:(int)index atValue:(int)value{
	[self setSliderBounds];
	[table reloadData];
}

- (void) setSliderBounds{
	tempSumLot = 0;
	tempSumCarried = 0;
	currentSlider = -1;
	[self updateSums];
	int lotSpace = lotData.itemLimit - tempSumLot;
	int carrySpace = [Datastore getInst].carryLimit - tempSumCarried;
	for(int i=0;i<items.count;i++){
		//Item* citm = [(NSDictionary*) [items objectAtIndex:i] objectForKey:LotItemDictKeyCarried];
		NSMutableDictionary* infoDict = [items objectAtIndex:i];
		int lotQty = [(Item*)[infoDict objectForKey:LotItemDictKeyLot] qty];
		[infoDict setObject:[NSNumber numberWithInt:(lotQty-carrySpace)] forKey:LotItemDictKeyMinValue];
		[infoDict setObject:[NSNumber numberWithInt:(lotQty+lotSpace)] forKey:LotItemDictKeyMaxValue];
	}
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

- (void) save{
	[super save];
	[model callFunction:@"setLotInfo" withParams:lotData.serverParams];
}

- (void) saveDidSucceed{
	[delegate remapLot:lotData];
	[super saveDidSucceed];
}

- (void)dealloc {
	[lotData release];
	[carriedTotLab release];
	[lotTotLab release];
	[table release];
	[headerView release];
	[items release];
    [super dealloc];
}


@end
