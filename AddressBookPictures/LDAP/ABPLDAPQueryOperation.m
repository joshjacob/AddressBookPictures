//
//  ABPLDAPQueryOperation.m
//  AddressBookPictures
//
//  Created by Josh Jacob on 6/12/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import "ABPLDAPQueryOperation.h"
#import "ABPLDAPConfiguration.h"
#import "ABPLDAPService.h"
#import "ABPLDAPEntry.h"
#import "ldap.h"

@implementation ABPLDAPQueryOperation

@synthesize results;
@synthesize errorString;
@synthesize statusString;

- (id)initWithConfig: (ABPLDAPConfiguration *) ldapConfig andGetPictures: (BOOL) withPicts {
    self = [super init];
    if (self) {
        config = ldapConfig;
        getPicts = withPicts;
        executing = NO;
        finished = NO;
    }
    return self;
}

- (void)dealloc {
    DLog(@"I'm going away!");
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}

- (BOOL)isCancelled {
    return canceled;
}

- (void)cancel {
    [super cancel];
    canceled = YES;
}

- (void)start {
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {

//    NSString * tempError;
//    self.results = [ABPLDAPService getEntries: config
//                                 withPictures: getPicts
//                                    withError:&tempError];
//    if (tempError != nil)
//        self.errorString = [NSString stringWithString:tempError];
    
    NSMutableArray * returnArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    LDAP *ld;
    int  result;
    int desired_version = LDAP_VERSION3;
    
    // set auth type
    int  auth_method    = LDAP_AUTH_SIMPLE;
    if (config.authTypeIndex.intValue == ABP_LDAP_AUTH_TYPE_BASIC) {
        auth_method = LDAP_AUTH_SIMPLE;
    }
    if (config.authTypeIndex.intValue == ABP_LDAP_AUTH_TYPE_SASL) {
        auth_method = LDAP_AUTH_SASL;
    }
    
    //
    // init connection
    //
    
    // TODO: switch to ldap_create
    if ((ld = ldap_init([config.host cStringUsingEncoding:NSASCIIStringEncoding],
                        config.port == nil ? LDAP_PORT : [config.port intValue])) == NULL )
    {
        [self setErrorString: @"LDAP services not available"];
        [self completeOperation];
        return;
    }
    if (canceled) {
        [self completeOperation];
        return;
    }
    
    //
    // set ldap version
    //
    
    result = ldap_set_option(ld, LDAP_OPT_PROTOCOL_VERSION, &desired_version);
    if (result != LDAP_OPT_SUCCESS)
    {
        char * errorCString = ldap_err2string(result);
        [self setErrorString: [NSString stringWithCString: errorCString encoding: NSASCIIStringEncoding]];
        [self completeOperation];
        return;
    }
    if (canceled) {
        [self completeOperation];
        return;
    }
    
    //
    // bind connection
    //
    
    [self setStatusString: @"Connecting to LDAP server"];
    // TODO: fix to not use deprecated method
    result = ldap_bind_s(ld,
                         [config.username cStringUsingEncoding:NSASCIIStringEncoding],
                         [config.password cStringUsingEncoding:NSASCIIStringEncoding],
                         auth_method);
    if (result != LDAP_SUCCESS )
    {
        char * errorCString = ldap_err2string(result);
        [self setErrorString: [NSString stringWithCString: errorCString encoding: NSASCIIStringEncoding]];
        [self completeOperation];
        return;
    }
    if (canceled) {
        [self completeOperation];
        return;
    }
    
    //
    // get ldap info
    //
    
    LDAPAPIInfo api;
    api.ldapai_info_version = 1;
    result = ldap_get_option(ld, LDAP_OPT_API_INFO, &api);
    if(result != LDAP_SUCCESS) {
        char * errorCString = ldap_err2string(result);
		DLog(@"%s: ldap_get_option(API_INFO) failed\n", errorCString);
		// return;
	} else {
        DLog(@"\nExecution time API Information\n");
        DLog(@"  API Info version:  %d\n", api.ldapai_info_version);
        DLog(@"  API Version:       %d\n", api.ldapai_api_version);
        DLog(@"  Protocol Max:      %d\n", api.ldapai_protocol_version);
        if(api.ldapai_extensions == NULL) {
            DLog(@"  Extensions:        none\n");
            
        } else {
            int i;
            for(i=0; api.ldapai_extensions[i] != NULL; i++) /* empty */;
            DLog(@"  Extensions:        %d\n", i);
            for(i=0; api.ldapai_extensions[i] != NULL; i++) {
                LDAPAPIFeatureInfo fi;
                fi.ldapaif_info_version = LDAP_FEATURE_INFO_VERSION;
                fi.ldapaif_name = api.ldapai_extensions[i];
                fi.ldapaif_version = 0;
                
                if( ldap_get_option(NULL, LDAP_OPT_API_FEATURE_INFO, &fi) == LDAP_SUCCESS ) {
                    if(fi.ldapaif_info_version != LDAP_FEATURE_INFO_VERSION) {
                        DLog(@"                     %s feature info mismatch: got %d, expected %d\n", api.ldapai_extensions[i], LDAP_FEATURE_INFO_VERSION, fi.ldapaif_info_version);
                        
                    } else {
                        DLog(@"                     %s: version %d\n", fi.ldapaif_name, fi.ldapaif_version);
                    }
                    
                } else {
                    DLog(@"                     %s (NO FEATURE INFO)\n", api.ldapai_extensions[i]);
                }
                ldap_memfree(api.ldapai_extensions[i]);
            }
            ldap_memfree(api.ldapai_extensions);
        }
        DLog(@"  Vendor Name:       %s\n", api.ldapai_vendor_name);
        ldap_memfree(api.ldapai_vendor_name);
        DLog(@"  Vendor Version:    %d\n", api.ldapai_vendor_version);
        DLog(@"\nExecution time Default Options\n");
    }
    
    //
    // query
    //
    
    /* search from this point */
    const char* base = [config.searchBase cStringUsingEncoding:NSASCIIStringEncoding]; // "CN=Users,DC=Hansoninc,DC=local";
    
    /* return everything */
    const char* filter = [config.searchFilter cStringUsingEncoding:NSASCIIStringEncoding]; // "(cn=josh*)";
    
    [self setStatusString: @"Searching for users"];
    
    LDAPMessage* msg;
    result = ldap_search_s(ld, base, LDAP_SCOPE_SUBTREE, filter, NULL, 0, &msg);
    if (result != LDAP_SUCCESS)
    {
        char * errorCString = ldap_err2string(result);
        [self setErrorString:  [NSString stringWithCString: errorCString encoding: NSASCIIStringEncoding]];
        [self completeOperation];
        return;
    }
    if (canceled) {
        [self completeOperation];
        return;
    }
    
    //
    // process results
    //
    
    int num_entries_returned = ldap_count_entries(ld, msg);
    DLog(@"Number of entries found: %d \n", num_entries_returned);
    
    [self setStatusString: [NSString stringWithFormat:@"Found %d entries", num_entries_returned]];
    
    int entryCount = 1;
    LDAPMessage * entry;
    for (entry = ldap_first_entry(ld, msg); entry != NULL; entry = ldap_next_entry(ld, entry)) {
        /* process entry here ... */
        
        ABPLDAPEntry * tempEntry = [[ABPLDAPEntry alloc] init];
        
        tempEntry.dn = [ABPLDAPService getStringValueFromAttribute: "distinguishedName" forEntry: entry fromLDAP: ld];
        tempEntry.givenName = [ABPLDAPService getStringValueFromAttribute: "givenName" forEntry: entry fromLDAP: ld];
        tempEntry.sn = [ABPLDAPService getStringValueFromAttribute: "sn" forEntry: entry fromLDAP: ld];
        tempEntry.displayName = [ABPLDAPService getStringValueFromAttribute: "displayName" forEntry: entry fromLDAP: ld];
        tempEntry.mail = [ABPLDAPService getStringValueFromAttribute: "mail" forEntry: entry fromLDAP: ld];
        
        if (getPicts == YES) {
            NSData * data = [ABPLDAPService getDataValueFromAttribute: "thumbnailPhoto" forEntry: entry fromLDAP: ld];
            if (data == nil) {
                data = [ABPLDAPService getDataValueFromAttribute: "jpegPhoto" forEntry: entry fromLDAP: ld];
            }
            if (data == nil) {
                data = [ABPLDAPService getDataValueFromAttribute: "photo" forEntry: entry fromLDAP: ld];
            }
            tempEntry.thumbnailPhoto = [[NSImage alloc] initWithData: data];
        }
        
        if (tempEntry.mail != nil) {
            [returnArray addObject:tempEntry];
        }
        
        // debugging start
        
//        BerElement * ber;
//        char * attr;
//        for( attr = ldap_first_attribute(ld, entry, &ber); attr != NULL; attr = ldap_next_attribute(ld, entry, ber))
//        {
//            /* process attributes here ... */
//            // printf("attribute %s\n", attr);
//            
//            int i;
//            char ** vals;
//            struct berval ** bervals;
//            if ((vals = ldap_get_values(ld, entry, attr)) != NULL)  {
//                for(i = 0; vals[i] != NULL; i++) {
//                    /* process the current value */
//                    printf("%s:%s\n", attr, vals[i]);
//                }
//            } else if ((bervals = ldap_get_values_len(ld, entry, attr)) != NULL) {
//                for(i = 0; bervals[i] != NULL; i++) {
//                    /* process the current value */
//                    printf("%s: length = %ld\n", attr, bervals[i]->bv_len);
//                }
//            }
//        }

        // debugging end
        
        DLog(@"Entry %d of %d: %@", entryCount, num_entries_returned, tempEntry.givenName);
        [self setStatusString: [NSString stringWithFormat:@"Reading entry %d of %d: %@", entryCount, num_entries_returned, tempEntry.givenName]];
        entryCount++;
        
        if (canceled) {
            [self completeOperation];
            return;
        }
    }
    [self setStatusString: @"Done with query"];
    
    [self setResults: returnArray];
    
    [self completeOperation];
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
