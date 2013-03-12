//
//  ERL.h
//  Erldoc
//
//  Created by Joe Conway on 3/6/13.
//  Copyright (c) 2013 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSXMLElement *ERLOnly(NSXMLElement *e, NSString *key);

#define ATTR(x) [[NSAttributedString alloc] initWithString:x]
#define M_ATTR(x) [[NSMutableAttributedString alloc] initWithString:x];

#define str(x) #x
#define token(x) @str(x)

#define encode(x) [aCoder encodeObject:x forKey:token(x)]
#define decode(x) x = [aDecoder decodeObjectForKey:token(x)]