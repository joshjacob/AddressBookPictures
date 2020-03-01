//
//  ABPLDAPService.m
//  AddressBookPictures
//
//  Created by Josh Jacob on 3/31/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import "ABPLDAPService.h"
#import "ldap.h"
#import "ABPLDAPConfiguration.h"
#import "ABPLDAPEntry.h"

@implementation ABPLDAPService

//+ (NSMutableArray *) getEntries: (ABPLDAPConfiguration *) config
//                   withPictures: (BOOL) withPicts
//                     withError: (NSString **) error
//{
//    NSMutableArray * returnArray = [[NSMutableArray alloc] initWithCapacity:10];
//    
//    // Insert code here to initialize your application
//    
//    LDAP *ld;
//    int  result;
//    int  auth_method    = LDAP_AUTH_SIMPLE;
//    int desired_version = LDAP_VERSION3;
//    // char *ldap_host     = "hanad02.hansoninc.local";
//    // char *root_dn       = "main.computer@hansoninc.local";
//    // char *root_pw       = "password";
//    
//    // TODO: switch to ldap_create
//    if ((ld = ldap_init([config.host cStringUsingEncoding:NSASCIIStringEncoding],
//                        config.port == nil ? LDAP_PORT : [config.port intValue])) == NULL )
//    {
//        *error = @"LDAP services not available";
//        return nil;
//        
//        // perror( "ldap_init failed" );
//        // exit( EXIT_FAILURE );
//    }
//    
//    result = ldap_set_option(ld, LDAP_OPT_PROTOCOL_VERSION, &desired_version);
//    if (result != LDAP_OPT_SUCCESS)
//    {
//        char * errorString = ldap_err2string(result);
//        *error = [NSString stringWithCString: errorString encoding: NSASCIIStringEncoding];
//        return nil;
//        
//        // ldap_perror(ld, "ldap_set_option failed!");
//        // exit(EXIT_FAILURE);
//    }
//    
//    // TODO: fix to not use deprecated method
//    result = ldap_bind_s(ld,
//                         [config.username cStringUsingEncoding:NSASCIIStringEncoding],
//                         [config.password cStringUsingEncoding:NSASCIIStringEncoding],
//                         auth_method);
//    if (result != LDAP_SUCCESS )
//    {
//        char * errorString = ldap_err2string(result);
//        *error = [NSString stringWithCString: errorString encoding: NSASCIIStringEncoding];
//        return nil;
//        
//        // ldap_perror( ld, "ldap_bind" );
//        // exit( EXIT_FAILURE );
//    }
//    
//    /* search from this point */
//    const char* base = [config.searchBase cStringUsingEncoding:NSASCIIStringEncoding]; // "CN=Users,DC=Hansoninc,DC=local";
//    
//    /* return everything */
//    const char* filter = [config.searchFilter cStringUsingEncoding:NSASCIIStringEncoding]; // "(cn=josh*)";
//    
//    LDAPMessage* msg;
//    result = ldap_search_s(ld, base, LDAP_SCOPE_SUBTREE, filter, NULL, 0, &msg);
//    if (result != LDAP_SUCCESS)
//    {
//        char * errorString = ldap_err2string(result);
//        *error = [NSString stringWithCString: errorString encoding: NSASCIIStringEncoding];
//        return nil;
//        
//        // ldap_perror( ld, "ldap_search_s" );
//    }
//    
//    int num_entries_returned = ldap_count_entries(ld, msg);
//    DLog(@"Number of entries %d \n", num_entries_returned);
//    
//    LDAPMessage * entry;
//    for (entry = ldap_first_entry(ld, msg); entry != NULL; entry = ldap_next_entry(ld, entry)) {
//        /* process entry here ... */
//        
//        ABPLDAPEntry * tempEntry = [[ABPLDAPEntry alloc] init];
//        
//        tempEntry.dn = [ABPLDAPService getStringValueFromAttribute: "distinguishedName" forEntry: entry fromLDAP: ld];
//        tempEntry.givenName = [ABPLDAPService getStringValueFromAttribute: "givenName" forEntry: entry fromLDAP: ld];
//        tempEntry.sn = [ABPLDAPService getStringValueFromAttribute: "sn" forEntry: entry fromLDAP: ld];
//        tempEntry.displayName = [ABPLDAPService getStringValueFromAttribute: "displayName" forEntry: entry fromLDAP: ld];
//        tempEntry.mail = [ABPLDAPService getStringValueFromAttribute: "mail" forEntry: entry fromLDAP: ld];
//        
//        if (withPicts == YES) {
//            NSData * data = [ABPLDAPService getDataValueFromAttribute: "thumbnailPhoto" forEntry: entry fromLDAP: ld];
//            if (data == nil) {
//                data = [ABPLDAPService getDataValueFromAttribute: "jpegPhoto" forEntry: entry fromLDAP: ld];
//            }
//            tempEntry.thumbnailPhoto = [[NSImage alloc] initWithData: data];
//        }
//        
//        DLog(@"Entry: %@", tempEntry.givenName);
//        
//        [returnArray addObject:tempEntry];
//        
//        // debugging start
//        
////        BerElement * ber;
////        char * attr;
////        for( attr = ldap_first_attribute(ld, entry, &ber); attr != NULL; attr = ldap_next_attribute(ld, entry, ber)) 
////        {
////            /* process attributes here ... */
////            // printf("attribute %s\n", attr);
////            
////            int i;
////            char ** vals;
////            struct berval ** bervals;
////            if ((vals = ldap_get_values(ld, entry, attr)) != NULL)  {
////                for(i = 0; vals[i] != NULL; i++) {
////                    /* process the current value */
////                    printf("%s:%s\n", attr, vals[i]);
////                }
////            } else if ((bervals = ldap_get_values_len(ld, entry, attr)) != NULL) {
////                for(i = 0; bervals[i] != NULL; i++) {
////                    /* process the current value */
////                    printf("%s: length = %ld\n", attr, bervals[i]->bv_len);
////                }
////            }
////        }
//        
//        // debugging end
//    }
//    
//    return returnArray;
//}

