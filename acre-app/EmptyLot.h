//
//  EmptyLot.h
//  Acre
//
//  Created by Justin Armstrong on 2/13/11.
//  Copyright 2011 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SaveableView.h"
#import "Lot.h"
#import "Datastore.h"


@interface EmptyLot : SaveableView 
{
	Lot* lotData;
		
	IBOutlet UILabel* rentPriceLab;
	IBOutlet UIButton* claimButton;
	IBOutlet UITextField* lotNameFld;
	IBOutlet UILabel* NSFLab;
	
	BOOL claimed;
}

@property (nonatomic, retain) UILabel* rentPriceLab;
@property (nonatomic, retain) UIButton* claimButton;
@property (nonatomic, retain) Lot* lotData;
@property (nonatomic, retain) UITextField* lotNameFld;
@property (nonatomic, retain) UILabel* NSFLab;


- (IBAction) hideKeyboard;
- (void) disableClaim;

@end
