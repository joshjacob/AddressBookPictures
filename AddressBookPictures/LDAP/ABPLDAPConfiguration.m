//
//  ABPLDAPConfiguration.m
//  AddressBookPictures
//
//  Created by Josh Jacob on 3/31/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import "ABPLDAPConfiguration.h"

@implementation ABPLDAPConfiguration

- (id) init
{
    self = [super init];
    if (self) {
        
        _authTypes = [[NSArray alloc] initWithObjects:@"None", @"Basic", @"SASL", nil];
        _authTypeIndex = [NSNumber numberWithInt:0];
    }
    
    return self;
}

- (void) dealloc
{
    self.name = nil;
    self.host = nil;
    self.port = nil;
    self.authTypeIndex = nil;
    self.username = nil;
    self.password = nil;
    self.searchBase = nil;
    self.searchFilter = nil;
}

#pragma mark - NSCoding

- (void) encodeWithCoder:(NSCoder*)encoder {
    // If parent class also adopts NSCoding, include a call to
    // [super encodeWithCoder:encoder] as the first statement.
    
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.host forKey:@"host"];
    [encoder encodeObject:self.port forKey:@"port"];
    [encoder encodeObject:self.authTypeIndex forKey:@"authTypeIndex"];
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.password forKey:@"password"];
    [encoder encodeObject:self.searchBase forKey:@"searchBase"];
    [encoder encodeObject:self.searchFilter forKey:@"searchFilter"];
}

- (id) initWithCoder:(NSCoder*)decoder {
    if (self = [super init]) {
        
        _authTypes = [[NSArray alloc] initWithObjects:@"None", @"Basic", @"SASL", nil];
        
        // If parent class also adopts NSCoding, replace [super init]
        // with [super initWithCoder:decoder] to properly initialize.
        
        self.name = [decoder decodeObjectForKey:@"name"];
        self.host = [decoder decodeObjectForKey:@"host"];
        self.port = [decoder decodeObjectForKey:@"port"];
        self.authTypeIndex = [decoder decodeObjectForKey:@"authTypeIndex"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.password = [decoder decodeObjectForKey:@"password"];
        self.searchBase = [decoder decodeObjectForKey:@"searchBase"];
        self.searchFilter = [decoder decodeObjectForKey:@"searchFilter"];
    }
    return self;
}


@end
