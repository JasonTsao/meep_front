//
//  EventPageViewController.h
//  MeepIOS
//
//  Created by Ryan Sharp on 4/15/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EventPageViewControllerDelegate <NSObject>

@optional

@required
- (void)closeEventModal;

@end

@interface EventPageViewController : UIViewController

@property (nonatomic, assign) id<EventPageViewControllerDelegate> delegate;

@end