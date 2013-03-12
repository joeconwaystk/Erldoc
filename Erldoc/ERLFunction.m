//
//  ERLFunction.m
//  Erldoc
//
//  Created by Joe Conway on 10/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLFunction.h"
#import "ERLHelpers.h"
@implementation ERLFunction
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    encode(_label);
    encode(_name);
    encode(_callName);
    encode(_callSemantics);
    encode(_argumentDefinitions);
    encode(_discussion);
    encode(_summary);
    encode(_module);
    [aCoder encodeInt32:_arity forKey:@"_arity"];
    [aCoder encodeBool:_exported forKey:@"_exported"];
    [aCoder encodeBool:_callback forKey:@"_callback"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self) {
        decode(_label);
        decode(_name);
        decode(_callName);
        decode(_callSemantics);
        decode(_argumentDefinitions);
        decode(_discussion);
        decode(_summary);
        decode(_module);
        _arity = [aDecoder decodeInt32ForKey:@"_arity"];
        _exported = [aDecoder decodeBoolForKey:@"_exported"];
        _callback = [aDecoder decodeBoolForKey:@"_callback"];

    }
    return self;
}

- (NSString *)searchTag
{
    return [self label];
}

- (NSString *)displayName
{
    return [NSString stringWithFormat:@"%@/%d", [self name], [self arity]];
}

- (NSImage *)displayImage
{
    if([self isCallback])
        return [NSImage imageNamed:@"Callback"];
    return [NSImage imageNamed:@"Function"];
}

@end
