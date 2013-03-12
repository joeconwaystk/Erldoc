//
//  ERLStore.m
//  Erldoc
//
//  Created by Joe Conway on 3/8/13.
//  Copyright (c) 2013 Big Nerd Ranch. All rights reserved.
//

#import "ERLStore.h"
#import "ERLModuleParser.h"
#import "ERLModule.h"

NSString * const ERLSourcePathChangedNotification = @"ERLSourcePathChangedNotification";

@interface ERLStore ()
{
    NSMutableArray *_loadedModules;
    NSMutableArray *_requiredModules;
    NSString *_documentationPath;
}
@end

@implementation ERLStore
@dynamic sourcePath;

+ (ERLStore *)store
{
    static ERLStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[ERLStore alloc] init];
    });
    
    return store;
}

- (id)init
{
    self = [super init];
    if(self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        if([paths count] == 1) {
            _documentationPath = [paths[0] stringByAppendingPathComponent:@"Erldoc"];
            [[NSFileManager defaultManager] createDirectoryAtPath:_documentationPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        _requiredModules = [@[@"$ERLSRC/stdlib"] mutableCopy];
        _loadedModules = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)allFilesForPath:(NSString *)path
{
    path = [path stringByReplacingOccurrencesOfString:@"$ERLSRC" withString:[self sourcePath]];
    
    NSString *rootSrcPath = [path stringByAppendingPathComponent:@"src"];
    NSString *rootDocPath = [[path stringByAppendingPathComponent:@"doc"] stringByAppendingPathComponent:@"src"];

    NSDirectoryEnumerator *de = [[NSFileManager defaultManager] enumeratorAtPath:rootSrcPath];
    [de skipDescendants];
    
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for(NSString *p in de) {
        if([[p pathExtension] isEqualToString:@"erl"]) {
            NSString *srcPath = [rootSrcPath stringByAppendingPathComponent:p];
            NSString *docPath = [rootDocPath stringByAppendingPathComponent:[[p stringByDeletingPathExtension] stringByAppendingPathExtension:@"xml"]];
            NSString *edocPath = [[_documentationPath stringByAppendingPathComponent:[p stringByDeletingPathExtension]] stringByAppendingPathExtension:@"edoc"];
            NSString *srcOutPath = [[_documentationPath stringByAppendingPathComponent:[p stringByDeletingPathExtension]] stringByAppendingPathExtension:@"xml"];
            
            NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
            if([[NSFileManager defaultManager] fileExistsAtPath:edocPath]) {
                [d setObject:edocPath forKey:@"edoc"];
            } else {
                [d setObject:srcPath forKey:@"src"];
                [d setObject:srcOutPath forKey:@"srcOut"];
                if([[NSFileManager defaultManager] fileExistsAtPath:docPath])
                    [d setObject:docPath forKey:@"doc"];
            }
            [a addObject:d];
        }
    }
    return a;
}

- (void)prepareModules
{
    NSMutableArray *generated = [[NSMutableArray alloc] init];
    NSMutableString *argFile = [[NSMutableString alloc] init];
    [argFile appendFormat:@"{\"%@\", [", _documentationPath];
    for(NSString *path in _requiredModules) {
        NSArray *paths = [self allFilesForPath:path];

        BOOL addedToList = NO;
        for(NSDictionary *docDict in paths) {
            NSString *srcPath = [docDict objectForKey:@"src"];
            if(srcPath) {
                [generated addObject:docDict];
                addedToList = YES;
                
                [argFile appendFormat:@"\"%@\"", srcPath];
                if(docDict != [paths lastObject])
                    [argFile appendFormat:@","];
                }
        }
        if(addedToList && path != [_requiredModules lastObject])
            [argFile appendFormat:@","];
    }
    [argFile appendFormat:@"]}."];
    
    
    if([generated count] > 0) {
        
        NSString *argFilePath = [_documentationPath stringByAppendingPathComponent:@"argfiles"];
        [argFile writeToFile:argFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        NSString *erlSource = [[NSBundle mainBundle] pathForResource:@"erldoc" ofType:@"erl"];
        NSTask *compile = [[NSTask alloc] init];
        [compile setLaunchPath:@"/usr/local/bin/erlc"];
        [compile setArguments:@[erlSource, @"-o", _documentationPath]];
        [compile launch];
        [compile waitUntilExit];
    
        NSTask *run = [[NSTask alloc] init];
        [run setLaunchPath:@"/usr/local/bin/erl"];
        [run setArguments:@[@"-pa", _documentationPath, @"-noinput", @"-s", @"erldoc", @"start", argFilePath, @"-s", @"init", @"stop"]];
        [run launch];
        [run waitUntilExit];
        
        for(NSDictionary *docDict in generated) {
            NSString *genPath = docDict[@"srcOut"];
            NSString *xRefPath = docDict[@"doc"];
            
            ERLModuleParser *p = [[ERLModuleParser alloc] initWithPath:genPath xrefPath:xRefPath];
            if([p module]) {
                NSString *outputPath = [[_documentationPath stringByAppendingPathComponent:[[p module] name]] stringByAppendingPathExtension:@"edoc"];

                [NSKeyedArchiver archiveRootObject:[p module] toFile:outputPath];
            }            
            [[NSFileManager defaultManager] removeItemAtPath:genPath error:nil];
        }
        [[NSFileManager defaultManager] removeItemAtPath:argFilePath error:nil];
    }
}

- (void)setSourcePath:(NSString *)sourcePath
{
    if(sourcePath) {
        [[NSUserDefaults standardUserDefaults] setObject:sourcePath forKey:@"sourcePath"];
        NSNotification *note = [NSNotification notificationWithName:ERLSourcePathChangedNotification object:self];
        [[NSNotificationCenter defaultCenter] postNotification:note];
    }
}

- (NSString *)sourcePath
{
    NSString *val = [[NSUserDefaults standardUserDefaults] objectForKey:@"sourcePath"];
    return val;
}

- (void)fetchModulesWithCompletion:(void (^)(NSArray *module, NSError *err))block
{
    if(![self sourcePath]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self prepareModules];
        NSDirectoryEnumerator *de = [[NSFileManager defaultManager] enumeratorAtPath:_documentationPath];
        for(NSString *path in de) {
            if([[path pathExtension] isEqualToString:@"edoc"]) {
                [_loadedModules addObject:[NSKeyedUnarchiver unarchiveObjectWithFile:[_documentationPath stringByAppendingPathComponent:path]]];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(_loadedModules, nil);
        }];
    });
}

@end
