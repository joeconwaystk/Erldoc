//
//  ERLModuleParser.h
//  Erldoc
//
//  Created by Joe Conway on 11/2/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ERLModule;

@interface ERLModuleParser : NSObject

- (id)initWithPath:(NSString *)path xrefPath:(NSString *)xrefPath;

@property (nonatomic, strong, readonly) ERLModule *module;

@end
