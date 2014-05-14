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
@property (nonatomic, strong) NSMutableDictionary * parsedData;
@property (nonatomic, assign) BOOL timeFieldEditable;
@property (nonatomic, assign) BOOL dateFieldEditable;
@property (nonatomic, assign) BOOL locationFieldEditable;

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

- (void)getGroupMembers
{
    NSString * requestURL = [NSString stringWithFormat:@"%@group/%i/members",[MEEPhttp accountURL], _selectedGroup.group_id];
    NSDictionary * postDict = [[NSDictionary alloc] init];
    //NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"user", nil];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    _data = [[NSMutableData alloc] init]; // _data being an ivar
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [_data appendData:data];
}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Handle the error properly
    NSLog(@"Call Failed");
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [self handleData]; // Deal with the data
}

-(void)handleData{
    NSError* error;
    NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
    NSArray * members = jsonResponse[@"members"];
    _invited_friends_list = [[NSMutableArray alloc]init];
    for( int i = 0; i< [members count]; i++){
        Friend *new_friend = [[Friend alloc]init];
        
        NSDictionary * new_friend_dict = members[i];
        new_friend.name = new_friend_dict[@"user_name"];
        new_friend.bio = new_friend_dict[@"bio"];
        new_friend.account_id = [new_friend_dict[@"id"] intValue];
        
        /*NSURL *url = [[NSURL alloc] initWithString:new_friend_dict[@"fb_pfpic_url"]];
         //NSURL *url = [[NSURL alloc] initWithString:@"https://graph.facebook.com/jason.s.tsao/picture"];
         NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
         //NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:nil];
         NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
         UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
         new_friend.profilePic = image;
         NSLog(@"new friend pf pic %@", new_friend.profilePic);*/
        
        [_invited_friends_list addObject:new_friend];
    }
    
    [_invitedFriendsTable reloadData];
    
}


- (IBAction)createEvent:(id)sender {
    NSString *messageText = _messageField.text;
    NSLog(@"Message: %@", messageText);
    NSMutableArray *invitedFriendsToSend = [[NSMutableArray alloc] init];
    NSDictionary * postDict;
    
    for (int i = 0; i < [_invited_friends_list count]; i++){
        NSString *user_id = [NSString stringWithFormat: @"%i", [_invited_friends_list[i] account_id]];
        NSDictionary *friend_dict = [[NSDictionary alloc] initWithObjectsAndKeys:user_id,@"user_id", @"false", @"can_invite_friends", nil];
        [invitedFriendsToSend addObject:friend_dict];
        NSLog(@"invited friend: %i", [_invited_friends_list[i] account_id]);
    }
    
    NSString * requestURL = [NSString stringWithFormat:@"%@new",[MEEPhttp eventURL]];
    //NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"user", messageText, @"description", invitedFriendsToSend, @"invited_friends", nil];
    
    if(_selectedGroup != nil){
        // send group id to create event as well
        NSString *group_id = [NSString stringWithFormat:@"%i", _selectedGroup.group_id];
        postDict = [[NSDictionary alloc] initWithObjectsAndKeys:messageText, @"description", invitedFriendsToSend, @"invited_friends", group_id,@"group_id", nil];
    }
    else{
        postDict = [[NSDictionary alloc] initWithObjectsAndKeys:messageText, @"description", invitedFriendsToSend, @"invited_friends", nil];
    }

    
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData *return_data = [NSURLConnection sendSynchronousRequest:request
                                                returningResponse:&response
                                                            error:&error];
    
    NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:return_data options:0 error:&error];
    NSLog(@"jsonResponse: %@", jsonResponse);
    /*
    NSArray * success = jsonResponse[@"success"];
    NSMutableArray * return_invited_friends = jsonResponse[@"invited_friends"];
    NSMutableArray * invitedFriendsList = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [return_invited_friends count]; i++){
     
     InvitedFriend * invited_friend = [[InvitedFriend alloc] initWithName:[_invited_friends_list[i] name] withAccountID:return_invited_friends[i][@"user"] withAttending:return_invited_friends[i][@"attending"] withCanInvite:return_invited_friends[i][@"can_invite_friends"]];
     [invitedFriendsList addObject: invited_friend];
     }*/
    
    Event * newEvent = [[Event alloc] initWithDescription:jsonResponse[@"event"][@"description"] withName:jsonResponse[@"event"][@"name"] startTime:jsonResponse[@"event"][@"start_time"] eventId:[jsonResponse[@"event"][@"id"] integerValue]];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    EventPageViewController *eventPageViewController = (EventPageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"EventViewController"];
    eventPageViewController.currentEvent = newEvent;
    [eventPageViewController setDelegate:self.delegate];
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:eventPageViewController];
    [self presentViewController:navigation animated:YES completion:nil];
    //[self presentViewController:eventPageViewController animated:YES completion:nil];
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
        
        if( _selectedGroup != nil){
            header = _selectedGroup.name;
        }
        else{
            header = @"Invited";
        }
        
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
    if (_dateFieldEditable) {
        if ([contentDetails objectForKey:@"startDate"]) {
            [self.dateField setText:[contentDetails objectForKey:@"startDate"]];
        }
        else {
            [self.dateField setText:@""];
        }
    }
    if (_timeFieldEditable) {
        if ([contentDetails objectForKey:@"startTime"]) {
            [self.timeField setText:[contentDetails objectForKey:@"startTime"]];
        }
        else {
            [self.timeField setText:@""];
        }
    }
    if (_locationFieldEditable) {
        if ([contentDetails objectForKey:@"location"]) {
            [self.locationField setText:[contentDetails objectForKey:@"location"]];
        }
        else {
            [self.locationField setText:@""];
        }
    }
    NSLog(@"%@",contentDetails);
}

- (void) dateFieldDidChange {
    self.dateFieldEditable = NO;
}

- (void) timeFieldDidChange {
    self.timeFieldEditable = NO;
}

- (void) locationFieldDidChange {
    self.locationFieldEditable = NO;
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
    NSLog(@"group : %@", _selectedGroup.name);
    NSLog(@"selected groups : %@", _selectedGroup);
    
    if( _selectedGroup != nil){
        NSLog(@"selected group is not nil!!");
        [self getGroupMembers];
    }
    self.messageField.delegate = self;
    // Do any additional setup after loading the view.
    self.parser = [[MEPTextParse alloc] init];
    [self.messageField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    [self.dateField addTarget:self action:@selector(dateFieldDidChange) forControlEvents:UIControlEventAllEditingEvents];
    [self.timeField addTarget:self action:@selector(timeFieldDidChange) forControlEvents:UIControlEventAllEditingEvents];
    [self.locationField addTarget:self action:@selector(locationFieldDidChange) forControlEvents:UIControlEventAllEditingEvents];
    self.parsedData = [[NSMutableDictionary alloc] init];
    self.locationFieldEditable = YES;
    self.timeFieldEditable = YES;
    self.dateFieldEditable = YES;
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
