//
//  main.m
//  MobileMessage
//
//  Created by yangw on 13-5-31.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "DebugView.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
#ifdef __i386__
        return UIApplicationMain(argc, argv, @"DebugViewApp", NSStringFromClass([AppDelegate class]));
#else
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
#endif        
    }
}
