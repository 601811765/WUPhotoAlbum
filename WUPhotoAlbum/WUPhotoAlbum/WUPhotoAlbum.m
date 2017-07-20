//
//  WUPhotoAlbum.m
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/17.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import "WUPhotoAlbum.h"
#import "WUPhotoAlbumNavigationController.h"
#import "WUPhotoAlbumGroupsViewController.h"

@interface WUPhotoAlbum()

@property(nonatomic, strong) WUPhotoAlbumNavigationController *navigationController;

@end

@implementation WUPhotoAlbum

-(instancetype)init {
    self = [super init];
    if(self) {
        [self initialize];
    }
    return self;
}

-(instancetype)initWithConfiguration:(WUPhotoAlbumConfiguration *)configuration {
    self = [super init];
    if(self) {
        [self initialize];
    }
    
    return self;
}

-(void)initialize {
    self.navigationController = [[WUPhotoAlbumNavigationController alloc] init];
    
    WUPhotoAlbumConfiguration *configuration = [WUPhotoAlbumConfiguration shareConfiguration];
    if(configuration.titleTextAttributes)
        self.navigationController.navigationBar.titleTextAttributes = configuration.titleTextAttributes;
    
    if(configuration.barTintColor)
        self.navigationController.navigationBar.barTintColor = configuration.barTintColor;
    
    if(configuration.tintColor)
        self.navigationController.navigationBar.tintColor = configuration.tintColor;
    
    if(configuration.backIndicatorImage)
        self.navigationController.navigationBar.backIndicatorImage = configuration.backIndicatorImage;
    
    if(configuration.backIndicatorTransitionMaskImage)
        self.navigationController.navigationBar.backIndicatorTransitionMaskImage = configuration.backIndicatorTransitionMaskImage;
}

-(void)presentAlbumWithController:(UIViewController*)controller {
    
    WUPhotoAlbumConfiguration *configuration = [WUPhotoAlbumConfiguration shareConfiguration];
    
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if(authStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if(status == PHAuthorizationStatusAuthorized) {
                    [self openAlbumWithController:controller];
                } else {
                    if(configuration.delegate) {
                        [configuration.delegate photoAlbumAuthorizationFail:authStatus];
                    }
                }
            }];
            
        }];
    } else if(authStatus == PHAuthorizationStatusRestricted || authStatus == PHAuthorizationStatusDenied) {
        if(configuration.delegate) {
            [configuration.delegate photoAlbumAuthorizationFail:authStatus];
        }
    } else {
        [self openAlbumWithController:controller];
    }
}

-(void)openAlbumWithController:(UIViewController*)controller {
    WUPhotoAlbumGroupsViewController *groupsController = [[WUPhotoAlbumGroupsViewController alloc] init];
    [self.navigationController setViewControllers:@[groupsController]];
    
    [controller presentViewController:self.navigationController animated:YES completion:nil];
}

@end
