//
//  AppDelegate.m
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/16.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    ViewController *controller = [[ViewController alloc] init];
    self.window.rootViewController = controller;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}



@end
