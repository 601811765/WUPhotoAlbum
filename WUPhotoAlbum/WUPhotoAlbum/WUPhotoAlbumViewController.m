//
//  WUPhotoAlbumViewController.m
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/17.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import "WUPhotoAlbumViewController.h"
#import "WUPhotoAlbumConfiguration.h"
#import "WUPhotoAlbumPreviewViewController.h"

@class WUPhotoAlbumCell;

@protocol WUPhotoAlbumCellDelegate <NSObject>

@required
-(void)albumCellSelectHandler:(WUPhotoAlbumCell*)cell;

@end

@interface WUPhotoAlbumCell : UICollectionViewCell

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIView *selectedFlagBackView;
@property(nonatomic, strong) UIImageView *selectedFlagView;

@property(nonatomic, weak) id<WUPhotoAlbumCellDelegate> delegate;

@end

@implementation WUPhotoAlbumCell

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self setSelectState:selected];
}

-(void)setSelectState:(BOOL)selectState {
    self.selectedFlagBackView.hidden = !selectState;
    
    WUPhotoAlbumConfiguration *configuration = [WUPhotoAlbumConfiguration shareConfiguration];
    
    UIImage *selectImage = selectState ? configuration.selectImage : configuration.deSelectImage;
    self.selectedFlagView.image = selectImage;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self initialize];
    }
    return self;
}

-(void)initialize {
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    
    self.selectedFlagBackView = [[UIView alloc] init];
    self.selectedFlagBackView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    self.selectedFlagBackView.hidden = YES;
    [self.contentView addSubview:self.selectedFlagBackView];
    
    self.selectedFlagView = [[UIImageView alloc] init];
    self.selectedFlagView.contentMode = UIViewContentModeCenter;
    self.selectedFlagView.image = [WUPhotoAlbumConfiguration imageWithKey:@"WUPhotoAlbumChecked"];
    self.selectedFlagView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.selectedFlagView];
    
    [self makeCosntraints];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectFlagViewTap:)];
    tap.numberOfTapsRequired = 1;
    [self.selectedFlagView addGestureRecognizer:tap];
}

-(void)makeCosntraints {
    UIView *view = self.contentView;
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1 constant:0].active = YES;
    
    self.selectedFlagBackView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.selectedFlagBackView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.selectedFlagBackView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.selectedFlagBackView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.selectedFlagBackView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1 constant:0].active = YES;
    
    self.selectedFlagView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.selectedFlagView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.selectedFlagView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.selectedFlagView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:40].active = YES;
    [NSLayoutConstraint constraintWithItem:self.selectedFlagView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:40].active = YES;
}

-(void)selectFlagViewTap:(UIGestureRecognizer*)recognizer {
    if(self.delegate) {
        [self.delegate albumCellSelectHandler:self];
    }
}

@end






@interface WUPhotoAlbumFlowLayout : UICollectionViewFlowLayout

@end

@implementation WUPhotoAlbumFlowLayout

@end








NSString *const WUPhtotAlbumCellIdentifier = @"WUPhtotAlbumCellIdentifier";

#define WUPhotoAlbumBottomToolbarHeight 44

@interface WUPhotoAlbumViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WUPhotoAlbumCellDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray<WUPhotoAlbumAsset*> *dataArray;

@property(nonatomic, assign) NSInteger columns;

@property(nonatomic, strong) UIToolbar *bottomToolbar;
@property(nonatomic, strong) UIBarButtonItem *previewBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *doneBarButtonItem;

@property(nonatomic, strong) WUPhotoAlbumConfiguration *configuration;

@end

@implementation WUPhotoAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeComponent];
}

