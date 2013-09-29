//
//  Lot.h
//  Acre
//
//  Created by Justin Armstrong on 10/28/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "DAOBase.h"
#import "Item.h"
#import "Offer.h"
#import "LogItem.h"
#import "LotLattice.h"
@class PListModel;


@interface Lot : DAOBase <MKReverseGeocoderDelegate> {
	//identity and location
	long int dbId;
	long int parentLotId;
	
	int ci;
	int cj;
	
	NSString* locationName;
	
	//ownership and state
	NSString* name;
	int ownerId;
	NSString* ownerName;
	int devTypeId;
	NSString* devTypeName;
	NSString* devTypeType;
	NSString* image;
	int rentBid;
	
	//actions
	NSMutableArray* offers;
	
	//private owner info
	int rentPrice;
	int itemLimit;
	int offerLimit;
	NSDate* rentDue;
	NSDate* timerStarted;
	
	NSMutableArray* lotHistory;
	
	NSMutableArray* itemsPresent;
    PListModel* model;
	
	//MKReverseGeocoder* reverseGeoCoder;
}

@property (nonatomic) long int dbId;
@property (nonatomic) long int parentLotId;
@property (nonatomic) int ci;
@property (nonatomic) int cj;
@property (nonatomic,retain) NSString* locationName;
@property (nonatomic,retain) NSString* name;
@property (nonatomic) int ownerId;
@property (nonatomic,retain) NSString* ownerName;
@property (nonatomic) int devTypeId;
@property (nonatomic,retain) NSString* devTypeName;
@property (nonatomic,retain) NSString* devTypeType;
@property (nonatomic) int itemLimit;
@property (nonatomic) int offerLimit;
@property (nonatomic,retain) NSString* image;
@property (nonatomic) int rentBid;
@property (nonatomic,retain) NSMutableArray* offers;
@property (nonatomic) int rentPrice;
@property (nonatomic,retain) NSDate* rentDue;
@property (nonatomic,retain) NSDate* timerStarted;
@property (nonatomic,retain) NSMutableArray* lotHistory;
@property (nonatomic,retain) NSMutableArray* itemsPresent;
@property (nonatomic, readonly) NSDictionary* serverParams;

- (void) lookupCity;
- (void) saveCityToServer;
- (int) qtyOfItemType:(int)itemType;

//- (void) calcGridFromLat:(double)lat andLon:(double)lon;


//- (void) calcBorders;

//service getLotsNearCoord(lon,lat):lotList
//client for each lot i,j calcBorders

@end
