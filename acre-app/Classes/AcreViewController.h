//
//  AcreViewController.h
//  Acre
//
//  Created by Justin Armstrong on 11/13/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


#import "LotEdit.h"
#import "LotItems.h"
#import "LotOffers.h"
#import "EmptyLot.h"
#import "LotView.h"
#import "Login.h"
#import "UserRegistration.h"
#import "HouseList.h"
#import "ItemList.h"
#import "LotLattice.h"
#import "PListModel.h"
#import "LotViewDelegate.h"
#import "Reachability.h"
#import "LotPolygon.h"

@interface AcreViewController : UIViewController 
<UserLoginDelegate, UserRegistrationDelegate, MKMapViewDelegate,
	LotLatticeDelegate, LotViewDelegate, CLLocationManagerDelegate> {
	//IBOutlet UITabBarController* lotAdmin;
	//LotService* lotService;
	UIView* tableBGView;
	
	IBOutlet MKMapView* theMap;
	LotLattice* lotLattice;
	LotPolygon* selectedLotPolygon;
	
	PListModel* getLotServ;
	PListModel* refreshCarryServ;
	PListModel* lotListServ;
	PListModel* userDetailServ;
	
	IBOutlet UILabel* moneyLabel;
	IBOutlet UILabel* itemsLabel;

	Lot* lotForRequery;
	BOOL isTransitionWaiting;
	BOOL isLotRequeryWaiting;
    BOOL locationFunctioning;
    BOOL hasActiveSession;
    BOOL temporaryShutdown;
	
	MKReverseGeocoder* reverseGeocoder;
	CLLocationManager* locationMgr;
    NSDate* resumeTime;
    CLLocationCoordinate2D shittyLocation;
    //Reachability* hostReach;
	
	
	NSString* statusMessage;
    
   
}
//@property (nonatomic,retain) LotService* lotService;
@property (nonatomic,retain) UIView* tableBGView;
@property (nonatomic,retain) MKMapView* theMap;
@property (nonatomic,retain) LotPolygon* selectedLotPolygon;

@property (nonatomic,retain) UILabel* moneyLabel;
@property (nonatomic,retain) UILabel* itemsLabel;

@property (nonatomic,retain) Lot* lotForRequery;

@property (nonatomic,retain) MKReverseGeocoder* reverseGeocoder;
@property (nonatomic,retain) NSString* statusMessage;
@property (nonatomic,retain) NSDate* resumeTime;

//@property (nonatomic,retain) MKMapView* acreMap;
//@property (nonatomic,retain) Login* loginView; 
//@property (nonatomic,retain) UITabBarController* lotAdmin;

- (void) startupEventDidOccur;
- (void) shutdownEventDidOccur;
- (void) tryStart;
- (void) setMapRegion:(CLLocationCoordinate2D) coordinate;

- (void) showLoginViewAnimated:(BOOL)animated;
- (void) sessionDidExpire;
- (void) tempShutdownDidTimeout;
- (void) willResignActive;

- (void) didTapMap:(UIGestureRecognizer *)sender;
- (void) showModalViewForLot:(Lot*)thisLot;
- (void) loadLotAdmin:(Lot*)thisLot;
- (void) loadLotViewer:(Lot*)thisLot;
- (void) startupEventDidOccur;
- (void) shutdownEventDidOccur;

- (void) viewWasDismissed;
- (void) tryShowRequeriedLot;
- (void) statusMessageShouldUpdate;

- (void) updateControlBar;
- (IBAction) logout;
- (IBAction) recenterMap;
- (IBAction) showResourceManager;
- (IBAction) showProfileManager;

- (void)relocateGoogleLogo;

- (UIColor*) fillColorForLotPolygon:(LotPolygon*)lp;
NSComparisonResult recentSort(id l1, id l2, void * context);
//- (void) lotWasDismissed;

@end

