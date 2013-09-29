//
//  UDF.h
//  Acre
//
//  Created by Justin Armstrong on 12/26/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#define winkleCosLat1 0.636619772
#define winkleXScale 0.097246132
#define winkleYScale 0.159154943

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <math.h>


@interface UDF : NSObject {
	
}

+(NSString*) nameValuePairStringWithDictionary:(NSDictionary*)dict;
+(CGPoint) winkleProjection:(CLLocationCoordinate2D)coordinate width:(NSUInteger)iWidth height:(NSUInteger)iHeight;

//+(NSArray*) arrayFromArray:(NSArray*)array resultingFromPerItemSelector:(NSSelector

@end
