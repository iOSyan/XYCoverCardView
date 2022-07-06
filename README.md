# XYCoverCardView
### 如果有任何疑问或新的需求可发邮件：ioshxy@163.com

CoverCardView， 叠加的轮播view，类似知乎的回答问题。及like or pass。可定时轮播。
可以用于Banner，或者广告推广展示。

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
