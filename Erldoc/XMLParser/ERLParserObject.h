//
//  ERLParser.h
//  Erldoc
//
//  Created by Joe Conway on 10/30/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ERLParserObject : NSObject <NSXMLParserDelegate>

@property (nonatomic, weak) ERLParserObject *parent;
@property (nonatomic, assign) NSXMLParser *parser;

- (void)parseData:(NSData *)data;

- (void)beginAccumulatingString;
- (NSString *)returnAndClearAccumulatedString;

- (id)passControlOfParserToInstanceOfType:(Class)cls;
- (void)returnControlToParent;

// Override
- (void)regainControlFromChild:(ERLParserObject *)p;

@end
