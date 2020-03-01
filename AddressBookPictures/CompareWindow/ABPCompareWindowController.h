//
//  ABPCompareWindowController.h
//  AddressBookPictures
//
//  Created by Josh Jacob on 5/1/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ABPLDAPConfiguration;
@class ABPLDAPEntry;
@class ABPLDAPQueryOperation;

@interface ABPCompareWindowController : NSWindowController
{
    BOOL didCancel;
}

@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSArrayController *arrayController;
@property (strong) ABPLDAPConfiguration * ldapConfig;
@property (retain) NSMutableArray * entries;

@property (strong) ABPLDAPQueryOperation * op;
@property (strong) IBOutlet NSPanel *connectionSheet;
@property (strong) IBOutlet NSProgressIndicator *connectionSheetProgress;
@property (strong) IBOutlet NSButtonCell *connectionSheetCancel;

@property (strong) IBOutlet NSButton *buttonSync;

- (id) initWithWindowNibName: (NSString *) nibName LDAPConfiguration: (ABPLDAPConfiguration *) config;

- (IBAction)setSkipAll:(id)sender;
- (IBAction)setUpdateAll:(id)sender;
- (IBAction)setUpdateBlank:(id)sender;
- (IBAction)synchronize:(id)sender;

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)endConnection: (ABPLDAPQueryOperation *) inOp;
- (IBAction)cancelConnection:(id)sender;

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

- (void)displayError;

@end
