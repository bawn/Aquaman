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

First make sure to import the framework:

```
import Aquaman
```

Basically, we just need to provide the list of child view controllers to show. Then call some necessary methods.

Let's see the steps to do this:

#### Create a AquamanPageViewController subclass

```swift
import Aquaman

class PageViewController: AquamanPageViewController {
  // ...
}
```

#### Provide the view controllers that will appear embedded into the AquamanPageViewController

```swift
override func numberOfViewControllers(in pageController: AquamanPageViewController) -> Int {
    return count
}
    
override func pageController(_ pageController: AquamanPageViewController, viewControllerAt index: Int) -> (UIViewController & AquamanChildViewController) {
    // ...
    return viewController
}
    
```

Every UIViewController that will appear within the AquamanPageViewController should conform to `AquamanChildViewController` by implementing `func aquamanChildScrollView() -> UIScrollView` 

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



#### Provide the headerView and headerView height 

```swift
override func headerViewFor(_ pageController: AquamanPageViewController) -> UIView {
    return HeaderView()
}

override func headerViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
    return headerViewHeight
}
```

#### Provide the menuView and menuView height

```swift
override func menuViewFor(_ pageController: AquamanPageViewController) -> UIView {
    return menuView
}

override func menuViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
    return menuViewHeight
}
```

#### Update menuView's layout when content scroll view did scroll and check state when viewController did end isplay

```swift
override func pageController(_ pageController: AquamanPageViewController, contentScrollViewDidScroll scrollView: UIScrollView) {
    menuView.updateLayout(scrollView)
}

override func pageController(_ pageController: AquamanPageViewController, didDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
        menuView.checkState(animation: true)
}
```



## Examples

Follow these 4 steps to run Example project: 

1. Clone Aquaman repository
2. Run the `pod install` command 
3. Open Aquaman workspace 
4. Run the Aquaman-Demo project.

### License

Aquaman is released under the MIT license. See LICENSE for details.
