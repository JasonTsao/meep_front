//
//  CreateMessageViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/1/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "CreateMessageViewController.h"
#import "MEPTextParse.h"

@interface CreateMessageViewController ()
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UITableView *invitedFriendsTable;
@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UITextField *dateField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (nonatomic, strong) MEPTextParse *parser;
@property (nonatomic, strong) NSMutableData * data;


@end

@implementation CreateMessageViewController
    

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)createEvent:(id)sender {
    NSString *messageText = _messageField.text;
    NSLog(@"Message: %@", messageText);
    NSMutableArray *invitedFriendsToSend = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_invited_friends_list count]; i++){
        NSString *user_id = [NSString stringWithFormat: @"%i", [_invited_friends_list[i] account_id]];
        NSDictionary *friend_dict = [[NSDictionary alloc] initWithObjectsAndKeys:user_id,@"user_id", @"false", @"can_invite_friends", nil];
        [invitedFriendsToSend addObject:friend_dict];
        NSLog(@"invited friend: %i", [_invited_friends_list[i] account_id]);
    }
    
    NSString * requestURL = [NSString stringWithFormat:@"%@new",[MEEPhttp eventURL]];
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"user", messageText, @"description", invitedFriendsToSend, @"invited_friends", nil];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData *return_data = [NSURLConnection sendSynchronousRequest:request
                                                returningResponse:&response
                                                            error:&error];
    
    NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:return_data options:0 error:&error];
    NSLog(@"jsonResponse: %@", jsonResponse);
    NSArray * success = jsonResponse[@"success"];
    NSMutableArray * return_invited_friends = jsonResponse[@"invited_friends"];
    NSMutableArray * invitedFriendsList = [[NSMutableArray alloc]init];
    
    /*for (int i = 0; i < [return_invited_friends count]; i++){
     
     InvitedFriend * invited_friend = [[InvitedFriend alloc] initWithName:[_invited_friends_list[i] name] withAccountID:return_invited_friends[i][@"user"] withAttending:return_invited_friends[i][@"attending"] withCanInvite:return_invited_friends[i][@"can_invite_friends"]];
     [invitedFriendsList addObject: invited_friend];
     }*/
    
    Event * newEvent = [[Event alloc] initWithDescription:jsonResponse[@"event"][@"description"] withName:jsonResponse[@"event"][@"name"] startTime:jsonResponse[@"event"][@"start_time"] eventId:[jsonResponse[@"event"][@"id"] integerValue]];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    EventPageViewController *eventPageViewController = (EventPageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"EventViewController"];
    eventPageViewController.currentEvent = newEvent;
    [eventPageViewController setDelegate:self.delegate];
    [self presentViewController:eventPageViewController animated:YES completion:nil];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *friend_name;
    Friend *selectedFriend;
    
    if(indexPath.section == 0){
        selectedFriend = _invited_friends_list[indexPath.row];
        friend_name = selectedFriend.name;
        [tableView beginUpdates];
        [_invited_friends_list removeObjectAtIndex: indexPath.row];
        [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]]
                         withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    if (section == 0){
        header = @"Invited";
    }
    
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 1;
    if (section == 0){
        numRows = [_invited_friends_list count];
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"invitedFriendCell"];
    
    if (indexPath.section == 0){
        Friend *currentFriend = _invited_friends_list[indexPath.row];
        cell.textLabel.text = currentFriend.name;
    }
    
    return cell;
}

- (void) textFieldDidChange {
    NSDictionary * contentDetails = [_parser parseText:[_messageField text]];
    NSLog(@"%@",contentDetails);
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messageField.delegate = self;
    // Do any additional setup after loading the view.
    self.parser = [[MEPTextParse alloc] init];
    [self.messageField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    

}


@end
