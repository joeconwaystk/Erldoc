//
//  ERLExportParser.h
//  Erldoc
//
//  Created by Joe Conway on 10/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ERLExportParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) id <NSXMLParserDelegate> parentParser;
@property (nonatomic, strong) NSMutableAttributedString *attributedText;

- (id)initWithName:(NSString *)name;


@end
