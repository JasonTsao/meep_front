//
//  EventChatViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/17/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "EventChatViewController.h"
#import "EventChatMessage.h"
#import "CenterViewController.h"
#import "Friend.h"
#import "DjangoAuthClient.h"
#import "MEEPhttp.h"

@interface EventChatViewController ()
@property (weak, nonatomic) IBOutlet UITextField *chatMessageToSend;
@property(nonatomic, strong) NSMutableArray *chatMessages;
@property (weak, nonatomic) IBOutlet UILabel *textAndButtonHolder;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UITableView *chatMessageTable;

@property(nonatomic, strong) DjangoAuthClient * authClient;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textboxVerticalTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBoxTableConstraint;
@property (nonatomic, assign) BOOL keyboardShowed;
@end

#define BORDER_COLOR "3FC380"
@implementation EventChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)putMessageOnTable:(NSString *)message
{
    EventChatMessage * chatMessage = [[EventChatMessage alloc] init];
    NSInteger creator_id = [_account_id integerValue];
    NSString *creator_name = _user_name;
    //NSString * currentTime = @"2014-05-15 04:33:22";
    
    NSLog(@"creator_id: %i", creator_id);
    chatMessage.event_id = _currentEvent.event_id;
    chatMessage.creator_id = creator_id;
    chatMessage.creator_name = creator_name;
    chatMessage.message = message;
    //chatMessage.time_stamp = currentTime;
    chatMessage.new_message = YES;
    
    //[_chatMessages addObject:chatMessage];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_chatMessages indexOfObject:chatMessage] inSection:0];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    
    
    [_chatMessageTable beginUpdates];
    [_chatMessages addObject:chatMessage];
    [_chatMessageTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_chatMessages indexOfObject:chatMessage] inSection:0]]
                     withRowAnimation:UITableViewRowAnimationFade];
    [_chatMessageTable endUpdates];
    NSLog(@"indexPath %@", indexPath);
    NSLog(@"indexPaths %@", indexPaths);
    
    /*[_chatMessageTable beginUpdates];
    [_chatMessageTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPaths] withRowAnimation:UITableViewRowAnimationBottom];
    [_chatMessageTable endUpdates];*/
    
    NSLog(@"updates to table complete");
}

- (void) getPreviousChats{
    NSString *event_id = [NSString stringWithFormat:@"%ld", _currentEvent.event_id];
    NSString * requestURL = [NSString stringWithFormat:@"%@chat_messages/%@",[MEEPhttp eventURL], event_id];
    NSDictionary * postDict = [[NSDictionary alloc] init];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (IBAction)sendMessage:(id)sender {
    NSLog(@"%@", _chatMessageToSend.text);
    NSString *event_id = [NSString stringWithFormat:@"%ld", _currentEvent.event_id];
    NSString * requestURL = [NSString stringWithFormat:@"%@chat_message/%@/new",[MEEPhttp eventURL], event_id];
    NSLog(@"create message request url:%@", requestURL);
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:_chatMessageToSend.text,@"message", nil];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
    [self putMessageOnTable:_chatMessageToSend.text];
    [_chatMessageToSend resignFirstResponder];
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
    
    if([jsonResponse objectForKey:@"chat_created"] != nil){
        NSLog(@"new chat created and saved on server!");
        NSInteger index = [_chatMessages count] - 1 ;
        EventChatMessage *newChatMessage = _chatMessages[index];
        newChatMessage.new_message = NO;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_chatMessages count] - 1 inSection:0];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.chatMessageTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    else if([jsonResponse objectForKey:@"comments"] != nil){
        NSArray *chatMessageArray = jsonResponse[@"comments"];
        
        for(int i = 0; i < [chatMessageArray count]; i++){
            EventChatMessage * message = [[EventChatMessage alloc] init];
            message.event_id = _currentEvent.event_id;
            message.creator_id = [chatMessageArray[i][@"creator_id"] integerValue];
            message.creator_name = chatMessageArray[i][@"creator_name"];
            message.message = chatMessageArray[i][@"message"];
            message.time_stamp = chatMessageArray[i][@"created"];
            
            [_chatMessages addObject:message];
        }
        [self.chatMessageTable reloadData];
    }
}

- (void) observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"pressed return!!");
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing: YES];
}

