//
//  User.h
//  Acre
//
//  Created by Justin Armstrong on 10/28/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAOBase.h"

@interface User : DAOBase {
	int dbId;
	NSString* screenName;
	NSString* emailAddress;
	NSString* password;
	BOOL isFemale;
	
	int lotsVisited;
	int lotsOwned;
	long int score;
	NSArray* mapPoints;
	
	NSArray* nobleTitles;
}

@property (nonatomic) int dbId;//***make readonly
@property (nonatomic, retain) NSString* screenName;
@property (nonatomic, retain) NSString* emailAddress;
@property (nonatomic) BOOL isFemale;
@property (nonatomic,readonly) int lotsVisited;
@property (nonatomic,readonly) int lotsOwned;
@property (nonatomic,readonly) long int score;
@property (nonatomic, retain) NSArray* mapPoints;
@property (nonatomic, retain) NSString* password;

@property (nonatomic, retain) NSArray* nobleTitles;


@end
