//
//  OfferCreate.h
//  Acre
//
//  Created by Justin Armstrong on 11/14/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Offer.h"
#import "Lot.h"
#import "Dev.h"
#import "SaveableView.h"

#import "Item.h"

@protocol OfferCreateDelegate

- (void) didCreateNewOffer:(Offer*)offer;
- (void) didDismissView;

@end


@interface OfferCreate : UIViewController 
<UIPickerViewDelegate, UIPickerViewDataSource>{
	Offer* newOffer;
	Lot* lotData;
	Dev* lotDev;
	IBOutlet UISegmentedControl* actionSeg;
	IBOutlet UIPickerView* resourcePicker;
	IBOutlet UITextField* priceFld;
	NSMutableArray* qtyArray;
	NSArray* qtyArraySource;
	NSMutableArray* pickerResourcesSell;
	NSMutableArray* pickerResourcesBuy;
	
	//NSArray* buyableItems;
	//NSArray* sellableItems;
	
	id <OfferCreateDelegate> delegate;
}

@property (nonatomic, retain) Offer* newOffer;
@property (nonatomic, retain) Lot* lotData;
@property (nonatomic, retain) Dev* lotDev;
@property (nonatomic, retain) UISegmentedControl* actionSeg;
@property (nonatomic, retain) UIPickerView* resourcePicker;
@property (nonatomic, retain) UITextField* priceFld;
@property (nonatomic, retain) NSMutableArray* qtyArray;
@property (nonatomic, retain) NSArray* qtyArraySource;
@property (nonatomic, retain) NSMutableArray* pickerResourcesSell;
@property (nonatomic, retain) NSMutableArray* pickerResourcesBuy;

//@property (nonatomic, retain) NSArray* buyableItems;
//@property (nonatomic, retain) NSArray* sellableItems;

@property (nonatomic, retain) id <OfferCreateDelegate> delegate;


- (IBAction) didSelectToolbarButton:(id)sender;
- (IBAction) hideKeyboard;

//private
- (void) rewriteData;
- (IBAction) actionDidChange;
- (void) rebuildQtyArray:(int)maxQty;

@end
