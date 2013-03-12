//
//  ERLDescriptionParser.m
//  Erldoc
//
//  Created by Joe Conway on 3/5/13.
//  Copyright (c) 2013 Big Nerd Ranch. All rights reserved.
//

#import "ERLDescriptionParser.h"

@interface ERLDescriptionParser ()
- (NSAttributedString *)parseMarkup:(NSArray *)elements;
@end

@implementation ERLDescriptionParser

- (id)initWithElements:(NSArray *)elements
{
    self = [super init];
    if(self) {
        if([elements count] > 0) {
            NSXMLElement *e = elements[0];
            _discussion = [self parseMarkup:[e elementsForName:@"fullDescription"]];
            _summary = [self parseMarkup:[e elementsForName:@"briefDescription"]];
        }
    }
    return self;
}

- (NSAttributedString *)parseMarkup:(NSArray *)elements
{
    if([elements count] == 1) {
        NSXMLElement *e = [elements objectAtIndex:0];
        NSMutableString *str = [[e XMLString] mutableCopy];
        [str replaceOccurrencesOfString:@"<fullDescription>" withString:@"" options:0 range:NSMakeRange(0, [str length])];
        [str replaceOccurrencesOfString:@"<briefDescription>" withString:@"" options:0 range:NSMakeRange(0, [str length])];
        [str replaceOccurrencesOfString:@"</fullDescription>" withString:@"" options:0 range:NSMakeRange(0, [str length])];
        [str replaceOccurrencesOfString:@"</briefDescription>" withString:@"" options:0 range:NSMakeRange(0, [str length])];
        [str replaceOccurrencesOfString:@"<a href=\"([^\"]*)\">" withString:@"!j!$1!c!" options:NSRegularExpressionSearch range:NSMakeRange(0, [str length])];
        [str replaceOccurrencesOfString:@"</a>" withString:@"!c!j!" options:0 range:NSMakeRange(0, [str length])];
        id output = [[NSMutableAttributedString alloc] initWithHTML:[str dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:@{NSTextSizeMultiplierDocumentOption : @(1.2)}
                                                 documentAttributes:nil];
        NSMutableArray *rangeDicts = [[NSMutableArray alloc] init];
        NSRegularExpression *exp  = [[NSRegularExpression alloc] initWithPattern:@"!j!(.*)!c!(.*)!c!j!" options:0 error:nil];
        NSString *os = [output string];
        [exp enumerateMatchesInString:os options:0 range:NSMakeRange(0, [os length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSRange replaceRange = [result range];
            NSRange hrefRange = [result rangeAtIndex:1];
            NSRange textRange = [result rangeAtIndex:2];
            [rangeDicts addObject:@{@"r" : [NSValue valueWithRange:replaceRange], @"h" : [os substringWithRange:hrefRange], @"t" : [os substringWithRange:textRange]}];
        }];
        
        for(int i = (int)[rangeDicts count] - 1; i >= 0; i --) {
            NSDictionary *d = rangeDicts[i];
            NSRange rr = [d[@"r"] rangeValue];
            NSString *href = d[@"h"];
            NSString *text = d[@"t"];
            
            NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:@{NSLinkAttributeName : href}];
            [output replaceCharactersInRange:rr withAttributedString:attrStr];
        }
        
        return output;
        //return [[NSAttributedString alloc] initWithString:[e stringValue]];
    }
    
    return nil;
}


@end
