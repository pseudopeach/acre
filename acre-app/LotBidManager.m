//
//  LotBidManager.m
//  Acre
//
//  Created by Justin Armstrong on 12/7/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "LotBidManager.h"


@implementation LotBidManager
@synthesize  lotNameLab, lotImage, bidPriceFld, currentBidLab, 
	highBidLab, lotData, cancelBtn, delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
	lotNameLab.text = lotData.name;
	[self updateLabels];
	
	bidService = [PListModel new];
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(setBidDidRespond:) 
			name:@"serverDidRespond" object:bidService];
}


- (IBAction) updateBid{
	int p = [bidPriceFld.text intValue];
	[self hideKeyboard];
	if(p <= 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
			message:@"Please enter a bid." delegate:self 
			cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
		[alert show]; 
		[alert release];
		return; 
	}
	//lotData.rentPrice = p;
	NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSString stringWithFormat:@"%d",lotData.ci],@"ci",
		[NSString stringWithFormat:@"%d",lotData.cj],@"cj",
		[NSString stringWithFormat:@"%d",p], @"bid",
		
	nil];
	[ActivityView presentFrom:self withMessage:@"processing..." cancelable:NO];
	[bidService callFunction:@"setLotBid" withParams:params];
	[params release];
}
/*- (void) serverDidRespond:(ServerResponse*)response{
	if(response.success)
		[self.navigationController popViewControllerAnimated:YES];
	[self updateLabels];
}*/
- (IBAction) cancelBid{
	NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSString stringWithFormat:@"%d",lotData.ci],@"ci",
		[NSString stringWithFormat:@"%d",lotData.cj],@"cj",
		@"0",@"bid",nil];
	[ActivityView presentFrom:self withMessage:@"processing..." cancelable:NO];
	[bidService callFunction:@"setLotBid" withParams:params];
	[params release];
}
- (IBAction) hideKeyboard{
	[bidPriceFld resignFirstResponder];
}

- (void) updateLabels{
	if(lotData.rentPrice == 0){//interpreted as your bid
		currentBidLab.text = @" - ";
		cancelBtn.enabled = NO;
		cancelBtn.alpha = .5;
	}else{
		currentBidLab.text = [NSString stringWithFormat:@"$%d",lotData.rentPrice];
		cancelBtn.enabled = YES;
		cancelBtn.alpha = 1.0;
	}
		
	highBidLab.text = (lotData.rentBid == 15) ? 
		@"Opening bid: $16" : [NSString stringWithFormat:@"High Bid: $%d",lotData.rentBid];
}

- (void) setBidDidRespond:(NSNotification*)notification{
	[ActivityView removeSelf];
	ServerResponse* response = [[notification object] lastResponse];
	if(response.success){
		int newBid = [[response.resultObject valueForKey:@"newBid"] intValue];
		lotData.rentPrice = newBid;
		if(newBid != 0)
			lotData.rentBid = newBid;
		[self updateLabels];
        [delegate didUpdateBid];
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
	[lotData release];
	[lotNameLab release];
	[lotImage release];
	[bidPriceFld release];
	[currentBidLab release];
	[highBidLab release];
	[cancelBtn release];
	
	[bidService release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}


@end
