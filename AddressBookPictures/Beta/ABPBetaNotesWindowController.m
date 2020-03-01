//
//  ABPBetaNotesWindowController.m
//  AddressBookPictures
//
//  Created by Josh Jacob on 2/19/13.
//  Copyright (c) 2013 Josh Jacob. All rights reserved.
//

#import "ABPBetaNotesWindowController.h"

@interface ABPBetaNotesWindowController ()

@end

@implementation ABPBetaNotesWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [[self window] setExcludedFromWindowsMenu:YES];
    
    [self.textView readRTFDFromFile:[[NSBundle mainBundle] pathForResource:@"BetaTesterNotes" ofType:@"rtf"]];
}

@end
