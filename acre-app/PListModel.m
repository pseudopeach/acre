//
//  PListModel.m
//  Acre
//
//  Created by Justin Armstrong on 12/23/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "PListModel.h"


@implementation PListModel
@synthesize lastResponse, baseURLStr, lastFName, hasOutstandingCall;


- (id) init{
	if((self = [super init])){
		self.baseURLStr = [Datastore getBaseURLStr];
        [[NSNotificationCenter defaultCenter] addObserver:self 
            selector:@selector(cancelCall) name:@"ServerCallShouldBeCanceled"object:nil];
	}
	return self;
}

- (id) initWithBaseURL:(NSString*)urlStr{
	if((self = [super init])){
		self.baseURLStr = urlStr;
	}
	return self;
}

- (BOOL) callFunction:(NSString *)fname withParams:(NSDictionary *)params{

	// Create the request.
	NSLog(@"calling %@...",fname);
	NSString* fullEndpointURL1 = [NSString stringWithFormat:
		@"%@/%@.cfm", [Datastore getBaseURLStr], fname];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullEndpointURL1]];
	
	//if there are are params, make them into POST data
	if(params){
		NSString* paramStr = [UDF nameValuePairStringWithDictionary:params];
		NSLog(@"sending: %@",paramStr);
		NSData *postData = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
		[theRequest setHTTPMethod: @"POST"];
		[theRequest setHTTPBody:postData];
	}
    
    if(hasOutstandingCall)
        [self cancelCall];
	
	self.lastFName = fname;
	
	// create the connection with the request
    hasOutstandingCall = YES;
	theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		receivedData = [[NSMutableData data] retain];
		return YES;
	} else 
		return NO;
    //[theConnection release]; //released at completion or error
}




// ==== NSURLConnectionDelegate
	//connection:didReceiveResponse:, connection:didReceiveData:, connection:didFailWithError: and connectionDidFinishLoading:
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [receivedData setLength:0];
	NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) response;
	if([httpResp statusCode] == 401){
		NSLog(@"User not logged in.");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"userSessionExpired" object:self];
	}else
        [Datastore updateServerActivityTime];
}	
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receivedData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    hasOutstandingCall = NO;
	[theConnection release];
    [receivedData release];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"connectionDidFail" object:self];
	NSLog(@"Connection failed! Error - %@ %@",
	  [error localizedDescription],
	  [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	hasOutstandingCall = NO;
    [theConnection release];
    NSError* sError;

	NSDictionary* tmpDict = [NSPropertyListSerialization propertyListWithData:receivedData 
        options:NSPropertyListImmutable
        format:NULL error:&sError];
    ServerResponse* response = [ServerResponse new];
	[response setValuesForKeysWithDictionary:tmpDict];
    self.lastResponse = response;
    [response release];
	if(tmpDict.count == 0){
		lastResponse.success = NO;
		lastResponse.errorId = -1;
		lastResponse.errorMessage = @"Couldn't understand server response";
		[[NSNotificationCenter defaultCenter] postNotificationName:@"serverDidRespond" object:self];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestDidFail" object:self];
		NSLog(@"failed to deserialize response");
        NSString* serverMessage = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		NSLog(@"SERVER SAID: %@",serverMessage);
        [serverMessage release];
		[receivedData release];
		return;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"serverDidRespond" object:self];
	
	if(lastResponse.success){
		if(lastResponse.resultQuery)
			NSLog(@"%@ response: query with %d rows",lastFName, lastResponse.resultQuery.count);
		else if(lastResponse.resultObject)
			NSLog(@"%@ response: object",lastFName);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestDidSucceed" object:self];
	}else{
		NSLog(@"%@ response: ERROR id: %d, message: %@",lastFName, lastResponse.errorId, lastResponse.errorMessage);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestDidFail" object:self];
	}

    // release the connection, and the data object
    //[connection release];
    [receivedData release];
}

- (void) cancelCall{
    if(hasOutstandingCall){
        hasOutstandingCall = NO;
        if(theConnection && [theConnection isKindOfClass:[NSURLConnection class]]){
            [theConnection cancel];
            [theConnection release];
        }
        if(receivedData)
            [receivedData release];
    }
}



//============================
	
- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
        
	[lastResponse release];
	[baseURLStr release];
	[lastFName release];

	[super dealloc];
}	
@end
