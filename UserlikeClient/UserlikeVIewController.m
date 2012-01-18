//
//  UserlikeClient
//
//  Created by David on 10/5/11.
//  Copyright 2011 Devcores. All rights reserved.
//
//  Based on PTConversation by Lasha Dolidze 
//  Copyright 2010 Picktek LLC. All rights reserved.


#import "UserlikeVIewController.h"
#import "ULLog.h"

@interface UserlikeVIewController (Private)
- (void)resizeForKeyboard:(NSNotification*)notification appearing:(BOOL)appearing;
@end


@implementation UserlikeVIewController
@synthesize autoresizesForKeyboard = _autoresizesForKeyboard,
            isViewAppearing = _isViewAppearing;

- (id)init {
    if ((self = [super init])) {
        _autoresizesForKeyboard = NO;
    }
    return self;
}

- (void)awakeFromNib {
    [self init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    ULLog(@"");
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)dealloc {
    [super dealloc];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isViewAppearing = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isViewAppearing = NO;
}

#pragma mark -
#pragma mark Keyboard notification methods

- (void)keyboardWillShow:(NSNotification*)notification {
    if (self.isViewAppearing) {
        [self resizeForKeyboard:notification appearing:YES];
    }

    NSValue* value = [notification.userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
    CGRect keyboardBounds;
    [value getValue:&keyboardBounds];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    NSValue* value = [notification.userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
    CGRect keyboardBounds;
    [value getValue:&keyboardBounds];
    [self keyboardDidAppear:YES withBounds:keyboardBounds];
}

- (void)keyboardDidHide:(NSNotification*)notification {
    if (self.isViewAppearing) {
        [self resizeForKeyboard:notification appearing:NO];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSValue* value = [notification.userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
    CGRect keyboardBounds;
    [value getValue:&keyboardBounds];
    
    [self keyboardWillDisappear:YES withBounds:keyboardBounds];
}


- (void)setAutoresizesForKeyboard:(BOOL)autoresizesForKeyboard {
   
    if (autoresizesForKeyboard != _autoresizesForKeyboard) {
        _autoresizesForKeyboard = autoresizesForKeyboard;
   
        if (_autoresizesForKeyboard) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardWillShow:)
                                                         name:UIKeyboardWillShowNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardWillHide:)
                                                         name:UIKeyboardWillHideNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardDidShow:)
                                                         name:UIKeyboardDidShowNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardDidHide:)
                                                         name:UIKeyboardDidHideNotification
                                                       object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIKeyboardWillShowNotification
                                                          object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIKeyboardWillHideNotification
                                                          object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIKeyboardDidShowNotification
                                                          object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIKeyboardDidHideNotification
                                                          object:nil];
        }
    }
}

- (void)keyboardWillAppear:(BOOL)animated withBounds:(CGRect)bounds {
}

- (void)keyboardWillDisappear:(BOOL)animated withBounds:(CGRect)bounds {
}

- (void)keyboardDidAppear:(BOOL)animated withBounds:(CGRect)bounds {
}

- (void)keyboardDidDisappear:(BOOL)animated withBounds:(CGRect)bounds {
}


#pragma mark -
#pragma mark Private methods

- (void)resizeForKeyboard:(NSNotification*)notification appearing:(BOOL)appearing {
    NSValue* v1 = [notification.userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
    CGRect keyboardBounds;
    [v1 getValue:&keyboardBounds];
    
    NSValue* v2 = [notification.userInfo objectForKey:UIKeyboardCenterBeginUserInfoKey];
    CGPoint keyboardStart;
    [v2 getValue:&keyboardStart];
    
    NSValue* v3 = [notification.userInfo objectForKey:UIKeyboardCenterEndUserInfoKey];
    CGPoint keyboardEnd;
    [v3 getValue:&keyboardEnd];

    NSValue* v4 = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    double anim;
    [v4 getValue:&anim];
    
    BOOL animated = keyboardStart.y != keyboardEnd.y;
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:anim];
    }
    
    if (appearing) {
        [self keyboardWillAppear:animated withBounds:keyboardBounds];
    } else {
        [self keyboardDidDisappear:animated withBounds:keyboardBounds];
    }
    
    if (animated) {
        [UIView commitAnimations];
    }
}

@end
