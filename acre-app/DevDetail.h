//
//  DevDetail.h
//  Acre
//
//  Created by Justin Armstrong on 11/22/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailHeaderView.h"
#import "Item.h"
#import "Dev.h"
#import "Datastore.h"

@interface DevDetail : UITableViewController {
	Dev* development;
	UIView* headerView;
}
@property (nonatomic, retain) Dev* development;
@property (nonatomic, retain) UIView* headerView;
@end
