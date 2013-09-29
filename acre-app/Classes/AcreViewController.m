//
//  AcreViewController.m
//  Acre
//
//  Created by Justin Armstrong on 11/13/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "AcreViewController.h"
#import "MKMapView+Additions.h"

@implementation AcreViewController
@synthesize tableBGView, theMap, selectedLotPolygon, resumeTime,
	moneyLabel, itemsLabel, lotForRequery, reverseGeocoder, statusMessage;

/* a startup event is any of the 3 required services: 
* location, network, and server session changing to an on state
* this function does nothing until it's called and all 3 services are up
*/
- (void) startupEventDidOccur{
    [self statusMessageShouldUpdate];
	if(locationFunctioning && hasActiveSession 
    #if TARGET_IPHONE_SIMULATOR
    //nothing
    #else
        && [[Datastore getInst].hostReach currentReachabilityStatus] != NotReachable
    #endif
    ){
        NSLog(@"startup event passed");
        #if TARGET_IPHONE_SIMULATOR
            [lotLattice setGPSLocation:CLLocationCoordinate2DMake(37,-122)];
        #else
            [lotLattice setGPSLocation:locationMgr.location.coordinate];
        #endif
        self.statusMessage = @" ";
        [self statusMessageShouldUpdate];
        if(temporaryShutdown){
            //if temporary shutdown, remove the ActivityView
            [ActivityView removeSelf];
            temporaryShutdown = NO;
            return;
        }
        #if TARGET_IPHONE_SIMULATOR
            [self setMapRegion:CLLocationCoordinate2DMake(37,-122)];
        #else
            [self setMapRegion:locationMgr.location.coordinate];
        #endif
        //if here, login view must be showing
		if(!lotLattice){
			//prepare the lattice
			UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] 
			initWithTarget:self action:@selector(didTapMap:)];
			[theMap addGestureRecognizer:tapRec];
			[tapRec release];
			lotLattice = [[LotLattice alloc] initWithBox:theMap.region andDelegate:self];NSLog(@"im not dead!!");
        }
		NSLog(@"remove login view");	
		[self dismissModalViewControllerAnimated:YES];
	}
}

/*something happened that makes it so we can't process user input*/
- (void) shutdownEventDidOccur{
    if(hasActiveSession){
        //this means we are starting up without a current GPS fix, or we lost network access
        //enter temporary disabled state
        temporaryShutdown = YES;
        [ActivityView presentFrom:(self.modalViewController ? self.modalViewController : self)
            withMessage:@"aquiring signal, please wait..." cancelable:NO];
        [self performSelector:@selector(tempShutdownDidTimeout) withObject:nil afterDelay:15.0];
    }else{//if there's no session, we need a login screen
        [lotLattice removeAll];
        [self showLoginViewAnimated:YES];
    }
}
- (void) tempShutdownDidTimeout{
    //after 10 seconds in the temporary disabled state with no startup, go back to login
    if(temporaryShutdown){
        temporaryShutdown = NO;
        [ActivityView removeSelf];
        if([[Datastore getInst].hostReach currentReachabilityStatus] == NotReachable || !locationFunctioning){
            [lotLattice removeAll];
            [self showLoginViewAnimated:YES];
            hasActiveSession = NO;
            locationFunctioning = NO;
        }
    }
}

