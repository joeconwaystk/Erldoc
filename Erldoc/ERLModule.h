//
//  ERLModule.h
//  Erldoc
//
//  Created by Joe Conway on 10/17/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ERLSearchable.h"

@class ERLFunction;

@interface ERLModule : NSObject <NSCoding, ERLSearchable>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSAttributedString *summary;
@property (nonatomic, copy) NSAttributedString *discussion;
@property (nonatomic, copy) NSMutableArray *types;
@property (nonatomic, copy) NSMutableArray *functions;
@property (nonatomic, copy) NSMutableArray *callbacks;

- (BOOL)containsString:(NSString *)str;
- (ERLFunction *)functionWithName:(NSString *)fName arity:(int)arity;

@end
