//
//  ABPLDAPService.h
//  AddressBookPictures
//
//  Created by Josh Jacob on 3/31/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ldap.h"

@class ABPLDAPConfiguration;

@interface ABPLDAPService : NSObject {
    
    
}

//+ (NSMutableArray *) getEntries: (ABPLDAPConfiguration *) config
//                   withPictures: (BOOL) withPicts
//                     withError: (NSString **) error;

+ (NSString *) getStringValueFromAttribute: (char *) attribute
                                  forEntry: (LDAPMessage *) entry
                                  fromLDAP: (LDAP *) ldap;

+ (NSData *) getDataValueFromAttribute: (char *) attribute
                              forEntry: (LDAPMessage *) entry
                              fromLDAP: (LDAP *) ldap;

@end