- (void) keyboardWillShow:(NSNotification *)notification {
    if(_keyboardShowed){
        NSLog(@"keyboard going away!!");
        NSDictionary * info = [notification userInfo];
        NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect keyboardFrame = [kbFrame CGRectValue];
        CGFloat height = keyboardFrame.size.height;
        _keyboardHeight.constant = height;
        CGRect frameRect = self.textAndButtonHolder.frame;
        frameRect.origin.y = self.textAndButtonHolder.frame.origin.y + height;
        _textAndButtonHolder.frame = frameRect;
        
        CGRect textframeRect = self.chatMessageToSend.frame;
        textframeRect.origin.y = self.chatMessageToSend.frame.origin.y + height;
        _chatMessageToSend.frame = textframeRect;
        
        CGRect buttonframeRect = self.sendButton.frame;
        //textframeRect.size.height = (self.chatMessageToSend.frame.size.height - height);
        buttonframeRect.origin.y = self.sendButton.frame.origin.y + height;
        _sendButton.frame = buttonframeRect;
        
        CGRect tableFrameRect = self.chatMessageTable.frame;
        tableFrameRect.size.height = (self.chatMessageTable.frame.size.height + (height/2));
        tableFrameRect.origin.y = self.chatMessageTable.frame.origin.y + (height/2);
        _chatMessageTable.frame = tableFrameRect;
        
        [UIView animateWithDuration:animationDuration animations:^{
            [self.view layoutIfNeeded];
        }];
        
        NSLog(@"keyboard now gone!");
        self.keyboardShowed = NO;
    }
    else{
        NSDictionary * info = [notification userInfo];
        NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect keyboardFrame = [kbFrame CGRectValue];
        CGFloat height = keyboardFrame.size.height;
        _keyboardHeight.constant = height;
        CGRect frameRect = self.textAndButtonHolder.frame;
        frameRect.origin.y = self.textAndButtonHolder.frame.origin.y - height;
        _textAndButtonHolder.frame = frameRect;
        
        CGRect textframeRect = self.chatMessageToSend.frame;
        textframeRect.origin.y = self.chatMessageToSend.frame.origin.y - height;
        _chatMessageToSend.frame = textframeRect;
        
        CGRect buttonframeRect = self.sendButton.frame;
        //textframeRect.size.height = (self.chatMessageToSend.frame.size.height - height);
        buttonframeRect.origin.y = self.sendButton.frame.origin.y - height;
        _sendButton.frame = buttonframeRect;
        
        CGRect tableFrameRect = self.chatMessageTable.frame;
        tableFrameRect.size.height = (self.chatMessageTable.frame.size.height - (height/2));
        tableFrameRect.origin.y = self.chatMessageTable.frame.origin.y - (height/2);
        _chatMessageTable.frame = tableFrameRect;
        
        [UIView animateWithDuration:animationDuration animations:^{
            [self.view layoutIfNeeded];
        }];
        self.keyboardShowed = YES;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_chatMessages count];
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
    CGFloat height;
    EventChatMessage *currentMessage = _chatMessages[indexPath.row];

    CGRect chatCell = self.chatMessageTable.frame;
    
    if( [currentMessage creator_id] != [_account_id integerValue]){
        chatCell.size.width = (self.chatMessageTable.frame.size.width - (self.chatMessageTable.frame.size.width/3) );
        chatCell.origin.x = 0.0;
    
    }else{
        chatCell.size.width = (self.chatMessageTable.frame.size.width - (self.chatMessageTable.frame.size.width/3) );
        chatCell.origin.x = (self.chatMessageTable.frame.size.width - (self.chatMessageTable.frame.size.width/3) );
    }
    
    
    CGSize expectedLabelSize = [[currentMessage message] sizeWithFont:[UIFont systemFontOfSize:13]
                                   constrainedToSize:chatCell.size
                                       lineBreakMode:UILineBreakModeWordWrap];

    
    if( [currentMessage creator_id] != [_account_id integerValue]){
        height = expectedLabelSize.height * 3;
    }
    else{
        height = expectedLabelSize.height * 2.5;
    }
    
    return height;
}


