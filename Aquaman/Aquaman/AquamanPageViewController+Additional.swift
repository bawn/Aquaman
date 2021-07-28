//
//  AquamanPageViewController.swift
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

extension AquamanPageViewController {
    public func updateHeaderViewHeight(animated: Bool = false,
                                       duration: TimeInterval = 0.25,
                                       completion: ((Bool) -> Void)? = nil) {
        
        headerViewHeight = headerViewHeightFor(self)
        sillValue = headerViewHeight - menuViewPinHeight
        
        mainScrollView.headerViewHeight = headerViewHeight
        headerViewConstraint?.constant = headerViewHeight
        
        var manualHandel = false
        if mainScrollView.contentOffset.y < sillValue {
            currentChildScrollView?.contentOffset = currentChildScrollView?.am_originOffset ?? .zero
            currentChildScrollView?.am_isCanScroll = false
            mainScrollView.am_isCanScroll = true
            manualHandel = true
        } else if mainScrollView.contentOffset.y == sillValue  {
            mainScrollView.am_isCanScroll = false
            manualHandel = true
        }
        let isAdsorption = (headerViewHeight <= 0.0) ? true : !mainScrollView.am_isCanScroll
        if animated {
            UIView.animate(withDuration: duration, animations: {
                self.mainScrollView.layoutIfNeeded()
                if manualHandel {
                    self.pageController(self, menuView: isAdsorption)
                }
            }) { (finish) in
                completion?(finish)
            }
        } else {
            self.pageController(self, menuView: isAdsorption)
            completion?(true)
        }
    }
    
    public func setSelect(index: Int, animation: Bool) {
        let offset = CGPoint(x: contentScrollView.bounds.width * CGFloat(index),
                             y: contentScrollView.contentOffset.y)
        contentScrollView.setContentOffset(offset, animated: animation)
        if animation == false {
            contentScrollViewDidEndScroll(contentScrollView)
        }
    }
    
    public func scrollToTop(_ animation: Bool) {
        currentChildScrollView?.setContentOffset(currentChildScrollView?.am_originOffset ?? .zero, animated: true)
        mainScrollView.am_isCanScroll = true
        mainScrollView.setContentOffset(.zero, animated: animation)
    }
    
    public func reloadData() {
        mainScrollView.isUserInteractionEnabled = false
        clear()
        obtainDataSource()
        updateOriginContent()
        setupDataSource()
        view.layoutIfNeeded()
        if originIndex > 0 {
            setSelect(index: originIndex, animation: false)
        } else {
            showChildViewContoller(at: originIndex)
            didDisplayViewController(at: originIndex)
        }
        mainScrollView.isUserInteractionEnabled = true
    }
}


extension AquamanPageViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == mainScrollView {
            pageController(self, mainScrollViewDidScroll: scrollView)
            let offsetY = scrollView.contentOffset.y
            if offsetY >= sillValue {
                scrollView.contentOffset = CGPoint(x: 0, y: sillValue)
                currentChildScrollView?.am_isCanScroll = true
                scrollView.am_isCanScroll = false
                pageController(self, menuView: !scrollView.am_isCanScroll)
            } else {
                
                if scrollView.am_isCanScroll == false {
                    pageController(self, menuView: true)
                    scrollView.contentOffset = CGPoint(x: 0, y: sillValue)
                } else {
                    pageController(self, menuView: false)
                }
            }
        } else {
            pageController(self, contentScrollViewDidScroll: scrollView)
            layoutChildViewControlls()
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == contentScrollView {
            mainScrollView.isScrollEnabled = false
        }
    }

    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == contentScrollView {
            mainScrollView.isScrollEnabled = true
            if decelerate == false {
                contentScrollViewDidEndScroll(contentScrollView)
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == contentScrollView {
            contentScrollViewDidEndScroll(contentScrollView)
        }
    }
    
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == contentScrollView {
            contentScrollViewDidEndScroll(contentScrollView)
        }
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        guard scrollView == mainScrollView else {
            return false
        }
        currentChildScrollView?.setContentOffset(currentChildScrollView?.am_originOffset ?? .zero, animated: true)
        return true
    }
    
}

extension AquamanPageViewController {
    internal func childScrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.am_isCanScroll == false {
            scrollView.contentOffset = scrollView.am_originOffset ?? .zero
        }
        let offsetY = scrollView.contentOffset.y
        if offsetY <= (scrollView.am_originOffset ?? .zero).y {
            scrollView.contentOffset = scrollView.am_originOffset ?? .zero
            scrollView.am_isCanScroll = false
            mainScrollView.am_isCanScroll = true
        }
    }
}
