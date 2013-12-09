//
//  MsgContentViewCell.m
//  MobileMessage
//
//  Created by yangw on 13-5-31.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "MsgContentViewCell.h"
#import "UIImage+Stretch.h"

@implementation MsgContentViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _msgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        [self.contentView addSubview:_msgView];
        
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 46, 46)];
        _headImageView.backgroundColor = [UIColor lightGrayColor];
        [_msgView addSubview:_headImageView];

        
        UIImage * image = [UIImage imageNamed:@"dial_talk_left01"];
        image = [image stretchableImageWithLeftCapWidth:30 topCapHeight:26];
        _msgBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 0, CGRectGetWidth(_msgView.frame)-70*2, image.size.height)];
        _msgBgImageView.image = image;
        [_msgView addSubview:_msgBgImageView];
        
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 155, 0)];
        _msgLabel.backgroundColor = [UIColor clearColor];
        _msgLabel.numberOfLines = 0;
        _msgLabel.textColor = [UIColor blackColor];
        _msgLabel.text = @"aaaaaaaaaaaaaaaaaaaaaaaaaakdjfadjlfaldkl;ajf;ajl;f";
        [self setMsgText:@"aaaaaaaaaaaaaaaaaaaaaaaaaakdjfadjlfaldkl;ajf;ajl;f"];
        [_msgBgImageView addSubview:_msgLabel];
        
        _msgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _msgImageView.backgroundColor = [UIColor clearColor];
        _msgImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_msgView addSubview:_msgImageView];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _msgView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

- (void)dealloc {
    [_msgView release];
    [_msgBgImageView release];
    [_msgImageView release];
    [_msgLabel release];
    [_headImageView release];
    [_nickNameLabel release];
    [_timeLabel release];
    [super dealloc];
}

- (void)setMsgText:(NSString *)str {
    if (str == nil) {
        str = @" ";
    }
    _msgLabel.text = str;
    CGSize size = [str sizeWithFont:_msgLabel.font constrainedToSize:CGSizeMake(CGRectGetWidth(_msgLabel.frame), 9999)];
    CGRect frame = _msgLabel.frame;
    frame.size = size;
    _msgLabel.frame = frame;
    frame.origin.x = 70;
    frame.origin.y = 0;
    frame.size = CGSizeMake(CGRectGetWidth(_msgView.frame)-70*2, MAX(size.height+20, _msgBgImageView.image.size.height));
    _msgBgImageView.frame = frame;
}

- (void)setCellIndex:(int)index type:(MsglViewCellType)viewType content:(NSDictionary *)dic {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight {
    return 100;
}

@end
