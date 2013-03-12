//
//  ERLDescriptionParser.h
//  Erldoc
//
//  Created by Joe Conway on 10/30/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ERLParserObject.h"

@interface ERLDescriptionParser : ERLParserObject

@property (nonatomic, strong, readonly) NSArray *contents;

@end
