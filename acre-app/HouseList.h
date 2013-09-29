//
//  HouseList.h
//  Acre
//
//  Created by Justin Armstrong on 12/18/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SaveableTableView.h"
#import "Lot.h"
#import "LotListPayRent.h"

@interface HouseList : SaveableTableView {
	NSArray* lotList;
	NSArray* houseList;
	BOOL isLeaf;
}

@property (nonatomic, retain) NSArray* lotList;
@property (nonatomic, retain) NSArray* houseList;
@property (nonatomic) BOOL isLeaf;

@end
