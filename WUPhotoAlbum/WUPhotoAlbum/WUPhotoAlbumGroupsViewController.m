//
//  WUPhotoAlbumGroupsViewController.m
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/17.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import "WUPhotoAlbumGroupsViewController.h"
#import <Photos/Photos.h>
#import "WUPhotoAlbumConfiguration.h"
#import "WUPhotoAlbumViewController.h"

@interface WUPhotoAlbumGroupCell : UITableViewCell

@property(nonatomic, strong) UIImageView *imView;
@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation WUPhotoAlbumGroupCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self initialize];
    }
    return self;
}

-(void)initialize {
    self.imView = [[UIImageView alloc] init];
    self.imView.contentMode = UIViewContentModeScaleAspectFill;
    self.imView.clipsToBounds = YES;
    [self.contentView addSubview:self.imView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:self.titleLabel];
    
    [self makeConstraints];
}

-(void)makeConstraints {
    UIView *view = self.contentView;
    
    self.imView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.imView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1 constant:5].active = YES;
    [NSLayoutConstraint constraintWithItem:self.imView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1 constant:15].active = YES;
    [NSLayoutConstraint constraintWithItem:self.imView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:-5].active = YES;
    [NSLayoutConstraint constraintWithItem:self.imView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:1 constant:-10].active = YES;
    
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.imView attribute:NSLayoutAttributeRight multiplier:1 constant:10].active = YES;
    [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1 constant:0].active = YES;
}

@end




NSString *const WUPhotoAlbumGroupCellIdentifier = @"WUPhotoAlbumGroupCellIdentifier";

@interface WUPhotoAlbumGroupsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray<WUPhotoAlbumGroupObject*> *groups;
@property(nonatomic, assign) CGFloat widthNormal;

@property(nonatomic, strong) WUPhotoAlbumConfiguration *configuration;

@end

@implementation WUPhotoAlbumGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeComponent];
}

-(void)initializeComponent {
    self.title = [WUPhotoAlbumConfiguration localizableStringWithKey:@"Album"];
    self.configuration = [WUPhotoAlbumConfiguration shareConfiguration];
    self.view.backgroundColor = self.configuration.backgroundColor;
    
    self.groups = [NSMutableArray array];
    self.widthNormal = 56;
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(rightBarButtonTouch:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 66;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[WUPhotoAlbumGroupCell class] forCellReuseIdentifier:WUPhotoAlbumGroupCellIdentifier];
    [self.view addSubview:self.tableView];
    
    [self makeConstraints];
    
    [self loadAlbumGroups];
}

-(void)makeConstraints {
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0].active = YES;
}

-(void)rightBarButtonTouch:(UIBarButtonItem*)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadAlbumGroups {
    
    [self.groups removeAllObjects];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PHFetchResult<PHAssetCollection *> *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        for (PHAssetCollection *collection in fetchResult) {
            WUPhotoAlbumGroupObject *groupItem = [self groupItemWithCollection:collection];
            if(groupItem) {
                if(collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                    [self.groups insertObject:groupItem atIndex:0];
                } else {
                    [self.groups addObject:groupItem];
                }
            }
        }
        
        PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        if(result && result.count > 0){
            for (PHAssetCollection *item in result) {
                WUPhotoAlbumGroupObject *groupItem = [self groupItemWithCollection:item];
                if(groupItem) {
                    [self.groups addObject:groupItem];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

-(WUPhotoAlbumGroupObject*)groupItemWithCollection:(PHAssetCollection*)assetCollection {
    
    WUPhotoAlbumGroupObject *groupItem = [[WUPhotoAlbumGroupObject alloc] init];
    
    groupItem.title = assetCollection.localizedTitle == nil ? @"" : assetCollection.localizedTitle;
    
    PHFetchResult<PHAsset*> *assetResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    if(!assetResult || assetResult.count == 0) {
        return nil;
    } else {
        groupItem.assetCollection = assetCollection;
        groupItem.count = assetResult.count;
    }
    
    PHAsset *asset = [assetResult lastObject];
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.synchronous = YES;
    PHImageManager *imageManager = [PHImageManager defaultManager];
    CGFloat width = self.widthNormal * [[UIScreen mainScreen] scale];
    [imageManager requestImageForAsset:asset targetSize:CGSizeMake(width, width) contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if(result) {
            groupItem.image = result;
        } else {
            groupItem.image = [[UIImage alloc] init];
        }
    }];
    
    return groupItem;
}

#pragma mark - UITableView delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WUPhotoAlbumGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:WUPhotoAlbumGroupCellIdentifier forIndexPath:indexPath];
    
    WUPhotoAlbumGroupObject *obj = self.groups[indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imView.image = obj.image;
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ (%lu)",obj.title,(unsigned long)obj.count];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WUPhotoAlbumGroupObject *group = self.groups[indexPath.row];

    WUPhotoAlbumViewController *albumController = [[WUPhotoAlbumViewController alloc] init];
    albumController.group = group;
    [self showViewController:albumController sender:nil];
}

#pragma mark -
-(BOOL)shouldAutorotate {
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
