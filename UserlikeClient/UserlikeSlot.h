//
//  UserlikeSlot.h
//  UserlikeClient
//
//  Created by David on 10/5/11.
//  Copyright 2011 Devcores. All rights reserved.
//


#import <Foundation/Foundation.h>

@class SocketIO;
@protocol SocketIODelegate;
@class UserlikeLocationController;;
@protocol UserlikeLocationControllerDelegate;


@protocol UserlikeSlotDelegate;

@interface UserlikeSlot : NSObject <SocketIODelegate,UserlikeLocationControllerDelegate>{
    SocketIO      *socketIO;
    id<UserlikeSlotDelegate> delegate;
    NSDictionary  *slot;
    NSDictionary  *operator;
    NSMutableDictionary *applicationConfig;
    NSMutableDictionary *applicationStorage;
	UserlikeLocationController *locationController;
    BOOL sendNotifications;
}

@property(nonatomic,assign) id<UserlikeSlotDelegate> delegate;
@property(nonatomic,copy) NSDictionary  *slot;
@property(nonatomic,copy) NSDictionary  *operator;
@property(nonatomic,retain) NSMutableDictionary  *applicationConfig;
@property(nonatomic,retain) NSMutableDictionary  *applicationStorage;
- (BOOL)prepareAndCheckConfig;
- (void)createNewChatSlot;
- (void)connectToChatServer;
- (void)disconnectFromChatServerWithNotification:(BOOL)notify;
- (void)sendChatMessage:(NSString*)bodyText;
@end

@protocol UserlikeSlotDelegate <NSObject>



@required
- (void)chatSlotAvailable:(BOOL)avail with:(NSString*)message;
- (void)receivedChatSlotWithMessage:(NSString*)message image:(NSString*)url;
- (void)receivedChatMessage:(NSString*)bodyText from:(NSString*)operatorName;

@optional
- (void)exitWithConfigError:(NSString*)errorMessage;
- (void)connectedToChatServer;
- (void)disconnectedFromChatServer:(NSString*)errorMessage;
- (void)chatServerConnectionError:(NSString*)errorMessage;
@end