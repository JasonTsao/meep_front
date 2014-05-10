//
//  EditGroupViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/10/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "EditGroupViewController.h"

@interface EditGroupViewController ()

@end

@implementation EditGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)backToGroupPage:(id)sender {
    
    // synchronous update of event
    [_delegate backToGroupPage:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToGroupPage:)];
    
    self.navigationItem.leftBarButtonItem = customBarItem;
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
