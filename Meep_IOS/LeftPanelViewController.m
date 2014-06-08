//
//  LeftPanelViewController.m
//  SlideoutNavigation
//
//  Created by Tammy Coron on 1/10/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "LeftPanelViewController.h"
#import "DjangoAuthClient.h"
#import "Colors.h"

#define LEFTTEXTCOLOR "FFFFFF"
#define CELLBACKGROUNDCOLOR "34495e"
#define TABLEBACKGROUNDCOLOR "34495e"

@interface LeftPanelViewController ()

@property (nonatomic, weak) IBOutlet UITableView *myTableView;
@property (nonatomic, weak) IBOutlet UITableViewCell *cellMain;
@property (weak, nonatomic) IBOutlet UITableView *navTable;
@property(nonatomic, strong) DjangoAuthClient * authClient;
@property (nonatomic, strong) NSArray *navItems;
@property (nonatomic, strong) NSMutableArray *arrayOfAnimals;

@end

@implementation LeftPanelViewController
- (IBAction)openAccountSettings:(id)sender {
    [_delegate openAccountSettings];
}
- (IBAction)openFriendsListPage:(id)sender {
    [_delegate openFriendsListPage];
}

- (IBAction)openGroupsPage:(id)sender {
    [_delegate openGroupsPage];
}


- (IBAction)openAddFriendsPage:(id)sender {
    [_delegate openAddFriendsPage];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

/*-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 {
 NSString *header;
 
 if(section == 0){
 NSData *authenticated = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_client"];
 _authClient = [NSKeyedUnarchiver unarchiveObjectWithData:authenticated];
 header = _authClient.enc_username;
 }
 
 return header;
 }*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = [_navItems count];
    
    if(section == 0){
        numRows = 1;
    }
    else if(section == 1){
        numRows = numRows -1;
    }
    else{
        numRows = 1;
    }
    return numRows;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if( indexPath.section == 0){
        [_delegate openProfilePage];
    }
    
    if([_navItems[indexPath.row] isEqualToString:@"Groups"]){
        
    }
    
    if (indexPath.section == 1){
        NSLog(@"cell was 1");
        if(indexPath.row == 1){
            [_delegate openGroupsPage];
        }
        else if(indexPath.row == 2){
            [_delegate openFriendsListPage];
        }
        else if(indexPath.row == 3){
            [_delegate openAddFriendsPage];
        }
        else if(indexPath.row == 4){
            [_delegate openNotificationsPage];
        }
    }
    
    else if(indexPath.section == 2){
        if(indexPath.row == 0){
            [_delegate openAccountSettings];
        }
    }
    
}


-(void)openProfilePage:(id)sender{
    NSLog(@"in openprofile page sender");
    //[_delegate openProfilePage];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"navItem" forIndexPath:indexPath];
    //initWithFrame:CGRectMake(cell.bounds.size.width-10,-10,23,23) == top right
    
    UIColor * leftTextColor = [Colors colorWithHexString: [NSString stringWithFormat:@"%s",LEFTTEXTCOLOR]];
    UIColor * cellBackgroundColor = [Colors colorWithHexString: [NSString stringWithFormat:@"%s",CELLBACKGROUNDCOLOR]];
    
    cell.contentView.backgroundColor = cellBackgroundColor;
    //    cell.textLabel.backgroundColor = [UIColor blueColor];
    //    cell.textLabel.textColor = [UIColor blueColor];
    //    UIColor * XXX = [Colors colorWithHexString: [NSString stringWithFormat:@"%s",YYY]];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0){
        NSString *name;
        NSData *authenticated = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_client"];
        _authClient = [NSKeyedUnarchiver unarchiveObjectWithData:authenticated];
        name = _authClient.enc_username;
        
        //UILabel *userHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 235, 21)];
        UILabel *userHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 70, 21)];
        userHeader.text = name;
        [userHeader setFont:[UIFont systemFontOfSize:18]];
        userHeader.textColor = leftTextColor;
        
        userHeader.tag = 1;
        [cell.contentView addSubview:userHeader];
        
        //NEED TO ACTUALLY GET REAL PF PIC LATER!
        UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
        
        img.image = [UIImage imageNamed:@"ManSilhouette"];
        img.layer.cornerRadius = img.frame.size.height/2;
        img.layer.masksToBounds = YES;
        [cell.contentView addSubview:img];
    }
    else if(indexPath.section == 1){
        //cell.textLabel.text = _navItems[indexPath.row];
        UILabel *leftNavHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 120, 21)];
        leftNavHeader.text = _navItems[indexPath.row];
        [leftNavHeader setFont:[UIFont systemFontOfSize:18]];
        leftNavHeader.textColor = leftTextColor;
        [cell.contentView addSubview:leftNavHeader];
        
        UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
        
        if([_navItems[indexPath.row] isEqualToString:@"Search"] ){
            img.image = [UIImage imageNamed:@"search"];
        }
        else if([_navItems[indexPath.row] isEqualToString:@"Groups"] ){
            img.image = [UIImage imageNamed:@"groups"];
        }
        else if([_navItems[indexPath.row] isEqualToString:@"Home"] ){
            img.image = [UIImage imageNamed:@"home"];
        }
        else if([_navItems[indexPath.row] isEqualToString:@"Friends"] ){
            img.image = [UIImage imageNamed:@"friends"];
        }
        else if([_navItems[indexPath.row] isEqualToString:@"Notifications"] ){
            img.image = [UIImage imageNamed:@"notificationBell"];
        }
        img.layer.cornerRadius = img.frame.size.height/2;
        img.layer.masksToBounds = YES;
        [cell.contentView addSubview:img];
    }
    else if(indexPath.section == 2){
        NSInteger index = indexPath.row + 5;
        UILabel *settingsHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 120, 21)];
        settingsHeader.text = _navItems[index];
        [settingsHeader setFont:[UIFont systemFontOfSize:18]];
        settingsHeader.textColor = leftTextColor;
        [cell.contentView addSubview:settingsHeader];
        
        UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 22, 22)];
        img.image = [UIImage imageNamed:@"settings"];
        img.layer.cornerRadius = img.frame.size.height/2;
        img.layer.masksToBounds = YES;
        [cell.contentView addSubview:img];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section != 0){
        return 1;
    }
    return 0;
}


#pragma mark -
#pragma mark View Did Load/Unload

- (void)viewDidLoad
{
    UIColor * tableViewBackgroundColor = [Colors colorWithHexString: [NSString stringWithFormat:@"%s",TABLEBACKGROUNDCOLOR]];
    [super viewDidLoad];
    _navItems = [[NSArray alloc] initWithObjects:@"Home",@"Groups", @"Friends",@"Search", @"Notifications",@"Settings" ,nil];
    [self.navTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"navItem"];
    self.navTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navTable.backgroundColor = tableViewBackgroundColor;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark -
#pragma mark View Will/Did Appear

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark -
#pragma mark View Will/Did Disappear

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Default System Code

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
