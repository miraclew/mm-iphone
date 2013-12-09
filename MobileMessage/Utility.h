//
//  Utility.h
//  HumorBooks
//
//  Created by yangw on 13-5-1.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define FONT(a) [UIFont fontWithName:@"Arial" size:a]
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define ApplicationScreenHeight [[UIScreen mainScreen] bounds].size.height - 20
#define TabBarHeight 45.0
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

//
#define Base_URL  @"http://121.199.26.162/mm/api/"

NSString *hdGetDocumentPath(NSString *fileName);
