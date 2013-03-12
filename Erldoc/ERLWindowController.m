//
//  ERLWindowController.m
//  Erldoc
//
//  Created by Joe Conway on 10/17/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLWindowController.h"
#import "ERLModuleParser.h"
#import "ERLModuleViewController.h"
#import "ERLModule.h"
#import "ERLBrowserViewController.h"
#import "ERLSearchViewController.h"

@interface ERLWindowController () <NSTextFieldDelegate>
{
    ERLSearchViewController *searchVC;
    ERLModuleViewController *moduleVC;
    ERLBrowserViewController *browserVC;
}
@end

@implementation ERLWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if(self) {
        browserVC = [[ERLBrowserViewController alloc] init];
        moduleVC = [[ERLModuleViewController alloc] init];
        searchVC = [[ERLSearchViewController alloc] init];
        [browserVC setModuleVC:moduleVC];
        [searchVC setBrowserVC:browserVC];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    

    int h = 400;
    int searchHeight = 22;
    int leftHeight = h - searchHeight;
    [[[self window] contentView] addSubview:[searchVC view]];
    [[[self window] contentView] addSubview:[browserVC view]];
    [[[self window] contentView] addSubview:[moduleVC view]];


    NSArray *c = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[a(==200)][b(>=600)]|"
                                                         options:0
                                                         metrics:nil
                                                           views:@{@"a" : [browserVC view], @"b" : [moduleVC view]}];
    [[[self window] contentView] addConstraints:c];

    c = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|[s(==200)][b(>=600)]|"]
                                                options:0
                                                metrics:nil
                                                  views:@{@"b" : [moduleVC view], @"s" : [searchVC view]}];
    [[[self window] contentView] addConstraints:c];

    
    c = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[b(>=%d)]|", h]
                                                options:0
                                                metrics:nil
                                                  views:@{@"b" : [moduleVC view]}];
    [[[self window] contentView] addConstraints:c];

    c = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[s(==%d)][a(>=%d)]|", searchHeight, leftHeight]
                                                options:0
                                                metrics:nil
                                                  views:@{@"a" : [browserVC view], @"s" : [searchVC view]}];
    [[[self window] contentView] addConstraints:c];
}

@end
