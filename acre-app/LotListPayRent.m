//
//  LotListPayRent.m
//  Acre
//
//  Created by Justin Armstrong on 12/19/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "LotListPayRent.h"


@implementation LotListPayRent
@synthesize payButton, dueLab, valueLab, nameLab, 
	detailLab, hasOutstandingCall, spinner;

- (void) setLotData:(Lot*)input {
	[lotData autorelease];
	lotData = [input retain];
    nameLab.text = lotData.name;
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
    }else{
        payButton.enabled = YES;
        payButton.alpha = 1.0;
    }
    if (ti < 0) 
        dueLab.textColor = [UIColor redColor];
    else
        dueLab.textColor = [UIColor blackColor];
    [dateFormatter release];
	detailLab.text = input.locationName ?
			[NSString stringWithFormat:@"%@ in %@",input.devTypeName,input.locationName] : 
			input.devTypeName;

}

- (Lot*) lotData{
	return lotData;
}

- (NSString*) reuseIdentifier{
	return hasOutstandingCall ? @"dontUse" : @"payCell";
}

- (IBAction) payRent{
	hasOutstandingCall = YES;
	if(!model)
		model = [PListModel new];
	NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSString stringWithFormat:@"%d", lotData.ci],@"ci",
		[NSString stringWithFormat:@"%d", lotData.cj],@"cj",nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(payRentDidRespond:) 
			name:@"serverDidRespond" object:model];
	
	[model callFunction:@"payUpkeep" withParams:params];
	[params release];
	payButton.enabled = NO;
	payButton.alpha = 0;
	spinner.alpha = 1.0;
	[spinner startAnimating];
}

- (void) payRentDidRespond:(NSNotification*)notification{
	hasOutstandingCall = NO;
	payButton.alpha = 1.0;
	spinner.alpha = 0;
	payButton.enabled = YES;
	[spinner stopAnimating];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	ServerResponse* response = [[notification object] lastResponse];
	if(response.success){
		NSDate* newRentDueDate = [response.resultObject valueForKey:@"newDueDate"];
		if(newRentDueDate)
			lotData.rentDue = newRentDueDate;
		self.lotData = lotData;
	}else{
		NSString* msg = [NSString stringWithFormat:@"Transaction didn't go through. Error id: %d : %@",
			response.errorId, response.errorMessage];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
			message:msg delegate:self 
			cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
		[alert show]; 
		[alert release];
	}

}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[payButton release];
	[dueLab release];
	[valueLab release];
	[lotData release];
	
	[detailLab release];
	[nameLab release];
	[spinner release];
	
	[model release];
    [super dealloc];
}


@end
