//
//  LotPolygon.h
//  Acre
//
//  Created by Justin Armstrong on 1/1/11.
//  Copyright 2011 Actinic inc. All rights reserved.
//

#define hashConst 500000LL

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Lot.h"
#import "LotAnnotation.h"



@interface LotPolygon : NSObject 
<MKOverlay> {
	int Ci;
	int Cj;
	
	double topLat;
	double bottomLat;
	double leftLon;
	double rightLon;
	
	LotAnnotation* developmentIcon;
	
	//UIColor* fillColor;
	//UIColor* strokeColor;
	
	int ownerId;
	int devTypeId;
	
	
	NSString* keyString;
	
	MKPolygon* polygon;
	
	//float fillAlpha;
	//float lineWidth;
}

@property (nonatomic) int Ci;
@property (nonatomic) int Cj;

@property (nonatomic) double topLat;
@property (nonatomic) double bottomLat;
@property (nonatomic) double leftLon;
@property (nonatomic) double rightLon;

@property (nonatomic) int ownerId;
@property (nonatomic) int devTypeId;
@property (nonatomic,retain) LotAnnotation* developmentIcon;

//@property (nonatomic, readonly) NSString* keyString;

@property (nonatomic, readonly) MKPolygon* polygon;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) MKMapRect boundingMapRect;

//- (NSString*) keyString
+ (NSString*) keyStringWithLocationCi:(int)i andCj:(int)j;

//+ (LotPolygon*) lotPolygonWithRect:(double)top right:(double)right bottom:(double)bottom left:(double)left;
- (LotPolygon*) initWithRect:(double)top right:(double)right bottom:(double)bottom left:(double)left;

//@property (nonatomic,retain) UIColor* fillColor;
//@property (nonatomic,retain) UIColor* strokeColor;

//@property (nonatomic) float fillAlpha;
//@property (nonatomic) float lineWidth;

@end
