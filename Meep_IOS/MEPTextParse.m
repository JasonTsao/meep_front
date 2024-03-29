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
        _timeIntRegex = [[NSRegularExpression alloc] initWithPattern:@"((([0-2]?[0-9])((:)?([0-5][0-9]))?\\s?(AM|am|PM|pm)?)|((0[0-9]|1[0-9]|2[0-3])([0-5][0-9])))" options:NSRegularExpressionCaseInsensitive error:nil];
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
    if (!([[text substringFromIndex:[text length] - 1] isEqualToString:@" "] | [[text substringFromIndex:[text length] - 1] isEqualToString:@"."])) {
        arraySize = arraySize - 1;
    }
    int previousBeginningOfExpression = 0;
    for (int i = 0; i < arraySize; i++) {
        if (i == 0) {
            [contentDictionary setValue:[MEPTextParse identifyCategory:[textArray objectAtIndex:i]] forKey:@"category"];
        }
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
        NSString * timeContent = [self convertToConstructedTimeString:[text substringWithRange:[[content objectAtIndex:[content count] - 1] range]]];
        // [returnDictionary setObject:[text substringWithRange:[[content objectAtIndex:0] range]] forKey:@"startTime"];
        [returnDictionary setObject:[self convertToConstructedTimeString:[text substringWithRange:[[content objectAtIndex:[content count] - 1] range]]] forKey:@"startTime"];
    }
    /*
    content = [_timeExplicitRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    if ([content count] > 0) {
        [returnDictionary setObject:[text substringWithRange:[[content objectAtIndex:0] range]] forKey:@"startTime"];
    }
     */
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
            content = [_dateExplicitRegex matchesInString:textArrayElement options:0 range:NSMakeRange(0, [textArrayElement length])];
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
            [returnDictionary setObject:[self evaluateExplicitDateString:[textArrayElement substringWithRange:[[content objectAtIndex:0] range]] plusWeeks:weeks] forKey:@"startDate"];
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
    NSLog(@"%@",text);
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
    NSLog(@"%i",weeks);
    NSLog(@"%i",daysFromToday);
    int secondsFromToday = (daysFromToday + (weeks * 7)) * 24 * 60 * 60;
    NSDate * targetDate = [NSDate dateWithTimeInterval:secondsFromToday sinceDate:today];
    [dayStringFormat setDateFormat:@"MMM dd, yyyy"];
    return [dayStringFormat stringFromDate:targetDate];
}

- (NSString*) convertToConstructedTimeString:(NSString*)timeText {
    NSString * timeWithoutPunctuation = @"";
    NSString * timeModifier = @"";
    timeText = [timeText lowercaseString];
    for (int i = 0; i < [timeText length]; i++) {
        NSString * currentChar = [timeText substringToIndex:i+1];
        currentChar = [currentChar substringFromIndex:i];
        NSScanner * scanner = [[NSScanner alloc] initWithString:currentChar];
        if ([scanner scanInteger:NULL]) {
            timeWithoutPunctuation = [NSString stringWithFormat:@"%@%@",timeWithoutPunctuation,currentChar];
        }
        else if (!([currentChar isEqualToString:@":"] | [currentChar isEqualToString:@" "])) {
            timeModifier = [NSString stringWithFormat:@"%@%@",timeModifier,currentChar];
        }
    }
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    int time = [timeWithoutPunctuation intValue];
    NSLog(@"%i",time);
    if ([timeWithoutPunctuation length] == 4) {
        if (time > 1259) {
            [formatter setDateFormat:@"HHmm"];
        }
        else {
            [formatter setDateFormat:@"hhmm"];
        }
    }
    else if ([timeWithoutPunctuation length] == 3) {
        [formatter setDateFormat:@"hmm"];
    }
    else if ([timeWithoutPunctuation length] < 3) {
        [formatter setDateFormat:@"h"];
    }
    else {
        return @"";
    }
    if (([timeModifier length] >= 2)) {
        [formatter setDateFormat:@"HHmm"];
        if ([@"p" isEqualToString:[timeModifier substringToIndex:1]]) {
            if (time <= 12) {
                time = time * 100;
            }
            if (time < 1200) {
                time += 1200;
            }
        }
        if ([@"a" isEqualToString:[timeModifier substringToIndex:1]]) {
            if (time <= 12) {
                time = time * 100;
            }
        }
        if ([@"a" isEqualToString:[timeModifier substringToIndex:1]] && time == 1200) {
            time = 0;
            [formatter setDateFormat:@"H"];
        }
    }
    NSString * dateString = [NSString stringWithFormat:@"%i",time];
    NSDate * date = [formatter dateFromString:dateString];
    [formatter setDateFormat:@"hh:mm a"];
    return [formatter stringFromDate:date];
}

