//
//  UIImage+WUPhotoAlbum.m
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/24.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import "UIImage+WUPhotoAlbum.h"

@implementation UIImage (WUPhotoAlbum)

-(CGRect)WUPhotoAlbum_rectAspectFitRectForSize:(CGSize)size {
    CGFloat targetAspect = size.width / size.height;
    CGFloat sourceAspect = self.size.width / self.size.height;
    CGRect rect = CGRectZero;
    if(targetAspect > sourceAspect) {
        rect.size.height = size.height;
        rect.size.width = ceilf(rect.size.height * sourceAspect);
        rect.origin.x = ceilf((size.width - rect.size.width) * 0.5);
    } else {
        rect.size.width = size.width;
        rect.size.height = ceilf(rect.size.width / sourceAspect);
        rect.origin.y = ceilf((size.height - rect.size.height) * 0.5);
    }
    return rect;
}

@end
