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
@synthesize currentSession, carryLimit, lastServerActivity;

+ (void) initialize{
	inst = [self new];
	//inst.currentSession = [User new];
	//inst.acreReachability = [Reachability reachabilityWithHostName:[Datastore getBaseURLStr]]; //[PListModel getBaseURLStr]
}

+ (Datastore*) getInst{
	return inst;
}

+ (NSString*) getBaseURLStr {
    #if TARGET_IPHONE_SIMULATOR
       return @"http://127.0.0.1:8500/acre-services"; 
        /*return @"http://actinicapps.com/acre-services";*/
    #else
        return @"http://actinicapps.com/acre-services";
    #endif	
}

//+ (NSString*) getVersionStr {return @"0.8";}

+ (void) updateServerActivityTime{
    inst.lastServerActivity = [NSDate dateWithTimeIntervalSinceNow:0];
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

- (void) setCarriedItems:(NSMutableArray *)input{
	[carriedItems autorelease];
	carriedItems = [[NSMutableArray alloc] initWithCapacity:input.count];
	for(int i=0;i<input.count;i++){
		id thisObject = [input objectAtIndex:i];
		if([thisObject isKindOfClass:[Item class]]){
            NSLog(@"object is already of type Item");
            [carriedItems insertObject:thisObject atIndex:i];
		}else{
            Item* item = [Item new];
			[item setValuesForKeysWithDictionary:(NSDictionary*)thisObject];
            [carriedItems insertObject:item atIndex:i];
            [item release];
		}
	}
}
- (NSMutableArray*) carriedItems{
	return carriedItems;
}

- (void) setAllDevelopments:(NSMutableArray *)input{
	[allDevelopments autorelease];
	allDevelopments = [[NSMutableArray alloc] initWithCapacity:input.count];
	for(int i=0;i<input.count;i++){
		id thisObject = [input objectAtIndex:i];
		if([thisObject isKindOfClass:[Dev class]])
			[allDevelopments insertObject:thisObject atIndex:i];
		else{
            Dev* dev = [Dev new];
			[dev setValuesForKeysWithDictionary:(NSDictionary*)thisObject];
            [allDevelopments insertObject:dev atIndex:i];
            [dev release];
		}
		
	}
}
- (NSMutableArray*) allDevelopments{
	return allDevelopments;
}

- (void) setAllItemsWithArray:(NSArray*)input{
	[allItems autorelease];
	allItems = [[NSMutableDictionary alloc] initWithCapacity:input.count];
	for(int i=0;i<input.count;i++){
		NSDictionary* dict = [input objectAtIndex:i];
		int thisTypeId = [(NSNumber*) [dict valueForKey:@"typeId"] intValue];
		[allItems setObject:dict forKey:
			[NSString stringWithFormat:@"%d", thisTypeId]];
		NSString* imageName = [dict valueForKey:@"image"];
		if(![UIImage imageNamed:imageName] && ![Datastore imageFromBundle:imageName])
			[self saveImageFromURL:
				[NSString stringWithFormat:@"%@/resourceImages/%@",
					[Datastore getBaseURLStr],imageName]
				as:imageName];
	}
}


- (NSDictionary*) allItems{
	return allItems;
}
	

+ (UIImage*) imageForItemWithId:(int)typeId{
	NSDictionary* itemObj = [inst.allItems objectForKey:[NSString stringWithFormat:@"%d",typeId]];
	if(!itemObj)
		return nil;
	//NSLog(@"looked up image named: %@",[itemObj objectForKey:@"image"]);
	NSString* imageName = [itemObj objectForKey:@"image"];
	UIImage* image = [UIImage imageNamed:[itemObj objectForKey:@"image"]];
	if(!image)
		image = [Datastore imageFromBundle:imageName];
	
	return image;
}
+ (UIImage*) imageFromBundle:(NSString*)name{
	NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) 
		objectAtIndex:0];
	filePath = [filePath stringByAppendingPathComponent:name];
	return [UIImage imageWithContentsOfFile:filePath];
}

+ (UIImage*) imageForDevWithId:(int)devTypeId{
	int i = 0;
	while(i<inst.allDevelopments.count && [(Dev*)[inst.allDevelopments objectAtIndex:i] dbId] != devTypeId)
		i++;
	if(i >= inst.allDevelopments.count)
		return nil;
		
	Dev* dev = [inst.allDevelopments objectAtIndex:i];
	return [UIImage imageNamed:[NSString stringWithFormat:@"dev_%@.png",dev.typeName]];
}


- (void) loadSavedSession{
	NSString* filePath = [self savedSessionPath];
    User* aSession = [User new];
	self.currentSession = aSession;
    [aSession release];
	if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
		NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
		[currentSession setValuesForKeysWithDictionary:dict];
		[dict release];
	}else NSLog(@"couldn't find saved login info");
}

- (void) saveSession{
	NSString* filePath = [self savedSessionPath];
	NSDictionary* savableUserData = [[NSDictionary alloc] initWithObjectsAndKeys:
		currentSession.screenName,@"screenName",
		currentSession.password,@"password", nil];
	[savableUserData writeToFile:filePath atomically:YES];
	[savableUserData release];
}

- (NSString*) savedSessionPath{
	NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) 
		objectAtIndex:0];
	return [filePath stringByAppendingPathComponent:@"lastSession.plist"];
}

- (BOOL) saveImageFromURL:(NSString*)urlStr as:(NSString*)fileName{
	/*UIImage* image = [[UIImage alloc]initWithData:
		[NSData dataWithContentsOfURL:
			[NSURL URLWithString:urlStr]]];*/
	NSLog(@"saving image %@",fileName);
	NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
	if(!imageData){ NSLog(@"failed to downloadImage"); return NO;}
	NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) 
		objectAtIndex:0];
	filePath = [filePath stringByAppendingPathComponent:fileName];
	return [imageData writeToFile:filePath atomically:YES];
}
- (Reachability*) hostReach{
    if(!hostReach)
        hostReach = [[Reachability reachabilityWithHostName:@"actinicapps.com"] retain];
    return hostReach;
}

- (void) dealloc{
	[currentSession release];
	[allDevelopments release];
	[allItems release];
	[carriedItems release];
    [lastServerActivity release];
    
    [hostReach release];
	[super dealloc];
}

@end
