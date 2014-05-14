//
//  LeftPanelViewController.m
//  SlideoutNavigation
//
//  Created by Tammy Coron on 1/10/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "LeftPanelViewController.h"
#import "DjangoAuthClient.h"

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
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    
    if(section == 0){
        NSData *authenticated = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_client"];
        _authClient = [NSKeyedUnarchiver unarchiveObjectWithData:authenticated];
        NSLog(@"authclient is :%@", _authClient);
        NSLog(@"username is: %@", _authClient.enc_username);
        header = _authClient.enc_username;
    }
    
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = [_navItems count];
    
    if(section == 0){
        numRows = numRows -1;
    }
    else{
        numRows = 1;
    }
    return numRows;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0){
        if(indexPath.row == 1){
            [_delegate openGroupsPage];
        }
        else if(indexPath.row == 2){
            [_delegate openFriendsListPage];
        }
        else if(indexPath.row == 3){
            [_delegate openAddFriendsPage];
        }
    }
    
    else if(indexPath.section == 1){
        if(indexPath.row == 0){
            [_delegate openAccountSettings];
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"navItem" forIndexPath:indexPath];
    //initWithFrame:CGRectMake(cell.bounds.size.width-10,-10,23,23) == top right
    cell.contentView.backgroundColor = [UIColor darkGrayColor];
    cell.textLabel.backgroundColor = [UIColor darkGrayColor];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0){
        cell.textLabel.text = _navItems[indexPath.row];
    }
    else if(indexPath.section == 1){
        NSInteger index = indexPath.row + 4;
        cell.textLabel.text = _navItems[index] ;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 1;
}


#pragma mark -
#pragma mark View Did Load/Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    _navItems = [[NSArray alloc] initWithObjects:@"Home",@"Groups", @"Friends",@"Add Friends", @"Settings" ,nil];
    [self.navTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"navItem"];
    self.navTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
