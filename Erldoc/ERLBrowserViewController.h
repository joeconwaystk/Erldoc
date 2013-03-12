//
//  ERLBrowserViewController.h
//  Erldoc
//
//  Created by Joe Conway on 10/19/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ERLModuleViewController, ERLSearchResult;

@interface ERLBrowserViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) ERLModuleViewController *moduleVC;
@property (nonatomic, strong) ERLSearchResult *searchResult;
@property (nonatomic, strong) NSArray *modules;

- (void)setSearchTerm:(NSString *)searchTerm;

- (id)init;
- (void)finalizeSearchTerm;

@end
