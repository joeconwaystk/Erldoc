//
//  ERLModuleParser.m
//  Erldoc
//
//  Created by Joe Conway on 11/2/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLModuleParser.h"
#import "ERLModule.h"
#import "ERLFunction.h"
#import "ERLDataType.h"
#import "ERLDescriptionParser.h"
#import "ERLTypeParser.h"
#import "ERLHelpers.h"
#import "ERLMarkupParser.h"

@interface ERLModuleParser ()
- (void)parseBehaviors:(NSArray *)elements;
- (void)parseDescription:(NSArray *)elements;
- (void)parseAuthors:(NSArray *)elements;
- (void)parseTypes:(NSArray *)elements;
- (void)parseFunctions:(NSArray *)functions asCallbacks:(BOOL)flag;

- (void)parseCrossReference:(NSXMLDocument *)doc;
@end

@implementation ERLModuleParser

- (id)initWithPath:(NSString *)path xrefPath:(NSString *)xrefPath
{
    self = [super init];
    if(self) {
        ERLModule *m = [[ERLModule alloc] init];
        _module = m;
        
        [_module setName:[[path lastPathComponent] stringByDeletingPathExtension]];
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        
        if(data) {
            NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:0 error:nil];
            NSXMLElement *root = [doc rootElement];
        
            [self parseDescription:[root elementsForName:@"description"]];
            [self parseBehaviors:[root elementsForName:@"behaviour"]];
            [self parseAuthors:[root elementsForName:@"author"]];
            [self parseTypes:[root elementsForName:@"typedecls"]];
            [self parseFunctions:[root elementsForName:@"functions"] asCallbacks:NO];
            [self parseFunctions:[root elementsForName:@"callbacks"] asCallbacks:YES];
            
            // Need to cross reference?
            NSData *refData = [[NSData alloc] initWithContentsOfFile:xrefPath];
            if(refData) {
                NSXMLDocument *xrefDoc = [[NSXMLDocument alloc] initWithData:refData options:0 error:nil];
                [self parseCrossReference:xrefDoc];
            }
        }
    }
    return self;
}

- (void)parseBehaviors:(NSArray *)elements
{
    
}
- (void)parseDescription:(NSArray *)elements
{
    ERLDescriptionParser *p = [[ERLDescriptionParser alloc] initWithElements:elements];
    [[self module] setSummary:[p summary]];
    [[self module] setDiscussion:[p discussion]];
}

- (void)parseAuthors:(NSArray *)elements
{
    
}

- (void)parseTypes:(NSArray *)elements
{
    for(NSXMLElement *decls in elements) {
        NSArray *decs = [decls elementsForName:@"typedecl"];
        for(NSXMLElement *e in decs) {
            ERLDataType *t = [[ERLDataType alloc] init];
            [t setLabel:[[e attributeForName:@"label"] stringValue]];

            ERLDescriptionParser *p = [[ERLDescriptionParser alloc] initWithElements:[e elementsForName:@"description"]];
            [t setShortDescription:[p summary]];
            [t setLongDescription:[p discussion]];

            NSXMLElement *td = ERLOnly(e, @"typedef");
            NSXMLElement *erlangName = ERLOnly(td, @"erlangName");
            [t setName:[[erlangName attributeForName:@"name"] stringValue]];
            
            
            //NSXMLElement *argTypes = ERLOnly(td, @"argtypes");
            
            NSXMLElement *type = ERLOnly(td, @"type");
            if(type) {
                ERLTypeParser *tp = [[ERLTypeParser alloc] initWithXMLElement:type];
                [t setDefinition:[tp attributedString]];
            }
            [t setModule:_module];
            
            [[_module types] addObject:t];
        }
    }
    [[_module types] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];

}

