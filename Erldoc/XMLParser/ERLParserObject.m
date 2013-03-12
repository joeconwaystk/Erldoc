//
//  ERLParser.m
//  Erldoc
//
//  Created by Joe Conway on 10/30/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLParserObject.h"

@interface ERLParserObject ()
{
    NSMutableString *_string;
}
@end

@implementation ERLParserObject

- (void)parseData:(NSData *)data
{
    NSXMLParser *p = [[NSXMLParser alloc] initWithData:data];
    [self setParser:p];
    [p setDelegate:self];
    [p parse];
}

- (id)passControlOfParserToInstanceOfType:(Class)cls
{
    ERLParserObject *obj = [[cls alloc] init];
    [obj setParent:self];
    [[self parser] setDelegate:obj];
    [obj setParser:[self parser]];
    return obj;
}

- (void)returnControlToParent
{
    [[self parser] setDelegate:[self parent]];
    [[self parent] regainControlFromChild:self];
}

- (void)regainControlFromChild:(ERLParserObject *)p
{
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_string appendString:string];
}

- (void)beginAccumulatingString
{
    _string = [[NSMutableString alloc] init];
}

- (NSString *)returnAndClearAccumulatedString
{
    NSString *str = [_string copy];
    _string = nil;
    return str;
}

@end
