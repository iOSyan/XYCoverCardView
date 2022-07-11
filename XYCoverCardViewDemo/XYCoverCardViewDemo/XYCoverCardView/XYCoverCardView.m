//
//  XYCoverCardView.m
//  LNHealthWatch
//
//  Created by xiaoyan on 2021/11/17.
//  Copyright © 2021 ecsage. All rights reserved.
//

#import "XYCoverCardView.h"
#import "XYCoverCardCollectionView.h"

/// 划走的方向
typedef NS_ENUM(NSInteger, XYMovedDirectionType)
{
    XYMovedDirectionLeft,
    XYMovedDirectionRight,
};

@interface XYCoverCardView () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>
 
@property (nonatomic,strong) UIPageControl *pageControl;
 
@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger currentPage;

/// 正在操作
@property (nonatomic, assign) BOOL isMoving;

/// 正在滑回上一张
@property (nonatomic, assign) BOOL isReversing;

/// 划走的方向 - 固定向左
//@property (nonatomic, assign) XYMovedDirectionType movedDirectionType;

@property (nonatomic, strong)  UIPanGestureRecognizer *panGesture;

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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}

// MARK: - UI
- (void)setup {
    self.dataArray = [NSMutableArray array];
    
    self.timerDuration = 2.0;
}

- (void)setupUI {
    
    XYCoverCardViewLayout *layout = [[XYCoverCardViewLayout alloc] init];
    layout.coverDirectionType = self.coverDirectionType;
    self.collectionView = [[XYCoverCardCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.clipsToBounds = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self addSubview:self.collectionView];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
//    panGesture.delaysTouchesBegan = YES;
    panGesture.delegate = self;
    [self.collectionView addGestureRecognizer:panGesture];
    self.panGesture = panGesture;
}

- (void)refreshPageControlFrame {
    CGSize size = [self.pageControl sizeForNumberOfPages:self.pageControl.numberOfPages];
    self.pageControl.frame = CGRectMake((self.frame.size.width - size.width)/2, self.frame.size.height - size.height - 10, size.width, size.height);
    [self bringSubviewToFront:self.pageControl];
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
//    [self nextPage: self.movedDirectionType];
    self.isMoving = YES;
    // 固定方向
    [self nextPage: XYMovedDirectionLeft];
}

#pragma mark - CurrentPage
- (void)refreshCurrentPage {
    
    if (self.currentPage == -1) {
        self.currentPage = self.dataArray.count-1;
        if (self.isReversing) {
            self.currentPage = self.dataArray.count-2;
        }
    } else if (self.currentPage == self.dataArray.count) {
        self.currentPage = 0;
    }
}

#pragma mark - 手势
- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture {
    
    if (self.dataArray.count < 2) return;
    
    CGPoint movePoint = [panGesture translationInView:panGesture.view];
    
    // 获取到当前cell
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.movingPoint = CGPointZero;
            // 暂停
            [self removeTimer];
            // 上一张
            if (self.isCanReverse && movePoint.x >= 0 && !self.isReversing) {
                self.isReversing = YES;
                [self gestureRecognizerStateBeganWithReversing];
            }
            
            self.isMoving = YES;
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            
            // 只允许左右滑动
            if (movePoint.y > 20 || movePoint.y < -20) return;
            
            if (self.isCanReverse) {
                if (movePoint.x >= 0 && self.isReversing) { // 手势向右滑
                    // 卡片划的方向 -> 右 上一张
                    [self moveCell:cell toLastWithGesture:panGesture point:movePoint];
                }  else  {
                    // 手势向左滑
                    // 卡片划走的方向 -> 左 下一张
                    [self moveCell:cell toNextWithGesture:panGesture point:movePoint];
                }
            } else {
                // 下一张
                [self moveCell:cell toNextWithGesture:panGesture point:movePoint];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            
            if (self.isReversing) {
                if (self.movingPoint.x > 150) { // 右滑
                    // 上一张
                    [self lastPage: XYMovedDirectionRight];
                } else { // 左滑
                    // 卡片划走的方向 -> 左 下一张
                    [self nextPage: XYMovedDirectionLeft];
                }
                
            } else {
                [self gestureRecognizerStateEndedWithNoReversing];
            }
            
            // 继续
            [self addTimer];
        }
            break;
            
        default:
            break;
    }
}

// 手势开始 允许返回上一张的情况下
- (void)gestureRecognizerStateBeganWithReversing {
    
    id model = self.dataArray.lastObject;
    [self.dataArray insertObject:model atIndex:0];
    NSArray *indexes = @[[NSIndexPath indexPathForItem:0 inSection:0]];
    [self insertCellsAtIndexPath:indexes];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell *lastCell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect frame = lastCell.frame;
    frame.origin.x = -frame.size.width;
    lastCell.frame = frame;
//    lastCell.transform = CGAffineTransformMakeTranslation(-300, 0);
}

// 手势结束 不能返回上一张的情况下
- (void)gestureRecognizerStateEndedWithNoReversing {
    if (self.movingPoint.x > 50) { // 右滑
        if (self.isCanReverse) {
            [self resetOrigin];
        } else {
            // 卡片划走的方向 -> 右 下一张
            [self nextPage: XYMovedDirectionRight];
        }
    } else if (self.movingPoint.x < -100) { // 左滑
        // 卡片划走的方向 -> 左 下一张
        [self nextPage: XYMovedDirectionLeft];
    } else {
        [self resetOrigin];
    }
}

