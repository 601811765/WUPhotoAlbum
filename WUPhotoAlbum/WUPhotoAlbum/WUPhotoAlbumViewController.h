//
//  WUPhotoAlbumViewController.h
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/17.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "WUPhotoAlbumAsset.h"

@class WUPhotoAlbumConfiguration;
@class WUPhotoAlbumGroupObject;

NS_ASSUME_NONNULL_BEGIN

@interface WUPhotoAlbumViewController : UIViewController

@property(nonatomic, strong) WUPhotoAlbumGroupObject *group;

@property(nonatomic, strong, readonly, nullable) NSArray<WUPhotoAlbumAsset*> *selectedItems;

@end

NS_ASSUME_NONNULL_END
