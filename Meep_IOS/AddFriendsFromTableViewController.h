//
//  AddFriendsFromTableViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/4/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Friend.h"
#import "MEEPhttp.h"

@interface AddFriendsFromTableViewController : UITableViewController
@property(nonatomic, strong) NSMutableData * data;
@property(nonatomic, strong) NSMutableArray * phoneRegisteredUsers;
@property(nonatomic, strong) NSMutableArray * phoneNonRegisteredUsers;
@property(nonatomic, strong) NSMutableArray * phoneNonFriendUsers;
@property(nonatomic, strong) NSMutableArray * phoneNonFriendUsersNumbers;
@property(nonatomic, strong) NSMutableArray * phoneContacts;
@property(nonatomic, strong) NSMutableArray * phoneContactNumbers;
@property(nonatomic, strong) NSMutableArray * friendsList;
@property(nonatomic, strong) NSMutableDictionary * buttonTagDictionary;
@property(nonatomic) NSInteger buttonTagNumber;
@property(nonatomic, strong) NSString * viewTitle;
@end
