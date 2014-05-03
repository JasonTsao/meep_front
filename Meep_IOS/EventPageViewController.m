//
//  EventPageViewController.m
//  MeepIOS
//
//  Created by Ryan Sharp on 4/15/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "EventPageViewController.h"
#import "Event.h"

@interface EventPageViewController ()

@property (weak, nonatomic) IBOutlet UILabel *eventDescription;

@end

@implementation EventPageViewController
- (IBAction)closeModal:(id)sender {
    [_delegate closeEventModal];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(Event*) event
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *friend_name;
    Friend *selectedFriend;
    
    if(indexPath.section == 0){
        /*selectedFriend = selected_friends_list[indexPath.row];
        friend_name = selectedFriend.name;
        [tableView beginUpdates];
        [selected_friends_list removeObjectAtIndex: indexPath.row];
        [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]]
                         withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];*/
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
        numRows = [_invitedFriends count];
    }

    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventInvitedFriend"];
    
    if (indexPath.section == 0){
        Friend *currentFriend = _invitedFriends[indexPath.row];
        cell.textLabel.text = currentFriend.name;
    }
    
    return cell;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([_currentEvent.description length] > 15){
        self.title = [_currentEvent.description substringToIndex:15];
    }
    
    _eventDescription.text = _currentEvent.description;
    NSLog(@"invited_friends: %@", _invitedFriends);
    _eventDescription.text = _currentEvent.description;
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
