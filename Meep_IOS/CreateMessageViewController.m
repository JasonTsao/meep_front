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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.parser = [[MEPTextParse alloc] init];
    [self.messageField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
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
