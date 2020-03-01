//
//  ABPCompareWindowController.m
//  AddressBookPictures
//
//  Created by Josh Jacob on 5/1/12.
//  Copyright (c) 2012 Josh Jacob. All rights reserved.
//

#import "ABPCompareWindowController.h"
#import "ABPLDAPCompareEntry.h"
#import "ABPLDAPEntry.h"
#import "ABPLDAPQueryOperation.h"
#import <AddressBook/AddressBook.h>

@interface ABPCompareWindowController ()

@end

@implementation ABPCompareWindowController
@synthesize tableView;
@synthesize arrayController;
@synthesize ldapConfig;
@synthesize entries;
@synthesize op;
@synthesize connectionSheet;
@synthesize connectionSheetProgress;
@synthesize connectionSheetCancel;

- (id) initWithWindowNibName: (NSString *) nibName LDAPConfiguration: (ABPLDAPConfiguration *) config
{
    self = [super initWithWindowNibName:nibName];
    if (self) {
        self.ldapConfig = config;
        
        didCancel = NO;
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window setDefaultButtonCell:[self.buttonSync cell]];
    
    // show sheet
    [self.connectionSheetProgress startAnimation: self];
    [NSApp beginSheet:self.connectionSheet 
       modalForWindow:[self window]
        modalDelegate:self 
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
          contextInfo:nil];
    
    [self setOp: [[ABPLDAPQueryOperation alloc] initWithConfig:self.ldapConfig andGetPictures:YES]];
    
    ABPCompareWindowController * weakController = self;
    ABPLDAPQueryOperation * weakOp = self.op;
    [op setCompletionBlock: ^{
        
        [weakController performSelectorOnMainThread:@selector(endConnection:) withObject: weakOp waitUntilDone:NO];
        
    }];
    
    [self.op start];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) dealloc
{
    self.entries = nil;
}

#pragma mark - IBActions

- (IBAction)setSkipAll:(id)sender {
    
    for (ABPLDAPCompareEntry * entry in self.entries)
    {
        entry.action = [[NSNumber alloc] initWithInt:ABPLDAPCompareEntrySKIP];
    }
}

- (IBAction)setUpdateAll:(id)sender {
    
    for (ABPLDAPCompareEntry * entry in self.entries)
    {
        entry.action = [[NSNumber alloc] initWithInt:ABPLDAPCompareEntryUPDATE];
    }
}

- (IBAction)setUpdateBlank:(id)sender {
    
    for (ABPLDAPCompareEntry * entry in self.entries)
    {
        if (entry.addressBookImage == nil) {
            entry.action = [[NSNumber alloc] initWithInt:ABPLDAPCompareEntryUPDATE];
        } else {
            entry.action = [[NSNumber alloc] initWithInt:ABPLDAPCompareEntrySKIP];
        }
    }
}

- (IBAction)synchronize:(id)sender {
    
    ABAddressBook* tempBook = [ABAddressBook addressBook];
        
    for (ABPLDAPCompareEntry * entry in self.entries)
    {
        if ([entry.action intValue] == ABPLDAPCompareEntryUPDATE)
        {
            ABPerson * record = (ABPerson *) [tempBook recordForUniqueId: entry.addressBookUniqueId];
            [record setImageData: [entry.ldapEntry.thumbnailPhoto TIFFRepresentation]];
        }
    }

    [tempBook save];
    tempBook = nil;
    
    [self createCompareEntries];
}

#pragma mark - Connection Sheet

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
}

- (void)endConnection: (ABPLDAPQueryOperation *) inOp
{
    if (didCancel == YES) {
        
        // dismiss sheet
        [self.connectionSheetProgress stopAnimation:self];
        [NSApp performSelectorOnMainThread:@selector(endSheet:) withObject:self.connectionSheet waitUntilDone:NO];
        [self.connectionSheet orderOut: self];
        
        // close window
        // self.op = nil;
        [self close];
        
    } else {
        
        if (op.errorString != nil) {
           
            // dismiss sheet
            [self.connectionSheetProgress stopAnimation:self];
            [NSApp performSelectorOnMainThread:@selector(endSheet:) withObject:self.connectionSheet waitUntilDone:NO];
            [self.connectionSheet orderOut: self];
        
            [self performSelectorOnMainThread:@selector(displayError) withObject:self waitUntilDone:NO];
            
        } else {
            
            [self createCompareEntries];
        }
        
        [self.connectionSheetProgress stopAnimation:self];
        [NSApp performSelectorOnMainThread:@selector(endSheet:) withObject:self.connectionSheet waitUntilDone:NO];
        [self.connectionSheet orderOut: self];
        
        // self.op = nil;
    }
}

- (IBAction)cancelConnection:(id)sender {
    
    didCancel = YES;
    [self.op setStatusString:@"Canceling..."];
    [connectionSheetCancel setEnabled: NO];
    [self.op cancel];
}

- (void) createCompareEntries {
    
    NSMutableArray * compareEntries = [[NSMutableArray alloc] initWithCapacity:[op.results count]];
    
    // look for users             
    ABAddressBook* tempBook = [ABAddressBook addressBook];
    
    for (ABPLDAPEntry * entry in op.results)
    {
        if ((entry.mail != nil) && ([entry.mail length] > 0) && (entry.thumbnailPhoto != nil))
        {
            ABSearchElement* emailSearch = [ABPerson searchElementForProperty:kABEmailProperty label:nil key:nil value:entry.mail comparison:kABEqualCaseInsensitive];
            
            NSArray * searchResults = [tempBook recordsMatchingSearchElement:emailSearch];
            
            for (ABPerson * record in searchResults) {
                
                // DLog(@"Found record: %@", [record valueForProperty:kABEmailProperty]);
                // DLog(@"Found record: %@", record);
                
                ABPLDAPCompareEntry * compareEntry = [[ABPLDAPCompareEntry alloc] init];
                compareEntry.ldapEntry = entry;
                compareEntry.addressBookUniqueId = record.uniqueId;
                compareEntry.addressBookImage = [[NSImage alloc] initWithData: record.imageData];
                compareEntry.action = [[NSNumber alloc] initWithInt: ABPLDAPCompareEntrySKIP];
                
                [compareEntries addObject:compareEntry];
                
                if ([record respondsToSelector:@selector(linkedPeople)]) {
                    NSArray *linkedArray = [record linkedPeople];
                    for (NSObject *linked in linkedArray) {
                        DLog(@"Linked %@", linked);
                    }
                }
            }
        }
    }
    
    tempBook = nil;
    
    [self.arrayController removeObjects:self.entries];
    self.entries = compareEntries;
    [self.arrayController addObjects:self.entries];
}

#pragma mark - Error sheet

- (void) displayError {
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Error!"];
    if (op.errorString != nil)
        [alert setInformativeText:op.errorString];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow:[self window] 
                      modalDelegate:self 
                     didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                        contextInfo:nil];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [self close];
}

@end
