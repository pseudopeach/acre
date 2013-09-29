//
//  LotEditPayRent.m
//  Acre
//
//  Created by Justin Armstrong on 11/19/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "LotEditPayRent.h"


@implementation LotEditPayRent
@synthesize rentValueLab, rentDueLab, payButton;

- (void) setLotData:(Lot*)input {
	[lotData autorelease];
	lotData = [input retain];
	rentValueLab.text = [NSString stringWithFormat:@"$%d",lotData.rentPrice];
		NSDateFormatter* dateFormatter = [NSDateFormatter new];
			[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		rentDueLab.text = [NSString stringWithFormat:@"Due %@",
			[dateFormatter stringFromDate:lotData.rentDue]];
		NSDate* now = [NSDate dateWithTimeIntervalSinceNow:0];
		double ti = [lotData.rentDue timeIntervalSinceDate:now];//1d = 86400s
		if(ti > 604800 || [Datastore getInst].moneyItem.qty < lotData.rentPrice){//due date more than a week away or can't afford
			payButton.enabled = NO;
			payButton.alpha = .4;
		}else if (ti < 0) 
			rentDueLab.textColor = [UIColor redColor];
    [dateFormatter release];
}

- (Lot*) lotData{
	return lotData;
}

- (void)dealloc {
	[payButton release];
	[rentDueLab release];
	[rentValueLab release];
	[lotData release];
    [super dealloc];
}


@end
