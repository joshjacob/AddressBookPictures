//
//  ABPLDAPQueryOperation.h
//  AddressBookPictures
//
//  Created by Josh Jacob on 6/12/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABPLDAPConfiguration;

@interface ABPLDAPQueryOperation : NSOperation {

    ABPLDAPConfiguration * config;
    BOOL getPicts;
    
    BOOL executing;
    BOOL finished;
    BOOL canceled;

}

@property NSMutableArray * results;
@property NSString * statusString;
@property NSString * errorString;

- (id)initWithConfig: (ABPLDAPConfiguration *) ldapConfig andGetPictures: (BOOL) withPicts;
- (void)completeOperation;

@end
