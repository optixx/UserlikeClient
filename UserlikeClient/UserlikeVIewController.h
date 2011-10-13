//
//  UserlikeClient
//
//  Created by David on 10/5/11.
//  Copyright 2011 Devcores. All rights reserved.
//
//  Based on PTConversation by Lasha Dolidze 
//  Copyright 2010 Picktek LLC. All rights reserved.


#import <UIKit/UIKit.h>


@interface UserlikeVIewController : UIViewController {

    BOOL _autoresizesForKeyboard;
    BOOL _isViewAppearing;
}

@property(nonatomic,readonly) BOOL isViewAppearing;

@property(nonatomic) BOOL autoresizesForKeyboard;

- (void)keyboardWillAppear:(BOOL)animated withBounds:(CGRect)bounds;

- (void)keyboardWillDisappear:(BOOL)animated withBounds:(CGRect)bounds;

- (void)keyboardDidAppear:(BOOL)animated withBounds:(CGRect)bounds;

- (void)keyboardDidDisappear:(BOOL)animated withBounds:(CGRect)bounds;

@end
