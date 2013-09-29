//
//  UserDetail.h
//  Acre
//
//  Created by Justin Armstrong on 12/10/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "User.h"
#import "UserLotMap.h"
#import "UDF.h"

@interface UserDetail : UITableViewController {
	User* userData;
	IBOutlet UIView* headerView;
	IBOutlet UILabel* header1;
	IBOutlet UserLotMap* mapView;
}
@property (nonatomic, retain) User* userData;
@property (nonatomic, retain) UIView* headerView;
@property (nonatomic, retain) UILabel* header1;
@property (nonatomic, retain) UserLotMap* mapView;

@end
