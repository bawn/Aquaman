//
//  MenuView.swift
//  Aquaman-Demo
//
//  Created by bawn on 2018/12/10.
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

enum MenuStyle {
    case textFont(UIFont)
    case normalTextColor(UIColor)
    case selectedTextColor(UIColor)
    case progressColor(UIColor)
    case progressHeight(CGFloat)
}

protocol MenuViewDelegate: class {
    func menuView(_ menuView: MenuView, didSelectedItemAt index: Int)
}

class MenuView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 30.0
        return stackView
    }()
    lazy private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.clipsToBounds = false
        return scrollView
    }()
    private let progressView = UIView()
    private var menuItemViews = [MenuItemView]()
    weak var delegate: MenuViewDelegate?
    
    var textFont = UIFont.systemFont(ofSize: 15.0)
    var normalTextColor = UIColor.darkGray
    var selectedTextColor = UIColor.red
    var progressColor = UIColor.red
    var progressHeight: CGFloat = 2.0
    
    init(parts: MenuStyle...) {
        super.init(frame: .zero)
        for part in parts {
            switch part {
            case .textFont(let font):
                textFont = font
            case .normalTextColor(let color):
                normalTextColor = color
            case .selectedTextColor(let color):
                selectedTextColor = color
            case .progressColor(let color):
                progressColor = color
            case .progressHeight(let height):
                progressHeight = height
            }
        }
        initialize()
    }
    
    
    private var scrollRate: CGFloat = 0.0 {
        didSet {
            currentLabel?.rate = 1.0 - scrollRate
            nextLabel?.rate = scrollRate
        }
    }
    
    var titles = [String]() {
        didSet {
            stackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
            menuItemViews.removeAll()
            guard titles.isEmpty == false else {
                return
            }
            titles.forEach { (item) in
                let label = MenuItemView(textFont, normalTextColor, selectedTextColor)
                label.text = item
                label.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(titleTapAction(_:)))
                label.addGestureRecognizer(tap)
                stackView.addArrangedSubview(label)
                label.snp.makeConstraints({ (make) in
                    make.height.equalToSuperview()
                })
                menuItemViews.append(label)
            }

            currentIndex = 0
            
            stackView.layoutIfNeeded()
            let labelWidth = stackView.arrangedSubviews.first?.bounds.width ?? 0.0
            let offset = stackView.arrangedSubviews.first?.frame.midX ?? 0.0
            progressView.snp.updateConstraints { (make) in
                make.width.equalTo(labelWidth)
                make.centerX.equalTo(scrollView.snp.leading).offset(offset)
            }
            checkState(animation: false)
        }
    }
    
    private var itemSpace: CGFloat {
        guard let currentLabel = currentLabel
            , let nextLabel = nextLabel else {
                return 0.0
        }
        
        let value = nextLabel.frame.minX - currentLabel.frame.midX + nextLabel.bounds.width * 0.5
        return value
    }
    
    private var widthDifference: CGFloat {
        guard let currentLabel = currentLabel
            , let nextLabel = nextLabel else {
                return 0.0
        }
        
        let value = nextLabel.bounds.width - currentLabel.bounds.width
        return value
    }
    
    private var nextIndex = Int.max {
        didSet {
            guard nextIndex < titles.count
                , nextIndex >= 0
                , oldValue != nextIndex else {
                return
            }
            nextLabel = menuItemViews[nextIndex]
        }
    }
    
    private var currentIndex = Int.max {
        didSet {
            guard currentIndex < titles.count
                , currentIndex >= 0
                , oldValue != currentIndex else {
                return
            }
            nextIndex = currentIndex + 1
            currentLabel = menuItemViews[currentIndex]
        }
    }
    private var currentLabel: MenuItemView?
    private var nextLabel: MenuItemView?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initialize() {
        backgroundColor = .white
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(24.0)
            make.trailing.equalToSuperview().offset(-24.0)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        progressView.backgroundColor = progressColor
        progressView.layer.cornerRadius = 1.0
        scrollView.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.width.equalTo(0.0)
            make.height.equalTo(progressHeight)
            make.centerX.equalTo(scrollView.snp.leading).offset(0)
            make.bottom.equalToSuperview()
        }
        
        layer.shadowRadius = 4
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.05
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    func clear() {
        stackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        menuItemViews.removeAll()
    }
    
    @objc private func titleTapAction(_ sender: UIGestureRecognizer) {
        guard let targetView = sender.view
            , let index = stackView.arrangedSubviews.firstIndex(of: targetView) else {
            return
        }
        delegate?.menuView(self, didSelectedItemAt: index)
    }
    
    
    func updateLayout(_ externalScrollView: UIScrollView) {
        guard currentIndex >= 0, currentIndex < titles.count else {
            return
        }
        let scrollViewWidth = externalScrollView.bounds.width
        let offsetX = externalScrollView.contentOffset.x
        let index = Int(offsetX / scrollViewWidth)
        guard index >= 0, index < titles.count else {
            return
        }
        
        currentIndex = index
        scrollRate = (offsetX - CGFloat(currentIndex) * scrollViewWidth) / scrollViewWidth
        
        let currentWidth = stackView.arrangedSubviews[currentIndex].bounds.width
        let leadingMargin = stackView.arrangedSubviews[currentIndex].frame.midX

        progressView.snp.updateConstraints { (make) in
            make.width.equalTo(widthDifference * scrollRate + currentWidth)
            make.centerX.equalTo(scrollView.snp.leading).offset(leadingMargin + itemSpace * scrollRate)
        }
    }
    
    func checkState(animation: Bool) {
        guard currentIndex >= 0
            , currentIndex < titles.count
            , let currentLabel = currentLabel else {
            return
        }
        menuItemViews.forEach({$0.textColor = normalTextColor})
        menuItemViews[currentIndex].textColor = selectedTextColor
        scrollView.scrollToSuitablePosition(currentLabel, animation)
    }
}

