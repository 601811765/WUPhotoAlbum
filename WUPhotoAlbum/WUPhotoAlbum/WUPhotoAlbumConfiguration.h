//
//  WUPhotoAlbumConfiguration.h
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/16.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "WUPhotoAlbumAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface WUPhotoAlbumGroupObject : NSObject

@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) PHAssetCollection *assetCollection;
@property(nonatomic, assign) NSUInteger count;

@end



@protocol WUPhotoAlbumDelegate <NSObject>

@required
-(void)photoAlbumSelectFinished:(NSArray<WUPhotoAlbumAsset*>*)assets;
-(void)photoAlbumAuthorizationFail:(PHAuthorizationStatus)authStatus;

@end

@interface WUPhotoAlbumConfiguration : NSObject

#pragma mark -UINavigationBar
@property(nonatomic, strong, nullable) NSDictionary<NSString*, id> *titleTextAttributes;
@property(nonatomic, strong, nullable) UIColor *barTintColor;
@property(nonatomic, strong, nullable) UIColor *tintColor;
@property(nonatomic, strong, nullable) UIImage *backIndicatorImage;
@property(nonatomic, strong, nullable) UIImage *backIndicatorTransitionMaskImage;

@property(nonatomic, strong) UIImage *selectImage;
@property(nonatomic, strong) UIImage *deSelectImage;

@property(nonatomic, strong, nullable) UIColor *backgroundColor;

#pragma mark -
@property(nonatomic, assign) NSUInteger maxSelecteCount;

#pragma mark -

@property(nonatomic, weak) id<WUPhotoAlbumDelegate> delegate;

+(nullable NSString*)localizableStringWithKey:(NSString*)key;
+(nullable UIImage *)imageWithKey:(NSString *)key;

+(instancetype)shareConfiguration;

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
