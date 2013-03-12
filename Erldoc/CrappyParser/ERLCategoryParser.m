//
//  ERLCategoryParser.m
//  Erldoc
//
//  Created by Joe Conway on 10/17/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLCategoryParser.h"
#import "ERLCategoryElementParser.h"

@interface ERLCategoryParser ()
{
    NSMutableString *_string;
    NSMutableArray *_elements;
}
@end

@implementation ERLCategoryParser
@dynamic text, attributedText;

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if(self) {
        [self setTitle:[title stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
        _elements = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"h3"] || [elementName isEqualToString:@"hr"]) {
        [parser setDelegate:[self parentParser]];
        [[self parentParser] parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
        
        return;
    }
    
    ERLCategoryElementParser *cep = [[ERLCategoryElementParser alloc] initWithElementType:elementName];
    [cep setParentParser:self];
    [parser setDelegate:cep];
    [_elements addObject:cep];

}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"%@: UNKNOWN CHARACTERS %@", [self title], string);
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{

}

- (NSAttributedString *)attributedText
{
    NSMutableAttributedString *t = [[NSMutableAttributedString alloc] init];
    for(ERLCategoryElementParser *cep in _elements) {
        [t appendAttributedString:[cep attributedText]];
    }
    return t;
}

- (NSString *)text
{
    NSMutableAttributedString *t = [[NSMutableAttributedString alloc] init];
    for(ERLCategoryElementParser *cep in _elements) {
        [t appendAttributedString:[cep attributedText]];
    }
    return [t string];
}


@end
