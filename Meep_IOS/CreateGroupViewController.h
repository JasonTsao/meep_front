//
//  CreateGroupViewController.h
//  Group
//
//  Created by Jason Tsao on 4/30/14.
//  Copyright (c) 2014 Jason Tsao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateGroupViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) NSMutableData * data;
@end
