//
//  AKVector.h
//  Acre
//
//  Created by Justin Armstrong on 12/3/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>


@interface AKVector : NSObject {
	double i;
	double j;
	double k;
}

@property (nonatomic) double i;
@property (nonatomic) double j;
@property (nonatomic) double k;

+ (AKVector*) vectorWithArray:(NSArray*)array;
- (double) norm2;


@end