- (void) tryStart{ 
    //initiates all systems at app launch and app resume
    self.resumeTime = [NSDate dateWithTimeIntervalSinceNow:0];
    
    if(![Datastore getInst].lastServerActivity || 
    [resumeTime timeIntervalSinceDate:[Datastore getInst].lastServerActivity] > 3600.0){
        NSLog(@"Session timer triggered");
        hasActiveSession = NO;
        //locationFunctioning = NO;
        [self shutdownEventDidOccur];
    }
    else if([resumeTime timeIntervalSinceDate:[Datastore getInst].lastServerActivity] > 300.0){
        NSLog(@"medium-term timeout");
        [self shutdownEventDidOccur];
    }
	//get location
	#if TARGET_IPHONE_SIMULATOR
        NSLog(@"simulator build--preset location");
		[self locationManager:nil 
		didUpdateToLocation:[[CLLocation alloc] initWithLatitude:37.0 longitude:-122.0] 	
		fromLocation:nil]; 
	#else
        NSLog(@"device build--getting location...");
		[locationMgr startUpdatingLocation];
	#endif
    
    NSLog(@"%@",[Datastore getBaseURLStr]);
    
    if([[Datastore getInst].hostReach currentReachabilityStatus] == NotReachable)
        [self shutdownEventDidOccur];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self relocateGoogleLogo];
	//MKCoordinateRegion testRegion;
	
	locationMgr = [CLLocationManager new];
	locationMgr.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	locationMgr.distanceFilter = 10;
	locationMgr.delegate = self;

	//miami springs
	//initialCenter.latitude = 25.815;
	//initialCenter.longitude = -80.281;
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(sessionDidExpire) 
			name:@"userSessionExpired" object:nil];
	
	refreshCarryServ = [PListModel new];
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(carryListShouldRefresh:) 
			name:@"serverDidRespond" object:refreshCarryServ];
			
	lotListServ = [PListModel new];
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(getLotListDidRespond:) 
			name:@"serverDidRespond" object:lotListServ];
			
	getLotServ = [PListModel new];
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(serverDidReturnLot:) 
			name:@"serverDidRespond" object:getLotServ];	
			
	userDetailServ = [PListModel new];
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(getUserDetailDidRespond:) 
			name:@"requestDidSucceed" object:userDetailServ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange) 
        name:kReachabilityChangedNotification object:[Datastore getInst].hostReach];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
	NSLog(@"new location %f, %f accuracy:%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude,
          newLocation.horizontalAccuracy);
    
    //bullshit location filter ----------------
    if([newLocation.timestamp timeIntervalSinceDate:resumeTime] < 0){ 
        //never do anything with a stale location
        NSLog(@"throwing out old location");
        return;
    }
    if(newLocation.horizontalAccuracy > 700) {
        //shitty GPS data, hold off for 5 seconds before accepting
        self.statusMessage = @"Reticulating lots...";
        locationFunctioning = NO;
        shittyLocation = newLocation.coordinate;
        [self statusMessageShouldUpdate];
        [self performSelector:@selector(settleForShittyLocation) withObject:nil afterDelay:1.5];
        return;
    }
    //--------------------- END Location filter
    
    locationFunctioning = YES;

    if(lotLattice && oldLocation && [oldLocation distanceFromLocation:newLocation] < 200){
        NSLog(@"detected small location change--redrawing lattice");
        [lotLattice setGPSLocation:newLocation.coordinate];
    }else{
        NSLog(@"detected large location change (or no lattice yet)");
        //[self setNewLocation:newLocation.coordinate];
        [self startupEventDidOccur];
    }
}
- (void) settleForShittyLocation{
    if(!locationFunctioning){
        NSLog(@"settling for shitty location accuracy");
        locationFunctioning = YES;
        //[self setNewLocation:shittyLocation];
        [self startupEventDidOccur];
    }
}

/* setNewLocation runs on startup, or in case of large location changes*/
- (void) setMapRegion:(CLLocationCoordinate2D) coordinate{
    MKCoordinateRegion mapRegion;
    mapRegion.center = coordinate;
    mapRegion.span.latitudeDelta = 9.0/3600.0;
    mapRegion.span.longitudeDelta = .000001;
    [theMap setRegion:mapRegion animated:YES];
    
    //set the GPS lattice center (GPS location)
    /*[lotLattice setGPSLocation:coordinate];
    //recenter the map in the same location
    if(hasActiveSession)
        [theMap setRegion:mapRegion animated:YES];
    else    NSLog(@"didn't update map region");*/
    //changing the map region also triggers the lattice frame to change
    //prevent set map region if no login session
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	NSLog(@"Location Error: %@", [error description]);
		
	locationFunctioning = NO;
	//[self shutdownEventDidOccur];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	if(lotForRequery){
		isTransitionWaiting = NO;
		[self tryShowRequeriedLot];
	}
	if(![Datastore getInst].currentSession || [Datastore getInst].currentSession.dbId == 0){
		[self showLoginViewAnimated:NO];
	}
}

