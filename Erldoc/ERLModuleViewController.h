//
//  ERLModuleViewController.h
//  Erldoc
//
//  Created by Joe Conway on 10/17/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ERLModule, ERLFunction, ERLDataType, ERLBrowserViewController;

@interface ERLModuleViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) ERLModule *module;

- (void)scrollToTag:(NSString *)tag;

@end
