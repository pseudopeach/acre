//
//  LotEditPayRent.h
//  Acre
//
//  Created by Justin Armstrong on 11/19/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lot.h"
#import "PListModel.h"

@interface LotEditPayRent : UITableViewCell {
	IBOutlet UILabel* rentValueLab;
	IBOutlet UILabel* rentDueLab;
	IBOutlet UIButton* payButton;
	Lot* lotData;
}

@property (nonatomic,retain) UILabel* rentValueLab;
@property (nonatomic,retain) UILabel* rentDueLab;
@property (nonatomic,retain) UIButton* payButton;
@property (nonatomic,retain) Lot* lotData;

@end