//
//  ERLMarkupParser.h
//  Erldoc
//
//  Created by Joe Conway on 3/8/13.
//  Copyright (c) 2013 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ERLMarkupParser : NSObject

- (NSAttributedString *)transformString:(NSString *)str;

@end
