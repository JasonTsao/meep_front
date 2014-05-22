//
//  InviteFriendsViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/1/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import "MEEPhttp.h"
#import "jsonPArser.h"
#import "Group.h"
#import "Friend.h"
#import "Colors.h"

#define TABLE_BACKGROUND_COLOR "FFFFFF"

#define TABLE_SECTION_HEADER_BACKGROUND_COLOR "FFFFFF"
#define TABLE_SECTION_HEADER_TEXT_COLOR "019875"

#define TABLE_DATA_BACKGROUND_COLOR "3FC380"
#define TABLE_DATA_TEXT_COLOR "FFFFFF"

#define CELL_SELECT_COLOR "89C4F4"

@interface InviteFriendsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *friendTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) NSIndexPath* selectedIndex;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *breakBar;

@end

@implementation InviteFriendsViewController{
    NSMutableArray *friends_list;
    NSMutableArray *selected_friends_list;
    NSMutableArray *search_friends_list;
    NSMutableArray *groups_list;
    Group * selectedGroup;
    dispatch_queue_t networkQueue;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)backToMain:(id)sender {
    [self.delegate backToCenterFromCreateEvent:self];
}


- (void)getGroupList
{
    NSString * requestURL = [NSString stringWithFormat:@"%@group/list",[MEEPhttp accountURL]];
    NSDictionary * postDict = [[NSDictionary alloc] init];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}


- (void)getFriendsList
{
    NSString * requestURL = [NSString stringWithFormat:@"%@friends/list",[MEEPhttp accountURL]];
    NSLog(@"request url : %@", requestURL);
    NSDictionary * postDict = [[NSDictionary alloc] init];
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
    
    if ([jsonResponse objectForKey:@"groups"] != nil){
        NSArray * groups = jsonResponse[@"groups"];
        groups_list = [jsonParser groupsArray:groups];
    }
    else{
        NSArray * friends = jsonResponse[@"friends"];
        friends_list = [jsonParser friendsArray:friends];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:friends_list];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"friends_list"];
        [NSUserDefaults resetStandardUserDefaults];
    }
    
    [self.friendTable reloadData];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *friend_name;
    Friend *selectedFriend;
    
    NSString *classType = [NSString stringWithFormat:@"%@",[tableView class]];
    // if this is the search bar table
    if([classType isEqualToString:@"UISearchResultsTableView"] ){
        selectedFriend = search_friends_list[indexPath.row];
        friend_name = selectedFriend.name;
        if (![selected_friends_list containsObject:selectedFriend]){
            [selected_friends_list addObject:selectedFriend];
        }
        else{
            NSInteger deleteRow = [selected_friends_list indexOfObject:selectedFriend];
            [selected_friends_list removeObjectAtIndex: deleteRow];
        }
        [_collectionView reloadData];
        [tableView reloadData];
        [self.searchDisplayController setActive:NO animated:YES];
    }
    else{
        if (indexPath.section == 1){
            UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
            selectedFriend = friends_list[indexPath.row];
            friend_name = selectedFriend.name;
            if (![selected_friends_list containsObject:selectedFriend]){
                [selected_friends_list addObject:selectedFriend];
            }
            else{
                NSInteger deleteRow = [selected_friends_list indexOfObject:selectedFriend];
                [selected_friends_list removeObjectAtIndex: deleteRow];
                [cell viewWithTag:1].backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_DATA_BACKGROUND_COLOR]];
            }
        }
        else if(indexPath.section == 0){
            selectedGroup = groups_list[indexPath.row];
            [self performSegueWithIdentifier:@"inviteFriendsToCreateMessage" sender:self];
        }
        [_collectionView reloadData];
        [tableView reloadData];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numSections = 0;
    NSString *classType = [NSString stringWithFormat:@"%@",[tableView class]];
    
    if([classType isEqualToString:@"UISearchResultsTableView"] ){
        numSections = 1;
    }
    else{
        numSections = 2;
    }
    return numSections;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *header;
    NSString *classType = [NSString stringWithFormat:@"%@",[tableView class]];
    if([classType isEqualToString:@"UISearchResultsTableView"] ){
        header = @"Friends";
    }
    else{
        if(section == 0){
            header = @"Groups";
        }
        else if(section == 1){
            header = @"Contacts";
        }
    }
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width - 6, 20)];
    headerView.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_SECTION_HEADER_BACKGROUND_COLOR]];
    UIView * lineSeparatorMask = [[UIView alloc] initWithFrame:CGRectMake(0, (tableView.sectionHeaderHeight * 4)-1, headerView.frame.size.width, 1)];
    lineSeparatorMask.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BACKGROUND_COLOR]];
    [headerView addSubview:lineSeparatorMask];
    UILabel * headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width - 6, 20)];
    headerTitle.text = header;
    headerTitle.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_SECTION_HEADER_TEXT_COLOR]];
    headerTitle.textAlignment = NSTextAlignmentRight;
    [headerView addSubview:headerTitle];
    return headerView;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    NSString *classType = [NSString stringWithFormat:@"%@",[tableView class]];
    if([classType isEqualToString:@"UISearchResultsTableView"] ){
        header = @"Friends";
    }
    else{
        if(section == 0){
            header = @"Groups";
        }
        else if(section == 1){
            header = @"Friends";
        }
    }
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 1;
    
    NSString *classType = [NSString stringWithFormat:@"%@",[tableView class]];
    
    if([classType isEqualToString:@"UISearchResultsTableView"] ){
        numRows = [search_friends_list count];
    }
    else{
        if(section == 0){
            numRows = [groups_list count];
        }
        else if(section == 1){
            numRows = [friends_list count];
        }
    }
    
    return numRows;
}

