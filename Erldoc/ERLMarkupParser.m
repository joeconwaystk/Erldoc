//
//  ERLMarkupParser.m
//  Erldoc
//
//  Created by Joe Conway on 3/8/13.
//  Copyright (c) 2013 Big Nerd Ranch. All rights reserved.
//

#import "ERLMarkupParser.h"
#import "ERLHelpers.h"

@interface ERLMarkupParser ()

@property (nonatomic, strong) NSDictionary *map;
@end

@implementation ERLMarkupParser

- (id)init
{
    self = [super init];
    if(self) {

        NSFont *codeFont = [NSFont fontWithName:@"Menlo" size:14];
        NSFont *textFont = [NSFont fontWithName:@"Lucida Grande" size:14];
        _map =
        @{
          @"desc" : ^(NSMutableAttributedString *str, NSRange *range) {
              [str addAttribute:NSFontAttributeName value:textFont range:*range];
          },
          @"p" : ^(NSMutableAttributedString *str, NSRange *range) {
              NSMutableAttributedString *inside = [[str attributedSubstringFromRange:*range] mutableCopy];
              while ([[inside mutableString] rangeOfString:@"  "].location != NSNotFound) {
                  [[inside mutableString] replaceOccurrencesOfString:@"  " withString:@" " options:0 range:NSMakeRange(0, [[inside mutableString] length])];
              }
              [[inside mutableString] replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, [[inside mutableString] length])];
              [[inside mutableString] replaceOccurrencesOfString:@"\t" withString:@"" options:0 range:NSMakeRange(0, [[inside mutableString] length])];
              [inside appendAttributedString:ATTR(@"\n\n")];
              [inside insertAttributedString:ATTR(@"\t") atIndex:0];
              [inside addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, [inside length])];
              [str replaceCharactersInRange:*range withAttributedString:inside];
              range->length = [[inside mutableString] length];
          },
          @"pre" : ^(NSMutableAttributedString *str, NSRange *range) {
              NSMutableAttributedString *inside = [[str attributedSubstringFromRange:*range] mutableCopy];
              [inside appendAttributedString:ATTR(@"\n\n")];
              [str replaceCharactersInRange:*range withAttributedString:inside];
              range->length = [[inside mutableString] length];
          },

          @"code" : ^(NSMutableAttributedString *str, NSRange *range) {
              NSMutableAttributedString *inside = [[str attributedSubstringFromRange:*range] mutableCopy];
              
              [inside appendAttributedString:ATTR(@"\n\n")];
              [inside addAttribute:NSFontAttributeName value:codeFont range:NSMakeRange(0, [inside length])];
              [str replaceCharactersInRange:*range withAttributedString:inside];
              range->length = [[inside mutableString] length];
          },

          @"c" : ^(NSMutableAttributedString *str, NSRange *range) {
              [str addAttribute:NSFontAttributeName value:codeFont range:*range];
          },
          @"anno" : ^(NSMutableAttributedString *str, NSRange *range) {
              [str addAttribute:NSFontAttributeName value:codeFont range:*range];
          },
          @"input" : ^(NSMutableAttributedString *str, NSRange *range) {
              [str addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Menlo-Italic" size:14] range:*range];
          },
          @"item" : ^(NSMutableAttributedString *str, NSRange *range) {
              NSMutableAttributedString *inside = [[str attributedSubstringFromRange:*range] mutableCopy];
              while ([[inside mutableString] rangeOfString:@"  "].location != NSNotFound) {
                  [[inside mutableString] replaceOccurrencesOfString:@"  " withString:@" " options:0 range:NSMakeRange(0, [[inside mutableString] length])];
              }
              [[inside mutableString] replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, [[inside mutableString] length])];
              [[inside mutableString] replaceOccurrencesOfString:@"\t" withString:@"" options:0 range:NSMakeRange(0, [[inside mutableString] length])];
              
              [inside insertAttributedString:ATTR(@"\t\t• ") atIndex:0];
              [inside appendAttributedString:ATTR(@"\n\n")];
              [str replaceCharactersInRange:*range withAttributedString:inside];
              range->length = [[inside mutableString] length];
          }

        };
    }
    return self;
}


- (NSAttributedString *)transformString:(NSString *)str
{
    // This code will fail specatularly if there is the same tag within a tag. probably.
    NSMutableAttributedString *m = [[NSMutableAttributedString alloc] initWithString:str];
    
    for(int i = 0; i < [[m mutableString] length]; i++) {
        char c = [[m mutableString] characterAtIndex:i];
        if(c == '<') {
            NSUInteger currentLength = [[m mutableString] length];
            NSRange close = [[m mutableString] rangeOfString:@">" options:0 range:NSMakeRange(i + 1, currentLength - (i + 1))];
            if(close.location != NSNotFound) {
                NSRange tagRange = NSMakeRange(i, close.location - i + 1);
                NSRange tagNameRange = NSMakeRange(tagRange.location + 1, tagRange.length - 2);
                NSString *tagName = [[m mutableString] substringWithRange:tagNameRange];
                if([tagName isEqualToString:@"br"] || [tagName isEqualToString:@"/br"]) {
                    [m deleteCharactersInRange:tagRange];
                } else {
                    // Split out xml attrs
                    NSArray *tagNameComponents = [tagName componentsSeparatedByString:@" "];
                    tagName = [tagNameComponents objectAtIndex:0];
                    
                    NSString *tagEnd = [NSString stringWithFormat:@"</%@>", tagName];
                    NSRange endRange = [[m mutableString] rangeOfString:tagEnd options:0 range:NSMakeRange(i, currentLength - i)];
                    
                    NSRange internalRange = NSMakeRange(tagRange.location + tagRange.length, endRange.location - (tagRange.location + tagRange.length));
                    void (^change)(NSMutableAttributedString *, NSRange *) = [[self map] objectForKey:tagName];
                    if(change) {
                        change(m, &internalRange);
                        
                        // Recompute end
                        endRange.location = internalRange.location + internalRange.length;
                    }
                    
                    [m deleteCharactersInRange:endRange];
                    [m deleteCharactersInRange:tagRange];
                }
                i = -1;
            }
        }
    }
    return m;
}

@end
