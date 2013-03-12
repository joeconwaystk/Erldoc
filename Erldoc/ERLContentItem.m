//
//  ERLContentItem.m
//  Erldoc
//
//  Created by Joe Conway on 10/30/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLContentItem.h"

@interface ERLContentItem ()
{
    NSMutableString *_string;
    NSMutableArray *_contents;
}
@end

@implementation ERLContentItem
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
        return;
    }
}
@end
