//
//  ABPConfigurationWindowController.h
//  AddressBookPictures
//
//  Created by Josh Jacob on 3/31/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ABPLDAPConfiguration;
@class ABPLDAPQueryOperation;

@interface ABPConfigurationWindowController : NSWindowController <NSSplitViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSMenuDelegate, NSControlTextEditingDelegate> {
    ABPLDAPConfiguration * curConfig;
}

@property (retain) ABPLDAPConfiguration * curConfig;
@property (strong) IBOutlet NSOutlineView *configTableView;
@property (strong) IBOutlet NSArrayController *configTableViewArrayController;
@property (strong) IBOutlet NSProgressIndicator *testConnectionProgress;
@property (strong) IBOutlet NSTextField *testConnectionMessage;
@property (strong) IBOutlet NSTextField *connectionNameTextField;

@property (strong) ABPLDAPQueryOperation * op;
@property (strong) NSMutableArray * canceledTestOps;
@property (strong) IBOutlet NSPanel *testSheet;
@property (strong) IBOutlet NSProgressIndicator *testSheetProgress;

@property (strong) IBOutlet NSMenu *listActionMenu;

@property (strong) IBOutlet NSMenuItem *actionAddLDAP;
@property (strong) IBOutlet NSMenuItem *actionDeleteLDAP;

- (IBAction)actionDoAddLDAP:(id)sender;
- (IBAction)actionDoDeleteLDAP:(id)sender;

- (IBAction)testConnection:(id)sender;
- (IBAction)openConnection:(id)sender;

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)endTestConnection: (ABPLDAPQueryOperation *) inOp;
- (IBAction)cancelTest:(id)sender;

@end