- (void)parseFunctions:(NSArray *)functions asCallbacks:(BOOL)flag
{
    for(NSXMLElement *container in functions) {
        for(NSXMLElement *func in [container children]) {
            ERLFunction *f = [[ERLFunction alloc] init];
            [f setName:[[func attributeForName:@"name"] stringValue]];
            [f setArity:[[[func attributeForName:@"arity"] stringValue] intValue]];
            if(flag)
                [f setExported:YES];
            else
                [f setExported:[[[func attributeForName:@"exported"] stringValue] isEqual:@"yes"]];
            [f setLabel:[[func attributeForName:@"label"] stringValue]];
            if(![f label]) {
                [f setLabel:[NSString stringWithFormat:@"%@-%d", [f name], [f arity]]];
            }
            NSXMLElement *spec = ERLOnly(func, @"typespec");
            if(spec) {
                NSString *callName = [[ERLOnly(spec, @"erlangName") attributeForName:@"name"] stringValue];
                [f setCallName:callName];
                
                NSXMLElement *funcType = ERLOnly(spec, @"type");
                ERLTypeParser *funcTp = [[ERLTypeParser alloc] initWithXMLElement:funcType];
                [f setCallSemantics:[funcTp attributedString]];
                
                NSArray *localDefs = [spec elementsForName:@"localdef"];
                NSMutableArray *defs = [[NSMutableArray alloc] init];
                for(NSXMLElement *ld in localDefs) {
                    NSXMLElement *tv = ERLOnly(ld, @"typevar");
                    NSXMLElement *type = ERLOnly(ld, @"type");
                    
                    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[[tv attributeForName:@"name"] stringValue]]];
                    [str appendAttributedString:[[NSAttributedString alloc] initWithString:@" = "]];

                    ERLTypeParser *tp = [[ERLTypeParser alloc] initWithXMLElement:type];
                    [str appendAttributedString:[tp attributedString]];
                    [defs addObject:str];
                }
                if([defs count] > 0)
                    [f setArgumentDefinitions:defs];
            }
            ERLDescriptionParser *descParse = [[ERLDescriptionParser alloc] initWithElements:[func elementsForName:@"description"]];
            [f setSummary:[descParse summary]];
            [f setDiscussion:[descParse discussion]];

            [f setModule:_module];
            
            if(flag) {
                [f setCallback:YES];
                [[_module callbacks] addObject:f];
            } else {
                [[_module functions] addObject:f];
            }
        }
    }
    if(flag)
        [[_module callbacks] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    else
        [[_module functions] sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
}

- (void)parseCallbacks:(NSArray *)callbacks
{
    
}

- (void)parseCrossReference:(NSXMLDocument *)doc
{
    if(!doc)
        return;
    
    ERLMarkupParser *mp = [[ERLMarkupParser alloc] init];
    NSXMLElement *root = [doc rootElement];
    if(![_module summary]) {
        [_module setSummary:[[NSAttributedString alloc] initWithString:[ERLOnly(root, @"modulesummary") stringValue]]];
    }
    if(![_module discussion]) {
        [_module setSummary:[mp transformString:[ERLOnly(root, @"description") description]]];
    }
    
    NSRegularExpression *arityParser = [[NSRegularExpression alloc] initWithPattern:@"([a-zA-z_0-9]*)\\((.*)\\)" options:0 error:nil];
    NSRegularExpression *callbackArityParser = [[NSRegularExpression alloc] initWithPattern:@"(?:[a-zA-z_0-9]*:)([a-zA-z_0-9]*)\\((.*)\\)" options:0 error:nil];
    
    NSArray *funcsRoots = [root elementsForName:@"funcs"];
    NSMutableDictionary *funcTable = [NSMutableDictionary dictionary];
    NSMutableDictionary *funcDerivedTable = [NSMutableDictionary dictionary];
    
    for(NSXMLElement *funcsRoot in funcsRoots) {
        NSArray *funcs = [funcsRoot elementsForName:@"func"];
        for(NSXMLElement *fElement in funcs) {            
            NSXMLElement *n = ERLOnly(fElement, @"name");

            // If there are attributes, this is the new style
            if([n attributes]) {
                NSString *name = [[n attributeForName:@"name"] stringValue];
                NSString *arity = [[n attributeForName:@"arity"] stringValue];
                [funcTable setObject:fElement forKey:[NSString stringWithFormat:@"%@-%@", name, arity]];
            } else {
                // If there are not, this is the oldstyle
                NSArray *allFuncNames = [fElement elementsForName:@"name"];
                for(NSXMLElement *e in allFuncNames) {
                    NSString *semantics = [e stringValue];
                    
                    NSTextCheckingResult *tr = [arityParser firstMatchInString:semantics options:0 range:NSMakeRange(0, [semantics length])];
                    if(!tr)
                        tr = [callbackArityParser firstMatchInString:semantics options:0 range:NSMakeRange(0, [semantics length])];
                    if(tr) {
                        if([tr numberOfRanges] >= 2) {                            
                            NSMutableDictionary *derivedValue = [[NSMutableDictionary alloc] init];
                            
                            int arity = 0;
                            NSRange nameRange = [tr rangeAtIndex:1];
                            if([tr numberOfRanges] == 3) {
                                NSRange argsRange = [tr rangeAtIndex:2];
                                NSString *args = [semantics substringWithRange:argsRange];
                                derivedValue[@"callSemantics"] = [semantics substringFromIndex:nameRange.location + nameRange.length];
                                arity = (int)[[args componentsSeparatedByString:@","] count];
                            }
                            
                            NSString *name = [semantics substringWithRange:nameRange];
                            derivedValue[@"callName"] = name;
                            
                            NSString *key = [NSString stringWithFormat:@"%@-%d", name, arity];
                            [funcDerivedTable setObject:derivedValue forKey:key];
                            [funcTable setObject:fElement forKey:key];
                        } else {
                            NSLog(@"couldn't parse %@", semantics);
                        }
                    
                    }
                }
            }
        }
    }
    
    void (^replaceFunction)(ERLFunction *) = ^(ERLFunction *f) {
        NSString *key = [NSString stringWithFormat:@"%@-%d", [f name], [f arity]];
        NSXMLElement *thisFunc = [funcTable objectForKey:key];
        
        if(thisFunc) {
            
            if(![f callName]) {
                [f setCallName:[[funcDerivedTable objectForKey:key] objectForKey:@"callName"]];
            }
            
            if(![f callSemantics]) {
                [f setCallSemantics:ATTR([[funcDerivedTable objectForKey:key] objectForKey:@"callSemantics"])];
            }
            
            if(![f argumentDefinitions]) {
                NSMutableArray *defs = [[NSMutableArray alloc] init];
                for(NSXMLElement *types in [thisFunc elementsForName:@"type"]) {
                    for(NSXMLElement *v in [types elementsForName:@"v"]) {
                        [defs addObject:ATTR([v stringValue])];
                    }
                }
                [f setArgumentDefinitions:defs];
            }
            
            if(![f summary]) {
                [f setSummary:[[NSAttributedString alloc] initWithString:[ERLOnly(thisFunc, @"fsummary") stringValue]]];
            }
            if(![f discussion]) {
                NSString *e = [ERLOnly(thisFunc, @"desc") description];
                [f setDiscussion:[mp transformString:e]];
            }
        }
    };
    
    for(ERLFunction *f in [_module functions]) {
        replaceFunction(f);
    }
    for(ERLFunction *f in [_module callbacks]) {
        replaceFunction(f);
    }
}


@end
