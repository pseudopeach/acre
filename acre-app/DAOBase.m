//
//  DAOBase.m
//  Acre
//
//  Created by Justin Armstrong on 11/7/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "DAOBase.h"


@implementation DAOBase

- (void) setNilValueForKey:(NSString*)key{
	NSLog(@"Didn't find bindable property for %@", key);
}

- (void) setValue:(id)value forKey:(NSString *)key{
	//NSLog(@"setting value for %@...",key);
	[super setValue:value forKey:key];
}
- (void) setValue:(id)value forUndefinedKey:(NSString*)key{
	NSLog(@"Notice: No class member found for key %@",key);
}
@end
