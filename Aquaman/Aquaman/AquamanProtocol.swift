//
//  AquamanProtocol.swift
//  Aquaman
//
//  Created by bawn on 2018/12/7.
//  Copyright © 2018 bawn. All rights reserved.( http://bawn.github.io )
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import UIKit

protocol AMPageControllerDataSource: class {
    
    func pageController(_ pageController: AquamanPageViewController, viewControllerAt index: Int) -> (UIViewController & AquamanChildViewController)
    func numberOfViewControllers(in pageController: AquamanPageViewController) -> Int
    func headerViewFor(_ pageController: AquamanPageViewController) -> UIView
    func headerViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat
    func menuViewFor(_ pageController: AquamanPageViewController) -> UIView
    func menuViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat
    func menuViewPinHeightFor(_ pageController: AquamanPageViewController) -> CGFloat
    
    /// The index of the controller displayed by default. You should have menview ready before setting this value
    ///
    /// - Parameter pageController: AquamanPageViewController
    /// - Returns: Int
    func originIndexFor(_ pageController: AquamanPageViewController) -> Int
}

protocol AMPageControllerDelegate: class {
    
    /// Any offset changes in pageController's mainScrollView
    ///
    /// - Parameters:
    ///   - pageController: AquamanPageViewController
    ///   - scrollView: mainScrollView
    func pageController(_ pageController: AquamanPageViewController, mainScrollViewDidScroll scrollView: UIScrollView)
   
    
    /// Method call when contentScrollView did end scroll
    ///
    /// - Parameters:
    ///   - pageController: AquamanPageViewController
    ///   - scrollView: contentScrollView
    func pageController(_ pageController: AquamanPageViewController, contentScrollViewDidEndScroll scrollView: UIScrollView)
    
    
    /// Any offset changes in pageController's contentScrollView
    ///
    /// - Parameters:
    ///   - pageController: AquamanPageViewController
    ///   - scrollView: contentScrollView
    func pageController(_ pageController: AquamanPageViewController, contentScrollViewDidScroll scrollView: UIScrollView)
    
    /// Method call when viewController will cache
    ///
    /// - Parameters:
    ///   - pageController: AquamanPageViewController
    ///   - viewController: target viewController
    ///   - index: target viewController's index
    func pageController(_ pageController: AquamanPageViewController, willCache viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int)
    
    
    /// Method call when viewController will display
    ///
    /// - Parameters:
    ///   - pageController: AquamanPageViewController
    ///   - viewController: target viewController
    ///   - index: target viewController's index
    func pageController(_ pageController: AquamanPageViewController, willDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int)
    
    
    /// Method call when viewController did display
    ///
    /// - Parameters:
    ///   - pageController: AquamanPageViewController
    ///   - viewController: target viewController
    ///   - index: target viewController's index
    func pageController(_ pageController: AquamanPageViewController, didDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int)
    
    
    /// Method call when menuView is adsorption
    ///
    /// - Parameters:
    ///   - pageController: AquamanPageViewController
    ///   - isAdsorption: is adsorption
    func pageController(_ pageController: AquamanPageViewController, menuView isAdsorption: Bool)
    
    
    /// Asks the delegate for the margins to apply to content.
    /// - Parameter pageController: AquamanPageViewController
    func contentInsetFor(_ pageController: AquamanPageViewController) -> UIEdgeInsets
    
}