- (void) sessionDidExpire{
    //if we get a 401 or errorId 1 from the server, we need to log in again
    //nothing happens unless this we previously had a session
    BOOL hadActiveSession = hasActiveSession;
	hasActiveSession = NO;
    if(hadActiveSession){
        self.statusMessage = @"Session expired. Please login again.";
        [self shutdownEventDidOccur];
    }
}

- (void) reachabilityDidChange{
    if([[Datastore getInst].hostReach currentReachabilityStatus] == NotReachable){
        NSLog(@"Network connection lost");
        [self shutdownEventDidOccur];
    }else if(temporaryShutdown){
        NSLog(@"network connection restored!");
        [self startupEventDidOccur];
    }
        
}

- (void) loginDidSucceed:(ServerResponse*)loginInfo{
	self.statusMessage = @"";
	NSDictionary* resultObject = loginInfo.resultObject;
	
	//get devlist
	Datastore* datastoreInst = [Datastore getInst];
	//populate session
	[datastoreInst.currentSession setValuesForKeysWithDictionary:
		[resultObject valueForKey:@"sessionInfo"]];
	[datastoreInst saveSession];
	
	NSMutableArray* allItems = [resultObject valueForKey:@"allItems"];
	[datastoreInst setAllItemsWithArray:allItems];
	NSMutableArray* carriedItems = [resultObject valueForKey:@"carriedItems"];
	datastoreInst.carriedItems = carriedItems;
	NSMutableArray* allDevs = [resultObject valueForKey:@"allDevelopments"];
	datastoreInst.allDevelopments = allDevs;
	
	datastoreInst.carryLimit = [(NSNumber*)[resultObject valueForKey:@"carryLimit"] intValue];
	[self updateControlBar];
	
	hasActiveSession = YES;
    NSString* loginMsg = [resultObject valueForKey:@"notice"];
    if(loginMsg && ![loginMsg isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
            message:loginMsg delegate:self 
            cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
        [alert show]; 
        [alert release];
    }
    
	[self startupEventDidOccur];
}
- (NSString*) statusMessageForLoginView{
    if([statusMessage isEqualToString:@""]){
        if(!hasActiveSession)
            return @"Logging in...";
        else if(!locationFunctioning)
            return @"Finding location...";
    }
	return statusMessage;
}

- (void) statusMessageShouldUpdate{
    id modal = self.modalViewController;
    if(modal && [modal isKindOfClass:[Login class]])
        [(Login*) modal statusDidChange];
}

//============== modal view functions ===================================

- (void) serverDidReturnLot:(NSNotification*)notification{
    [ActivityView removeSelf];
	ServerResponse* response = [[notification object] lastResponse];
    if(response.success){
        Lot* thisLot = [Lot new];
        [thisLot setValuesForKeysWithDictionary:response.resultObject];
        if(lotForRequery){ //catch server answer and send it to tryShow
            self.lotForRequery = thisLot;
            isLotRequeryWaiting = NO;
            [self tryShowRequeriedLot];
        }else //normal response
            [self showModalViewForLot:thisLot];
        [thisLot release];
    }else{ //if get lot failed...
        if(selectedLotPolygon){
            MKPolygonView* pv = (MKPolygonView*) [theMap viewForOverlay:selectedLotPolygon];
            pv.strokeColor = [UIColor blackColor];
            pv.fillColor = [self fillColorForLotPolygon:selectedLotPolygon];
            self.selectedLotPolygon = nil;
        }
        NSString* msg = [NSString stringWithFormat:@"Failed to get lot. errorId: %d",response.errorId];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                    message:msg delegate:self 
          cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
		[alert show]; 
		[alert release];
    }
}

- (void) showModalViewForLot:(Lot*)thisLot{
	if(thisLot.dbId != 0 && thisLot.ownerId != [Datastore getInst].currentSession.dbId)
		[self loadLotViewer:thisLot];
	else 
		[self loadLotAdmin:thisLot];
}
- (void) tryShowRequeriedLot{
	if(isTransitionWaiting || isLotRequeryWaiting)
		return;
	[self showModalViewForLot:lotForRequery];
	self.lotForRequery = nil;
}

- (void) loadLotAdmin:(Lot*)thisLot{
	
	//configure tab bar
	UITabBarController* lotAdmin = [UITabBarController new];
	lotAdmin.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_regular.png"]];
	
	//we always have some tabs and an items view
	NSMutableArray* tabViews;
	LotItems* lotItemsView = [[LotItems alloc] initWithNibName:@"LotItems" bundle:nil];
	lotItemsView.title = @"Items";
	lotItemsView.tabBarItem.image = [UIImage imageNamed:@"Tab_Items.png"];
	lotItemsView.lotData = thisLot;
	lotItemsView.delegate = self;
	
	if(thisLot.dbId == 0){
		EmptyLot* emptyLotView = [EmptyLot new];
		emptyLotView.title = @"Claim";
		emptyLotView.tabBarItem.image = [UIImage imageNamed:@"Tab_Controls.png"];
		emptyLotView.lotData = thisLot;
		emptyLotView.delegate = self;
		
		tabViews = [[NSMutableArray alloc] initWithObjects:
			emptyLotView, lotItemsView,  nil];
		
		[emptyLotView release];
	}else{
		//make a nav controller
		LotEdit* lotEditView = [[LotEdit alloc] initWithStyle:UITableViewStyleGrouped];
		UINavigationController*  navController = [[UINavigationController alloc]
			initWithRootViewController:lotEditView];
		navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
		
		//make the tab controllers
		lotEditView.title = @"Control";
		lotEditView.tabBarItem.image = [UIImage imageNamed:@"Tab_Controls.png"];
		
		//fill the tab views array
		tabViews = [[NSMutableArray alloc] initWithObjects:
			navController, lotItemsView, nil];
		
		if([thisLot.devTypeType isEqualToString:@"factory"] || [thisLot.devTypeType isEqualToString:@"store"]){
			LotOffers* lotOffersView = [LotOffers new];
			lotOffersView.title = @"Offers";
			lotOffersView.tabBarItem.image = [UIImage imageNamed:@"Tab_Offers.png"];
			lotOffersView.lotData = thisLot;
			lotOffersView.delegate = self;
			[tabViews insertObject:lotOffersView atIndex:tabViews.count];
			[lotOffersView release];
		}
		
		//load data
		lotEditView.lotData = thisLot;
		lotEditView.delegate = self;
		//cleanup
		[lotEditView release];
		[navController release];
	}
	
	lotAdmin.viewControllers = tabViews;
	
	//deploy controller
	lotAdmin.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:lotAdmin animated:YES];
	
	//cleanup
	
	[lotItemsView release];
	[tabViews release];
	[lotAdmin release];
}

