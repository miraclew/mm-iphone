//
//  UIImage+Stretch.m
//  VenusIphone
//
//  Created by yangwei on 13-4-3.
//  Copyright (c) 2013年 hoodinn. All rights reserved.
//

#import "UIImage+Stretch.h"
#import "UIImage+Stretch.h"

@implementation UIImage (Stretch)
+ (UIImage *)imageStretchWithCenterPointPixel:(NSString *)imageName {
	UIImage * image = [self imageNamed:imageName];
	if ([image respondsToSelector:@selector(stretchableImageWithLeftCapWidth:topCapHeight:)]) {
		image = [image stretchableImageWithLeftCapWidth:image.size.width/2-1 topCapHeight:image.size.height/2-1];
	}else {
		image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2-1, image.size.width/2-1, image.size.height/2-1, image.size.width/2-1)];
	}
	return image;
}

@end
