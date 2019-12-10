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

import UIKit
import SnapKit

open class AquamanPageViewController: UIViewController, AMPageControllerDataSource, AMPageControllerDelegate {
    
    public private(set) var currentViewController: (UIViewController & AquamanChildViewController)?
    public private(set) var currentIndex = 0
    private var originIndex = 0

    lazy public private(set) var mainScrollView: AquaMainScrollView = {
        let scrollView = AquaMainScrollView()
        scrollView.delegate = self
        scrollView.am_isCanScroll = true
        return scrollView
    }()
    
    lazy private var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        if let popGesture = navigationController?.interactivePopGestureRecognizer {
            scrollView.panGestureRecognizer.require(toFail: popGesture)
        }
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        return stackView
    }()

    private var headerViewHeight: CGFloat = 0.0
    private let headerContentView = UIView()
    private let menuContentView = UIView()
    private var menuViewHeight: CGFloat = 0.0
    private var menuViewPinHeight: CGFloat = 0.0
    private var sillValue: CGFloat = 0.0
    private var childControllerCount = 0
    private var headerView: UIView?
    private var menuView: UIView?
    private var countArray = [Int]()
    private var containViews = [AquamanContainView]()
    private var currentChildScrollView: UIScrollView?
    private var childScrollViewObservation: NSKeyValueObservation?
    
    private let memoryCache = NSCache<NSString, UIViewController>()
    private weak var dataSource: AMPageControllerDataSource?
    private weak var delegate: AMPageControllerDelegate?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dataSource = self
        delegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dataSource = self
        delegate = self
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        obtainDataSource()
        setupOriginContent()
        setupDataSource()
        view.layoutIfNeeded()
        if originIndex > 0 {
            setSelect(index: originIndex, animation: false)
        } else {
            showChildViewContoller(at: originIndex)
            didDisplayViewController(at: originIndex)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainScrollView.isScrollEnabled = true
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainScrollView.isScrollEnabled = false
    }
    
    deinit {
        childScrollViewObservation?.invalidate()
    }
    
    public func updateHeaderViewHeight(animated: Bool = false, duration: TimeInterval = 0.25, completion: ((Bool) -> Void)? = nil) {
        headerViewHeight = headerViewHeightFor(self)
        sillValue = headerViewHeight - menuViewPinHeight
        
        mainScrollView.headerViewHeight = headerViewHeight
        headerContentView.snp.updateConstraints({$0.height.equalTo(headerViewHeight)})
        
        if mainScrollView.contentOffset.y < sillValue {
            currentChildScrollView?.contentOffset = currentChildScrollView?.am_originOffset ?? .zero
            currentChildScrollView?.am_isCanScroll = false
            mainScrollView.am_isCanScroll = true
        }
        pageController(self, menuView: !mainScrollView.am_isCanScroll)
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.mainScrollView.layoutIfNeeded()
            }) { (finish) in
                completion?(finish)
            }
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
    
    private func didDisplayViewController(at index: Int) {
        guard childControllerCount > 0
            , index >= 0
            , index < childControllerCount
            , containViews.isEmpty == false else {
                return
        }
        let containView = containViews[index]
        currentViewController = containView.viewController
        currentChildScrollView = currentViewController?.aquamanChildScrollView()
        currentIndex = index
        
        childScrollViewObservation?.invalidate()
        let keyValueObservation = currentChildScrollView?.observe(\.contentOffset, options: [.new, .old], changeHandler: { [weak self] (scrollView, change) in
            guard let self = self, change.newValue != change.oldValue else {
                return
            }
            self.childScrollViewDidScroll(scrollView)
        })
        childScrollViewObservation = keyValueObservation
        
        if let viewController = containView.viewController {
            pageController(self, didDisplay: viewController, forItemAt: index)
        }
    }
    
    
    private func obtainDataSource() {
        originIndex = originIndexFor(self)
        
        headerView = headerViewFor(self)
        headerViewHeight = headerViewHeightFor(self)
        
        menuView = menuViewFor(self)
        menuViewHeight = menuViewHeightFor(self)
        menuViewPinHeight = menuViewPinHeightFor(self)
        
        childControllerCount = numberOfViewControllers(in: self)
        
        sillValue = headerViewHeight - menuViewPinHeight
        countArray = Array(stride(from: 0, to: childControllerCount, by: 1))
    }
    
    
    private func setupOriginContent() {
        
        mainScrollView.headerViewHeight = headerViewHeight
        mainScrollView.menuViewHeight = menuViewHeight
        
        view.addSubview(mainScrollView)
        mainScrollView.snp.makeConstraints({$0.edges.equalTo(contentInsetFor(self))})
        
        mainScrollView.addSubview(headerContentView)
        headerContentView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(headerViewHeight)
        }
        
        mainScrollView.addSubview(menuContentView)
        menuContentView.snp.makeConstraints { (make) in
            make.leading.equalTo(mainScrollView)
            make.trailing.equalTo(mainScrollView)
            make.width.equalTo(mainScrollView)
            make.top.equalTo(headerContentView.snp.bottom)
            make.height.equalTo(menuViewHeight)
        }
        
        mainScrollView.addSubview(contentScrollView)
        
        contentScrollView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(menuContentView.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(-menuViewHeight - menuViewPinHeight)
        }
        
        
        contentScrollView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        mainScrollView.bringSubviewToFront(menuContentView)
    }
    
    private func updateOriginContent() {
        mainScrollView.headerViewHeight = headerViewHeight
        mainScrollView.menuViewHeight = menuViewHeight
        mainScrollView.snp.updateConstraints({$0.edges.equalTo(contentInsetFor(self))})
        headerContentView.snp.updateConstraints({$0.height.equalTo(headerViewHeight)})
        menuContentView.snp.updateConstraints({$0.height.equalTo(menuViewHeight)})
        contentScrollView.snp.updateConstraints({$0.height.equalToSuperview().offset(-menuViewHeight - menuViewPinHeight)})
    }
    
    private func clear() {
        childScrollViewObservation?.invalidate()
        
        originIndex = 0
        
        mainScrollView.am_isCanScroll = true
        currentChildScrollView?.am_isCanScroll = false
        
        childControllerCount = 0
        
        currentViewController = nil
        currentChildScrollView?.am_originOffset = nil
        currentChildScrollView = nil
        
        headerView?.removeFromSuperview()
        contentScrollView.contentOffset = .zero
        
        contentStackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        clearMemoryCache()
        
        containViews.forEach({$0.viewController?.clearFromParent()})
        containViews.removeAll()
        
        countArray.removeAll()
    }
    
    internal func clearMemoryCache() {
        countArray.forEach { (index) in
            let viewController = memoryCache[index] as? (UIViewController & AquamanChildViewController)
            let scrollView = viewController?.aquamanChildScrollView()
            scrollView?.am_originOffset = nil
        }
        memoryCache.removeAllObjects()
    }
    
    private func setupDataSource() {
        memoryCache.countLimit = childControllerCount
        
        if let headerView = headerView {
            headerContentView.addSubview(headerView)
            headerView.snp.makeConstraints({$0.edges.equalToSuperview()})
        }
        
        if let menuView = menuView {
            menuContentView.addSubview(menuView)
            menuView.snp.makeConstraints({$0.edges.equalToSuperview()})
        }
        
        countArray.forEach { (_) in
            let containView = AquamanContainView()
            contentStackView.addArrangedSubview(containView)
            containView.snp.makeConstraints({$0.size.equalTo(contentScrollView)})
            containViews.append(containView)
        }
    }
    
    private func showChildViewContoller(at index: Int) {
        guard childControllerCount > 0
            , index >= 0
            , index < childControllerCount
            , containViews.isEmpty == false else {
            return
        }
        
        let containView = containViews[index]
        guard containView.isEmpty else {
            return
        }
        
        let cachedViewContoller = memoryCache[index] as? (UIViewController & AquamanChildViewController)
        let viewController = cachedViewContoller != nil ? cachedViewContoller : pageController(self, viewControllerAt: index)
        
        guard let targetViewController = viewController else {
            return
        }
        pageController(self, willDisplay: targetViewController, forItemAt: index)
        
        addChild(targetViewController)
        containView.addSubview(targetViewController.view)
        targetViewController.view.snp.makeConstraints({$0.edges.equalToSuperview()})
        
        targetViewController.didMove(toParent: self)
        targetViewController.view.layoutSubviews()
        containView.viewController = targetViewController
        
        let scrollView = targetViewController.aquamanChildScrollView()
        scrollView.am_originOffset = scrollView.contentOffset
        
        if mainScrollView.contentOffset.y < sillValue {
            scrollView.contentOffset = scrollView.am_originOffset ?? .zero
            scrollView.am_isCanScroll = false
            mainScrollView.am_isCanScroll = true
        }
    }
    
    
    private func removeChildViewController(at index: Int) {
        guard childControllerCount > 0
            , index >= 0
            , index < childControllerCount
            , containViews.isEmpty == false else {
                return
        }
        
        let containView = containViews[index]
        guard containView.isEmpty == false
            , let viewController = containView.viewController else {
            return
        }
        viewController.clearFromParent()
        
        if memoryCache[index] == nil {
            pageController(self, willCache: viewController, forItemAt: index)
            memoryCache[index] = viewController
        }
    }
      
    private func layoutChildViewControlls() {
        countArray.forEach { (index) in
            let containView = containViews[index]
            let isDisplaying = containView.displayingIn(view: view, containView: contentScrollView)
            isDisplaying ? showChildViewContoller(at: index) : removeChildViewController(at: index)
        }
    }
    
    private func contentScrollViewDidEndScroll(_ scrollView: UIScrollView) {
        let scrollViewWidth = scrollView.bounds.width
        guard scrollViewWidth > 0 else {
            return
        }
        
        let offsetX = scrollView.contentOffset.x
        let index = Int(offsetX / scrollViewWidth)
        didDisplayViewController(at: index)
        pageController(self, contentScrollViewDidEndScroll: contentScrollView)
    }
    
    
    open func pageController(_ pageController: AquamanPageViewController, viewControllerAt index: Int) -> (UIViewController & AquamanChildViewController) {
        assertionFailure("Sub-class must implement the AMPageControllerDataSource method")
        return UIViewController() as! (UIViewController & AquamanChildViewController)
    }
    
    open func numberOfViewControllers(in pageController: AquamanPageViewController) -> Int {
        assertionFailure("Sub-class must implement the AMPageControllerDataSource method")
        return 0
    }
    
    open func headerViewFor(_ pageController: AquamanPageViewController) -> UIView {
        assertionFailure("Sub-class must implement the AMPageControllerDataSource method")
        return UIView()
    }
    
    open func headerViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        assertionFailure("Sub-class must implement the AMPageControllerDataSource method")
        return 0
    }
    
    open func menuViewFor(_ pageController: AquamanPageViewController) -> UIView {
        assertionFailure("Sub-class must implement the AMPageControllerDataSource method")
        return UIView()
    }
    
    open func menuViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        assertionFailure("Sub-class must implement the AMPageControllerDataSource method")
        return 0
    }
    
    open func originIndexFor(_ pageController: AquamanPageViewController) -> Int {
        return 0
    }
    
    open func menuViewPinHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return 0
    }
    
    open func pageController(_ pageController: AquamanPageViewController, mainScrollViewDidScroll scrollView: UIScrollView) {
        
    }
    
    open func pageController(_ pageController: AquamanPageViewController, contentScrollViewDidEndScroll scrollView: UIScrollView) {
        
    }
    
    open func pageController(_ pageController: AquamanPageViewController, contentScrollViewDidScroll scrollView: UIScrollView) {
        
    }
    
    open func pageController(_ pageController: AquamanPageViewController, willCache viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
        
    }
    
    open func pageController(_ pageController: AquamanPageViewController, willDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
        
    }
    
    open func pageController(_ pageController: AquamanPageViewController, didDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
        
    }
    
    open func pageController(_ pageController: AquamanPageViewController, menuView isAdsorption: Bool) {
        
    }
    
    open func contentInsetFor(_ pageController: AquamanPageViewController) -> UIEdgeInsets {
        return .zero
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
    private func childScrollViewDidScroll(_ scrollView: UIScrollView) {
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

