//
//  Dev.h
//  Acre
//
//  Created by Justin Armstrong on 11/3/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAOBase.h"
#import "Item.h"
@class Lot;

@interface Dev : DAOBase {
	int dbId;
	NSString* typeName;
	NSString* name;
	NSString* description;
	NSString* image;
	NSMutableArray* abilities; //NSString[]
	NSMutableArray* cost; //item[]
	NSMutableArray* input; //item[]
	NSMutableArray* output; //item[]
}

@property (nonatomic) int dbId;
@property (nonatomic,retain) NSString* typeName;
@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSString* description;
@property (nonatomic,retain) NSString* image;
@property (nonatomic,retain) NSMutableArray* abilities;
@property (nonatomic,retain) NSMutableArray* cost; //item[]
@property (nonatomic,retain) NSMutableArray* input; //item[]
@property (nonatomic,retain) NSMutableArray* output; //item[]

- (BOOL) canBuildOnLot:(Lot*)lot;

@end
