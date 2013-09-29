//
//  LotAnnotation.h
//  Acre
//
//  Created by Justin Armstrong on 1/6/11.
//  Copyright 2011 Actinic inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LotAnnotation : NSObject 
<MKAnnotation>{
	CLLocationCoordinate2D coordinate;
	int devTypeId;
	NSString* title;
}

- (id) initWithlocation:(CLLocationCoordinate2D)loc andDevTypeId:(int)dev;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) int devTypeId;
@property (nonatomic,retain)NSString* title;
@end
