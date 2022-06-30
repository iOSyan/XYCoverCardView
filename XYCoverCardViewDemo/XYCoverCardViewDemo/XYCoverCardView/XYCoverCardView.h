//
//  XYCoverCardView.h
//  LNHealthWatch
//
//  Created by xiaoyan on 2021/11/17.
//  Copyright © 2021 ecsage. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XYCoverCardView;

NS_ASSUME_NONNULL_BEGIN

typedef  void (^UpdateCallback)(void);
typedef  void (^UpdatesBlock)(void);
typedef  void (^Completion)(BOOL);

@protocol XYCoverCardViewDataSource <NSObject>

@optional
- (NSInteger)numberOfItemsInCoverCardView:(XYCoverCardView *)coverCardView;
- (UICollectionViewCell *)coverCardView:(XYCoverCardView *)coverCardView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

/// 移除cell之后, 调用此方法, 需要从数据源移除model. 数据处理完成之后,必须在最后调用callback闭包
- (void)coverCardView:(XYCoverCardView *)coverCardView didRemoveCell:(UICollectionViewCell *)cell updateCallback:(UpdateCallback)updateCallback;


- (void)coverCardView:(XYCoverCardView *)coverCardView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface XYCoverCardView : UIView

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
