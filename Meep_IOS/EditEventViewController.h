//
//  EditEventViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/9/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "EventPageViewController.h"

@class EditEventViewController;

@protocol EditEventViewControllerDelegate
- (void) backToEventPage:(EditEventViewController *)controller;
@end

@interface EditEventViewController : UIViewController
@property (nonatomic) Event *currentEvent;
@property(nonatomic, strong) id <EditEventViewControllerDelegate> delegate;
@end
