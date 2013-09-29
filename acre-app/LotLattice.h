//
//  LotLattice.h
//  Acre
//
//  Created by Justin Armstrong on 12/2/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <math.h>

#import "Lot.h"
#import "PListModel.h"



#define nLatBands 162000.0
#define nLonBands 152594.0
#define latCoeff (90.0/nLatBands)
#define radiansPerBand (M_PI/nLatBands/2.0)
#define innerBufferScale .6
#define outerBufferScale 1.2

#define maxRangeSquared 0.000209

#define jCoordRateConst (nLonBands/nLatBands*2*M_PI) //5.918

double calcLonCoeff(int Ci);

@class LotPolygon;

@protocol LotLatticeDelegate

- (void) addPolygons:(NSArray*)somePolygons;
- (void) removePolygons:(NSArray*)somePolygons andTheirIcons:(NSArray*)icons;
- (void) refreshPolygons:(NSArray*)somePolygons;

@end

@interface LotLattice : NSObject {
    
    double bottomLat;
	double topLat;
	double leftLon;
	double rightLon;
    
    double bufferMaxLat;
	double bufferMinLat;
	double bufferMaxLon;
	double bufferMinLon;
	
	NSDictionary* lotsByLocation;
	NSMutableArray* lotArray;
	
	BOOL hasNewGPSLocation;
    BOOL allowLocationCheckin;
    //BOOL hasFirstGPSLocation;
	MKCoordinateRegion box;
	CLLocationCoordinate2D GPSLocation;
	//double maxRangeSquared;
	double longitudeScale;
	
	NSPredicate* outsideMaxBuffer;
	NSPredicate* outsideMaxRange;
	
    //NSString* unrequitedLots;
    NSMutableArray* lotRequests;
	//PListModel* model;
	id <LotLatticeDelegate> delegate;
}

@property (nonatomic, retain) NSDictionary* lotsByLocation;
@property (nonatomic, retain) NSMutableArray* lotArray;
@property (nonatomic, retain) NSPredicate* outsideMaxBuffer;
@property (nonatomic, retain) NSPredicate* outsideMaxRange;

@property (nonatomic) MKCoordinateRegion box;
//@property (nonatomic, retain) NSString* unrequitedLots;
@property (nonatomic,retain) NSMutableArray* lotRequests;

@property (nonatomic,retain) id <LotLatticeDelegate> delegate;

@property (nonatomic,readonly) int lotCount;
@property (nonatomic) BOOL allowLocationCheckin;


+ (CLLocationCoordinate2D) locationOfCi:(int)Ci Cj:(int)Cj;

//for some reason these cause build errors, so I'll take the warnings instead
- (LotPolygon *) lotPolygonAt:(int)ci Cj:(int)cj; 
- (LotPolygon *) lotPolygonContainingCoordinate:(CLLocationCoordinate2D)coord;

- (id) initWithBox:(MKCoordinateRegion)input andDelegate:(id<LotLatticeDelegate>)del;
- (void) setBox:(MKCoordinateRegion)box;
- (void) removeAll;
- (void) reset;



- (void) reconstuctDictionary;
- (NSArray*) lotAnnotationsForLots:(NSArray*)lots;

- (void) setGPSLocation:(CLLocationCoordinate2D)location;
- (void) doRangeCleanup;

@end
