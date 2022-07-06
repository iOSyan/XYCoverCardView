//
//  XYCoverCardViewLayout.m
//  LNHealthWatch
//
//  Created by xiaoyan on 2021/11/17.
//  Copyright © 2021 ecsage. All rights reserved.
//

#import "XYCoverCardViewLayout.h"

@interface XYCoverCardViewLayout ()
@property (nonatomic, strong) NSMutableArray *attributesArray;
@property (nonatomic, assign) CGRect contentBounds;
@end

@implementation XYCoverCardViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.coverDirectionType = XYCoverDirectionBottom;
    self.lineSpacing = 15;
    self.itemSpacing = 15;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self.attributesArray removeAllObjects];
    self.contentBounds = CGRectMake(0, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    NSInteger currentIndex = 0;
    
    while (currentIndex < count) {
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0]];
        attributes.frame = self.collectionView.bounds;
        
        // 计算每个 cell 的宽度和高度
        CGFloat width = self.collectionView.bounds.size.width - currentIndex * self.lineSpacing * 2.0;
        CGFloat height = self.collectionView.bounds.size.height - currentIndex * self.itemSpacing * 2.0;
        // 计算出缩放的比例
        CGFloat scaleX = width / attributes.bounds.size.width;
        CGFloat scaleY = height / attributes.bounds.size.height;
        
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scaleX, scaleY);
        
        CGAffineTransform transform;
        if (self.coverDirectionType == XYCoverDirectionRight) {
            transform = CGAffineTransformTranslate(scaleTransform, currentIndex * self.itemSpacing * 2.0, 0);
        } else {
            transform = CGAffineTransformTranslate(scaleTransform, 0, currentIndex * self.itemSpacing * 2.0);
        }
        
        attributes.transform = transform;
        [self.attributesArray insertObject:attributes atIndex:0];
        
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
    return self.attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.attributesArray[indexPath.item];
}

#pragma mark - getter
- (NSMutableArray *)attributesArray {
    if (_attributesArray == nil) {
        _attributesArray = [NSMutableArray array];
    }
    return _attributesArray;
}

@end
