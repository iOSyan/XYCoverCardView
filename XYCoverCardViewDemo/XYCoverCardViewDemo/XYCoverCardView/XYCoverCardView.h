//
//  XYCoverCardView.h
//  LNHealthWatch
//
//  Created by xiaoyan on 2021/11/17.
//  Copyright © 2021 ecsage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYCoverCardViewLayout.h"
@class XYCoverCardView;

NS_ASSUME_NONNULL_BEGIN

typedef  void (^UpdatesBlock)(void);
typedef  void (^Completion)(BOOL);

@protocol XYCoverCardViewDataSource <NSObject>

- (UICollectionViewCell *)coverCardView:(XYCoverCardView *)coverCardView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)coverCardView:(XYCoverCardView *)coverCardView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface XYCoverCardView : UIView

/// 覆盖的方向
@property (nonatomic, assign) XYCoverDirectionType coverDirectionType;

/// 自动轮播时间间隔 默认2s
@property (nonatomic, assign) CGFloat timerDuration;

/// 数据数组
@property (nonatomic, strong) NSMutableArray *dataArray;

/// 是否可以把上一张滑回来 默认 - NO
@property (nonatomic, assign) BOOL isCanReverse;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGPoint movingPoint;
@property (nonatomic, weak) id<XYCoverCardViewDataSource> cardViewDataSource;

- (void)registerCellClass:(Class)anyClass forCellWithReuseIdentifier:(NSString *)identifier;
- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(nonnull NSIndexPath *)indexPath;
- (void)reloadData;
- (void)insertCellsAtIndexPath:(NSArray *)indexPaths;
- (void)performBatchUpdates:(UpdatesBlock)updates completion:(Completion)completion;

@end

NS_ASSUME_NONNULL_END
