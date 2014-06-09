//
//  CreateMessageViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/1/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "CreateMessageViewController.h"
#import "EventElementViewController.h"
#import "MEPTextParse.h"
#import "Colors.h"

#define TABLE_ROW_HEIGHT 25.0;
#define TABLE_BORDER_COLOR "F2F1EF"

@interface CreateMessageViewController () <EventElementViewControllerDelegate>
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

@property (nonatomic, strong) NSMutableArray * tableCellViews;

@property (nonatomic, assign) NSString * locationString;
@property (nonatomic, assign) NSString * dateString;
@property (nonatomic, assign) NSString * timeString;

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
    NSMutableDictionary * postDict;
    
    if([messageText length] > 0){
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
            postDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:messageText, @"description", invitedFriendsToSend, @"invited_friends", group_id,@"group_id", nil];
        }
        else{
            postDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:messageText, @"description", invitedFriendsToSend, @"invited_friends", nil];
        }
        if (![_locationString isEqualToString:@""]) {
            [postDict setObject:_locationString forKey:@"location_name"];
        }
        if (![_dateString isEqualToString:@""] && ![_timeString isEqualToString:@""]) {
            NSDateFormatter * df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSDateFormatter * parsingFormat = [[NSDateFormatter alloc] init];
            [parsingFormat setDateFormat:@"hh:mm a MMM dd, yyyy"];
            
            NSString * dateTimeString = [NSString stringWithFormat:@"%@ %@",_timeString, _dateString];
            NSDate * startDateTime = [parsingFormat dateFromString:dateTimeString];
            NSString * startDateTimeString = [df stringFromDate:startDateTime];
            [postDict setObject:startDateTimeString forKey:@"start_time"];
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
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message is empty!"
                                                        message:@"Please Write a message"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EventElementViewController * elem;
    if (indexPath.row == 0) {
        elem = [[EventElementViewController alloc] initWithNibName:@"LocationSearch" bundle:nil];
        elem.delegate = self;
        [self presentViewController:elem animated:YES completion:nil];
    }
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.sectionHeaderHeight)];
    header.backgroundColor = [UIColor blackColor];
    return header;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 1;
    if (section == 0){
        numRows = [_invited_friends_list count];
    }
    return 3;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        return TABLE_ROW_HEIGHT;
    }
    return 22;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"invitedFriendCell"];
    for (UIView * subview in cell.contentView.subviews) {
        if ([subview isKindOfClass:[UIView class]]) {
            [subview removeFromSuperview];
        }
    }
    UIView * cellView = [_tableCellViews objectAtIndex:indexPath.row];
    cell.frame = cellView.frame;
    [cell addSubview:cellView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void) textFieldDidChange {
    NSDictionary * contentDetails = [_parser parseText:[_messageField text]];
    BOOL reload = NO;
    if (_dateFieldEditable) {
        if ([contentDetails objectForKey:@"startDate"]) {
            _dateString = [contentDetails objectForKey:@"startDate"];
            [_tableCellViews setObject:[self dateRowViewForTarget:_dateString] atIndexedSubscript:2];
            reload = YES;
        }
        else {
            [self.dateField setText:@""];
        }
    }
    if (_timeFieldEditable) {
        if ([contentDetails objectForKey:@"startTime"]) {
            _timeString = [contentDetails objectForKey:@"startTime"];
            [_tableCellViews setObject:[self timeRowViewForTarget:_timeString] atIndexedSubscript:1];
            reload = YES;
        }
        else {
            [self.timeField setText:@""];
        }
    }
    if (_locationFieldEditable) {
        if ([contentDetails objectForKey:@"location"]) {
            _locationString = [contentDetails objectForKey:@"location"];
            [_tableCellViews setObject:[self locationRowViewForTarget:_locationString] atIndexedSubscript:0];
            reload = YES;
        }
        else {
            [self.locationField setText:@""];
        }
    }
    if (reload) {
        [self.invitedFriendsTable reloadData];
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
    
    /*
    if( _selectedGroup != nil){
        NSLog(@"selected group is not nil!!");
        [self getGroupMembers];
    }
     */
    self.messageField.delegate = self;
    [self.messageField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    // Do any additional setup after loading the view.
    self.parser = [[MEPTextParse alloc] init];
    self.parsedData = [[NSMutableDictionary alloc] init];
    self.locationFieldEditable = YES;
    self.timeFieldEditable = YES;
    self.dateFieldEditable = YES;
    [self setupTableRowArray];
    [self.invitedFriendsTable reloadData];
    [self.messageField becomeFirstResponder];
    _locationString = @"";
    _dateString = @"";
    _timeString = @"";
}

- (UIView*) locationRowViewForTarget:(NSString*)locationInfo {
    CGFloat tableHeight = TABLE_ROW_HEIGHT;
    UIColor * borderColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BORDER_COLOR]];
    
    UIView * verticalLine1 = [[UIView alloc] initWithFrame:CGRectMake(_invitedFriendsTable.frame.size.width*0.2, 0, 1, tableHeight)];
    verticalLine1.backgroundColor = borderColor;
    UIView * horizontalLine1 = [[UIView alloc] initWithFrame:CGRectMake(0, tableHeight, _invitedFriendsTable.frame.size.width, 1)];
    horizontalLine1.backgroundColor = borderColor;
    
    UIView * locationLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _invitedFriendsTable.frame.size.width, tableHeight)];
    
    locationLine.backgroundColor = [Colors colorWithHexString:@"FCFCFC"];
    
    UILabel * locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _invitedFriendsTable.frame.size.width * 0.2 - 3, tableHeight)];
    locationLabel.text = @"Place";
    locationLabel.textAlignment = NSTextAlignmentRight;
    [locationLabel setFont:[UIFont systemFontOfSize:14.0f]];
    UILabel * locationText = [[UILabel alloc] initWithFrame:CGRectMake((_invitedFriendsTable.frame.size.width/5) + 3, 0, (_invitedFriendsTable.frame.size.width*0.8) - 3, tableHeight)];
    locationText.textAlignment = NSTextAlignmentLeft;
    if (!(locationInfo == nil)) {
        locationText.text = locationInfo;
    }
    [locationText setFont:[UIFont fontWithName:@"AvenirNext-UltraLightItalic" size:14.0f]];
    [locationLine addSubview:locationLabel];
    [locationLine addSubview:locationText];
    [locationLine addSubview:verticalLine1];
    [locationLine addSubview:horizontalLine1];
    return locationLine;
}

