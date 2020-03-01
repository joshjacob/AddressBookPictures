//
//  ABPLDAPEntry.h
//  AddressBookPictures
//
//  Created by Josh Jacob on 3/31/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABPLDAPEntry : NSObject

@property (strong) NSString * dn;
@property (strong) NSString * givenName;
@property (strong) NSString * sn;
@property (strong) NSString * displayName;
@property (strong) NSString * mail;
@property (strong) NSImage * thumbnailPhoto;

@property (readonly, getter = getName) NSString *name;

@end
