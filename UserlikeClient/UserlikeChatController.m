//
//  UserlikeClient
//
//  Created by David on 10/5/11.
//  Copyright 2011 Devcores. All rights reserved.
//
//  Based on PTConversation by Lasha Dolidze 
//  Copyright 2010 Picktek LLC. All rights reserved.


#import "UserlikeVIewController.h"
#import "UserlikeChatTableViewController.h"
#import "UserlikeChatBarViewController.h"
#import "UserlikeChatController.h"
#import "MBProgressHUD.h"
#import "UserlikeSlot.h"

@interface UserlikeChatController (Private)
- (void)createProgressView;
@end

@implementation UserlikeChatController

@synthesize chatTableViewController;
@synthesize chatBarViewController;
@synthesize delegate;
@synthesize chatVisible;
@synthesize messages;
@synthesize userlikeSlot;


- (id)init {
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    messages = [[NSMutableArray alloc] init];
    chatVisible = NO;
    [self showProgress:NSLocalizedString(@"Connecting...",@"")];
    [self showNetworkActivityIndicator];
    
    userlikeSlot = [[UserlikeSlot alloc] init];
    userlikeSlot.delegate = self;
    [userlikeSlot connectToChatServer];
    return;
}   


- (void) showChatView {
    if (chatVisible){
        return;
    }
    chatVisible = YES;
    
    [self hideProgress];
    [self hideNetworkActivityIndicator];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.autoresizesForKeyboard = YES;
    CGRect rect = self.view.frame;

    // Initialize container
    _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
	navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, self.view.frame.size.width, NAVIBAR_HEIGHT)];
    navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIImage *userlikeLogo = [UIImage imageNamed:@"userlike_logo.png"];
    UIImageView *userlikeImageView = [ [ UIImageView alloc ] 
                              initWithFrame:CGRectMake((self.view.frame.size.width - userlikeLogo.size.width)/2 , 0.0, userlikeLogo.size.width, userlikeLogo.size.height) ];
	//userlikeImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    userlikeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    userlikeImageView.contentMode = UIViewContentModeCenter;
    
    [userlikeImageView setImage:userlikeLogo];
    [navigationBar addSubview:userlikeImageView];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                    style:UIBarButtonSystemItemDone 
                                                                  target:self
                                                                  action:@selector(leaveChatView)]; 
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    item.leftBarButtonItem = doneButton;
    item.hidesBackButton = YES;
    [navigationBar pushNavigationItem:item animated:NO];
    [doneButton release];
    [item release];
    [_container addSubview:navigationBar];
    
    
    // Create Conversation TableView
    chatTableViewController = [[UserlikeChatTableViewController alloc] initWithStyle:UITableViewStylePlain];
    chatTableViewController.tableView.frame = CGRectMake(0, NAVIBAR_HEIGHT, rect.size.width, rect.size.height - BAR_HEIGHT - NAVIBAR_HEIGHT);
    //conversationTableViewController.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    chatTableViewController.delegate = self;
    [_container addSubview:chatTableViewController.tableView];

    // Create Conversation Entry bar
    chatBarViewController = [[UserlikeChatBarViewController alloc] init];
    chatBarViewController.delegate = self;
    chatBarViewController.view.frame = CGRectMake(0, rect.size.height - BAR_HEIGHT, rect.size.width, BAR_HEIGHT);
    chatBarViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_container addSubview:chatBarViewController.view];
    
    [self.view addSubview:_container];
    [self becomeEntryBar];
    [self showLastMessage:NO];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark Keyboard Notification methods

- (void)keyboardDidAppear:(BOOL)animated withBounds:(CGRect)bounds {
    _container.frame = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, self.view.frame.size.height - bounds.size.height);
}

- (void)keyboardWillAppear:(BOOL)animated withBounds:(CGRect)bounds {
    // When keyboard appears resize view appropriately 
    _container.frame = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, self.view.frame.size.height - bounds.size.height);
}

- (void)keyboardDidDisappear:(BOOL)animated withBounds:(CGRect)bounds {
    _container.frame = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, self.view.frame.size.height + bounds.size.height);
}

#pragma mark -
#pragma mark Message Delegate methods

- (int)messageCount:(UserlikeChatTableViewController *)controller
{
    return [messages count];
}

- (UserlikeChatMessage*)messageAt:(UserlikeChatTableViewController *)controller row:(int)row
{
    return [messages objectAtIndex:row];
}

- (BOOL)touchSend:(UserlikeChatBarViewController *)controller text:(NSString*)text
{
    BOOL send = TRUE;
    [userlikeSlot sendChatMessage:text];
    UserlikeChatMessage *message = [UserlikeChatMessage initWithText:text type:UserlikeChatMessageTypeOperatorTerminating];
    [messages addObject:message];
    [self reloadMessages];
    [self showLastMessage:YES];
    [message release];
    return send;
}


#pragma mark -
#pragma mark Helper methods

- (void) becomeEntryBar {
    [self.chatBarViewController.textView becomeFirstResponder];
}

- (void) resignEntryBar {
    [self.chatBarViewController.textView resignFirstResponder];
}

- (void) showLastMessage:(BOOL)aimation
{
    int count = [messages count];
    UITableView *tView = self.chatTableViewController.tableView;
    if(count > 0) {
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:(count - 1) inSection:0];
        [tView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:aimation];
    }
}

- (void) reloadMessages
{
    UITableView *tView = self.chatTableViewController.tableView;
    [tView reloadData];
}

- (void)showNetworkActivityIndicator
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
}

- (void)hideNetworkActivityIndicator
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
}

- (void) showProgress:(NSString*)text
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = text;
}

- (void) hideProgress
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) leaveChatView
{
    [userlikeSlot disconnectFromChatServerWithNotification:NO];
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [self.delegate chatDidFinish];
}

- (void) alertAndLeave:(NSString*)text
{
    [self hideProgress];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Userlike" 
                                                    message:text
                                                   delegate:self 
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark -
#pragma mark UIAlertViewDelegate 

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [self.delegate chatDidFinish];
}

#pragma mark -
#pragma mark UserlikeSlotDelegate 

- (void)connectedToChatServer;
{
    UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
}

- (void)disconnectedFromChatServer:(NSString*)errorMessage
{
    
    [self alertAndLeave:errorMessage];
}

- (void)chatServerConnectionError:(NSString*)errorMessage
{
    [self alertAndLeave:errorMessage];
}

- (void)chatSlotAvailable:(BOOL)avail with:(NSString*)message
{
    if (!avail){
        [self alertAndLeave:message];
    } 
}

- (void)receivedChatSlotWithMessage:(NSString*)message image:(NSString*)url;
{
    [self showChatView];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    [messages addObject:[UserlikeChatMessage initWithText:message 
                                                       type:UserlikeChatMessageTypeClientTerminating
                                             operatorImage:image]];
    
    [self reloadMessages];
    [self showLastMessage:YES];
    
}

- (void)receivedChatMessage:(NSString*)bodyText from: (NSString* ) operatorName;
{
    [messages addObject:[UserlikeChatMessage initWithText:bodyText 
                                                       type:UserlikeChatMessageTypeClientTerminating]];
    
    [self reloadMessages];
    [self showLastMessage:YES];
    
}

#pragma mark -
#pragma mark Memory methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.chatTableViewController = nil;
    self.chatBarViewController = nil;
    self.autoresizesForKeyboard = NO;
}

- (void)dealloc {
    self.autoresizesForKeyboard = NO;
    [messages release];
    [chatBarViewController release];
    [chatTableViewController release];
    [navigationBar release];
    [_container release];
    [userlikeSlot release];
    [super dealloc];
}


@end
