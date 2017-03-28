//
//  WUPhotoAlbumAsset.m
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/22.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import "WUPhotoAlbumAsset.h"

@implementation WUPhotoAlbumAsset

-(instancetype)initWithAsset:(PHAsset *)asset {
    self = [super init];
    if(self) {
        _asset = asset;
    }
    return self;
}

-(UIImage *)imageSynchronousWithSize:(CGSize)size {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    
    __block UIImage *image;
    
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:self.asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        image = result;
    }];
    
    return image;
}

-(void)imageWithSize:(CGSize)size completed:(void (^)(UIImage *image))completed {
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:self.asset targetSize:size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        completed(result);
    }];
}

-(void)dataOriginalWithCompleted:(void (^)(NSData *imageData))completed {
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageDataForAsset:self.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if(completed) {
            completed(imageData);
        }
    }];
}

-(void)setAssetPrivate:(PHAsset*)asset {
    _asset = asset;
}

-(id)copyWithZone:(NSZone *)zone {
    WUPhotoAlbumAsset *asset = [WUPhotoAlbumAsset allocWithZone:zone];
    [asset setAssetPrivate:self.asset];
    asset.tag = self.tag;
    return asset;
}

-(NSString *)description {
    NSString *oDesc = [super description];
    NSString *desc = [NSString stringWithFormat:@"%@ tag=%ld", oDesc, (long)self.tag];
    return desc;
}

@end
