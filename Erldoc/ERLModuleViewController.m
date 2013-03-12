//
//  ERLModuleViewController.m
//  Erldoc
//
//  Created by Joe Conway on 10/17/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ERLModuleViewController.h"
#import "ERLModule.h"
#import "ERLDataType.h"
#import "ERLFunction.h"
#import "ERLModuleParser.h"
#import "ERLHelpers.h"

@interface ERLModuleViewController () <NSTableViewDataSource, NSTableViewDelegate>
{
    NSRange _typeRange;
    NSRange _funcRange;
    NSRange _callRange;
}
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;

- (void)configureItemsFromCurrentModule;
@end

@implementation ERLModuleViewController

- (id)init
{
    self = [super initWithNibName:@"ERLModuleViewController" bundle:[NSBundle mainBundle]];
    if (self) {
 
    }
    
    return self;

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (void)setModule:(ERLModule *)module
{
    _module = module;
    [self configureItemsFromCurrentModule];
}

- (void)scrollToTag:(NSString *)tag
{
    if(tag)
        [self textView:[self textView] clickedOnLink:tag atIndex:0];
    else
        [[self textView] scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex
{
    link = [link stringByReplacingOccurrencesOfString:@"#" withString:@""];
    [[[self textView] textStorage] enumerateAttribute:NSToolTipAttributeName
                                              inRange:NSMakeRange(0, [[[self textView] textStorage] length])
                                              options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
                                                  if([value isEqual:link]) {
                                                      [[self textView] scrollRangeToVisible:range];
                                                      *stop = YES;
                                                  }
                                              }];
    return YES;
}

- (void)configureItemsFromCurrentModule
{
    [[[self textView] textStorage] deleteCharactersInRange:NSMakeRange(0, [[[self textView] textStorage] length])];
    _typeRange = _funcRange = _callRange = NSMakeRange(0, 0);

    if(!_module){
        return;
    }

    NSMutableParagraphStyle *indentStyle = [[NSMutableParagraphStyle alloc] init];
    [indentStyle setFirstLineHeadIndent:10];
    NSMutableParagraphStyle *doubleIndentStyle = [[NSMutableParagraphStyle alloc] init];
    [doubleIndentStyle setFirstLineHeadIndent:20];

        
    NSMutableDictionary *defaultAttrs = [[[self textView] linkTextAttributes] mutableCopy];
    defaultAttrs[NSForegroundColorAttributeName] = [NSColor colorWithDeviceRed:0.4 green:0.55 blue:.8 alpha:1];
    [[self textView] setLinkTextAttributes:defaultAttrs];
     
    NSMutableParagraphStyle *centeredStyle = [[NSMutableParagraphStyle alloc] init];
    [centeredStyle setAlignment:NSCenterTextAlignment];
        
    [[[self textView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ reference\n\n", [_module name]]
                                                                attributes:@{NSFontAttributeName : [NSFont fontWithName:@"LucidaGrande-Bold" size:32],
                                                                             NSParagraphStyleAttributeName : centeredStyle,
                                                                             NSForegroundColorAttributeName : [NSColor blackColor]}]];

    if([_module summary] || [_module discussion]) {
        [[[self textView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"Overview\n\n"
                                                                                              attributes:@{NSFontAttributeName : [NSFont fontWithName:@"LucidaGrande-Bold" size:24],
                                                                         NSForegroundColorAttributeName : [NSColor colorWithDeviceRed:0.4 green:0.44 blue:0.52 alpha:1]}]];
        if([_module summary]) {
            [[[self textView] textStorage] appendAttributedString:[_module summary]];
            
            [[[self textView] textStorage] appendAttributedString:ATTR(@"\n\n")];
        }
        if([_module discussion]) {
            [[[self textView] textStorage] appendAttributedString:[_module discussion]];
            [[[self textView] textStorage] appendAttributedString:ATTR(@"\n\n")];
        }
    }
    
    if([[_module types] count] > 0) {
        _typeRange = NSMakeRange(0, [[_module types] count] + 1);
        
        [[[self textView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"Types\n\n"
                                                                                              attributes:@{NSFontAttributeName : [NSFont fontWithName:@"LucidaGrande-Bold" size:24],
                                                                         NSForegroundColorAttributeName : [NSColor colorWithDeviceRed:0.4 green:0.44 blue:0.52 alpha:1]}]];
        
        
        
        for(ERLDataType *dt in [_module types]) {
            [[[self textView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@()\n", [dt name]]
                                                                                                  attributes:@{NSFontAttributeName : [NSFont fontWithName:@"Menlo" size:18],
                                                                             NSForegroundColorAttributeName : [NSColor colorWithDeviceRed:0.2 green:0.52 blue:0.2 alpha:1],
                                                                                     NSToolTipAttributeName : ([dt label] ? [dt label] : @"")}]];
            if([dt definition]) {
                [[[self textView] textStorage] appendAttributedString:ATTR(@"\n")];
                
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:[dt definition]];
                
                [str addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Menlo" size:14] range:NSMakeRange(0, [str length])];
                [str addAttribute:NSParagraphStyleAttributeName value:indentStyle range:NSMakeRange(0, [str length])];
                [[[self textView] textStorage] appendAttributedString:str];
            }
            
            if([dt longDescription]) {
                [[[self textView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nDiscussion\n"
                                                                                                      attributes:@{NSFontAttributeName : [NSFont fontWithName:@"LucidaGrande-Bold" size:14]}]];
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:[dt longDescription]];
                [str addAttribute:NSParagraphStyleAttributeName value:indentStyle range:NSMakeRange(0, [str length])];
                [[[self textView] textStorage] appendAttributedString:str];
            }
            else if([dt shortDescription]) {
                [[[self textView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nDiscussion\n"
                                                                                                      attributes:@{NSFontAttributeName : [NSFont fontWithName:@"LucidaGrande-Bold" size:14]}]];
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:[dt shortDescription]];
                [str addAttribute:NSParagraphStyleAttributeName value:indentStyle range:NSMakeRange(0, [str length])];
                [[[self textView] textStorage] appendAttributedString:str];
            }
            [[[self textView] textStorage] appendAttributedString:ATTR(@"\n\n\n")];
        }
    }
    
    
    
    void (^addFunction)(ERLFunction *) = ^(ERLFunction *f) {
        if([f isExported]) {
            [[[self textView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@/%d\n\n", [f name], [f arity]]
                                                                                                  attributes:@{NSFontAttributeName : [NSFont fontWithName:@"Menlo" size:18],
                                                                             NSForegroundColorAttributeName : [NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.52 alpha:1],
                                                                                     NSToolTipAttributeName : ([f label] ? [f label] : @"")}]];
            
            if([f callName] && [f callSemantics]) {
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[f callName]];
                [str addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Menlo-Bold" size:14] range:NSMakeRange(0, [str length])];
                [str addAttribute:NSParagraphStyleAttributeName value:indentStyle range:NSMakeRange(0, [str length])];
                
                [[[self textView] textStorage] appendAttributedString:str];
                
                str = [[NSMutableAttributedString alloc] initWithAttributedString:[f callSemantics]];
                [str addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Menlo-Bold" size:14] range:NSMakeRange(0, [str length])];
                [str addAttribute:NSParagraphStyleAttributeName value:indentStyle range:NSMakeRange(0, [str length])];
                
                [[[self textView] textStorage] appendAttributedString:str];
                [[[self textView] textStorage] appendAttributedString:ATTR(@"\n")];
            }
            
            if([[f argumentDefinitions] count] > 0) {
                [[[self textView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nArguments\n"
                                                                                                      attributes:@{NSFontAttributeName : [NSFont fontWithName:@"LucidaGrande-Bold" size:14],
                                                                                  NSParagraphStyleAttributeName : indentStyle}]];
            }
            
            for(NSAttributedString *ad in [f argumentDefinitions]) {
                [[[self textView] textStorage] appendAttributedString:ATTR(@"\n")];
                [[[self textView] textStorage] appendAttributedString:ad];
                NSRange r = NSMakeRange([[[self textView] textStorage] length] - [ad length], [ad length]);
                [[[self textView] textStorage] addAttribute:NSParagraphStyleAttributeName value:doubleIndentStyle range:r];
                [[[self textView] textStorage] addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Menlo" size:13] range:r];
                
                [[[self textView] textStorage] appendAttributedString:ATTR(@"\n")];
            }
            
            if([[f discussion] length] > 0 || [[f summary] length] > 0) {
                [[[self textView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nDiscussion\n"
                                                                                                      attributes:@{NSFontAttributeName : [NSFont fontWithName:@"LucidaGrande-Bold" size:14],
                                                                                  NSParagraphStyleAttributeName : indentStyle}]];
                if([[f discussion] length] > 0) {
                    [[[self textView] textStorage] appendAttributedString:[f discussion]];
                } else if([[f summary] length] > 0) {
                    [[[self textView] textStorage] appendAttributedString:[f summary]];
                }
                
            }
            
            [[[self textView] textStorage] appendAttributedString:ATTR(@"\n\n\n")];
        }
    };

    if([[_module functions] count] > 0) {
        _funcRange = NSMakeRange(_typeRange.location + _typeRange.length, [[_module functions] count] + 1);
        [[[self textView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"Functions\n\n"
                                                                                              attributes:@{NSFontAttributeName : [NSFont fontWithName:@"LucidaGrande-Bold" size:24],
                                                                         NSForegroundColorAttributeName : [NSColor colorWithDeviceRed:0.4 green:0.44 blue:0.52 alpha:1]}]];
        
        for(ERLFunction *f in [_module functions]) {
            addFunction(f);
        }
    }
    
    if([[_module callbacks] count] > 0) {
        _callRange = NSMakeRange(_funcRange.location + _funcRange.length, [[_module callbacks] count] + 1);
        [[[self textView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"Callbacks\n\n"
                                                                                              attributes:@{NSFontAttributeName : [NSFont fontWithName:@"LucidaGrande-Bold" size:24],
                                                                         NSForegroundColorAttributeName : [NSColor colorWithDeviceRed:0.4 green:0.44 blue:0.52 alpha:1]}]];
        
        for(ERLFunction *f in [_module callbacks]) {
            addFunction(f);
        }
    }
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowOffset:CGSizeMake(0, -1)];
    [shadow setShadowColor:[NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:0.85]];

    [[[self textView] textStorage] addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, [[[self textView] textStorage] length])];

    [[[[[self tableView] tableColumns] objectAtIndex:0] headerCell] setStringValue:[_module name]];
         
    [[self tableView] reloadData];
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
    [cell setDrawsBackground:YES];
    BOOL isHeader = NO;
    if(NSLocationInRange(rowIndex, _typeRange)) {
        int adjustedIndex = (int)rowIndex;
        if(adjustedIndex == 0)
            isHeader = YES;
    } else if(NSLocationInRange(rowIndex, _funcRange)) {
        int adjustedIndex = (int)rowIndex - (int)_funcRange.location;
        if(adjustedIndex == 0)
            isHeader = YES;
    } else if(NSLocationInRange(rowIndex, _callRange)) {
        int adjustedIndex = (int)rowIndex - (int)_callRange.location;
        if(adjustedIndex == 0)
            isHeader = YES;
    }
    
    if(isHeader) {
        [cell setBackgroundColor:[NSColor colorWithDeviceRed:221.0 / 255.0 green:233.0 / 255.0 blue:245.0 / 255.0 alpha:1]];
//        [cell setTextColor:[NSColor whiteColor]];
        //[cell setShadow:shadow];
        [cell setAlignment:NSCenterTextAlignment];
    } else {
        [cell setBackgroundColor:[NSColor colorWithDeviceRed:231.0 / 255.0 green:243.0 / 255.0 blue:1 alpha:1]];
//        [cell setTextColor:[NSColor blackColor]];
        [cell setAlignment:NSLeftTextAlignment];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSInteger rowIndex = [[self tableView] selectedRow];
    [[self tableView] deselectRow:rowIndex];
    
    NSString *tag = nil;
    if(NSLocationInRange(rowIndex, _typeRange)) {
        int adjustedIndex = (int)rowIndex;
        if(adjustedIndex == 0)
            return;
        adjustedIndex --;
        ERLDataType *type = [[_module types] objectAtIndex:adjustedIndex];
        tag = [type label];
    } else if(NSLocationInRange(rowIndex, _funcRange)) {
        int adjustedIndex = (int)rowIndex - (int)_funcRange.location;
        if(adjustedIndex == 0)
            return;
        adjustedIndex --;
        
        ERLFunction *func = [[_module functions] objectAtIndex:adjustedIndex];
        tag = [func label];
    } else if(NSLocationInRange(rowIndex, _callRange)) {
        int adjustedIndex = (int)rowIndex - (int)_callRange.location;
        if(adjustedIndex == 0)
            return;
        adjustedIndex --;
        
        ERLFunction *func = [[_module callbacks] objectAtIndex:adjustedIndex];
        tag = [func label];
    }
    if(tag) {
        [self textView:nil clickedOnLink:tag atIndex:0];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return _funcRange.length + _typeRange.length + _callRange.length;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if(NSLocationInRange(rowIndex, _typeRange)) {
        int adjustedIndex = (int)rowIndex;
        if(adjustedIndex == 0)
            return @"Data Types";
        adjustedIndex --;
        return [NSString stringWithFormat:@"%@()", [[[_module types] objectAtIndex:adjustedIndex] name]];
        
    } else if(NSLocationInRange(rowIndex, _funcRange)) {
        int adjustedIndex = (int)rowIndex - (int)_funcRange.location;
        if(adjustedIndex == 0)
            return @"Exported Functions";
        adjustedIndex --;
        
        ERLFunction *func = [[_module functions] objectAtIndex:adjustedIndex];
        return [NSString stringWithFormat:@"%@/%d", [func name], [func arity]];
    } else if(NSLocationInRange(rowIndex, _callRange)) {
        int adjustedIndex = (int)rowIndex - (int)_callRange.location;
        if(adjustedIndex == 0)
            return @"Callbacks";
        adjustedIndex --;
        
        ERLFunction *func = [[_module callbacks] objectAtIndex:adjustedIndex];
        return [NSString stringWithFormat:@"%@/%d", [func name], [func arity]];        
    }
    
    return @"";
}


- (void)awakeFromNib
{
    [self configureItemsFromCurrentModule];
}


@end
