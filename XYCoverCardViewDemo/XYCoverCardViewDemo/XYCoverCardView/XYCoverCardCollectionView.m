//
//  XYCoverCardCollectionView.m
//  LNHealthWatch
//
//  Created by xiaoyan on 2021/11/17.
//  Copyright © 2021 ecsage. All rights reserved.
//

#import "XYCoverCardCollectionView.h"

@implementation XYCoverCardCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    return self;
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    
    if ([subview isKindOfClass:[UICollectionViewCell class]]) {
        [self sendSubviewToBack:subview];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
