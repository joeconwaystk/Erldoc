//
//  ERLSearchResult.m
//  Erldoc
//
//  Created by Joe Conway on 3/11/13.
//  Copyright (c) 2013 Big Nerd Ranch. All rights reserved.
//

#import "ERLSearchResult.h"

@interface ERLSearchResult ()
{
    NSMutableArray *_searchResults;
}
@end

@implementation ERLSearchResult
@synthesize items = _searchResults;

- (id)init
{
    self = [super init];
    if(self) {
        _searchResults = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)addItem:(id)item
{
    [_searchResults addObject:item];
}
@end
