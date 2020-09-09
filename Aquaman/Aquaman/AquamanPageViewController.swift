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

open class AquamanPageViewController: UIViewController, AMPageControllerDataSource, AMPageControllerDelegate {
    
    public private(set) var currentViewController: (UIViewController & AquamanChildViewController)?
    public private(set) var currentIndex = 0
    internal var originIndex = 0

    lazy public private(set) var mainScrollView: AquaMainScrollView = {
        let scrollView = AquaMainScrollView()
        scrollView.delegate = self
        scrollView.am_isCanScroll = true
        return scrollView
    }()
    
    lazy internal var contentScrollView: UIScrollView = {
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
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var contentScrollViewConstraint: NSLayoutConstraint?
    private var menuViewConstraint: NSLayoutConstraint?
    internal var headerViewConstraint: NSLayoutConstraint?
    private var mainScrollViewConstraints: [NSLayoutConstraint] = []
    
    internal var headerViewHeight: CGFloat = 0.0
    private let headerContentView = UIView()
    private let menuContentView = UIView()
    private var menuViewHeight: CGFloat = 0.0
    internal var menuViewPinHeight: CGFloat = 0.0
    internal var sillValue: CGFloat = 0.0
    private var childControllerCount = 0
    private var countArray = [Int]()
    private var containViews = [AquamanContainView]()
    internal var currentChildScrollView: UIScrollView?
    private var childScrollViewObservation: NSKeyValueObservation?
    
    private let memoryCache = NSCache<NSString, UIViewController>()
    private weak var dataSource: AMPageControllerDataSource?
    private weak var delegate: AMPageControllerDelegate?
    
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
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
    
    deinit {
        childScrollViewObservation?.invalidate()
    }
    
    internal func didDisplayViewController(at index: Int) {
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
    
    
    internal func obtainDataSource() {
        originIndex = originIndexFor(self)
        
        headerViewHeight = headerViewHeightFor(self)
        
        menuViewHeight = menuViewHeightFor(self)
        menuViewPinHeight = menuViewPinHeightFor(self)
        
        childControllerCount = numberOfViewControllers(in: self)
        
        sillValue = headerViewHeight - menuViewPinHeight
        countArray = Array(stride(from: 0, to: childControllerCount, by: 1))
    }
    
    private func setupOriginContent() {
        
        mainScrollView.headerViewHeight = headerViewHeight
        mainScrollView.menuViewHeight = menuViewHeight
        if #available(iOS 13.0, *) {
            mainScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        view.addSubview(mainScrollView)
        let contentInset = contentInsetFor(self)
        let constraints = [
            mainScrollView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: contentInset.top),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentInset.left),
            mainScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -contentInset.bottom),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentInset.right)
        ]
        mainScrollViewConstraints = constraints
        NSLayoutConstraint.activate(constraints)
        
        
        mainScrollView.addSubview(headerContentView)
        headerContentView.translatesAutoresizingMaskIntoConstraints = false
        
        let headerContentViewHeight = headerContentView.heightAnchor.constraint(equalToConstant: headerViewHeight)
        headerViewConstraint = headerContentViewHeight
        NSLayoutConstraint.activate([
            headerContentView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            headerContentView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            headerContentView.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            headerContentViewHeight,
        ])
        
        mainScrollView.addSubview(menuContentView)
        menuContentView.translatesAutoresizingMaskIntoConstraints = false
        
        let menuContentViewHeight = menuContentView.heightAnchor.constraint(equalToConstant: menuViewHeight)
        menuViewConstraint = menuContentViewHeight
        NSLayoutConstraint.activate([
            menuContentView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            menuContentView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            menuContentView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),
            menuContentView.topAnchor.constraint(equalTo: headerContentView.bottomAnchor),
            menuContentViewHeight
        ])
        
        
        mainScrollView.addSubview(contentScrollView)
        
        let contentScrollViewHeight = contentScrollView.heightAnchor.constraint(equalTo: mainScrollView.heightAnchor, constant: -menuViewHeight - menuViewPinHeight)
        contentScrollViewConstraint = contentScrollViewHeight
        NSLayoutConstraint.activate([
            contentScrollView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            contentScrollView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),
            contentScrollView.topAnchor.constraint(equalTo: menuContentView.bottomAnchor),
            contentScrollViewHeight
            ])
        
        
        contentScrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
            contentStackView.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            contentStackView.heightAnchor.constraint(equalTo: contentScrollView.heightAnchor)
        ])
        
        mainScrollView.bringSubviewToFront(menuContentView)
        mainScrollView.bringSubviewToFront(headerContentView)
    }
    
    internal func updateOriginContent() {
        mainScrollView.headerViewHeight = headerViewHeight
        mainScrollView.menuViewHeight = menuViewHeight
        
        if mainScrollViewConstraints.count == 4 {
            let contentInset = contentInsetFor(self)
            mainScrollViewConstraints.first?.constant = contentInset.top
            mainScrollViewConstraints[1].constant = contentInset.left
            mainScrollViewConstraints[2].constant = -contentInset.bottom
            mainScrollViewConstraints.last?.constant = -contentInset.right
        }
        headerViewConstraint?.constant = headerViewHeight
        menuViewConstraint?.constant = menuViewHeight
        contentScrollViewConstraint?.constant = -menuViewHeight - menuViewPinHeight
    }
    
    internal func clear() {
        childScrollViewObservation?.invalidate()
        
        originIndex = 0
        currentIndex = 0
        
        mainScrollView.am_isCanScroll = true
        currentChildScrollView?.am_isCanScroll = false
        
        childControllerCount = 0
        
        currentViewController = nil
        currentChildScrollView?.am_originOffset = nil
        currentChildScrollView = nil
        
        menuContentView.subviews.forEach({$0.removeFromSuperview()})
        headerContentView.subviews.forEach({$0.removeFromSuperview()})
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
    
    internal func setupDataSource() {
        memoryCache.countLimit = childControllerCount
        
        let headerView = headerViewFor(self)
        headerContentView.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: headerContentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: headerContentView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: headerContentView.bottomAnchor),
            headerView.topAnchor.constraint(equalTo: headerContentView.topAnchor)
            ])
        
        let menuView = menuViewFor(self)
        menuContentView.addSubview(menuView)
        menuView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menuView.leadingAnchor.constraint(equalTo: menuContentView.leadingAnchor),
            menuView.trailingAnchor.constraint(equalTo: menuContentView.trailingAnchor),
            menuView.bottomAnchor.constraint(equalTo: menuContentView.bottomAnchor),
            menuView.topAnchor.constraint(equalTo: menuContentView.topAnchor)
            ])
        
        
        countArray.forEach { (_) in
            let containView = AquamanContainView()
            contentStackView.addArrangedSubview(containView)
            NSLayoutConstraint.activate([
                containView.heightAnchor.constraint(equalTo: contentScrollView.heightAnchor),
                containView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor)
                ])
            containViews.append(containView)
        }
    }
    
    internal func showChildViewContoller(at index: Int) {
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
        targetViewController.beginAppearanceTransition(true, animated: false)
        containView.addSubview(targetViewController.view)
        targetViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            targetViewController.view.leadingAnchor.constraint(equalTo: containView.leadingAnchor),
            targetViewController.view.trailingAnchor.constraint(equalTo: containView.trailingAnchor),
            targetViewController.view.bottomAnchor.constraint(equalTo: containView.bottomAnchor),
            targetViewController.view.topAnchor.constraint(equalTo: containView.topAnchor),
            ])
        targetViewController.endAppearanceTransition()
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
      
    internal func layoutChildViewControlls() {
        countArray.forEach { (index) in
            let containView = containViews[index]
            let isDisplayingInScreen = containView.displayingIn(view: view, containView: contentScrollView)
            isDisplayingInScreen ? showChildViewContoller(at: index) : removeChildViewController(at: index)
        }
    }
    
    internal func contentScrollViewDidEndScroll(_ scrollView: UIScrollView) {
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


