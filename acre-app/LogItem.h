//
//  HistoryItem.h
//  Acre
//
//  Created by Justin Armstrong on 11/15/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAOBase.h"

@interface LogItem : DAOBase {
	NSString* description;
	int userid;
	int itemTypeId;
	long int lotId;
	long int offerId;
	NSString* notes;
	NSString* userScreenName;
	NSDate* timestamp;
}

@property (nonatomic, retain) NSString* description;
@property (nonatomic) int userid;
@property (nonatomic) int itemTypeId;
@property (nonatomic) long int lotId;
@property (nonatomic) long int offerId;
@property (nonatomic, retain) NSString* notes;
@property (nonatomic, retain) NSString* userScreenName;
@property (nonatomic, retain) NSDate* timestamp;

@end
