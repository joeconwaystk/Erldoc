//
//  ERLTypeParser.h
//  Erldoc
//
//  Created by Joe Conway on 3/5/13.
//  Copyright (c) 2013 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ERLTypeParser : NSObject

- (id)initWithXMLElement:(NSXMLElement *)e;

@property (nonatomic, strong, readonly) NSAttributedString *attributedString;

@end
