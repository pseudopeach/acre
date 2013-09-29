//
//  UserRegistration.m
//  Acre
//
//  Created by Justin Armstrong on 12/13/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "UserRegistration.h"


@implementation UserRegistration
@synthesize table, footerView, delegate;
@synthesize emailFld, screenNameFld, errorMessageLab,
passwordFld, passwordCfmFld, genderSelect, fieldsByIP;
@synthesize labelsByIP, IPsByTag, currentIndexPath;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	//self.dataObject = userData;
	
	CGRect newFrame = CGRectMake(0.0, 0.0, table.bounds.size.width, self.footerView.frame.size.height);
	self.footerView.backgroundColor = [UIColor clearColor];
    self.table.backgroundColor = [UIColor clearColor];
	self.footerView.frame = newFrame;
	table.tableFooterView = self.footerView;	// note this will override UITableView's 'sectionFooterHeight' property
	
	emailFld = [[UITextField alloc] initWithFrame:CGRectMake(100,12,200,25)];
	emailFld.keyboardType = UIKeyboardTypeEmailAddress;
	emailFld.returnKeyType = UIReturnKeyDone;
	[emailFld addTarget:self action:@selector(textFieldDidBeginEditing:) 
		forControlEvents:UIControlEventEditingDidBegin];
	[emailFld addTarget:self action:@selector(textFieldDidEndEditing:) 
		forControlEvents:UIControlEventEditingDidEndOnExit];
	
	screenNameFld = [[UITextField alloc] initWithFrame:CGRectMake(100,12,200,25)];
	screenNameFld.keyboardType = UIKeyboardTypeEmailAddress;
	screenNameFld.returnKeyType = UIReturnKeyDone;
	[screenNameFld setClearsOnBeginEditing:NO];
	[screenNameFld addTarget:self action:@selector(textFieldDidBeginEditing:) 
		forControlEvents:UIControlEventEditingDidBegin];
	[screenNameFld addTarget:self action:@selector(textFieldDidEndEditing:) 
		forControlEvents:UIControlEventEditingDidEndOnExit];
	
	passwordFld = [[UITextField alloc] initWithFrame:CGRectMake(100,12,200,25)]; 
	passwordFld.returnKeyType = UIReturnKeyDone;
	[passwordFld setSecureTextEntry:YES];
	[passwordFld addTarget:self action:@selector(textFieldDidBeginEditing:) 
		forControlEvents:UIControlEventEditingDidBegin];
	[passwordFld addTarget:self action:@selector(textFieldDidEndEditing:) 
		forControlEvents:UIControlEventEditingDidEndOnExit];
		
	passwordCfmFld = [[UITextField alloc] initWithFrame:CGRectMake(100,12,200,25)]; 
	passwordCfmFld.returnKeyType = UIReturnKeyDone;
	[passwordCfmFld setSecureTextEntry:YES];
	[passwordCfmFld addTarget:self action:@selector(textFieldDidBeginEditing:) 
		forControlEvents:UIControlEventEditingDidBegin];
	[passwordCfmFld addTarget:self action:@selector(textFieldDidEndEditing:) 
		forControlEvents:UIControlEventEditingDidEndOnExit];
	
	genderSelect = 
        [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"M",@"F", nil]];
	genderSelect.frame = CGRectMake(140,6,70,32);
	genderSelect.selectedSegmentIndex = 0;
	
	fieldsByIP = [[NSDictionary alloc] initWithObjectsAndKeys:
		emailFld,@"s2r0",
		screenNameFld,@"s0r0",
		passwordFld,@"s1r0",
		passwordCfmFld,@"s1r1"
	,nil];

	labelsByIP = [[NSDictionary alloc] initWithObjectsAndKeys:
		@"Email",@"s2r0",
		@"Name*",@"s0r0",
		@"Password*",@"s1r0",
		@"Confirm*",@"s1r1"
	,nil];
	IPsByTag = [NSMutableDictionary new];
	
	errorMessageLab.text = @"";
	
	model = [PListModel new];
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(serverDidRespond:) 
			name:@"serverDidRespond" object:model];
}

- (void) setUserData:(User *)input{
	[userData autorelease];
	userData = [input retain];
	
	//emailFld.text = userData.emailAddress;
	//screenNameFld.text = userData.screenName;
	//genderSelect.selectedSegmentIndex = userData.isFemale ? 1 : 0;
}

- (User*) userData{
	return userData;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(keyboardWasShown:)
		name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(keyboardWillBeHidden:)
		name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDissapear:(BOOL)animated {
    [super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 2:
			return 2;
		case 0:
			return 1;
		case 1:
			return 2;
	}
	return 0;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section) {
		case 2:
			return @"Optional Info";
		case 0:
			return @"Desired Screen Name";
		case 1:
			return @"Password";
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 
		reuseIdentifier:nil] autorelease];
	if(indexPath.section == 2 && indexPath.row == 1){
		cell.textLabel.text = @"Gender";
		[cell.contentView addSubview:genderSelect];
	}else{
		NSString* ipKey = [NSString stringWithFormat:@"s%dr%d",indexPath.section,indexPath.row];
		cell.textLabel.text = [labelsByIP objectForKey:ipKey];
		UITextField* aField = [fieldsByIP objectForKey:ipKey];
		int someTag = 50*indexPath.section + indexPath.row;
		aField.tag = someTag;
		[IPsByTag setObject:indexPath forKey:[NSString stringWithFormat:@"%d",someTag]];
		[cell addSubview:aField];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if(section ==2)
        return @"Email is optional for registration, but needed to reset forgotten passwords.";
    else
        return nil;
}


