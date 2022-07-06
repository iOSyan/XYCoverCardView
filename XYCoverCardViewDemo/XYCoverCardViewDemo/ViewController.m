//
//  ViewController.m
//  XYCoverCardViewDemo
//
//  Created by ecsage on 2022/6/30.
//

#import "ViewController.h"
#import "XYCoverCardView.h"
#import "XYCoverModel.h"
#import "XYCoverCell.h"

@interface ViewController () <XYCoverCardViewDataSource>

@property (nonatomic, strong) XYCoverCardView *cardView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCoverView];
}

- (void)setupCoverView {
    self.cardView = [[XYCoverCardView alloc] initWithFrame:CGRectMake(0, 0, 280, 180)];
    self.cardView.dataArray = self.dataArray;
    self.cardView.coverDirectionType = XYCoverDirectionRight;
    self.cardView.movedDirectionType = XYMovedDirectionLeft;
    self.cardView.timerDuration = 2.0;
    
    self.cardView.center = self.view.center;
    [self.cardView registerCellClass:[XYCoverCell class] forCellWithReuseIdentifier:@"cellID"];
    self.cardView.cardViewDataSource = self;
    [self.view addSubview:self.cardView];
}

#pragma mark - XYCoverCardViewDataSource
- (UICollectionViewCell *)coverCardView:(XYCoverCardView *)coverCardView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    XYCoverCell *cell = (XYCoverCell *)[coverCardView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    XYCoverModel *m = self.dataArray[indexPath.item];
    cell.label.text = m.name;
    cell.backgroundColor = [UIColor lightGrayColor];
    return cell;
}

- (void)coverCardView:(XYCoverCardView *)coverCardView didRemoveCell:(UICollectionViewCell *)cell updateCallback:(UpdateCallback)updateCallback {
    XYCoverModel *model = self.dataArray[0];
    [self.dataArray removeObjectAtIndex:0];
    
    [coverCardView performBatchUpdates:^{
        if (coverCardView.collectionView.subviews.count == 2) {
            // 如果只有两个 是两个Indicator 没有items
            return;
        }
        [coverCardView.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
    } completion:^(BOOL finished) {
        NSArray *indexes = @[[NSIndexPath indexPathForItem:self.dataArray.count inSection:0]];
        [self.dataArray addObject:model];
        [coverCardView insertCellsAtIndexPath:indexes];
        
        if (updateCallback) {
            updateCallback();
        }
    }];
}

- (void)coverCardView:(XYCoverCardView *)coverCardView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    XYCoverModel *m = self.dataArray[indexPath.item];
    NSLog(@"%@", m.name);
}

#pragma mark - getter
- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
        for (int i = 0; i < 4; i++) {
            XYCoverModel *m = [[XYCoverModel alloc] init];
            m.name = [NSString stringWithFormat:@"%d", i];
            [_dataArray addObject:m];
        }
    }
    return _dataArray;
}


@end
