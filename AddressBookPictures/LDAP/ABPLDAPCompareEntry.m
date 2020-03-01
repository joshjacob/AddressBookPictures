//
//  ABPLDAPCompareEntry.m
//  AddressBookPictures
//
//  Created by Josh Jacob on 6/11/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import "ABPLDAPCompareEntry.h"

@implementation ABPLDAPCompareEntry

@synthesize ldapEntry, addressBookUniqueId, addressBookImage, action;

- (void) dealloc
{ 
    self.ldapEntry = nil;
    self.addressBookUniqueId = nil;
    self.addressBookImage = nil;
    self.action = nil;
    
}

@end
