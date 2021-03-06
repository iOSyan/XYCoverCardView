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

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self setupUI];
    }
    return self;
}

- (void)setup {
    self.dataArray = [NSMutableArray array];
    
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

- (void)removeFromSuperview {
    [super removeFromSuperview];
    
    [self removeTimer];
}

- (void)dealloc {
    NSLog(@"dealloc");
}

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

- (void)refreshPageControlFrame {
    CGSize size = [self.pageControl sizeForNumberOfPages:self.pageControl.numberOfPages];
    self.pageControl.frame = CGRectMake((self.frame.size.width - size.width)/2, self.frame.size.height - size.height - 10, size.width, size.height);
    [self bringSubviewToFront:self.pageControl];
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

#pragma mark - 卡片的处理
- (void)insertCellsAtIndexPath:(NSArray *)indexPaths {
    [UIView performWithoutAnimation:^{
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
    }];
}

- (void)performBatchUpdates:(UpdatesBlock)updates completion:(Completion)completion {
    [self.collectionView performBatchUpdates:updates completion:completion];
}

// 滑到下一张
- (void)moveCell:(UICollectionViewCell *)cell toNextWithGesture:(UIPanGestureRecognizer *)panGesture point:(CGPoint)movePoint {
    self.movingPoint = CGPointMake(self.movingPoint.x + movePoint.x, self.movingPoint.y);
    cell.transform = CGAffineTransformMakeTranslation(self.movingPoint.x, self.movingPoint.y);
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
}

// 滚动到下一页
- (void)nextPage:(XYMovedDirectionType)movedDirection {
    if (self.dataArray.count < 2) return;
    
    self.currentPage++;
    if (self.currentPage == self.dataArray.count) {
        self.currentPage = 0;
    }
    
    CGFloat x = movedDirection == XYMovedDirectionLeft ? -200 : 200;
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cell.transform = CGAffineTransformTranslate(cell.transform, x, 0);
    } completion:^(BOOL finished) {
        
        cell.hidden = YES;
        
        /// 移除cell之后, 调用此方法, 需要从数据源移除model
        id model = self.dataArray[0];
        [self.dataArray removeObjectAtIndex:0];
        
        [self performBatchUpdates:^{
            // 如果只有两个 是两个Indicator 没有items
            if (self.collectionView.subviews.count == 2) return;
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
            
        } completion:^(BOOL finished) {
            NSArray *indexes = @[[NSIndexPath indexPathForItem:self.dataArray.count inSection:0]];
            [self.dataArray addObject:model];
            
            [self insertCellsAtIndexPath:indexes];
            cell.hidden = NO;
        }];
    }];
    
    self.pageControl.currentPage = self.currentPage;
}

#pragma mark - 手势
- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture {
    
    if (self.dataArray.count < 2) return;
    
    // 获取到当前cell
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    CGPoint movePoint = [panGesture translationInView:panGesture.view];
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
            // 只允许左右滑动
            if (movePoint.y > 20 || movePoint.y < -20) return;
            
            // 卡片划走的方向 -> 右 下一张
            [self moveCell:cell toNextWithGesture:panGesture point:movePoint];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (self.movingPoint.x > 100) { // 右滑
                
                // 卡片划走的方向 -> 左 下一张
                [self nextPage: XYMovedDirectionRight];
                
            } else if (self.movingPoint.x < -100) { // 左滑
                // 卡片划走的方向 -> 左 下一张
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
    return self.dataArray.count;
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
        //分页控件，本质上和cardView没有任何关系，是2个独立的控件
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.pageIndicatorTintColor = [UIColor yellowColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        _pageControl.currentPage = 0;
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
