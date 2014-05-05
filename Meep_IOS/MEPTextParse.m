//
//  MEPTextParse.m
//  Meep_IOS
//
//  Created by Ryan Sharp on 5/1/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "MEPTextParse.h"

@interface MEPTextParse ()
@property (nonatomic, strong) NSArray * timePrepositionArray;
@property (nonatomic, strong) NSArray * locationPrepositionArray;
@property (nonatomic, strong) NSArray * datePrepositionArray;
@property (nonatomic, strong) NSArray * timeIdentifierArray;
@property (nonatomic, strong) NSArray * dateIdentifierArray;
@property (nonatomic, strong) NSRegularExpression * timeIntRegex;
@property (nonatomic, strong) NSRegularExpression * timeExplicitRegex;
@property (nonatomic, strong) NSRegularExpression * dateIntRegex;
@property (nonatomic, strong) NSRegularExpression * dateExplicitRegex;
@property (nonatomic, assign) int beginningOfExpression;
@end

@implementation MEPTextParse

- (id) init {
    if((self = [super init])) {
        _beginningOfExpression = 0;
        _timePrepositionArray = [[NSArray alloc] initWithObjects:@"about",@"after",@"around",@"at",@"before",@"by",@"from",@"in",@"past",@"since",@"till",@"until",@"within", nil];
        _datePrepositionArray = [[NSArray alloc] initWithObjects:@"about",@"after",@"around",@"at",@"before",@"by",@"from",@"in",@"past",@"since",@"till",@"until",@"within", nil];
        _locationPrepositionArray = [[NSArray alloc] initWithObjects:@"around",@"behind",@"below",@"beneath",@"beside",@"between",@"by",@"in",@"inside",@"near",@"of",@"on",@"to",@"within",nil];
        _timeIntRegex = [[NSRegularExpression alloc] initWithPattern:@"(0[1-9]|1[0-2]|[1-9])(:|.|\\s)?([0-5][0-9])?\\s?(AM|am|PM|pm)?" options:NSRegularExpressionCaseInsensitive error:nil];
        _timeExplicitRegex = [[NSRegularExpression alloc] initWithPattern:@"(one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve)\\s?(ten|fifteen|twenty|twenty\\s?five|thirty|forty\\s?five|fifty)?" options:NSRegularExpressionCaseInsensitive error:nil];
        _dateIntRegex = [[NSRegularExpression alloc] initWithPattern:@"(0[1-9]|1[0-2]|[1-9])(/|-)([1-31])(/|-)([0-9]{4,4})?" options:NSRegularExpressionCaseInsensitive error:nil];
        _dateExplicitRegex = [[NSRegularExpression alloc] initWithPattern:@"(mon(day)*|tues(day)*|wed(nesday)*|thurs(day)*|fri(day)*|sat(urday)*|sun(day)*)" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return self;
}

- (NSDictionary*) parseText:(NSString*)text withOverride:(BOOL)override {
    NSArray * textArray = [text componentsSeparatedByString:@" "];
    NSMutableDictionary * contentDictionary = [[NSMutableDictionary alloc] init];
    int arraySize = [textArray count];
    _beginningOfExpression = 0;
    for (int i = 0; i < arraySize; i++) {
        NSLog(@"%@",[textArray objectAtIndex:i]);
        if([self isTimePreposition:[textArray objectAtIndex:i]] | [self isDatePreposition:[textArray objectAtIndex:i]] | [self isLocationPreposition:[textArray objectAtIndex:i]] | override) {
            NSString * phrase = @"";
            for (int j = _beginningOfExpression; j < i; j++) {
                phrase = [NSString stringWithFormat:@"%@ %@",phrase,[textArray objectAtIndex:j]];
            }
            NSDictionary * content = [self checkContent:phrase];
            if([content objectForKey:@"startTime"]) {
                [contentDictionary setValue:[content objectForKey:@"startTime"] forKey:@"startTime"];
            }
            if([content objectForKey:@"startDate"]) {
                [contentDictionary setValue:[content objectForKey:@"startDate"] forKey:@"startDate"];
            }
            if([self isTimePreposition:[textArray objectAtIndex:i]] | [self isDatePreposition:[textArray objectAtIndex:i]] | [self isLocationPreposition:[textArray objectAtIndex:i]]) {
                _beginningOfExpression = i + 1;
            }
        }
    }
    return contentDictionary;
}

- (BOOL) isTimePreposition:(NSString*)text {
    return [_timePrepositionArray containsObject:[text lowercaseString]];
}

- (BOOL) isDatePreposition:(NSString*)text {
    return [_datePrepositionArray containsObject:[text lowercaseString]];
}

- (BOOL) isLocationPreposition:(NSString*)text {
    return [_locationPrepositionArray containsObject:[text lowercaseString]];
}

- (NSDictionary*) checkContent:(NSString*)text {
    NSArray *content;
    content = [_timeIntRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    if([content count] > 0) {
        return [[NSDictionary alloc] initWithObjectsAndKeys:[text substringWithRange:[[content objectAtIndex:0] range]],@"startTime", nil];
    }
    content = [_timeExplicitRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    if([content count] > 0) {
        return [[NSDictionary alloc] initWithObjectsAndKeys:[text substringWithRange:[[content objectAtIndex:0] range]],@"startTime", nil];
    }
    content = [_dateIntRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    if([content count] > 0) {
        return [[NSDictionary alloc] initWithObjectsAndKeys:[text substringWithRange:[[content objectAtIndex:0] range]],@"startDate", nil];
    }
    content = [_dateExplicitRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    if([content count] > 0) {
        return [[NSDictionary alloc] initWithObjectsAndKeys:[text substringWithRange:[[content objectAtIndex:0] range]],@"startDate", nil];
    }
    return nil;
}

@end
