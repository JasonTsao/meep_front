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
@end

@implementation MEPTextParse

- (id) init {
    if((self = [super init])) {
        _timePrepositionArray = [[NSArray alloc] initWithObjects:@"about",@"after",@"around",@"at",@"before",@"by",@"from",@"in",@"past",@"since",@"till",@"until",@"within", nil];
        _datePrepositionArray = [[NSArray alloc] initWithObjects:@"about",@"after",@"around",@"at",@"before",@"by",@"from",@"in",@"past",@"since",@"till",@"until",@"within", nil];
        // _locationPrepositionArray = [[NSArray alloc] initWithObjects:@"around",@"behind",@"below",@"beneath",@"beside",@"between",@"by",@"in",@"inside",@"near",@"of",@"on",@"to",@"within",nil];
        _locationPrepositionArray = [[NSArray alloc] initWithObjects:@"at",@"near", nil];
        _timeIntRegex = [[NSRegularExpression alloc] initWithPattern:@"(0[1-9]|1[0-2]|[1-9])((:|.|\\s)?([0-5][0-9]))?\\s?(AM|am|PM|pm)?" options:NSRegularExpressionCaseInsensitive error:nil];
        _timeExplicitRegex = [[NSRegularExpression alloc] initWithPattern:@"(one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|noon)\\s?(ten|fifteen|twenty|twenty\\s?five|thirty|forty\\s?five|fifty)?\\s?(AM|am|PM|pm)?" options:NSRegularExpressionCaseInsensitive error:nil];
        _dateIntRegex = [[NSRegularExpression alloc] initWithPattern:@"(0[1-9]|1[0-2]|[1-9])(/|-)([1-31])(/|-)([0-9]{4,4})?" options:NSRegularExpressionCaseInsensitive error:nil];
        _dateExplicitRegex = [[NSRegularExpression alloc] initWithPattern:@"(mon(day)?|tues?(day)?|wed(nesday)?|thu?r?s?(day)?|fri(day)?|sat(urday)?|sun(day)?)" options:NSRegularExpressionCaseInsensitive error:nil];
        _datePreceedingExpressions = [[NSArray alloc] initWithObjects:@"next",@"this",nil];
        _dateKeywords = [[NSArray alloc] initWithObjects:@"week",@"afternoon",@"evening",@"day",@"month",@"morning",nil];
        _dateIdentifiers = [[NSArray alloc] initWithObjects:@"tomorrow",@"today",@"tonight",nil];
    }
    return self;
}

