//
//  ServerResponse.h
//  Acre
//
//  Created by Justin Armstrong on 12/8/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAOBase.h"


@interface ServerResponse : DAOBase {
	BOOL success;
	int errorId;
	NSString* errorMessage; 
	id resultObject;
	NSMutableArray* resultQuery;
}

@property (nonatomic) BOOL success;
@property (nonatomic) int errorId;
@property (nonatomic, retain) NSString* errorMessage; 
@property (nonatomic, retain) NSMutableDictionary* resultObject;
@property (nonatomic, retain) NSMutableArray* resultQuery;

@end
