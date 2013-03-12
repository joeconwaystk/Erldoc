//
//  ERLCategoryElementParser.h
//  Erldoc
//
//  Created by Joe Conway on 10/17/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ERLCategoryElementParser : NSObject <NSXMLParserDelegate>

- (id)initWithElementType:(NSString *)elementType;

@property (nonatomic, copy) NSString *elementType;
@property (nonatomic, weak) id <NSXMLParserDelegate> parentParser;
@property (nonatomic, readonly, strong) NSAttributedString *attributedText;
@property (nonatomic, readonly, strong) NSMutableArray *elements;
@end
