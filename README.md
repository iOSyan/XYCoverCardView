# XYCoverCardView
### 如果有任何疑问或新的需求可发邮件：ioshxy@163.com 如果有需要可以开发Swift版本。

CoverCardView， 叠加的轮播view，类似知乎的回答问题。及like or pass。可定时轮播。  
可以用于Banner，或者广告推广展示。


2022.9.6-Notice:
- 如果自定义cell，子控件用frame添加时，应避免将子控件的frame设为cell.frame。
- 需用cell.bounds来替代。
```
    view.frame = self.bounds;
```
- 主要原因是一开始cell.frame.origin的x,y都不是0,0。


2022.07.11-新增加：
- 可以手动返回上一张。
- 在分支dev-reverse里。下次有空的时候会合并分支。
```swift
    self.cardView.isCanReverse = YES;
```
<img src="https://github.com/iOSyan/XYCoverCardView/blob/dev-reverse/preview-reverse.gif?raw=true" width=30%>    


2022.07.06-新增加：
- 右边重叠效果
- 自动轮播的方向可以自行设置
```swift
    // 重叠的方向
    self.cardView.coverDirectionType = XYCoverDirectionRight;
    // 移动的方向
    self.cardView.movedDirectionType = XYMovedDirectionLeft;
```
<img src="https://github.com/iOSyan/XYCoverCardView/blob/main/preview1.gif?raw=true" width=30%>  

```swift
    // 重叠的方向
    self.cardView.coverDirectionType = XYCoverDirectionBottom;
    // 移动的方向
    self.cardView.movedDirectionType = XYMovedDirectionRight;
```
<img src="https://github.com/iOSyan/XYCoverCardView/blob/main/preview.gif?raw=true" width=30%>


#### 在早期项目中用到的，所以抽取出来，封装的比较粗糙，如果有实际需求欢迎提出，会继续改进。
