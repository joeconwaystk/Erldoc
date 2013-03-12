//
//  ERLDataType.h
//  Erldoc
//
//  Created by Joe Conway on 10/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ERLSearchable.h"

@class ERLModule;

@interface ERLDataType : NSObject <NSCoding, ERLSearchable>

@property (nonatomic, copy) NSString *label;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSAttributedString *shortDescription;
@property (nonatomic, copy) NSAttributedString *longDescription;

@property (nonatomic, copy) NSAttributedString *definition;

@property (nonatomic, weak) ERLModule *module;

@end
