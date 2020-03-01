//
//  ABPLDAPEntry.m
//  AddressBookPictures
//
//  Created by Josh Jacob on 3/31/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import "ABPLDAPEntry.h"

@implementation ABPLDAPEntry

@synthesize dn, givenName, sn, displayName, mail, thumbnailPhoto;

- (void) dealloc
{
    self.dn = nil;
    self.givenName = nil;
    self.sn = nil;
    self.displayName = nil;
    self.mail = nil;
    self.thumbnailPhoto = nil;
}

- (NSString *) getName
{
    if (self.displayName != nil)
        return self.displayName;
    if ((self.givenName != nil) && (self.sn != nil))
        return [NSString stringWithFormat:@"%@ %@", self.givenName, self.sn];
    if (self.givenName != nil)
        return self.givenName;
    
    return @"";
}

@end
