//
//  ERLSearchViewController.h
//  Erldoc
//
//  Created by Joe Conway on 11/2/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ERLBrowserViewController;

@interface ERLSearchViewController : NSViewController
@property (nonatomic, weak) ERLBrowserViewController *browserVC;
@end
