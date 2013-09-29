//
//  OfferAccept.h
//  Acre
//
//  Created by Justin Armstrong on 12/8/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Offer.h"
#import "PListModel.h"
#import "ActivityView.h"

@protocol OfferAcceptDelegate
- (void) didExecuteOffer;
@end

@interface OfferAccept : UIViewController {
	Offer* offerData;
	
	IBOutlet UILabel* getSummaryLab;
	IBOutlet UIImageView* getResourceImage;
	
	IBOutlet UILabel* giveSummaryLab;
	IBOutlet UIImageView* giveResourceImage;
	IBOutlet UILabel* giveResourceReserveLab;
	
	IBOutlet UIButton* acceptButton;
	
	PListModel* model;
	
	id <OfferAcceptDelegate> delegate;
}

@property (nonatomic, retain) Offer* offerData;
	
@property (nonatomic, retain)  UILabel* getSummaryLab;
@property (nonatomic, retain)  UIImageView* getResourceImage;

@property (nonatomic, retain)  UILabel* giveSummaryLab;
@property (nonatomic, retain)  UIImageView* giveResourceImage;
@property (nonatomic, retain)  UILabel* giveResourceReserveLab;

@property (nonatomic, retain)  UIButton* acceptButton;

@property (nonatomic, retain) id <OfferAcceptDelegate> delegate;

- (IBAction) acceptOffer;

@end
