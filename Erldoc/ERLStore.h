//
//  ERLStore.h
//  Erldoc
//
//  Created by Joe Conway on 3/8/13.
//  Copyright (c) 2013 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ERLSourcePathChangedNotification;

@interface ERLStore : NSObject

+ (ERLStore *)store;

- (void)fetchModulesWithCompletion:(void (^)(NSArray *module, NSError *err))block;

@property (nonatomic, strong) NSString *sourcePath;

@end