#pragma mark -
#pragma mark Table SaveableView overrides

- (IBAction) startRegistration{
	NSMutableArray* validationErrors = [[NSMutableArray new] autorelease];
	if(
		[screenNameFld.text isEqualToString:@""] ||
		[passwordFld.text isEqualToString:@""]
	)
		[validationErrors addObject:@"All fields except email are required."];
	if(![passwordFld.text isEqualToString:passwordCfmFld.text])
		[validationErrors addObject:@"Passwords do not match."];
	if(passwordFld.text.length < 8)
		[validationErrors addObject:@"Password must be at least 8 characters."];
	if(screenNameFld.text.length < 5 || screenNameFld.text.length > 16)
		[validationErrors addObject:@"Screen name must be between 5 and 16 characters."];
	if(validationErrors.count > 0){
		errorMessageLab.text = [validationErrors objectAtIndex:0];
		[self hideKeyboard];
		return;
	}
    
    self.userData = [[User new] autorelease];
    userData.screenName = screenNameFld.text;
    userData.password = passwordFld.text;
	
	NSString* optEmail = (emailFld.text && ![emailFld.text isEqualToString:@""]) ? emailFld.text : @" ";
	NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
		optEmail, @"email",
		screenNameFld.text, @"screenName",
		(genderSelect.selectedSegmentIndex == 0)?@"0":@"1",@"isFemale",
		passwordFld.text,@"password",nil
	];

	NSLog(@"register : %@", dict);
	
	[ActivityView presentFrom:self withMessage:@"saving..." cancelable:NO];
	[model callFunction:@"registerUser" withParams:dict];
    [dict release];
}
- (void) serverDidRespond:(NSNotification*)notification{
	[ActivityView removeSelf];
	ServerResponse* response = [[notification object] lastResponse];
	if(response.success){
		NSNumber* num = [response.resultObject valueForKey:@"newId"];
		userData.dbId = [num intValue]; 
		[delegate didCommitUser:userData];
	}else{
		errorMessageLab.text = response.errorMessage;
		[self hideKeyboard];
	}
}

- (IBAction) close {
	[delegate didDismissView];
}

- (void) hideKeyboard{
	NSString* ipKey = [NSString stringWithFormat:@"s%dr%d",currentIndexPath.section,currentIndexPath.row];
	[(UITextField*) [fieldsByIP objectForKey:ipKey] resignFirstResponder];
}
	



- (void)textFieldDidBeginEditing:(UITextField*)textField{
	NSIndexPath* ip = [IPsByTag objectForKey:[NSString stringWithFormat:@"%d",textField.tag]];
	[table scrollToRowAtIndexPath:ip
		atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
		
	self.currentIndexPath = ip;
}

- (void)textFieldDidEndEditing:(UITextField*)textField{

}

- (void)keyboardWasShown:(NSNotification*)aNotification{
    NSDictionary* info = [aNotification userInfo];
    CGFloat kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
	
	UIEdgeInsets tableInsets = UIEdgeInsetsMake(0.0, 0.0, kbHeight, 0.0);
    table.contentInset = tableInsets;
    table.scrollIndicatorInsets = tableInsets;
	[table scrollToRowAtIndexPath:currentIndexPath
		atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	
	//[UIView beginAnimations:@"" context:nil];
	//[UIView setAnimationDuration:0.5f];
	//[table setFrame:frame];
	//[UIView commitAnimations];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.5];
		table.contentInset = contentInsets;
		table.scrollIndicatorInsets = contentInsets;
	[UIView commitAnimations];
}

/*- (void) keyboardWillBeHidden:(NSNotification*)aNotification{
	[emailFld resignFirstResponder];
	[screenNameFld resignFirstResponder];
	[passwordFld resignFirstResponder];
	[passwordCfmFld resignFirstResponder];
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

//============= hideous functions to turn the labels black

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }

    // Create label with section title
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;

    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [view autorelease];
    [view addSubview:label];

    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForFooterInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }

    // Create label with section title
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(10, 6, 300, 50);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:12];
    label.text = sectionTitle;
    label.textAlignment = UITextAlignmentCenter;
    label.numberOfLines = 2;

    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [view autorelease];
    [view addSubview:label];

    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if(section == 2)
        return 40;
    else
        return 0;
}



- (void)dealloc {
	[userData release];
	[footerView release];
	[table release];

	[emailFld release];
	[screenNameFld release];
	[passwordFld release];
	[passwordCfmFld release];
	[genderSelect release];
	[errorMessageLab release];
	[fieldsByIP release];
	[labelsByIP release];
	[IPsByTag release];
	[currentIndexPath release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[model release];

	[super dealloc];
}


@end

