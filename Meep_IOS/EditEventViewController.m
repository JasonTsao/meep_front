//
//  EditEventViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/9/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "EditEventViewController.h"

@interface EditEventViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionField;
@property (weak, nonatomic) IBOutlet UIDatePicker *startTimeField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;

@end

@implementation EditEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing: YES];
}

- (void)backToEventPage:(id)sender {
    [_delegate backToEventPage:self];
}
- (IBAction)updateEvent:(id)sender {
    // synchronous update of event
    NSString * requestURL = [NSString stringWithFormat:@"%@update/%i",[MEEPhttp eventURL], _currentEvent.event_id];
    //NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"user", messageText, @"description", invitedFriendsToSend, @"invited_friends", nil];
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc]init];
    
    [postDict setObject:_descriptionField.text forKey:@"description"];
    [postDict setObject:_nameField.text forKey:@"name"];
    [postDict setObject:_locationField.text forKey:@"location_name"];
    [postDict setObject:_startTimeField.date.description forKey:@"start_time"];
    //NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:removedFriendsToSend, @"removed_friends", invitedFriendsToSend, @"invited_friends", nil];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLResponse * response = nil;
    NSError * error = nil;
    /*NSData *return_data = [NSURLConnection sendSynchronousRequest:request
     returningResponse:&response
     error:&error];*/
    [_delegate backToEventPage:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _currentEvent.name;
    _nameField.text = _currentEvent.name;
    _descriptionField.text = _currentEvent.description;
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToEventPage:)];
    
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
