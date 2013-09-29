//
//  SessionInfo.h
//  Acre
//
//  Created by Justin Armstrong on 11/2/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "User.h"
#import "Dev.h"
#import "PListModel.h"
#import "Reachability.h"

@class Item;


@interface Datastore : NSObject {
	//BOOL hasNetwork;
	

	User* currentSession;
	NSMutableArray* allDevelopments;
	NSMutableDictionary* allItems;
	NSMutableArray* carriedItems;
	int carryLimit;
    
    NSDate* lastServerActivity;
    
    Reachability* hostReach;
}

//@property (nonatomic) BOOL hasNetwork;

@property (nonatomic, retain) User* currentSession;
@property (nonatomic, retain) NSMutableArray* allDevelopments;
@property (nonatomic, readonly) NSMutableDictionary* allItems;
@property (nonatomic, retain) NSMutableArray* carriedItems;
@property (nonatomic) int carryLimit;
@property (nonatomic, retain) NSDate* lastServerActivity;

@property (nonatomic, readonly) Item* moneyItem;
@property (nonatomic, readonly) Reachability* hostReach;

+ (Datastore*) getInst;

+ (NSString*) getBaseURLStr;
//+ (NSString*) getVersionStr;

+ (UIImage*) imageForItemWithId:(int)dbId;
+ (UIImage*) imageFromBundle:(NSString*)name;
+ (UIImage*) imageForDevWithId:(int)devTypeId;
+ (void) updateServerActivityTime;

- (int) qtyOfItemWithId:(int)typeId;
- (Item*) moneyItem;
- (void) setAllItemsWithArray:(NSArray*)input;
- (BOOL) saveImageFromURL:(NSString*)urlStr as:(NSString*)fileName;

- (void) loadSavedSession;
- (void) saveSession;
- (NSString*) savedSessionPath;
@end



