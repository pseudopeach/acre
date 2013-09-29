//
//  LotLattice.m
//  Acre
//
//  Created by Justin Armstrong on 12/2/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "LotLattice.h"
#import "LotPolygon.h"


@implementation LotLattice
@synthesize lotsByLocation, lotArray, lotRequests,
outsideMaxBuffer, outsideMaxRange, allowLocationCheckin, delegate;



//double lonCoeff(
- (id) initWithBox:(MKCoordinateRegion)input andDelegate:(id<LotLatticeDelegate>)del{
	if((self = [super init])){
        NSLog(@"initializing lattice");
		self.delegate = del;
		//model = [PListModel new];
		/*[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(serverDidRespond:) 
			name:@"serverDidRespond" object:model];*/
		lotArray = [[NSMutableArray alloc] initWithCapacity:200];
        //self.unrequitedLots = @"";
        NSMutableArray* reqList = [[NSMutableArray alloc] initWithCapacity:3];
        self.lotRequests = reqList;
        [reqList release];
		[self setGPSLocation:input.center];
		[self setBox:input];
	}
	return self;
}
- (MKCoordinateRegion) box{
	return box;
}
- (void) removeAll{
	NSArray* iconsToRemove = [self lotAnnotationsForLots:lotArray];
	[delegate removePolygons:lotArray andTheirIcons:iconsToRemove];
	[lotArray removeAllObjects];
	[self reconstuctDictionary];
}
- (void) reset{
	[self removeAll];
	[self setBox:box];
}

/* setBox sets the viewing frame of the map and generates all the necesary lot polygons*/
- (void) setBox:(MKCoordinateRegion)input{
	NSLog(@"starting lattice setBox");
	
	double thisBandTopLat;
	double thisLon;
	
	int leftCj;
	int rightCj;
	
	int bottomCi;
    int topCi;
	NSMutableArray* leftCjs;
	NSMutableArray* rightCjs;
    
	box = input;
	bottomLat = box.center.latitude - box.span.latitudeDelta * innerBufferScale;
	topLat = box.center.latitude + box.span.latitudeDelta * innerBufferScale;
	leftLon = box.center.longitude - box.span.longitudeDelta * innerBufferScale;
	rightLon = box.center.longitude + box.span.longitudeDelta * innerBufferScale;
	
	bufferMinLat = box.center.latitude - box.span.latitudeDelta * outerBufferScale;
	bufferMaxLat = box.center.latitude + box.span.latitudeDelta * outerBufferScale;
	bufferMinLon = box.center.longitude - box.span.longitudeDelta * outerBufferScale;
	bufferMaxLon = box.center.longitude + box.span.longitudeDelta * outerBufferScale;

	//box.center.latitude + box.span.latitudeDelta;
	self.outsideMaxBuffer = [NSPredicate predicateWithFormat:
		@"bottomLat > %f || topLat < %f || leftLon > %f || rightLon < %f",
		bufferMaxLat, bufferMinLat, bufferMaxLon, bufferMinLon];
	
	bottomCi = floor(bottomLat/latCoeff);
	topCi = ceil(topLat/latCoeff);
	//NSLog(@"coordinate box lat:%f lon:%f",box.span.latitudeDelta,box.span.longitudeDelta);
	
	double thisBandBottomLat = latCoeff*bottomCi;
	int latBands = topCi - bottomCi;
	
	leftCjs = [[NSMutableArray alloc] initWithCapacity:latBands];
	rightCjs = [[NSMutableArray alloc] initWithCapacity:latBands];
	
	NSMutableArray* lotsToAdd = [[NSMutableArray alloc] initWithCapacity:75];
	//loop through each lat band
	for(int i=bottomCi;i<=topCi;i++){
		double lonCoeff = calcLonCoeff(i);
		
		//populate border arrays
		leftCj = floor(leftLon/lonCoeff);
		rightCj = ceil(rightLon/lonCoeff);
		[leftCjs insertObject:[NSNumber numberWithDouble:leftCj]
			atIndex:(i - bottomCi)];
		[leftCjs insertObject:[NSNumber numberWithDouble:rightCj]
			atIndex:(i - bottomCi)];

		//initialize vars for this band
		thisBandTopLat = thisBandBottomLat + latCoeff;
		thisLon = lonCoeff*leftCj;
		
		for(int j=leftCj;j<=rightCj;j++){
			if(![lotsByLocation objectForKey:[LotPolygon keyStringWithLocationCi:i andCj:j]]
			&& pow(thisBandBottomLat-GPSLocation.latitude,2)
			+  pow(thisLon-GPSLocation.longitude,2)/longitudeScale <= maxRangeSquared){
				//lot is not already here
				LotPolygon* newLP = [[LotPolygon alloc] initWithRect:thisBandTopLat 
					right:thisLon+lonCoeff bottom:thisBandBottomLat left:thisLon];
				thisLon = newLP.rightLon;
				newLP.Ci = i;
				newLP.Cj = j;
				[lotsToAdd insertObject:newLP atIndex:lotsToAdd.count];
				[newLP release];
			}else
				thisLon += lonCoeff; //still need to keep this going
		} // end j loop
		
		//new bottom is the top
		thisBandBottomLat = thisBandTopLat;
	} // end bands loop (i loop)
    
    [leftCjs release];
    [rightCjs release];
	
	//lotsToAdd is now ready
	
	NSArray* lotsToRemove = [lotArray filteredArrayUsingPredicate:outsideMaxBuffer];
	NSArray* iconsToRemove = [self lotAnnotationsForLots:lotsToRemove];
			
	[delegate removePolygons:lotsToRemove andTheirIcons:iconsToRemove];
	[lotArray removeObjectsInArray:lotsToRemove];
	
	//hopefully, that cleared up enough memory for the stuff we need to add
	[delegate addPolygons:lotsToAdd];
	[lotArray addObjectsFromArray:lotsToAdd];
	
	NSLog(@"update lotArray. add:%d, remove:%d newTotal:%d",lotsToAdd.count, lotsToRemove.count, lotArray.count);
	
	[self reconstuctDictionary];
    
    //if there are new lots being added, ask the server about them
	if(lotsToAdd.count > 0){
        NSString* lotList = [lotsToAdd componentsJoinedByString:@","];
		LotPolygon* centerLot = [self lotPolygonContainingCoordinate:box.center];
        
		NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
			[NSString stringWithFormat:@"%d",centerLot.Ci],@"centerCi",
			[NSString stringWithFormat:@"%d",centerLot.Cj],@"centerCj",
			lotList,@"lotList",nil];
            
        /*  if we have a new location to report and location reporting isn't blocked by
        *   the delegate (due to staleness) add this location info to the server request params
        */
		if(hasNewGPSLocation && allowLocationCheckin){
			hasNewGPSLocation = NO;
			[params setObject:[NSString stringWithFormat:@"%f",GPSLocation.latitude] 
				forKey:@"GPSLatitude"];
			[params setObject:[NSString stringWithFormat:@"%f",GPSLocation.longitude]  
				forKey:@"GPSLongitude"];
		}
        
        PListModel* model = [PListModel new];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                selector:@selector(serverDidRespond:) 
                name:@"serverDidRespond" object:model];
                
        //model instances are stored in the lotRequests array until they return data
        [lotRequests insertObject:model atIndex:lotRequests.count];
        
        //the actual server call
		[model callFunction:@"getLotsInRange" withParams:params];
        
		[params release];
        [model release];
	}
	//clean up
	[lotsToAdd release];
}

