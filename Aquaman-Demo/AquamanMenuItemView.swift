//
//  AquamanMenuItemView.swift
//  Aquaman-Demo
//
//  Created by bawn on 2018/12/11.
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

class AquamanMenuItemView: UILabel {
    var normalTextColor = UIColor.gray
    var selectedTextColor = UIColor.red
    var normalTextFont = UIFont.systemFont(ofSize: 15.0)
    var selectedTextFont = UIFont.systemFont(ofSize: 15.0)
    
    lazy var normalColors = normalTextColor.rgb
    lazy var selectedColors = selectedTextColor.rgb
    
    var rate: CGFloat = 0.0 {
        didSet {
            guard rate > 0.0, rate < 1.0 else {
                return
            }
            let r = normalColors.red + (selectedColors.red - normalColors.red) * rate
            let g = normalColors.green + (selectedColors.green - normalColors.green) * rate
            let b = normalColors.blue + (selectedColors.blue - normalColors.blue) * rate
            let a = normalColors.alpha + (selectedColors.alpha - normalColors.alpha) * rate
            
            textColor = UIColor(red: r, green: g, blue: b, alpha: a)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        font = normalTextFont
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

