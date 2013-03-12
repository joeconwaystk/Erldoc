//
//  ERLTypeParser.m
//  Erldoc
//
//  Created by Joe Conway on 3/5/13.
//  Copyright (c) 2013 Big Nerd Ranch. All rights reserved.
//

#import "ERLTypeParser.h"
#import "ERLHelpers.h"

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"


@interface ERLTypeParser ()

@end


@implementation ERLTypeParser

/*
 typevar (has attribute "name"), for local defs
 atom, integer, range, binary, float, nil, , , , 'fun', record, abstype,
 union list, nonempty_list, paren, tuple
 */

#define STRING(x) [self performSelector:[ERLTypeParser selectorForType:[x name]] withObject:x]
#define XML_ATTR(x, y) [[x attributeForName:y] stringValue]

+ (SEL)selectorForType:(NSString *)type
{
    NSDictionary *d = @{@"typevar" : @"parseTypevar:",
                        @"atom" : @"parseAtom:",
                        @"integer" : @"parseInteger:",
                        @"range" : @"parseRange:",
                        @"binary" : @"parseBinary:",
                        @"float" : @"parseFloat:",
                        @"nil" : @"parseNil:",
                        @"fun" : @"parseFun:",
                        @"record" : @"parseRecord:",
                        @"abstype" : @"parseAbsType:",
                        @"union" : @"parseUnion:",
                        @"list" : @"parseList:",
                        @"nonempty_list" : @"parseNonEmptyList:",
                        @"paren" : @"parseParen:",
                        @"tuple" : @"parseTuple:",
                        @"erlangName" : @"parseErlangName:",
                        @"type" : @"parseType:",
                        };
    
    if(d[type])
        return NSSelectorFromString(d[type]);
    return nil;
}


- (id)initWithXMLElement:(NSXMLElement *)e
{
    self = [super init];
    if(self) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        if([e attributeForName:@"name"]) {
            [attr appendAttributedString:ATTR([[e attributeForName:@"name"] stringValue])];
            [attr appendAttributedString:ATTR(@" :: ")];
        }
        if([e childCount] == 1) {
            NSXMLElement *firstChild = (NSXMLElement *)[e childAtIndex:0];
            [attr appendAttributedString:STRING(firstChild)];
            _attributedString = attr;
        } else {
            NSLog(@"ERLTypeParser incorrect assumption in %@", NSStringFromSelector(_cmd));
        }
    }
    return self;
}

- (NSMutableAttributedString *)parseTypevar:(NSXMLElement *)e
{
    return [[NSMutableAttributedString alloc] initWithString:XML_ATTR(e, @"name")];
}

- (NSMutableAttributedString *)parseAtom:(NSXMLElement *)e
{
    return [[NSMutableAttributedString alloc] initWithString:XML_ATTR(e, @"value")];
}


- (NSMutableAttributedString *)parseErlangName:(NSXMLElement *)e
{
    NSString *str = XML_ATTR(e, @"name");
    NSString *realStr = str;
    if([realStr rangeOfString:@"non_neg_integer"].location != NSNotFound)
        realStr = [realStr stringByReplacingOccurrencesOfString:@"non_neg_integer" withString:@"integer () >= 0"];
    else if([realStr rangeOfString:@"non_neg_integer"].location != NSNotFound)
        realStr = [realStr stringByReplacingOccurrencesOfString:@"pos_integer" withString:@"integer () >= 1"];
    
    return [[NSMutableAttributedString alloc] initWithString:realStr];
}

- (NSMutableAttributedString *)parseRange:(NSXMLElement *)e
{
    NSString *str = XML_ATTR(e, @"value");
    return [[NSMutableAttributedString alloc] initWithString:str];
}

- (NSMutableAttributedString *)parseInteger:(NSXMLElement *)e
{
    NSString *str = XML_ATTR(e, @"value");
    return [[NSMutableAttributedString alloc] initWithString:str];
}

- (NSMutableAttributedString *)parseFloat:(NSXMLElement *)e
{
    NSString *str = XML_ATTR(e, @"value");
    return [[NSMutableAttributedString alloc] initWithString:str];
}


- (NSMutableAttributedString *)parseNil:(NSXMLElement *)e
{
    return [[NSMutableAttributedString alloc] initWithString:@"[]"];
}