//NEED TO FIGURE OUT BETTER SPACING TO GET ALL TEXT WITHIN BOUNDS
- (CGSize) getMessageLabelSize:(NSInteger) messageLength withString:(NSString *)message isCreator:(BOOL)isCreator
{
    CGSize messageSize;
    
    CGRect chatCell = self.chatMessageTable.frame;
    
    if( isCreator){
        chatCell.size.width = (self.chatMessageTable.frame.size.width - (self.chatMessageTable.frame.size.width/3) );
        chatCell.origin.x = (self.chatMessageTable.frame.size.width - (self.chatMessageTable.frame.size.width/3) );
    }else{
        chatCell.size.width = (self.chatMessageTable.frame.size.width - (self.chatMessageTable.frame.size.width/3) );
        chatCell.origin.x = 35.0;
    }
    
    CGSize expectedLabelSize = [message sizeWithFont:[UIFont systemFontOfSize:13]
                                   constrainedToSize:chatCell.size
                                       lineBreakMode:UILineBreakModeWordWrap];
    
    if(expectedLabelSize.width < 15){
        expectedLabelSize.width = 15;
    }
    
    messageSize.width = expectedLabelSize.width;
    messageSize.height = expectedLabelSize.height;
    
    if( isCreator){
        messageSize.height = messageSize.height *1.3;
    }else{
        messageSize.height = messageSize.height *1.3;
    }

    if (messageSize.height < 31.018002){
        messageSize.height = 31;
    }

    return messageSize;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatMessage" forIndexPath:indexPath];

    cell = [self clearCell:cell];
    CGRect cellFrameRect = cell.contentView.frame;
    cellFrameRect.size.height = (cell.contentView.frame.size.height + 10 );
    cell.contentView.frame = cellFrameRect;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    EventChatMessage *currentMessage = _chatMessages[indexPath.row];
    NSInteger message_length = [currentMessage.message length];
    
    BOOL isCreator;
    if(currentMessage.creator_id == [_account_id integerValue]){
        isCreator = YES;
    }
    else{
        isCreator = NO;
    }
    CGSize messageSize = [self getMessageLabelSize:message_length withString:currentMessage.message isCreator:isCreator];
    
    NSInteger message_pixel_length = messageSize.width + 10;
    NSInteger message_pixel_height = messageSize.height;


    if( [currentMessage creator_id] != [_account_id integerValue]){
        
        UILabel *currentMessageHeader = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, message_pixel_length, message_pixel_height)];
        currentMessageHeader.textAlignment = NSTextAlignmentCenter;
        currentMessageHeader.layer.cornerRadius = 5;
        currentMessageHeader.layer.masksToBounds = YES;
        currentMessageHeader.lineBreakMode = UILineBreakModeWordWrap;
        currentMessageHeader.text = [currentMessage message];
        currentMessageHeader.backgroundColor = [UIColor lightGrayColor];
        
        
        [currentMessageHeader setFont:[UIFont systemFontOfSize:13]];
        [cell.contentView addSubview:currentMessageHeader];
        
        UILabel *messageCreatorName = [[UILabel alloc] initWithFrame:CGRectMake(35, -6, 100, 21)];
        messageCreatorName.text = [currentMessage creator_name];
        [messageCreatorName setTextColor:[UIColor lightGrayColor]];
        [messageCreatorName setFont:[UIFont systemFontOfSize:11]];
        [cell.contentView addSubview:messageCreatorName];
        
        UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, 25, 25)];
        img.image = [UIImage imageNamed:@"ManSilhouette"];
        img.layer.cornerRadius = img.frame.size.height/2;
        img.layer.masksToBounds = YES;

        //img.image = currentFriend.profilePic;
        [cell.contentView addSubview:img];
    }
    else{
        UILabel *currentMessageHeader = [[UILabel alloc] initWithFrame:CGRectMake(self.chatMessageTable.frame.size.width - (message_pixel_length) -  (self.chatMessageTable.frame.size.width/30), 0, message_pixel_length, message_pixel_height)];
        currentMessageHeader.textAlignment = NSTextAlignmentCenter;
        currentMessageHeader.layer.cornerRadius = 5;
        currentMessageHeader.layer.masksToBounds = YES;
        currentMessageHeader.lineBreakMode = UILineBreakModeWordWrap;
        
        if(currentMessage.new_message){
            UIColor *self_message_color = [UIColor whiteColor];
            currentMessageHeader.textColor = [CenterViewController colorWithHexString:[NSString stringWithFormat:@"%s",BORDER_COLOR]];
            currentMessageHeader.backgroundColor = self_message_color;
            currentMessageHeader.layer.borderColor = [[CenterViewController colorWithHexString:[NSString stringWithFormat:@"%s",BORDER_COLOR]]CGColor];
            currentMessageHeader.layer.borderWidth = 0.5;
        }
        else{
            UIColor *self_message_color = [CenterViewController colorWithHexString:[NSString stringWithFormat:@"%s",BORDER_COLOR]];
            currentMessageHeader.textColor = [UIColor whiteColor];
            currentMessageHeader.backgroundColor = self_message_color;
        }
        
        //UIColor *self_message_color = [CenterViewController colorWithHexString:[NSString stringWithFormat:@"%s",BORDER_COLOR]];

        currentMessageHeader.text = [currentMessage message];
        currentMessageHeader.numberOfLines = 0;
 
        [currentMessageHeader setFont:[UIFont systemFontOfSize:13]];
        
        
        [cell.contentView addSubview:currentMessageHeader];
        
    }

    return cell;
}
                                       


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.keyboardShowed = NO;
    [self observeKeyboard];
    self.title = @"Chat";
    _chatMessages = [[NSMutableArray alloc] init];
    
    NSData *authenticated = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_client"];
    _authClient = [NSKeyedUnarchiver unarchiveObjectWithData:authenticated];
    _account_id = _authClient.enc_userid;
    _user_name = _authClient.enc_username;
    
    [self getPreviousChats];
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
