//
//  Lot.m
//  Acre
//
//  Created by Justin Armstrong on 10/28/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "Lot.h"
#import "PListModel.h"

@implementation Lot

@synthesize dbId, parentLotId, ci, cj, locationName,
name, ownerId, ownerName, 
devTypeId, devTypeName, devTypeType, itemLimit, offerLimit,
image, rentBid, rentPrice, rentDue, timerStarted;

- (void) setOffers:(NSMutableArray*)input{
	[offers autorelease];
	offers = [[NSMutableArray alloc] initWithCapacity:input.count];
	
	//loop through the array, creating an Item for for each object in the array
	for(int i=0;i<input.count;i++){
		
		if(![[input objectAtIndex:i] isMemberOfClass:[Offer class]] && NO)
			[offers insertObject:[input objectAtIndex:i] atIndex:i];
		else{
			Offer* item = [Offer new];
			[item setValuesForKeysWithDictionary:(NSDictionary*)[input objectAtIndex:i]]; 
			[offers insertObject:item atIndex:i];
			[item release];
		}
	}
}
- (NSMutableArray*) offers{
	return offers;
}
- (void) setItemsPresent:(NSMutableArray*)input{
	[itemsPresent autorelease];
	itemsPresent = [[NSMutableArray alloc] initWithCapacity:input.count];

	//loop through the array, creating an Item for for each object in the array
	for(int i=0;i<input.count;i++){
		
		if(![[input objectAtIndex:i] isMemberOfClass:[Item class]] && NO)
			[itemsPresent insertObject:[input objectAtIndex:i] atIndex:i];
		else{
			Item* item = [Item new];
			[item setValuesForKeysWithDictionary:(NSDictionary*)[input objectAtIndex:i]]; 
			[itemsPresent insertObject:item atIndex:i];
			[item release];
		}
	}
}
- (NSMutableArray*) itemsPresent{
	return itemsPresent;
}

- (void) setLotHistory:(NSMutableArray*)input{
	[lotHistory autorelease];
	lotHistory = [[NSMutableArray alloc] initWithCapacity:input.count];
	
	//loop through the array, creating an Item for for each object in the array
	for(int i=0;i<input.count;i++){
		
		if(![[input objectAtIndex:i] isMemberOfClass:[LogItem class]] && NO)
			[lotHistory insertObject:[input objectAtIndex:i] atIndex:i];
		else{
			LogItem* item = [LogItem new];
			[item setValuesForKeysWithDictionary:(NSDictionary*)[input objectAtIndex:i]]; 
			[lotHistory insertObject:item atIndex:i];
			[item release];
		}
	}
}
- (NSMutableArray*) lotHistory{
	return lotHistory;
}

- (NSDictionary*) serverParams{
	//Ci, Cj, devTypeId,name,
	//offerList(offerId(new=0),itemHave_typeId, itemHave_qty, itemWant_typeId, itemWant_qty;...),
	//itemQtyList(typeId,qty;typeId,qty;...)
	NSString* itemQtyList = [itemsPresent componentsJoinedByString:@";"];
	NSString* offerList = [offers componentsJoinedByString:@";"];
    
	NSDictionary* result = (dbId == 0) ?
    
        [[NSDictionary alloc] initWithObjectsAndKeys:
         [NSString stringWithFormat:@"%d",ci],@"ci",
         [NSString stringWithFormat:@"%d",cj],@"cj",
         itemQtyList,@"itemQtyList",nil]    :
        
        [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",ci],@"ci",
            [NSString stringWithFormat:@"%d",cj],@"cj",
            [NSString stringWithFormat:@"%d",devTypeId],@"devTypeId",
            name,@"name",locationName,@"locationName",
            itemQtyList,@"itemQtyList",
            offerList,@"offerList",nil];
	return [result autorelease];
}

- (void) lookupCity{
	MKReverseGeocoder* reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:
		[LotLattice locationOfCi:ci Cj:cj]];
	reverseGeocoder.delegate = self;
	NSLog(@"starting geocoder with %f %f",reverseGeocoder.coordinate.latitude, reverseGeocoder.coordinate.longitude);
	[reverseGeocoder start];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark{
	self.locationName = placemark.locality ? placemark.locality : @"~";
	[geocoder release];
	NSLog(@"city is %@",locationName);
	[self saveCityToServer];
}

- (void) reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error{
	self.locationName = @"~";
	[geocoder release];
	NSLog(@"no city. error is %@",[error localizedDescription]);
	[self saveCityToServer];
}

- (void) saveCityToServer{
	if(!model)
		model = [PListModel new];
	NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSString stringWithFormat:@"%d",ci], @"ci", 
		[NSString stringWithFormat:@"%d",cj], @"cj", 
		locationName, @"locationName",nil];
	[model callFunction:@"saveLotCity" withParams:params];
	[params release];
}

- (int) qtyOfItemType:(int)itemType{
    int i = 0;
    Item* item = nil;
    while(i<itemsPresent.count && [(item=[itemsPresent objectAtIndex:i]) typeId] != itemType)
        i++;
    return item ? item.qty : 0;
}

-(void) dealloc{
	[name release];
	[locationName release];
	[ownerName release];
	[devTypeName release];
	[devTypeType release];
	[image release];
	[offers release];
	[rentDue release];
	[timerStarted release];
	[itemsPresent release];
	[lotHistory release];
	
	[model release];
	[super dealloc];
}

@end
