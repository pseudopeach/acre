//
//  Offer.h
//  Acre
//
//  Created by Justin Armstrong on 10/28/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAOBase.h"
@class Item;

@interface Offer : DAOBase {
	long int dbId;
	
	Item* haveItem;
	Item* wantItem;
	
	NSDate* effective;
	NSDate* expires;
	int unfulfilled;
}

@property (nonatomic) long int dbId;

@property (nonatomic,retain) Item* haveItem;
@property (nonatomic,retain) Item* wantItem;

@property (nonatomic,retain) NSDate* effective;
@property (nonatomic,retain) NSDate* expires;
@property (nonatomic) int unfulfilled;

@property (nonatomic, readonly) BOOL isBuy;
@property (nonatomic, readonly) BOOL isSell;
@property (nonatomic, readonly) BOOL isLandBid;

- (void) setWantItemWithCopyOfItem:(Item*)input;
- (void) setHaveItemWithCopyOfItem:(Item*)input;


@end
