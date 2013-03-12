//
//  ERLDescriptionParser.h
//  Erldoc
//
//  Created by Joe Conway on 3/5/13.
//  Copyright (c) 2013 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ERLDescriptionParser : NSObject

- (id)initWithElements:(NSArray *)elements;

@property (nonatomic, readonly, strong) NSAttributedString *summary;
@property (nonatomic, readonly, strong)  NSAttributedString *discussion;

@end
