//
//  WUPhotoAlbumNavigationController.m
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/16.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import "WUPhotoAlbumNavigationController.h"

@interface WUPhotoAlbumNavigationController ()

@end

@implementation WUPhotoAlbumNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark -
-(BOOL)shouldAutorotate {
    return self.childViewControllers.lastObject.shouldAutorotate;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.childViewControllers.lastObject.supportedInterfaceOrientations;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.childViewControllers.lastObject.preferredInterfaceOrientationForPresentation;
}

@end