// 还原最初的位置
- (void)resetOrigin {
    // 获取到当前cell
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [UIView animateWithDuration:0.25 animations:^{
        // 还原到最初的状态
        cell.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.isMoving = NO;
    }];
}

#pragma mark - 卡片的处理
// 滑到上一张
- (void)moveCell:(UICollectionViewCell *)currentCell toLastWithGesture:(UIPanGestureRecognizer *)panGesture point:(CGPoint)movePoint {
    self.movingPoint = CGPointMake(self.movingPoint.x + movePoint.x, self.movingPoint.y);
    
//    // 取第一个cell
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    [self.collectionView bringSubviewToFront:cell];
    
//    cell.transform = CGAffineTransformMakeTranslation(self.movingPoint.x, self.movingPoint.y);
    CGRect frame = cell.frame;
    frame.origin.x = self.movingPoint.x-frame.size.width;
    cell.frame = frame;
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
}

// 滑到下一张
- (void)moveCell:(UICollectionViewCell *)cell toNextWithGesture:(UIPanGestureRecognizer *)panGesture point:(CGPoint)movePoint {
    self.movingPoint = CGPointMake(self.movingPoint.x + movePoint.x, self.movingPoint.y);
    cell.transform = CGAffineTransformMakeTranslation(self.movingPoint.x, self.movingPoint.y);
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
}

// 滚回到上一页
- (void)lastPage:(XYMovedDirectionType)movedDirection {
    
    if (self.dataArray.count < 2) return;
    
    self.currentPage--;
    [self refreshCurrentPage];
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = cell.frame;
        frame.origin.x = 0;
        cell.frame = frame;
    } completion:^(BOOL finished) {
        /// 移除cell之后, 调用此方法, 需要从数据源移除model
        [self.dataArray removeLastObject];
        
        [self performBatchUpdates:^{
            // 如果只有两个 是两个Indicator 没有items
            if (self.collectionView.subviews.count == 2) return;
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.dataArray.count inSection:0]]];
        } completion:^(BOOL finished) {
            self.isReversing = NO;
            self.isMoving = NO;
        }];
    }];
    
    self.pageControl.currentPage = self.currentPage;
}

// 滚动到下一页
- (void)nextPage:(XYMovedDirectionType)movedDirection {
//    self.isReversing = NO;
    
    if (self.dataArray.count < 2) return;
    
    if (!self.isReversing) {
        self.currentPage++;
    }
    [self refreshCurrentPage];
    
    CGFloat x = movedDirection == XYMovedDirectionLeft ? -300 : 300;
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cell.transform = CGAffineTransformTranslate(cell.transform, x, 0);
    } completion:^(BOOL finished) {
        
//        if (!self.isReversing) {
            cell.hidden = YES;
//        }
        
        /// 移除cell之后, 调用此方法, 需要从数据源移除model
        id model = self.dataArray[0];
        [self.dataArray removeObjectAtIndex:0];
        
        [self performBatchUpdates:^{
            // 如果只有两个 是两个Indicator 没有items
            if (self.collectionView.subviews.count == 2) return;
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
            
        } completion:^(BOOL finished) {
            if (!self.isReversing) {
                NSArray *indexes = @[[NSIndexPath indexPathForItem:self.dataArray.count inSection:0]];
                [self.dataArray addObject:model];
                    
                [self insertCellsAtIndexPath:indexes];
            }
            cell.hidden = NO;
            
            self.isReversing = NO;
            self.isMoving = NO;
        }];
    }];
    
    self.pageControl.currentPage = self.currentPage;
}

#pragma mark - UIGestureRecognizerDelegate
// 是否允许开始点击
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // 当上一个动画结束后才能点击
    return !self.isMoving;
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cardViewDataSource coverCardView:self cellForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cardViewDataSource respondsToSelector:@selector(coverCardView:didSelectItemAtIndexPath:)]) {
        [self.cardViewDataSource coverCardView:self didSelectItemAtIndexPath:indexPath];
    }
}

#pragma mark - Private
- (void)registerCellClass:(Class)anyClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:anyClass forCellWithReuseIdentifier:identifier];
}

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(nonnull NSIndexPath *)indexPath {
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (void)reloadData {
    [self.collectionView reloadData];
    
    self.pageControl.numberOfPages = self.dataArray.count;
    self.pageControl.currentPage = 0;
    [self refreshPageControlFrame];
}

#pragma mark collectionView update
- (void)insertCellsAtIndexPath:(NSArray *)indexPaths {
    [UIView performWithoutAnimation:^{
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
    }];
}

- (void)performBatchUpdates:(UpdatesBlock)updates completion:(Completion)completion {
    [self.collectionView performBatchUpdates:updates completion:completion];
}

#pragma mark - setter
- (void)setCardViewDataSource:(id<XYCoverCardViewDataSource>)cardViewDataSource {
    _cardViewDataSource = cardViewDataSource;
    
    [self addTimer];
}

- (void)setDataArray:(NSMutableArray *)dataArray {
    _dataArray = dataArray;
    
    self.pageControl.hidden = dataArray.count < 2;
    if (self.pageControl.hidden) return;
    
    self.pageControl.numberOfPages = dataArray.count;
    self.pageControl.currentPage = 0;
    [self refreshPageControlFrame];
}

#pragma mark - getter
//懒加载pageControl
- (UIPageControl *)pageControl {
 
    if (_pageControl == nil) {
        //分页控件，本质上和cardView没有任何关系，是2个独立的控件
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.pageIndicatorTintColor = [UIColor yellowColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        _pageControl.currentPage = 0;
        _pageControl.enabled = NO;
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
