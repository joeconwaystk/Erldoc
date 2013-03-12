//
//  ERLBrowserViewController.m
//  Erldoc
//
//  Created by Joe Conway on 10/19/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLBrowserViewController.h"
#import "ERLModuleViewController.h"
#import "ERLModule.h"
#import "ERLModuleParser.h"
#import "ERLFunction.h"
#import "ERLStore.h"
#import "ERLSearchResult.h"
#import "ERLDataType.h"
#import "ERLAppDelegate.h"

@interface ERLBrowserViewController ()
{
    
}

@property (weak) IBOutlet NSButton *prefButton;
@property (weak) IBOutlet NSTextField *instructionLabel;
@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) IBOutlet NSTableView *tableView;

- (IBAction)openPrefs:(id)sender;

@end

@implementation ERLBrowserViewController

- (id)init
{
    self = [super initWithNibName:@"ERLBrowserViewController" bundle:[NSBundle mainBundle]];
    if(self) {
        _modules = nil;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sourcePathChanged:)
                                                     name:ERLSourcePathChangedNotification
                                                   object:nil];

    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}


- (void)finalizeSearchTerm
{
    [_tableView deselectAll:nil];
    if([[[self searchResult] items] count] > 0) {
        [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0]
                byExtendingSelection:NO];
    }
}

- (void)setSearchTerm:(NSString *)searchTerm
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for(ERLModule *m in _modules) {
        if([[m name] rangeOfString:searchTerm].location != NSNotFound) {
            [items addObject:m];
        }
        for(ERLFunction *f in [m functions]) {
            if([[f name] rangeOfString:searchTerm].location != NSNotFound) {
                [items addObject:f];
            }
        }
        for(ERLFunction *f in [m callbacks]) {
            if([[f name] rangeOfString:searchTerm].location != NSNotFound) {
                [items addObject:f];
            }
        }
        for(ERLDataType *t in [m types]) {
            if([[t name] rangeOfString:searchTerm].location != NSNotFound) {
                [items addObject:t];
            }
        }
    }
    
    ERLSearchResult *s = [[ERLSearchResult alloc] init];
    [s setItems:items];
    [self setSearchResult:s];
    
}

- (void)setSearchResult:(ERLSearchResult *)searchResult
{
    _searchResult = searchResult;        
    [_tableView reloadData];
}

- (void)awakeFromNib
{
    if([[ERLStore store] sourcePath]) {
        [[self prefButton] setHidden:YES];
        [[self instructionLabel] setHidden:YES];
        [self sourcePathChanged:nil];
    } else {
    }

    [_tableView reloadData];
}

- (void)sourcePathChanged:(id)sender
{
    [[self prefButton] setHidden:YES];
    [[self instructionLabel] setHidden:YES];
    [[self moduleVC] setModule:nil];
    [[self spinner] startAnimation:nil];
    [[ERLStore store] fetchModulesWithCompletion:^(NSArray *module, NSError *err) {
        [[self prefButton] setHidden:YES];
        [[self instructionLabel] setHidden:YES];
        [[self spinner] stopAnimation:nil];
        _modules = module;
        [[self tableView] reloadData];
    }];

}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [[[self searchResult] items] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    id <ERLSearchable> item = [[[self searchResult] items] objectAtIndex:rowIndex];
    if([[aTableColumn identifier] isEqualToString:@"Text"]) {
        return [item displayName];
    }
    
    if([[aTableColumn identifier] isEqualToString:@"Image"]) {
        if([item respondsToSelector:@selector(displayImage)])
            return [item displayImage];
    }
    
    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    if([[self tableView] selectedRow] != -1) {
        id <ERLSearchable> item = [[[self searchResult] items] objectAtIndex:[[self tableView] selectedRow]];
        ERLModule *m = [item module];
        [[self moduleVC] setModule:m];
        if([item respondsToSelector:@selector(searchTag)]) {
            [[self moduleVC] scrollToTag:[item searchTag]];
        }
        [[self tableView] deselectRow:[[self tableView] selectedRow]];
    }
}

- (IBAction)openPrefs:(id)sender
{
    [(ERLAppDelegate *)[NSApp delegate] showPreferences:nil];
}
@end
