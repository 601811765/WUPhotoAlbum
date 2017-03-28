//
//  ViewController.m
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/16.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import "ViewController.h"
#import "WUPhotoAlbum.h"

@interface ViewController ()<WUPhotoAlbumDelegate>

@property(nonatomic, strong) UIButton *testButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _testButton = [[UIButton alloc] init];
    [_testButton setTitle:@"选择" forState:UIControlStateNormal];
    [_testButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_testButton setBackgroundColor:[UIColor redColor]];
    _testButton.layer.masksToBounds = YES;
    _testButton.layer.cornerRadius = 4;
    [_testButton addTarget:self action:@selector(testButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_testButton];
    
    [self makeConstraints];
}

-(void)makeConstraints {
    _testButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:_testButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:_testButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:_testButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:0 constant:200].active = YES;
    [NSLayoutConstraint constraintWithItem:_testButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:0 constant:44].active = YES;
}

-(void)testButtonTouchUpInside:(UIButton*)sender {
    
    WUPhotoAlbumConfiguration *configuration = [WUPhotoAlbumConfiguration shareConfiguration];
    configuration.maxSelecteCount = 3;
    configuration.delegate = self;
    
    WUPhotoAlbum *album = [[WUPhotoAlbum alloc] initWithConfiguration:configuration];
    [album presentAlbumWithController:self];
}

-(void)photoAlbumSelectFinished:(NSArray<WUPhotoAlbumAsset *> *)assets {
    NSLog(@"已选择：%@", assets);
}

-(void)photoAlbumAuthorizationFail:(PHAuthorizationStatus)authStatus {
    NSLog(@"授权失败");
}

@end
