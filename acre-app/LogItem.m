//
//  HistoryItem.m
//  Acre
//
//  Created by Justin Armstrong on 11/15/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "LogItem.h"


@implementation LogItem
@synthesize description, userid, itemTypeId, lotId, offerId, notes, timestamp, userScreenName;

- (void) dealloc{
	[description release];
	[notes release];
	[timestamp release];
	[userScreenName release];
	[super dealloc];
}
@end
