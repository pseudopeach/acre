//
//  MKMapView+Additions.m
//  Acre
//
//  Created by Justin on 5/5/11.
//  Copyright 2011 Actinic inc. All rights reserved.
//

#import "MKMapView+Additions.h"


@implementation MKMapView (Additions)

- (UIImageView*)googleLogo {
	UIImageView *imgView = nil;
	for (UIView *subview in self.subviews) {
		if ([subview isMemberOfClass:[UIImageView class]]) {
			imgView = (UIImageView*)subview;
			break;
		}
	}

	return imgView;
}

@end

