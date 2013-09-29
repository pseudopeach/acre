/*
 *  LotViewDelegate.h
 *  Acre
 *
 *  Created by Justin Armstrong on 3/4/11.
 *  Copyright 2011 Actinic inc. All rights reserved.
 *
 */

@class Lot;

@protocol LotViewDelegate

- (void) dismissLotView;
- (void) remapLot:(Lot*)lot;
- (void) requeryLot:(Lot*)lot;

@end