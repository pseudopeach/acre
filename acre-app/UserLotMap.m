//
//  UserLotMap.m
//  Acre
//
//  Created by Justin Armstrong on 3/14/11.
//  Copyright 2011 Actinic inc. All rights reserved.
//

#import "UserLotMap.h"


@implementation UserLotMap
@synthesize pointArray;

- (void)drawRect:(CGRect)rect{
	[super drawRect:rect];
	self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"world_mask_small.png"]];
	
	CGContextRef contextRef = UIGraphicsGetCurrentContext();//teal:0.58984375,0.50390625,0.3515625

	CGContextSetRGBFillColor(contextRef, 0.168627451, 0.843137255,1.0, 0.02);
	for(int i=0;i<pointArray.count;i++){
		NSDictionary* dict = [pointArray objectAtIndex:i];
		CLLocationCoordinate2D location;
		location.latitude = [[dict objectForKey:@"lat"] doubleValue];
		location.longitude = [[dict objectForKey:@"lon"] doubleValue];
		CGPoint p = [UDF winkleProjection:location width:300 height:185];
		CGContextFillEllipseInRect(contextRef, CGRectMake(p.x-5, p.y-5, 10.0, 10.0));
	}
	
	
	CGContextSetRGBFillColor(contextRef, 0.168627451, 0.843137255,1.0, 0.9);
	for(int i=0;i<pointArray.count;i++){
		NSDictionary* dict = [pointArray objectAtIndex:i];
		CLLocationCoordinate2D location;
		location.latitude = [[dict objectForKey:@"lat"] doubleValue];
		location.longitude = [[dict objectForKey:@"lon"] doubleValue];
		CGPoint p = [UDF winkleProjection:location width:300 height:185];
		CGContextFillEllipseInRect(contextRef, CGRectMake(p.x-1, p.y-1, 2.0, 2.0));
	}
}


- (void)dealloc {
	[pointArray release];
    [super dealloc];
}


@end
