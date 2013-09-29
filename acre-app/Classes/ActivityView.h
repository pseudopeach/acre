//
//  ActivityView.h
//  Acre
//
//  Created by Justin Armstrong on 12/26/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ActivityView : UIViewController {
	IBOutlet UIActivityIndicatorView* indicatorView;
	IBOutlet UIButton* cancelButton;
	IBOutlet UILabel* actionLabel;
	BOOL isCancelable;
	NSString* message;
}

@property (nonatomic,retain) UIActivityIndicatorView* indicatorView;
@property (nonatomic,retain) UIButton* cancelButton;
@property (nonatomic,retain) UILabel* actionLabel;
@property (nonatomic) BOOL isCancelable;
@property (nonatomic,retain) NSString* message;

+ (id) presentFrom:(UIViewController*)parentView withMessage:(NSString*)message cancelable:(BOOL)cancelable;
+ (void) removeSelf;

- (IBAction) cancelAction;


@end