- (NSString*) evaluteExplicitTimeString:(NSString*)timeText {
    NSDate * today = [[NSDate alloc] init];
    NSDateFormatter * hours = [[NSDateFormatter alloc] init];
    NSDateFormatter * minutes = [[NSDateFormatter alloc] init];
    [hours setDateFormat:@"HH"];
    [minutes setDateFormat:@"mm"];
    NSDateFormatter * timeParser = [[NSDateFormatter alloc] init];
    return @"";
}

+ (NSString*) identifyCategory: (NSString*)text {
    NSArray * textArray = [text componentsSeparatedByString:@" "];
    NSString * firstWord = textArray[0];
    NSArray * category;
    NSString * first = [firstWord lowercaseString];
    category = [[NSArray alloc] initWithObjects:@"dinner",@"lunch",@"breakfast", nil];
    if ([category containsObject:first]) {
        return @"meal";
    }
    category = [[NSArray alloc] initWithObjects:@"clubbing", nil];
    if ([category containsObject:first]) {
        return @"nightlife";
    }
    category = [[NSArray alloc] initWithObjects:@"drinks", nil];
    if ([category containsObject:first]) {
        return @"drinks";
    }
    category = [[NSArray alloc] initWithObjects:@"call",@"meeting",nil];
    if ([category containsObject:first]) {
        return @"meeting";
    }
    category = [[NSArray alloc] initWithObjects:@"hiking",@"beach",@"camping", nil];
    if ([category containsObject:first]) {
        return @"outdoors";
    }
    return @"generic";
}

+ (NSString*) getTimeUntilDateTime:(NSDate *)date {
    NSDate * now = [[NSDate alloc] init];
    NSDate * then = date;
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    BOOL eventPassed = NO;
    if ([now compare:date] == NSOrderedDescending) {
        eventPassed = YES;
        then = now;
        now = date;
    }
    NSDateComponents * components = [calendar components:unitFlags fromDate:now toDate:then options:0];
    NSInteger years = [components year];
    NSInteger months = [components month];
    NSInteger days = [components day];
    NSInteger hours = [components hour];
    NSInteger minutes = [components minute];
    NSString * timeDiffMessage = @"";
    if (years > 0) {
        if (eventPassed) {
            if (years == 1) {
                return timeDiffMessage = [NSString stringWithFormat:@"1 year ago"];
            }
            return timeDiffMessage = [NSString stringWithFormat:@"%li years ago",(long)years];
        }
        else {
            if (years == 1) {
                return timeDiffMessage = [NSString stringWithFormat:@"In 1 year"];
            }
            return timeDiffMessage = [NSString stringWithFormat:@"In %ld years",(long)years];
        }
    }
    else if (months > 0) {
        if (eventPassed) {
            if (months == 1) {
                return timeDiffMessage = [NSString stringWithFormat:@"1 month ago"];
            }
            return timeDiffMessage = [NSString stringWithFormat:@"%li months ago",(long)months];
        }
        else {
            if (months == 1) {
                return timeDiffMessage = [NSString stringWithFormat:@"In 1 month"];
            }
            return timeDiffMessage = [NSString stringWithFormat:@"In %li months",(long)months];
        }
    }
    else if (days > 0) {
        if (eventPassed) {
            if (days == 1) {
                return timeDiffMessage = [NSString stringWithFormat:@"1 day ago"];
            }
            return timeDiffMessage = [NSString stringWithFormat:@"%li days ago",(long)days];
        }
        else {
            if (days == 1) {
                return timeDiffMessage = [NSString stringWithFormat:@"In 1 day"];
            }
            return timeDiffMessage = [NSString stringWithFormat:@"In %li days",(long)days];
        }
    }
    else if (hours > 0) {
        if (eventPassed) {
            if (hours == 1) {
                return timeDiffMessage = [NSString stringWithFormat:@"1 hour ago"];
            }
            return timeDiffMessage = [NSString stringWithFormat:@"%li hours ago",(long)hours];
        }
        else {
            if (hours == 1) {
                return timeDiffMessage = [NSString stringWithFormat:@"In 1 hour"];
            }
            return timeDiffMessage = [NSString stringWithFormat:@"In %li hours",(long)hours];
        }
    }
    else if (minutes >= 0) {
        if (eventPassed) {
            if (minutes == 1) {
                return timeDiffMessage = [NSString stringWithFormat:@"On going"];
            }
            return timeDiffMessage = [NSString stringWithFormat:@"Started %li minutes ago",(long)minutes];
        }
        else {
            if (minutes == 1) {
                return timeDiffMessage = [NSString stringWithFormat:@"Starts in 1 minute"];
            }
            return timeDiffMessage = [NSString stringWithFormat:@"Starts in %li minutes",(long)minutes];
        }
    }
    return @"Data Unavailable";
}

@end
