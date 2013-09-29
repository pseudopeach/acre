//
//  PListModel.h
//  Acre
//
//  Created by Justin Armstrong on 12/23/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerResponse.h"
#import "UDF.h"
#import "Datastore.h"

@interface PListModel : NSObject {
	NSURLConnection* theConnection;
	NSMutableData* receivedData;
	ServerResponse* lastResponse;
	NSString* baseURLStr;

	//NSError* serializationError;
	NSString* lastFName;
    BOOL hasOutstandingCall;
}

//@property (nonatomic, retain) NSURLConnection* theConnection;
//@property (nonatomic, retain) NSMutableData* receivedData;
@property (nonatomic, retain) ServerResponse* lastResponse;
@property (nonatomic, retain) NSString* baseURLStr;

//@property (nonatomic, retain) NSError* serializationError;
@property (nonatomic, readonly) BOOL hasOutstandingCall;
@property (nonatomic, retain) NSString* lastFName;


- (id) initWithBaseURL:(NSString*)urlStr;
- (BOOL) callFunction:(NSString*)fname withParams:(NSDictionary*)params;
- (void) cancelCall;


@end
