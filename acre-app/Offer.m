//
//  Offer.m
//  Acre
//
//  Created by Justin Armstrong on 10/28/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "Offer.h"
#import "Item.h"

@implementation Offer
@synthesize dbId, haveItem, wantItem, effective, expires, unfulfilled;

- (void) setHaveItem:(id)input{
	NSDictionary* dict = (NSDictionary*) input;
	[haveItem autorelease];
	if(dict){
		haveItem = [Item new];
		[haveItem setValuesForKeysWithDictionary:dict];
	}else{
		NSLog(@"passed a non dictionary to setHaveItem in Offer");
		haveItem = [input retain];
	}
}

- (void) setHaveItemWithCopyOfItem:(Item*)input{
	[haveItem autorelease];
	haveItem = [Item new];
	haveItem.qty = input.qty;
	haveItem.typeId = input.typeId;
	haveItem.typeName = input.typeName;
	haveItem.image = input.image;
	haveItem.dbId = input.dbId;
}
- (Item*) haveItem{
	return haveItem;
}

- (void) setWantItem:(id)input{
	NSDictionary* dict = (NSDictionary*) input;
	[wantItem autorelease];
	if(dict){
		wantItem = [Item new];
		[wantItem setValuesForKeysWithDictionary:dict];
	}else{
		NSLog(@"passed a non dictionary to setWantItem in Offer");
		wantItem = [input retain];
	}
}
- (void) setWantItemWithCopyOfItem:(Item*)input{
	[wantItem autorelease];
	wantItem = [Item new];
	wantItem.qty = input.qty;
	wantItem.typeId = input.typeId;
	wantItem.typeName = input.typeName;
	wantItem.image = input.image;
	wantItem.dbId = input.dbId;
}
- (Item*) wantItem{
	return wantItem;
}

- (BOOL) isBuy{return haveItem.typeId == 1;}
- (BOOL) isSell{return wantItem.typeId == 1;}
- (BOOL) isLandBid{return (wantItem.typeId == 0 && haveItem.typeId == 1);}

- (NSString*) description {
	return [NSString stringWithFormat:@"%d,%d,%d,%d,%d",dbId,haveItem.typeId, haveItem.qty, wantItem.typeId, wantItem.qty];
}

-(void) dealloc{
	[haveItem release];
	[wantItem release];
	[effective release];
	[expires release];
	[super dealloc];
}

@end
