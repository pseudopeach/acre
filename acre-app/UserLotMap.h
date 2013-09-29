//
//  UserLotMap.h
//  Acre
//
//  Created by Justin Armstrong on 3/14/11.
//  Copyright 2011 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UDF.h"


@interface UserLotMap : UIView {
	NSArray* pointArray;
}


@property (nonatomic,retain) NSArray* pointArray;

@end
