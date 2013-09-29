//
//  SaveableTableView.m
//  Acre
//
//  Created by Justin Armstrong on 11/20/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "SaveableTableView.h"


@implementation SaveableTableView
@synthesize dataObject, serverCall, delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
	model = [PListModel new];
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(serverDidRespond:) 
			name:@"serverDidRespond" object:model];
}



//called by save button
- (IBAction) saveAndClose{
	[ActivityView presentFrom:self withMessage:@"saving..." cancelable:YES];
	/*[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(serverDidRespond:) 
			name:@"serverDidRespond" object:model];*/
	[self save];
}
//actually closes
- (IBAction) close{
	[delegate dismissLotView];
}
//saves current data object to the server
- (void) save{
	[self rewriteData];
}

//writes current view state to data object
- (void) rewriteData{
}
//called by model
- (void) serverDidRespond:(NSNotification*)notification{
	[ActivityView removeSelf];
	
	ServerResponse* response = [[notification object] lastResponse];
    if(response.success)
        [self saveDidSucceed];
    else 
        [self saveDidFail:response];
	
}

- (void) saveDidSucceed{
	[self close];
}

-(void) saveDidFail:(ServerResponse*)response{
	if(response.errorId == 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
			message:@"Server communication error." delegate:self 
			cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show]; 
		[alert release];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

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

- (void) dealloc{
	
	[model release];
	[serverCall release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end

