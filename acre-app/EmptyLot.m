//
//  EmptyLot.m
//  Acre
//
//  Created by Justin Armstrong on 2/13/11.
//  Copyright 2011 Actinic inc. All rights reserved.
//

#import "EmptyLot.h"


@implementation EmptyLot
@synthesize rentPriceLab, claimButton, lotData, lotNameFld, NSFLab;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//model = [PListModel new];
	lotNameFld.text = [NSString stringWithFormat:@"%@'s Garden",
		[Datastore getInst].currentSession.screenName];
	[lotNameFld addTarget:self action:@selector(hideKeyboard) 
			forControlEvents:UIControlEventEditingDidEndOnExit|UIControlEventTouchUpOutside];
	if([Datastore getInst].moneyItem.qty < 15)
		[self disableClaim];
}

- (void) save{
	if([lotNameFld.text isEqualToString:@""]){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
			message:@"Please enter a name." delegate:self 
			cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
		[alert show]; 
		[alert release];
		return; 
	}
	claimed = YES;
	[super save];
	
	NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSString stringWithFormat:@"%d", lotData.ci],@"ci",
		[NSString stringWithFormat:@"%d", lotData.cj],@"cj",
		lotNameFld.text,@"name",nil];
	[model callFunction:@"payUpkeep" withParams:params];
	[params release];
}

- (void) saveDidSucceed{
	lotData.ownerId = [Datastore getInst].currentSession.dbId;
	lotData.devTypeId = 1; //**** can change later using save response?
	[delegate remapLot:lotData];
	//[delegate requeryLot:lotData];
	[delegate dismissLotView];
}

- (IBAction) hideKeyboard{
	[lotNameFld resignFirstResponder];
}

-(void) disableClaim{
	claimButton.enabled = NO;
	claimButton.alpha = 0.5;
	NSFLab.alpha = 1;
}

- (void)dealloc {
	[lotData release];
	[claimButton release];
	[rentPriceLab release];
	[lotNameFld release];
	[NSFLab release];

    [super dealloc];
}


@end
