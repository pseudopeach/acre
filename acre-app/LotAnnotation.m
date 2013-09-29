//
//  LotAnnotation.m
//  Acre
//
//  Created by Justin Armstrong on 1/6/11.
//  Copyright 2011 Actinic inc. All rights reserved.
//

#import "LotAnnotation.h"


@implementation LotAnnotation
@synthesize coordinate, devTypeId, title;

- (id) initWithlocation:(CLLocationCoordinate2D)loc andDevTypeId:(int)dev{
	if(self = [super init]){
		coordinate = loc;
		devTypeId = dev;
	}
	return self;
}

- (void) dealloc{
	[title release];
	[super dealloc];
}
@end
