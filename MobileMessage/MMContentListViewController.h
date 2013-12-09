//
//  MMContentListViewController.h
//  MobileMessage
//
//  Created by yangw on 13-5-31.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDTableViewHelper.h"

@interface MMContentListViewController : UITableViewController <HDTableViewHelperDelegate> {
    HDTableViewHelper * _tableViewHelper;
    NSMutableArray * _dataArray;
}

@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int chatId;

@end
