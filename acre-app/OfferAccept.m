//
//  OfferAccept.m
//  Acre
//
//  Created by Justin Armstrong on 12/8/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "OfferAccept.h"


@implementation OfferAccept

@synthesize getSummaryLab, getResourceImage, giveSummaryLab, giveResourceImage, giveResourceReserveLab, acceptButton,
	offerData, delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	//i.e. you get what the offer maker has
	getSummaryLab.text = [NSString stringWithFormat:@"%d %@",offerData.haveItem.qty,offerData.haveItem.typeName];
	//and give what the offer maker wants
	giveSummaryLab.text = [NSString stringWithFormat:@"%d %@",offerData.wantItem.qty,offerData.wantItem.typeName];
	
	getResourceImage.image = [Datastore imageForItemWithId:offerData.haveItem.typeId];
	giveResourceImage.image = [Datastore imageForItemWithId:offerData.wantItem.typeId];
	
	int reserve = [[Datastore getInst] qtyOfItemWithId:offerData.wantItem.typeId];
	giveResourceReserveLab.text = [NSString stringWithFormat:@"%d %@",
		reserve, offerData.wantItem.typeName];
		
	if(reserve < offerData.wantItem.qty){
		giveResourceReserveLab.textColor = [UIColor redColor];
		acceptButton.alpha = .4;
		acceptButton.enabled = NO;
	}
	
	model = [PListModel new];
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(serverDidRespond:) 
			name:@"serverDidRespond" object:model];
		
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction) acceptOffer{
	NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSString stringWithFormat:@"%d",offerData.dbId],@"id",nil];
	[ActivityView presentFrom:self withMessage:@"processing..." cancelable:NO];
	[model callFunction:@"executeOffer" withParams:dict];
	[dict release];
}

- (void) serverDidRespond:(NSNotification*)notification{
	[ActivityView removeSelf];
	ServerResponse* response = [[notification object] lastResponse];
	if(response.success){
		offerData.unfulfilled--;
		[delegate didExecuteOffer];
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
	[getSummaryLab release];
	[getResourceImage release];
	[giveSummaryLab release];
	[giveResourceImage release];
	[giveResourceReserveLab release];
	[acceptButton release];
	
	[offerData release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[model release];

    [super dealloc];
}


@end
