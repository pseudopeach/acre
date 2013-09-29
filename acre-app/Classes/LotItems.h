//
//  LotItems.h
//  Acre
//
//  Created by Justin Armstrong on 11/13/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SaveableView.h"
#import "Item.h"
#import "Lot.h"
#import "ItemSlider.h"


@interface LotItems : SaveableView 
<UITableViewDataSource, UITableViewDelegate, ItemSliderDelegate>{
	IBOutlet UILabel* carriedTotLab;
	IBOutlet UILabel* lotTotLab;
	IBOutlet UITableView* table;
	IBOutlet UIView* headerView;
	
	int tempSumLot;
	int tempSumCarried;
	int currentSlider;
	int currentSliderValue;
	
	NSMutableArray* items;
	//NSMutableArray* sliderItemsLot;
	Lot* lotData;
}

@property (nonatomic,retain)  Lot* lotData;
@property (nonatomic,retain)  UILabel* carriedTotLab;
@property (nonatomic,retain)  UILabel* lotTotLab;
@property (nonatomic,retain)  UITableView* table;
@property (nonatomic,retain)  UIView* headerView;
@property (nonatomic,retain)  NSMutableArray* items;
//@property (nonatomic,retain)  NSMutableArray* sliderItemsCarried;

- (void) setSliderBounds;
//- (IBAction) didSelectToolbarButton:(id)sender;
//- (void)setCarriedQty:(int)qty ofItem:(int)typeId;
//- (void)setLotQty:(int)qty ofItem:(int)typeId;

- (void) updateSums;

@end

/*
@protocol ItemSliderDelegate

- (void) sliderValueDidChange:(int)value;
- (void) sliderValueWasSet:(int)value;

@end
*/