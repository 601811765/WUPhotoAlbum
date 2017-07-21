//
//  WUPhotoAlbumPreviewViewController.m
//  WUPhotoAlbum
//
//  Created by 武探 on 2017/3/23.
//  Copyright © 2017年 wutan. All rights reserved.
//

#import "WUPhotoAlbumPreviewViewController.h"
#import "UIImage+WUPhotoAlbum.h"
#import "WUPhotoAlbumConfiguration.h"

#pragma mark - UIViewControllerAnimatedTransitioning

typedef void(^WUPhotoAlbumAnimatedBlcok)(void);

@interface WUPhotoAlbumPopAnimated : NSObject<UIViewControllerAnimatedTransitioning>

@property(nonatomic, copy) WUPhotoAlbumAnimatedBlcok animated;

@end

@implementation WUPhotoAlbumPopAnimated

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [[transitionContext containerView] insertSubview:toViewController.view atIndex:0];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.backgroundColor = [UIColor clearColor];
        if(self.animated) {
            self.animated();
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end





#define WUPhotoAlbumPreviewViewMargin 10
@class WUPhotoAlbumPreviewCell;
@protocol WUPhotoAlbumPreviewCellDelegate <NSObject>

@optional
-(void)albumPreviewCellTapHandler:(WUPhotoAlbumPreviewCell*)cell;

@end

@interface WUPhotoAlbumPreviewCell : UICollectionViewCell<UIScrollViewDelegate>

@property(nonatomic, strong) UIScrollView *imageScrollView;
@property(nonatomic, strong) UIImageView *imageView;

@property(nonatomic, weak) id<WUPhotoAlbumPreviewCellDelegate> delegate;

@end

@implementation WUPhotoAlbumPreviewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self initialize];
    }
    return self;
}

-(void)initialize {
    _imageScrollView = [[UIScrollView alloc] init];
    _imageScrollView.delegate = self;
    _imageScrollView.bounces = YES;
    _imageScrollView.maximumZoomScale = 2;
    _imageScrollView.minimumZoomScale = 1;
    [self.contentView addSubview:_imageScrollView];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.userInteractionEnabled = true;
    [_imageScrollView addSubview:_imageView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [_imageScrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [_imageView addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self layout];
}

-(void)layout {
    _imageScrollView.frame = CGRectMake(WUPhotoAlbumPreviewViewMargin, 0, CGRectGetWidth(self.frame) - 2 * WUPhotoAlbumPreviewViewMargin, CGRectGetHeight(self.frame));
    if(_imageView.image) {
        CGRect rect = [_imageView.image WUPhotoAlbum_rectAspectFitRectForSize:_imageScrollView.frame.size];
        _imageView.frame = rect;
    } else {
        _imageView.frame = _imageScrollView.bounds;
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.bounds.size.width > scrollView.contentSize.width ? (scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0.0;
    CGFloat offsetY = scrollView.bounds.size.height > scrollView.contentSize.height ? (scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0.0;
    _imageView.center = CGPointMake(scrollView.contentSize.width / 2 + offsetX, scrollView.contentSize.height / 2 + offsetY);
}

-(void)setImageZoom:(CGFloat)scale {
    [_imageScrollView setZoomScale:scale animated:NO];
}

#pragma -mark 点击图片

-(void)singleTap:(UIGestureRecognizer*)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(albumPreviewCellTapHandler:)]) {
        [self.delegate albumPreviewCellTapHandler:self];
    }
}

-(void)doubleTap:(UIGestureRecognizer*)sender {
    CGFloat scale = _imageScrollView.zoomScale;
    scale = scale < 2.0 ? 2.0 : 1;
    
    [_imageScrollView setZoomScale:scale animated:YES];
}


@end






@interface WUPhotoAlbumPreviewFlowLayout : UICollectionViewFlowLayout

@end

@implementation WUPhotoAlbumPreviewFlowLayout

@end







NSString *const WUPhotoAlbumPreviewViewCellIdentifier = @"WUPhotoAlbumPreviewViewCellIdentifier";

@interface WUPhotoAlbumPreviewViewController ()<UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WUPhotoAlbumPreviewCellDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIImageView *foregroundImageView;

@property(nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;

@property(nonatomic, strong) WUPhotoAlbumConfiguration *configuration;

@end

@implementation WUPhotoAlbumPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeComponent];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIViewController attemptRotationToDeviceOrientation];
        
    });
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
}

