//
//  UserlikeClient
//
//  Created by David on 10/5/11.
//  Copyright 2011 Devcores. All rights reserved.
//
//  Based on PTConversation by Lasha Dolidze 
//  Copyright 2010 Picktek LLC. All rights reserved.

#import <UIKit/UIKit.h>
#import "UserlikeVIewController.h"

#define NAVIBAR_HEIGHT      44
@class UserlikeChatTableViewController;
@class UserlikeChatBarViewController;
@class MBProgressHUD;
@class UserlikeSlot;
@protocol MBProgressHUDDelegate;
@protocol UserlikeChatDelegate;
@protocol UserlikeSlotDelegate;
@protocol UserlikeChatTableViewControllerDelegate;
@protocol UserlikeChatBarViewControllerDelegate;


@interface UserlikeChatController : UserlikeVIewController <UserlikeChatTableViewControllerDelegate,UserlikeChatBarViewControllerDelegate,UIActionSheetDelegate,MBProgressHUDDelegate,UIAlertViewDelegate,UserlikeSlotDelegate> {

    
    UserlikeChatTableViewController   *chatTableViewController;
    UserlikeChatBarViewController      *chatBarViewController;
    UINavigationBar                     *navigationBar;
    id<UserlikeChatDelegate> delegate;
    UIView                              *_container;
    MBProgressHUD *HUD;
    BOOL chatVisible;
    NSMutableArray  *messages;
    UserlikeSlot *userlikeSlot;
}


@property(nonatomic,retain) UserlikeChatTableViewController *chatTableViewController;
@property(nonatomic,retain) UserlikeChatBarViewController *chatBarViewController;
@property(nonatomic,assign) id<UserlikeChatDelegate> delegate;
@property(nonatomic,assign) BOOL chatVisible;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) UserlikeSlot *userlikeSlot;

- (void)showNetworkActivityIndicator;
- (void)hideNetworkActivityIndicator;
    - (void) becomeEntryBar;
- (void) resignEntryBar;
- (void) showLastMessage:(BOOL)aimation;
- (void) reloadMessages;
- (void) showChatView;
- (void) leaveChatView; 
- (void) showProgress:(NSString*)text;
- (void) hideProgress;
- (void) alertAndLeave:(NSString*)text;
@end




@protocol UserlikeChatDelegate <NSObject>

@optional
- (void)chatDidFinish;
@end

