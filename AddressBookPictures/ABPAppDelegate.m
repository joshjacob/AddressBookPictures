//
//  ABPAppDelegate.m
//  AddressBookPictures
//
//  Created by Josh Jacob on 3/30/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import "ABPAppDelegate.h"
#import "ldap.h"
#import "ABPLDAPConfiguration.h"
#import "ABPConfigurationWindowController.h"
#import "ABPBetaNotesWindowController.h"

#define PREFS_CONFIGS_LDAP @"configs_ldap"

@interface ABPAppDelegate()

@property (nonatomic, strong) NSMutableArray * LDAPConfigs;

@end

@implementation ABPAppDelegate

@synthesize window = _window;
@synthesize configWindow;
@synthesize compareWindows;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DLog(@"applicationDidFinishLaunching");
    
    // Insert code here to initialize your application
    
    compareWindows = [[NSMutableArray alloc] initWithCapacity:1];
    
    // show beta tester notes
    if (self.betaNotesWindow == nil)
        self.betaNotesWindow = [[ABPBetaNotesWindowController alloc] initWithWindowNibName:@"ABPBetaNotesWindowController"];
    
    [self.betaNotesWindow showWindow: self];
    [self.betaNotesWindow.window makeKeyAndOrderFront: self];
    
    [self loadLDAPConfigs];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    DLog(@"applicationWillTerminate");
    
    [self saveLDAPConfigs];
}

#pragma mark - Menu IBActions

- (IBAction)openConfigWindow:(id) sender
{
    if (self.configWindow == nil)
        self.configWindow = [[ABPConfigurationWindowController alloc] initWithWindowNibName:@"ABPConfigurationWindowController"];
    
    [self.configWindow showWindow: sender];
    [self.configWindow.window makeKeyAndOrderFront: sender];
}

- (IBAction)openBetaTesterHelpWindow:(id) sender
{
    [self.betaNotesWindow showWindow: sender];
    [self.betaNotesWindow.window makeKeyAndOrderFront: sender];
}

#pragma mark - LDAP Configuration Data

- (void)loadLDAPConfigs
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    NSData *data = [defaults objectForKey:PREFS_CONFIGS_LDAP];
    if (data == nil) {
        self.LDAPConfigs = [[NSMutableArray alloc] init];
    } else {
        NSArray *tempArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.LDAPConfigs = [tempArray mutableCopy];
    }
}

- (void)saveLDAPConfigs
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithArray:self.LDAPConfigs]];
    [defaults setObject:data forKey:PREFS_CONFIGS_LDAP];
    
    [defaults synchronize];
}

- (NSMutableArray *) getLDAPConfigs
{
    return self.LDAPConfigs;
}

- (NSInteger) addLDAPConfig
{
    ABPLDAPConfiguration *config = [[ABPLDAPConfiguration alloc] init];
    config.name = @"New Configuration";
    
    [self.LDAPConfigs addObject:config];
    
    [self saveLDAPConfigs];
    
    return (self.LDAPConfigs.count - 1);
}

- (void) deleteLDAPConfig:(ABPLDAPConfiguration *)config
{
    [self.LDAPConfigs removeObject:config];
    
    [self saveLDAPConfigs];
}

@end