-(void)initializeComponent {
    
    self.title = self.group.title;
    self.configuration = [WUPhotoAlbumConfiguration shareConfiguration];
    self.view.backgroundColor = self.configuration.backgroundColor;
    
    [self.navigationItem setValue:@"" forKey:@"backButtonTitle"];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(rightBarButtonTouch:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    self.dataArray = [NSMutableArray array];
    self.columns = 4;
    
    WUPhotoAlbumFlowLayout *layout = [[WUPhotoAlbumFlowLayout alloc] init];
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 2;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat width = (viewWidth - (self.columns - 1) * layout.minimumLineSpacing) / self.columns;
    layout.itemSize = CGSizeMake(width, width);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, WUPhotoAlbumBottomToolbarHeight, 0);
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, WUPhotoAlbumBottomToolbarHeight, 0);
    [self.collectionView registerClass:[WUPhotoAlbumCell class] forCellWithReuseIdentifier:WUPhtotAlbumCellIdentifier];
    [self.view addSubview:_collectionView];
    
    self.bottomToolbar = [[UIToolbar alloc] init];
    self.bottomToolbar.tintColor = [UIColor blackColor];
    self.previewBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[WUPhotoAlbumConfiguration localizableStringWithKey:@"Preview"] style:UIBarButtonItemStylePlain target:self action:@selector(previewBarButtonTouch:)];
    self.previewBarButtonItem.enabled = NO;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[WUPhotoAlbumConfiguration localizableStringWithKey:@"Done"] style:UIBarButtonItemStylePlain target:self action:@selector(doneBarButtonTouch:)];
    self.doneBarButtonItem.enabled = NO;
    [self.bottomToolbar setItems:@[self.previewBarButtonItem, flexibleSpace, self.doneBarButtonItem]];
    [self.view addSubview:self.bottomToolbar];
    
    [self makeConstraints];
    
    [self loadAlbumAsset];
}

-(void)makeConstraints {
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0].active = YES;
    
    self.bottomToolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.bottomToolbar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.bottomToolbar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.bottomToolbar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.bottomToolbar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:WUPhotoAlbumBottomToolbarHeight].active = YES;
}

#pragma mark - barButton Handler

-(void)rightBarButtonTouch:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)previewBarButtonTouch:(UIBarButtonItem *)sender {
    [self showPreview:nil];
}

-(void)doneBarButtonTouch:(UIBarButtonItem *)sender {
    NSArray<WUPhotoAlbumAsset*> *selectedItem = self.selectedItems;
    if(self.configuration.delegate) {
        [self.configuration.delegate photoAlbumSelectFinished:selectedItem];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Load Album
-(void)loadAlbumAsset {
    if(!self.group || !self.group.assetCollection) {
        return;
    }
    
    [self.dataArray removeAllObjects];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        __strong typeof(weakSelf) strongSelf = self;
        
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]];
        PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:strongSelf.group.assetCollection options:options];
        if(result && result.count > 0) {
            for (int i = 0; i < result.count; i++) {
                PHAsset *asset = result[i];
                WUPhotoAlbumAsset *albumAsset = [[WUPhotoAlbumAsset alloc] initWithAsset:asset];
                albumAsset.tag = i;
                [strongSelf.dataArray addObject:albumAsset];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.collectionView reloadData];
        });
        
    });
}

#pragma mark - UICollectionView delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0, 2);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WUPhotoAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WUPhtotAlbumCellIdentifier forIndexPath:indexPath];
    
    cell.delegate = self;
    
    WUPhotoAlbumAsset *asset = self.dataArray[indexPath.row];
    
    CGFloat width = CGRectGetWidth(cell.bounds) * 2;
    CGSize size = CGSizeMake(width, width);
    
    __weak typeof(cell) weakCell = cell;
    
    [asset imageWithSize:size completed:^(UIImage * _Nullable image) {
        __strong typeof(weakCell) strongCell = weakCell;
        strongCell.imageView.image = image;
    }];
    
    return cell;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    return NO;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    return NO;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self showPreview:indexPath];
}

#pragma mark -WUPhotoAlbumCell delegate

