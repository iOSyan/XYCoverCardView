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
    self.cardView = [[XYCoverCardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-60, 180)];
    self.cardView.backgroundColor = [UIColor lightGrayColor];
    self.cardView.dataArray = self.dataArray;
    self.cardView.coverDirectionType = XYCoverDirectionRight;
    self.cardView.timerDuration = 5.0;
    self.cardView.isCanReverse = YES;
    
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
    cell.backgroundColor = [self randomColor];
    return cell;
}

- (void)coverCardView:(XYCoverCardView *)coverCardView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    XYCoverModel *m = self.dataArray[indexPath.item];
    NSLog(@"%@", m.name);
}

#pragma mark - getter
- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            XYCoverModel *m = [[XYCoverModel alloc] init];
            m.name = [NSString stringWithFormat:@"%d", i];
            [_dataArray addObject:m];
        }
    }
    return _dataArray;
}

- (UIColor *)randomColor {

    CGFloat hue = ( arc4random() % 256 / 256.0 );  //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}


@end
