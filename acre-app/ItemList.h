//
//  ItemList.h
//  Acre
//
//  Created by Justin Armstrong on 3/5/11.
//  Copyright 2011 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Datastore.h"
#import "SaveableView.h"
#import "Item.h"
#import "PListModel.h"

@interface ItemList : SaveableView 
<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>{
	IBOutlet UITableView* table;
	
	NSMutableArray* itemArray;
	PListModel* liquidateService;
	Item* itemToLiquidate;
}

@property (nonatomic, retain) UITableView* table;
@property (nonatomic, retain) NSMutableArray* itemArray;
@property (nonatomic, retain) Item* itemToLiquidate;


@end
