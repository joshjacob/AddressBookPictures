//
//  ABPConfigurationWindowController.m
//  AddressBookPictures
//
//  Created by Josh Jacob on 3/31/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import "ABPConfigurationWindowController.h"
#import "ABPLDAPConfiguration.h"
#import "ABPLDAPService.h"
#import "ABPAppDelegate.h"
#import "ABPLDAPEntry.h"
#import "ABPCompareWindowController.h"
#import "ABPLDAPCompareEntry.h"
#import "ABPLDAPQueryOperation.h"
#import <AddressBook/AddressBook.h>

#define MENU_ACTION_DUMMY 0
#define MENU_ACTION_ADD_LDAP 1
#define MENU_ACTION_DELETE_LDAP 2

@interface ABPConfigurationWindowController ()

@end

@implementation ABPConfigurationWindowController

@synthesize curConfig;
@synthesize configTableView;
@synthesize configTableViewArrayController;
@synthesize testConnectionProgress;
@synthesize testConnectionMessage;
@synthesize op;
@synthesize canceledTestOps;
@synthesize testSheet;
@synthesize testSheetProgress;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        
        canceledTestOps = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [[self window] setExcludedFromWindowsMenu:YES];
    
    [configTableView expandItem:nil expandChildren:YES];
}

- (void) dealloc
{
    self.curConfig = nil;
}

#pragma mark - NSSplitViewDelegate

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
    switch (dividerIndex) {
        case 0:
            return 250;
            break;
        default:
            return 250;
            break;
    }
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
    switch (dividerIndex) {
        case 0:
            return 0;
            break;
        default:
            return 0;
            break;
    }
}

