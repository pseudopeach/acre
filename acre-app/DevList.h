//
//  DevList.h
//  Acre
//
//  Created by Justin Armstrong on 11/21/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Datastore.h"
#import "Lot.h"
#import "DevDetail2.h";

@interface DevList : UITableViewController {
	Lot* lotData;
}

@property (nonatomic, retain) Lot* lotData;
@end
