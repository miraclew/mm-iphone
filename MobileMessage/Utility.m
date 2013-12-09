//
//  Utility.m
//  HumorBooks
//
//  Created by yangw on 13-5-1.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "Utility.h"


NSString *hdGetDocumentPath(NSString *fileName)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if(fileName && ![fileName isEqualToString:@""])
        return   [documentsDirectory stringByAppendingPathComponent:fileName];
    return documentsDirectory;
}
