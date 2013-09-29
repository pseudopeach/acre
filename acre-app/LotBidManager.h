//
//  LotBidManager.h
//  Acre
//
//  Created by Justin Armstrong on 12/7/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lot.h"
#import "ServerResponse.h"
#import "PListModel.h"
#import "ActivityView.h"

@protocol LotBidManagerDelegate 
- (void) didUpdateBid;
@end

@interface LotBidManager : UIViewController {
	Lot* lotData;
	
	IBOutlet UILabel* lotNameLab;
	IBOutlet UIImageView* lotImage;
	IBOutlet UITextField* bidPriceFld;
	IBOutlet UILabel* currentBidLab;
	IBOutlet UILabel* highBidLab;
	IBOutlet UIButton* cancelBtn;
	
	PListModel* bidService;
    
    id <LotBidManagerDelegate> delegate;
}

@property (nonatomic, retain)  Lot* lotData;
	
@property (nonatomic, retain)  UILabel* lotNameLab;
@property (nonatomic, retain)  UIImageView* lotImage;
@property (nonatomic, retain)  UITextField* bidPriceFld;
@property (nonatomic, retain)  UILabel* currentBidLab;
@property (nonatomic, retain)  UILabel* highBidLab;
@property (nonatomic, retain) UIButton* cancelBtn;
@property (nonatomic, retain) id <LotBidManagerDelegate> delegate;

- (IBAction) updateBid;
- (IBAction) cancelBid;
- (IBAction) hideKeyboard;

- (void) updateLabels;

@end
