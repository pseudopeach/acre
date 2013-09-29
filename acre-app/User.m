//
//  User.m
//  Acre
//
//  Created by Justin Armstrong on 10/28/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "User.h"


@implementation User

@synthesize dbId, screenName, lotsVisited, 
lotsOwned, score, mapPoints, 
password, nobleTitles, emailAddress, isFemale;

-(void) dealloc{
	[screenName release];
	[emailAddress release];
	[mapPoints release];
	[password release];

	[nobleTitles release];
	[super dealloc];
}

@end
