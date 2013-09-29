//
//  LotOffers.h
//  Acre
//
//  Created by Justin Armstrong on 11/13/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lot.h"
#import "Offer.h"
#import "Item.h"
#import "SaveableView.h"
#import "Datastore.h"
#import "OfferCreate.h"

@interface LotOffers : SaveableView 
<UITableViewDelegate, UITableViewDataSource, OfferCreateDelegate>{
	Lot* lotData;
	IBOutlet UITableView* table;
}

@property (nonatomic,retain) Lot* lotData;
@property (nonatomic,retain) UITableView* table;

- (IBAction) didSelectToolbarButton:(id)sender;
- (void) toggleEditing;
- (void) addOfferItem;

@end