-(void)albumCellSelectHandler:(WUPhotoAlbumCell *)cell {
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    NSArray *selectedItems = [self.collectionView indexPathsForSelectedItems];
    
    if([selectedItems containsObject:indexPath]) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    } else {
        if(selectedItems.count + 1 > self.configuration.maxSelecteCount) {
            
            [self showSelectErrorMsg];
            return;
        } else {
            [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
    
    [self refreshBottomToolbar];
}

-(void)showSelectErrorMsg {
    NSString *message = [NSString stringWithFormat:[WUPhotoAlbumConfiguration localizableStringWithKey:@"AlbumSelectErrorMsg"], self.configuration.maxSelecteCount];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[WUPhotoAlbumConfiguration localizableStringWithKey:@"OK"] style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)refreshBottomToolbar {
    NSArray *selectedItems = [self.collectionView indexPathsForSelectedItems];
    BOOL isEnable = selectedItems.count > 0;
    self.previewBarButtonItem.enabled = isEnable;
    self.doneBarButtonItem.enabled = isEnable;
    
    NSString *doneTitle;
    
    if(selectedItems.count > 0) {
        doneTitle = [NSString stringWithFormat:@"%@(%lu)", [WUPhotoAlbumConfiguration localizableStringWithKey:@"Done"], (unsigned long)selectedItems.count];
    } else {
        doneTitle = [WUPhotoAlbumConfiguration localizableStringWithKey:@"Done"];
    }
    
    self.doneBarButtonItem.title = doneTitle;
}

#pragma mark -
-(NSArray<WUPhotoAlbumAsset *> *)selectedItems {
    NSArray *selectedItems = [self.collectionView indexPathsForSelectedItems];
    if(!selectedItems || selectedItems.count == 0) {
        return nil;
    }
    
    NSMutableArray *assetItems = [NSMutableArray array];
    for (NSIndexPath *indexPath in selectedItems) {
        WUPhotoAlbumAsset *assetItem = self.dataArray[indexPath.row];
        [assetItems addObject:assetItem];
    }
    
    NSArray *sortedArray = [assetItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        WUPhotoAlbumAsset *asset1 = (WUPhotoAlbumAsset*)obj1;
        WUPhotoAlbumAsset *asset2 = (WUPhotoAlbumAsset*)obj2;
        if(asset1.tag > asset2.tag) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    
    return sortedArray;
}

-(BOOL)isSelectedItem:(NSInteger)index {
    NSArray *selectedItems = [self.collectionView indexPathsForSelectedItems];
    if(selectedItems) {
        
        if([selectedItems containsObject:[NSIndexPath indexPathForRow:index inSection:0]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -

-(void)showPreview:(NSIndexPath*)indexPath {
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    WUPhotoAlbumAsset *asset = !indexPath ? self.selectedItems[0] : self.dataArray[indexPath.row];
    
    WUPhotoAlbumPreviewViewController *previewController = [[WUPhotoAlbumPreviewViewController alloc] init];
    
    if(!indexPath) {
        previewController.assets = self.selectedItems;
        previewController.startIndex = 0;
        previewController.appearAnimation = NO;
    } else {
        previewController.assets = self.dataArray;
        previewController.startIndex = indexPath.row;
        previewController.appearAnimation = YES;
    }
    previewController.startAnimationScreenRect = [self screenRectWithIndexPath:[NSIndexPath indexPathForRow:asset.tag inSection:0]];
    previewController.foregroundImage = [asset imageSynchronousWithSize:screenBounds.size];
    previewController.willDismissBlock = ^CGRect(NSInteger imageIndex) {
        return [self screenRectWithIndexPath:[NSIndexPath indexPathForRow:imageIndex inSection:0]];
    };
    previewController.selectState = ^BOOL(NSInteger imageIndex) {
        return [self isSelectedItem:imageIndex];
    };
    previewController.canSelect = ^BOOL(NSInteger imageIndex) {
        NSArray *selectedItems = [self.collectionView indexPathsForSelectedItems];
        if(selectedItems.count + 1 > self.configuration.maxSelecteCount) {
            
            return NO;
        }
        return YES;
    };
    previewController.selectItemHandler = ^(NSInteger imageIndex) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:imageIndex inSection:0];
        if([self isSelectedItem:indexPath.row]) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        } else {
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
        
        [self refreshBottomToolbar];
    };
    [self.navigationController pushViewController:previewController animated:NO];
}

-(CGRect)screenRectWithIndexPath:(NSIndexPath*)indexPath {
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    CGRect startRect = [cell convertRect:cell.contentView.frame toView:self.view];
    
    return startRect;
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
