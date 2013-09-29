//
//  OfferCreate.m
//  Acre
//
//  Created by Justin Armstrong on 11/14/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "OfferCreate.h"


@implementation OfferCreate
@synthesize newOffer, lotData, lotDev, actionSeg, resourcePicker, priceFld, 
	pickerResourcesBuy, pickerResourcesSell, qtyArray, qtyArraySource, 
	delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
	self.qtyArraySource = [NSArray arrayWithObjects:
		[NSNumber numberWithInteger:1],[NSNumber numberWithInteger:2],[NSNumber numberWithInteger:3],
		[NSNumber numberWithInteger:4],[NSNumber numberWithInteger:5],[NSNumber numberWithInteger:10],
		[NSNumber numberWithInteger:15],[NSNumber numberWithInteger:20],[NSNumber numberWithInteger:25],
		[NSNumber numberWithInteger:30],[NSNumber numberWithInteger:50],[NSNumber numberWithInteger:75],
		[NSNumber numberWithInteger:100],[NSNumber numberWithInteger:150],[NSNumber numberWithInteger:200],
		[NSNumber numberWithInteger:250],[NSNumber numberWithInteger:300],[NSNumber numberWithInteger:500],
		[NSNumber numberWithInteger:750],[NSNumber numberWithInteger:1000],nil];
	
	
		
	self.qtyArray = [[[NSMutableArray alloc] initWithArray:qtyArraySource] autorelease];
    [self rebuildQtyArray:lotData.itemLimit];
	newOffer = [Offer new];
	if([lotDev.typeName isEqualToString:@"store"]){
		NSArray* keys = [Datastore getInst].allItems.allKeys;
		self.pickerResourcesBuy = [[[NSMutableArray alloc] initWithCapacity:keys.count-1] autorelease];
		int i=0;
		for(NSString* key in keys){
			if([key isEqual:@"1"]) continue;
			Item* item = [Item new];
			item.typeId = [key intValue];
			[item lookupItemInfo];
			[pickerResourcesBuy insertObject:item atIndex:i];
			[item release];
			i++;
		}

		//clean lot items array
		self.pickerResourcesSell = [[[NSMutableArray alloc] initWithCapacity:lotData.itemsPresent.count] autorelease];
		for(int i=0;i<lotData.itemsPresent.count;i++){
			Item* item = [lotData.itemsPresent objectAtIndex:i];
			if(item.typeId != 1){
				[item lookupItemInfo];
				[pickerResourcesSell insertObject:item atIndex:pickerResourcesSell.count];
			}
		}
	}else{
		self.pickerResourcesBuy = lotDev.input;
		for(int i=0;i<pickerResourcesBuy.count;i++){
			Item* item = [pickerResourcesBuy objectAtIndex:i];
			if(!item.typeName)
				[item lookupItemInfo];
		}
		self.pickerResourcesSell = [NSMutableArray arrayWithObjects:nil];
	}
	[actionSeg setEnabled:(pickerResourcesSell.count>0) forSegmentAtIndex:1];
	
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	if(component == 0)
		return (actionSeg.selectedSegmentIndex == 0) ? 
			pickerResourcesBuy.count : pickerResourcesSell.count;
	else
		return qtyArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	if(component == 0){
		Item* item = (Item*) (actionSeg.selectedSegmentIndex == 0) ? 
			[pickerResourcesBuy objectAtIndex:row] : 
			[pickerResourcesSell objectAtIndex:row];
		return item.typeName;
	}else{
		return [(NSNumber*)[qtyArray objectAtIndex:row] stringValue];
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	if(actionSeg.selectedSegmentIndex == 1 && component == 0){
		[self rebuildQtyArray:[(Item*) [pickerResourcesSell objectAtIndex:row] qty]];
		[resourcePicker reloadComponent:1];
	}
}

- (IBAction) didSelectToolbarButton:(id)sender{
	UIBarButtonItem* button = (UIBarButtonItem*) sender;
	switch (button.tag) {
		case 0:
			[delegate didDismissView];
			break;
		case 1:
			if([priceFld.text intValue] <= 0){
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
					message:@"Please enter a price." delegate:self 
					cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
				[alert show]; 
				[alert release];
				return; 
			}
			[self rewriteData];
			[delegate didCreateNewOffer:newOffer];
			break;
		default:
			break;
	}
}

- (void) rewriteData{
	
	Item* moneyItem = [Item new];
	moneyItem.typeId = 1;
	moneyItem.typeName = @"$";
	moneyItem.qty = [priceFld.text intValue];
	
	if(actionSeg.selectedSegmentIndex == 0){
		[newOffer setWantItemWithCopyOfItem: (Item*) [pickerResourcesBuy 
			objectAtIndex:[resourcePicker selectedRowInComponent:0]]];
		[newOffer setHaveItemWithCopyOfItem:moneyItem]; 
	}else{
		[newOffer setHaveItemWithCopyOfItem: (Item*) [pickerResourcesSell objectAtIndex:
			[resourcePicker selectedRowInComponent:0]]];
		[newOffer setWantItemWithCopyOfItem: moneyItem]; 
	}
	[moneyItem release]; 

	if(actionSeg.selectedSegmentIndex == 0)
		newOffer.wantItem.qty = [(NSNumber*)[qtyArray objectAtIndex:
			[resourcePicker selectedRowInComponent:1]] intValue];
	else
		newOffer.haveItem.qty = [(NSNumber*)[qtyArray objectAtIndex:
			[resourcePicker selectedRowInComponent:1]] intValue];
	
	newOffer.unfulfilled = 1;
}


- (IBAction) actionDidChange{
	[self rebuildQtyArray: (actionSeg.selectedSegmentIndex == 0 ?
        lotData.itemLimit :
        [(Item*) [pickerResourcesSell objectAtIndex:0] qty] )];
	[resourcePicker reloadComponent:0];
	[resourcePicker reloadComponent:1];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
	if(component == 0)
		return 195;
	else 
		return 100;
}

- (void) rebuildQtyArray:(int)maxQty{
    int i=0;
    self.qtyArray = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
    while(i<qtyArraySource.count && 
    [(NSNumber*)[qtyArraySource objectAtIndex:i] intValue] < maxQty){
        Item* item = [qtyArraySource objectAtIndex:i];
        [qtyArray insertObject:item atIndex:qtyArray.count];
        i++;
    }
    [qtyArray insertObject:[NSNumber numberWithInt:maxQty] atIndex:qtyArray.count];
	

}

- (IBAction) hideKeyboard{
	[priceFld resignFirstResponder];
}


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
	
	[newOffer release];
	[lotData release];
	[lotDev release];
	[actionSeg release];
	[resourcePicker release];
	[priceFld release];
	[qtyArray release];
	[qtyArraySource release];
	[pickerResourcesBuy release];
	[pickerResourcesSell release];
	
    [super dealloc];
}


@end
