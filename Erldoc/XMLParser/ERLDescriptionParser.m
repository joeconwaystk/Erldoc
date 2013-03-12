//
//  ERLDescriptionParser.m
//  Erldoc
//
//  Created by Joe Conway on 10/30/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLDescriptionParser.h"
#import "ERLContentItem.h"

@interface ERLDescriptionParser ()
{
    NSMutableArray *_contents;
}
@end

@implementation ERLDescriptionParser
@synthesize contents = _contents;

- (id)init
{
    self = [super init];
    if(self) {
        _contents = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"div"]) {
        ERLContentItem *i = [self passControlOfParserToInstanceOfType:[ERLContentItem class]];
        [i setType:attributeDict[@"class"]];
        [_contents addObject:i];
        return;
    }
    
    if([elementName isEqualToString:@"p"]) {
        [self beginAccumulatingString];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"p"]) {
        [_contents addObject:[self returnAndClearAccumulatedString]];
    } else if([elementName isEqualToString:@"div"]) {
        [self returnControlToParent];
    }
}

@end
