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
@property (nonatomic, strong) NSArray * datePreceedingExpressions;
@property (nonatomic, strong) NSArray * dateKeywords;
@property (nonatomic, strong) NSArray * dateIdentifiers;
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
        _timeIntRegex = [[NSRegularExpression alloc] initWithPattern:@"[@]?\\s?(0[1-9]|1[0-2]|[1-9])(:|.|\\s)?([0-5][0-9])?\\s?(AM|am|PM|pm)?" options:NSRegularExpressionCaseInsensitive error:nil];
        _timeExplicitRegex = [[NSRegularExpression alloc] initWithPattern:@"[@]?(one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|noon)\\s?(ten|fifteen|twenty|twenty\\s?five|thirty|forty\\s?five|fifty)?" options:NSRegularExpressionCaseInsensitive error:nil];
        _dateIntRegex = [[NSRegularExpression alloc] initWithPattern:@"(0[1-9]|1[0-2]|[1-9])(/|-)([1-31])(/|-)([0-9]{4,4})?" options:NSRegularExpressionCaseInsensitive error:nil];
        _dateExplicitRegex = [[NSRegularExpression alloc] initWithPattern:@"(next\\s)?(mon(day)?|tues?(day)?|wed(nesday)?|thu?r?s?(day)?|fri(day)?|sat(urday)?|sun(day)?)\\s" options:NSRegularExpressionCaseInsensitive error:nil];
        _datePreceedingExpressions = [[NSArray alloc] initWithObjects:@"next",@"following",@"this",nil];
        _dateKeywords = [[NSArray alloc] initWithObjects:@"week",@"afternoon",@"evening",@"day",@"month",@"morning",@"noon",nil];
        _dateIdentifiers = [[NSArray alloc] initWithObjects:@"tomorrow",@"today",@"tonight",nil];
    }
    return self;
}

- (NSDictionary*) parseText:(NSString*)text {
    NSString * newText = @"";
    for (int i = 0; i < [text length]; i++) {
        NSString * nextChar = [NSString stringWithFormat:@"%c",[text characterAtIndex:i]];
        if ([newText length] == 0) {
            if ([nextChar isEqualToString:@" "]) {
                continue;
            }
            newText = nextChar;
            continue;
        }
        NSString * newTextLastChar = [newText substringFromIndex:[newText length] - 1];
        if ([nextChar isEqualToString:@" "] && [newTextLastChar isEqualToString:@" "]) {
            continue;
        }
        newText = [NSString stringWithFormat:@"%@%@",newText,nextChar];
    }
    text = newText;
    if ([text length] == 0) {
        return nil;
    }
    NSArray * textArray = [text componentsSeparatedByString:@" "];
    NSMutableDictionary * contentDictionary = [[NSMutableDictionary alloc] init];
    int arraySize = [textArray count];
    _beginningOfExpression = 0;
    for (int i = 0; i < arraySize; i++) {
        NSString * word = [textArray objectAtIndex:i];
        NSString * phrase = @"";
        for (int j = _beginningOfExpression; j < i + 1; j++) {
            NSString * currentWord = [textArray objectAtIndex:j];
            int beginningOfPunctuation = [self identifyPunctuation:currentWord];
            NSLog(@"%i",beginningOfPunctuation);
            if (beginningOfPunctuation != -1 && beginningOfPunctuation != 0) {
                currentWord = [currentWord substringToIndex:beginningOfPunctuation];
            }
            phrase = [NSString stringWithFormat:@"%@ %@",phrase,currentWord];
        }
        NSDictionary * content = [self checkContent:phrase];
        if ([content objectForKey:@"startTime"]) {
            [contentDictionary setValue:[content objectForKey:@"startTime"] forKey:@"startTime"];
        }
        if ([content objectForKey:@"startDate"]) {
            [contentDictionary setValue:[content objectForKey:@"startDate"] forKey:@"startDate"];
        }
        BOOL override = NO;
        if (i == arraySize - 1) {
            override = YES;
        }
        if ([self isTimePreposition:[textArray objectAtIndex:i]] |
            [self isDatePreposition:[textArray objectAtIndex:i]] |
            [self isLocationPreposition:[textArray objectAtIndex:i]] |
            [self breakPointPunctuation:word elseOverride:override]) {
            _beginningOfExpression = i + 1;
        }
    }
    return contentDictionary;
}

- (int) identifyPunctuation:(NSString*)word {
    NSRegularExpression * punctuation = [[NSRegularExpression alloc] initWithPattern:@"[.;,\"'/=+?!]" options:NSRegularExpressionCaseInsensitive error:nil];
    int breakIndex = -1;
    for (int i = 0; i < [word length]; i++) {
        NSArray * content = [punctuation matchesInString:[NSString stringWithFormat:@"%c",[word characterAtIndex:i]] options:0 range:NSMakeRange(0, 1)];
        if ([content count] > 0 && (breakIndex == 0 | breakIndex == -1)) {
            breakIndex = i;
        }
        else if (breakIndex != -1){
            breakIndex = 0;
        }
    }
    return breakIndex;
}

- (BOOL) breakPointPunctuation:(NSString*)word elseOverride:(BOOL)override {
    if (override) {
        return NO;
    }
    NSString * lastChar = [word substringFromIndex:([word length] - 1)];
    NSRegularExpression * bpPunctuation = [[NSRegularExpression alloc] initWithPattern:@"[.!?]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray * content = [bpPunctuation matchesInString:lastChar options:0 range:NSMakeRange(0, [lastChar length])];
    if ([content count] > 0) {
        return YES;
    }
    return NO;
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
    NSLog(@"%@",text);
    NSArray *content;
    NSMutableDictionary * returnDictionary = [[NSMutableDictionary alloc] init];
    content = [_timeIntRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    if ([content count] > 0) {
        [returnDictionary setObject:[text substringWithRange:[[content objectAtIndex:0] range]] forKey:@"startTime"];
    }
    content = [_timeExplicitRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    if ([content count] > 0) {
        [returnDictionary setObject:[text substringWithRange:[[content objectAtIndex:0] range]] forKey:@"startTime"];
    }
    content = [_dateIntRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    if ([content count] > 0) {
        [returnDictionary setObject:[text substringWithRange:[[content objectAtIndex:0] range]] forKey:@"startDate"];
    }
    content = [_dateExplicitRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    if ([content count] > 0) {
        [returnDictionary setObject:[text substringWithRange:[[content objectAtIndex:0] range]] forKey:@"startDate"];
    }
    NSArray * textArray = [text componentsSeparatedByString:@" "];
    BOOL searching = NO;
    for (NSString * textArrayElement in textArray) {
        
    }
    return returnDictionary;
}

@end
