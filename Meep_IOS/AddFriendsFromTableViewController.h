//
//  AddFriendsFromTableViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/4/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface AddFriendsFromTableViewController : UITableViewController
@property(nonatomic, strong) NSMutableData * data;
@property(nonatomic, strong) NSMutableArray * phoneContacts;
@property(nonatomic, strong) NSString * viewTitle;
@end