- (void) dismissLotView{
	[self dismissModalViewControllerAnimated:YES];
	if(selectedLotPolygon){
		MKPolygonView* pv = (MKPolygonView*) [theMap viewForOverlay:selectedLotPolygon];
		pv.strokeColor = [UIColor blackColor];
		pv.fillColor = [self fillColorForLotPolygon:selectedLotPolygon];
		self.selectedLotPolygon = nil;
	}
	[refreshCarryServ callFunction:@"getCarriedItems" withParams:nil];

}

- (void) remapLot:(Lot*)lot{
	LotPolygon* lp = [lotLattice lotPolygonAt:lot.ci Cj:lot.cj];
	lp.ownerId = lot.ownerId;
	lp.devTypeId = lot.devTypeId;
	if(lp.developmentIcon)
		[theMap removeAnnotation:lp.developmentIcon];
	lp.developmentIcon = [[[LotAnnotation alloc] 
		initWithlocation:lp.coordinate andDevTypeId:lot.devTypeId] autorelease]; 
	NSArray* oneLp = [[NSArray alloc] initWithObjects:lp,nil];
	[self refreshPolygons:oneLp];
    [oneLp release];
}

- (void) requeryLot:(Lot *)lot{
	self.lotForRequery = lot;
	isTransitionWaiting = YES;
	isLotRequeryWaiting = YES;
	NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
			[NSString stringWithFormat:@"%d",lotForRequery.ci],@"Ci",
			[NSString stringWithFormat:@"%d",lotForRequery.cj],@"Cj", nil];
	[getLotServ callFunction:@"getLot" withParams:params];
	[params release];
}