- (UITableViewCell*)clearCell:(UITableViewCell *)cell{
    for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

+ (UITableViewCell*) createCustomFriendCell:(Friend*)friend
                                   forTable:(UITableView*)tableView
                                   selected:(BOOL)sel {
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 54)];
    cell.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BACKGROUND_COLOR]];
    UIView * lineMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1)];
    lineMask.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BACKGROUND_COLOR]];
    [cell addSubview:lineMask];
    UIView * cellContents = [[UIView alloc] initWithFrame:CGRectMake(3, 3, cell.frame.size.width - 6, cell.frame.size.height + 6)];
    if (!sel) {
        cellContents.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_DATA_BACKGROUND_COLOR]];
    }
    else {
        cellContents.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",CELL_SELECT_COLOR]];
    }
    cellContents.layer.cornerRadius = 10;
    UILabel *friendHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 14, 235, 21)];
    friendHeader.text = friend.name;
    friendHeader.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_DATA_TEXT_COLOR]];
    [friendHeader setFont:[UIFont systemFontOfSize:18]];
    [cellContents addSubview:friendHeader];
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
    img.image = friend.profilePic;
    img.layer.cornerRadius = img.frame.size.height/2;
    img.layer.masksToBounds = YES;
    [cellContents addSubview:img];
    [cell addSubview:cellContents];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    
    NSString *classType = [NSString stringWithFormat:@"%@",[tableView class]];
    if([classType isEqualToString:@"UISearchResultsTableView"] ){
        //cell = [[UITableViewCell alloc]init];
        cell = [self clearCell:cell];
        Friend *currentFriend = search_friends_list[indexPath.row];
        //cell.textLabel.text = currentFriend.name;
        UILabel *friendHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 235, 21)];
        friendHeader.text = currentFriend.name;
        [friendHeader setFont:[UIFont systemFontOfSize:18]];
        [cell.contentView addSubview:friendHeader];
        
        UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
        img.image = currentFriend.profilePic;
        img.layer.cornerRadius = img.frame.size.height/2;
        img.layer.masksToBounds = YES;
        [cell.contentView addSubview:img];
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"selectFriendCell"];
        cell = [self clearCell:cell];
        UIView * lineSeparatorMask = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height-1, cell.frame.size.width, 1)];
        lineSeparatorMask.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BACKGROUND_COLOR]];
        [cell addSubview:lineSeparatorMask];
        UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(3, 3, tableView.frame.size.width - 6, cell.frame.size.height - 6)];
        contentView.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_DATA_BACKGROUND_COLOR]];
        contentView.layer.cornerRadius = 10;
        [contentView setTag:1];
        if (indexPath.section == 0){
            Group *currentGroup = groups_list[indexPath.row];
            UILabel *groupHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 14, 235, 21)];
            groupHeader.text = currentGroup.name;
            groupHeader.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_DATA_TEXT_COLOR]];
            [groupHeader setFont:[UIFont systemFontOfSize:18]];
            [contentView addSubview:groupHeader];
            UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
            img.image = currentGroup.groupProfilePic;
            img.layer.cornerRadius = img.frame.size.height/2;
            img.layer.masksToBounds = YES;
            [contentView addSubview:img];
            [cell addSubview:contentView];
        }
        else if (indexPath.section == 1){
            Friend *currentFriend = friends_list[indexPath.row];
            BOOL selected = NO;
            if ([selected_friends_list containsObject:currentFriend]) {
                selected = YES;
            }
            cell = [InviteFriendsViewController createCustomFriendCell:currentFriend forTable:tableView selected:selected];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // [cell addSubview:contentView];
    }
        
    
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    search_friends_list = [[NSMutableArray alloc] init];
    for( int i = 0; i < [friends_list count]; i++){
        if([[friends_list[i] name] hasPrefix:searchText]){
            [search_friends_list addObject:friends_list[i]];
        }
    }
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Invite Friends";
    friends_list = [[NSMutableArray alloc]init];
    selected_friends_list = [[NSMutableArray alloc]init];
    NSData *friendsListData = [[NSUserDefaults standardUserDefaults] objectForKey:@"friends_list"];
    NSMutableArray *user_friends_list = [NSKeyedUnarchiver unarchiveObjectWithData:friendsListData];
    self.friendTable.allowsMultipleSelectionDuringEditing=YES;
    if(!networkQueue){
        networkQueue = dispatch_queue_create("Network.Queue", NULL);
    }
    [self getFriendsList];
    [self getGroupList];
    if(!user_friends_list){
        //[self getFriendsList];
        //dispatch_async(networkQueue, ^{[self getFriendsList];});
    }
    else{
        //[self getFriendsList];
        //friends_list = user_friends_list;
    }
    friends_list = user_friends_list;
    // Do any additional setup after loading the view.
    _breakBar.backgroundColor = [Colors colorWithHexString:@"049372"];
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    CreateMessageViewController * createMessage = [segue destinationViewController];
    createMessage.invited_friends_list = selected_friends_list;
    createMessage.selectedGroup = selectedGroup;
    [createMessage setDelegate:self.delegate];
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [selected_friends_list removeObjectAtIndex:indexPath.row];
    [_collectionView reloadData];
    [_friendTable reloadData];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [selected_friends_list count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // UICollectionViewCell *cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(3, 3, collectionView.frame.size.height - 6, collectionView.frame.size.height - 6)];
    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"selectedFriendCollectionCell" forIndexPath:indexPath];
    for (UIView * subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    Friend * selectedFriend = selected_friends_list[indexPath.row];
    UIImageView * profilePicture = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, cell.frame.size.width - 4, cell.frame.size.width - 4)];
    profilePicture.image = selectedFriend.profilePic;
    profilePicture.layer.cornerRadius = profilePicture.frame.size.height/2;
    profilePicture.layer.masksToBounds = YES;
    [cell addSubview:profilePicture];
    UILabel * name = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.size.width - 4, cell.frame.size.width, 10)];
    name.text = selectedFriend.name;
    name.textAlignment = NSTextAlignmentCenter;
    name.backgroundColor = [Colors colorWithHexString:@"FFFFFF"];
    [name setFont:[UIFont systemFontOfSize:9]];
    [cell addSubview:name];
    return cell;
}

@end