-(void)initializeComponent {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.configuration = [WUPhotoAlbumConfiguration shareConfiguration];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:self.configuration.deSelectImage style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTouch:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    WUPhotoAlbumPreviewFlowLayout *layout = [[WUPhotoAlbumPreviewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-WUPhotoAlbumPreviewViewMargin, 0, CGRectGetWidth(self.view.bounds) + 2 * WUPhotoAlbumPreviewViewMargin, CGRectGetHeight(self.view.bounds)) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.alwaysBounceVertical = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[WUPhotoAlbumPreviewCell class] forCellWithReuseIdentifier:WUPhotoAlbumPreviewViewCellIdentifier];
    [self.view addSubview:self.collectionView];
    
    [self makeConstraints];
    [self addInteractionRecognizer];
    [self animationShowForegroundImage];
    
    WUPhotoAlbumAsset *asset = self.assets[self.startIndex];
    [self changeRightBarImage:self.selectState(asset.tag)];
}

-(void)makeConstraints {
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:-WUPhotoAlbumPreviewViewMargin].active = YES;
    [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:WUPhotoAlbumPreviewViewMargin].active = YES;
}

-(void)animationShowForegroundImage {
    if(self.foregroundImage) {
        self.foregroundImageView = [[UIImageView alloc] initWithFrame:self.startAnimationScreenRect];
        self.foregroundImageView.image = self.foregroundImage;
        self.foregroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.foregroundImageView.clipsToBounds = YES;
        [self.view addSubview:self.foregroundImageView];
    }
    
    self.collectionView.hidden = YES;
    
    CGRect imageRect = [self.foregroundImage WUPhotoAlbum_rectAspectFitRectForSize:self.view.bounds.size];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.foregroundImageView.frame = imageRect;
    } completion:^(BOOL finished) {
        self.foregroundImageView.hidden = YES;
        self.collectionView.hidden = NO;
    }];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.startIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

#pragma mark barButtonItem

-(void)rightBarButtonTouch:(UIBarButtonItem *)sender {
    NSIndexPath *indexPath = [self.collectionView indexPathsForVisibleItems][0];
    WUPhotoAlbumAsset *asset = self.assets[indexPath.row];
    BOOL state = self.selectState(asset.tag);
    if(state) {
        [self changeRightBarImage:NO];
        self.selectItemHandler(asset.tag);
    } else {
        if(self.canSelect(asset.tag)) {
            self.selectItemHandler(asset.tag);
            [self changeRightBarImage:self.selectState(asset.tag)];
        } else {
            [self showSelectErrorMsg];
        }
    }
}

-(void)changeRightBarImage:(BOOL)selectState {
    if(selectState) {
        self.navigationItem.rightBarButtonItem.image = self.configuration.selectImage;
    } else {
        self.navigationItem.rightBarButtonItem.image = self.configuration.deSelectImage;
    }
}

-(void)showSelectErrorMsg {
    NSString *message = [NSString stringWithFormat:[WUPhotoAlbumConfiguration localizableStringWithKey:@"AlbumSelectErrorMsg"], self.configuration.maxSelecteCount];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[WUPhotoAlbumConfiguration localizableStringWithKey:@"OK"] style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - interaction

-(void)addInteractionRecognizer {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(interactionRecognizer:)];
    pan.delegate = self;
    [self.navigationController.view addGestureRecognizer:pan];
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if(![self isInterfaceOrientationPortrait]) {
        return NO;
    }
    
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer*)gestureRecognizer;
    CGPoint point = [pan translationInView:gestureRecognizer.view];
    if(point.y > 0) {
        return YES;
    }
    return NO;
}