- (UIView *) timeRowViewForTarget:(NSString*)timeInfo {
    CGFloat tableHeight = TABLE_ROW_HEIGHT;
    UIColor * borderColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BORDER_COLOR]];
    
    UIView * verticalLine2 = [[UIView alloc] initWithFrame:CGRectMake(_invitedFriendsTable.frame.size.width*0.2, 0, 1, tableHeight)];
    verticalLine2.backgroundColor = borderColor;
    UIView * horizontalLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, tableHeight, _invitedFriendsTable.frame.size.width, 1)];
    horizontalLine2.backgroundColor = borderColor;
    
    UIView * timeLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _invitedFriendsTable.frame.size.width, tableHeight)];
    timeLine.backgroundColor = [Colors colorWithHexString:@"FCFCFC"];
    UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _invitedFriendsTable.frame.size.width*0.2 - 3, tableHeight)];
    timeLabel.text = @"Time";
    timeLabel.textAlignment = NSTextAlignmentRight;
    [timeLabel setFont:[UIFont systemFontOfSize:14.0f]];
    UILabel * timeText = [[UILabel alloc] initWithFrame:CGRectMake(_invitedFriendsTable.frame.size.width/5 + 3, 0, _invitedFriendsTable.frame.size.width*0.8 - 3, tableHeight)];
    timeText.textAlignment = NSTextAlignmentLeft;
    if (!(timeInfo == nil)) {
        timeText.text = timeInfo;
    }
    [timeText setFont:[UIFont fontWithName:@"AvenirNext-UltraLightItalic" size:14.0f]];
    [timeLine addSubview:timeLabel];
    [timeLine addSubview:timeText];
    [timeLine addSubview:verticalLine2];
    [timeLine addSubview:horizontalLine2];
    return timeLine;
}

- (UIView *) dateRowViewForTarget:(NSString*)dateInfo {
    CGFloat tableHeight = TABLE_ROW_HEIGHT;
    UIColor * borderColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BORDER_COLOR]];
    
    UIView * verticalLine3 = [[UIView alloc] initWithFrame:CGRectMake(_invitedFriendsTable.frame.size.width*0.2, 0, 1, tableHeight)];
    verticalLine3.backgroundColor = borderColor;
    UIView * horizontalLine3 = [[UIView alloc] initWithFrame:CGRectMake(0, tableHeight, _invitedFriendsTable.frame.size.width, 1)];
    horizontalLine3.backgroundColor = borderColor;
    
    UIView * dateLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _invitedFriendsTable.frame.size.width, tableHeight)];
    dateLine.backgroundColor = [Colors colorWithHexString:@"FCFCFC"];
    UILabel * dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _invitedFriendsTable.frame.size.width/5 - 3, tableHeight)];
    dateLabel.text = @"Date";
    dateLabel.textAlignment = NSTextAlignmentRight;
    [dateLabel setFont:[UIFont systemFontOfSize:14.0f]];
    UILabel * dateText = [[UILabel alloc] initWithFrame:CGRectMake(_invitedFriendsTable.frame.size.width*0.2 + 3, 0, _invitedFriendsTable.frame.size.width*0.8 - 3, tableHeight)];
    dateText.textAlignment = NSTextAlignmentLeft;
    if (!(dateInfo == nil)) {
        dateText.text = dateInfo;
    }
    [dateText setFont:[UIFont fontWithName:@"AvenirNext-UltraLightItalic" size:14.0f]];
    [dateLine addSubview:dateLabel];
    [dateLine addSubview:dateText];
    [dateLine addSubview:verticalLine3];
    [dateLine addSubview:horizontalLine3];
    return dateLine;
}

- (void) setupTableRowArray {
    _tableCellViews = [[NSMutableArray alloc] init];
    
    UIView * locationLine = [self locationRowViewForTarget:nil];
    [_tableCellViews addObject:locationLine];
    
    UIView * timeLine = [self timeRowViewForTarget:nil];
    [_tableCellViews addObject:timeLine];
    
    UIView * dateLine = [self dateRowViewForTarget:nil];
    [_tableCellViews addObject:dateLine];
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
