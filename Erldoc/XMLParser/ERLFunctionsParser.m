//
//  ERLFunctionsParser.m
//  Erldoc
//
//  Created by Joe Conway on 10/30/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLFunctionsParser.h"
#import "ERLFunctionParser.h"

@interface ERLFunctionsParser ()
{
    NSMutableArray *_functions;
    ERLFunctionParser *_currentFunctionParser;
}
@end


@implementation ERLFunctionsParser
@synthesize functions = _functions;

- (id)init
{
    self = [super init];
    if(self) {
        _functions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)regainControlFromChild:(ERLParserObject *)p
{
    [_functions addObject:[(ERLFunctionParser *)p function]];
    if(p == _currentFunctionParser)
        _currentFunctionParser = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"func"]) {
        _currentFunctionParser = [self passControlOfParserToInstanceOfType:[ERLFunctionParser class]];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"funcs"]) {
        [self returnControlToParent];
        return;
    }
}

@end
