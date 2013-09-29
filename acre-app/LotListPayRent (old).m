//
//  LotListPayRent.m
//  Acre
//
//  Created by Justin Armstrong on 12/19/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "LotListPayRent.h"


@implementation LotListPayRent
@synthesize payButton, dueLab, valueLab;

- (void) setLotData:(Lot*)input {
	[lotData autorelease];
	lotData = [input retain];
	valueLab.text = [NSString stringWithFormat:@"$%d",lotData.rentPrice];
		NSDateFormatter* dateFormatter = [NSDateFormatter new];
			[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		dueLab.text = [NSString stringWithFormat:@"Due %@",
			[dateFormatter stringFromDate:lotData.rentDue]];
		NSDate* now = [NSDate dateWithTimeIntervalSinceNow:0];
		double ti = [lotData.rentDue timeIntervalSinceDate:now];//1d = 86400s
		if(ti > 604800){//due date more than a week away
			payButton.enabled = NO;
			payButton.alpha = .4;
		}else if (ti < 0) 
			dueLab.textColor = [UIColor redColor];
    [dateFormatter release];
}

- (Lot*) lotData{
	return lotData;
}

- (IBAction) payRent{

}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (void)dealloc {
	[payButton release];
	[dueLab release];
	[valueLab release];
	[lotData release];
	
    [super dealloc];
}


@end
