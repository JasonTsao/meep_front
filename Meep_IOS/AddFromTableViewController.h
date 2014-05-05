//
//  AddFromContactsTableViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/4/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface AddFromTableViewController : UITableViewController <ABPeoplePickerNavigationControllerDelegate>

@property(nonatomic, strong) NSMutableData * data;
@property(nonatomic, strong) NSString * viewTitle;
@end
