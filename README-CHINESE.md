# Aquaman

![License MIT](https://img.shields.io/dub/l/vibe-d.svg)
![Pod version](http://img.shields.io/cocoapods/v/Aquaman.svg?style=flat)
![Platform info](http://img.shields.io/cocoapods/p/LCNetwork.svg?style=flat)
[![Support](https://img.shields.io/badge/support-iOS9.0+-blue.svg?style=flat)](https://www.apple.com/nl/ios/)
[![Swift 4.2](https://camo.githubusercontent.com/cc157628e33009bbb18f6e476955a0f641f407d9/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f53776966742d342e322d6f72616e67652e7376673f7374796c653d666c6174)](https://developer.apple.com/swift/)

A pure-Swift library for nested display of horizontal and vertical scrolling views.

![demo](./demo.gif)

## Requirements

- iOS 9.0+ 
- Swift 4.2+
- Xcode 10+



## Installation

#### [CocoaPods](http://cocoapods.org/) (recommended)

```
use_frameworks!

pod 'Aquaman'
```

## Usage

首先需要导入 Aquaman

```
import Aquaman
```



#### 创建 AquamanPageViewController 子类

```swift
import Aquaman

class PageViewController: AquamanPageViewController {
  // ...
}
```

#### 重写协议方法以提供 viewController 和相应的数量

```swift
override func numberOfViewControllers(in pageController: AquamanPageViewController) -> Int {
    return count
}
    
override func pageController(_ pageController: AquamanPageViewController, viewControllerAt index: Int) -> (UIViewController & AquamanChildViewController) {
    // ...
    return viewController
}
    
```

注意：所提供的 viewController 必须都遵守 `AquamanChildViewController` 协议，并实现 `func aquamanChildScrollView() -> UIScrollView` 方法

```swift
import Aquaman
class ChildViewController: UIViewController, AquamanChildViewController {

    @IBOutlet weak var tableView: UITableView!
    func aquamanChildScrollView() -> UIScrollView {
        return tableView
    }
    // ...
}
```



#### 重写协议方法以提供 headerView 及其高度

```swift
override func headerViewFor(_ pageController: AquamanPageViewController) -> UIView {
    return HeaderView()
}

override func headerViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
    return headerViewHeight
}
```

#### 重写协议方法以提供 menuView 及其高度

```swift
override func menuViewFor(_ pageController: AquamanPageViewController) -> UIView {
    return menuView
}

override func menuViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
    return menuViewHeight
}
```

考虑到有时候 menuView 需要高度的定制性，所以设计成由开发者自行提供（demo 中有 menuView 的实现方法）。

#### 更新 menuView 的布局

```swift
override func pageController(_ pageController: AquamanPageViewController, contentScrollViewDidScroll scrollView: UIScrollView) {
    menuView.updateLayout(scrollView)
}

override func pageController(_ pageController: AquamanPageViewController,
                             contentScrollViewDidEndScroll scrollView: UIScrollView) {
    menuView.checkState()
}
```

包括在内容的滚动的时候和停止滚动的时候，具体可参考 demo

## Examples

Follow these 4 steps to run Example project: 

1. Clone Aquaman repository
2. Run the `pod install` command 
3. Open Aquaman workspace 
4. Run the Aquaman-Demo project.

### License

Aquaman is released under the MIT license. See LICENSE for details.
