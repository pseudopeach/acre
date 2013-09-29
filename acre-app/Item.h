//
//  Item.h
//  Acre
//
//  Created by Justin Armstrong on 11/3/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAOBase.h"
#import "Datastore.h"

@interface Item : DAOBase {
	long int dbId;
	int typeId;
	NSString* typeName;
	int qty;
	NSString* image;
    
    int actionGroup;
}

@property (nonatomic) long int dbId;
@property (nonatomic) int typeId;
@property (nonatomic) int qty;
@property (nonatomic,retain) NSString* typeName;
@property (nonatomic,retain) NSString* image;
@property (nonatomic) int actionGroup;

- (Item*) initWithTypeId:(int)typeId andQty:(int)qty;
- (void) lookupItemInfo;

@end
