//
//  ABPLDAPConfiguration.h
//  AddressBookPictures
//
//  Created by Josh Jacob on 3/31/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ABP_LDAP_AUTH_TYPE_NONE 0
#define ABP_LDAP_AUTH_TYPE_BASIC 1
#define ABP_LDAP_AUTH_TYPE_SASL 2

@interface ABPLDAPConfiguration : NSObject <NSCoding> {
}

@property (readonly) NSArray * authTypes;

@property (strong) NSString * name;
@property (strong) NSString * host;
@property (strong) NSNumber * port;
@property (strong) NSNumber * authTypeIndex;
@property (strong) NSString * username;
@property (strong) NSString * password;
@property (strong) NSString * searchBase;
@property (strong) NSString * searchFilter;

@end
