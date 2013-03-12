//
//  ERLModuleParser.h
//  Erldoc
//
//  Created by Joe Conway on 10/17/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ERLModule;

@interface ERLModuleParser : NSObject
- (id)initWithHTMLData:(NSData *)d;

@property (nonatomic, strong, readonly) NSMutableDictionary *categories;
@property (nonatomic, strong, readonly) ERLModule *module;
@end
