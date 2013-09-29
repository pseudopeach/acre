//
//  ItemSlider.h
//  Acre
//
//  Created by Justin Armstrong on 11/28/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <math.h>
#import "Item.h"
#import "Lot.h"

#define LotItemDictKeyCarried @"carried"
#define LotItemDictKeyLot @"lot"
#define LotItemDictKeyIndex @"index"
#define LotItemDictKeyMaxValue @"maxValue"
#define LotItemDictKeyMinValue @"minValue"

@protocol ItemSliderDelegate

//- (void) sliderDidStartSliding:(int)index atValue:(int)value;
- (void) sliderValueDidChange:(int)index toValue:(int)value;
- (void) sliderDidEndSliding:(int)index atValue:(int)value;

@end


@interface ItemSlider : UITableViewCell {
	int minValue;
	int maxValue;
	Item* carriedItem;
	Item* lotItem;
	int thisIndex;
	
	
	NSMutableDictionary* itemInfo;
	int sum;
	int qtyInLot;
	Lot* lotData;
	
	IBOutlet UISlider* slider;
	IBOutlet UILabel* carryCountLab;
	IBOutlet UILabel* lotCountLab;
	IBOutlet UILabel* resourceTypeNameLab;
	IBOutlet UIImageView* resourceImage;
	
	id <ItemSliderDelegate> delegate;
	
}

@property (nonatomic) int minValue;
@property (nonatomic) int maxValue;
@property (nonatomic,retain) Item* carriedItem;
@property (nonatomic,retain) Item* lotItem;
//@property (nonatomic,retain) NSDictionary* itemPair;
@property (nonatomic, retain) NSMutableDictionary* itemInfo;
//@property (nonatomic) int sum;
@property (nonatomic,retain) Lot* lotData;
@property (nonatomic,retain) UISlider* slider;
@property (nonatomic,retain) UILabel* carryCountLab;
@property (nonatomic,retain) UILabel* lotCountLab;
@property (nonatomic,retain) id <ItemSliderDelegate> delegate;
@property (nonatomic,retain)  UILabel* resourceTypeNameLab;
@property (nonatomic,retain)  UIImageView* resourceImage;

- (IBAction) didSlide;
//- (IBAction) didStartSlide;
- (IBAction) didEndSlide;
- (void) updateLabels;

@end