- (void) viewWasDismissed{
	[self dismissModalViewControllerAnimated:YES];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReadyForDismissal" object:nil];
}

- (void) carryListShouldRefresh:(NSNotification*)notification{
	ServerResponse* response = [[notification object] lastResponse];
	if(response.success){
		[Datastore getInst].carriedItems = response.resultQuery;
		[self updateControlBar];
	}else 
		NSLog(@"failed to retreive item list");
}
- (void) didCommitUser:(User *)user{
	NSLog(@"didCommitUser stub");
}

- (void) loadLotViewer:(Lot*)thisLot{
	LotView* lotView = [[LotView alloc] initWithNibName:@"LotView" bundle:nil];
	lotView.lotData = thisLot;
	UINavigationController*  navController = [[UINavigationController alloc]
		initWithRootViewController:lotView];
	
	navController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_regular.png"]];
	navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	lotView.delegate = self;
	[self presentModalViewController:navController animated:YES];
	[lotView release];
}

- (IBAction) logout{
    hasActiveSession = NO;
    self.statusMessage = @"Logged out";
	PListModel* logoutServ = [PListModel new];
	[logoutServ callFunction:@"logoutUser" withParams:nil];
    [logoutServ release];
	[self shutdownEventDidOccur];
}

- (void) showLoginViewAnimated:(BOOL)animated{
	Login* loginView = [[Login alloc] initWithNibName:@"Login" bundle:nil];
	//loginView.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_regular.png"]];
	
	loginView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	loginView.delegate = self;
	[self presentModalViewController:loginView animated:animated];
	
	
}
- (IBAction) showResourceManager{
	[ActivityView presentFrom:self withMessage:@"loading..." cancelable:YES];
	[lotListServ callFunction:@"getPayableLots" withParams:nil];
}

- (void) getLotListDidRespond:(NSNotification*)notification{
	[ActivityView removeSelf];
	ServerResponse* response = [[notification object] lastResponse];
	if(!response.success) return;
	
	//cast all the dictionaries into Lots and make the lotList array
	NSMutableArray* lotList = [[NSMutableArray alloc] initWithCapacity:response.resultQuery.count];
	for(int i=0;i<response.resultQuery.count;i++){
		NSDictionary* dict = [response.resultQuery objectAtIndex:i];
		Lot* lot = [Lot new];
		[lot setValuesForKeysWithDictionary:dict];
		[lotList insertObject:lot atIndex:i];
		[lot release];
	}
	
	UITabBarController* lotListTabs = [UITabBarController new];
	HouseList* lotListByHouseView = [HouseList new];
	HouseList* lotListByDateView = [HouseList new];
	
	UINavigationController*  navControllerHouse = [[UINavigationController alloc]
		initWithRootViewController:lotListByHouseView];
	navControllerHouse.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	UINavigationController*  navControllerDate = [[UINavigationController alloc]
		initWithRootViewController:lotListByDateView];
	navControllerDate.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	
	lotListByHouseView.title = @"By House";
	lotListByHouseView.tabBarItem.image = [UIImage imageNamed:@"Tab_House.png"];
	
	lotListByDateView.title = @"By Date";
	lotListByDateView.tabBarItem.image = [UIImage imageNamed:@"Tab_ByDate.png"];
	
	lotListByHouseView.lotList = lotList;
	lotListByHouseView.isLeaf = NO;
	lotListByHouseView.delegate = self;
	
	lotListByDateView.lotList = [lotList sortedArrayUsingFunction:recentSort context:NULL];
	lotListByDateView.isLeaf = YES;
	lotListByDateView.delegate = self;
	
	ItemList* itemList = [[ItemList alloc] initWithNibName:@"ItemList" bundle:nil];
	itemList.title = @"Items";
	itemList.tabBarItem.image = [UIImage imageNamed:@"Tab_Items.png"];
	itemList.delegate = self;
	
	NSArray* tabViews = [[NSArray alloc] initWithObjects:
		itemList, navControllerHouse, navControllerDate, nil];
	lotListTabs.viewControllers = tabViews;
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
		selector:@selector(viewWasDismissed) 
		name:@"ReadyForDismissal" object:nil];
	lotListTabs.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:lotListTabs animated:YES];
	
    [lotList release];
	[lotListByHouseView release];
	[lotListByDateView release];
	[tabViews release];
	[lotListTabs release];
	[itemList release];
	
	[navControllerDate release];
	[navControllerHouse release];
}

