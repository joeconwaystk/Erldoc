//
//  ERLDataType.m
//  Erldoc
//
//  Created by Joe Conway on 10/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLDataType.h"
#import "ERLHelpers.h"

@implementation ERLDataType
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    encode(_label);
    encode(_name);
    encode(_shortDescription);
    encode(_longDescription);
    encode(_definition);
    encode(_module);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self) {
        decode(_label);
        decode(_name);
        decode(_shortDescription);
        decode(_longDescription);
        decode(_definition);
        decode(_module);
    }
    return self;
}

- (NSString *)displayName
{
    return [self name];
}

- (NSImage *)displayImage
{
    return [NSImage imageNamed:@"Type"];
}

- (NSString *)searchTag
{
    return [self label];
}


@end
