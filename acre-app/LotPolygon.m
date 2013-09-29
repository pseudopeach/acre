//
//  LotPolygon.m
//  Acre
//
//  Created by Justin Armstrong on 1/1/11.
//  Copyright 2011 Actinic inc. All rights reserved.
//

#import "LotPolygon.h"


@implementation LotPolygon
@synthesize Ci, Cj, topLat, bottomLat, leftLon, rightLon,
	ownerId,devTypeId, developmentIcon, polygon;

- (NSString*) description{
	if(!keyString)
		keyString = [[LotPolygon keyStringWithLocationCi:Ci andCj:Cj] retain];
	return keyString;
	//NSLog(@"created lattice address: %@",address);
}

- (id) initWithCoordinatesCi:(int)i andCj:(int)j{
	if((self = [super init])){
		self.Ci = i;
		self.Cj = j;
	}
	return self;
}

- (LotPolygon*) initWithRect:(double)top right:(double)right bottom:(double)bottom left:(double)left{
	if((self = [super init])){
		topLat = top;
		bottomLat = bottom;
		leftLon = left;
		rightLon = right;
	}
	return self;
}
/*- (double) distanceSqFromLat:(double)lat andLon:(double)lon scaledBy:(double)sc{
	return pow(bottomLat-
}*/

+(NSString*) keyStringWithLocationCi:(int)i andCj:(int)j{
	//long long int N = (hashConst*i+j);
	//NSLog(@"coord:%d,%d raw:%qi, %qX, %64x",i,j,N,N,N);
	return [NSString stringWithFormat:@"%qX",(long long int)(hashConst*i+j)];//(i*hashConst+j)
}

- (MKPolygon*) polygon{
	if(!polygon){
		CLLocationCoordinate2D coords[] = {
			{topLat,rightLon},{bottomLat,rightLon},
			{bottomLat,leftLon},{topLat,leftLon}
		};
		polygon = [[MKPolygon polygonWithCoordinates:coords count:4] retain];
		//NSLog(@"created polygon");
	}
	return polygon;
}

- (CLLocationCoordinate2D) coordinate{
	//MKPolygon* pg1 = self.polygon;
	//NSLog(@"access of polycon center: %f, %f",self.polygon.coordinate.latitude, self.polygon.coordinate.longitude);
	return [self.polygon coordinate];
}
- (MKMapRect)boundingMapRect{
	
	return [self.polygon boundingMapRect];
}
- (BOOL)intersectsMapRect:(MKMapRect)mapRect{
	return [self.polygon intersectsMapRect:mapRect];
}
//- (NSUInteger) pointCount{return 4;}
	
- (void) dealloc{
	[developmentIcon release];
	[polygon release];
	[keyString release];
	
	[super dealloc];
}

@end
