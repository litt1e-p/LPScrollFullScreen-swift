//
//  ViewController.swift
//  LPScrollFullScreen-swift
//
//  Created by litt1e-p on 16/1/15.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var webView: UIWebView?
    var scrollProxy: LPScrollFullScreen?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = UIWebView(frame: self.view.frame)
        self.view.addSubview(webView!)
        scrollProxy = LPScrollFullScreen(forwardTarget: self)
        webView?.scrollView.delegate = scrollProxy
        webView?.loadRequest(NSURLRequest(URL: NSURL(string: "https://www.github.com")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

