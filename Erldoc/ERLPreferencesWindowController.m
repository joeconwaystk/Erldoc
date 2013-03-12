//
//  ERLPreferencesWindowController.m
//  Erldoc
//
//  Created by Joe Conway on 3/12/13.
//  Copyright (c) 2013 Big Nerd Ranch. All rights reserved.
//

#import "ERLPreferencesWindowController.h"
#import "ERLStore.h"

@interface ERLPreferencesWindowController () <NSOpenSavePanelDelegate>

@property (weak) IBOutlet NSTextField *sourcePathField;
- (IBAction)chooseSourcePath:(id)sender;

@end

@implementation ERLPreferencesWindowController

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
    
    if([[ERLStore store] sourcePath])
        [[self sourcePathField] setStringValue:[[ERLStore store] sourcePath]];
}

- (IBAction)chooseSourcePath:(id)sender
{
    NSOpenPanel *op = [NSOpenPanel openPanel];
    [op setCanChooseDirectories:YES];
    [op setCanChooseFiles:NO];
    [op setCanCreateDirectories:NO];
    [op setAllowsMultipleSelection:NO];
    [op setTitle:@"Select Erlang Source"];
    [op setMessage:@"Select the lib directory of the Erlang source code as downloaded from http://www.erlang.org/download.html.\n For example, otp_src_R16B/lib."];
    [op setPrompt:@"Choose Directory"];
    if([op runModal] == NSFileHandlingPanelOKButton) {
        if([[op URLs] count] == 1) {
            NSString *path = [[[op URLs] objectAtIndex:0] path];
            [[self sourcePathField] setStringValue:path];
            [[ERLStore store] setSourcePath:path];
        }
    }
}

@end
