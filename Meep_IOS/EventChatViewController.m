//
//  EventChatViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/17/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "EventChatViewController.h"

@interface EventChatViewController ()
@property (weak, nonatomic) IBOutlet UITextField *chatMessageToSend;
@property(nonatomic, strong) NSMutableArray *chatMessages;
@property (weak, nonatomic) IBOutlet UILabel *textAndButtonHolder;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UITableView *chatMessageTable;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textboxVerticalTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBoxTableConstraint;
@property (nonatomic, assign) BOOL keyboardShowed;
@end

@implementation EventChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)sendMessage:(id)sender {
    NSLog(@"%@", _chatMessageToSend.text);
}

- (void) observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void) keyboardWillShow:(NSNotification *)notification {
    if(_keyboardShowed)
        return;
    NSDictionary * info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    _keyboardHeight.constant = height;
    CGRect frameRect = self.textAndButtonHolder.frame;
    frameRect.size.height = (self.textAndButtonHolder.frame.size.height - height - 50);
    frameRect.origin = self.textAndButtonHolder.frame.origin;
    _textAndButtonHolder.frame = frameRect;
    
    CGRect textframeRect = self.chatMessageToSend.frame;
    //textframeRect.size.height = (self.chatMessageToSend.frame.size.height - height);
    textframeRect.origin.y = self.chatMessageToSend.frame.origin.y - height;
    _chatMessageToSend.frame = textframeRect;
    
    CGRect buttonframeRect = self.sendButton.frame;
    //textframeRect.size.height = (self.chatMessageToSend.frame.size.height - height);
    buttonframeRect.origin.y = self.sendButton.frame.origin.y - height;
    _sendButton.frame = buttonframeRect;
    
    CGRect tableFrameRect = self.chatMessageTable.frame;
    tableFrameRect.size.height = (self.chatMessageTable.frame.size.height - height - 50);
    tableFrameRect.origin = self.chatMessageTable.frame.origin;
    _chatMessageTable.frame = tableFrameRect;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    self.keyboardShowed = YES;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatMessage" forIndexPath:indexPath];
    
    //cell = [self clearCell:cell];

    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.keyboardShowed = NO;
    [self observeKeyboard];
    self.title = @"Chat";
    _chatMessages = [[NSMutableArray alloc] init];
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
