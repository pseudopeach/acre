    //
//  SaveableView.m
//  Acre
//
//  Created by Justin Armstrong on 11/27/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "SaveableView.h"


@implementation SaveableView
@synthesize dataObject, serverCall, delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
	model = [PListModel new];
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(serverDidRespond:) 
			name:@"serverDidRespond" object:model];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(cancelServerCall) 
			name:@"ServerCallShouldBeCanceled" object:nil];
}



//called by save button
- (IBAction) saveAndClose{
	[ActivityView presentFrom:self withMessage:@"saving..." cancelable:YES];
	
	[self save];
}
//actually closes
- (IBAction) close{
	[delegate dismissLotView];
}
//saves current data object to the server
- (void) save{
	[self rewriteData];
}

//writes current view state to data object
- (void) rewriteData{
}
//called by model
- (void) serverDidRespond:(NSNotification*)notification{
	[ActivityView removeSelf];
	ServerResponse* response = [[notification object] lastResponse];
	
    if(response.success)
        [self saveDidSucceed];
    else 
        [self saveDidFail:response];
	
}

- (void) saveDidSucceed{
	[self close];
}

-(void) saveDidFail:(ServerResponse*)response{
	if(response.errorId == 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
			message:@"Server communication error." delegate:self 
			cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show]; 
		[alert release];
	}
}


- (void) dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[model release];
	[serverCall release];
	[super dealloc];
}

@end