- (IBAction) showProfileManager{
	[ActivityView presentFrom:self withMessage:@"loading..." cancelable:YES];
	NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
		[Datastore getInst].currentSession.screenName,@"screenName",nil];
	[userDetailServ callFunction:@"getUser" withParams:params];
	[params release];
}
- (void) getUserDetailDidRespond:(NSNotification*)notification{
	[ActivityView removeSelf];
	ServerResponse* response = [[notification object] lastResponse];
	if(!response.success) return;
	
    
	User* user = [User new];
	[user setValuesForKeysWithDictionary:response.resultObject];
	
	UserDetail* detailView = [[UserDetail alloc] initWithNibName:@"UserDetail" bundle:nil];
	detailView.userData = user;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:detailView];
    nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
            style:UIBarButtonItemStyleBordered target:self action:@selector(didDismissView)];
	detailView.navigationItem.rightBarButtonItem = cancelButton;
    nav.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_regular.png"]];
    
	[self presentModalViewController:nav animated:YES];
	
	[user release];
	[detailView release];
    [nav release];
    [cancelButton release];
}

- (IBAction) recenterMap{
    #if TARGET_IPHONE_SIMULATOR
        [theMap setCenterCoordinate:CLLocationCoordinate2DMake(37,-122) animated:YES];
    #else
        [theMap setCenterCoordinate:locationMgr.location.coordinate animated:YES];
    #endif
}


/*- (void) didCommitUser:(User*)user{
	//populate status bar
	[[Datastore getInst] saveSession];
	[self didDismissView];
}*/

//===================== housekeeping ===================================

- (void) didDismissView{
	[self dismissModalViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    /*[super didReceiveMemoryWarning];
    if(lotLattice.lotCount > 100){
        NSLog(@"memory warning, resetting lattice...");
        [lotLattice reset];
    }*/
}


NSComparisonResult recentSort(id l1, id l2, void * context) {
	Lot* lot1 = l1;
	Lot* lot2 = l2;
    return [lot1.rentDue compare:lot2.rentDue];
}

- (void) updateControlBar{
	NSArray* items = [Datastore getInst].carriedItems;
	int moneyBalance = 0;
	int itemCount = 0;
	for(int i=0;i<items.count;i++){
		Item* anItem = [items objectAtIndex:i];
		if(anItem.typeId == 1)
			moneyBalance += anItem.qty;
		else
			itemCount += anItem.qty;
	}
	moneyLabel.text =
		[NSNumberFormatter 
			localizedStringFromNumber:[NSNumber numberWithInt:moneyBalance] 
			numberStyle:NSNumberFormatterDecimalStyle];
	itemsLabel.text = [NSString stringWithFormat:@"%d / %d",itemCount, [Datastore getInst].carryLimit];
}

// MAP STUFF =======================================

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
	[lotLattice setBox:theMap.region];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay{
	LotPolygon* lp = overlay;
	MKPolygonView* pv = [[MKPolygonView alloc] initWithOverlay:lp.polygon];
	pv.strokeColor = [UIColor colorWithRed:0.58984375 green:0.50390625 blue:0.3515625 alpha:0.75];
	pv.fillColor = [self fillColorForLotPolygon:lp];
	pv.alpha = .8;
	pv.lineWidth = 1.0;
	//pv.fillAlpha = 0.5;
    return [pv autorelease];
    } 

- (void) didTapMap:(UIGestureRecognizer *)sender {
	//if(!locationFunctioning) return;
	
    CGPoint tapPoint = [sender locationInView:theMap];
	
	self.selectedLotPolygon = [lotLattice lotPolygonContainingCoordinate:
		[theMap convertPoint:tapPoint toCoordinateFromView:theMap]];
	if(selectedLotPolygon){
        [ActivityView presentFrom:self withMessage:@"loading lot..." cancelable:YES];
		NSLog(@"tapped: %d, %d : %f, %f",selectedLotPolygon.Ci,selectedLotPolygon.Cj,
			selectedLotPolygon.bottomLat,selectedLotPolygon.leftLon);
		MKPolygonView* pv = (MKPolygonView*) [theMap viewForOverlay:selectedLotPolygon];
		
		pv.fillColor = [UIColor colorWithRed:0.168627451 green:0.843137255 blue:1.0 alpha:0.8];
		//show activity
		//query server
		NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
			[NSString stringWithFormat:@"%d",selectedLotPolygon.Ci],@"Ci",
			[NSString stringWithFormat:@"%d",selectedLotPolygon.Cj],@"Cj", nil];
		[getLotServ callFunction:@"getLot" withParams:params];
		[params release];
		
	}
	//CLLocationCoordinate2D c = {70.0,-90.0};
	
	//[theMap setCenterCoordinate:c];
}

