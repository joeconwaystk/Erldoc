//
//  ERL.m
//  Erldoc
//
//  Created by Joe Conway on 3/6/13.
//  Copyright (c) 2013 Big Nerd Ranch. All rights reserved.
//

#import "ERLHelpers.h"

NSXMLElement *ERLOnly(NSXMLElement *e, NSString *s)
{
    NSArray *a = [e elementsForName:s];
    if([a count] == 1)
        return a[0];
    
    return nil;
}