/*  setGPSLocation changes the GPS location, which is the center of the 'circle' of viewable lots, 
*   but leaves the viewing frame as is. Stores this location to report to the server on next
*   getLotsInRange request
*/
- (void) setGPSLocation:(CLLocationCoordinate2D)location{
	NSLog(@"new lattice GPS location: %f, %f", location.latitude, location.longitude);
    self.allowLocationCheckin = YES;
	GPSLocation = location;
	longitudeScale = pow(cos(bottomLat*M_PI/180.0),2);
	self.outsideMaxRange = [NSPredicate predicateWithFormat:
		@"(bottomLat - %f)*(bottomLat - %f) + (leftLon - %f)*(leftLon - %f)/%f > %f",
		GPSLocation.latitude, GPSLocation.latitude,
		GPSLocation.longitude, GPSLocation.longitude,
		longitudeScale,maxRangeSquared];
	hasNewGPSLocation = YES;
	
    [self doRangeCleanup];
}

+ (CLLocationCoordinate2D) locationOfCi:(int)Ci Cj:(int)Cj{
	CLLocationCoordinate2D result;
	result.latitude = latCoeff*Ci;
	result.longitude = calcLonCoeff(Ci)*Cj;
	return result;
}

- (void) serverDidRespond:(NSNotification*)notification{
    PListModel* model = [notification object];
	ServerResponse* response = [model lastResponse];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serverDidRespond" object:model];
    
	if(!response.success){
		if(response.errorId == 3){
            NSString* str1 = @"We're getting some strange data from your device's GPS. Please move into a more open area.";
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                    message:str1 
				 delegate:self
				cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
			[alert show]; 
			[alert release];
        }else if(response.errorId == -1){
            return; //supress server errors
		}else{
			NSString* msg = [NSString stringWithFormat:@"Failed to get map data. errorId:%d",response.errorId];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
				message:msg delegate:self 
				cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
			[alert show]; 
			[alert release];
		}
		return;
	}/*else
        hasFirstGPSLocation = YES;*/
    
    NSArray* serverLots = [response.resultQuery retain]; 
    [lotRequests removeObject:model];       //once we pull out the lot array, drop the rest of the model
    NSMutableArray* lotsToRefresh = [[NSMutableArray alloc] initWithCapacity:serverLots.count];
    
    LotPolygon* thisLP;
    for(int i=0;i<serverLots.count;i++){
        NSDictionary* item = [serverLots objectAtIndex:i];
        
        NSString* lotHash = [item valueForKey:@"hash"];
        NSNumber* lotOwnerId = [item valueForKey:@"ownerId"];
        NSNumber* lotDevTypeId = [item valueForKey:@"devTypeId"];
        
        if((thisLP = [lotsByLocation objectForKey:lotHash])){
            thisLP.ownerId = [lotOwnerId intValue];
            thisLP.devTypeId = [lotDevTypeId intValue];
            LotAnnotation* newLA = [[LotAnnotation alloc] 
                initWithlocation:thisLP.coordinate 
                andDevTypeId:thisLP.devTypeId];
            thisLP.developmentIcon = newLA;
            [newLA release];
            [lotsToRefresh insertObject:thisLP atIndex:lotsToRefresh.count];
        }        
    }
    
    [delegate refreshPolygons:lotsToRefresh];
    
    [serverLots release];
    [lotsToRefresh release];
    
}

