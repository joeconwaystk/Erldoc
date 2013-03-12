//
//  ERLModule.m
//  Erldoc
//
//  Created by Joe Conway on 10/17/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLModule.h"
#import "ERLModuleParser.h"
#import "ERLFunction.h"
#import "ERLDataType.h"
#import "ERLDescriptionParser.h"
#import "ERLHelpers.h"

@interface ERLModule ()
@end

@implementation ERLModule

- (id)init
{
    self = [super init];
    if(self) {
        _types = [[NSMutableArray alloc] init];
        _functions = [[NSMutableArray alloc] init];
        _callbacks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    encode(_name);
    encode(_summary);
    encode(_discussion);
    encode(_types);
    encode(_functions);
    encode(_callbacks);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self) {
        decode(_name);
        decode(_summary);
        decode(_discussion);
        decode(_types);
        decode(_functions);
        decode(_callbacks);
    }
    return self;
}

- (ERLModule *)module
{
    return self;
}

- (NSString *)displayName
{
    return [self name];
}

- (NSImage *)displayImage
{
    return [NSImage imageNamed:@"Module"];
}

- (BOOL)containsString:(NSString *)str
{
    if([[self name] rangeOfString:str].location == 0)
        return YES;


    return NO;
}

- (ERLFunction *)functionWithName:(NSString *)fName arity:(int)arity
{

    return nil;
}

@end