//
//  KeychainItemWrapper.h
//  MeepIOS
//
//  Created by Ryan Sharp on 4/15/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainItemWrapper : NSObject
{
    NSMutableDictionary *keychainItemData;      // The actual keychain item data backing store.
    NSMutableDictionary *genericPasswordQuery;  // A placeholder for the generic keychain item query used to locate the item.
}

@property (nonatomic, retain) NSMutableDictionary *keychainItemData;
@property (nonatomic, retain) NSMutableDictionary *genericPasswordQuery;

-(id)initWithIdentifier:(NSString*)identifier accessGroup:(NSString*)accessGroup;
-(void)setObject:(id)inObject forKey:(id)key;
-(id)objectForKey:(id)key;

// Initialize & reset default generic keychain item data.
-(void)resetKeychainItem;
@end
