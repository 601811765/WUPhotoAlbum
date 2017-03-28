//
//  WUPhotoAlbum.h
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/17.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WUPhotoAlbumConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface WUPhotoAlbum : NSObject

-(instancetype)initWithConfiguration:(WUPhotoAlbumConfiguration*)configuration;

-(void)presentAlbumWithController:(UIViewController*)controller;

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
