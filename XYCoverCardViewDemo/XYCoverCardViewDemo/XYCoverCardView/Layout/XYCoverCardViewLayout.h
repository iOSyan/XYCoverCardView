//
//  XYCoverCardViewLayout.h
//  LNHealthWatch
//
//  Created by xiaoyan on 2021/11/17.
//  Copyright © 2021 ecsage. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 覆盖的方向
typedef NS_ENUM(NSInteger, XYCoverDirectionType)
{
    XYCoverDirectionRight,
    XYCoverDirectionBottom,
};

@interface XYCoverCardViewLayout : UICollectionViewLayout

/// 覆盖的方向
@property (nonatomic, assign) XYCoverDirectionType coverDirectionType;

/// 卡片左右之间的距离
@property (nonatomic, assign) CGFloat lineSpacing;
/// 卡片上下之间的距离
@property (nonatomic, assign) CGFloat itemSpacing;

@end

NS_ASSUME_NONNULL_END
