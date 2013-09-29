//
//  ItemSlider.m
//  Acre
//
//  Created by Justin Armstrong on 11/28/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "ItemSlider.h"


@implementation ItemSlider
@synthesize minValue, maxValue, carriedItem, lotItem, lotData, slider, carryCountLab, lotCountLab, 
	resourceTypeNameLab,resourceImage, delegate; //

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

- (void) setItemInfo:(NSMutableDictionary*)input{
	[itemInfo autorelease];
	itemInfo = [input retain];
	self.carriedItem = [itemInfo objectForKey:LotItemDictKeyCarried];
	self.lotItem = [itemInfo objectForKey:LotItemDictKeyLot];
	thisIndex = [(NSNumber*) [itemInfo objectForKey:LotItemDictKeyIndex] intValue]; 
	minValue = [(NSNumber*) [itemInfo objectForKey:LotItemDictKeyMinValue] intValue];
	maxValue = [(NSNumber*) [itemInfo objectForKey:LotItemDictKeyMaxValue] intValue];
	sum = carriedItem.qty + lotItem.qty;
	slider.maximumValue = sum;
	slider.value = lotItem.qty;
	Item* itemThatExists = carriedItem ? carriedItem : lotItem;
	[itemThatExists lookupItemInfo];
	resourceTypeNameLab.text = itemThatExists.typeName;
	resourceImage.image = [Datastore imageForItemWithId:itemThatExists.typeId];
	
	//NSLog(@"set %@ slider sum to %d", itemThatExists.typeName, sum);
	[self updateLabels];
}
- (NSMutableDictionary*) itemInfo{
	/*NSMutableDictionary* result = [[[NSDictionary alloc] initWithObjectsAndKeys:
		carriedItem, LotItemDictKeyCarried, lotItem, LotItemDictKeyLot,nil] autorelease];*/
    return itemInfo;
	//return result;
}


- (IBAction) didSlide{
	if(slider.value > maxValue)
		slider.value = maxValue;
	if(slider.value < minValue)
		slider.value = minValue;
		
	qtyInLot = round(slider.value);
	
	if(!carriedItem){
		self.carriedItem = [[Item alloc] initWithTypeId:lotItem.typeId andQty:0];
		[itemInfo setObject:carriedItem forKey:LotItemDictKeyCarried];
		//insert new item into DS carried items
		[[Datastore getInst].carriedItems insertObject:carriedItem atIndex:[Datastore getInst].carriedItems.count];
		NSLog(@"created carried item object");
	}else if(!lotItem){
		self.lotItem = [[Item alloc] initWithTypeId:carriedItem.typeId andQty:0];
		[itemInfo setObject:lotItem forKey:LotItemDictKeyLot];
		//insert the new item into the lot object
		[lotData.itemsPresent insertObject:lotItem atIndex:lotData.itemsPresent.count];
		NSLog(@"created lot item object");
	}
			
	lotItem.qty = qtyInLot;
	carriedItem.qty = sum - qtyInLot;
	
	[self updateLabels];
	
	[delegate sliderValueDidChange:thisIndex toValue:qtyInLot];
	
}

-(IBAction) didEndSlide{
	qtyInLot = round(slider.value);
	slider.value = qtyInLot; //round off to int
	[delegate sliderDidEndSliding:thisIndex atValue:qtyInLot];
}

- (void) updateLabels{
	carryCountLab.text = [NSString stringWithFormat:@"%d", carriedItem.qty];
	lotCountLab.text = [NSString stringWithFormat:@"%d", lotItem.qty];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	
	[carriedItem release];
	[lotItem release];
	[lotData release];
	[itemInfo release];
	[slider release];
	[carryCountLab release];
	[lotCountLab release];
	[resourceTypeNameLab release];
	[resourceImage release];
    [super dealloc];
}


@end