- (void) addPolygons:(NSArray*)somePolygons{
	[theMap addOverlays:somePolygons];
}
- (void) refreshPolygons:(NSArray*)somePolygons{
	for(int i=0;i<somePolygons.count;i++){
		LotPolygon* lp = [somePolygons objectAtIndex:i];
		MKPolygonView* pv = (MKPolygonView*) [theMap viewForOverlay:lp];
		pv.fillColor = [self fillColorForLotPolygon:lp];
		[theMap addAnnotation:lp.developmentIcon]; //development icon is null
	}
}
- (void) removePolygons:(NSArray*)somePolygons andTheirIcons:(NSArray*)icons{
	[theMap removeAnnotations:icons];
	[theMap removeOverlays:somePolygons];
}
- (UIColor*) fillColorForLotPolygon:(LotPolygon*)lp{
	if(lp.ownerId == 0)
		return [UIColor clearColor];
	else if(lp.ownerId == [Datastore getInst].currentSession.dbId)
		return [UIColor colorWithRed:0.640625 green:0.83984375 blue:0.54296875 alpha:0.9];//
	else return [UIColor colorWithRed:0.58984375 green:0.50390625 blue:0.3515625 alpha:0.4];//30% brown 2
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(LotAnnotation*)annotation{
	//MKAnnotationView* devIcon = [theMap dequeueReusableAnnotationViewWithIdentifier:@"dev"];
	//if(!devIcon)
    if(![annotation isKindOfClass:[LotAnnotation class]])
        return nil;
	MKAnnotationView*	devIcon = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"dev"];
	devIcon.image = [Datastore imageForDevWithId:annotation.devTypeId];

	return [devIcon autorelease];
}

//==================================================

- (void) willResignActive{
    lotLattice.allowLocationCheckin = NO;
	[locationMgr stopUpdatingLocation];
    locationFunctioning = NO;
    id modal = self.modalViewController;
    if(modal && ![modal isKindOfClass:[Login class]])
        if(selectedLotPolygon)
            [self dismissLotView];
        else
            [self dismissModalViewControllerAnimated:NO];
}

- (void)relocateGoogleLogo {
	UIImageView *logo = [theMap googleLogo];
	if (logo == nil)
		return;

	CGRect frame = logo.frame;
	frame.origin.y = 40 - frame.size.height - frame.origin.x;
	logo.frame = frame;
}


- (void)dealloc {
	[getLotServ release];
	[refreshCarryServ release];
	[lotListServ release];
	[userDetailServ release];
	
	[theMap release];
	[selectedLotPolygon release];
    [resumeTime release];
	
	[moneyLabel release];
	[itemsLabel release];
	
	[lotForRequery release];
	[reverseGeocoder release];
	[locationMgr release];
	[statusMessage release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
