//
//  WUPhotoAlbumAsset.h
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/22.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface WUPhotoAlbumAsset : NSObject<NSCopying>

@property(nonatomic, strong, readonly) PHAsset *asset;
@property(nonatomic, assign) NSInteger tag;

-(instancetype)initWithAsset:(PHAsset*)asset;

-(nullable UIImage *)imageSynchronousWithSize:(CGSize)size;
-(void)imageWithSize:(CGSize)size completed:(void (^)(UIImage * _Nullable image))completed;
-(void)dataOriginalWithCompleted:(void (^)(NSData * _Nullable imageData))completed;

@end

NS_ASSUME_NONNULL_END
