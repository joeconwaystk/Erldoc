//
//  ERLParser.m
//  Erldoc
//
//  Created by Joe Conway on 10/30/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLModuleParser.h"
#import "ERLModule.h"
#import "ERLDescriptionParser.h"
#import "ERLFunctionsParser.h"
#import "ERLDataTypesParser.h"

@interface ERLModuleParser ()
{
    ERLParserObject *_currentObject;
}

@end

@implementation ERLModuleParser

- (id)initWithXMLData:(NSData *)data
{
    self = [super init];
    if(self) {
        _module = [[ERLModule alloc] init];
        
//        NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyHTML error:nil];
        
        [self parseData:data];//[doc XMLDataWithOptions:NSXMLDocumentTidyXML]];
    }
    return self;
}

- (void)regainControlFromChild:(ERLParserObject *)p
{
    if([p isKindOfClass:[ERLDescriptionParser class]]) {
        [_module setModuleDescription:[(ERLDescriptionParser *)p contents]];
    } else if([p isKindOfClass:[ERLFunctionsParser class]]) {
        [_module setModuleExports:[(ERLFunctionsParser *)p functions]];
    } else if([p isKindOfClass:[ERLDataTypesParser class]]) {
        [_module setModuleDataTypes:[(ERLDataTypesParser *)p dataTypes]];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Error %ld:%ld", [parser lineNumber], [parser columnNumber]);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"module"]) {
        [self beginAccumulatingString];
    } else if([elementName isEqualToString:@"modulesummary"]) {
        [self beginAccumulatingString];
    } else if([elementName isEqualToString:@"description"]) {
        _currentObject = [self passControlOfParserToInstanceOfType:[ERLDescriptionParser class]];
    } else if([elementName isEqualToString:@"funcs"]) {
        _currentObject = [self passControlOfParserToInstanceOfType:[ERLFunctionsParser class]];
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"module"]) {
        [_module setModuleName:[self returnAndClearAccumulatedString]];
    } else if([elementName isEqualToString:@"modulesummary"] ) {
        [_module setModuleSummary:[self returnAndClearAccumulatedString]];
    }
}

@end
