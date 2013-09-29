//
//  DevDetail2.h
//  Acre
//
//  Created by Justin Armstrong on 11/26/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dev.h"
#import "Lot.h"

@interface DevDetail2 : UITableViewController {
	//BOOL canBuild;
	IBOutlet UILabel* cantAffordLab;
	IBOutlet UIButton* buildButton;
	Dev* development;
    Lot* lotData;
	IBOutlet UIView* headerView;
	IBOutlet UIView* footerView;
	IBOutlet UILabel* header1;
	IBOutlet UILabel* header2;
	IBOutlet UIImageView* devImage;
    
    BOOL hasMultiAction;
}
@property (nonatomic, retain) Dev* development;
@property (nonatomic, retain) UIView* headerView;
@property (nonatomic, retain) UIView* footerView;
@property (nonatomic, retain) UILabel* header1;
@property (nonatomic, retain) UILabel* header2;
//@property (nonatomic, retain) BOOL canBuild;
@property (nonatomic, retain) UILabel* cantAffordLab;
@property (nonatomic, retain) UIButton* buildButton;
@property (nonatomic, retain)  UIImageView* devImage;
@property (nonatomic, retain) Lot* lotData;

- (IBAction) buildHere;
- (int) correctedSection:(int)indexPathSec;
@end

/*@protocol DevDetailDelegate
- (void)didSelectDevelopment:(Dev*)newDev;
@end*/
