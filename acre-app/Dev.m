//
//  Dev.m
//  Acre
//
//  Created by Justin Armstrong on 11/3/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "Dev.h"
#import "Lot.h"

@implementation Dev
@synthesize dbId, typeName, name, description, image;

- (void) setAbilities:(NSMutableArray*)inputArg{
	[abilities autorelease];
	abilities = [[NSMutableArray alloc] initWithCapacity:inputArg.count];
	
	//loop through the array, creating an Item for for each object in the array
	for(int i=0;i<inputArg.count;i++){
		NSString* item = [inputArg objectAtIndex:i];
		[abilities insertObject:item atIndex:i];
		[item release];
	}
}

- (BOOL) canBuildOnLot:(Lot*)lot{
	for(int i=0;i<cost.count;i++){
		Item* thisCost = [cost objectAtIndex:i];
        int qtyAvailable = [[Datastore getInst] qtyOfItemWithId:thisCost.typeId];
        if(lot){
            qtyAvailable += [lot qtyOfItemType:thisCost.typeId];
        }
		if(qtyAvailable < thisCost.qty)
			return NO;
	}
	return YES;
}

- (NSMutableArray*) abilities{
	return abilities;
}
- (void) setCost:(NSMutableArray*)inputArg{
	[cost autorelease];
	cost = [[NSMutableArray alloc] initWithCapacity:inputArg.count];
	
	//loop through the array, creating an Item for for each object in the array
	for(int i=0;i<inputArg.count;i++){
		
		if(![[inputArg objectAtIndex:i] isMemberOfClass:[Item class]] && NO)
			[cost insertObject:[inputArg objectAtIndex:i] atIndex:i];
		else{
			Item* item = [Item new];
			[item setValuesForKeysWithDictionary:(NSDictionary*)[inputArg objectAtIndex:i]]; 
			[cost insertObject:item atIndex:i];
			[item release];
		}
	}
}
- (NSMutableArray*) cost{
	return cost;
}
- (void) setInput:(NSMutableArray*)inputArg{
	[input autorelease];
	input = [[NSMutableArray alloc] initWithCapacity:input.count];
	
	//loop through the array, creating an Item for for each object in the array
	for(int i=0;i<inputArg.count;i++){
		
		if(![[inputArg objectAtIndex:i] isMemberOfClass:[Item class]] && NO)
			[input insertObject:[input objectAtIndex:i] atIndex:i];
		else{
			Item* item = [Item new];
			[item setValuesForKeysWithDictionary:(NSDictionary*)[inputArg objectAtIndex:i]]; 
			[input insertObject:item atIndex:i];
			[item release];
		}
	}
}
- (NSMutableArray*) input{
	return input;
}

- (void) setOutput:(NSMutableArray*)inputArg{
	[output autorelease];
	output = [[NSMutableArray alloc] initWithCapacity:inputArg.count];
	
	//loop through the array, creating an Item for for each object in the array
	for(int i=0;i<inputArg.count;i++){
		if(![[inputArg objectAtIndex:i] isMemberOfClass:[Item class]] && NO)
			[output insertObject:[input objectAtIndex:i] atIndex:i];
		else{
			Item* item = [Item new];
			[item setValuesForKeysWithDictionary:(NSDictionary*)[inputArg objectAtIndex:i]]; 
			[output insertObject:item atIndex:i];
			[item release];
		}
	}
}
- (NSMutableArray*) output{
	return output;
}


-(void) dealloc{
	[typeName release];
	[name release];
	[description release];
	[image release];
	[cost release]; 
	[input release]; 
	[output release];
	[abilities release];
	[super dealloc];
}

@end
