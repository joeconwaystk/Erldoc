//
//  ERLCategoryParser.h
//  Erldoc
//
//  Created by Joe Conway on 10/17/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ERLCategoryParser : NSObject <NSXMLParserDelegate>

- (id)initWithTitle:(NSString *)title;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, weak) id <NSXMLParserDelegate> parentParser;
@property (nonatomic, readonly) NSAttributedString *attributedText;
@property (nonatomic, readonly) NSString *text;
@end
