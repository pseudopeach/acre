//
//  LotView.h
//  Acre
//
//  Created by Justin Armstrong on 11/14/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SaveableTableView.h"
#import "Lot.h"
#import "Offer.h"
#import "LotBidManager.h"
#import "OfferAccept.h"

#import "UserDetail.h"
@class User;


@interface LotView : SaveableTableView 
<OfferAcceptDelegate, LotBidManagerDelegate> {
	Lot* lotData;
	NSArray* offersBuy;
	NSArray* offersSell;
	NSArray* offersTrade;
	int nOfferSections;
	
	IBOutlet UIView* headerView;
	IBOutlet UILabel* nameLab;
	IBOutlet UIImageView* devImage;
	IBOutlet UILabel* devTypeNameLab;
	
	PListModel* userService;
	
}

@property (nonatomic, retain) Lot* lotData;
@property (nonatomic, retain) NSArray* offersBuy;
@property (nonatomic, retain) NSArray* offersSell;
@property (nonatomic, retain) NSArray* offersTrade;

@property (nonatomic, retain) UIView* headerView;
@property (nonatomic, retain) UILabel* nameLab;
@property (nonatomic, retain) UILabel* devTypeNameLab;
@property (nonatomic, retain) UIImageView* devImage;

- (NSArray*) offerArrayForSection:(int)section;
- (void) refreshOfferArrays;

@end
