//
//  UIViewControllerExtension.swift
//  LPScrollFullScreen-swift
//
//  Created by litt1e-p on 16/1/15.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

import UIKit

let IOS7_OR_LATER = (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 7.0
let IOS8_OR_LATER = (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0
let kNearZero = CGFloat(0.000001)

extension UIViewController {
    
    func showNavigationBar(animated:Bool) {
        let statusBarHeight = self.statusBarHeight()
        let appKeyWindow = UIApplication.sharedApplication().keyWindow
        let appBaseView = appKeyWindow?.rootViewController?.view
        let viewControllerFrame = appBaseView?.convertRect((appBaseView?.bounds)!, toView: appKeyWindow)
        let overwrapStatusBarHeight = statusBarHeight - (viewControllerFrame?.origin.y)!
        self.setNavigationBarOriginY(overwrapStatusBarHeight, animated: animated)
    }
    
    private func statusBarHeight() -> CGFloat {
        let statuBarFrameSize = UIApplication.sharedApplication().statusBarFrame.size
        if IOS8_OR_LATER {
            return statuBarFrameSize.height
        }
        return UIApplication.sharedApplication().statusBarOrientation == .Portrait ? statuBarFrameSize.height : statuBarFrameSize.width
    }
    
    func hideNavigationBar(animated:Bool) {
        let statusBarHeight = self.statusBarHeight()
        let appKeyWindow = UIApplication.sharedApplication().keyWindow
        let appBaseView = appKeyWindow?.rootViewController?.view
        let viewControllerFrame = appBaseView?.convertRect((appBaseView?.bounds)!, toView: appKeyWindow)
        let overwrapStatusBarHeight = statusBarHeight - (viewControllerFrame?.origin.y)!
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        let top = IOS7_OR_LATER ? -CGFloat(navigationBarHeight!) + overwrapStatusBarHeight : -CGFloat(navigationBarHeight!)
        self.setNavigationBarOriginY(top, animated: animated)
    }

    func moveNavigationBar(deltaY: CGFloat, animated: Bool) {
        let frame = self.navigationController?.navigationBar.frame
        let nextY = (frame?.origin.y)! + deltaY
        self.setNavigationBarOriginY(nextY, animated: animated)
    }
    
    func setNavigationBarOriginY(y: CGFloat, animated: Bool) {
        let statusBarHeight = self.statusBarHeight()
        let appKeyWindow = UIApplication.sharedApplication().keyWindow
        let appBaseView = appKeyWindow?.rootViewController?.view
        let viewControllerFrame = appBaseView?.convertRect((appBaseView?.bounds)!, toView: appKeyWindow)
        let overwrapStatusBarHeight = statusBarHeight - (viewControllerFrame?.origin.y)!
        var frame = self.navigationController?.navigationBar.frame
        let navigationBarHeight = frame?.size.height
        let topLimit = IOS7_OR_LATER ? -CGFloat(navigationBarHeight!) + CGFloat(overwrapStatusBarHeight) : -CGFloat(navigationBarHeight!)
        let bottomLimit = overwrapStatusBarHeight
        frame?.origin.y = fmin(fmax(y, topLimit), bottomLimit)
        let navBarHiddenRatio = overwrapStatusBarHeight > 0 ? (overwrapStatusBarHeight - (frame?.origin.y)!) / overwrapStatusBarHeight : 0
        let alpha = max(1.0 - navBarHiddenRatio, kNearZero)
        UIView.animateWithDuration(animated ? 0.1 : 0.0) { () -> Void in
            self.navigationController?.navigationBar.frame = frame!
            var index = 0
            for view: UIView in (self.navigationController?.navigationBar.subviews)! {
                index += 1
                if index == 1 || view.hidden || view.alpha <= 0.0 {
                    continue
                }
                view.alpha = alpha
            }
            if IOS7_OR_LATER {
                if let tintColor = self.navigationController?.navigationBar.tintColor {
                    self.navigationController?.navigationBar.tintColor = tintColor.colorWithAlphaComponent(alpha)
                }
            }
        }
    }

    func showToolbar(animated: Bool) {
        let viewSize = self.navigationController?.view.frame.size
        let viewHeight = self.bottomBarViewControlleViewHeightFromViewSize(viewSize!)
        let toolbarHeight = self.navigationController?.toolbar.frame.size.height
        self.setToolbarOriginY(viewHeight - toolbarHeight!, animated: animated)
    }
    
    private func bottomBarViewControlleViewHeightFromViewSize(viewSize: CGSize) -> CGFloat {
        var viewHeight: CGFloat = 0.0
        if IOS8_OR_LATER {
            viewHeight = viewSize.height
        } else {
            viewHeight = UIApplication.sharedApplication().statusBarOrientation == .Portrait ? viewSize.height : viewSize.width
        }
        return viewHeight
    }
    
    func hideToolbar(animated: Bool) {
        let viewSize = self.navigationController?.view.frame.size
        let viewHeight = self.bottomBarViewControlleViewHeightFromViewSize(viewSize!)
        self.setToolbarOriginY(viewHeight, animated: animated)
    }
    
    func moveToolbar(deltaY: CGFloat, animated: Bool) {
        let frame = self.navigationController?.toolbar.frame
        let nextY = (frame?.origin.y)! + deltaY
        self.setToolbarOriginY(nextY, animated: animated)
    }
    
    func setToolbarOriginY(y: CGFloat, animated: Bool) {
        var frame = self.navigationController?.toolbar.frame
        let toolBarHeight = frame?.size.height
        let viewSize = self.navigationController!.view.frame.size
        let viewHeight = self.bottomBarViewControlleViewHeightFromViewSize(viewSize)
        let topLimit = viewHeight - toolBarHeight!
        let bottomLimit = viewHeight
        frame?.origin.y = fmin(fmax(y, topLimit), bottomLimit)
        UIView.animateWithDuration(animated ? 0.1 : 0) { () -> Void in
            self.navigationController?.toolbar.frame = frame!
        }
    }
    
    func showTabBar(animated: Bool) {
        let viewSize = self.tabBarController?.view.frame.size
        let viewHeight = self.bottomBarViewControlleViewHeightFromViewSize(viewSize!)
        let toolbarHeight = self.tabBarController?.tabBar.frame.size.height
        self.setTabBarOriginY(viewHeight - toolbarHeight!, animated: animated)
    }
    
    func hideTabBar(animated: Bool) {
        let viewSize = self.tabBarController?.view.frame.size
        let viewHeight = self.bottomBarViewControlleViewHeightFromViewSize(viewSize!)
        self.setTabBarOriginY(viewHeight, animated: animated)
    }
    
    func moveTabBar(deltaY: CGFloat, animated: Bool) {
        let frame = self.tabBarController?.tabBar.frame
        let nextY = (frame?.origin.y)! + deltaY
        self.setTabBarOriginY(nextY, animated: animated)
    }
    
    func setTabBarOriginY(y: CGFloat, animated: Bool) {
        var frame = self.tabBarController!.tabBar.frame
        let toolBarHeight = frame.size.height
        let viewSize = self.tabBarController!.view.frame.size
        let viewHeight = self.bottomBarViewControlleViewHeightFromViewSize(viewSize)
        let topLimit = viewHeight - toolBarHeight
        let bottomLimit = viewHeight
        frame.origin.y = fmin(fmax(y, topLimit), bottomLimit)
        UIView.animateWithDuration(animated ? 0.1 : 0.0) { () -> Void in
            self.tabBarController!.tabBar.frame = frame
        }
    }
}
