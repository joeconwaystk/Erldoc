//
//  ERLSearchViewController.m
//  Erldoc
//
//  Created by Joe Conway on 11/2/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLSearchViewController.h"
#import "ERLBrowserViewController.h"

@interface ERLSearchViewController () <NSTextFieldDelegate>

- (IBAction)searchChanged:(id)sender;

@end

@implementation ERLSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"ERLSearchViewController" bundle:nil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}



- (IBAction)searchChanged:(id)sender
{
    [[self browserVC] setSearchTerm:[sender stringValue]];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    [[self browserVC] finalizeSearchTerm];
}
@end
