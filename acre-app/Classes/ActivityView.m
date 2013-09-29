//
//  ActivityView.m
//  Acre
//
//  Created by Justin Armstrong on 12/26/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "ActivityView.h"

static ActivityView* inst;

@implementation ActivityView
@synthesize indicatorView, cancelButton, actionLabel, isCancelable;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[indicatorView startAnimating];
	/*cancelButton.alpha = 0;
	cancelButton.enabled = NO;
	actionLabel.text = message;
	if(isCancelable)
		[self performSelector:@selector(showCancelBtn) withObject:nil afterDelay:5.0];*/
}

- (NSString*) message {
	return message;
}
- (void) setMessage:(NSString *)input{
	[message autorelease];
	message = [input retain];
	actionLabel.text = message;
	if(isCancelable){
		cancelButton.alpha = .7;
        cancelButton.enabled = YES;
    }else{
		cancelButton.alpha = 0;
        cancelButton.enabled = NO;
    }
}


- (void)viewWillDisappear: (BOOL)animated{
	[indicatorView stopAnimating];
	[super viewWillDisappear:animated];
}


- (IBAction) cancelAction{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ServerCallShouldBeCanceled" object:self];
    [ActivityView removeSelf];
}

+ (id) presentFrom:(UIViewController*)parentView withMessage:(NSString*)message cancelable:(BOOL)cancelable{
	if(!inst){
		inst = [ActivityView new] ;
        [[NSNotificationCenter defaultCenter] addObserver:inst selector:@selector(removeSelf) 
        name:@"connectionDidFail" object:nil];
    }
    inst.isCancelable = cancelable;
	inst.message = message;
	[parentView.view addSubview:inst.view];
	return inst;
}

+ (void) removeSelf{
	[inst.view removeFromSuperview];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[indicatorView release];
	[cancelButton release];
	[actionLabel release];
	[message release];
	[inst release];

    [super dealloc];
}


@end
