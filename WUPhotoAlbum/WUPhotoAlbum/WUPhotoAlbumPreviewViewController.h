//
//  WUPhotoAlbumPreviewViewController.h
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/23.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WUPhotoAlbumAsset.h"

NS_ASSUME_NONNULL_BEGIN

typedef CGRect(^WUPhotoAlbumPreviewWillDismiss)(NSInteger imageIndex);
typedef BOOL(^WUPhotoAlbumPreviewSelectState)(NSInteger imageIndex);
typedef BOOL(^WUPhotoAlbumPreviewCanSelect)(NSInteger imageIndex);
typedef void(^WUPhotoAlbumPreviewSelectItemHandler)(NSInteger imageIndex);

@interface WUPhotoAlbumPreviewViewController : UIViewController

@property(nonatomic, strong) NSArray<WUPhotoAlbumAsset*> *assets;

/**
 push动画所需前景图片
 */
@property(nonatomic, strong) UIImage *foregroundImage;
/**
 push动画起始Rect
 */
@property(nonatomic, assign) CGRect startAnimationScreenRect;
/**
 初始显示的图片索引
 */
@property(nonatomic, assign) NSInteger startIndex;

@property(nonatomic, copy) WUPhotoAlbumPreviewWillDismiss willDismissBlock;
@property(nonatomic, copy) WUPhotoAlbumPreviewSelectState selectState;
@property(nonatomic, copy) WUPhotoAlbumPreviewCanSelect canSelect;
@property(nonatomic, copy) WUPhotoAlbumPreviewSelectItemHandler selectItemHandler;

@end

NS_ASSUME_NONNULL_END