- (NSMutableAttributedString *)parseType:(NSXMLElement *)e
{
    NSString *n = XML_ATTR(e, @"name");
    if(n) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:n];
        [str appendAttributedString:ATTR(@" :: ")];
        if([e childCount] == 1) {
            [str appendAttributedString:STRING([e childAtIndex:0])];
        } else {
            NSLog(@"ERLTYpeParser incorrect assumption %@", NSStringFromSelector(_cmd));
        }
        return str;
    }
    if([e childCount] == 1)
        return STRING([e childAtIndex:0]);
    
    NSLog(@"ERLTypeParser incorrecta ssumption %@", NSStringFromSelector(_cmd));
    return [[NSMutableAttributedString alloc] init];
}

- (NSMutableAttributedString *)parseParen:(NSXMLElement *)e
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"("];
    for(NSXMLElement *c in [e children]) {
        [str appendAttributedString:STRING(c)];
    }
    [str appendAttributedString:ATTR(@")")];
    return str;
}


- (NSMutableAttributedString *)parseFun:(NSXMLElement *)e
{
    NSXMLElement *args = ERLOnly(e, @"argtypes");
    NSXMLElement *ret = ERLOnly(e, @"type");
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    [str appendAttributedString:ATTR(@"(")];
    for(NSXMLElement *c in [args children]) {
        [str appendAttributedString:STRING(c)];
        if(c != [[args children] lastObject])
            [str appendAttributedString:ATTR(@", ")];
    }
    [str appendAttributedString:ATTR(@") -> ")];
    
    [str appendAttributedString:STRING(ret)];
    
    return str;
}

- (NSMutableAttributedString *)parseAbsType:(NSXMLElement *)e
{
    NSString *href = XML_ATTR(e, @"href");
    NSXMLElement *n = ERLOnly(e, @"erlangName");
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    [attr appendAttributedString:[self parseErlangName:n]];
    if(href) {
        [attr setAttributes:@{NSLinkAttributeName : href}
                      range:NSMakeRange(0, [attr length])];
    }

    if([[e children] count] > 1) {
        [attr appendAttributedString:ATTR(@"(")];
        for(NSXMLElement *c in [e children]) {
            if(c != n) {
                [attr appendAttributedString:STRING(c)];
                if(c != [[e children] lastObject])
                    [attr appendAttributedString:ATTR(@",")];
            }
        }
        [attr appendAttributedString:ATTR(@")")];
    } else {
        if([[attr mutableString] rangeOfString:@"()"].location == NSNotFound)
            [attr appendAttributedString:ATTR(@"()")];
    }
    return attr;
}

- (NSMutableAttributedString *)parseUnion:(NSXMLElement *)e
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    for(NSXMLElement *c in [e children]) {
        [str appendAttributedString:STRING(c)];
        if(c != [[e children] lastObject])
            [str appendAttributedString:ATTR(@" | ")];
    }
    return str;
}

- (NSMutableAttributedString *)parseTuple:(NSXMLElement *)e
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    [str appendAttributedString:ATTR(@"{")];
    for(NSXMLElement *c in [e children]) {
        [str appendAttributedString:STRING(c)];
        if(c != [[e children] lastObject])
            [str appendAttributedString:ATTR(@", ")];
    }
    [str appendAttributedString:ATTR(@"}")];

    return str;
}


- (NSMutableAttributedString *)parseRecord:(NSXMLElement *)e
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    [str appendAttributedString:ATTR(@"#")];
    for(NSXMLElement *c in [e children]) {
        [str appendAttributedString:STRING(c)];
        if(c == [[e children] objectAtIndex:0]) {
            [str appendAttributedString:ATTR(@"{")];
        } else {            
            if(c != [[e children] lastObject])
                [str appendAttributedString:ATTR(@", ")];
        }
    }
    [str appendAttributedString:ATTR(@"}")];
    
    return str;
}

- (NSMutableAttributedString *)parseList:(NSXMLElement *)e
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    [str appendAttributedString:ATTR(@"[")];
    for(NSXMLElement *c in [e children]) {
        [str appendAttributedString:STRING(c)];
        if(c != [[e children] lastObject])
            [str appendAttributedString:ATTR(@", ")];
    }
    [str appendAttributedString:ATTR(@"]")];
    return str;
}

- (NSMutableAttributedString *)parseNonEmptyList:(NSXMLElement *)e
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    [str appendAttributedString:ATTR(@"[")];
    for(NSXMLElement *c in [e children]) {
        [str appendAttributedString:STRING(c)];
        [str appendAttributedString:ATTR(@", ")];
    }
    [str appendAttributedString:ATTR(@" ...]")];
    return str;
}


@end
