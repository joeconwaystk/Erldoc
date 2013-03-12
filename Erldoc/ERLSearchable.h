//
//  ERLSearchable.h
//  Erldoc
//
//  Created by Joe Conway on 3/11/13.
//  Copyright (c) 2013 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ERLModule;

@protocol ERLSearchable <NSObject>

- (NSString *)displayName;
- (ERLModule *)module;

@optional
- (NSImage *)displayImage;
- (NSString *)searchTag;

@end