//
//  DebugViewController.h
//  TestVoice
//
//  Created by  on 12-7-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __i386__

/*
usage:
 在main.m中，按下面的方式修改代码
 
 #ifdef __i386__
 return UIApplicationMain(argc, argv, @"DebugViewApp", NSStringFromClass([AppDelegate class]));
 #else
 return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
 #endif
*/

@interface DebugViewApp : UIApplication {
    
}
@end


@interface DebugView : UIView {
    UIView      *_topView;
    UIView      *_container;
    UIView      *_view;
	UILabel		*_label;
    
    struct {
        unsigned int help:1;
        unsigned int width:1;
        unsigned int cmdMode:1;
    } _switches;
    
    CGPoint     _offset;
	
	UniChar	_lastCode;
	int		_velocity;
	CGPoint _location;
	BOOL	_isMoved;
}

+ (DebugView*)sharedInstance;
- (BOOL)isStarted;
- (void)start:(UIView*)view;
- (void)stop;
- (void)inputChar:(UniChar)keyCode flag:(int)flag;
@end

#endif