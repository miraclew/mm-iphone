//
//  MMContactsViewController.h
//  MobileMessage
//
//  Created by yangw on 13-5-31.
//  Copyright (c) 2013年 yangw. All rights reserved.
//
// 联系人

#import <UIKit/UIKit.h>
#import "HDTableViewHelper.h"

@interface MMContactsViewController : UITableViewController <HDTableViewHelperDelegate> {
    HDTableViewHelper * _tableViewHelper;
    NSMutableArray * _dataArray;
}

@end