- (LotPolygon*) lotPolygonAt:(int)ci Cj:(int)cj{
	NSString* keyStr = [LotPolygon keyStringWithLocationCi:ci andCj:cj];	
	return [lotsByLocation objectForKey:keyStr];
}
- (LotPolygon*) lotPolygonContainingCoordinate:(CLLocationCoordinate2D)coord{	
	int ci = floor(coord.latitude/latCoeff);
	int cj = floor(coord.longitude/calcLonCoeff(ci));
	return [self lotPolygonAt:ci Cj:cj];
}


- (void) reconstuctDictionary{
	NSMutableArray* keys = [[NSMutableArray alloc] initWithCapacity:lotArray.count];
	for(int i=0;i<lotArray.count;i++){
		LotPolygon* lp = [lotArray objectAtIndex:i];
		[keys insertObject:lp.description atIndex:i];
	}
    NSMutableDictionary* newDict = [[NSDictionary alloc] initWithObjects:lotArray forKeys:keys];
	self.lotsByLocation = newDict;
    [newDict release];
	[keys release];
}
- (NSArray*) lotAnnotationsForLots:(NSArray*)lots{
	NSMutableArray* annotations = [[NSMutableArray alloc] initWithCapacity:lots.count];
	int j = 0;
	for(int i=0;i<lots.count;i++){
		LotPolygon* thisLot = [lots objectAtIndex:i];
		if(thisLot.developmentIcon){
			[annotations insertObject:thisLot.developmentIcon atIndex:j];
			j++;
		}
	}
	return [annotations autorelease];
}

- (void) doRangeCleanup{
	NSArray* lotsToRemove = [lotArray filteredArrayUsingPredicate:outsideMaxRange];
	NSArray* iconsToRemove = [self lotAnnotationsForLots:lotsToRemove];
	[delegate removePolygons:lotsToRemove andTheirIcons:iconsToRemove];
	[lotArray removeObjectsInArray:lotsToRemove];
	[self reconstuctDictionary];
}
- (int) lotCount{
    return lotArray.count;
}

double calcLonCoeff(int Ci){
	/*
	* has units of degrees of longitude / lot
	* M_PI*Ci/nLatBands/2 = base latitude for that band
	* nLonBands = maximum longitude bands
	* round(nLonBands*cos(M_PI*Ci/nLatBands/2)) = number of lots in this band
	* add 
	*/
	return 90 / round(nLonBands*cos(radiansPerBand*(Ci+(Ci<0) )));
}

- (void) dealloc{
	[lotsByLocation release];
	[lotArray release];
	[outsideMaxBuffer release];
	[outsideMaxRange release];
    //[unrequitedLots release];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[lotRequests release];
	
	[super dealloc];
}


@end
