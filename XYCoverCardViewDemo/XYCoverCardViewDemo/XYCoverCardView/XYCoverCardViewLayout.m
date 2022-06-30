//
//  XYCoverCardViewLayout.m
//  LNHealthWatch
//
//  Created by xiaoyan on 2021/11/17.
//  Copyright © 2021 ecsage. All rights reserved.
//

#import "XYCoverCardViewLayout.h"

@interface XYCoverCardViewLayout ()
@property (nonatomic, strong) NSMutableArray *cachedAttributes;
@property (nonatomic, assign) CGRect contentBounds;
/// 卡片左右之间的距离
@property (nonatomic, assign) CGFloat lineSpacing;
/// 卡片底部之间的距离
@property (nonatomic, assign) CGFloat interitemSpacing;
@end

@implementation XYCoverCardViewLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.lineSpacing = 15;
    self.interitemSpacing = 15;
    
    [self.cachedAttributes removeAllObjects];
    self.contentBounds = CGRectMake(0, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    NSInteger currentIndex = 0;
    
    while (currentIndex < count) {
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0]];
        attributes.frame = self.collectionView.bounds;
        
        // 计算每个 cell 的宽度和高度
        CGFloat width = self.collectionView.bounds.size.width - currentIndex * self.lineSpacing * 2.0;
        CGFloat height = self.collectionView.bounds.size.height - currentIndex * self.interitemSpacing * 2.0;
        // 计算出缩放的比例
        CGFloat scaleX = width / attributes.bounds.size.width;
        CGFloat scaleY = height / attributes.bounds.size.height;
        
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scaleX, scaleY);
        
        CGAffineTransform transform = CGAffineTransformTranslate(scaleTransform, 0, currentIndex * self.interitemSpacing * 2.0);
        attributes.transform = transform;
        [self.cachedAttributes insertObject:attributes atIndex:0];
        
        if (currentIndex == 0) {
            attributes.transform = CGAffineTransformIdentity;
        }
        
        currentIndex += 1;
    }
}

- (CGSize)collectionViewContentSize {
    return self.contentBounds.size;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.cachedAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.cachedAttributes[indexPath.item];
}

#pragma mark - getter
- (NSMutableArray *)cachedAttributes {
    if (_cachedAttributes == nil) {
        _cachedAttributes = [NSMutableArray array];
    }
    return _cachedAttributes;
}

@end
