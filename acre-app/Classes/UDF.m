//
//  UDF.m
//  Acre
//
//  Created by Justin Armstrong on 12/26/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "UDF.h"


@implementation UDF

+(NSString*) nameValuePairStringWithDictionary:(NSDictionary*)dict{
	NSString* result = [[NSString new] autorelease];
	BOOL isFirst = YES;
	for(NSString* key in dict){
		NSString* aValueStr = [dict valueForKey:key];
		aValueStr = [aValueStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		if(!isFirst)
			result =  [result stringByAppendingFormat:@"&%@=%@",
				key, aValueStr];
		else{
			result =  [result stringByAppendingFormat:@"%@=%@",
				key, aValueStr];
			isFirst = NO;
		}
	}
	return result;
}

+(CGPoint) winkleProjection:(CLLocationCoordinate2D)coordinate width:(NSUInteger)iWidth height:(NSUInteger)iHeight{
	CGPoint result;
       
	double lat = coordinate.latitude*M_PI/180;
	double lon = coordinate.longitude*M_PI/180;

    double alpha = cos(lat)*cos(lon/2);
    alpha = sqrt(1-alpha*alpha)/acos(alpha);
	
	//winkle transform
	result.x = winkleXScale*(lon*winkleCosLat1+2*cos(lat)*sin(lon/2)/alpha);
	result.y = winkleYScale*(lat+sin(lat)/alpha);
	
    //pixel transform
    result.x = iWidth*(result.x+.5);
    result.y = iHeight*(.5-result.y);
    
	return result;
}

/*+(double) haversineDistanceFrom:(CLLocationCoordinate2D)loc1 to:(CLLocationCoordinate2D)loc2{
    double lat1 = loc1.
    <cfset var D = 7918*asin(sqr(
                                 sin((lat1-lat2)/114.59)^2
                                 +sin((lon1-lon2)/114.59)^2
                                 *cos(lat1/57.3)*cos(lat2/57.3) ))/>
    
    <cfreturn D/>
}*/

@end
