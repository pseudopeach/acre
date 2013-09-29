//
//  Login.h
//  Acre
//
//  Created by Justin Armstrong on 12/9/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "UserRegistration.h"
#import "PListModel.h"
#import "ActivityView.h"
#import "Datastore.h"

@protocol UserLoginDelegate

- (void) loginDidSucceed:(ServerResponse*)loginInfo;
- (void) didDismissView;
- (NSString*) statusMessageForLoginView;

@end

@interface Login : UIViewController 
<UserRegistrationDelegate> {
	IBOutlet UITextField* loginFld;
	IBOutlet UITextField* passwordFld;
	IBOutlet UIButton* hideKeyboardButton;
	IBOutlet UILabel* errorMessageLab;
	
	IBOutlet UIButton* loginBtn;
	IBOutlet UIButton* registerBtn;
	IBOutlet UILabel* versionLab;
	
	User* userData;
    BOOL doesRespondToExternalStatusMgs;
	
	//UserRegistration* registrationView;
	PListModel* model;
	id <UserLoginDelegate> delegate;
}

@property (nonatomic,retain) UITextField* loginFld;
@property (nonatomic,retain) UITextField* passwordFld;
@property (nonatomic,retain) UIButton* hideKeyboardButton;
@property (nonatomic,retain) User* userData;
@property (nonatomic,retain) UILabel* errorMessageLab;
@property (nonatomic,retain)  UILabel* versionLab;

@property (nonatomic,retain) UIButton* loginBtn;
@property (nonatomic,retain) UIButton* registerBtn;

//@property (nonatomic,retain) UserRegistration* registrationView;
@property (nonatomic,retain) id <UserLoginDelegate> delegate;

- (IBAction) startLogin;
- (IBAction) showRegisterView;

- (IBAction) hideKeyboard;

- (void) statusDidChange;


@end
