//
//  UserRegistration.h
//  Acre
//
//  Created by Justin Armstrong on 12/13/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SaveableView.h"
#import "User.h"

#import "ActivityView.h"
#import "PListModel.h"

@protocol UserRegistrationDelegate

- (void) didCommitUser:(User*)user;
- (void) didDismissView;

@end

@interface UserRegistration : UIViewController 
<UITableViewDataSource, UITableViewDelegate> {
	User* userData;
	IBOutlet UIView* footerView;
	IBOutlet UITableView* table;
	
	id <UserRegistrationDelegate> delegate;
	
	 UITextField* emailFld;
	 UITextField* screenNameFld;
	 UITextField* passwordFld;
	 UITextField* passwordCfmFld;
	 UISegmentedControl* genderSelect;
	 
	 NSMutableDictionary* IPsByTag;
	 NSDictionary* fieldsByIP;
	 NSDictionary* labelsByIP;
	 NSIndexPath* currentIndexPath;
	 
	 IBOutlet UILabel* errorMessageLab;
	 
	 PListModel* model;
}
@property (nonatomic,retain) User* userData;
@property (nonatomic,retain) UIView* footerView;
@property (nonatomic,retain) UITableView* table;

@property (nonatomic,retain)  UITextField* emailFld;
@property (nonatomic,retain)  UITextField* screenNameFld;
@property (nonatomic,retain)  UITextField* passwordFld;
@property (nonatomic,retain)  UITextField* passwordCfmFld;
@property (nonatomic,retain)  UISegmentedControl* genderSelect;

@property (nonatomic,retain) NSMutableDictionary* IPsByTag;
@property (nonatomic,retain) NSDictionary* fieldsByIP;
@property (nonatomic,retain) NSDictionary* labelsByIP;
@property (nonatomic,retain) NSIndexPath* currentIndexPath;

@property (nonatomic,retain)  UILabel* errorMessageLab;

@property (nonatomic,retain) id <UserRegistrationDelegate> delegate;

- (IBAction) close;
- (void) hideKeyboard;
- (IBAction) startRegistration;
- (void) serverDidRespond:(NSNotification*)notification;

@end
