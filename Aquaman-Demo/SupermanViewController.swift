//
//  SupermanViewController.swift
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
import Aquaman
import MJRefresh

class SupermanViewController: UIViewController, AquamanChildViewController {
    @IBOutlet weak var tableView: UITableView!
    var number = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
    }
    
    func aquamanChildScrollView() -> UIScrollView {
        return tableView
    }
    
    @objc func loadMoreData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.tableView.mj_footer?.isRefreshing ?? false{
                self.tableView.mj_footer?.endRefreshing()
                self.number += 20
                self.tableView.reloadData()
            }
        }
    }
}


extension SupermanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return number
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Update head view height"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Set select"
        } else {
            cell.textLabel?.text = "Title"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let pageViewController = parent as? PageViewController else {
            return
        }
        
        if indexPath.row == 0 {
            
            tableView.isUserInteractionEnabled = false
            var array = [250, 80, 150, 0]
            let headerViewHeight = pageViewController.headerViewHeight
            array.removeAll(where: {$0 == Int(headerViewHeight)})
            pageViewController.headerViewHeight = CGFloat(array.randomElement()!)
            
            pageViewController.updateHeaderViewHeight(animated: true,
                                                      duration: 0.25) { (finish) in
                tableView.isUserInteractionEnabled = true
            }
        } else if indexPath.row == 1 {
            
            pageViewController.setSelect(index: pageViewController.currentIndex + 1,
                                         animation: [true, false].randomElement()!)
        } else {
//            navigationController?.popViewController(animated: true)
            tableView.setEditing(!tableView.isEditing, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        number -= 1
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
