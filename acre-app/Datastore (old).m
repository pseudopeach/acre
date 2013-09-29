//
//  SessionInfo.m
//  Acre
//
//  Created by Justin Armstrong on 11/2/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "Datastore.h"

static Datastore* inst;

@implementation Datastore
@synthesize currentSession, allDevelopments, allItems, carryLimit, carriedItems;

+ (void) initialize{
	inst = [self new];
	inst.currentSession = [User new];
	inst.currentSession.screenName = @"PseudoPeach";
	inst.currentSession.dbId = 1;
	
	NSString* errorMessage;
	NSPropertyListFormat format;
	NSString* filePath = [[NSBundle mainBundle] pathForResource:@"devList" ofType:@"plist"];
	NSData* pListXML = [[NSFileManager defaultManager] contentsAtPath:filePath];
	NSMutableArray* array = (NSMutableArray*) [NSPropertyListSerialization
		propertyListFromData:pListXML mutabilityOption:NSPropertyListImmutable
		format:&format errorDescription:&errorMessage];
	inst.allDevelopments = [[NSMutableArray alloc] initWithCapacity:array.count];
	for(int i=0;i<array.count;i++){
		Dev* newDev = [Dev new];
		[newDev setValuesForKeysWithDictionary:(NSDictionary*) [array objectAtIndex:i]];
		[inst.allDevelopments insertObject:newDev atIndex:i];
	}
	filePath = [[NSBundle mainBundle] pathForResource:@"itemList" ofType:@"plist"];
	inst.allItems = [NSDictionary dictionaryWithContentsOfFile:filePath];
	[errorMessage release];
	
	inst.carriedItems = [[NSMutableArray alloc] initWithObjects:
		[[Item alloc] initWithTypeId:1 andQty:109],
		[[Item alloc] initWithTypeId:8 andQty:3],
		[[Item alloc] initWithTypeId:11 andQty:2],nil];
	inst.carryLimit = 10;
	
}

+ (Datastore*) getInst{
	return inst;
}

- (Item*) moneyItem{
	int i = 0;
	while(i<carriedItems.count && [(Item*)[carriedItems objectAtIndex:i] typeId] != 1)
		i++;
	return (i < carriedItems.count) ? [carriedItems objectAtIndex:i] : nil;
}

- (int) qtyOfItemWithId:(int)typeId{
	int i = 0;
	while(i<carriedItems.count && [(Item*)[carriedItems objectAtIndex:i] typeId] != typeId)
		i++;
	return (i < carriedItems.count) ? [(Item*)[carriedItems objectAtIndex:i] qty] : 0;
}



+ (UIImage*) imageForItemWithId:(int)typeId{
	NSDictionary* itemObj = [inst.allItems objectForKey:[NSString stringWithFormat:@"%d",typeId]];
	if(!itemObj)
		return nil;
	//NSLog(@"looked up image named: %@",[itemObj objectForKey:@"image"]);
	return [UIImage imageNamed:[itemObj objectForKey:@"image"]];
}

- (void) loadSavedSession{
	NSString* filePath = [[NSBundle mainBundle] pathForResource:@"lastSession" ofType:@"plist"];
	currentSession = [User new];
	if(filePath){
		NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
		[currentSession setValuesForKeysWithDictionary:dict];
		[dict release];
	}
}

- (void) saveSession{
	NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) 
		objectAtIndex:0];
	filePath = [filePath stringByAppendingPathComponent:@"lastSession.plist"];
	NSDictionary* savableUserData = [[NSDictionary alloc] initWithObjectsAndKeys:
		currentSession.screenName,@"screenName",
		currentSession.password,@"password", nil];
	[savableUserData writeToFile:filePath atomically:YES];
	[savableUserData release];
}

- (void) dealloc{
	[currentSession release];
	[allDevelopments release];
	[allItems release];
	[carriedItems release];
	[super dealloc];
}

@end
