//
//  ERLFunctionParser.m
//  Erldoc
//
//  Created by Joe Conway on 10/30/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLFunctionParser.h"
#import "ERLDescriptionParser.h"
#import "ERLFunction.h"

@interface ERLFunctionParser ()
{
    NSMutableString *_string;
    NSMutableDictionary *_usageDictionary;
}
@end

@implementation ERLFunctionParser

- (id)init
{
    self = [super init];
    if(self) {
        _usageDictionary = [[NSMutableDictionary alloc] init];
        _function = [[ERLFunction alloc] init];
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"h3"]) {
        _string = [[NSMutableString alloc] init];
        _usageDictionary[attributeDict[@"id"]] = _string;
    } else if([elementName isEqualToString:@"ul"]) {
        if([attributeDict[@"class"] isEqualToString:@"type"]) {
            _string = [[NSMutableString alloc] init];
        }
    } else if([elementName isEqualToString:@"div"]) {
        [self passControlOfParserToInstanceOfType:[ERLDescriptionParser class]];
        return;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_string appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"h3"]) {
        _string = nil;
    } else if([elementName isEqualToString:@"ul"]) {
        _string = nil;
    } else if([elementName isEqualToString:@"div"]) {
        [self returnControlToParent];
    }
}


@end
