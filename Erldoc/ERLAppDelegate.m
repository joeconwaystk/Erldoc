//
//  ERLAppDelegate.m
//  Erldoc
//
//  Created by Joe Conway on 10/17/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLAppDelegate.h"
#import "ERLModuleParser.h"
#import "ERLModuleViewController.h"
#import "ERLWindowController.h"
#import "ERLModule.h"
#import "ERLPreferencesWindowController.h"

@interface ERLAppDelegate ()
@property (nonatomic, strong) ERLWindowController *windowController;
@property (nonatomic, strong) ERLPreferencesWindowController *prefController;
@end

@implementation ERLAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ERLWindowController *w = [[ERLWindowController alloc] initWithWindowNibName:@"ERLWindowController"];
    [w showWindow:self];
    _windowController = w;
}

- (IBAction)showPreferences:(id)sender
{
    if(!_prefController)
        _prefController = [[ERLPreferencesWindowController alloc] initWithWindowNibName:@"ERLPreferencesWindowController"];
    [_prefController showWindow:self];
    [[_prefController window] makeKeyAndOrderFront:nil];
    [[_prefController window] center];
}

@end
