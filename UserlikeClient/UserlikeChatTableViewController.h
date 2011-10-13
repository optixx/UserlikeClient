//
//  UserlikeClient
//
//  Created by David on 10/5/11.
//  Copyright 2011 Devcores. All rights reserved.
//
//  Based on PTConversation by Lasha Dolidze 
//  Copyright 2010 Picktek LLC. All rights reserved.

#import <UIKit/UIKit.h>
#import "UserlikeChatMessage.h"
#import "UserlikeChatViewCell.h"

@protocol UserlikeChatTableViewControllerDelegate;

@interface UserlikeChatTableViewController : UITableViewController {

    id<UserlikeChatTableViewControllerDelegate>  delegate;
}

@property (nonatomic, assign) id<UserlikeChatTableViewControllerDelegate> delegate;
@end


@protocol UserlikeChatTableViewControllerDelegate <NSObject>
- (int)messageCount:(UserlikeChatTableViewController *)controller;
- (UserlikeChatMessage*)messageAt:(UserlikeChatTableViewController *)controller row:(int)row;
@end
