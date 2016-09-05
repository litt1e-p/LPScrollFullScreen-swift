
//
//  TableView2Controller.swift
//  LPScrollFullScreen-swift
//
//  Created by litt1e-p on 16/9/5.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

import UIKit

class TableView2Controller: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var scrollProxy: LPScrollFullScreen?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TableView base on code"
        view.addSubview(tableView)
        scrollProxy = LPScrollFullScreen(forwardTarget: self)
        tableView.delegate = scrollProxy
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: String(TableView2Controller))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        showTabBar(false)
        showNavigationBar(false)
        showToolbar(false)
    }
    
    private lazy var tableView: UITableView = {
        let tb = UITableView(frame: self.view.bounds)
        return tb
    } ()
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        navigationController?.pushViewController(ViewController(), animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(String(TableView2Controller), forIndexPath: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}