#pragma mark - NSOutlineViewDataSource

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    ABPAppDelegate * delegate = (ABPAppDelegate *) [NSApp delegate];
    
    if (item == nil) {
        if (index == 0) {
            return [delegate getLDAPConfigs];
        }
    } else {
        if (item == [delegate getLDAPConfigs]) {
            return [[delegate getLDAPConfigs] objectAtIndex:index];
        }
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    ABPAppDelegate * delegate = (ABPAppDelegate *) [NSApp delegate];
    
    if (item == nil) {
        return YES;
    }
    
    if (item == [delegate getLDAPConfigs]) {
        return YES;
    }
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    ABPAppDelegate * delegate = (ABPAppDelegate *) [NSApp delegate];
    
    if (item == nil) {
        return 1;
    }
    
    if (item == [delegate getLDAPConfigs]) {
        return [[delegate getLDAPConfigs] count];
    }
    
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    ABPAppDelegate * delegate = (ABPAppDelegate *) [NSApp delegate];
    
    NSTableCellView * view;
    if (item == [delegate getLDAPConfigs]) {
        view =  (NSTableCellView *) [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        [view.textField setStringValue:@"LDAP Connections"];
    } else {
        ABPLDAPConfiguration * config = (ABPLDAPConfiguration *) item;
        view =  (NSTableCellView *) [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        [view.textField setStringValue: config.name];
    }
    return view;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    ABPAppDelegate * delegate = (ABPAppDelegate *) [NSApp delegate];
     
    if ([tableColumn identifier] == 0)
    {
        if (item == [delegate getLDAPConfigs])
        {
            // return [[NSTextFieldCell alloc] initTextCell:@"LDAP Configurations"];
            return @"LDAP Configurations";
        }
    }
    
    if ([[delegate getLDAPConfigs] indexOfObject:item] != NSNotFound) {
        ABPLDAPConfiguration * config = [[delegate getLDAPConfigs] objectAtIndex:[[delegate getLDAPConfigs] indexOfObject:item]];
        
        // return [[NSTextFieldCell alloc] initTextCell:[config name]];
        return [config name];
    }
    
    return nil;
}

#pragma mark - NSOutlineViewDelegate

//- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
//{
//    ABPAppDelegate * delegate = (ABPAppDelegate *) [NSApp delegate];
//    
//    if (item == [delegate getLDAPConfigs]) 
//        return YES;
//    
//    return NO;
//}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    ABPAppDelegate * delegate = (ABPAppDelegate *) [NSApp delegate];
    
    if (item == [delegate getLDAPConfigs]) 
        return NO;
    
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item
{
    ABPAppDelegate * delegate = (ABPAppDelegate *) [NSApp delegate];
    
    if (item == [delegate getLDAPConfigs]) 
        return NO;
    
    return NO;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    // nil everything
    [self.configTableViewArrayController removeObjects:[self.configTableViewArrayController content]];
    [self.testConnectionMessage setStringValue:@""];
    
    self.curConfig = [self.configTableView itemAtRow: self.configTableView.selectedRow];
}

//- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowCellExpansionForTableColumn:(NSTableColumn *)tableColumn item:(id)item
//{
//    return YES;
//}
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item
//{
//    return YES;
//}
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
//{
//    return YES;
//}

#pragma mark - IBActions

- (IBAction)actionDoAddLDAP:(id)sender {
    ABPAppDelegate * delegate = (ABPAppDelegate *) [NSApp delegate];

    NSInteger newConfigIndex = [delegate addLDAPConfig];
    
    [self.configTableView reloadData];
    
    [configTableView expandItem:nil expandChildren:YES];
    
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:newConfigIndex+1];
    [configTableView selectRowIndexes:indexSet byExtendingSelection:NO];
}

- (IBAction)actionDoDeleteLDAP:(id)sender {
    if (self.curConfig != nil) {
        ABPAppDelegate * delegate = (ABPAppDelegate *) [NSApp delegate];
        
        [delegate deleteLDAPConfig:self.curConfig];
        
        [self.configTableView reloadData];
        [configTableView expandItem:nil expandChildren:YES];
        
        // nil everything
        [self.configTableViewArrayController removeObjects:[self.configTableViewArrayController content]];
        [self.testConnectionMessage setStringValue:@""];
        
        self.curConfig = nil;
    }
}

- (IBAction)testConnection:(id)sender
{
    // nil everything
    [self.configTableViewArrayController removeObjects:[self.configTableViewArrayController content]];
    [self.testConnectionMessage setStringValue:@""];
    
    // show sheet
    [self.testSheetProgress startAnimation: self];
    [NSApp beginSheet:self.testSheet 
       modalForWindow:[self window]
        modalDelegate:self 
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
          contextInfo:nil];
    
    //[self willChangeValueForKey:@"getOp"];
    [self setOp: [[ABPLDAPQueryOperation alloc] initWithConfig:curConfig andGetPictures:NO]];
    //[self didChangeValueForKey:@"getOp"];
    
    ABPConfigurationWindowController * weakController = self;
    ABPLDAPQueryOperation * weakOp = op;
    [op setCompletionBlock: ^{
        
        [weakController performSelectorOnMainThread:@selector(endTestConnection:) withObject: weakOp waitUntilDone:NO];
        
    }];
    
    [op start];
}

- (IBAction)openConnection:(id)sender
{    
    ABPAppDelegate * delegate = (ABPAppDelegate *) [NSApp delegate];
    
    ABPCompareWindowController * compareWin = [[ABPCompareWindowController alloc] initWithWindowNibName:@"ABPCompareWindowController" LDAPConfiguration:curConfig];

    [delegate.compareWindows addObject:compareWin];    
    
    [compareWin showWindow:self];
    [compareWin.window makeKeyAndOrderFront: self];

    return;
}

- (void)endTestConnection: (ABPLDAPQueryOperation *) inOp
{
    // if we're not the current op then nil it out
    if (inOp != op) {
        if ([canceledTestOps indexOfObject:inOp] != NSNotFound) {
            [canceledTestOps removeObjectAtIndex:[canceledTestOps indexOfObject:inOp]];
        }
    } else {
        if (op.errorString != nil) {
            [self.testConnectionMessage setStringValue:op.errorString];
        } else {
            
            [self.testConnectionMessage setStringValue:[NSString stringWithFormat:@"%ld results returned.", [op.results count]]];
            [self.configTableViewArrayController addObjects:op.results];
        }
        
        [self.testSheetProgress stopAnimation:self];
        [NSApp performSelectorOnMainThread:@selector(endSheet:) withObject:self.testSheet waitUntilDone:NO];
        [self.testSheet orderOut: self];
        
        [self setOp: nil];
    }
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
}

- (IBAction)cancelTest:(id)sender {
    
    // add current test to canceled array
    if (self.op != nil)
        [canceledTestOps addObject:self.op];
    
    // reset current op
    [self setOp: nil];
    
    // close up sheet
    [self.testSheetProgress stopAnimation:self];
    [NSApp performSelectorOnMainThread:@selector(endSheet:) withObject:self.testSheet waitUntilDone:NO];
    [self.testSheet orderOut: self];
}

#pragma mark - NSMenuDelegate

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    [[menu itemAtIndex:MENU_ACTION_DUMMY] setHidden:YES];
    [[menu itemAtIndex:MENU_ACTION_ADD_LDAP] setEnabled:YES];
    [[menu itemAtIndex:MENU_ACTION_DELETE_LDAP] setEnabled:(self.curConfig != nil)];
}

#pragma mark - NSControlTextEditingDelegate

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
    NSTextField *editedTextField = aNotification.object;
    if (editedTextField == self.connectionNameTextField) {
        NSTableCellView *selectedCell = [self.configTableView viewAtColumn:self.configTableView.selectedColumn
                                                                       row:self.configTableView.selectedRow
                                                           makeIfNecessary:NO];
        [selectedCell.textField setStringValue: self.curConfig.name];
    }
}

@end








