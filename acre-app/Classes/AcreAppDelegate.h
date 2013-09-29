//
//  AcreAppDelegate.h
//  Acre
//
//  Created by Justin Armstrong on 11/13/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AcreViewController;

@interface AcreAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AcreViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AcreViewController *viewController;

@end

