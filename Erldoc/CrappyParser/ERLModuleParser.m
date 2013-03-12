//
//  ERLModuleParser.m
//  Erldoc
//
//  Created by Joe Conway on 10/17/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLModuleParser.h"
#import "ERLCategoryParser.h"
#import "ERLModule.h"
#import "ERLDataType.h"
#import "ERLFunction.h"
#import "ERLArgumentType.h"

@interface ERLModuleParser ()
{
    BOOL startPayingAttention;
    int divStack;
    NSMutableString *categoryString;
}
- (void)parseDescription:(NSString *)desc;
- (void)parseExports:(NSString *)exports;
- (void)parseDataTypes:(NSString *)dataTypes;

- (NSArray *)findDataTypesStrings:(NSString *)str;
- (void)parseEachDataType:(NSArray *)dataTypes;
- (NSArray *)findFunctionExports:(NSString *)str;
- (ERLFunction *)parseFunctionDictionary:(NSDictionary *)d;

- (NSDictionary *)findTypeMapFromStrings:(NSArray *)strings;

- (void)stripDecorations:(NSMutableString *)str;
- (NSArray *)findChunksWithPattern:(NSString *)pattern string:(NSString *)str;
@end

@implementation ERLModuleParser

- (id)initWithHTMLData:(NSData *)d
{
    self = [super init];
    if(self) {
        _categories = [[NSMutableDictionary alloc] init];
        NSString *htmlDocString = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
        
        _module = [[ERLModule alloc] init];
        
        NSRegularExpression *expr = [[NSRegularExpression alloc] initWithPattern:@"<h3>MODULE<\\/h3>[ \\\n]*<div class=\"REFBODY\">(.*?)<\\/div>" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
        NSArray *matches = [expr matchesInString:htmlDocString options:0 range:NSMakeRange(0, [htmlDocString length])];
        if([matches count] > 0) {
            NSTextCheckingResult *r = matches[0];
            if([r numberOfRanges] > 0) {
                NSRange range = [r rangeAtIndex:1];
                [_module setModuleName:[htmlDocString substringWithRange:range]];
            }
        }
        

        expr = [[NSRegularExpression alloc] initWithPattern:@"<h3>MODULE SUMMARY<\\/h3>[ \\\n]*<div class=\"REFBODY\">(.*?)<\\/div>" options:0 error:nil];
        matches = [expr matchesInString:htmlDocString options:0 range:NSMakeRange(0, [htmlDocString length])];
        if([matches count] > 0) {
            NSTextCheckingResult *r = matches[0];
            if([r numberOfRanges] > 0) {
                NSRange range = [r rangeAtIndex:1];
                [_module setModuleSummary:[htmlDocString substringWithRange:range]];
            }
        }

        expr = [[NSRegularExpression alloc] initWithPattern:@"<h3>DESCRIPTION<\\/h3>(.*?)<h3>" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
        matches = [expr matchesInString:htmlDocString options:0 range:NSMakeRange(0, [htmlDocString length])];
        if([matches count] > 0) {
            NSTextCheckingResult *r = matches[0];
            if([r range].location != NSNotFound) {
                NSRange range = [r range];
                [self parseDescription:[htmlDocString substringWithRange:range]];
            } else {
                [_module setModuleDescription:@"???"];
            }
        }

        expr = [[NSRegularExpression alloc] initWithPattern:@"<h3>DATA TYPES<\\/h3>(.*?)<h3" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
        matches = [expr matchesInString:htmlDocString options:0 range:NSMakeRange(0, [htmlDocString length])];
        if([matches count] > 0) {
            NSTextCheckingResult *r = matches[0];
            if([r numberOfRanges] > 0) {
                NSRange range = [r rangeAtIndex:1];
                [self parseDataTypes:[htmlDocString substringWithRange:range]];
            }
        }
        
        expr = [[NSRegularExpression alloc] initWithPattern:@"<h3>EXPORTS<\\/h3>(.*?)<h" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
        matches = [expr matchesInString:htmlDocString options:0 range:NSMakeRange(0, [htmlDocString length])];
        if([matches count] > 0) {
            NSTextCheckingResult *r = matches[0];
            if([r numberOfRanges] > 0) {
                NSRange range = [r rangeAtIndex:1];
                [self parseExports:[htmlDocString substringWithRange:range]];
            }
        }

        
    }
    return self;
}

- (void)stripDecorations:(NSMutableString *)str
{
    [str replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"&lt;" withString:@"<" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"&gt;" withString:@">" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\t" withString:@" " options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"  " withString:@"" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\n" withString:@" " options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<p>" withString:@"" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"</p>" withString:@"\n\n" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<br>" withString:@"\n\n" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<div class=\"REFBODY\">" withString:@"" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"</div>" withString:@"" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<ul>" withString:@"" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"</ul>" withString:@"\n" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<li>" withString:@"\n\t• " options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"</li>" withString:@"\n" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<strong>" withString:@"" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"</strong>" withString:@"" options:0 range:NSMakeRange(0, [str length])];

}

- (void)parseDescription:(NSString *)desc
{    
    NSMutableString *str = [desc mutableCopy];
    [str replaceOccurrencesOfString:@"<h3>DESCRIPTION</h3>" withString:@"" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<h3>" withString:@"" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<a .*?=\".*?\">" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"</a>" withString:@"" options:0 range:NSMakeRange(0, [str length])];
    [self stripDecorations:str];

    [_module setModuleDescription:[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

- (void)parseDataTypes:(NSString *)dataTypes
{
    NSMutableString *str = [dataTypes mutableCopy];
    [self stripDecorations:str];
    NSArray *a = [self findDataTypesStrings:str];
    [self parseEachDataType:a];

}

- (NSArray *)findDataTypesStrings:(NSString *)str
{
    return [self findChunksWithPattern:@"<span class=\"bold_code\"><a name=\"type-[a-zA-z0-9_-]*\">" string:str];
}

- (void)parseEachDataType:(NSArray *)dataTypes
{
    NSMutableArray *types = [NSMutableArray array];

    NSRegularExpression *typeExp = [[NSRegularExpression alloc] initWithPattern:@"<a name=\"type-([a-zA-z0-9_-]*)\">([a-zA-z0-9\\(\\)_-]*)<\\/a>(.*)<\\/span>" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    for(NSString *dt in dataTypes) {
        NSArray *matches = [typeExp matchesInString:dt options:0 range:NSMakeRange(0, [dt length])];
        for(NSTextCheckingResult *tr in matches) {
            ERLDataType *t = [[ERLDataType alloc] init];
            if([tr numberOfRanges] >= 2) {
                [t setName:[dt substringWithRange:[tr rangeAtIndex:1]]];
            }
            if([tr numberOfRanges] >= 3) {
                [t setValue:[dt substringWithRange:[tr rangeAtIndex:2]]];
            }
            if([tr numberOfRanges] >= 4) {
                NSString *ss = [dt substringWithRange:[tr rangeAtIndex:3]];
                NSMutableString *str = [[ss stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
                
                [str replaceOccurrencesOfString:@"<a .*?=\".*?\">" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [str length])];
                [str replaceOccurrencesOfString:@"</a>" withString:@"" options:0 range:NSMakeRange(0, [str length])];
                [str replaceOccurrencesOfString:@"<span .*?=\".*?\">" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [str length])];
                [str replaceOccurrencesOfString:@"</span>" withString:@"" options:0 range:NSMakeRange(0, [str length])];
                

                [t setQualifier:str];
                
            }

            // Put the rest into the discussion.
            NSRange matchedRange = [tr range];
            NSRange discRange = NSMakeRange(matchedRange.location + matchedRange.length, 0);
            discRange.length = [dt length] - discRange.location;
            if(discRange.length > 0)
                [t setDiscussion:[dt substringWithRange:discRange]];
            [types addObject:t];
        }
    }
    [_module setModuleDataTypes:types];
}

- (NSArray *)findChunksWithPattern:(NSString *)pattern string:(NSString *)str
{
    NSMutableArray *a = [NSMutableArray array];
    NSRegularExpression *expr = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSArray *matches = [expr matchesInString:str options:0 range:NSMakeRange(0, [str length])];
    for(NSTextCheckingResult *res in matches) {
        NSRange r = [res range];
        [a addObject:[NSValue valueWithRange:r]];
    }
    
    if([a count] == 0)
        return [NSArray array];
    
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    for(int i = 0; i < [a count] - 1; i++) {
        NSRange thisRange = [a[i] rangeValue];
        NSRange captureRange = NSMakeRange(thisRange.location, 0);
        NSRange nextRange = [a[i+1] rangeValue];
        captureRange.length = nextRange.location - thisRange.location;
        [strings addObject:[str substringWithRange:captureRange]];
    }
    NSRange lastRange = [[a lastObject] rangeValue];
    lastRange.length = [str length] - lastRange.location;
    [strings addObject:[str substringWithRange:lastRange]];
    return strings;
}

- (void)parseExports:(NSString *)exports
{
    // Strip decorations later, they are useful in parsing here
    NSArray *a = [self findFunctionExports:exports];
    [_module setModuleExports:a];
}

- (NSArray *)argumentRangesForString:(NSString *)str
{
    NSMutableArray *ranges = [NSMutableArray array];
    int paranStack = 0;
    NSRange currentRange = NSMakeRange(0, 0);
    for(NSUInteger idx = 0; idx < [str length]; idx++) {
        NSString *substr = [str substringWithRange:NSMakeRange(idx, 1)];
        if([substr isEqualToString:@"("]) {
            paranStack ++;
            if(paranStack == 1) {
                currentRange.location = idx;
                currentRange.length = 0;
            }
        } else if([substr isEqualToString:@")"]) {
            paranStack--;
            if(paranStack == 0) {
                currentRange.length = idx - currentRange.location;
                [ranges addObject:[NSValue valueWithRange:currentRange]];
                
                // reset
                currentRange.location = currentRange.length = 0;
            }
        }
    }
    return ranges;
}

- (NSMutableString *)stripHeaderOfInternalMarkup:(NSString *)h
{
    NSMutableString *header = [h mutableCopy];
    NSArray *ranges = [self argumentRangesForString:header];
    
    for(int i = (int)[ranges count] - 1; i >= 0; i--) {
        NSRange range = [ranges[i] rangeValue];
        NSMutableString *substr = [[header substringWithRange:range] mutableCopy];
        [substr replaceOccurrencesOfString:@"<span class=\".*?\">" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [substr length])];
        [substr replaceOccurrencesOfString:@"<a href=\".*?\">" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [substr length])];
        [substr replaceOccurrencesOfString:@"</a>" withString:@"" options:0 range:NSMakeRange(0, [substr length])];
        [substr replaceOccurrencesOfString:@"</span>" withString:@"" options:0 range:NSMakeRange(0, [substr length])];
        [header replaceCharactersInRange:range withString:substr];
    }
  
    return header;
}

- (NSDictionary *)parseFunctionFromUsage:(NSString *)use
{
    NSString *stripped = use;
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    int paranStack = 0;
    
    NSRange paranRange = [stripped rangeOfString:@"("];
    if(paranRange.location != NSNotFound) {
        d[@"name"] = [stripped substringWithRange:NSMakeRange(0, paranRange.location)];
    } else {
        return nil;
    }
    
    NSMutableString *args = [NSMutableString string];
    NSRange returnValueRange = NSMakeRange(NSNotFound, 0);
    paranStack = 1;
    for(NSUInteger idx = paranRange.location + 1; idx < [stripped length]; idx++) {
        NSString *substr = [stripped substringWithRange:NSMakeRange(idx, 1)];
        if([substr isEqualToString:@"("]) {
            paranStack++;
            [args appendString:@"("];
        } else if([substr isEqualToString:@")"]) {
            paranStack--;
            if(paranStack > 0)
                [args appendString:@")"];
        } else
            [args appendString:substr];

        if(paranStack == 0) {
            returnValueRange = NSMakeRange(idx, [stripped length] - idx);
            break;
        }
    }
    d[@"args"] = args;
    
    if(returnValueRange.location != NSNotFound) {
        NSString *retVal = [stripped substringWithRange:returnValueRange];
        NSRange rhsRange = [retVal rangeOfString:@"-&gt;"];
        if(rhsRange.location != NSNotFound) {
            NSString *retValString = [retVal substringWithRange:NSMakeRange(rhsRange.location + rhsRange.length, [retVal length] - (rhsRange.location + rhsRange.length))];
            d[@"retVal"] = [retValString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    
    
    return d;
}

- (ERLFunction *)parseFunctionDictionary:(NSDictionary *)d
{
    NSMutableString *header = d[@"header"];
    header = [self stripHeaderOfInternalMarkup:header];
    NSArray *bodys = d[@"bodys"];
    
    ERLFunction *f = [[ERLFunction alloc] init];
    NSRegularExpression *nameArityUsageExpr = [[NSRegularExpression alloc] initWithPattern:@"<a name=\"([a-zA-z0-9_:]*)-([0-9]*)\">(?:<\\/a>)*?<span class=\"bold_code\">(.*?)<\\/span>"
                                                                                   options:NSRegularExpressionDotMatchesLineSeparators
                                                                                     error:nil];
    NSArray *matches = [nameArityUsageExpr matchesInString:header options:0 range:NSMakeRange(0, [header length])];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    NSMutableArray *arities = [[NSMutableArray alloc] init];
    NSMutableSet *args = [NSMutableSet set];
    NSMutableArray *usages = [NSMutableArray array];
    for(NSTextCheckingResult *tr in matches) {
        NSRange nameRange = [tr rangeAtIndex:1];
        [names addObject:[header substringWithRange:nameRange]];
        NSRange arityRange = [tr rangeAtIndex:2];
        [arities addObject:[NSNumber numberWithInt:[[header substringWithRange:arityRange] intValue]]];

        NSString *usage = [header substringWithRange:[tr rangeAtIndex:3]];
        NSDictionary *usageResult = [self parseFunctionFromUsage:usage];
        if(usageResult) {
            NSMutableString *usageString = [NSMutableString string];
            [usageString appendFormat:@"%@(", usageResult[@"name"]];
            if([usageResult[@"args"] length]) {
                NSArray *argsOriginal = [usageResult[@"args"] componentsSeparatedByString:@","];
                for(NSString *arg in argsOriginal) {
                    NSMutableString *mStr = [[NSMutableString alloc] initWithString:[arg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                    [mStr replaceOccurrencesOfString:@"&gt;" withString:@">" options:0 range:NSMakeRange(0, [mStr length])];
                    [mStr replaceOccurrencesOfString:@"&lt;" withString:@"<" options:0 range:NSMakeRange(0, [mStr length])];
                    [mStr replaceOccurrencesOfString:@"<br>" withString:@"\n" options:0 range:NSMakeRange(0, [mStr length])];
                    [args addObject:mStr];
                    [usageString appendFormat:@"%@, ", mStr];
                }
                [usageString replaceCharactersInRange:NSMakeRange([usageString length] - 2, 2) withString:@""];
                [usageString appendString:@")"];
            } else {
                [usageString appendString:@")"];
            }
            if([usageResult[@"retVal"] length]) {
                NSMutableString *mStr = [[NSMutableString alloc] initWithString:usageResult[@"retVal"]];
                [mStr replaceOccurrencesOfString:@"<span class=\".*?\">" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [mStr length])];
                [mStr replaceOccurrencesOfString:@"</span>" withString:@"" options:0 range:NSMakeRange(0, [mStr length])];
                [mStr replaceOccurrencesOfString:@"</a>" withString:@"" options:0 range:NSMakeRange(0, [mStr length])];
                [mStr replaceOccurrencesOfString:@"<a .*?=\".*?\">" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [mStr length])];
                [self stripDecorations:mStr];
                [f setReturnTypes:[[ERLArgumentType alloc] initWithString:[mStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
            } else {
                [f setReturnTypes:[[ERLArgumentType alloc] initWithString:nil]];
            }
            [usages addObject:usageString];
        }
    }

    [f setUsages:usages];
    [f setArgumentList:[args allObjects]];
    [f setArities:arities];
    [f setNames:names];

    NSRegularExpression *raTypesExp = [[NSRegularExpression alloc] initWithPattern:@"<div class=\"REFTYPES\">(.*?)<\\/div>" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    for(NSString *b in bodys) {
        if([b rangeOfString:@"<p>Types:</p>"].location != NSNotFound) {
            // This is the Types body
            NSArray *ratMatches = [raTypesExp matchesInString:b options:0 range:NSMakeRange(0, [b length])];
            NSMutableArray *allTypes = [NSMutableArray array];
            if([ratMatches count] > 0) {
                for(NSTextCheckingResult *rtr in ratMatches) {
                    NSMutableString *mStr = [[b substringWithRange:[rtr rangeAtIndex:1]] mutableCopy];
                    [mStr replaceOccurrencesOfString:@"<br>" withString:@"\n" options:0 range:NSMakeRange(0, [mStr length])];
                    [mStr replaceOccurrencesOfString:@"&gt;" withString:@">" options:0 range:NSMakeRange(0, [mStr length])];
                    [allTypes addObject:mStr];
                }
            }                    
            
            NSDictionary *typeMap = [self findTypeMapFromStrings:allTypes];
            [f setArgumentTypes:typeMap];

        } else {
            // This is the discussion body
            NSMutableString *bStrip = [b mutableCopy];
            [bStrip replaceOccurrencesOfString:@"<a .*?=\".*?\">" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [bStrip length])];
            [bStrip replaceOccurrencesOfString:@"</a>" withString:@"" options:0 range:NSMakeRange(0, [bStrip length])];
            [self stripDecorations:bStrip];
            
            [f setDiscussion:[bStrip stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
    
    return f;
}

- (NSArray *)findFunctionExports:(NSString *)str
{
    NSRegularExpression *expr = [[NSRegularExpression alloc] initWithPattern:@"<a name=\"[a-zA-z0-9_:-]*\">(?:<\\/a>)*?(?:<span class=\"bold_code\">)(.*?)<div class=\"REFBODY\">"
                                                                     options:NSRegularExpressionDotMatchesLineSeparators
                                                                       error:nil];
    NSArray *matches = [expr matchesInString:str options:0 range:NSMakeRange(0, [str length])];
    
    NSMutableArray *headerRanges = [NSMutableArray array];
    for(NSTextCheckingResult *res in matches) {
        NSRange r = [res range];
        r.length -= [@"<div class=\"REFBODY\">" length];
        [headerRanges addObject:[NSValue valueWithRange:r]];
    }

    NSMutableArray *funcSections = [NSMutableArray array]; // of dicts
    // Ok, let's find all ref bodies between the next function header and organize them (there is 1-3 I think)
    for(int i = 0; i < (int)[headerRanges count]; i++) {
        NSRange thisRange = [headerRanges[i] rangeValue];
        NSRange endRange;
        if(i == [headerRanges count] - 1) {
            endRange.location = [str length] - 1;
            endRange.length = 1;
        } else {
            endRange = [headerRanges[i + 1] rangeValue];
        }
        
        BOOL mayHaveMore = YES;
        NSRange checkRange = NSMakeRange(thisRange.location, endRange.location - thisRange.location);
        NSMutableArray *ranges = [NSMutableArray array];
        while(mayHaveMore) {
            NSRange bodyRange = [str rangeOfString:@"<div class=\"REFBODY\">" options:0 range:checkRange];
            if(bodyRange.location != NSNotFound) {
                [ranges addObject:[NSValue valueWithRange:bodyRange]];
                checkRange = NSMakeRange(bodyRange.location + bodyRange.length, endRange.location - (bodyRange.location + bodyRange.length));
            } else {
                mayHaveMore = NO;
            }
        }
        NSMutableArray *bodys = [NSMutableArray array];
        for(int j = 0; j < (int)[ranges count] - 1; j++) {
            NSRange thisBodyRange = [ranges[j] rangeValue];
            NSRange nextBodyRange = [ranges[j + 1] rangeValue];
            
            NSRange useRange;
            useRange.location = thisBodyRange.location + thisBodyRange.length;
            useRange.length = nextBodyRange.location - useRange.location;
            [bodys addObject:[str substringWithRange:useRange]];
        }
        NSRange lastBodyRange = [[ranges lastObject] rangeValue];
        lastBodyRange.location += lastBodyRange.length;
        lastBodyRange.length = endRange.location - lastBodyRange.location;
        [bodys addObject:[str substringWithRange:lastBodyRange]];
        
        NSDictionary *sectionDict = @{@"header": [str substringWithRange:[headerRanges[i] rangeValue]], @"bodys": bodys};
        [funcSections addObject:sectionDict];
    }
    
    NSMutableArray *funcs = [NSMutableArray array];
    for(NSDictionary *d in funcSections) {
        [funcs addObject:[self parseFunctionDictionary:d]];
    }
    
    return funcs;
}

- (NSDictionary *)findTypeMapFromStrings:(NSArray *)strings
{
    NSRegularExpression *linkStripperExp = [[NSRegularExpression alloc] initWithPattern:@"<a href=\".*?\">" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    for(NSString *s in strings) {
        
        NSMutableString *u = [s mutableCopy];
        if([u rangeOfString:@"<a href"].location != NSNotFound) {
            // Strip any links from this.
            NSArray *matches = [linkStripperExp matchesInString:u options:0 range:NSMakeRange(0, [u length])];
            for(int i = (int)[matches count] - 1; i >= 0; i--) {
                NSTextCheckingResult *tr = matches[i];
                NSRange fullRange = [tr range];
                [u replaceCharactersInRange:fullRange withString:@""];
            }
        }
        [u replaceOccurrencesOfString:@"<span class=\"bold_code\">" withString:@"" options:0 range:NSMakeRange(0, [u length])];
        [u replaceOccurrencesOfString:@"</span>" withString:@"" options:0 range:NSMakeRange(0, [u length])];
        [u replaceOccurrencesOfString:@"</a>" withString:@"" options:0 range:NSMakeRange(0, [u length])];
         
        NSArray *comps = [u componentsSeparatedByString:@"="];
        NSString *rhs = [[comps lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        ERLArgumentType *arg = [[ERLArgumentType alloc] initWithString:rhs];
        for(int i = 0; i < [comps count] - 1; i++) {
            [d setObject:arg forKey:[comps[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
    
    return d;
}


@end