//
//  EventElementViewController.m
//  Meep_IOS
//
//  Created by Ryan Sharp on 4/23/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "EventElementViewController.h"

@interface EventElementViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *timeSelect;

@end

@implementation EventElementViewController

- (IBAction)returnToEventCreator:(id)sender {
    
}

- (IBAction)selectTime:(id)sender {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
