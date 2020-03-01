//
//  ABPAppDelegate.h
//  AddressBookPictures
//
//  Created by Josh Jacob on 3/30/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ABPConfigurationWindowController;
@class ABPBetaNotesWindowController;
@class ABPLDAPConfiguration;

@interface ABPAppDelegate : NSObject <NSApplicationDelegate, NSKeyedUnarchiverDelegate> {
    
    
    NSMutableArray * compareWindows;
    
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) IBOutlet ABPConfigurationWindowController * configWindow;
@property (retain) IBOutlet ABPBetaNotesWindowController * betaNotesWindow;

@property (retain) NSMutableArray * compareWindows;

- (IBAction)openConfigWindow:(id) sender;
- (IBAction)openBetaTesterHelpWindow:(id) sender;

- (NSMutableArray *) getLDAPConfigs;
- (NSInteger) addLDAPConfig;
- (void) deleteLDAPConfig:(ABPLDAPConfiguration *)config;

@end
