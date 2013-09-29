    //
//  Login.m
//  Acre
//
//  Created by Justin Armstrong on 12/9/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "Login.h"


@implementation Login
@synthesize loginFld, passwordFld, hideKeyboardButton, versionLab,
	userData, delegate, errorMessageLab, loginBtn, registerBtn;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	model = [PListModel new];
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(serverDidRespond:) 
			name:@"serverDidRespond" object:model];
	[[Datastore getInst] loadSavedSession];
    [loginFld addTarget:self action:@selector(hideKeyboard) 
         forControlEvents:UIControlEventEditingDidEndOnExit|UIControlEventTouchUpOutside];
    [passwordFld addTarget:self action:@selector(hideKeyboard) 
       forControlEvents:UIControlEventEditingDidEndOnExit|UIControlEventTouchUpOutside];


	self.userData = [Datastore getInst].currentSession;
	if(userData && userData.screenName != nil){
		loginFld.text = userData.screenName;
		passwordFld.text = userData.password;
	}
    NSLog(@"login viewDidLoad message:%@",[delegate statusMessageForLoginView]);
	errorMessageLab.text = [delegate statusMessageForLoginView];
	versionLab.text = [NSString stringWithFormat:@"V. %@",
                       [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]];
}


- (IBAction) startLogin{
    #if TARGET_IPHONE_SIMULATOR
    //nothing
    #else
    if([[Datastore getInst].hostReach currentReachabilityStatus] == NotReachable){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
            message:@"No internet connection is available. Acre needs an internet connection to function." delegate:self 
                cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
        [alert show]; 
        [alert release];
        return;
    }
    if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
            message:@"Location services are not available. Acre needs location services to function." delegate:self 
            cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
        [alert show]; 
        [alert release];
        return;
    }
    #endif
   
	NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
		loginFld.text,@"login",passwordFld.text,@"password",nil];
	[Datastore getInst].currentSession.password = passwordFld.text;
	errorMessageLab.text = @"logging in...";
    loginBtn.enabled = NO;
    doesRespondToExternalStatusMgs = YES;
	[model callFunction:@"loginUser" withParams:dict];
	[dict release];
}

- (void) serverDidRespond:(NSNotification*)notification{
	errorMessageLab.text = @"";
	ServerResponse* response = [[notification object] lastResponse];
	if(response.success){
		[delegate loginDidSucceed:response];
	}else{
		errorMessageLab.text = response.errorMessage;
        doesRespondToExternalStatusMgs = NO;
        loginBtn.enabled = YES;
    }
}

#pragma mark -
#pragma mark Table SaveableView overrides



- (IBAction) hideKeyboard{NSLog(@"login page hide kb");
	[loginFld resignFirstResponder];
	[passwordFld resignFirstResponder];
}

- (IBAction) showRegisterView{
	User* newUser = [User new];
	UserRegistration* registrationView = [[UserRegistration alloc] initWithNibName:@"UserRegistration" bundle:nil];
    registrationView.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_regular.png"]];
	registrationView.delegate = self;
	registrationView.userData = newUser;
	[self presentModalViewController:registrationView animated:YES];
	[newUser release];
	[registrationView release];
}

- (void) statusDidChange{
    if(doesRespondToExternalStatusMgs){
        NSString* str = [delegate statusMessageForLoginView];
        NSLog(@"status change notification:%@",str);
        errorMessageLab.text = str;
    }
}

#pragma mark -
#pragma mark Table UserRegistration delegate

- (void) didCommitUser:(User*)user{
	loginFld.text = user.screenName;
	passwordFld.text = user.password;
	[Datastore getInst].currentSession = user;
	[self didDismissView];
}
- (void) didDismissView{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[hideKeyboardButton release];
	[loginFld release];
	[passwordFld release];
	[errorMessageLab release];
	[versionLab release];
	
	[loginBtn release];
	[registerBtn release];
	
	[model release];
	[userData release];

    [super dealloc];
}


@end