+ (NSString *) getStringValueFromAttribute: (char *) attribute
                            forEntry: (LDAPMessage *) entry
                            fromLDAP: (LDAP *) ldap
{
    NSString * value = nil;
    
    char ** vals;
//    struct berval ** bervals;
    if ((vals = ldap_get_values(ldap, entry, attribute)) != NULL)  {
        if (ldap_count_values(vals) > 0) {
            // printf("%s:%s\n", attribute, vals[0]);
            value = [NSString stringWithCString:vals[0] encoding:NSASCIIStringEncoding];
        }
//    } else if ((bervals = ldap_get_values_len(ldap, entry, attribute)) != NULL) {
//        if (ldap_count_values_len(bervals) > 0) {
//            printf("%s: length = %ld\n", attribute, bervals[0]->bv_len);
//        }
    }
    
    // free
    ldap_value_free(vals);
    
    return value;
}

+ (NSData *) getDataValueFromAttribute: (char *) attribute
                            forEntry: (LDAPMessage *) entry
                            fromLDAP: (LDAP *) ldap
{
    NSData * value = nil;
    
//    char ** vals;
    struct berval ** bervals;
//    if ((vals = ldap_get_values(ldap, entry, attribute)) != NULL)  {
//        if (ldap_count_values(vals) > 0) {
//            printf("%s:%s\n", attribute, vals[0]);
//        }
//    } else
    if ((bervals = ldap_get_values_len(ldap, entry, attribute)) != NULL) {
        if (ldap_count_values_len(bervals) > 0) {
            // printf("%s: length = %ld\n", attribute, bervals[0]->bv_len);
            value = [NSData dataWithBytes:bervals[0]->bv_val length:bervals[0]->bv_len];
        }
    }
    
    // free
    ldap_value_free_len(bervals);
    
    return value;
}

@end
