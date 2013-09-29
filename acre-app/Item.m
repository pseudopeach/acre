//
//  Item.m
//  Acre
//
//  Created by Justin Armstrong on 11/3/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "Item.h"


@implementation Item

@synthesize dbId, typeId, typeName, qty, image, actionGroup;

- (Item*) initWithTypeId:(int)tid andQty:(int)qt{
	if(self = [super init]){
		self.typeId = tid;
		self.qty = qt;
	}
	return self;
}

- (void) lookupItemInfo{
	if(typeName) return;
	//NSDictionary* debugD = [[Datastore getInst].allItems objectForKey:[NSString stringWithFormat:@"%d",typeId]];
	[self setValuesForKeysWithDictionary: (NSDictionary*)
		[[Datastore getInst].allItems objectForKey:
		[NSString stringWithFormat:@"%d",typeId]]];
}

- (NSString*) description {
	return [NSString stringWithFormat:@"%d,%d",typeId,qty];
}


- (void) dealloc{
	[typeName release];
	[image release];
	[super dealloc];
}

@end
