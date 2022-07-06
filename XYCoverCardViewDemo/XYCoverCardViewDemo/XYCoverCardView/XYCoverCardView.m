//
//  XYCoverCardView.m
//  LNHealthWatch
//
//  Created by xiaoyan on 2021/11/17.
//  Copyright © 2021 ecsage. All rights reserved.
//

#import "XYCoverCardView.h"
#import "XYCoverCardCollectionView.h"

@interface XYCoverCardView () <UICollectionViewDataSource, UICollectionViewDelegate>
 
@property (nonatomic,strong) UIPageControl *pageControl;
 
@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation XYCoverCardView

- (void)removeFromSuperview {
    [super removeFromSuperview];
    
    [self removeTimer];
}


- (void)dealloc {
    NSLog(@"dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self setupUI];
    }
    return self;
}

- (void)setup {
    self.timerDuration = 2.0;
    self.movedDirectionType = XYMovedDirectionRight;
}

- (void)setupUI {
    
    XYCoverCardViewLayout *layout = [[XYCoverCardViewLayout alloc] init];
    layout.coverDirectionType = self.coverDirectionType;
    self.collectionView = [[XYCoverCardCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.clipsToBounds = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.collectionView addGestureRecognizer:panGesture];
    [self addSubview:self.collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}

- (void)registerCellClass:(Class)anyClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:anyClass forCellWithReuseIdentifier:identifier];
}

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(nonnull NSIndexPath *)indexPath {
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (void)reloadData {
    [self.collectionView reloadData];
    
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = [self.cardViewDataSource numberOfItemsInCoverCardView:self];
}

#pragma mark - setter
- (void)setCardViewDataSource:(id<XYCoverCardViewDataSource>)cardViewDataSource {
    _cardViewDataSource = cardViewDataSource;
    
    self.pageControl.numberOfPages = [self.cardViewDataSource numberOfItemsInCoverCardView:self];
    
    [self addTimer];
}

#pragma mark - 卡片的处理
- (void)insertCellsAtIndexPath:(NSArray *)indexPaths {
    [UIView performWithoutAnimation:^{
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
    }];
}

- (void)performBatchUpdates:(UpdatesBlock)updates completion:(Completion)completion {
    [self.collectionView performBatchUpdates:updates completion:completion];
}

// 滚动
- (void)nextPage:(XYMovedDirectionType)movedDirection {
    self.currentPage++;
    if (self.currentPage == 4) {
        self.currentPage = 0;
    }
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    CGFloat x = movedDirection == XYMovedDirectionLeft ? -200 : 200;
    [UIView animateWithDuration:0.25 animations:^{
        
        CGAffineTransform currentTransform = cell.transform;
        cell.transform = CGAffineTransformTranslate(currentTransform, x, 0);
    } completion:^(BOOL finished) {
        
        cell.hidden = YES;
        [self.cardViewDataSource coverCardView:self didRemoveCell:cell updateCallback:^ {
            cell.hidden = NO;
        }];
    }];
    
    self.pageControl.currentPage = self.currentPage;
}

#pragma mark - NSTimer
// 添加定时器
- (void)addTimer {

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.timerDuration target:self selector:@selector(aotuNextPage) userInfo:nil repeats:YES];
   // 添加到runloop中
   [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
   self.timer = timer;
}

// 删除定时器
- (void)removeTimer {

   [self.timer invalidate];
   self.timer = nil;
}

// 自动滚动
- (void)aotuNextPage {
    [self nextPage: self.movedDirectionType];
}

#pragma mark - 点击事件
- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture {
    // 获取到当前cell
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.movingPoint = CGPointZero;
            // 暂停
            [self removeTimer];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint movePoint = [panGesture translationInView:panGesture.view];
            // 只允许左右滑动
            if (movePoint.y > 20 || movePoint.y < -20) return;
            self.movingPoint = CGPointMake(self.movingPoint.x + movePoint.x, self.movingPoint.y);
            cell.transform = CGAffineTransformMakeTranslation(self.movingPoint.x, self.movingPoint.y);
            [panGesture setTranslation:CGPointZero inView:panGesture.view];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (self.movingPoint.x > 100) {
                // 右滑
                [self nextPage: XYMovedDirectionRight];
            } else if (self.movingPoint.x < -100) {
                // 左滑
                [self nextPage: XYMovedDirectionLeft];
            }
            
            else
            {
                [UIView animateWithDuration:0.25 animations:^{
                    // 还原到最初的状态
                    cell.transform = CGAffineTransformIdentity;
                }];
            }
            
            // 继续
            [self addTimer];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.cardViewDataSource numberOfItemsInCoverCardView:self];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cardViewDataSource coverCardView:self cellForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexPath.item ==== %zd", indexPath.item);
    if ([self.cardViewDataSource respondsToSelector:@selector(coverCardView:didSelectItemAtIndexPath:)]) {
        [self.cardViewDataSource coverCardView:self didSelectItemAtIndexPath:indexPath];
    }
}

#pragma mark - getter
//懒加载pageControl
- (UIPageControl *)pageControl {
 
    if (_pageControl == nil) {
        //分页控件，本质上和scorllView没有任何关系，是2个独立的控件
        _pageControl = [[UIPageControl alloc]init];
//        _pageControl.numberOfPages = 4;
        CGSize size = [_pageControl sizeForNumberOfPages:5];
        _pageControl.frame = CGRectMake((self.frame.size.width - size.width)/2, self.frame.size.height - size.height - 10, size.width, size.height);
        _pageControl.pageIndicatorTintColor = [UIColor yellowColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        [self addSubview:_pageControl];
 
    }
    return _pageControl;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
