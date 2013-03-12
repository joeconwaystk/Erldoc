//
//  ERLCategoryElementParser.m
//  Erldoc
//
//  Created by Joe Conway on 10/17/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLCategoryElementParser.h"
#import "ERLCategoryParser.h"
#import "ERLExportParser.h"

@interface ERLCategoryElementParser ()
{
    NSMutableAttributedString *_string;
    NSString *_spanType;
}
@end

@implementation ERLCategoryElementParser
@dynamic attributedText;

- (id)initWithElementType:(NSString *)elementType
{
    self = [super init];
    if(self) {
        [self setElementType:elementType];
    }
    return self;
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"hr"]) {
        [parser setDelegate:[self parentParser]];
        [[self parentParser] parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
        return;
    }
    if([elementName isEqualToString:@"p"] || [elementName isEqualToString:@"div"])
    {
        //if(!_string)
        //    _string = [[NSMutableAttributedString alloc] init];
        [_string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
        
    } else if([elementName isEqualToString:@"span"]) {
        _spanType = attributeDict[@"class"];
    } else if([elementName isEqualToString:@"a"]) {
        if(!_elements)
            _elements = [[NSMutableArray alloc] init];
                
        ERLExportParser *cep = [[ERLExportParser alloc] initWithName:attributeDict[@"name"]];
        [cep setParentParser:self];
        [parser setDelegate:cep];
        [_elements addObject:cep];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(!_string)
        _string = [[NSMutableAttributedString alloc] init];
    
    NSString *cleanString = [string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:cleanString];
    if([_spanType isEqualToString:@"code"]) {
        [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, [attrString length])];
    } else if([_spanType isEqualToString:@"bold_code"]) {
        [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, [attrString length])];
    }
    [_string appendAttributedString:attrString];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   // NSLog(@"End: %@", elementName);
    if([elementName isEqualToString:[self elementType]]) {
        [parser setDelegate:[self parentParser]];
        return;
    }
    if([elementName isEqualToString:@"span"]) {
        _spanType = nil;
    }
}

- (NSAttributedString *)attributedText
{
    return _string;
}

- (NSString *)description
{
    NSMutableString *childrenTypes = [NSMutableString string];
    for(ERLCategoryElementParser *cep in _elements) {
        [childrenTypes appendFormat:@"%@ ", [cep elementType]];
    }
    return [NSString stringWithFormat:@"%@ (parent: %@, children: %@)",
            [self elementType],
            ([[self parentParser] isKindOfClass:[ERLCategoryElementParser class]] ?
                        [(ERLCategoryElementParser *)[self parentParser] elementType] :
                        [(ERLCategoryParser *)[self parentParser] title]),
            childrenTypes];
}
@end
