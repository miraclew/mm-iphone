//
//  AppDelegate.h
//  MobileMessage
//
//  Created by yangw on 13-5-31.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobleData.h"
#import "SRWebSocket.h"

@class HomeViewController;
@class LoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,SRWebSocketDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GlobleData * globleData;
@property (strong, nonatomic) HomeViewController * rootViewController;
@property (strong, nonatomic) LoginViewController * loginViewController;

- (void)logInSuccess;

@end

AppDelegate * MMGetAppDelegate(void);
GlobleData * MMGetGlobleData(void);