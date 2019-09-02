//
//  PageViewController.swift
//  Aquaman-Demo
//
//  Created by bawn on 2018/12/8.
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
import MJRefresh
import Aquaman

class PageViewController: AquamanPageViewController {

    let navBar = UIView()
    let menuView = AquamanMenuView(parts:
        .normalTextColor(UIColor.gray),
        .selectedTextColor(UIColor.blue),
        .textFont(UIFont.systemFont(ofSize: 15.0)),
        .progressColor(UIColor.blue),
        .progressHeight(2)
    )
    var count = 3
    var headerViewHeight: CGFloat = 200.0
    var menuViewHeight: CGFloat = 44.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        if #available(iOS 11.0, *) {
            mainScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        navBar.alpha = 0.0
        navBar.backgroundColor = .white
        view.addSubview(navBar)
        navBar.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(UIApplication.shared.statusBarFrame.height + 44.0)
        }
        
        menuView.titles = ["Superman", "Batman", "Wonder Woman"]
        
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(updateData))
        mainScrollView.mj_header = header
        menuView.delegate = self
    }
    
    @objc func updateData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.menuView.titles = ["Superman", "Batman", "Wonder Woman", "The Flash", "Aquaman"]
            self.count = self.menuView.titles.count
            self.headerViewHeight = 120.0
            self.menuViewHeight = 50.0
            self.reloadData()
            self.setSelect(index: 2, animation: false)
            if self.mainScrollView.mj_header.isRefreshing {
                self.mainScrollView.mj_header.endRefreshing()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    
    override func headerViewFor(_ pageController: AquamanPageViewController) -> UIView {
        return HeaderView()
    }
    
    override func headerViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return headerViewHeight
    }
    
    override func numberOfViewControllers(in pageController: AquamanPageViewController) -> Int {
        return count
    }
    
    override func pageController(_ pageController: AquamanPageViewController, viewControllerAt index: Int) -> (UIViewController & AquamanChildViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if index == 0 {
            let viewController = storyboard.instantiateViewController(withIdentifier: "SupermanViewController") as! SupermanViewController
            return viewController
        } else if index == 1 {
            let viewController = storyboard.instantiateViewController(withIdentifier: "BatmanViewController") as! BatmanViewController
            return viewController
        } else {
            let viewController = storyboard.instantiateViewController(withIdentifier: "WonderWomanViewController") as! WonderWomanViewController
            return viewController
        }
    }
    
    
//    override func originIndexFor(_ pageController: AquamanPageViewController) -> Int {
//        return 2
//    }
    
    override func menuViewFor(_ pageController: AquamanPageViewController) -> UIView {
        return menuView
    }
    
    override func menuViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return menuViewHeight
    }
    
    override func menuViewPinHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return UIApplication.shared.statusBarFrame.height + 44.0
    }

    
    override func pageController(_ pageController: AquamanPageViewController, mainScrollViewDidScroll scrollView: UIScrollView) {
        let rate = (UIApplication.shared.statusBarFrame.height * 3.0)
        navBar.alpha = min(scrollView.contentOffset.y / rate, 1.0)
    }
    
    override func pageController(_ pageController: AquamanPageViewController, contentScrollViewDidScroll scrollView: UIScrollView) {
        menuView.updateLayout(scrollView)
    }
    
    override func pageController(_ pageController: AquamanPageViewController,
                                 contentScrollViewDidEndScroll scrollView: UIScrollView) {
        menuView.checkState()
    }
    
    override func pageController(_ pageController: AquamanPageViewController, menuView isAdsorption: Bool) {
        menuView.backgroundColor = isAdsorption ? .black : .white
    }
    
    
    override func pageController(_ pageController: AquamanPageViewController, willDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
    }
    
    override func pageController(_ pageController: AquamanPageViewController, didDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
    }
}


extension PageViewController: AquamanMenuViewDelegate {
    func aquamanMenuView(_ menuView: AquamanMenuView, didSelectedItemAt index: Int) {
        guard index < count else {
            return
        }
        setSelect(index: index, animation: true)
    }
}
