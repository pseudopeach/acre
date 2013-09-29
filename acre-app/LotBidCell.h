//
//  LotBidCell.h
//  Acre
//
//  Created by Justin Armstrong on 12/5/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lot.h"

@interface LotBidCell : UITableViewCell {
	Lot* lotData;
	IBOutlet UIButton* setBidButton;
	IBOutlet UITextField* bidField;
}

@property (nonatomic, retain) Lot* lotData;
@property (nonatomic, retain) UIButton* setBidButton;
@property (nonatomic, retain) UITextField* bidField;


@end
