//
//  ServerResponse.m
//  Acre
//
//  Created by Justin Armstrong on 12/8/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "ServerResponse.h"


@implementation ServerResponse
@synthesize success, errorId, errorMessage, resultObject, resultQuery;


- (void) dealloc{
	[errorMessage release];
	[resultObject release];
	[resultQuery release];
	[super dealloc];
}

@end
