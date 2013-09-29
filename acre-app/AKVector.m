//
//  AKVector.m
//  Acre
//
//  Created by Justin Armstrong on 12/3/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "AKVector.h"


@implementation AKVector
@synthesize i,j,k;


+ (AKVector*) vectorWithArray:(NSArray*)array{
	AKVector* newVect = [AKVector alloc];
	return newVect;
}
- (double) norm2{
	return sqrt(i*i + j*j + k*k);
}

@end