-(BOOL)isInterfaceOrientationPortrait {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if(screenBounds.size.width > screenBounds.size.height) {
        return NO;
    }
    return YES;
}

-(void)interactionRecognizer:(UIPanGestureRecognizer*)recognizer {
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [self.navigationController setNavigationBarHidden:NO];
            
            self.interactiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [recognizer translationInView:self.view];
            CGFloat distance = fabs(translation.y / CGRectGetHeight(self.view.bounds));
            [self.interactiveTransition updateInteractiveTransition:distance];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            CGPoint translation = [recognizer velocityInView:self.view];
            if(translation.y > 0) {
                [self.interactiveTransition finishInteractiveTransition];
            } else {
                [self.interactiveTransition cancelInteractiveTransition];
                self.collectionView.hidden = NO;
                self.collectionView.backgroundColor = [UIColor clearColor];
            }
            self.interactiveTransition = nil;
        }
            break;
        default:
            break;
    }
}

#pragma mark - UINavigationControllerDelegate

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if(operation == UINavigationControllerOperationPop && [fromVC isEqual:self]) {
        if([self isInterfaceOrientationPortrait]) {
            WUPhotoAlbumPopAnimated *popAnimated = [[WUPhotoAlbumPopAnimated alloc] init];
            
            self.foregroundImageView.hidden = NO;
            self.collectionView.hidden = YES;
            WUPhotoAlbumPreviewCell *cell = (WUPhotoAlbumPreviewCell*)self.collectionView.visibleCells[0];
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            WUPhotoAlbumAsset *asset = self.assets[indexPath.row];
            self.foregroundImageView.image = cell.imageView.image;
            self.foregroundImageView.frame = [self.foregroundImageView.image WUPhotoAlbum_rectAspectFitRectForSize:self.view.bounds.size];
            popAnimated.animated = ^ {
                self.foregroundImageView.frame = self.willDismissBlock(asset.tag);
            };
            
            return popAnimated;
        }
    }
    return nil;
}

-(id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    return self.interactiveTransition;
}

#pragma mark - collectionView delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = collectionView.bounds.size;
    return size;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WUPhotoAlbumPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WUPhotoAlbumPreviewViewCellIdentifier forIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    WUPhotoAlbumPreviewCell *previewCell = (WUPhotoAlbumPreviewCell*)cell;
    [previewCell setImageZoom:1];
    previewCell.delegate = self;
    
    WUPhotoAlbumAsset *asset = self.assets[indexPath.row];
    
    __weak typeof(previewCell) weakCell = previewCell;
    [asset imageWithSize:cell.bounds.size completed:^(UIImage * _Nullable image) {
        
        __strong typeof(weakCell) strongCell = weakCell;
        strongCell.imageView.image = image;
        [strongCell layout];
    }];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger page = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    
    WUPhotoAlbumAsset *asset = self.assets[page];
    [self changeRightBarImage:self.selectState(asset.tag)];
}

#pragma mark - WUPhotoAlbumPreviewCellDelegate

-(void)albumPreviewCellTapHandler:(WUPhotoAlbumPreviewCell *)cell {
    BOOL isHiden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:!isHiden animated:NO];
    self.collectionView.backgroundColor = isHiden ? [UIColor clearColor] : [UIColor blackColor];
    [self setNeedsStatusBarAppearanceUpdate];
}

-(BOOL)prefersStatusBarHidden {
    return self.navigationController.navigationBarHidden;
}

#pragma mark -

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSInteger page = self.collectionView.contentOffset.x / CGRectGetWidth(self.collectionView.bounds);
 
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self.collectionView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(coordinator.transitionDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    });
}

#pragma mark -
-(BOOL)shouldAutorotate {
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}


@end
