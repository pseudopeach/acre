//
//  SaveableView.h
//  Acre
//
//  Created by Justin Armstrong on 11/27/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerResponse.h"
#import "PListModel.h"
#import "ActivityView.h"
#import "LotViewDelegate.h"

@interface SaveableView : UIViewController {
	//BOOL hasNewData;
	id dataObject;
	NSString* serverCall;
	PListModel* model;
	
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
