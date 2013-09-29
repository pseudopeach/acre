//
//  LotListPayRent.h
//  Acre
//
//  Created by Justin Armstrong on 12/19/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lot.h"
#import "PListModel.h"

@interface LotListPayRent : UITableViewCell {
	Lot* lotData;
	BOOL hasOutstandingCall;
	PListModel* model;
	
	IBOutlet UILabel* nameLab;
	IBOutlet UILabel* detailLab;
	
	IBOutlet UIButton* payButton;
	IBOutlet UILabel* dueLab;
	IBOutlet UILabel* valueLab;
	IBOutlet UIActivityIndicatorView* spinner;
	
}
@property (nonatomic,retain)  UILabel* nameLab;
@property (nonatomic,retain)  UILabel* detailLab;
@property (nonatomic,retain) Lot* lotData;
@property (nonatomic,retain) UIButton* payButton;
@property (nonatomic,retain) UILabel* dueLab;
@property (nonatomic,retain) UILabel* valueLab;
@property (nonatomic,retain) UIActivityIndicatorView* spinner;

@property (nonatomic, readonly) BOOL hasOutstandingCall;

- (IBAction) payRent;

@end
