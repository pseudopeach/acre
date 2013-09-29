//
//  SaveableTableView.h
//  Acre
//
//  Created by Justin Armstrong on 11/20/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerResponse.h"
#import "PListModel.h"
#import "ActivityView.h"
#import "LotViewDelegate.h"

@interface SaveableTableView : UITableViewController {
	//BOOL hasNewData;
	id dataObject;
	NSString* serverCall;
	PListModel* model;
	
	//BOOL hasOutstandingCall;
	//BOOL callWasCanceled;
	
	id <LotViewDelegate> delegate;
}
//@property (nonatomic) BOOL hasNewData;
@property (nonatomic,retain) id dataObject;
@property (nonatomic,retain) NSString* serverCall;
@property (nonatomic,retain) id <LotViewDelegate> delegate;

- (IBAction) saveAndClose;
- (IBAction) close;

//protected ==========
- (void) rewriteData; 
- (void) save;
- (void) serverDidRespond:(NSNotification*)notification;
- (void) saveDidSucceed;
- (void) saveDidFail:(ServerResponse*)response;

@end
