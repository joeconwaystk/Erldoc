//
//  ERLFunction.h
//  Erldoc
//
//  Created by Joe Conway on 10/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ERLSearchable.h"

@class ERLModule;

@interface ERLFunction : NSObject <NSCoding, ERLSearchable>

@property (nonatomic, strong) NSString *label;

@property (nonatomic, copy) NSString *name;
@property (nonatomic) int arity;
@property (nonatomic, getter = isExported) BOOL exported;
@property (nonatomic, copy) NSString *callName;
@property (nonatomic, copy) NSAttributedString *callSemantics;
@property (nonatomic, strong) NSArray *argumentDefinitions;
@property (nonatomic, copy) NSAttributedString *discussion;
@property (nonatomic, copy) NSAttributedString *summary;
@property (nonatomic, getter = isCallback) BOOL callback;

@property (nonatomic, weak) ERLModule *module;

@end
