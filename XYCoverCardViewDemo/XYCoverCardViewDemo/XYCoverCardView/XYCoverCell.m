//
//  XYCoverCell.m
//  LNHealthWatch
//
//  Created by xiaoyan on 2021/11/17.
//  Copyright © 2021 ecsage. All rights reserved.
//

#import "XYCoverCell.h"

@implementation XYCoverCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.shadowColor = [[UIColor blueColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 10.0;
        self.layer.shadowOpacity = 0.3;
        self.layer.cornerRadius = 10.0;
        
        CGFloat width = 100;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - width)/2, 50, width, width)];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        self.label = label;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}


@end
