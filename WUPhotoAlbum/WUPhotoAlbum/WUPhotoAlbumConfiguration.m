//
//  WUPhotoAlbumConfiguration.m
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/16.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import "WUPhotoAlbumConfiguration.h"

#define WUPhotoAlbumBundleName @"WUPhotoAlbum"

@implementation WUPhotoAlbumGroupObject

@end

@implementation WUPhotoAlbumConfiguration

+(instancetype)shareConfiguration {
    static dispatch_once_t onceToken;
    static WUPhotoAlbumConfiguration *configuration;
    dispatch_once(&onceToken, ^{
        configuration = [[WUPhotoAlbumConfiguration alloc] initPrivate];
    });
    return configuration;
}

-(instancetype)initPrivate {
    self = [super init];
    if(self) {
        self.maxSelecteCount = 9;
        self.backgroundColor = [UIColor whiteColor];
        self.selectImage = [[WUPhotoAlbumConfiguration imageWithKey:@"WUPhotoAlbumChecked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.deSelectImage = [[WUPhotoAlbumConfiguration imageWithKey:@"WUPhotoAlbumChecked"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    return self;
}

+(NSString *)localizableStringWithKey:(NSString *)key {
    return NSLocalizedStringFromTable(key, @"WUPhotoAlbumLocalizable", nil);
}

+(UIImage *)imageWithKey:(NSString *)key {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:WUPhotoAlbumBundleName ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
//    int scale = (int)[[UIScreen mainScreen] scale];
//    NSString *path = [bundle pathForResource:[NSString stringWithFormat:@"%@@%dx", key, scale] ofType:@"png"];
//    UIImage *image = [UIImage imageWithContentsOfFile:path];
    UIImage *image = [UIImage imageNamed:key inBundle:bundle compatibleWithTraitCollection:nil];
    
    return image;
}

@end
