//
//  MsgContentViewCell.h
//  MobileMessage
//
//  Created by yangw on 13-5-31.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	MsglViewCellTypeText = 0,
    MsglViewCellTypeVoice,
    MsglViewCellTypeImage,
}MsglViewCellType;


@interface MsgContentViewCell : UITableViewCell {
    UIView * _msgView; // 包含contact信息  头像 昵称 文本 媒体信息
    UILabel * _msgLabel;
    UIImageView * _msgImageView;
    UIImageView * _msgBgImageView;
}

@property (nonatomic, retain) UIImageView * headImageView;
@property (nonatomic, retain) UILabel * nickNameLabel;
@property (nonatomic, retain) UILabel * timeLabel;

- (void)setMsgText:(NSString *)str;

+ (CGFloat)cellHeight;

@end
