//
//  ABPLDAPCompareEntry.h
//  AddressBookPictures
//
//  Created by Josh Jacob on 6/11/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ABPLDAPCompareEntrySKIP 0
#define ABPLDAPCompareEntryUPDATE 1

@class ABPLDAPEntry;

@interface ABPLDAPCompareEntry : NSObject {

    ABPLDAPEntry * ldapEntry;
    NSString * addressBookUniqueId;
    NSImage * addressBookImage;
    NSNumber * action;
    
}

@property (strong) ABPLDAPEntry * ldapEntry;
@property (strong) NSString * addressBookUniqueId;
@property (strong) NSImage * addressBookImage;
@property (retain) NSNumber * action;

@end
