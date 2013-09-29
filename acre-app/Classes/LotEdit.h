//
//  LotEdit.h
//  Acre
//
//  Created by Justin Armstrong on 11/13/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lot.h"
#import "LogItem.h"
#import "LotEditPayRent.h"
#import "SaveableTableView.h"
#import "DevList.h"
#import "PListModel.h"

@interface LotEdit : SaveableTableView {
	Lot* lotData;
	UITextField* nameField;
	LotEditPayRent* rentPayCell;
	//NSDateFormatter* dateFormatter;
	
	PListModel* payService;
}

@property (nonatomic,retain) Lot* lotData;
@property (nonatomic,retain) UITextField* nameField;
@property (nonatomic,retain) LotEditPayRent* rentPayCell;






@end