- (NSDictionary*) parseText:(NSString*)text {
    NSString * newText = @"";
    NSString * locationText = @"";
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
    int beginningOfExpression = 0;
    if (![[text substringFromIndex:[text length] - 1] isEqualToString:@" "]) {
        arraySize = arraySize - 1;
    }
    int previousBeginningOfExpression = 0;
    for (int i = 0; i < arraySize; i++) {
        NSString * word = [textArray objectAtIndex:i];
        NSString * phrase = @"";
        for (int j = beginningOfExpression; j < i + 1; j++) {
            NSString * currentWord = [textArray objectAtIndex:j];
            int beginningOfPunctuation = [self identifyPunctuation:currentWord];
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
        if (previousBeginningOfExpression != 0 && [locationText isEqualToString:@""]) {
            if ([_locationPrepositionArray containsObject:[textArray objectAtIndex:previousBeginningOfExpression]]) {
                for (int n = previousBeginningOfExpression + 1; n < beginningOfExpression; n++) {
                    if ([self.dateIdentifiers containsObject:[textArray objectAtIndex:n]] |
                        [self.dateKeywords containsObject:[textArray objectAtIndex:n]] |
                        [[self.timeIntRegex matchesInString:[textArray objectAtIndex:n] options:0 range:NSMakeRange(0, [[textArray objectAtIndex:n] length])] count] > 0 |
                        [[self.timeExplicitRegex matchesInString:[textArray objectAtIndex:n] options:0 range:NSMakeRange(0, [[textArray objectAtIndex:n] length])] count] > 0 |
                        [[self.dateExplicitRegex matchesInString:[textArray objectAtIndex:n] options:0 range:NSMakeRange(0, [[textArray objectAtIndex:n] length])] count] > 0 |
                        [[self.dateIntRegex matchesInString:[textArray objectAtIndex:n] options:0 range:NSMakeRange(0, [[textArray objectAtIndex:n] length])] count] > 0) {
                        break;
                    }
                    locationText = [NSString stringWithFormat:@"%@ %@",locationText,[textArray objectAtIndex:n]];
                }
                if (![locationText length] < 1) {
                    [contentDictionary setValue:[locationText substringFromIndex:1] forKey:@"location"];
                }
            }
        }
        BOOL override = NO;
        if (i == arraySize - 1) {
            override = YES;
        }
        if ([self isTimePreposition:[textArray objectAtIndex:i]] |
            [self isDatePreposition:[textArray objectAtIndex:i]] |
            [self isLocationPreposition:[textArray objectAtIndex:i]]) {
            previousBeginningOfExpression = beginningOfExpression;
            beginningOfExpression = i;
        }
        else if ([self breakPointPunctuation:word elseOverride:override]) {
            previousBeginningOfExpression = beginningOfExpression;
            beginningOfExpression = i + 1;
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
    /*
    content = [_dateExplicitRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    BOOL containsExplicitDate = NO;
    if ([content count] > 0) {
        containsExplicitDate = YES;
        // [returnDictionary setObject:[text substringWithRange:[[content objectAtIndex:0] range]] forKey:@"startDate"];
    }
     */
    NSArray * textArray = [text componentsSeparatedByString:@" "];
    BOOL searching = NO;
    BOOL stillSearching = NO;
    BOOL containsExplicitDate = NO;
    NSString * preceedingElement;
    for (NSString * textArrayElement in textArray) {
        if ([_dateIdentifiers containsObject:[textArrayElement lowercaseString]]) {
            if ([[textArrayElement lowercaseString] isEqualToString:@"tomorrow"]) {
                [returnDictionary setObject:[self createDateString:1] forKey:@"startDate"];
            }
            else {
                [returnDictionary setObject:[self createDateString:0] forKey:@"startDate"];
            }
        }
        if (searching) {
            if ([_dateKeywords containsObject:[textArrayElement lowercaseString]]) {
                if ([preceedingElement isEqualToString:@"this"]) {
                    [returnDictionary setObject:[self createDateString:0] forKey:@"startDate"];
                }
            }
        }
        if ([[_dateExplicitRegex matchesInString:textArrayElement options:0 range:NSMakeRange(0, [textArrayElement length])] count] > 0) {
            containsExplicitDate = YES;
        }
        else {
            containsExplicitDate = NO;
        }
        if (containsExplicitDate) {
            int weeks = 0;
            if (searching) {
                if ([preceedingElement isEqualToString:@"next"]) {
                    weeks = 1;
                }
            }
            [returnDictionary setObject:[self evaluateExplicitDateString:[text substringWithRange:[[content objectAtIndex:0] range]] plusWeeks:weeks] forKey:@"startDate"];
        }
        if ([_datePreceedingExpressions containsObject:[textArrayElement lowercaseString]]) {
            searching = YES;
            preceedingElement = [textArrayElement lowercaseString];
        }
        if (searching && !stillSearching) {
            stillSearching = YES;
        }
        else {
            searching = NO;
            stillSearching = NO;
        }
    }
    return returnDictionary;
}

- (NSString*) createDateString:(int)daysFromToday {
    NSDate * today = [NSDate date];
    int intervalInSeconds = daysFromToday * 60 * 60 * 24;
    NSDate * targetDate = [NSDate dateWithTimeInterval:intervalInSeconds sinceDate:today];
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM dd, yyyy"];
    return [df stringFromDate:targetDate];
}

- (NSString*) evaluateExplicitDateString:(NSString*)dateText plusWeeks:(int)weeks {
    NSDate * today = [NSDate date];
    NSDateFormatter * dayStringFormat = [[NSDateFormatter alloc] init];
    [dayStringFormat setDateFormat:@"c"];
    NSString * text = [dateText lowercaseString];
    NSString * writtenDay = [dayStringFormat stringFromDate:today];
    int currentDay = [writtenDay intValue];
    int daysFromToday = 0;
    if ([text isEqualToString:@"sun"] | [text isEqualToString:@"sunday"]) {
        if (currentDay < 2) {
            daysFromToday = 0;
        }
        else {
            daysFromToday = 8 - currentDay;
        }
    }
    if ([text isEqualToString:@"mon"] | [text isEqualToString:@"monday"]) {
        if (currentDay < 3) {
            daysFromToday = 2 - currentDay;
        }
        else {
            daysFromToday = 9 - currentDay;
        }
    }
    if ([text isEqualToString:@"tue"] | [text isEqualToString:@"tues"] | [text isEqualToString:@"tuesday"]) {
        if (currentDay < 4) {
            daysFromToday = 3 - currentDay;
        }
        else {
            daysFromToday = 10 - currentDay;
        }
    }
    if ([text isEqualToString:@"wed"] | [text isEqualToString:@"wednesday"]) {
        if (currentDay < 5) {
            daysFromToday = 4 - currentDay;
        }
        else {
            daysFromToday = 11 - currentDay;
        }
    }
    if ([text isEqualToString:@"thu"] | [text isEqualToString:@"thur"] | [text isEqualToString:@"thurs"] | [text isEqualToString:@"thursday"]) {
        if (currentDay < 6) {
            daysFromToday = 5 - currentDay;
        }
        else {
            daysFromToday = 12 - currentDay;
        }
    }
    if ([text isEqualToString:@"fri"] | [text isEqualToString:@"friday"]) {
        if (currentDay < 7) {
            daysFromToday = 6 - currentDay;
        }
        else {
            daysFromToday = 13 - currentDay;
        }
    }
    if ([text isEqualToString:@"sat"] | [text isEqualToString:@"saturday"]) {
        daysFromToday = 7 - currentDay;
    }
    int secondsFromToday = (daysFromToday + (weeks * 7)) * 24 * 60 * 60;
    NSDate * targetDate = [NSDate dateWithTimeInterval:secondsFromToday sinceDate:today];
    [dayStringFormat setDateFormat:@"MMM dd, yyyy"];
    return [dayStringFormat stringFromDate:targetDate];
}

- (NSString*) evaluteExplicitTimeString:(NSString*)timeText {
    NSDate * today = [[NSDate alloc] init];
    NSDateFormatter * hours = [[NSDateFormatter alloc] init];
    NSDateFormatter * minutes = [[NSDateFormatter alloc] init];
    [hours setDateFormat:@"HH"];
    [minutes setDateFormat:@"mm"];
    return @"";
}

@end
