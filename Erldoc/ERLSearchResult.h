//
//  ERLSearchResult.h
//  Erldoc
//
//  Created by Joe Conway on 3/11/13.
//  Copyright (c) 2013 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ERLSearchResult : NSObject

@property (nonatomic, strong) NSArray *items;

- (void)addItem:(id)item;

@end
